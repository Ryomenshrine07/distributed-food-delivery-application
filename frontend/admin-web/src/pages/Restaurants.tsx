import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { getRestaurants, updateRestaurantStatus } from '@/services/restaurants';
import { PageHeader } from '@/components/shared/PageHeader';
import { DataTable } from '@/components/shared/DataTable';
import { type Restaurant } from '@/types/restaurant';
import { type ColumnDef } from '@tanstack/react-table';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { useMemo } from 'react';

export const Restaurants = () => {
  const queryClient = useQueryClient();

  const { data: restaurants, isLoading, error } = useQuery({
    queryKey: ['restaurants'],
    queryFn: getRestaurants,
  });

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
    return <div>Error loading restaurants</div>;
  }

  return (
    <div>
      <PageHeader 
        title="Restaurants" 
        description="Manage partner restaurants across the platform."
      />
      {isLoading ? (
        <div className="py-8 text-center text-muted-foreground">Loading restaurants...</div>
      ) : (
        <DataTable columns={columns} data={restaurants || []} />
      )}
    </div>
  );
};
