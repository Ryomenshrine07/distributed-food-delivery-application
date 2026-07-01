import type { ReactNode } from 'react';
import { Inbox, type LucideIcon } from 'lucide-react';
import { cn } from '@/lib/utils';

interface EmptyStateProps {
  title: string;
  description?: string;
  icon?: LucideIcon;
  action?: ReactNode;
  className?: string;
}

/**
 * Shared empty state (Req 12.5) for async/list pages that resolved with no data.
 */
export const EmptyState = ({
  title,
  description,
  icon: Icon = Inbox,
  action,
  className,
}: EmptyStateProps) => {
  return (
    <div className={cn('flex flex-col items-center justify-center gap-3 py-12 text-center', className)}>
      <div className="rounded-full bg-muted p-4">
        <Icon className="h-8 w-8 text-muted-foreground" aria-hidden="true" />
      </div>
      <div className="space-y-1">
        <h3 className="text-lg font-semibold text-foreground">{title}</h3>
        {description && <p className="max-w-md text-sm text-muted-foreground">{description}</p>}
      </div>
      {action && <div className="mt-2">{action}</div>}
    </div>
  );
};
