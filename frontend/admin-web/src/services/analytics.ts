import { api } from '@/lib/api';

export interface AnalyticsData {
  totalOrders: number;
  totalRevenue: number;
  pendingOrders: number;
  deliveredOrders: number;
}

export const getAnalytics = async (): Promise<AnalyticsData> => {
  const response = await api.get<AnalyticsData>('/analytics/admin');
  return response.data;
};
