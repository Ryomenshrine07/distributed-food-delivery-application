import { Link } from 'react-router-dom';
import { buttonVariants } from '@/components/ui/button';
import { AlertCircle } from 'lucide-react';

export const NotFound = () => {
  return (
    <div className="flex h-screen w-screen flex-col items-center justify-center bg-background text-center">
      <AlertCircle className="mb-4 h-16 w-16 text-muted-foreground" />
      <h1 className="mb-2 text-4xl font-bold tracking-tight">404</h1>
      <p className="mb-8 text-lg text-muted-foreground">Page not found</p>
      <Link to="/" className={buttonVariants()}>Return to Dashboard</Link>
    </div>
  );
};
