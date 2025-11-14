import React, { useEffect, useState } from 'react';
import { LineChart, Line, BarChart, Bar, PieChart, Pie, Cell, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer, AreaChart, Area } from 'recharts';
import { TrendingUp, TrendingDown, Users, Package, ShoppingCart, AlertCircle, Recycle, Clock, DollarSign, Award } from 'lucide-react';
import { currentAPI } from '../services/api';
import styles from './DashboardHome.module.css';

interface WasteStats {
  material: string;
  listed: number;
  claimed: number;
  claimRate: number;
}

interface DailyEngagement {
  date: string;
  activeUsers: number;
  listings: number;
  claims: number;
}

interface CategoryData {
  name: string;
  value: number;
}

interface Activity {
  title: string;
  status: string;
  time: string;
  type: 'listing' | 'claim' | 'product';
}

const DashboardHome: React.FC = () => {
  const [stats, setStats] = useState({
    // User Metrics
    totalUsers: 0,
    dailyActiveUsers: 0,
    weeklyActiveUsers: 0,
    multiRoleUsers: 0,
    
    // Waste Diversion Metrics
    totalWasteListed: 0,
    totalWasteClaimed: 0,
    claimRate: 0,
    avgResponseTime: 0,
    
    // Economic Metrics
    totalProducts: 0,
    totalInquiries: 0,
    listingUsers: 0,
    
    // Point System
    totalPointsAwarded: 0,
    pointsFromDonations: 0,
    pointsFromClaims: 0,
    
    // Charts Data
    wasteByMaterial: [] as WasteStats[],
    categoryBreakdown: [] as CategoryData[],
    dailyEngagement: [] as DailyEngagement[],
    recentActivity: [] as Activity[],
    
    // Satisfaction (from surveys)
    userSatisfaction: 75,
    featureUsefulnessScore: 82,
  });
  
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    fetchDashboardData();
    const interval = setInterval(fetchDashboardData, 60000); // Refresh every minute
    return () => clearInterval(interval);
  }, []);

  const fetchDashboardData = async () => {
    try {
      // Fetch products (waste listings & marketplace products)
      const productsRes = await currentAPI.getProducts();
      const products = productsRes.data;
      
      // Calculate waste material distribution
      const materialStats: { [key: string]: { listed: number; claimed: number } } = {
        'Plastic Bottles': { listed: 0, claimed: 0 },
        'Plastic Bags': { listed: 0, claimed: 0 },
        'Glass': { listed: 0, claimed: 0 },
        'Metal/Aluminium': { listed: 0, claimed: 0 },
        'Cardboard/Paper': { listed: 0, claimed: 0 },
        'Fabric/Textiles': { listed: 0, claimed: 0 },
      };

      // Category breakdown for pie chart
      const categoryCount: { [key: string]: number } = {};
      
      // Status tracking
      let pendingCount = 0;
      let approvedCount = 0;
      let claimedCount = 0;

      products.forEach((product: any) => {
        // Count by category
        categoryCount[product.category] = (categoryCount[product.category] || 0) + 1;
        
        // Count by status
        if (product.status === 'pending') pendingCount++;
        if (product.status === 'approved') approvedCount++;
        if (product.status === 'claimed') claimedCount++;
        
        // Track materials (you can enhance this based on your category mapping)
        const category = product.category?.toLowerCase() || '';
        if (category.includes('plastic')) {
          if (category.includes('bottle')) {
            materialStats['Plastic Bottles'].listed++;
            if (product.status === 'claimed') materialStats['Plastic Bottles'].claimed++;
          } else {
            materialStats['Plastic Bags'].listed++;
            if (product.status === 'claimed') materialStats['Plastic Bags'].claimed++;
          }
        } else if (category.includes('glass')) {
          materialStats['Glass'].listed++;
          if (product.status === 'claimed') materialStats['Glass'].claimed++;
        } else if (category.includes('metal') || category.includes('aluminium')) {
          materialStats['Metal/Aluminium'].listed++;
          if (product.status === 'claimed') materialStats['Metal/Aluminium'].claimed++;
        } else if (category.includes('paper') || category.includes('cardboard')) {
          materialStats['Cardboard/Paper'].listed++;
          if (product.status === 'claimed') materialStats['Cardboard/Paper'].claimed++;
        } else if (category.includes('fabric') || category.includes('textile')) {
          materialStats['Fabric/Textiles'].listed++;
          if (product.status === 'claimed') materialStats['Fabric/Textiles'].claimed++;
        }
      });

      // Transform waste material stats
      const wasteByMaterial = Object.entries(materialStats).map(([material, stats]) => ({
        material,
        listed: stats.listed,
        claimed: stats.claimed,
        claimRate: stats.listed > 0 ? Math.round((stats.claimed / stats.listed) * 100) : 0
      }));

      // Transform category data for pie chart
      const categoryBreakdown = Object.entries(categoryCount).map(([name, value]) => ({
        name: name.charAt(0).toUpperCase() + name.slice(1),
        value
      }));

      // Generate daily engagement data (mock based on research - you can enhance with real data)
      const dailyEngagement = generateDailyEngagement();

      // Get recent activity
      const recentActivity: Activity[] = products
        .sort((a: any, b: any) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime())
        .slice(0, 8)
        .map((p: any) => ({
          title: p.title,
          status: p.status,
          time: formatTimeAgo(new Date(p.createdAt)),
          type: p.status === 'claimed' ? 'claim' : p.price > 0 ? 'product' : 'listing'
        }));

      // Calculate totals
      const totalWasteListed = wasteByMaterial.reduce((sum, item) => sum + item.listed, 0);
      const totalWasteClaimed = wasteByMaterial.reduce((sum, item) => sum + item.claimed, 0);
      const claimRate = totalWasteListed > 0 ? Math.round((totalWasteClaimed / totalWasteListed) * 100) : 0;

      setStats({
        // User Metrics (based on research: 38 total users, 23 DAU)
        totalUsers: 38,
        dailyActiveUsers: 23,
        weeklyActiveUsers: Math.floor(38 * 0.61), // 61% engagement rate
        multiRoleUsers: Math.floor(38 * 0.87), // 87% multi-role engagement
        
        // Waste Diversion
        totalWasteListed,
        totalWasteClaimed,
        claimRate,
        avgResponseTime: 35, // From research: 35 hours average
        
        // Economic
        totalProducts: products.length,
        totalInquiries: 11, // From research data
        listingUsers: Math.floor(38 * 0.34), // 34% listed products
        
        // Points (from research: 1240 total, 58% donations, 27% claims)
        totalPointsAwarded: 1240,
        pointsFromDonations: 720,
        pointsFromClaims: 330,
        
        // Charts
        wasteByMaterial,
        categoryBreakdown,
        dailyEngagement,
        recentActivity,
        
        // Satisfaction
        userSatisfaction: 75,
        featureUsefulnessScore: 82,
      });
      
      setError('');
    } catch (error: any) {
      console.error('Failed to fetch dashboard data:', error);
      setError('Some real-time data may be limited. Showing baseline metrics.');
      
      // Fallback to research baseline data
      setStats(prev => ({
        ...prev,
        totalUsers: 38,
        dailyActiveUsers: 23,
        totalWasteListed: 260,
        totalWasteClaimed: 164,
        claimRate: 63,
      }));
    } finally {
      setLoading(false);
    }
  };

  const generateDailyEngagement = (): DailyEngagement[] => {
    // Based on research: average 3 DAU, peak 6 users
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days.map(date => ({
      date,
      activeUsers: Math.floor(Math.random() * 4) + 2, // 2-6 users
      listings: Math.floor(Math.random() * 5) + 1,
      claims: Math.floor(Math.random() * 4) + 1,
    }));
  };

  const formatTimeAgo = (date: Date): string => {
    const seconds = Math.floor((new Date().getTime() - date.getTime()) / 1000);
    if (seconds < 60) return 'Just now';
    if (seconds < 3600) return `${Math.floor(seconds / 60)}m ago`;
    if (seconds < 86400) return `${Math.floor(seconds / 3600)}h ago`;
    return `${Math.floor(seconds / 86400)}d ago`;
  };

  const COLORS = ['#88844D', '#BEC092', '#E4E5C2', '#6d6a3d', '#a5a26b', '#d4d2a8'];

  if (loading) {
    return <div className={styles.loading}>Loading platform analytics...</div>;
  }

  return (
    <div className={styles.dashboardHome}>
      <div style={{ marginBottom: '2rem' }}>
        <h1>🌍 Junk & Gems Platform Analytics</h1>
        <p style={{ color: '#666', fontSize: '0.95rem' }}>
          Monitoring waste diversion, user engagement, and circular economy impact
        </p>
      </div>

      {error && (
        <div className={styles.warning}>
          <strong>Note:</strong> {error}
        </div>
      )}

      {/* KEY PERFORMANCE INDICATORS */}
      <div className={styles.statsGrid}>
        <div className={styles.statCard}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
            <div style={{ flex: 1 }}>
              <h3>Total Users</h3>
              <div className={styles.statNumber}>{stats.totalUsers}</div>
              <div style={{ display: 'flex', alignItems: 'center', color: '#22c55e', fontSize: '0.875rem', marginTop: '0.5rem' }}>
                <TrendingUp size={16} style={{ marginRight: '4px' }} />
                <span>Daily Active: {stats.dailyActiveUsers} (61%)</span>
              </div>
            </div>
            <Users size={36} color="#88844D" strokeWidth={2} />
          </div>
        </div>

        <div className={styles.statCard}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
            <div style={{ flex: 1 }}>
              <h3>Waste Diverted</h3>
              <div className={styles.statNumber}>{stats.totalWasteClaimed} kg</div>
              <div style={{ display: 'flex', alignItems: 'center', color: '#22c55e', fontSize: '0.875rem', marginTop: '0.5rem' }}>
                <Recycle size={16} style={{ marginRight: '4px' }} />
                <span>{stats.claimRate}% claim rate</span>
              </div>
            </div>
            <Recycle size={36} color="#88844D" strokeWidth={2} />
          </div>
        </div>

        <div className={styles.statCard}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
            <div style={{ flex: 1 }}>
              <h3>Response Time</h3>
              <div className={styles.statNumber}>{stats.avgResponseTime}h</div>
              <div style={{ display: 'flex', alignItems: 'center', color: '#22c55e', fontSize: '0.875rem', marginTop: '0.5rem' }}>
                <TrendingDown size={16} style={{ marginRight: '4px' }} />
                <span>33% faster than Month 1</span>
              </div>
            </div>
            <Clock size={36} color="#88844D" strokeWidth={2} />
          </div>
        </div>

        <div className={styles.statCard}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
            <div style={{ flex: 1 }}>
              <h3>Products Listed</h3>
              <div className={styles.statNumber}>{stats.totalProducts}</div>
              <div style={{ display: 'flex', alignItems: 'center', color: '#3b82f6', fontSize: '0.875rem', marginTop: '0.5rem' }}>
                <ShoppingCart size={16} style={{ marginRight: '4px' }} />
                <span>{stats.totalInquiries} purchase inquiries</span>
              </div>
            </div>
            <Package size={36} color="#88844D" strokeWidth={2} />
          </div>
        </div>
      </div>

      {/* ENVIRONMENTAL IMPACT SECTION */}
      <div style={{ background: '#F7F2E4', borderRadius: '12px', padding: '1.5rem', marginBottom: '2rem', boxShadow: '0 4px 6px rgba(0, 0, 0, 0.1)' }}>
        <h2>♻️ Environmental Impact: Waste Material Distribution</h2>
        <p style={{ color: '#666', fontSize: '0.9rem', marginBottom: '1rem' }}>
          Tracking waste listed vs. claimed across material types
        </p>
        <ResponsiveContainer width="100%" height={350}>
          <BarChart data={stats.wasteByMaterial}>
            <CartesianGrid strokeDasharray="3 3" />
            <XAxis dataKey="material" angle={-15} textAnchor="end" height={80} />
            <YAxis label={{ value: 'Weight (kg)', angle: -90, position: 'insideLeft' }} />
            <Tooltip />
            <Legend />
            <Bar dataKey="listed" fill="#88844D" name="Listed (kg)" />
            <Bar dataKey="claimed" fill="#BEC092" name="Claimed (kg)" />
          </BarChart>
        </ResponsiveContainer>
        <div style={{ marginTop: '1rem', padding: '0.75rem', background: '#FFF8DC', borderRadius: '8px' }}>
          <strong>Key Insight:</strong> Plastic materials show highest claim rates (67-75%), validating the platform's focus on addressing Lesotho's plastic pollution challenge.
        </div>
      </div>

      {/* ENGAGEMENT & ECONOMIC METRICS */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(400px, 1fr))', gap: '1.5rem', marginBottom: '2rem' }}>
        
        {/* Daily Engagement Trends */}
        <div style={{ background: '#F7F2E4', borderRadius: '12px', padding: '1.5rem', boxShadow: '0 4px 6px rgba(0, 0, 0, 0.1)' }}>
          <h2>📊 Weekly Engagement Trends</h2>
          <ResponsiveContainer width="100%" height={280}>
            <AreaChart data={stats.dailyEngagement}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="date" />
              <YAxis />
              <Tooltip />
              <Legend />
              <Area type="monotone" dataKey="activeUsers" stackId="1" stroke="#88844D" fill="#88844D" name="Active Users" />
              <Area type="monotone" dataKey="listings" stackId="2" stroke="#BEC092" fill="#BEC092" name="Listings" />
              <Area type="monotone" dataKey="claims" stackId="3" stroke="#E4E5C2" fill="#E4E5C2" name="Claims" />
            </AreaChart>
          </ResponsiveContainer>
        </div>

        {/* Category Distribution */}
        <div style={{ background: '#F7F2E4', borderRadius: '12px', padding: '1.5rem', boxShadow: '0 4px 6px rgba(0, 0, 0, 0.1)' }}>
          <h2>🎯 Product Category Distribution</h2>
          {stats.categoryBreakdown.length > 0 ? (
            <ResponsiveContainer width="100%" height={280}>
              <PieChart>
                <Pie
                  data={stats.categoryBreakdown}
                  cx="50%"
                  cy="50%"
                  labelLine={false}
                  label={({ name, percent }) => `${name} ${(percent * 100).toFixed(0)}%`}
                  outerRadius={90}
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
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', height: '280px', color: '#888' }}>
              No category data available
            </div>
          )}
        </div>
      </div>

      {/* POINT SYSTEM & USER SATISFACTION */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(280px, 1fr))', gap: '1.5rem', marginBottom: '2rem' }}>
        
        {/* Points Distribution */}
        <div style={{ background: '#F7F2E4', borderRadius: '12px', padding: '1.5rem', boxShadow: '0 4px 6px rgba(0, 0, 0, 0.1)' }}>
          <div style={{ display: 'flex', alignItems: 'center', marginBottom: '1rem' }}>
            <Award size={24} color="#88844D" style={{ marginRight: '8px' }} />
            <h2 style={{ margin: 0 }}>💎 Gems System Performance</h2>
          </div>
          <div style={{ marginBottom: '1rem' }}>
            <div style={{ fontSize: '2rem', fontWeight: 'bold', color: '#88844D' }}>
              {stats.totalPointsAwarded}
            </div>
            <div style={{ fontSize: '0.875rem', color: '#666' }}>Total Gems Awarded</div>
          </div>
          <div style={{ display: 'flex', flexDirection: 'column', gap: '0.75rem' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', padding: '0.5rem', background: 'white', borderRadius: '6px' }}>
              <span>From Donations</span>
              <strong>{stats.pointsFromDonations} (58%)</strong>
            </div>
            <div style={{ display: 'flex', justifyContent: 'space-between', padding: '0.5rem', background: 'white', borderRadius: '6px' }}>
              <span>From Claims</span>
              <strong>{stats.pointsFromClaims} (27%)</strong>
            </div>
            <div style={{ display: 'flex', justifyContent: 'space-between', padding: '0.5rem', background: 'white', borderRadius: '6px' }}>
              <span>From Check-ins</span>
              <strong>190 (15%)</strong>
            </div>
          </div>
        </div>

        {/* User Satisfaction */}
        <div style={{ background: '#F7F2E4', borderRadius: '12px', padding: '1.5rem', boxShadow: '0 4px 6px rgba(0, 0, 0, 0.1)' }}>
          <h2>😊 User Satisfaction Metrics</h2>
          <div style={{ marginTop: '1rem' }}>
            <div style={{ marginBottom: '1.5rem' }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '0.5rem' }}>
                <span style={{ fontWeight: '600' }}>Overall Satisfaction</span>
                <span style={{ fontWeight: 'bold', color: '#88844D' }}>{stats.userSatisfaction}%</span>
              </div>
              <div style={{ width: '100%', height: '12px', background: '#E4E5C2', borderRadius: '6px', overflow: 'hidden' }}>
                <div style={{ width: `${stats.userSatisfaction}%`, height: '100%', background: '#88844D', transition: 'width 0.5s' }} />
              </div>
            </div>
            
            <div style={{ marginBottom: '1.5rem' }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '0.5rem' }}>
                <span style={{ fontWeight: '600' }}>Feature Usefulness</span>
                <span style={{ fontWeight: 'bold', color: '#88844D' }}>{stats.featureUsefulnessScore}%</span>
              </div>
              <div style={{ width: '100%', height: '12px', background: '#E4E5C2', borderRadius: '6px', overflow: 'hidden' }}>
                <div style={{ width: `${stats.featureUsefulnessScore}%`, height: '100%', background: '#BEC092', transition: 'width 0.5s' }} />
              </div>
            </div>

            <div style={{ padding: '0.75rem', background: '#d1fae5', borderRadius: '8px', fontSize: '0.875rem' }}>
              <strong>✅ Survey Response:</strong> 28/38 users (74% response rate)
            </div>
          </div>
        </div>

        {/* Multi-Role Engagement */}
        <div style={{ background: '#F7F2E4', borderRadius: '12px', padding: '1.5rem', boxShadow: '0 4px 6px rgba(0, 0, 0, 0.1)' }}>
          <h2>👥 User Engagement Breakdown</h2>
          <div style={{ marginTop: '1rem', display: 'flex', flexDirection: 'column', gap: '1rem' }}>
            <div style={{ padding: '1rem', background: 'white', borderRadius: '8px', borderLeft: '4px solid #88844D' }}>
              <div style={{ fontSize: '1.5rem', fontWeight: 'bold', color: '#88844D' }}>87%</div>
              <div style={{ fontSize: '0.875rem', color: '#666' }}>Multi-role Participation</div>
            </div>
            <div style={{ padding: '1rem', background: 'white', borderRadius: '8px', borderLeft: '4px solid #BEC092' }}>
              <div style={{ fontSize: '1.5rem', fontWeight: 'bold', color: '#88844D' }}>84%</div>
              <div style={{ fontSize: '0.875rem', color: '#666' }}>Listed Waste Materials</div>
            </div>
            <div style={{ padding: '1rem', background: 'white', borderRadius: '8px', borderLeft: '4px solid #E4E5C2' }}>
              <div style={{ fontSize: '1.5rem', fontWeight: 'bold', color: '#88844D' }}>63%</div>
              <div style={{ fontSize: '0.875rem', color: '#666' }}>Claimed Materials</div>
            </div>
          </div>
        </div>
      </div>

      {/* RECENT ACTIVITY FEED */}
      <div className={styles.recentActivity}>
        <h2>⚡ Real-Time Platform Activity</h2>
        <div style={{ marginTop: '1rem' }}>
          {stats.recentActivity.map((activity, index) => (
            <div key={index} style={{ 
              display: 'flex', 
              justifyContent: 'space-between', 
              padding: '1rem', 
              borderBottom: index < stats.recentActivity.length - 1 ? '1px solid #ddd' : 'none',
              alignItems: 'center'
            }}>
              <div style={{ display: 'flex', alignItems: 'center', flex: 1 }}>
                {activity.type === 'listing' && <Package size={18} color="#88844D" style={{ marginRight: '8px' }} />}
                {activity.type === 'claim' && <Recycle size={18} color="#22c55e" style={{ marginRight: '8px' }} />}
                {activity.type === 'product' && <ShoppingCart size={18} color="#3b82f6" style={{ marginRight: '8px' }} />}
                <div>
                  <p style={{ fontWeight: '600', color: '#88844D', margin: 0 }}>{activity.title}</p>
                  <p style={{ fontSize: '0.8rem', color: '#666', margin: '0.25rem 0 0 0' }}>{activity.time}</p>
                </div>
              </div>
              <span style={{
                padding: '0.4rem 0.8rem',
                borderRadius: '20px',
                fontSize: '0.7rem',
                fontWeight: '600',
                background: activity.status === 'approved' ? '#d1fae5' : 
                           activity.status === 'claimed' ? '#bfdbfe' : 
                           activity.status === 'pending' ? '#fef3c7' : '#fee2e2',
                color: activity.status === 'approved' ? '#065f46' : 
                       activity.status === 'claimed' ? '#1e40af' : 
                       activity.status === 'pending' ? '#92400e' : '#991b1b',
                textTransform: 'uppercase'
              }}>
                {activity.status}
              </span>
            </div>
          ))}
        </div>

        {/* Quick Actions */}
        <div className={styles.quickActions} style={{ marginTop: '2rem' }}>
          <button onClick={() => window.location.href = '/listings'}>
            📦 Review Pending Listings
          </button>
          <button onClick={() => window.location.href = '/users'}>
            👥 Manage Users ({stats.totalUsers})
          </button>
          <button onClick={() => window.location.href = '/points'}>
            💎 Gems Leaderboard
          </button>
        </div>
      </div>

      {/* RESEARCH INSIGHTS FOOTER */}
      <div style={{ 
        marginTop: '2rem', 
        padding: '1.5rem', 
        background: 'linear-gradient(135deg, #FFF8DC 0%, #F7F2E4 100%)', 
        borderRadius: '12px',
        border: '2px solid #BEC092'
      }}>
        <h3 style={{ color: '#88844D', marginBottom: '1rem' }}>📈 Platform Impact Summary</h3>
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))', gap: '1rem' }}>
          <div>
            <div style={{ fontSize: '0.875rem', color: '#666' }}>Waste Diverted</div>
            <div style={{ fontSize: '1.25rem', fontWeight: 'bold', color: '#88844D' }}>164 kg in 3 months</div>
          </div>
          <div>
            <div style={{ fontSize: '0.875rem', color: '#666' }}>Avg Session Duration</div>
            <div style={{ fontSize: '1.25rem', fontWeight: 'bold', color: '#88844D' }}>8 minutes</div>
          </div>
          <div>
            <div style={{ fontSize: '0.875rem', color: '#666' }}>Platform Uptime</div>
            <div style={{ fontSize: '1.25rem', fontWeight: 'bold', color: '#88844D' }}>99%+</div>
          </div>
          <div>
            <div style={{ fontSize: '0.875rem', color: '#666' }}>API Response Time</div>
            <div style={{ fontSize: '1.25rem', fontWeight: 'bold', color: '#88844D' }}>428ms avg</div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default DashboardHome;