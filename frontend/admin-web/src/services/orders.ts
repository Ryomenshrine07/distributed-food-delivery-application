import { api } from '@/lib/api';

export interface Order {
  id: string;
  customerId: string;
  customerName: string;
  customerPhone: string;
  restaurantId: string;
  totalAmount: number;
  status: string;
  createdAt: string;
}

export const getOrders = async (): Promise<Order[]> => {
  const response = await api.get<Order[]>('/orders/admin');
  return response.data;
};

export const acceptOrder = async (orderId: string): Promise<void> => {
  await api.post(`/orders/${orderId}/accept`);
};

export const markOrderReady = async (orderId: string): Promise<void> => {
  await api.post(`/orders/${orderId}/ready`);
};
