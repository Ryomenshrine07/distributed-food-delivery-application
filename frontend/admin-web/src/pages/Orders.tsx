import { useMemo, useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { PageHeader } from '@/components/shared/PageHeader';
import { DataTable } from '@/components/shared/DataTable';
import { type Order, getOrders, acceptOrder, markOrderReady } from '@/services/orders';
import { type ColumnDef } from '@tanstack/react-table';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { LoadingState } from '@/components/shared/LoadingState';
import { ErrorState } from '@/components/shared/ErrorState';
import { filterOrders } from '@/lib/order-filter';

/** Statuses offered as filter chips (Req 16.3). */
const ORDER_STATUSES = [
  'PENDING_PAYMENT',
  'CONFIRMED',
  'PREPARING',
  'READY_FOR_PICKUP',
  'OUT_FOR_DELIVERY',
  'DELIVERED',
  'CANCELLED',
] as const;

/**
 * Auto-refresh cadence for in-flight orders (Req 16.2). Exported so tests can
 * advance fake timers by exactly this interval.
 */
export const ORDERS_REFETCH_INTERVAL_MS = 10_000;

export const Orders = () => {
  const queryClient = useQueryClient();
  const [selectedStatuses, setSelectedStatuses] = useState<Set<string>>(new Set());
  const [search, setSearch] = useState('');

  const { data, isLoading, isError, refetch } = useQuery({
    queryKey: ['orders'],
    queryFn: getOrders,
    // Keep the list current while the page is open (Req 16.2).
    refetchInterval: ORDERS_REFETCH_INTERVAL_MS,
  });

  const actionMutation = useMutation({
    mutationFn: ({ action, orderId }: { action: 'accept' | 'ready'; orderId: string }) =>
      action === 'accept' ? acceptOrder(orderId) : markOrderReady(orderId),
    onSuccess: () => {
      // Refresh the list so the acted-on order reflects its new status (Req 16.7).
      queryClient.invalidateQueries({ queryKey: ['orders'] });
    },
  });

  const toggleStatus = (status: string) => {
    setSelectedStatuses((prev) => {
      const next = new Set(prev);
      if (next.has(status)) {
        next.delete(status);
      } else {
        next.add(status);
      }
      return next;
    });
  };

  const filtered = useMemo(
    () => filterOrders(data ?? [], selectedStatuses, search),
    [data, selectedStatuses, search],
  );

  const columns = useMemo<ColumnDef<Order>[]>(
    () => [
      {
        accessorKey: 'id',
        header: 'Order ID',
        cell: ({ row }) => (
          <span className="font-mono text-xs text-muted-foreground truncate max-w-[100px] block">
            {row.getValue('id')}
          </span>
        ),
      },
      {
        accessorKey: 'customerName',
        header: 'Customer',
      },
      {
        accessorKey: 'restaurantId',
        header: 'Restaurant ID',
        cell: ({ row }) => (
          <span className="font-mono text-xs text-muted-foreground truncate max-w-[100px] block">
            {row.getValue('restaurantId')}
          </span>
        ),
      },
      {
        accessorKey: 'totalAmount',
        header: 'Total',
        cell: ({ row }) => {
          const amount = parseFloat(row.getValue('totalAmount'));
          return new Intl.NumberFormat('en-US', {
            style: 'currency',
            currency: 'USD',
          }).format(amount);
        },
      },
      {
        accessorKey: 'status',
        header: 'Status',
        cell: ({ row }) => {
          return <Badge variant="secondary">{row.getValue('status')}</Badge>;
        },
      },
      {
        accessorKey: 'createdAt',
        header: 'Date',
        cell: ({ row }) => {
          const date = new Date(row.getValue('createdAt'));
          return date.toLocaleDateString();
        },
      },
      {
        id: 'actions',
        header: 'Actions',
        cell: ({ row }) => {
          const status = row.getValue('status') as string;
          const orderId = row.getValue('id') as string;

          return (
            <div className="flex gap-2">
              {status === 'PENDING_PAYMENT' || status === 'CONFIRMED' ? (
                <Button
                  size="sm"
                  onClick={() => actionMutation.mutate({ action: 'accept', orderId })}
                  disabled={actionMutation.isPending}
                >
                  Accept
                </Button>
              ) : null}
              {status === 'PREPARING' ? (
                <Button
                  size="sm"
                  onClick={() => actionMutation.mutate({ action: 'ready', orderId })}
                  disabled={actionMutation.isPending}
                >
                  Mark Ready
                </Button>
              ) : null}
            </div>
          );
        },
      },
    ],
    [actionMutation],
  );

  return (
    <div className="space-y-6">
      <PageHeader
        title="Order Management"
        description="Monitor active orders and override statuses if necessary."
        action={<Button onClick={() => refetch()}>Refresh Orders</Button>}
      />

      {isError ? (
        <ErrorState
          message="We couldn't load orders. Please try again."
          onRetry={() => refetch()}
        />
      ) : isLoading ? (
        <LoadingState message="Loading orders..." />
      ) : (
        <>
          <div className="flex flex-col gap-4">
            <Input
              type="search"
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              placeholder="Search by order ID, customer, or restaurant"
              aria-label="Search orders"
              className="max-w-sm"
            />
            <div className="flex flex-wrap gap-2" role="group" aria-label="Filter orders by status">
              {ORDER_STATUSES.map((status) => {
                const selected = selectedStatuses.has(status);
                return (
                  <Button
                    key={status}
                    type="button"
                    size="sm"
                    variant={selected ? 'default' : 'outline'}
                    aria-pressed={selected}
                    onClick={() => toggleStatus(status)}
                  >
                    {status.replace(/_/g, ' ')}
                  </Button>
                );
              })}
            </div>
          </div>
          <DataTable columns={columns} data={filtered} />
        </>
      )}
    </div>
  );
};
