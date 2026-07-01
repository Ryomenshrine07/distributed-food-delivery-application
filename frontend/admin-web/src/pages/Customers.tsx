import { useEffect, useState } from 'react';
import { PageHeader } from '@/components/shared/PageHeader';
import { DataTable } from '@/components/shared/DataTable';
import { type Customer, getCustomers } from '@/services/customers';
import { type ColumnDef } from '@tanstack/react-table';
import { Badge } from '@/components/ui/badge';
import { LoadingState } from '@/components/shared/LoadingState';

const columns: ColumnDef<Customer>[] = [
  {
    accessorKey: 'id',
    header: 'Customer ID',
  },
  {
    accessorKey: 'fullName',
    header: 'Name',
  },
  {
    accessorKey: 'email',
    header: 'Email',
  },
  {
    accessorKey: 'phone',
    header: 'Phone',
  },
  {
    accessorKey: 'role',
    header: 'Role',
    cell: ({ row }) => {
      return <Badge variant="secondary">{row.getValue('role')}</Badge>;
    },
  },
];

export const Customers = () => {
  const [data, setData] = useState<Customer[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    getCustomers()
      .then(setData)
      .catch(console.error)
      .finally(() => setLoading(false));
  }, []);

  return (
    <div className="space-y-6">
      <PageHeader 
        title="Customer Management" 
        description="View customer details, order history, and support tickets."
      />
      {loading ? (
        <LoadingState message="Loading customers..." />
      ) : (
        <DataTable columns={columns} data={data} />
      )}
    </div>
  );
};
