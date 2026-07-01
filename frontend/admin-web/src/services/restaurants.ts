import { api } from '@/lib/api';
import { type Restaurant } from '@/types/restaurant';

export const getRestaurants = async (): Promise<Restaurant[]> => {
  const response = await api.get('/restaurants');
  // The backend returns an ApiResponse wrapper containing a Spring Page object
  return response.data.data.content;
};

export const getRestaurant = async (id: string): Promise<Restaurant> => {
  const response = await api.get(`/restaurants/${id}`);
  return response.data.data;
};

export const updateRestaurantStatus = async (id: string, active: boolean): Promise<Restaurant> => {
  const response = await api.patch(`/restaurants/${id}/status`, { active });
  return response.data.data;
};
