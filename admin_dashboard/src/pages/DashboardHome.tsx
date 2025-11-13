import React, { useEffect, useState } from 'react';
import { LineChart, Line, BarChart, Bar, PieChart, Pie, Cell, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer, AreaChart, Area } from 'recharts';
import { TrendingUp, TrendingDown, Users, Package, ShoppingCart, AlertCircle } from 'lucide-react';
import { currentAPI } from '../services/api';
import styles from './DashboardHome.module.css';

interface CategoryData {
  name: string;
  value: number;
}

interface GrowthData {
  month: string;
  users: number;
  products: number;
}

interface Activity {
  title: string;
  status: string;
  time: string;
}

const DashboardHome: React.FC = () => {
  const [stats, setStats] = useState({
    totalUsers: 0,
    totalProducts: 0,
    totalMaterials: 0,
    pendingProducts: 0,
    activeProducts: 0,
    categoryBreakdown: [] as CategoryData[],
    recentActivity: [] as Activity[],
    userGrowth: [] as GrowthData[]
  });
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    fetchDashboardData();
    const interval = setInterval(fetchDashboardData, 30000);
    return () => clearInterval(interval);
  }, []);

  const fetchDashboardData = async () => {
    try {
      // Fetch products
      const productsRes = await currentAPI.getProducts();
      const products = productsRes.data;
      
      // Fetch materials
      const materialsRes = await currentAPI.getProducts(); // Using products as fallback
      const materials = materialsRes.data;

      // Calculate stats
      const categoryCount: { [key: string]: number } = {};
      const statusCount = {
        pending: 0,
        approved: 0,
        rejected: 0
      };

      products.forEach((product: any) => {
        categoryCount[product.category] = (categoryCount[product.category] || 0) + 1;
        if (product.status in statusCount) {
          statusCount[product.status as keyof typeof statusCount]++;
        }
      });

      // Transform category data
      const categoryBreakdown = Object.entries(categoryCount).map(([name, value]) => ({
        name: name.charAt(0).toUpperCase() + name.slice(1),
        value
      }));

      // Generate growth data
      const userGrowth = generateUserGrowthData();

      // Get recent activity
      const recentActivity = products
        .sort((a: any, b: any) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime())
        .slice(0, 5)
        .map((p: any) => ({
          title: p.title,
          status: p.status,
          time: new Date(p.createdAt).toLocaleDateString()
        }));

      setStats({
        totalUsers: 150,
        totalProducts: products.length,
        totalMaterials: materials.length,
        pendingProducts: statusCount.pending,
        activeProducts: statusCount.approved,
        categoryBreakdown,
        recentActivity,
        userGrowth
      });
      setError('');
    } catch (error: any) {
      console.error('Failed to fetch dashboard data:', error);
      setError('Some data may be limited');
    } finally {
      setLoading(false);
    }
  };

  const generateUserGrowthData = (): GrowthData[] => {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
    return months.map((month, i) => ({
      month,
      users: Math.floor(Math.random() * 50) + 20 + i * 10,
      products: Math.floor(Math.random() * 30) + 10 + i * 5
    }));
  };

  const COLORS = ['#88844D', '#BEC092', '#E4E5C2', '#6d6a3d', '#a5a26b', '#d4d2a8'];

  if (loading) {
    return <div className={styles.loading}>Loading dashboard analytics...</div>;
  }

  return (
    <div className={styles.dashboardHome}>
      <h1>📊 Dashboard Analytics</h1>

      {/* Stats Grid */}
      <div className={styles.statsGrid}>
        <div className={styles.statCard}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <div>
              <h3>Total Users</h3>
              <div className={styles.statNumber}>{stats.totalUsers}</div>
              <div style={{ display: 'flex', alignItems: 'center', color: '#22c55e', fontSize: '0.875rem', marginTop: '0.5rem' }}>
                <TrendingUp size={16} style={{ marginRight: '4px' }} />
                <span>12% from last month</span>
              </div>
            </div>
            <Users size={40} color="#88844D" />
          </div>
        </div>

        <div className={styles.statCard}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <div>
              <h3>Total Products</h3>
              <div className={styles.statNumber}>{stats.totalProducts}</div>
              <div style={{ display: 'flex', alignItems: 'center', color: '#22c55e', fontSize: '0.875rem', marginTop: '0.5rem' }}>
                <TrendingUp size={16} style={{ marginRight: '4px' }} />
                <span>8% from last month</span>
              </div>
            </div>
            <Package size={40} color="#88844D" />
          </div>
        </div>

        <div className={styles.statCard}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <div>
              <h3>Pending Approvals</h3>
              <div className={styles.statNumber}>{stats.pendingProducts}</div>
              <div style={{ display: 'flex', alignItems: 'center', color: '#ef4444', fontSize: '0.875rem', marginTop: '0.5rem' }}>
                <AlertCircle size={16} style={{ marginRight: '4px' }} />
                <span>Needs attention</span>
              </div>
            </div>
            <AlertCircle size={40} color="#88844D" />
          </div>
        </div>

        <div className={styles.statCard}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <div>
              <h3>Active Listings</h3>
              <div className={styles.statNumber}>{stats.activeProducts}</div>
              <div style={{ display: 'flex', alignItems: 'center', color: '#22c55e', fontSize: '0.875rem', marginTop: '0.5rem' }}>
                <TrendingUp size={16} style={{ marginRight: '4px' }} />
                <span>15% from last month</span>
              </div>
            </div>
            <ShoppingCart size={40} color="#88844D" />
          </div>
        </div>
      </div>

      {error && (
        <div className={styles.warning}>
          <strong>Note:</strong> {error}
        </div>
      )}

      {/* Charts Section */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(400px, 1fr))', gap: '1.5rem', marginBottom: '2rem' }}>
        {/* Growth Chart */}
        <div style={{ background: '#F7F2E4', borderRadius: '12px', padding: '1.5rem', boxShadow: '0 4px 6px rgba(0, 0, 0, 0.1)' }}>
          <h2>📈 Growth Trends</h2>
          <ResponsiveContainer width="100%" height={300}>
            <AreaChart data={stats.userGrowth}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="month" />
              <YAxis />
              <Tooltip />
              <Legend />
              <Area type="monotone" dataKey="users" stackId="1" stroke="#88844D" fill="#88844D" name="Users" />
              <Area type="monotone" dataKey="products" stackId="1" stroke="#BEC092" fill="#BEC092" name="Products" />
            </AreaChart>
          </ResponsiveContainer>
        </div>

        {/* Category Pie Chart */}
        <div style={{ background: '#F7F2E4', borderRadius: '12px', padding: '1.5rem', boxShadow: '0 4px 6px rgba(0, 0, 0, 0.1)' }}>
          <h2>🎯 Products by Category</h2>
          {stats.categoryBreakdown.length > 0 ? (
            <ResponsiveContainer width="100%" height={300}>
              <PieChart>
                <Pie
                  data={stats.categoryBreakdown}
                  cx="50%"
                  cy="50%"
                  labelLine={false}
                  label={({ name, percent }) => `${name} ${(percent * 100).toFixed(0)}%`}
                  outerRadius={100}
                  fill="#8884d8"
                  dataKey="value"
                >
                  {stats.categoryBreakdown.map((entry, index) => (
                    <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                  ))}
                </Pie>
                <Tooltip />
              </PieChart>
            </ResponsiveContainer>
          ) : (
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', height: '300px', color: '#888' }}>
              No category data available
            </div>
          )}
        </div>
      </div>

      {/* Recent Activity */}
      <div className={styles.recentActivity}>
        <h2>⚡ Recent Activity</h2>
        <div style={{ marginTop: '1rem' }}>
          {stats.recentActivity.map((activity, index) => (
            <div key={index} style={{ 
              display: 'flex', 
              justifyContent: 'space-between', 
              padding: '1rem', 
              borderBottom: '1px solid #ddd',
              alignItems: 'center'
            }}>
              <div>
                <p style={{ fontWeight: '600', color: '#88844D' }}>{activity.title}</p>
                <p style={{ fontSize: '0.875rem', color: '#666' }}>{activity.time}</p>
              </div>
              <span style={{
                padding: '0.5rem 1rem',
                borderRadius: '20px',
                fontSize: '0.75rem',
                fontWeight: '600',
                background: activity.status === 'approved' ? '#d1fae5' : activity.status === 'pending' ? '#fef3c7' : '#fee2e2',
                color: activity.status === 'approved' ? '#065f46' : activity.status === 'pending' ? '#92400e' : '#991b1b'
              }}>
                {activity.status}
              </span>
            </div>
          ))}
        </div>

        <div className={styles.quickActions}>
          <button onClick={() => window.location.href = '/listings'}>
            📦 Manage Products
          </button>
          <button onClick={() => window.location.href = '/users'}>
            👥 View Users
          </button>
          <button onClick={() => window.location.href = '/points'}>
            💎 Gems System
          </button>
        </div>
      </div>
    </div>
  );
};

export default DashboardHome;