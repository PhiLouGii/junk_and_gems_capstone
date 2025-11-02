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

// Response interceptor
api.interceptors.response.use(
  (response) => response,
  (error) => {
    console.error('API Error:', error.response?.data || error.message);
    return Promise.reject(error);
  }
);

export const currentAPI = {
  // Auth
  login: (credentials: { email: string; password: string }) =>
    api.post('/login', credentials),

  signup: (userData: { email: string; password: string; name: string; role?: string }) =>
    api.post('/signup', userData),

  // Dashboard
  getDashboardStats: () => api.get('/admin/stats'),

  // Users
  getUsers: () => api.get('/admin/users'),
  getUserById: (id: string) => api.get(`/admin/users/${id}`),
  banUser: (id: string, reason?: string) => 
    api.put(`/admin/users/${id}/ban`, { reason }),
  unbanUser: (id: string) => api.put(`/admin/users/${id}/unban`),

  // Materials (Waste Listings)
  getMaterials: () => api.get('/admin/materials'),
  approveMaterial: (id: string) => api.put(`/admin/materials/${id}/approve`),
  deleteMaterial: (id: string) => api.delete(`/admin/materials/${id}`),

  // Products
  getProducts: () => api.get('/api/products'),
  createProduct: (data: any) => api.post('/api/products', data),
  updateProduct: (id: string, data: any) => api.put(`/api/products/${id}`, data),
  deleteProduct: (id: string) => api.delete(`/api/products/${id}`),

  // Transactions
  getTransactions: () => api.get('/admin/transactions'),

  // Points System
  getPointsLeaderboard: () => api.get('/admin/points/leaderboard'),
  adjustUserPoints: (userId: string, gems: number, reason: string) =>
    api.put(`/admin/points/${userId}`, { gems, reason }),

  // Reports
  getReports: () => api.get('/admin/reports'),
};