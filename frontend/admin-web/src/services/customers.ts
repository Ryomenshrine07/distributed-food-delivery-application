import { api } from '@/lib/api';

export interface Customer {
  id: string;
  fullName: string;
  email: string;
  phone: string;
  role: string;
}

export const getCustomers = async (): Promise<Customer[]> => {
  const response = await api.get<Customer[]>('/auth/admin/users?role=CUSTOMER');
  return response.data;
};
