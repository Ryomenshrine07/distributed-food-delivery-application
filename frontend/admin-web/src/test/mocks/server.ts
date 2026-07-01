import { http, HttpResponse } from 'msw';
import { setupServer } from 'msw/node';

export const handlers = [
  http.get('http://localhost:8080/restaurants', () => {
    return HttpResponse.json([
      {
        id: '1',
        name: 'Test Restaurant',
        description: 'A great place',
        address: { city: 'New York', state: 'NY', street: '123 Test St', zipCode: '10001', country: 'USA' },
        isActive: true,
        ownerId: 'owner1'
      }
    ]);
  }),
];

export const server = setupServer(...handlers);
