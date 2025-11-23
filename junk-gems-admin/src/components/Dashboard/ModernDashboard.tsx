import React, { useEffect, useState } from 'react';
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer, LineChart, Line, PieChart, Pie, Cell, AreaChart, Area } from 'recharts';
import { TrendingUp, Users, Package, Recycle, DollarSign, Award, Moon, Sun } from 'lucide-react';
import { useTheme } from '../../contexts/useTheme';

interface Material {
  category: string;
  quantity: string | number;
  claim_status: string;
}

interface Product {
  category: string;
  status: string;
  price: string | number;
}

interface DashboardStats {
  totalUsers: number;
  dailyActiveUsers: number;
  totalProducts: number;
  totalRevenue: number;
  wasteByMaterial: Array<{ material: string; listed: number; claimed: number }>;
  categoryBreakdown: Array<{ name: string; value: number }>;
  dailyEngagement: Array<{ date: string; activeUsers: number; listings: number; claims: number }>;
  revenueOverTime: Array<{ month: string; revenue: number }>;
}

const ModernAdminDashboard = () => {
  const { theme, toggleTheme } = useTheme();
  const isDark = theme === 'dark';

  const [stats, setStats] = useState<DashboardStats>({
    totalUsers: 0,
    dailyActiveUsers: 0,
    totalProducts: 0,
    totalRevenue: 0,
    wasteByMaterial: [],
    categoryBreakdown: [],
    dailyEngagement: [],
    revenueOverTime: []
  });
  const [loading, setLoading] = useState(true);

  const colors = {
    background: isDark ? '#1a1a1a' : 'linear-gradient(135deg, #F7F2E4 0%, #E4E5C2 100%)',
    cardBg: isDark ? '#2d2d2d' : 'white',
    text: isDark ? '#e5e7eb' : '#1f2937',
    textSecondary: isDark ? '#9ca3af' : '#666',
    border: isDark ? '#404040' : '#e5e7eb',
    primary: '#88844D',
    success: '#22c55e',
    info: '#3b82f6',
    warning: '#f59e0b',
    chartGrid: isDark ? '#404040' : '#e5e7eb',
    chartText: isDark ? '#9ca3af' : '#6b7280'
  };

  useEffect(() => {
    fetchDashboardData();
  }, []);

  const fetchDashboardData = async () => {
    try {
      const [materialsRes, productsRes] = await Promise.all([
        fetch('https://junk-and-gems-api.onrender.com/api/analytics/materials'),
        fetch('https://junk-and-gems-api.onrender.com/api/analytics/products')
      ]);

      const materials: Material[] = await materialsRes.json();
      const products: Product[] = await productsRes.json();
      
      const materialStats: { [key: string]: { listed: number; claimed: number } } = {};
      materials.forEach((m) => {
        const cat = m.category || 'Other';
        if (!materialStats[cat]) materialStats[cat] = { listed: 0, claimed: 0 };
        const weight = parseFloat(String(m.quantity)) || 1;
        materialStats[cat].listed += weight;
        if (m.claim_status === 'confirmed') materialStats[cat].claimed += weight;
      });

      const wasteByMaterial = Object.entries(materialStats).map(([material, data]) => ({
        material,
        listed: Math.round(data.listed * 10) / 10,
        claimed: Math.round(data.claimed * 10) / 10
      }));

      const categoryCount: { [key: string]: number } = {};
      let totalRevenue = 0;
      
      const productsArray = Array.isArray(products) ? products : [];
      productsArray.forEach((p) => {
        categoryCount[p.category] = (categoryCount[p.category] || 0) + 1;
        if (p.status === 'sold') totalRevenue += parseFloat(String(p.price)) || 0;
      });

      const categoryBreakdown = Object.entries(categoryCount).map(([name, value]) => ({
        name,
        value
      }));

      const dailyEngagement = generateDailyData();
      const revenueOverTime = generateMonthlyRevenue();

      setStats({
        totalUsers: 29,
        dailyActiveUsers: 17,
        totalProducts: productsArray.length,
        totalRevenue: Math.round(totalRevenue * 100) / 100,
        wasteByMaterial,
        categoryBreakdown,
        dailyEngagement,
        revenueOverTime
      });
    } catch (error) {
      console.error('Error fetching data:', error);
    } finally {
      setLoading(false);
    }
  };

  const generateDailyData = () => {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days.map(day => ({
      date: day,
      activeUsers: Math.floor(Math.random() * 20) + 10,
      listings: Math.floor(Math.random() * 15) + 5,
      claims: Math.floor(Math.random() * 10) + 3
    }));
  };

  const generateMonthlyRevenue = () => {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
    return months.map((month, i) => ({
      month,
      revenue: Math.floor(Math.random() * 5000) + 2000 + (i * 500)
    }));
  };

  const COLORS = ['#88844D', '#BEC092', '#E4E5C2', '#F7F2E4', '#22c55e', '#3b82f6', '#ef4444', '#f59e0b'];

  if (loading) {
    return (
      <div style={{
        minHeight: '100vh',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        background: colors.background
      }}>
        <div style={{
          border: '4px solid ' + (isDark ? '#404040' : '#f3f3f3'),
          borderTop: '4px solid #88844D',
          borderRadius: '50%',
          width: '60px',
          height: '60px',
          animation: 'spin 1s linear infinite'
        }} />
        <style>{`@keyframes spin { 0% { transform: rotate(0deg); } 100% { transform: rotate(360deg); }}`}</style>
      </div>
    );
  }

  return (
    <div style={{
      minHeight: '100vh',
      background: colors.background,
      padding: '2rem',
      fontFamily: '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif',
      transition: 'background 0.3s ease'
    }}>
      {/* Header */}
      <div style={{
        maxWidth: '1400px',
        margin: '0 auto',
        marginBottom: '2rem'
      }}>
        <div style={{
          display: 'flex',
          justifyContent: 'space-between',
          alignItems: 'center',
          flexWrap: 'wrap',
          gap: '1rem'
        }}>
          <div>
            <h1 style={{
              margin: '0 0 0.5rem 0',
              fontSize: 'clamp(1.75rem, 4vw, 2.5rem)',
              fontWeight: '700',
              color: colors.text,
              transition: 'color 0.3s ease'
            }}>
              Junk & Gems Platform Analytics
            </h1>
            <p style={{ margin: 0, color: colors.textSecondary, fontSize: 'clamp(0.875rem, 2vw, 1rem)', transition: 'color 0.3s ease' }}>
              Monitoring waste diversion, user engagement, and circular economy impact
            </p>
          </div>
          <div style={{ display: 'flex', gap: '1rem', alignItems: 'center' }}>
            <button
              onClick={toggleTheme}
              style={{
                padding: '0.75rem',
                background: colors.cardBg,
                color: colors.text,
                border: '2px solid ' + colors.border,
                borderRadius: '8px',
                cursor: 'pointer',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                transition: 'all 0.3s ease'
              }}
              title={`Switch to ${isDark ? 'light' : 'dark'} mode`}
            >
              {isDark ? <Sun size={20} /> : <Moon size={20} />}
            </button>
            <button
              onClick={() => window.location.href = '/login'}
              style={{
                padding: '0.75rem 1.5rem',
                background: colors.primary,
                color: 'white',
                border: 'none',
                borderRadius: '8px',
                cursor: 'pointer',
                fontWeight: '600',
                fontSize: '0.95rem',
                transition: 'all 0.3s ease'
              }}
            >
              Logout
            </button>
          </div>
        </div>
      </div>

      <div style={{
        maxWidth: '1400px',
        margin: '0 auto'
      }}>
        {/* KPI Cards */}
        <div style={{
          display: 'grid',
          gridTemplateColumns: 'repeat(auto-fit, minmax(280px, 1fr))',
          gap: '1.5rem',
          marginBottom: '2rem'
        }}>
          {[
            { label: 'Total Users', value: stats.totalUsers, icon: Users, color: colors.primary, trend: `Daily Active: ${stats.dailyActiveUsers} (58%)` },
            { label: 'Total Products', value: stats.totalProducts, icon: Package, color: colors.success, trend: '11 purchase inquiries' },
            { label: 'Total Revenue', value: `M${stats.totalRevenue}`, icon: DollarSign, color: colors.info, trend: '+12% from last month' },
            { label: 'Waste Diverted', value: `${stats.wasteByMaterial.reduce((sum, item) => sum + item.claimed, 0).toFixed(1)} kg`, icon: Recycle, color: colors.warning, trend: 'From landfills' }
          ].map((item, index) => (
            <div key={index} style={{
              background: colors.cardBg,
              borderRadius: '16px',
              padding: '1.5rem',
              boxShadow: isDark ? '0 4px 12px rgba(0,0,0,0.3)' : '0 4px 12px rgba(0,0,0,0.08)',
              borderLeft: `4px solid ${item.color}`,
              transition: 'all 0.3s ease'
            }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: '1rem' }}>
                <div style={{ flex: 1 }}>
                  <div style={{ fontSize: '0.875rem', color: colors.textSecondary, marginBottom: '0.5rem', fontWeight: '500', transition: 'color 0.3s ease' }}>
                    {item.label}
                  </div>
                  <div style={{ fontSize: 'clamp(2rem, 5vw, 2.5rem)', fontWeight: '700', color: item.color }}>
                    {item.value}
                  </div>
                </div>
                <div style={{
                  width: '48px',
                  height: '48px',
                  borderRadius: '12px',
                  background: item.color + '20',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center'
                }}>
                  <item.icon size={24} color={item.color} />
                </div>
              </div>
              <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', color: colors.success, fontSize: '0.875rem' }}>
                <TrendingUp size={16} />
                <span>{item.trend}</span>
              </div>
            </div>
          ))}
        </div>

        {/* Charts Row 1 */}
        <div style={{
          display: 'grid',
          gridTemplateColumns: 'repeat(auto-fit, minmax(min(100%, 500px), 1fr))',
          gap: '1.5rem',
          marginBottom: '2rem'
        }}>
          {/* Revenue Over Time */}
          <div style={{
            background: colors.cardBg,
            borderRadius: '16px',
            padding: '1.5rem',
            boxShadow: isDark ? '0 4px 12px rgba(0,0,0,0.3)' : '0 4px 12px rgba(0,0,0,0.08)',
            transition: 'all 0.3s ease'
          }}>
            <h2 style={{
              margin: '0 0 1.5rem 0',
              fontSize: '1.25rem',
              fontWeight: '600',
              color: colors.text,
              transition: 'color 0.3s ease'
            }}>
              Revenue Trend
            </h2>
            <ResponsiveContainer width="100%" height={300}>
              <LineChart data={stats.revenueOverTime}>
                <CartesianGrid strokeDasharray="3 3" stroke={colors.chartGrid} />
                <XAxis dataKey="month" stroke={colors.chartText} style={{ fontSize: '0.875rem' }} />
                <YAxis stroke={colors.chartText} style={{ fontSize: '0.875rem' }} />
                <Tooltip
                  contentStyle={{
                    background: colors.cardBg,
                    border: '1px solid ' + colors.border,
                    borderRadius: '8px',
                    boxShadow: '0 4px 6px rgba(0,0,0,0.1)',
                    color: colors.text
                  }}
                />
                <Line
                  type="monotone"
                  dataKey="revenue"
                  stroke={colors.info}
                  strokeWidth={3}
                  dot={{ fill: colors.info, strokeWidth: 2, r: 4 }}
                  activeDot={{ r: 6 }}
                />
              </LineChart>
            </ResponsiveContainer>
          </div>

          {/* Category Distribution */}
          <div style={{
            background: colors.cardBg,
            borderRadius: '16px',
            padding: '1.5rem',
            boxShadow: isDark ? '0 4px 12px rgba(0,0,0,0.3)' : '0 4px 12px rgba(0,0,0,0.08)',
            transition: 'all 0.3s ease'
          }}>
            <h2 style={{
              margin: '0 0 1.5rem 0',
              fontSize: '1.25rem',
              fontWeight: '600',
              color: colors.text,
              transition: 'color 0.3s ease'
            }}>
              Product Categories
            </h2>
            <ResponsiveContainer width="100%" height={300}>
              <PieChart>
                <Pie
                  data={stats.categoryBreakdown}
                  cx="50%"
                  cy="50%"
                  labelLine={false}
                  label={(entry) => entry.name}
                  outerRadius={100}
                  fill="#8884d8"
                  dataKey="value"
                >
                  {stats.categoryBreakdown.map((entry, index) => (
                    <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                  ))}
                </Pie>
                <Tooltip contentStyle={{ background: colors.cardBg, border: '1px solid ' + colors.border, color: colors.text }} />
              </PieChart>
            </ResponsiveContainer>
          </div>
        </div>

        {/* Charts Row 2 */}
        <div style={{
          display: 'grid',
          gridTemplateColumns: 'repeat(auto-fit, minmax(min(100%, 500px), 1fr))',
          gap: '1.5rem',
          marginBottom: '2rem'
        }}>
          {/* Weekly Engagement */}
          <div style={{
            background: colors.cardBg,
            borderRadius: '16px',
            padding: '1.5rem',
            boxShadow: isDark ? '0 4px 12px rgba(0,0,0,0.3)' : '0 4px 12px rgba(0,0,0,0.08)',
            transition: 'all 0.3s ease'
          }}>
            <h2 style={{
              margin: '0 0 1.5rem 0',
              fontSize: '1.25rem',
              fontWeight: '600',
              color: colors.text,
              transition: 'color 0.3s ease'
            }}>
              Weekly Activity
            </h2>
            <ResponsiveContainer width="100%" height={300}>
              <AreaChart data={stats.dailyEngagement}>
                <CartesianGrid strokeDasharray="3 3" stroke={colors.chartGrid} />
                <XAxis dataKey="date" stroke={colors.chartText} style={{ fontSize: '0.875rem' }} />
                <YAxis stroke={colors.chartText} style={{ fontSize: '0.875rem' }} />
                <Tooltip
                  contentStyle={{
                    background: colors.cardBg,
                    border: '1px solid ' + colors.border,
                    borderRadius: '8px',
                    boxShadow: '0 4px 6px rgba(0,0,0,0.1)',
                    color: colors.text
                  }}
                />
                <Legend />
                <Area type="monotone" dataKey="activeUsers" stackId="1" stroke="#88844D" fill="#88844D" name="Active Users" />
                <Area type="monotone" dataKey="listings" stackId="1" stroke="#BEC092" fill="#BEC092" name="Listings" />
                <Area type="monotone" dataKey="claims" stackId="1" stroke="#E4E5C2" fill="#E4E5C2" name="Claims" />
              </AreaChart>
            </ResponsiveContainer>
          </div>

          {/* Waste Materials */}
          <div style={{
            background: colors.cardBg,
            borderRadius: '16px',
            padding: '1.5rem',
            boxShadow: isDark ? '0 4px 12px rgba(0,0,0,0.3)' : '0 4px 12px rgba(0,0,0,0.08)',
            transition: 'all 0.3s ease'
          }}>
            <h2 style={{
              margin: '0 0 1.5rem 0',
              fontSize: '1.25rem',
              fontWeight: '600',
              color: colors.text,
              transition: 'color 0.3s ease'
            }}>
              Waste Material Status
            </h2>
            <ResponsiveContainer width="100%" height={300}>
              <BarChart data={stats.wasteByMaterial}>
                <CartesianGrid strokeDasharray="3 3" stroke={colors.chartGrid} />
                <XAxis dataKey="material" stroke={colors.chartText} style={{ fontSize: '0.75rem' }} angle={-15} textAnchor="end" height={80} />
                <YAxis stroke={colors.chartText} style={{ fontSize: '0.875rem' }} />
                <Tooltip
                  contentStyle={{
                    background: colors.cardBg,
                    border: '1px solid ' + colors.border,
                    borderRadius: '8px',
                    boxShadow: '0 4px 6px rgba(0,0,0,0.1)',
                    color: colors.text
                  }}
                />
                <Legend />
                <Bar dataKey="listed" fill="#88844D" radius={[8, 8, 0, 0]} name="Listed (kg)" />
                <Bar dataKey="claimed" fill="#22c55e" radius={[8, 8, 0, 0]} name="Claimed (kg)" />
              </BarChart>
            </ResponsiveContainer>
          </div>
        </div>

        {/* Quick Actions */}
        <div style={{
          display: 'grid',
          gridTemplateColumns: 'repeat(auto-fit, minmax(250px, 1fr))',
          gap: '1rem'
        }}>
          {[
            { label: 'Manage Users', icon: Users, href: '/users' },
            { label: 'Waste Listings', icon: Recycle, href: '/waste-listing' },
            { label: 'Product Listings', icon: Package, href: '/product-listing' },
            { label: 'Gems Leaderboard', icon: Award, href: '/points-management' }
          ].map((action, index) => (
            <button
              key={index}
              onClick={() => window.location.href = action.href}
              style={{
                padding: '1rem',
                background: colors.cardBg,
                border: '2px solid ' + colors.primary,
                borderRadius: '12px',
                color: colors.primary,
                fontWeight: '600',
                fontSize: '1rem',
                cursor: 'pointer',
                transition: 'all 0.2s',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                gap: '0.5rem'
              }}
              onMouseOver={(e) => {
                e.currentTarget.style.background = colors.primary;
                e.currentTarget.style.color = 'white';
              }}
              onMouseOut={(e) => {
                e.currentTarget.style.background = colors.cardBg;
                e.currentTarget.style.color = colors.primary;
              }}
            >
              <action.icon size={20} />
              {action.label}
            </button>
          ))}
        </div>
      </div>
    </div>
  );
};

export default ModernAdminDashboard;