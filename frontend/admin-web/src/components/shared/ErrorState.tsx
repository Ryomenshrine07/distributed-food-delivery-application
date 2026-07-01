import { CircleAlert, RefreshCw, type LucideIcon } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { cn } from '@/lib/utils';

interface ErrorStateProps {
  title?: string;
  message?: string;
  icon?: LucideIcon;
  onRetry?: () => void;
  retryLabel?: string;
  className?: string;
}

/**
 * Shared error state (Req 12.5). Replaces ad-hoc `<div>Error...</div>` and,
 * critically for analytics (Req 17.5), is shown on fetch failure INSTEAD of any
 * fabricated fallback numbers. Announces itself via role="alert".
 */
export const ErrorState = ({
  title = 'Something went wrong',
  message = "We couldn't load this data. Please try again.",
  icon: Icon = CircleAlert,
  onRetry,
  retryLabel = 'Retry',
  className,
}: ErrorStateProps) => {
  return (
    <div
      role="alert"
      className={cn('flex flex-col items-center justify-center gap-3 py-12 text-center', className)}
    >
      <div className="rounded-full bg-destructive/10 p-4">
        <Icon className="h-8 w-8 text-destructive" aria-hidden="true" />
      </div>
      <div className="space-y-1">
        <h3 className="text-lg font-semibold text-foreground">{title}</h3>
        {message && <p className="max-w-md text-sm text-muted-foreground">{message}</p>}
      </div>
      {onRetry && (
        <Button variant="outline" onClick={onRetry} className="mt-2">
          <RefreshCw className="mr-2 h-4 w-4" aria-hidden="true" />
          {retryLabel}
        </Button>
      )}
    </div>
  );
};
