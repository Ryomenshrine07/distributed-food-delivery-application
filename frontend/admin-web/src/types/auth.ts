export interface User {
  id: string;
  name: string;
  email: string;
  role: 'ADMIN' | 'RESTAURANT_OWNER' | 'CUSTOMER';
}

export interface AuthSession {
  token: string;
  user: User;
}
