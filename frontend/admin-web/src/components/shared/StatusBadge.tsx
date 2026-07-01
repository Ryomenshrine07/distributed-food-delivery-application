import { Badge } from '@/components/ui/badge';


interface StatusBadgeProps {
  status: string;
}

export const StatusBadge: React.FC<StatusBadgeProps> = ({ status }) => {
  let variant: 'default' | 'secondary' | 'destructive' | 'outline' | null = 'default';
  let className = '';

  switch (status.toUpperCase()) {
    case 'PENDING':
      variant = 'secondary';
      break;
    case 'ACCEPTED':
    case 'PREPARING':
    case 'READY_FOR_PICKUP':
    case 'OUT_FOR_DELIVERY':
      variant = 'default';
      className = 'bg-blue-100 text-blue-800 hover:bg-blue-100 dark:bg-blue-900/30 dark:text-blue-400';
      break;
    case 'DELIVERED':
    case 'ONLINE':
      variant = 'default';
      className = 'bg-success text-success-foreground hover:bg-success/80';
      break;
    case 'CANCELLED':
    case 'OFFLINE':
      variant = 'destructive';
      break;
    case 'ON_DELIVERY':
      variant = 'default';
      className = 'bg-warning text-warning-foreground hover:bg-warning/80';
      break;
    default:
      variant = 'outline';
  }

  return (
    <Badge variant={variant} className={className}>
      {status.replace(/_/g, ' ')}
    </Badge>
  );
};
