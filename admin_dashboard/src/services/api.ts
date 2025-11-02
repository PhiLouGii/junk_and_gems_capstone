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

// Response interceptor to handle errors
api.interceptors.response.use(
  (response) => response,
  (error) => {
    console.error('API Error:', error.response?.data || error.message);
    return Promise.reject(error);
  }
);

export const adminAPI = {
  // Auth - using your existing endpoints
  login: (credentials: { email: string; password: string }) =>
    api.post('/login', credentials),

  // Products (Waste Listings) - using your existing endpoints
  getProducts: () => api.get('/api/products'),
  createProduct: (productData: any) => api.post('/api/products', productData),
  updateProduct: (id: string, productData: any) => 
    api.put(`/api/products/${id}`, productData),
  deleteProduct: (id: string) => api.delete(`/api/products/${id}`),
  
  // Materials
  getMaterials: () => api.get('/materials'),
  createMaterial: (materialData: any) => api.post('/materials', materialData),
  
  // Cart/Transactions
  getUserCart: (userId: string) => api.get(`/api/users/${userId}/cart`),

  // Admin specific endpoints - these might need to be created in your backend
  getDashboardStats: () => api.get('/admin/stats'),
  getUsers: () => api.get('/admin/users'),
  updateUserStatus: (userId: string, status: string) =>
    api.patch(`/admin/users/${userId}`, { status }),
  getTransactions: () => api.get('/admin/transactions'),
};

// SWITCH TO REAL API - NO MORE MOCK BULLSHIT
export const currentAPI = adminAPI;