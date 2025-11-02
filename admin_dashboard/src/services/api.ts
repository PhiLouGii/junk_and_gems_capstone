import axios from 'axios';

const API_BASE_URL = 'https://junk-and-gems-api.onrender.com';

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Add auth token to requests
api.interceptors.request.use((config) => {
  const token = localStorage.getItem('adminToken');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

export const adminAPI = {
  // Auth
  login: (credentials: { email: string; password: string }) =>
    api.post('/admin/login', credentials),

  // Dashboard Stats
  getDashboardStats: () => api.get('/admin/dashboard/stats'),
  
  // User Management
  getUsers: (page: number = 1) => api.get(`/admin/users?page=${page}`),
  updateUserStatus: (userId: string, status: string) =>
    api.patch(`/admin/users/${userId}`, { status }),
  
  // Waste Listings
  getListings: (status?: string) => 
    api.get(`/admin/listings${status ? `?status=${status}` : ''}`),
  updateListingStatus: (listingId: string, status: string) =>
    api.patch(`/admin/listings/${listingId}`, { status }),
  
  // Transactions
  getTransactions: (page: number = 1) =>
    api.get(`/admin/transactions?page=${page}`),
  
  // Points System
  getPointsOverview: () => api.get('/admin/points/overview'),
  adjustUserPoints: (userId: string, points: number, reason: string) =>
    api.post('/admin/points/adjust', { userId, points, reason }),
};

export default api;