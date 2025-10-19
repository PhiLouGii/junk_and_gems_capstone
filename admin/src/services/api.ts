import { User, DashboardStats } from '../types';

const API_BASE_URL = 'http://localhost:3003';

class ApiService {
  private token: string | null = null;

  setToken(token: string) {
    this.token = token;
    localStorage.setItem('admin_token', token);
  }

  getToken(): string | null {
    if (!this.token) {
      this.token = localStorage.getItem('admin_token');
    }
    return this.token;
  }

  clearToken() {
    this.token = null;
    localStorage.removeItem('admin_token');
  }

  private async request<T>(endpoint: string, options: RequestInit = {}): Promise<T> {
    const headers: HeadersInit = {
      'Content-Type': 'application/json',
      ...options.headers,
    };

    if (this.token) {
      headers['Authorization'] = `Bearer ${this.token}`;
    }

    const response = await fetch(`${API_BASE_URL}${endpoint}`, {
      ...options,
      headers,
    });

    if (!response.ok) {
      const error = await response.json();
      throw new Error(error.error || 'Request failed');
    }

    return response.json();
  }

  async login(email: string, password: string) {
    const response = await this.request<{ token: string; user: User }>('/login', {
      method: 'POST',
      body: JSON.stringify({ email, password }),
    });
    this.setToken(response.token);
    return response;
  }

  async getDashboardStats(): Promise<DashboardStats> {
    const [users, materials, products] = await Promise.all([
      this.request<User[]>('/api/contributors'),
      this.request<any[]>('/materials'),
      this.request<any[]>('/api/products'),
    ]);

    const totalGems = users.reduce((sum, u) => sum + (u.available_gems || 0), 0);
    const todayStart = new Date();
    todayStart.setHours(0, 0, 0, 0);
    const todayRegistrations = users.filter(
      u => new Date(u.created_at) >= todayStart
    ).length;

    return {
      totalUsers: users.length,
      totalMaterials: materials.length,
      totalProducts: products.length,
      totalGems,
      activeConversations: 0,
      todayRegistrations,
      pendingMaterials: materials.filter((m: any) => !m.is_claimed).length,
      suspendedAccounts: 0,
    };
  }

  async getUsers(filter?: string): Promise<User[]> {
    const contributors = await this.request<User[]>('/api/contributors');
    const artisans = await this.request<User[]>('/api/artisans');
    
    const allUsers = [...contributors, ...artisans];
    const uniqueUsers = Array.from(new Map(allUsers.map(u => [u.id, u])).values());

    if (filter && filter !== 'all') {
      return uniqueUsers.filter(u => u.user_type === filter);
    }
    return uniqueUsers;
  }

  async getMaterials(): Promise<any[]> {
    return this.request<any[]>('/materials');
  }

  async getProducts(): Promise<any[]> {
    return this.request<any[]>('/api/products');
  }
}

export const api = new ApiService();