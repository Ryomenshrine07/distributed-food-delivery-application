
import { api } from '@/lib/api';
import { type AuthSession } from '@/types/auth';
import { z } from 'zod';

export const loginSchema = z.object({
  email: z.string().email(),
  password: z.string().min(6),
});

export type LoginDto = z.infer<typeof loginSchema>;

export const login = async (data: LoginDto): Promise<AuthSession> => {
  const response = await api.post<{
    token: string;
    userId: string;
    fullName: string;
    email: string;
    role: string;
  }>('/auth/login/admin', data);
  
  return {
    token: response.data.token,
    user: {
      id: response.data.userId,
      name: response.data.fullName,
      email: response.data.email,
      role: response.data.role as 'ADMIN' | 'RESTAURANT_OWNER' | 'CUSTOMER',
    }
  };
};
