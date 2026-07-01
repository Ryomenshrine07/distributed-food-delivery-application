import { useQuery } from '@tanstack/react-query';
import { PageHeader } from '@/components/shared/PageHeader';
import { LoadingState } from '@/components/shared/LoadingState';
import { ErrorState } from '@/components/shared/ErrorState';
import { AnalyticsCharts } from '@/components/shared/AnalyticsCharts';
import { MetricCard } from '@/components/shared/MetricCard';
import { Activity, CheckCircle, Clock, DollarSign } from 'lucide-react';
import { getAnalytics } from '@/services/analytics';
import { getOrders } from '@/services/orders';

const currency = new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' });

export const Dashboard = () => {
  const analyticsQuery = useQuery({ queryKey: ['analytics'], queryFn: getAnalytics });
  const ordersQuery = useQuery({ queryKey: ['orders'], queryFn: getOrders });

  return (
    <div className="space-y-6">
      <PageHeader title="Dashboard" description="Platform overview and key metrics." />

      {analyticsQuery.isLoading ? (
        <LoadingState message="Loading dashboard metrics..." />
      ) : analyticsQuery.isError || !analyticsQuery.data ? (
        <ErrorState
          message="We couldn't load the dashboard metrics. Please try again."
          onRetry={() => analyticsQuery.refetch()}
        />
      ) : (
        <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
          <MetricCard
            title="Total Orders"
            icon={Activity}
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
