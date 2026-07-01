import { useQuery } from '@tanstack/react-query';
import { Link, useParams } from 'react-router-dom';
import { ArrowLeft } from 'lucide-react';
import { getRestaurant } from '@/services/restaurants';
import { PageHeader } from '@/components/shared/PageHeader';
import { LoadingState } from '@/components/shared/LoadingState';
import { ErrorState } from '@/components/shared/ErrorState';
import { Badge } from '@/components/ui/badge';
import { buttonVariants } from '@/components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';

export const RestaurantDetail = () => {
  const { id } = useParams<{ id: string }>();

  const { data: restaurant, isLoading, isError, refetch } = useQuery({
    queryKey: ['restaurants', id],
    queryFn: () => getRestaurant(id as string),
    enabled: Boolean(id),
  });

  return (
    <div className="space-y-6">
      <PageHeader
        title={restaurant?.name ?? 'Restaurant Detail'}
        description="Restaurant profile and current availability."
        action={
          <Link to="/restaurants" className={buttonVariants({ variant: 'outline' })}>
            <ArrowLeft className="mr-2 h-4 w-4" aria-hidden="true" />
            Back to Restaurants
          </Link>
        }
      />

      {isError ? (
        <ErrorState
          message="We couldn't load this restaurant. Please try again."
          onRetry={() => refetch()}
        />
      ) : isLoading ? (
        <LoadingState message="Loading restaurant..." />
      ) : restaurant ? (
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-3">
              {restaurant.name}
              <Badge
                variant={restaurant.isActive ? 'default' : 'secondary'}
                className={restaurant.isActive ? 'bg-success text-success-foreground' : ''}
              >
                {restaurant.isActive ? 'Active' : 'Inactive'}
              </Badge>
            </CardTitle>
          </CardHeader>
          <CardContent className="space-y-4 text-sm">
            {restaurant.description && (
              <p className="text-muted-foreground">{restaurant.description}</p>
            )}
            <dl className="grid gap-3 sm:grid-cols-2">
              <div>
                <dt className="font-medium text-foreground">Address</dt>
                <dd className="text-muted-foreground">
                  {restaurant.address.street}, {restaurant.address.city}, {restaurant.address.state}{' '}
                  {restaurant.address.zipCode}, {restaurant.address.country}
                </dd>
              </div>
              <div>
                <dt className="font-medium text-foreground">Restaurant ID</dt>
                <dd className="font-mono text-xs text-muted-foreground">{restaurant.id}</dd>
              </div>
              <div>
                <dt className="font-medium text-foreground">Owner ID</dt>
                <dd className="font-mono text-xs text-muted-foreground">{restaurant.ownerId}</dd>
              </div>
            </dl>
          </CardContent>
        </Card>
      ) : null}
    </div>
  );
};
