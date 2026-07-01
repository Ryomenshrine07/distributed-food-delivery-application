import { useQuery } from '@tanstack/react-query';
import { PageHeader } from '@/components/shared/PageHeader';
import { LoadingState } from '@/components/shared/LoadingState';
import { ErrorState } from '@/components/shared/ErrorState';
import { AnalyticsCharts } from '@/components/shared/AnalyticsCharts';
import { MetricCard } from '@/components/shared/MetricCard';
import { getAnalytics } from '@/services/analytics';
import { getOrders } from '@/services/orders';
import { Button } from '@/components/ui/button';
import { CheckCircle, Clock, DollarSign, Download, ShoppingBag } from 'lucide-react';

const currency = new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' });

export const Analytics = () => {
  const analyticsQuery = useQuery({ queryKey: ['analytics'], queryFn: getAnalytics });
  const ordersQuery = useQuery({ queryKey: ['orders'], queryFn: getOrders });

  return (
    <div className="space-y-6">
      <PageHeader
        title="Analytics & Reports"
        description="Deep dive into platform performance and financial reports."
        action={
          <Button variant="outline">
            <Download className="mr-2 h-4 w-4" aria-hidden="true" />
            Export Report
          </Button>
        }
      />

      {analyticsQuery.isLoading ? (
        <LoadingState message="Loading analytics..." />
      ) : analyticsQuery.isError || !analyticsQuery.data ? (
        <ErrorState
          message="We couldn't load analytics. Please try again."
          onRetry={() => analyticsQuery.refetch()}
        />
      ) : (
        <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
          <MetricCard
            title="Total Orders"
            icon={ShoppingBag}
            value={analyticsQuery.data.totalOrders.toLocaleString()}
          />
          <MetricCard
            title="Total Revenue"
            icon={DollarSign}
            value={currency.format(analyticsQuery.data.totalRevenue)}
          />
          <MetricCard
            title="Pending Orders"
            icon={Clock}
            value={analyticsQuery.data.pendingOrders.toLocaleString()}
          />
          <MetricCard
            title="Delivered Orders"
            icon={CheckCircle}
            value={analyticsQuery.data.deliveredOrders.toLocaleString()}
          />
        </div>
      )}

      {ordersQuery.isLoading ? (
        <LoadingState message="Loading charts..." />
      ) : ordersQuery.isError || !ordersQuery.data ? (
        <ErrorState
          message="We couldn't load order analytics. Please try again."
          onRetry={() => ordersQuery.refetch()}
        />
      ) : (
        <AnalyticsCharts orders={ordersQuery.data} />
      )}
    </div>
  );
};
