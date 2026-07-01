import { useEffect, useState, useMemo } from 'react';
import { PageHeader } from '@/components/shared/PageHeader';
import { DataTable } from '@/components/shared/DataTable';
import { type Order, getOrders, acceptOrder, markOrderReady } from '@/services/orders';
import { type ColumnDef } from '@tanstack/react-table';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';

export const Orders = () => {
  const [data, setData] = useState<Order[]>([]);
  const [loading, setLoading] = useState(true);

  const loadOrders = () => {
    setLoading(true);
    getOrders()
      .then(setData)
      .catch(console.error)
      .finally(() => setLoading(false));
  };

  useEffect(() => {
    loadOrders();
  }, []);

  const handleAction = async (action: 'accept' | 'ready', orderId: string) => {
    try {
      if (action === 'accept') {
        await acceptOrder(orderId);
      } else if (action === 'ready') {
        await markOrderReady(orderId);
      }
      loadOrders();
    } catch (error) {
      console.error(error);
    }
  };

  const columns = useMemo<ColumnDef<Order>[]>(() => [
    {
      accessorKey: 'id',
      header: 'Order ID',
      cell: ({ row }) => <span className="font-mono text-xs text-muted-foreground truncate max-w-[100px] block">{row.getValue('id')}</span>,
    },
    {
      accessorKey: 'customerName',
      header: 'Customer',
    },
    {
      accessorKey: 'restaurantId',
      header: 'Restaurant ID',
      cell: ({ row }) => <span className="font-mono text-xs text-muted-foreground truncate max-w-[100px] block">{row.getValue('restaurantId')}</span>,
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
              <Button size="sm" onClick={() => handleAction('accept', orderId)}>Accept</Button>
            ) : null}
            {status === 'PREPARING' ? (
              <Button size="sm" onClick={() => handleAction('ready', orderId)}>Mark Ready</Button>
            ) : null}
          </div>
        );
      },
    },
  ], []);

  return (
    <div className="space-y-6">
      <PageHeader 
        title="Order Management" 
        description="Monitor active orders and override statuses if necessary."
        action={<Button onClick={loadOrders}>Refresh Orders</Button>}
      />
      {loading ? (
        <div>Loading orders...</div>
      ) : (
        <DataTable columns={columns} data={data} />
      )}
    </div>
  );
};
