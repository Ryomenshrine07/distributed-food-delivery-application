export type DeliveryPartnerStatus = 'ONLINE' | 'OFFLINE' | 'ON_DELIVERY';

export interface DeliveryPartner {
  id: string;
  name: string;
  phone: string;
  vehicleType: string;
  vehicleNumber: string;
  status: DeliveryPartnerStatus;
  currentLocation?: {
    latitude: number;
    longitude: number;
  };
}
