import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Construction } from 'lucide-react';

interface PendingFeatureProps {
  title: string;
  description?: string;
}

export const PendingFeature: React.FC<PendingFeatureProps> = ({ title, description }) => {
  return (
    <Card className="flex flex-col items-center justify-center py-12 text-center border-dashed border-2">
      <CardHeader>
        <div className="flex justify-center mb-4">
          <div className="rounded-full bg-muted p-4">
            <Construction className="h-8 w-8 text-muted-foreground" />
          </div>
        </div>
        <CardTitle className="text-xl">{title}</CardTitle>
        <CardDescription className="max-w-md mt-2">
          {description || "This feature requires backend endpoints that are not yet implemented. It's marked as a gap in the spec."}
        </CardDescription>
      </CardHeader>
      <CardContent>
      </CardContent>
    </Card>
  );
};
