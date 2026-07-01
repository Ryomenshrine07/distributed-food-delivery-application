import fs from 'fs';
import path from 'path';

function walk(dir) {
    let results = [];
    const list = fs.readdirSync(dir);
    list.forEach(file => {
        file = path.resolve(dir, file);
        const stat = fs.statSync(file);
        if (stat && stat.isDirectory()) {
            results = results.concat(walk(file));
        } else {
            results.push(file);
        }
    });
    return results;
}

const files = walk('./src').filter(f => f.endsWith('.tsx') || f.endsWith('.ts'));

for (const file of files) {
    let content = fs.readFileSync(file, 'utf-8');
    let changed = false;

    // Remove unused React import
    if (content.includes("import React from 'react';")) {
        content = content.replace(/import React from 'react';\n?/g, '');
        changed = true;
    }
    
    // Fix specific type imports
    if (file.endsWith('StatusBadge.tsx') && content.includes('OrderStatus')) {
        content = content.replace(/import { OrderStatus } from '@\/types\/order';/, "import { type OrderStatus } from '@/types/order';");
        // Also remove unused OrderStatus in StatusBadge.tsx(3,1) if it's there
        changed = true;
    }
    if (file.endsWith('Login.tsx') && content.includes('LoginDto')) {
        content = content.replace(/import { LoginDto } from '@\/types\/auth';/, "import { type LoginDto } from '@/types/auth';");
        content = content.replace(/import { CardFooter } from '@\/components\/ui\/card';\n?/, "");
        changed = true;
    }
    if (file.endsWith('Restaurants.tsx') && content.includes('ColumnDef')) {
        content = content.replace(/import { ColumnDef } from '@tanstack\/react-table';/, "import { type ColumnDef } from '@tanstack/react-table';");
        content = content.replace(/import { Restaurant } from '@\/types\/restaurant';/, "import { type Restaurant } from '@/types/restaurant';");
        changed = true;
    }
    if (file.endsWith('services/auth.ts')) {
        content = content.replace(/import { api } from '\.\/api';\n?/, "");
        content = content.replace(/import { AuthSession, LoginDto } from '@\/types\/auth';/, "import { type AuthSession, type LoginDto } from '@/types/auth';");
        content = content.replace(/import { AuthSession } from '@\/types\/auth';/, "import { type AuthSession } from '@/types/auth';");
        changed = true;
    }
    if (file.endsWith('services/restaurants.ts')) {
        content = content.replace(/import { Restaurant } from '@\/types\/restaurant';/, "import { type Restaurant } from '@/types/restaurant';");
        changed = true;
    }
    if (file.endsWith('store/session.ts')) {
        content = content.replace(/import { AuthSession } from '@\/types\/auth';/, "import { type AuthSession } from '@/types/auth';");
        changed = true;
    }
    if (file.endsWith('StatusBadge.tsx')) {
         // Also remove unused OrderStatus in StatusBadge.tsx(3,1) if it's there
         // wait, the error TS6133 is about 'OrderStatus' is declared but never read.
         // Wait, the status badge might use it as type. Let's make sure it's just `type OrderStatus`
         content = content.replace(/import { OrderStatus }/g, "import { type OrderStatus }");
         changed = true;
    }

    if (changed) {
        fs.writeFileSync(file, content);
        console.log(`Updated ${file}`);
    }
}
