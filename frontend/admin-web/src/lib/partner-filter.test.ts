import { describe, it, expect } from 'vitest';
import { filterPartners, partnerMatchesFilter, type PartnerFilter } from '@/lib/partner-filter';
import type { DeliveryPartner } from '@/services/delivery';

const partner = (over: Partial<DeliveryPartner>): DeliveryPartner => ({
  id: 'p',
  name: 'Partner',
  phone: '000',
  available: false,
  online: false,
  currentAssignmentId: null,
  lastSeen: '2024-01-01T00:00:00.000Z',
  ...over,
});

const online = partner({ id: 'p1', online: true, available: true, currentAssignmentId: null });
const offline = partner({ id: 'p2', online: false, available: false, currentAssignmentId: null });
const assigned = partner({ id: 'p3', online: true, available: false, currentAssignmentId: 'asg-1' });
const all = [online, offline, assigned];

describe('partnerMatchesFilter (Req 14.3)', () => {
  it('derives each filter from the loaded fields', () => {
    expect(partnerMatchesFilter(online, 'online')).toBe(true);
    expect(partnerMatchesFilter(offline, 'online')).toBe(false);
    expect(partnerMatchesFilter(online, 'available')).toBe(true);
    expect(partnerMatchesFilter(assigned, 'available')).toBe(false);
    expect(partnerMatchesFilter(assigned, 'assigned')).toBe(true);
    expect(partnerMatchesFilter(online, 'assigned')).toBe(false);
  });
});

describe('filterPartners (Req 14.3)', () => {
  it('returns all partners when no filter is active', () => {
    expect(filterPartners(all, new Set())).toEqual(all);
  });

  it('keeps only online partners for the online filter', () => {
    expect(filterPartners(all, new Set<PartnerFilter>(['online']))).toEqual([online, assigned]);
  });

  it('keeps only partners with a non-null assignment for the assigned filter', () => {
    expect(filterPartners(all, new Set<PartnerFilter>(['assigned']))).toEqual([assigned]);
  });

  it('applies multiple active filters with AND semantics', () => {
    // online AND available -> only the online+available partner.
    expect(filterPartners(all, new Set<PartnerFilter>(['online', 'available']))).toEqual([online]);
    // online AND assigned -> only the online+assigned partner.
    expect(filterPartners(all, new Set<PartnerFilter>(['online', 'assigned']))).toEqual([assigned]);
  });
});
