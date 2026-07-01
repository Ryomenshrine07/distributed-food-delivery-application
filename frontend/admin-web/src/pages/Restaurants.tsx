import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { Link } from 'react-router-dom';
import { getRestaurants, updateRestaurantStatus } from '@/services/restaurants';
import { PageHeader } from '@/components/shared/PageHeader';
import { DataTable } from '@/components/shared/DataTable';
import { type Restaurant } from '@/types/restaurant';
import { type ColumnDef } from '@tanstack/react-table';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { LoadingState } from '@/components/shared/LoadingState';
import { ErrorState } from '@/components/shared/ErrorState';
import { useMemo } from 'react';

export const Restaurants = () => {
  const queryClient = useQueryClient();

  // Reads the paginated ApiResponse<Page<Restaurant>> via getRestaurants()
  // (`.data.data.content`) — see services/restaurants.ts (Req 13.1).
  const { data: restaurants, isLoading, error } = useQuery({
    queryKey: ['restaurants'],
    queryFn: getRestaurants,
  });

  // No optimistic update: on failure the cached list is untouched, so the
  // displayed status stays exactly as it was (Req 13.5, no optimistic desync).
  const mutation = useMutation({
    mutationFn: ({ id, active }: { id: string; active: boolean }) => updateRestaurantStatus(id, active),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['restaurants'] });
    },
  });

  const columns = useMemo<ColumnDef<Restaurant>[]>(() => [
    {
      accessorKey: 'name',
      header: 'Name',
      cell: ({ row }) => (
        <Link
          to={`/restaurants/${row.original.id}`}
          className="font-medium text-primary hover:underline"
        >
          {row.getValue('name')}
        </Link>
      ),
    },
    {
      accessorFn: (row) => `${row.address.city}, ${row.address.state}`,
      header: 'Location',
    },
    {
      accessorKey: 'isActive',
      header: 'Status',
      cell: ({ row }) => {
        const isActive = row.getValue('isActive');
        return (
          <Badge variant={isActive ? 'default' : 'secondary'} className={isActive ? 'bg-success text-success-foreground' : ''}>
            {isActive ? 'Active' : 'Inactive'}
          </Badge>
        );
      },
    },
    {
      accessorKey: 'id',
      header: 'ID',
      cell: ({ row }) => <span className="font-mono text-xs text-muted-foreground">{row.getValue('id')}</span>,
    },
    {
      id: 'actions',
      header: 'Actions',
      cell: ({ row }) => {
        const isActive = row.getValue('isActive') as boolean;
        const id = row.getValue('id') as string;
        
        return (
          <Button 
            size="sm" 
            variant={isActive ? 'destructive' : 'default'}
            onClick={() => mutation.mutate({ id, active: !isActive })}
            disabled={mutation.isPending}
          >
            {isActive ? 'Deactivate' : 'Activate'}
          </Button>
        );
      },
    }
  ], [mutation]);

  if (error) {
    return <ErrorState message="We couldn't load restaurants. Please try again." />;
  }

  return (
    <div>
      <PageHeader 
        title="Restaurants" 
        description="Manage partner restaurants across the platform."
      />
      {mutation.isError && (
        <div
          role="alert"
          className="mb-4 rounded-md border border-destructive/50 bg-destructive/10 px-4 py-3 text-sm text-destructive"
        >
          We couldn't update the restaurant status. The status is unchanged &mdash; please try again.
        </div>
      )}
      {isLoading ? (
        <LoadingState message="Loading restaurants..." />
      ) : (
        <DataTable columns={columns} data={restaurants || []} />
      )}
    </div>
  );
};
