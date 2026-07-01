import { Loader2 } from 'lucide-react';
import { cn } from '@/lib/utils';

interface LoadingStateProps {
  message?: string;
  className?: string;
}

/**
 * Shared async loading state (Req 12.5). Replaces ad-hoc `<div>Loading...</div>`.
 * Announces itself to assistive technology via role="status".
 */
export const LoadingState = ({ message = 'Loading...', className }: LoadingStateProps) => {
  return (
    <div
      role="status"
      aria-busy="true"
      aria-live="polite"
      className={cn('flex flex-col items-center justify-center gap-3 py-12 text-center', className)}
    >
      <Loader2 className="h-6 w-6 animate-spin text-primary" aria-hidden="true" />
      <p className="text-sm text-muted-foreground">{message}</p>
    </div>
  );
};
