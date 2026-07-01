import { http, HttpResponse } from 'msw';
import { setupServer } from 'msw/node';

export const handlers = [
  http.get('http://localhost:8080/restaurants', () => {
    // Mirrors the real backend contract: ApiResponse<Page<Restaurant>>, which
    // getRestaurants() unwraps via `.data.data.content`.
    return HttpResponse.json({
      data: {
        content: [
          {
            id: '1',
            name: 'Test Restaurant',
            description: 'A great place',
            address: { city: 'New York', state: 'NY', street: '123 Test St', zipCode: '10001', country: 'USA' },
            isActive: true,
            ownerId: 'owner1'
          }
        ],
        totalElements: 1,
        totalPages: 1,
        number: 0,
        size: 20
      }
    });
  }),
];

export const server = setupServer(...handlers);
