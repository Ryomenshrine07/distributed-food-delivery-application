import { createBrowserRouter, Navigate } from 'react-router-dom';
import { AuthGuard } from '@/components/auth/AuthGuard';
import { AppShell } from '@/components/layout/AppShell';

import { Suspense, lazy } from 'react';

const Login = lazy(() => import('@/pages/Login').then(m => ({ default: m.Login })));
const Dashboard = lazy(() => import('@/pages/Dashboard').then(m => ({ default: m.Dashboard })));
const Restaurants = lazy(() => import('@/pages/Restaurants').then(m => ({ default: m.Restaurants })));
const RestaurantDetail = lazy(() => import('@/pages/RestaurantDetail').then(m => ({ default: m.RestaurantDetail })));
const Orders = lazy(() => import('@/pages/Orders').then(m => ({ default: m.Orders })));
const DeliveryPartners = lazy(() => import('@/pages/DeliveryPartners').then(m => ({ default: m.DeliveryPartners })));
const LiveMap = lazy(() => import('@/pages/LiveMap').then(m => ({ default: m.LiveMap })));
const Customers = lazy(() => import('@/pages/Customers').then(m => ({ default: m.Customers })));
const Analytics = lazy(() => import('@/pages/Analytics').then(m => ({ default: m.Analytics })));
const Notifications = lazy(() => import('@/pages/Notifications').then(m => ({ default: m.Notifications })));
const Settings = lazy(() => import('@/pages/Settings').then(m => ({ default: m.Settings })));
const NotFound = lazy(() => import('@/pages/NotFound').then(m => ({ default: m.NotFound })));

export const router = createBrowserRouter([
  {
    path: '/login',
    element: (
      <Suspense fallback={<div className="flex h-screen items-center justify-center">Loading...</div>}>
        <Login />
      </Suspense>
    ),
  },
  {
    path: '/',
    element: (
      <AuthGuard>
        <AppShell />
      </AuthGuard>
    ),
    children: [
      { index: true, element: <Navigate to="/dashboard" replace /> },
      { path: 'dashboard', element: <Suspense fallback={<div>Loading...</div>}><Dashboard /></Suspense> },
      { path: 'restaurants', element: <Suspense fallback={<div>Loading...</div>}><Restaurants /></Suspense> },
      { path: 'restaurants/:id', element: <Suspense fallback={<div>Loading...</div>}><RestaurantDetail /></Suspense> },
      { path: 'orders', element: <Suspense fallback={<div>Loading...</div>}><Orders /></Suspense> },
      { path: 'delivery-partners', element: <Suspense fallback={<div>Loading...</div>}><DeliveryPartners /></Suspense> },
      { path: 'live-map', element: <Suspense fallback={<div>Loading...</div>}><LiveMap /></Suspense> },
      { path: 'customers', element: <Suspense fallback={<div>Loading...</div>}><Customers /></Suspense> },
      { path: 'analytics', element: <Suspense fallback={<div>Loading...</div>}><Analytics /></Suspense> },
      { path: 'notifications', element: <Suspense fallback={<div>Loading...</div>}><Notifications /></Suspense> },
      { path: 'settings', element: <Suspense fallback={<div>Loading...</div>}><Settings /></Suspense> },
    ],
  },
  {
    path: '*',
    element: (
      <Suspense fallback={<div className="flex h-screen items-center justify-center">Loading...</div>}>
        <NotFound />
      </Suspense>
    ),
  },
]);
