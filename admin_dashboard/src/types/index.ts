export interface User {
  id: string;
  name: string;
  email: string;
  points: number;
  status: 'active' | 'suspended';
  lastLogin: string;
}

export interface WasteListing {
  id: string;
  title: string;
  description: string;
  category: string;
  status: 'pending' | 'approved' | 'rejected';
  userId: string;
  createdAt: string;
  images: string[];
}

export interface Transaction {
  id: string;
  userId: string;
  type: 'earn' | 'spend' | 'transfer';
  points: number;
  description: string;
  timestamp: string;
}

export interface DashboardStats {
  totalUsers: number;
  activeListings: number;
  totalTransactions: number;
  pendingApprovals: number;
}