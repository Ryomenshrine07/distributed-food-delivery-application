import { useEffect, useState, useMemo } from 'react';
import { PageHeader } from '@/components/shared/PageHeader';
import { DataTable } from '@/components/shared/DataTable';
import { type DeliveryPartner, getDeliveryPartners, setPartnerOnline, setPartnerOffline } from '@/services/delivery';
import { type ColumnDef } from '@tanstack/react-table';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { LoadingState } from '@/components/shared/LoadingState';
import { filterPartners, type PartnerFilter } from '@/lib/partner-filter';

const PARTNER_FILTERS: { key: PartnerFilter; label: string }[] = [
  { key: 'online', label: 'Online' },
  { key: 'available', label: 'Available' },
  { key: 'assigned', label: 'Assigned' },
];

export const DeliveryPartners = () => {
  const [data, setData] = useState<DeliveryPartner[]>([]);
  const [loading, setLoading] = useState(true);
  const [activeFilters, setActiveFilters] = useState<Set<PartnerFilter>>(new Set());

  const loadPartners = () => {
    setLoading(true);
    getDeliveryPartners()
      .then(setData)
      .catch(console.error)
      .finally(() => setLoading(false));
  };

  useEffect(() => {
    loadPartners();
  }, []);

  const toggleFilter = (key: PartnerFilter) => {
    setActiveFilters((prev) => {
      const next = new Set(prev);
      if (next.has(key)) {
        next.delete(key);
      } else {
        next.add(key);
      }
      return next;
    });
  };

  const filtered = useMemo(() => filterPartners(data, activeFilters), [data, activeFilters]);

  const handleToggleOnline = async (id: string, isOnline: boolean) => {
    try {
      if (isOnline) {
        await setPartnerOffline(id);
      } else {
        await setPartnerOnline(id);
      }
      loadPartners();
    } catch (error) {
      console.error(error);
    }
  };

  const columns = useMemo<ColumnDef<DeliveryPartner>[]>(() => [
    {
      accessorKey: 'id',
      header: 'Partner ID',
      cell: ({ row }) => <span className="font-mono text-xs text-muted-foreground truncate max-w-[100px] block">{row.getValue('id')}</span>,
    },
    {
      accessorKey: 'name',
      header: 'Name',
    },
    {
      accessorKey: 'phone',
      header: 'Phone',
    },
    {
      accessorKey: 'online',
      header: 'Status',
      cell: ({ row }) => {
        const isOnline = row.getValue('online') as boolean;
        return (
          <Badge variant={isOnline ? 'default' : 'secondary'} className={isOnline ? 'bg-success text-success-foreground' : ''}>
            {isOnline ? 'Online' : 'Offline'}
          </Badge>
        );
      },
    },
    {
      accessorKey: 'available',
      header: 'Availability',
      cell: ({ row }) => {
        const isAvailable = row.getValue('available') as boolean;
        return (
          <Badge variant={isAvailable ? 'default' : 'secondary'}>
            {isAvailable ? 'Available' : 'Busy'}
          </Badge>
        );
      },
    },
    {
      accessorKey: 'currentAssignmentId',
      header: 'Current Assignment',
      cell: ({ row }) => {
        const assignmentId = row.getValue('currentAssignmentId') as string;
        return assignmentId ? (
          <span className="text-xs font-mono">{assignmentId}</span>
        ) : (
          <span className="text-sm text-muted-foreground">None</span>
        );
      },
    },
    {
      id: 'actions',
      header: 'Actions',
      cell: ({ row }) => {
        const isOnline = row.getValue('online') as boolean;
        const id = row.getValue('id') as string;
        
        return (
          <Button 
            size="sm" 
            variant={isOnline ? 'destructive' : 'default'}
            onClick={() => handleToggleOnline(id, isOnline)}
          >
            {isOnline ? 'Force Offline' : 'Set Online'}
          </Button>
        );
      },
    }
  ], []);

  return (
    <div className="space-y-6">
      <PageHeader 
        title="Delivery Partners" 
        description="Manage your fleet, track active deliveries, and review performance."
        action={<Button onClick={loadPartners}>Refresh List</Button>}
      />
      {loading ? (
        <LoadingState message="Loading partners..." />
      ) : (
        <>
          <div className="flex flex-wrap gap-2" role="group" aria-label="Filter delivery partners">
            {PARTNER_FILTERS.map(({ key, label }) => {
              const selected = activeFilters.has(key);
              return (
                <Button
                  key={key}
                  type="button"
                  size="sm"
                  variant={selected ? 'default' : 'outline'}
                  aria-pressed={selected}
                  onClick={() => toggleFilter(key)}
                >
                  {label}
                </Button>
              );
            })}
          </div>
          <DataTable columns={columns} data={filtered} />
        </>
      )}
    </div>
  );
};
