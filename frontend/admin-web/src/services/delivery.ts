import { api } from '@/lib/api';

export interface DeliveryPartner {
  id: string;
  name: string;
  phone: string;
  available: boolean;
  online: boolean;
  currentAssignmentId: string | null;
  lastSeen: string;
}

export const getDeliveryPartners = async (): Promise<DeliveryPartner[]> => {
  const response = await api.get<DeliveryPartner[]>('/api/delivery/partners/admin');
  return response.data;
};

export const setPartnerOnline = async (id: string): Promise<void> => {
  await api.post(`/api/delivery/partners/${id}/online`);
};

export const setPartnerOffline = async (id: string): Promise<void> => {
  await api.post(`/api/delivery/partners/${id}/offline`);
};
