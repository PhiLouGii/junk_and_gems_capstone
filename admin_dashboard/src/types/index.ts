export interface User {
  id: string;
  name: string;
  email: string;
  points: number;
  status: 'active' | 'suspended';
  joinDate: string;
  listingsCount: number;
}

export interface WasteListing {
  id: string;
  title: string;
  description: string;
  category: string;
  price: number;
  status: 'pending' | 'approved' | 'rejected';
  userId: string;
  createdAt: string;
  images: string[];
}

export interface Transaction {
  id: string;
  userId: string;
  userName: string;
  type: 'purchase' | 'sale' | 'transfer';
  amount: number;
  points: number;
  status: 'completed' | 'pending' | 'failed';
  timestamp: string;
}

export interface DashboardStats {
  totalUsers: number;
  activeListings: number;
  totalTransactions: number;
  pendingApprovals: number;
  totalRevenue: number;
}