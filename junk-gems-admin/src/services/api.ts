import axios, { AxiosInstance, AxiosResponse, AxiosError } from 'axios';

const API_BASE_URL = 'https://junk-and-gems-api.onrender.com';

// Define types for better type safety
interface LoginCredentials {
  email: string;
  password: string;
}

interface SignupData {
  email: string;
  password: string;
  name: string;
}

interface ProductData {
  name: string;
  description?: string;
  price?: number;
  category?: string;
  images?: string[];
  [key: string]: unknown;
}

interface MaterialData {
  name: string;
  type?: string;
  [key: string]: unknown;
}

interface CartItem {
  productId: string;
  quantity: number;
  [key: string]: unknown;
}

// Create axios instance with default config
const apiClient: AxiosInstance = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
  timeout: 30000, // 30 seconds timeout for slow connections
});

// Request interceptor to add auth token
apiClient.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('adminToken');
    if (token && config.headers) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error: AxiosError) => {
    return Promise.reject(error);
  }
);

// Response interceptor for error handling
apiClient.interceptors.response.use(
  (response) => response,
  (error: AxiosError) => {
    if (error.response?.status === 401) {
      // Unauthorized - clear token and redirect to login
      localStorage.removeItem('adminToken');
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

// API Service Object
export const currentAPI = {
  // ============================================
  // AUTH ENDPOINTS
  // ============================================
  
  login: (credentials: LoginCredentials): Promise<AxiosResponse> => {
    return apiClient.post('/login', credentials);
  },

  signup: (userData: SignupData): Promise<AxiosResponse> => {
    return apiClient.post('/signup', userData);
  },

  googleAuth: (googleToken: string): Promise<AxiosResponse> => {
    return apiClient.post('/auth/google', { token: googleToken });
  },

  // ============================================
  // PRODUCTS ENDPOINTS
  // ============================================
  
  getProducts: (): Promise<AxiosResponse> => {
    return apiClient.get('/api/products');
  },

  getProductById: (id: string): Promise<AxiosResponse> => {
    return apiClient.get(`/api/products/${id}`);
  },

  createProduct: (productData: ProductData): Promise<AxiosResponse> => {
    return apiClient.post('/api/products', productData);
  },

  updateProduct: (id: string, updates: Partial<ProductData>): Promise<AxiosResponse> => {
    return apiClient.put(`/api/products/${id}`, updates);
  },

  deleteProduct: (id: string): Promise<AxiosResponse> => {
    return apiClient.delete(`/api/products/${id}`);
  },

  // ============================================
  // MATERIALS ENDPOINTS
  // ============================================
  
  getMaterials: (): Promise<AxiosResponse> => {
    return apiClient.get('/materials');
  },

  createMaterial: (materialData: MaterialData): Promise<AxiosResponse> => {
    return apiClient.post('/materials', materialData);
  },

  // ============================================
  // ADMIN ENDPOINTS (you may need to add these to your backend)
  // ============================================
  

  getUsers: (): Promise<AxiosResponse> => {
    // This endpoint should list all users for admin management
    return apiClient.get('/api/analytics/users');
  },

  getUserById: (userId: string): Promise<AxiosResponse> => {
    return apiClient.get(`/admin/users/${userId}`);
  },

  banUser: (userId: string, reason: string): Promise<AxiosResponse> => {
    return apiClient.post(`/admin/users/${userId}/ban`, { reason });
  },

  unbanUser: (userId: string): Promise<AxiosResponse> => {
    return apiClient.post(`/admin/users/${userId}/unban`);
  },

  updateUserStatus: (userId: string, status: string): Promise<AxiosResponse> => {
    return apiClient.patch(`/admin/users/${userId}/status`, { status });
  },

  // ============================================
  // POINTS/GEMS SYSTEM ENDPOINTS
  // ============================================
  
  getPointsLeaderboard: (): Promise<AxiosResponse> => {
    return apiClient.get('/admin/points/leaderboard');
  },

  adjustUserPoints: (userId: string, points: number, reason: string): Promise<AxiosResponse> => {
    return apiClient.post(`/admin/users/${userId}/points`, { points, reason });
  },

  getPointsHistory: (userId?: string): Promise<AxiosResponse> => {
    const url = userId ? `/admin/points/history?userId=${userId}` : '/admin/points/history';
    return apiClient.get(url);
  },

  // ============================================
  // CART ENDPOINTS (for reference, may not be needed in admin)
  // ============================================
  
  getUserCart: (userId: string): Promise<AxiosResponse> => {
    return apiClient.get(`/api/users/${userId}/cart`);
  },

  addToCart: (userId: string, item: CartItem): Promise<AxiosResponse> => {
    return apiClient.post(`/api/users/${userId}/cart`, item);
  },

  updateCartItem: (userId: string, itemId: string, updates: Partial<CartItem>): Promise<AxiosResponse> => {
    return apiClient.put(`/api/users/${userId}/cart/${itemId}`, updates);
  },

  removeFromCart: (userId: string, itemId: string): Promise<AxiosResponse> => {
    return apiClient.delete(`/api/users/${userId}/cart/${itemId}`);
  },

  clearCart: (userId: string): Promise<AxiosResponse> => {
    return apiClient.delete(`/api/users/${userId}/cart`);
  },

  // ============================================
  // ANALYTICS & REPORTING (may need backend implementation)
  // ============================================
  
  getWasteStats: (): Promise<AxiosResponse> => {
    // Returns waste diversion statistics
    return apiClient.get('/admin/analytics/waste');
  },

  getEngagementStats: (): Promise<AxiosResponse> => {
    // Returns user engagement metrics
    return apiClient.get('/admin/analytics/engagement');
  },

  getRevenueStats: (): Promise<AxiosResponse> => {
    // Returns revenue and transaction data
    return apiClient.get('/admin/analytics/revenue');
  },

  // ============================================
  // UTILITY FUNCTIONS
  // ============================================
  
  healthCheck: (): Promise<AxiosResponse> => {
    return apiClient.get('/');
  },

  logout: (): void => {
    localStorage.removeItem('adminToken');
    window.location.href = '/login';
  },

  isAuthenticated: (): boolean => {
    return !!localStorage.getItem('adminToken');
  },

  getToken: (): string | null => {
    return localStorage.getItem('adminToken');
  },
};

// Export the base URL for reference
export const API_URL = API_BASE_URL;

export default currentAPI;