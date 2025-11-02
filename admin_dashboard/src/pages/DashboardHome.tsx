import React, { useEffect, useState } from 'react';
import { DashboardStats } from '../types';
import { adminAPI } from '../services/api';
import styles from './DashboardHome.module.css';

const DashboardHome: React.FC = () => {
  const [stats, setStats] = useState<DashboardStats | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchStats = async () => {
      try {
        const response = await adminAPI.getDashboardStats();
        setStats(response.data);
      } catch (error) {
        console.error('Failed to fetch stats:', error);
      } finally {
        setLoading(false);
      }
    };

    fetchStats();
  }, []);

  if (loading) {
    return <div className={styles.loading}>Loading dashboard...</div>;
  }

  return (
    <div className={styles.dashboardHome}>
      <h1>Dashboard Overview</h1>
      
      <div className={styles.statsGrid}>
        <div className={styles.statCard}>
          <h3>Total Users</h3>
          <div className={styles.statNumber}>{stats?.totalUsers || 0}</div>
        </div>
        
        <div className={styles.statCard}>
          <h3>Active Listings</h3>
          <div className={styles.statNumber}>{stats?.activeListings || 0}</div>
        </div>
        
        <div className={styles.statCard}>
          <h3>Total Transactions</h3>
          <div className={styles.statNumber}>{stats?.totalTransactions || 0}</div>
        </div>
        
        <div className={styles.statCard}>
          <h3>Pending Approvals</h3>
          <div className={styles.statNumber}>{stats?.pendingApprovals || 0}</div>
        </div>
      </div>

      <div className={styles.recentActivity}>
        <h2>Recent Activity</h2>
        <p>Activity feed will be displayed here...</p>
      </div>
    </div>
  );
};

export default DashboardHome;