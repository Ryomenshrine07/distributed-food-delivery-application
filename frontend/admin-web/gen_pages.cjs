const fs = require('fs');
const pages = [
  'Login', 'Dashboard', 'Restaurants', 'Orders', 
  'DeliveryPartners', 'Customers', 'Analytics', 
  'Notifications', 'Settings', 'NotFound'
];

pages.forEach(page => {
  fs.writeFileSync(`src/pages/${page}.tsx`, `import React from 'react';\n\nexport const ${page} = () => <div>${page} Page</div>;\n`);
});

fs.writeFileSync('src/components/layout/AppShell.tsx', `import React from 'react';\nimport { Outlet } from 'react-router-dom';\n\nexport const AppShell = () => <div>AppShell Layout <Outlet /></div>;\n`);
