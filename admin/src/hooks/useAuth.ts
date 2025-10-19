import { useState, useEffect } from 'react';
import { api } from '../services/api';
import { User } from '../types';

export const useAuth = () => {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const token = api.getToken();
    setLoading(false);
  }, []);

  const login = async (email: string, password: string) => {
    const response = await api.login(email, password);
    setUser(response.user);
    return response;
  };

  const logout = () => {
    api.clearToken();
    setUser(null);
  };

  return { user, loading, login, logout, isAuthenticated: !!user || !!api.getToken() };
};