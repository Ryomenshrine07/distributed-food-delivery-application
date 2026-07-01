import { create } from 'zustand';
import { persist } from 'zustand/middleware';
import { type AuthSession } from '@/types/auth';

interface SessionState {
  session: AuthSession | null;
  setSession: (session: AuthSession | null) => void;
  logout: () => void;
  isAuthenticated: () => boolean;
}

export const useSessionStore = create<SessionState>()(
  persist(
    (set, get) => ({
      session: null,
      setSession: (session) => set({ session }),
      logout: () => set({ session: null }),
      isAuthenticated: () => !!get().session?.token,
    }),
    {
      name: 'admin-session-storage',
    }
  )
);
