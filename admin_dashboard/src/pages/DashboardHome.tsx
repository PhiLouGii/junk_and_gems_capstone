import React, { useEffect, useState } from 'react';
import { DashboardStats } from '../types';
import { currentAPI } from '../services/api';
import styles from './DashboardHome.module.css';

const DashboardHome: React.FC = () => {
  const [stats, setStats] = useState<DashboardStats | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    fetchStats();
  }, []);

  const fetchStats = async () => {
    try {
      const response = await currentAPI.getDashboardStats();
      setStats(response.data);
    } catch (error: any) {
      console.error('Failed to fetch stats:', error);
      setError(error.response?.data?.message || 'Failed to load dashboard stats');
      // Fallback: Calculate stats from available data
      await calculateFallbackStats();
    } finally {
      setLoading(false);
    }
  };

  const calculateFallbackStats = async () => {
    try {
      // Get products and calculate basic stats
      const productsResponse = await currentAPI.getProducts();
      const products = productsResponse.data;
      
      const fallbackStats: DashboardStats = {
        totalUsers: 0, // We'll need a users endpoint for this
        activeListings: products.length,
        totalTransactions: 0, // We'll need a transactions endpoint for this
        pendingApprovals: products.filter((p: any) => p.status === 'pending').length,
        totalRevenue: 0
      };
      
      setStats(fallbackStats);
    } catch (error) {
      console.error('Failed to calculate fallback stats:', error);
    }
  };

  if (loading) {
    return <div className={styles.loading}>Loading dashboard...</div>;
  }

  if (error && !stats) {
    return (
      <div className={styles.errorContainer}>
        <h2>Error Loading Dashboard</h2>
        <p>{error}</p>
        <button onClick={fetchStats}>Retry</button>
      </div>
    );
  }

  return (
    <div className={styles.dashboardHome}>
      <h1>Dashboard Overview</h1>
      
      <div className={styles.statsGrid}>
        <div className={styles.statCard}>
          <h3>Total Users</h3>
          <div className={styles.statNumber}>{stats?.totalUsers || 'N/A'}</div>
        </div>
        
        <div className={styles.statCard}>
          <h3>Active Listings</h3>
          <div className={styles.statNumber}>{stats?.activeListings || 0}</div>
        </div>
        
        <div className={styles.statCard}>
          <h3>Total Transactions</h3>
          <div className={styles.statNumber}>{stats?.totalTransactions || 'N/A'}</div>
        </div>
        
        <div className={styles.statCard}>
          <h3>Pending Approvals</h3>
          <div className={styles.statNumber}>{stats?.pendingApprovals || 0}</div>
        </div>
      </div>

      {error && (
        <div className={styles.warning}>
          <strong>Note:</strong> {error} Some data may be limited.
        </div>
      )}

      <div className={styles.recentActivity}>
        <h2>Quick Actions</h2>
        <div className={styles.quickActions}>
          <button onClick={() => window.location.href = '/listings'}>
            Manage Listings
          </button>
          <button onClick={() => window.location.href = '/users'}>
            View Users
          </button>
        </div>
      </div>
    </div>
  );
};

export default DashboardHome;