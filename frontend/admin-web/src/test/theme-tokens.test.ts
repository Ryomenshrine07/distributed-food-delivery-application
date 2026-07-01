/// <reference types="node" />
import { describe, it, expect } from 'vitest';
import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';

/**
 * Brand-token drift guard (Req 12.6).
 *
 * Parses the ACTUAL source of truth (`src/index.css`) so the test fails if the
 * brand tokens ever drift away from the documented shared Brand_Green.
 *
 *   Brand_Green  #2B9E49  -> oklch(0.617 0.159 148)   (light theme)
 *   Brand_Green  #1F7A38  -> oklch(0.511 0.131 148)   (dark-theme shade)
 *
 * These are exact hex->oklch conversions (sRGB -> linear -> OKLab -> OKLCH).
 */
const BRAND_GREEN_LIGHT = { l: 0.617, c: 0.159, h: 148 };
const BRAND_GREEN_DARK = { l: 0.511, c: 0.131, h: 148 };
// The stale shadcn default that MUST no longer appear on dark --sidebar-primary.
const OLD_PURPLE = { l: 0.488, c: 0.243, h: 264.376 };

// Read the actual stylesheet source so this test guards the real token definitions.
const css = readFileSync(resolve(process.cwd(), 'src/index.css'), 'utf-8');

/** Return the declaration text inside a `selector { ... }` block. */
function blockText(selector: string): string {
  const idx = css.indexOf(selector);
  if (idx === -1) throw new Error(`selector "${selector}" not found in index.css`);
  const open = css.indexOf('{', idx);
  const close = css.indexOf('}', open);
  if (open === -1 || close === -1) throw new Error(`malformed block for "${selector}"`);
  return css.slice(open + 1, close);
}

/** Read a `--name: value` token out of a block. */
function token(block: string, name: string): string {
  const match = block.match(new RegExp(`--${name}\\s*:\\s*([^;\\n}]+)`));
  if (!match) throw new Error(`token --${name} not found`);
  return match[1].trim();
}

/** Parse `oklch(L C H)` into numeric components. */
function parseOklch(value: string): { l: number; c: number; h: number } {
  const match = value.match(/oklch\(\s*([\d.]+)\s+([\d.]+)\s+([\d.]+)/);
  if (!match) throw new Error(`not an oklch value: "${value}"`);
  return { l: Number(match[1]), c: Number(match[2]), h: Number(match[3]) };
}

function expectBrand(
  actual: { l: number; c: number; h: number },
  expected: { l: number; c: number; h: number },
  label: string,
) {
  expect(Math.abs(actual.l - expected.l), `${label} lightness`).toBeLessThanOrEqual(0.02);
  expect(Math.abs(actual.c - expected.c), `${label} chroma`).toBeLessThanOrEqual(0.02);
  expect(Math.abs(actual.h - expected.h), `${label} hue`).toBeLessThanOrEqual(3);
}

const light = blockText(':root');
const dark = blockText('.dark');

describe('brand token drift guard (Req 12.6)', () => {
  it('light --primary equals the documented Brand_Green', () => {
    expectBrand(parseOklch(token(light, 'primary')), BRAND_GREEN_LIGHT, 'light --primary');
  });

  it('dark --primary equals the documented dark Brand_Green shade', () => {
    expectBrand(parseOklch(token(dark, 'primary')), BRAND_GREEN_DARK, 'dark --primary');
  });

  it('light --sidebar-primary equals the documented Brand_Green', () => {
    expectBrand(parseOklch(token(light, 'sidebar-primary')), BRAND_GREEN_LIGHT, 'light --sidebar-primary');
  });

  it('dark --sidebar-primary equals the documented dark Brand_Green shade', () => {
    expectBrand(parseOklch(token(dark, 'sidebar-primary')), BRAND_GREEN_DARK, 'dark --sidebar-primary');
  });

  it('dark --sidebar-primary is no longer the old purple', () => {
    const value = parseOklch(token(dark, 'sidebar-primary'));
    // Hue must be a green (~148), nowhere near the old purple hue (~264).
    expect(Math.abs(value.h - OLD_PURPLE.h)).toBeGreaterThan(50);
    expect(value.c).toBeLessThan(OLD_PURPLE.c);
  });

  it('--ring is brand-tinted (not grayscale) in both themes', () => {
    // A grayscale ring has chroma 0; brand tinting gives it real chroma.
    expect(parseOklch(token(light, 'ring')).c).toBeGreaterThan(0.05);
    expect(parseOklch(token(dark, 'ring')).c).toBeGreaterThan(0.05);
  });

  it('--chart-1 is anchored on the Brand_Green', () => {
    expectBrand(parseOklch(token(light, 'chart-1')), BRAND_GREEN_LIGHT, 'light --chart-1');
  });

  it('leaves --success unchanged as the green anchor reference', () => {
    // Req 12.2 note: --success is intentionally NOT recolored.
    expectBrand(parseOklch(token(light, 'success')), { l: 0.627, c: 0.171, h: 143 }, 'light --success');
  });
});
