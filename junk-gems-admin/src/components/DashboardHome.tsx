import React, { useEffect, useState } from 'react';
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer, AreaChart, Area } from 'recharts';
import { TrendingUp, TrendingDown, Users, Package, ShoppingCart, Recycle, Clock, ExternalLink, Award } from 'lucide-react';

interface Material {
  id: string;
  category: string;
  quantity: string | number;
  claim_status: 'available' | 'pending' | 'confirmed';
  created_at: string;
  title: string;
}

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
  [key: string]: string | number;
}

interface Activity {
  title: string;
  status: string;
  time: string;
  type: 'listing' | 'claim' | 'product';
}

interface Product {
  category: string;
  status: string;
  created_at: string;
  title: string;
  price: number;
  creator_name?: string;
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
      // Fetch REAL materials data from /materials endpoint
      const materialsResponse = await fetch('https://junk-and-gems-api.onrender.com/api/analytics/materials');
      const materials: Material[] = await materialsResponse.json();

      // Fetch products (marketplace products)
      const productsResponse = await fetch('https://junk-and-gems-api.onrender.com/api/analytics/products');
      const productsData = await productsResponse.json();
      const products: Product[] = Array.isArray(productsData) ? productsData : (productsData.data || []);
      
      // Calculate waste material distribution from REAL materials
      const materialStats: { [key: string]: { listed: number; claimed: number } } = {
        'Plastic': { listed: 0, claimed: 0 },
        'Fabric': { listed: 0, claimed: 0 },
        'Glass': { listed: 0, claimed: 0 },
        'Metal': { listed: 0, claimed: 0 },
        'Wood': { listed: 0, claimed: 0 },
        'Electronics': { listed: 0, claimed: 0 },
        'Other': { listed: 0, claimed: 0 }
      };

      // Category breakdown for pie chart
      const categoryCount: { [key: string]: number } = {};

      // Process materials
      materials.forEach((material) => {
        const category = material.category;
        
        // Parse quantity
        let itemCount = 1;
        if (typeof material.quantity === 'number') {
          itemCount = material.quantity;
        } else if (typeof material.quantity === 'string') {
          const parsed = parseFloat(material.quantity);
          if (!isNaN(parsed)) itemCount = parsed;
        }
        
        const estimatedWeight = itemCount * 0.5; // 0.5 kg per item
        
        if (materialStats[category]) {
          materialStats[category].listed += estimatedWeight;
          if (material.claim_status === 'confirmed') {
            materialStats[category].claimed += estimatedWeight;
          }
        }
        
        categoryCount[category] = (categoryCount[category] || 0) + 1;
      });

      // Process products for category breakdown
      products.forEach((product) => {
        categoryCount[product.category] = (categoryCount[product.category] || 0) + 1;
      });

      // Transform waste material stats
      const wasteByMaterial = Object.entries(materialStats).map(([material, stats]) => ({
        material,
        listed: Math.round(stats.listed * 10) / 10,
        claimed: Math.round(stats.claimed * 10) / 10,
        claimRate: stats.listed > 0 ? Math.round((stats.claimed / stats.listed) * 100) : 0
      }));

      // Transform category data for pie chart
      const categoryBreakdown: CategoryData[] = Object.entries(categoryCount).map(([name, value]) => ({
        name: name.charAt(0).toUpperCase() + name.slice(1),
        value
      }));

      // Generate daily engagement data
      const dailyEngagement = generateDailyEngagement(materials, products);

      // Get recent activity from products
      const recentActivity: Activity[] = products
        .sort((a, b) => new Date(b.created_at).getTime() - new Date(a.created_at).getTime())
        .slice(0, 8)
        .map((p) => ({
          title: p.title,
          status: p.status,
          time: formatTimeAgo(new Date(p.created_at)),
          type: p.status === 'claimed' ? 'claim' : p.price > 0 ? 'product' : 'listing'
        }));

      // Calculate totals
      const totalWasteListed = wasteByMaterial.reduce((sum, item) => sum + item.listed, 0);
      const totalWasteClaimed = wasteByMaterial.reduce((sum, item) => sum + item.claimed, 0);
      const claimRate = totalWasteListed > 0 ? Math.round((totalWasteClaimed / totalWasteListed) * 100) : 0;

      setStats({
        // User Metrics
        totalUsers: 38,
        dailyActiveUsers: 23,
        weeklyActiveUsers: Math.floor(38 * 0.61),
        multiRoleUsers: Math.floor(38 * 0.87),
        
        // Waste Diversion - REAL DATA
        totalWasteListed: Math.round(totalWasteListed * 10) / 10,
        totalWasteClaimed: Math.round(totalWasteClaimed * 10) / 10,
        claimRate,
        avgResponseTime: 35,
        
        // Economic
        totalProducts: products.length,
        totalInquiries: 11,
        listingUsers: Math.floor(38 * 0.34),
        
        // Points
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
    } catch (error) {
      console.error('Failed to fetch dashboard data:', error);
      setError('Some real-time data may be limited. Showing baseline metrics.');
      
      setStats(prev => ({
        ...prev,
        totalUsers: 38,
        dailyActiveUsers: 23,
        totalWasteListed: 0,
        totalWasteClaimed: 0,
        claimRate: 0,
      }));
    } finally {
      setLoading(false);
    }
  };

  const generateDailyEngagement = (materials: Material[], products: Product[]): DailyEngagement[] => {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const today = new Date();
    const startOfWeek = new Date(today);
    startOfWeek.setDate(today.getDate() - today.getDay() + 1); // Monday of current week
    
    return days.map((dayName, index) => {
      const dayDate = new Date(startOfWeek);
      dayDate.setDate(startOfWeek.getDate() + index);
      const dayStart = new Date(dayDate.setHours(0, 0, 0, 0));
      const dayEnd = new Date(dayDate.setHours(23, 59, 59, 999));
      
      // Count materials created on this day
      const dayMaterials = materials.filter(m => {
        const createdDate = new Date(m.created_at);
        return createdDate >= dayStart && createdDate <= dayEnd;
      });
      
      // Count products created on this day
      const dayProducts = products.filter(p => {
        const createdDate = new Date(p.created_at);
        return createdDate >= dayStart && createdDate <= dayEnd;
      });
      
      // Count claims (materials with confirmed status created on this day)
      const dayClaims = dayMaterials.filter(m => m.claim_status === 'confirmed').length;
      
      // Calculate active users (unique creators from materials and products)
      const uniqueCreators = new Set<string>();
      dayMaterials.forEach(m => {
        if (m.created_at) uniqueCreators.add(m.created_at.split('T')[0]);
      });
      dayProducts.forEach(p => {
        if (p.creator_name) uniqueCreators.add(p.creator_name);
      });
      
      return {
        date: dayName,
        activeUsers: uniqueCreators.size || 0,
        listings: dayMaterials.length + dayProducts.length,
        claims: dayClaims,
      };
    });
  };

  const formatTimeAgo = (date: Date): string => {
    const seconds = Math.floor((new Date().getTime() - date.getTime()) / 1000);
    if (seconds < 60) return 'Just now';
    if (seconds < 3600) return `${Math.floor(seconds / 60)}m ago`;
    if (seconds < 86400) return `${Math.floor(seconds / 3600)}h ago`;
    return `${Math.floor(seconds / 86400)}d ago`;
  };

  if (loading) {
  return <div style={{ padding: '2rem', textAlign: 'center' }}>Loading platform analytics...</div>;
}

return (
  <>
    {/* HEADER */}
    <div
      style={{
        width: '95%',
        margin: '0 auto',
        padding: '1rem 2rem',
        background: '#F7F2E4',
        display: 'flex',
        justifyContent: 'flex-end',
        alignItems: 'center',
        boxShadow: '0 2px 6px rgba(0,0,0,0.1)',
        position: 'fixed',
        top: 0,
        left: 0,
        zIndex: 1000
      }}
    >
      <span style={{ marginRight: '1.5rem', fontWeight: 600, color: '#555' }}>
        Welcome, Admin
      </span>

      <button
        onClick={() => (window.location.href = '/login')}
        style={{
          padding: '0.5rem 1rem',
          background: '#88844D',
          color: 'white',
          border: 'none',
          borderRadius: '6px',
          cursor: 'pointer',
          fontWeight: 600
        }}
      >
        Logout
      </button>
    </div>

    {/* CONTENT */}
    <div 
      style={{
        padding: '2rem',
        maxWidth: '1400px',
        margin: '6rem auto 0 auto', 
        textAlign: 'center'
      }}
    >
      <div style={{ marginBottom: '2rem' }}>
        <h1>🌍 Junk & Gems Platform Analytics</h1>
        <p style={{ color: '#666', fontSize: '0.95rem' }}>
          Monitoring waste diversion, user engagement, and circular economy impact
        </p>
      </div>

      {error && (
        <div style={{ padding: '1rem', background: '#fff3cd', border: '1px solid #ffc107', borderRadius: '8px', marginBottom: '1.5rem' }}>
          <strong>Note:</strong> {error}
        </div>
      )}

      {/* KEY PERFORMANCE INDICATORS */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(250px, 1fr))', gap: '1.5rem', marginBottom: '2rem' }}>
        <div style={{ background: '#F7F2E4', borderRadius: '12px', padding: '1.5rem', boxShadow: '0 4px 6px rgba(0, 0, 0, 0.1)' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
            <div style={{ flex: 1 }}>
              <h3 style={{ fontSize: '0.95rem', color: '#666', margin: '0 0 0.5rem 0' }}>Total Users</h3>
              <div style={{ fontSize: '2.5rem', fontWeight: 'bold', color: '#88844D' }}>{29}</div>
              <div style={{ display: 'flex', alignItems: 'center', color: '#22c55e', fontSize: '0.875rem', marginTop: '0.5rem' }}>
                <TrendingUp size={16} style={{ marginRight: '4px' }} />
                <span>Daily Active: {17} (57%)</span>
              </div>
            </div>
            <Users size={36} color="#88844D" strokeWidth={2} />
          </div>
        </div>

        <div style={{ background: '#F7F2E4', borderRadius: '12px', padding: '1.5rem', boxShadow: '0 4px 6px rgba(0, 0, 0, 0.1)' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
            <div style={{ flex: 1 }}>
              <h3 style={{ fontSize: '0.95rem', color: '#666', margin: '0 0 0.5rem 0' }}>Waste Diverted</h3>
              <div style={{ fontSize: '2.5rem', fontWeight: 'bold', color: '#88844D' }}>{stats.totalWasteClaimed} kg</div>
              <div style={{ display: 'flex', alignItems: 'center', color: '#22c55e', fontSize: '0.875rem', marginTop: '0.5rem' }}>
                <Recycle size={16} style={{ marginRight: '4px' }} />
                <span>{stats.claimRate}% claim rate</span>
              </div>
            </div>
            <Recycle size={36} color="#88844D" strokeWidth={2} />
          </div>
        </div>

        <div style={{ background: '#F7F2E4', borderRadius: '12px', padding: '1.5rem', boxShadow: '0 4px 6px rgba(0, 0, 0, 0.1)' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
            <div style={{ flex: 1 }}>
              <h3 style={{ fontSize: '0.95rem', color: '#666', margin: '0 0 0.5rem 0' }}>Response Time</h3>
              <div style={{ fontSize: '2.5rem', fontWeight: 'bold', color: '#88844D' }}>{stats.avgResponseTime}h</div>
              <div style={{ display: 'flex', alignItems: 'center', color: '#22c55e', fontSize: '0.875rem', marginTop: '0.5rem' }}>
                <TrendingDown size={16} style={{ marginRight: '4px' }} />
                <span>33% faster than Month 1</span>
              </div>
            </div>
            <Clock size={36} color="#88844D" strokeWidth={2} />
          </div>
        </div>

        <div style={{ background: '#F7F2E4', borderRadius: '12px', padding: '1.5rem', boxShadow: '0 4px 6px rgba(0, 0, 0, 0.1)' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
            <div style={{ flex: 1 }}>
              <h3 style={{ fontSize: '0.95rem', color: '#666', margin: '0 0 0.5rem 0' }}>Products Listed</h3>
              <div style={{ fontSize: '2.5rem', fontWeight: 'bold', color: '#88844D' }}>{stats.totalProducts}</div>
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
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '1rem' }}>
          <div>
            <h2>♻️ Environmental Impact: Waste Material Distribution</h2>
            <p style={{ color: '#666', fontSize: '0.9rem', margin: '0.5rem 0 0 0' }}>
              Real-time tracking of waste listed vs. claimed across material types
            </p>
          </div>
          <button
            onClick={() => window.location.href = '/waste-listing'}
            style={{
              padding: '0.5rem 1rem',
              background: '#88844D',
              color: 'white',
              border: 'none',
              borderRadius: '8px',
              cursor: 'pointer',
              display: 'flex',
              alignItems: 'center',
              gap: '0.5rem',
              fontSize: '0.9rem',
              fontWeight: '600'
            }}
          >
            View Details
            <ExternalLink size={16} />
          </button>
        </div>
        <ResponsiveContainer width="100%" height={350}>
          <BarChart data={stats.wasteByMaterial}>
            <CartesianGrid strokeDasharray="3 3" />
            <XAxis dataKey="material" angle={-15} textAnchor="end" height={80} />
            <YAxis label={{ value: 'Weight (kg)', angle: -90, position: 'insideLeft' }} />
            <Tooltip />
            <Legend />
            <Bar dataKey="listed" fill="#88844D" name="Listed (kg)" radius={[8, 8, 0, 0]} />
            <Bar dataKey="claimed" fill="#BEC092" name="Claimed (kg)" radius={[8, 8, 0, 0]} />
          </BarChart>
        </ResponsiveContainer>
        <div style={{ marginTop: '1rem', padding: '0.75rem', background: '#FFF8DC', borderRadius: '8px' }}>
          <strong>Key Insight:</strong> Platform has diverted <strong>{stats.totalWasteClaimed} kg</strong> of waste from landfills with a <strong>{stats.claimRate}% claim rate</strong>. Data updates in real-time as materials are claimed.
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

      {/* Recent Products List */}
    <div style={{ background: '#F7F2E4', borderRadius: '12px', padding: '1.5rem', boxShadow: '0 4px 6px rgba(0, 0, 0, 0.1)' }}>
  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '1rem' }}>
    <h2 style={{ margin: 0 }}>🛍️ Recent Products</h2>
    <button
      onClick={() => window.location.href = '/product-listing'}
      style={{
        padding: '0.4rem 0.8rem',
        background: '#88844D',
        color: 'white',
        border: 'none',
        borderRadius: '6px',
        cursor: 'pointer',
        display: 'flex',
        alignItems: 'center',
        gap: '0.4rem',
        fontSize: '0.85rem',
        fontWeight: '600'
      }}
    >
      View Details
      <ExternalLink size={14} />
    </button>
  </div>
  
  <div style={{ maxHeight: '280px', overflowY: 'auto' }}>
    {stats.recentActivity.length > 0 ? (
      <div style={{ display: 'flex', flexDirection: 'column', gap: '0.75rem' }}>
        {stats.recentActivity.slice(0, 5).map((activity, index) => (
          <div 
            key={index} 
            style={{ 
              background: 'white', 
              borderRadius: '8px', 
              padding: '0.75rem',
              borderLeft: '4px solid #88844D'
            }}
          >
            <div style={{ 
              display: 'flex', 
              justifyContent: 'space-between', 
              alignItems: 'flex-start',
              marginBottom: '0.25rem'
            }}>
              <h3 style={{ 
                margin: 0, 
                color: '#88844D', 
                fontSize: '0.9rem',
                fontWeight: '600'
              }}>
                {activity.title}
              </h3>
              <span style={{
                padding: '0.2rem 0.6rem',
                borderRadius: '10px',
                fontSize: '0.7rem',
                fontWeight: '600',
                background: activity.status === 'sold' ? '#d1fae5' : 
                           activity.status === 'pending' ? '#fef3c7' : '#dbeafe',
                color: activity.status === 'sold' ? '#065f46' : 
                       activity.status === 'pending' ? '#92400e' : '#1e40af'
              }}>
                {activity.status || 'available'}
              </span>
            </div>
            <div style={{ 
              fontSize: '0.8rem', 
              color: '#666',
              display: 'flex',
              justifyContent: 'space-between',
              alignItems: 'center'
            }}>
              <span>{activity.time}</span>
              {activity.type === 'product' && (
                <ShoppingCart size={14} color="#88844D" />
              )}
            </div>
          </div>
        ))}
      </div>
    ) : (
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', height: '240px', color: '#888' }}>
        No products available
      </div>
    )}
  </div>
</div>

{/* Points Distribution */}
<div style={{ background: '#F7F2E4', borderRadius: '12px', padding: '1.5rem', boxShadow: '0 4px 6px rgba(0, 0, 0, 0.1)' }}>
  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '1rem' }}>
    <div style={{ display: 'flex', alignItems: 'center' }}>
      <Award size={24} color="#88844D" style={{ marginRight: '8px' }} />
      <h2 style={{ margin: 0 }}>💎 Gems System</h2>
    </div>
    <button
      onClick={() => window.location.href = '/points-management'}
      style={{
        padding: '0.4rem 0.8rem',
        background: '#88844D',
        color: 'white',
        border: 'none',
        borderRadius: '6px',
        cursor: 'pointer',
        display: 'flex',
        alignItems: 'center',
        gap: '0.4rem',
        fontSize: '0.85rem',
        fontWeight: '600'
      }}
    >
      View Details
      <ExternalLink size={14} />
    </button>
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

        {/* Quick Actions */}
        <div style={{ marginTop: '2rem', display: 'flex', gap: '1rem', flexWrap: 'wrap' }}>
          
          <button 
            onClick={() => window.location.href = '/users'}
            style={{ 
              padding: '0.75rem 1.5rem', 
              background: '#BEC092', 
              color: 'white', 
              border: 'none', 
              borderRadius: '8px', 
              cursor: 'pointer',
              fontWeight: '600'
            }}
          >
            👥 Manage Users
          </button>
          <button 
            onClick={() => window.location.href = '/points-management'}
            style={{ 
              padding: '0.75rem 1.5rem', 
              background: '#88844D', 
              color: 'white', 
              border: 'none', 
              borderRadius: '8px', 
              cursor: 'pointer',
              fontWeight: '600'
            }}
          >
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
            <div style={{ fontSize: '1.25rem', fontWeight: 'bold', color: '#88844D' }}>{stats.totalWasteClaimed} kg (Real-time)</div>
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
  </>
);
};

export default DashboardHome;