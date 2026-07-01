import { NavLink } from 'react-router-dom';
import { useUiStore } from '@/store/ui';
import { cn } from '@/lib/utils';
import { 
  LayoutDashboard, 
  Store, 
  ShoppingBag, 
  Users, 
  UsersRound, 
  LineChart, 
  Bell, 
  Settings,
  MapPin
} from 'lucide-react';

const navItems = [
  { label: 'Dashboard', path: '/dashboard', icon: LayoutDashboard },
  { label: 'Restaurants', path: '/restaurants', icon: Store },
  { label: 'Orders', path: '/orders', icon: ShoppingBag },
  { label: 'Delivery Partners', path: '/delivery-partners', icon: Users },
  { label: 'Live Map', path: '/live-map', icon: MapPin },
  { label: 'Customers', path: '/customers', icon: UsersRound },
  { label: 'Analytics', path: '/analytics', icon: LineChart },
  { label: 'Notifications', path: '/notifications', icon: Bell },
  { label: 'Settings', path: '/settings', icon: Settings },
];

export const Sidebar = () => {
  const { sidebarOpen } = useUiStore();

  return (
    <aside className={cn(
      "fixed inset-y-0 left-0 z-20 flex h-full flex-col border-r bg-background transition-all duration-300",
      sidebarOpen ? "w-64" : "w-16"
    )}>
      <div className="flex h-14 items-center border-b px-4">
        {sidebarOpen ? (
          <span className="text-lg font-bold">Admin Portal</span>
        ) : (
          <span className="text-lg font-bold">AP</span>
        )}
      </div>
      <nav className="flex-1 space-y-1 p-2 overflow-y-auto">
        {navItems.map((item) => {
          const Icon = item.icon;
          return (
            <NavLink
              key={item.path}
              to={item.path}
              className={({ isActive }) => cn(
                "flex items-center gap-3 rounded-md px-3 py-2 text-sm font-medium transition-colors hover:bg-muted",
                isActive ? "bg-muted text-primary" : "text-muted-foreground"
              )}
              title={item.label}
            >
              <Icon className="h-5 w-5 shrink-0" />
              {sidebarOpen && <span>{item.label}</span>}
            </NavLink>
          );
        })}
      </nav>
    </aside>
  );
};
