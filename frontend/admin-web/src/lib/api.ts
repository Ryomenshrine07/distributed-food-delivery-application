import axios, { AxiosError } from 'axios';
import { useSessionStore } from '@/store/session';

export const api = axios.create({
  baseURL: import.meta.env.VITE_API_URL || 'http://localhost:8080',
  headers: {
    'Content-Type': 'application/json',
  },
});

api.interceptors.request.use((config) => {
  const token = useSessionStore.getState().session?.token;
  if (token && config.headers) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

api.interceptors.response.use(
  (response) => response,
  (error: AxiosError) => {
    if (error.response?.status === 401) {
      useSessionStore.getState().logout();
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);
