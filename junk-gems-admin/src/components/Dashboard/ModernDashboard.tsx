import { useEffect, useState } from 'react';
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer, PieChart, Pie, Cell, AreaChart, Area } from 'recharts';
import { TrendingUp, Users, Package, Recycle, Award, Moon, Sun, Eye, FileDown, FileText } from 'lucide-react';

const useTheme = () => {
  const [theme, setTheme] = useState('light');

  const toggleTheme = () => {
    const newTheme = theme === 'light' ? 'dark' : 'light';
    setTheme(newTheme);
  };

  return { theme, toggleTheme };
};

interface Material {
  id: number;
  category: string;
  quantity: string | number;
  claim_status: string;
  created_at: string;
}

interface Product {
  id: number;
  category: string;
  status: string;
  price: string | number;
  views: number;
  inquiries: number;
  created_at: string;
}

interface UserSummary {
  total_users: string;
  daily_active_users: string;
  weekly_active_users: string;
  banned_users: string;
}

interface DailyActiveUser {
  login_date: string;
  active_users: string;
}

interface DashboardStats {
  totalUsers: number;
  dailyActiveUsers: number;
  weeklyActiveUsers: number;
  totalProducts: number;
  availableProducts: number;
  soldProducts: number;
  totalViews: number;
  totalInquiries: number;
  totalMaterials: number;
  availableMaterials: number;
  claimedMaterials: number;
  wasteByMaterial: Array<{ material: string; listed: number; claimed: number }>;
  categoryBreakdown: Array<{ name: string; value: number }>;
  materialCategoryBreakdown: Array<{ name: string; value: number }>;
  dailyEngagement: Array<{ date: string; activeUsers: number; listings: number; materials: number }>;
  productStatusBreakdown: Array<{ name: string; value: number }>;
}

const ModernAdminDashboard = () => {
  const { theme, toggleTheme } = useTheme();
  const isDark = theme === 'dark';

  const [stats, setStats] = useState<DashboardStats>({
    totalUsers: 0,
    dailyActiveUsers: 0,
    weeklyActiveUsers: 0,
    totalProducts: 0,
    availableProducts: 0,
    soldProducts: 0,
    totalViews: 0,
    totalInquiries: 0,
    totalMaterials: 0,
    availableMaterials: 0,
    claimedMaterials: 0,
    wasteByMaterial: [],
    categoryBreakdown: [],
    materialCategoryBreakdown: [],
    dailyEngagement: [],
    productStatusBreakdown: []
  });
  const [loading, setLoading] = useState(true);
  const [generating, setGenerating] = useState<'csv' | 'pdf' | null>(null);

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
    danger: '#ef4444',
    chartGrid: isDark ? '#404040' : '#e5e7eb',
    chartText: isDark ? '#9ca3af' : '#6b7280'
  };

  useEffect(() => {
    fetchDashboardData();
  }, []);

  const fetchDashboardData = async () => {
    try {
      const [materialsRes, productsRes, usersRes, dailyActiveRes] = await Promise.all([
        fetch('https://junk-and-gems-api.onrender.com/api/analytics/materials'),
        fetch('https://junk-and-gems-api.onrender.com/api/analytics/products'),
        fetch('https://junk-and-gems-api.onrender.com/api/analytics/users'),
        fetch('https://junk-and-gems-api.onrender.com/api/analytics/daily-active-users')
      ]);

      const materials: Material[] = await materialsRes.json();
      const products: Product[] = await productsRes.json();
      const usersData = await usersRes.json();
      const dailyActiveData = await dailyActiveRes.json();

      // Process materials data
      const materialStats: { [key: string]: { listed: number; claimed: number } } = {};
      const materialCategoryCount: { [key: string]: number } = {};
      let availableMaterials = 0;
      let claimedMaterials = 0;

      materials.forEach((m) => {
        const cat = m.category || 'Other';
        materialCategoryCount[cat] = (materialCategoryCount[cat] || 0) + 1;
        
        if (!materialStats[cat]) materialStats[cat] = { listed: 0, claimed: 0 };
        const weight = parseFloat(String(m.quantity)) || 1;
        materialStats[cat].listed += weight;
        
        const status = m.claim_status || 'available';
        if (status === 'confirmed') {
          materialStats[cat].claimed += weight;
          claimedMaterials++;
        } else if (status === 'available') {
          availableMaterials++;
        }
      });

      const wasteByMaterial = Object.entries(materialStats).map(([material, data]) => ({
        material,
        listed: Math.round(data.listed * 10) / 10,
        claimed: Math.round(data.claimed * 10) / 10
      }));

      const materialCategoryBreakdown = Object.entries(materialCategoryCount).map(([name, value]) => ({
        name,
        value
      }));

      // Process products data
      const categoryCount: { [key: string]: number } = {};
      const statusCount: { [key: string]: number } = {};
      let totalViews = 0;
      let totalInquiries = 0;
      let availableProducts = 0;
      let soldProducts = 0;

      const productsArray = Array.isArray(products) ? products : [];
      productsArray.forEach((p) => {
        categoryCount[p.category] = (categoryCount[p.category] || 0) + 1;
        const status = p.status || 'available';
        statusCount[status] = (statusCount[status] || 0) + 1;
        totalViews += p.views || 0;
        totalInquiries += p.inquiries || 0;
        
        if (status === 'available') availableProducts++;
        if (status === 'sold') soldProducts++;
      });

      const categoryBreakdown = Object.entries(categoryCount).map(([name, value]) => ({
        name,
        value
      }));

      const productStatusBreakdown = Object.entries(statusCount).map(([name, value]) => ({
        name: name.charAt(0).toUpperCase() + name.slice(1),
        value
      }));

      // Process user data
      const userSummary: UserSummary = usersData.summary || {
        total_users: '0',
        daily_active_users: '0',
        weekly_active_users: '0',
        banned_users: '0'
      };

      // Process daily active users data
      const dailyActive: DailyActiveUser[] = dailyActiveData.data || [];
      
      // Create a map of the past 7 days
      const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
      const today = new Date();
      const dailyEngagement = Array.from({ length: 7 }, (_, i) => {
        const date = new Date(today);
        date.setDate(date.getDate() - (6 - i));
        const dayName = days[date.getDay()];
        const dateStr = date.toISOString().split('T')[0];
        
        const activeData = dailyActive.find(d => d.login_date === dateStr);
        
        const productsOnDay = productsArray.filter(p => {
          const productDate = new Date(p.created_at).toISOString().split('T')[0];
          return productDate === dateStr;
        }).length;

        const materialsOnDay = materials.filter(m => {
          const materialDate = new Date(m.created_at).toISOString().split('T')[0];
          return materialDate === dateStr;
        }).length;

        return {
          date: dayName,
          activeUsers: activeData ? parseInt(activeData.active_users) : 0,
          listings: productsOnDay,
          materials: materialsOnDay
        };
      });

      setStats({
        totalUsers: parseInt(userSummary.total_users) || 0,
        dailyActiveUsers: parseInt(userSummary.daily_active_users) || 0,
        weeklyActiveUsers: parseInt(userSummary.weekly_active_users) || 0,
        totalProducts: productsArray.length,
        availableProducts,
        soldProducts,
        totalViews,
        totalInquiries,
        totalMaterials: materials.length,
        availableMaterials,
        claimedMaterials,
        wasteByMaterial,
        categoryBreakdown,
        materialCategoryBreakdown,
        dailyEngagement,
        productStatusBreakdown
      });
    } catch (error) {
      console.error('Error fetching data:', error);
    } finally {
      setLoading(false);
    }
  };

  const generateCSVReport = () => {
    setGenerating('csv');
    
    const activeRate = stats.totalUsers > 0 ? Math.round((stats.dailyActiveUsers / stats.totalUsers) * 100) : 0;
    const timestamp = new Date().toISOString().split('T')[0];
    
    let csvContent = "Junk & Gems Platform Analytics Report\n";
    csvContent += `Generated on: ${new Date().toLocaleString()}\n\n`;
    
    // Summary Statistics
    csvContent += "=== SUMMARY STATISTICS ===\n";
    csvContent += "Metric,Value,Additional Info\n";
    csvContent += `Total Users,${stats.totalUsers},${stats.dailyActiveUsers} active today (${activeRate}%)\n`;
    csvContent += `Total Materials,${stats.totalMaterials},"${stats.availableMaterials} available, ${stats.claimedMaterials} claimed"\n`;
    csvContent += `Total Products,${stats.totalProducts},"${stats.availableProducts} available, ${stats.soldProducts} sold"\n`;
    csvContent += `Product Views,${stats.totalViews},${stats.totalInquiries} total inquiries\n`;
    csvContent += "\n";
    
    // Weekly Activity
    csvContent += "=== WEEKLY ACTIVITY (PAST 7 DAYS) ===\n";
    csvContent += "Day,Active Users,New Products,New Materials\n";
    stats.dailyEngagement.forEach(day => {
      csvContent += `${day.date},${day.activeUsers},${day.listings},${day.materials}\n`;
    });
    csvContent += "\n";
    
    // Product Status
    csvContent += "=== PRODUCT STATUS BREAKDOWN ===\n";
    csvContent += "Status,Count\n";
    stats.productStatusBreakdown.forEach(item => {
      csvContent += `${item.name},${item.value}\n`;
    });
    csvContent += "\n";
    
    // Material Categories
    csvContent += "=== MATERIAL CATEGORIES ===\n";
    csvContent += "Category,Count\n";
    stats.materialCategoryBreakdown.forEach(item => {
      csvContent += `${item.name},${item.value}\n`;
    });
    csvContent += "\n";
    
    // Waste Material Weight
    csvContent += "=== WASTE MATERIAL WEIGHT STATUS ===\n";
    csvContent += "Material,Total Listed (kg),Claimed (kg)\n";
    stats.wasteByMaterial.forEach(item => {
      csvContent += `${item.material},${item.listed},${item.claimed}\n`;
    });
    csvContent += "\n";
    
    // Product Categories
    csvContent += "=== PRODUCT CATEGORIES ===\n";
    csvContent += "Category,Count\n";
    stats.categoryBreakdown.forEach(item => {
      csvContent += `${item.name},${item.value}\n`;
    });
    
    const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
    const link = document.createElement('a');
    link.href = URL.createObjectURL(blob);
    link.download = `junk-gems-analytics-${timestamp}.csv`;
    link.click();
    
    setTimeout(() => setGenerating(null), 1000);
  };

  const generatePDFReport = () => {
    setGenerating('pdf');
    
    const activeRate = stats.totalUsers > 0 ? Math.round((stats.dailyActiveUsers / stats.totalUsers) * 100) : 0;
    
    const htmlContent = `
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Junk & Gems Analytics Report</title>
  <style>
    body {
      font-family: Arial, sans-serif;
      padding: 40px;
      max-width: 1200px;
      margin: 0 auto;
      color: #333;
    }
    h1 {
      color: #88844D;
      border-bottom: 3px solid #88844D;
      padding-bottom: 10px;
      margin-bottom: 10px;
    }
    h2 {
      color: #88844D;
      margin-top: 30px;
      border-bottom: 1px solid #ddd;
      padding-bottom: 5px;
    }
    .header {
      background: linear-gradient(135deg, #F7F2E4 0%, #E4E5C2 100%);
      padding: 20px;
      border-radius: 8px;
      margin-bottom: 30px;
    }
    .stats-grid {
      display: grid;
      grid-template-columns: repeat(2, 1fr);
      gap: 20px;
      margin-bottom: 30px;
    }
    .stat-card {
      background: #f9f9f9;
      padding: 15px;
      border-radius: 8px;
      border-left: 4px solid #88844D;
    }
    .stat-label {
      font-size: 12px;
      color: #666;
      margin-bottom: 5px;
    }
    .stat-value {
      font-size: 32px;
      font-weight: bold;
      color: #88844D;
      margin-bottom: 5px;
    }
    .stat-info {
      font-size: 11px;
      color: #22c55e;
    }
    table {
      width: 100%;
      border-collapse: collapse;
      margin: 20px 0;
      background: white;
    }
    th, td {
      padding: 12px;
      text-align: left;
      border-bottom: 1px solid #ddd;
    }
    th {
      background-color: #88844D;
      color: white;
      font-weight: 600;
    }
    tr:hover {
      background-color: #f5f5f5;
    }
    .footer {
      margin-top: 40px;
      padding-top: 20px;
      border-top: 1px solid #ddd;
      text-align: center;
      color: #666;
      font-size: 12px;
    }
    @media print {
      body { padding: 20px; }
      .stat-card { page-break-inside: avoid; }
    }
  </style>
</head>
<body>
  <div class="header">
    <h1>Junk & Gems Platform Analytics Report</h1>
    <p style="margin: 5px 0; color: #666;">Generated on: ${new Date().toLocaleString()}</p>
    <p style="margin: 5px 0; color: #666;">Monitoring waste diversion, user engagement, and circular economy impact</p>
  </div>

  <div class="stats-grid">
    <div class="stat-card">
      <div class="stat-label">Total Users</div>
      <div class="stat-value">${stats.totalUsers}</div>
      <div class="stat-info">${stats.dailyActiveUsers} active today (${activeRate}%)</div>
    </div>
    <div class="stat-card">
      <div class="stat-label">Total Materials</div>
      <div class="stat-value">${stats.totalMaterials}</div>
      <div class="stat-info">${stats.availableMaterials} available, ${stats.claimedMaterials} claimed</div>
    </div>
    <div class="stat-card">
      <div class="stat-label">Total Products</div>
      <div class="stat-value">${stats.totalProducts}</div>
      <div class="stat-info">${stats.availableProducts} available, ${stats.soldProducts} sold</div>
    </div>
    <div class="stat-card">
      <div class="stat-label">Product Views</div>
      <div class="stat-value">${stats.totalViews}</div>
      <div class="stat-info">${stats.totalInquiries} total inquiries</div>
    </div>
  </div>

  <h2>Weekly Activity (Past 7 Days)</h2>
  <table>
    <thead>
      <tr>
        <th>Day</th>
        <th>Active Users</th>
        <th>New Products</th>
        <th>New Materials</th>
      </tr>
    </thead>
    <tbody>
      ${stats.dailyEngagement.map(day => `
        <tr>
          <td>${day.date}</td>
          <td>${day.activeUsers}</td>
          <td>${day.listings}</td>
          <td>${day.materials}</td>
        </tr>
      `).join('')}
    </tbody>
  </table>

  <h2>Product Status Breakdown</h2>
  <table>
    <thead>
      <tr>
        <th>Status</th>
        <th>Count</th>
      </tr>
    </thead>
    <tbody>
      ${stats.productStatusBreakdown.map(item => `
        <tr>
          <td>${item.name}</td>
          <td>${item.value}</td>
        </tr>
      `).join('')}
    </tbody>
  </table>

  <h2>Material Categories</h2>
  <table>
    <thead>
      <tr>
        <th>Category</th>
        <th>Count</th>
      </tr>
    </thead>
    <tbody>
      ${stats.materialCategoryBreakdown.map(item => `
        <tr>
          <td>${item.name}</td>
          <td>${item.value}</td>
        </tr>
      `).join('')}
    </tbody>
  </table>

  <h2>Waste Material Weight Status</h2>
  <table>
    <thead>
      <tr>
        <th>Material</th>
        <th>Total Listed (kg)</th>
        <th>Claimed (kg)</th>
      </tr>
    </thead>
    <tbody>
      ${stats.wasteByMaterial.map(item => `
        <tr>
          <td>${item.material}</td>
          <td>${item.listed}</td>
          <td>${item.claimed}</td>
        </tr>
      `).join('')}
    </tbody>
  </table>

  <h2>Product Categories</h2>
  <table>
    <thead>
      <tr>
        <th>Category</th>
        <th>Count</th>
      </tr>
    </thead>
    <tbody>
      ${stats.categoryBreakdown.map(item => `
        <tr>
          <td>${item.name}</td>
          <td>${item.value}</td>
        </tr>
      `).join('')}
    </tbody>
  </table>

  <div class="footer">
    <p>Junk & Gems Platform - Circular Economy Analytics</p>
    <p>This report was automatically generated from live platform data</p>
  </div>
</body>
</html>
    `;
    
    const printWindow = window.open('', '_blank');
    if (printWindow) {
      printWindow.document.write(htmlContent);
      printWindow.document.close();
      printWindow.onload = () => {
        printWindow.print();
      };
    }
    
    setTimeout(() => setGenerating(null), 1000);
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

  const activeRate = stats.totalUsers > 0 
    ? Math.round((stats.dailyActiveUsers / stats.totalUsers) * 100) 
    : 0;

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
          <div style={{ display: 'flex', gap: '1rem', alignItems: 'center', flexWrap: 'wrap' }}>
            <button
              onClick={generateCSVReport}
              disabled={generating !== null}
              style={{
                padding: '0.75rem 1.25rem',
                background: generating === 'csv' ? '#666' : colors.success,
                color: 'white',
                border: 'none',
                borderRadius: '8px',
                cursor: generating !== null ? 'not-allowed' : 'pointer',
                fontWeight: '600',
                fontSize: '0.9rem',
                display: 'flex',
                alignItems: 'center',
                gap: '0.5rem',
                transition: 'all 0.3s ease',
                opacity: generating !== null ? 0.7 : 1
              }}
              title="Download analytics report as CSV"
            >
              <FileDown size={18} />
              {generating === 'csv' ? 'Generating...' : 'CSV Report'}
            </button>
            <button
              onClick={generatePDFReport}
              disabled={generating !== null}
              style={{
                padding: '0.75rem 1.25rem',
                background: generating === 'pdf' ? '#666' : colors.danger,
                color: 'white',
                border: 'none',
                borderRadius: '8px',
                cursor: generating !== null ? 'not-allowed' : 'pointer',
                fontWeight: '600',
                fontSize: '0.9rem',
                display: 'flex',
                alignItems: 'center',
                gap: '0.5rem',
                transition: 'all 0.3s ease',
                opacity: generating !== null ? 0.7 : 1
              }}
              title="Print/Save analytics report as PDF"
            >
              <FileText size={18} />
              {generating === 'pdf' ? 'Generating...' : 'PDF Report'}
            </button>
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
            { 
              label: 'Total Users', 
              value: stats.totalUsers, 
              icon: Users, 
              color: colors.primary, 
              trend: `${stats.dailyActiveUsers} active today (${activeRate}%)` 
            },
            { 
              label: 'Total Materials', 
              value: stats.totalMaterials, 
              icon: Recycle, 
              color: colors.warning, 
              trend: `${stats.availableMaterials} available, ${stats.claimedMaterials} claimed` 
            },
            { 
              label: 'Total Products', 
              value: stats.totalProducts, 
              icon: Package, 
              color: colors.success, 
              trend: `${stats.availableProducts} available, ${stats.soldProducts} sold` 
            },
            { 
              label: 'Product Views', 
              value: stats.totalViews, 
              icon: Eye, 
              color: colors.info, 
              trend: `${stats.totalInquiries} total inquiries` 
            }
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
              Weekly Activity (Past 7 Days)
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
                <Area type="monotone" dataKey="materials" stackId="1" stroke="#f59e0b" fill="#f59e0b" name="New Materials" />
                <Area type="monotone" dataKey="listings" stackId="1" stroke="#BEC092" fill="#BEC092" name="New Products" />
              </AreaChart>
            </ResponsiveContainer>
          </div>

          {/* Product Status Breakdown */}
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
              Product Status Overview
            </h2>
            <ResponsiveContainer width="100%" height={300}>
              <PieChart>
                <Pie
                  data={stats.productStatusBreakdown}
                  cx="50%"
                  cy="50%"
                  labelLine={false}
                  label={(entry) => `${entry.name}: ${entry.value}`}
                  outerRadius={100}
                  fill="#8884d8"
                  dataKey="value"
                >
                  {stats.productStatusBreakdown.map((_, index) => (
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
          {/* Material Categories Distribution */}
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
              Material Categories
            </h2>
            <ResponsiveContainer width="100%" height={300}>
              <PieChart>
                <Pie
                  data={stats.materialCategoryBreakdown}
                  cx="50%"
                  cy="50%"
                  labelLine={false}
                  label={(entry) => entry.name}
                  outerRadius={100}
                  fill="#8884d8"
                  dataKey="value"
                >
                  {stats.materialCategoryBreakdown.map((_, index) => (
                    <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                  ))}
                </Pie>
                <Tooltip contentStyle={{ background: colors.cardBg, border: '1px solid ' + colors.border, color: colors.text }} />
              </PieChart>
            </ResponsiveContainer>
          </div>

          {/* Waste Materials Weight */}
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
              Waste Material Weight Status
            </h2>
            <ResponsiveContainer width="100%" height={300}>
              <BarChart data={stats.wasteByMaterial}>
                <CartesianGrid strokeDasharray="3 3" stroke={colors.chartGrid} />
                <XAxis dataKey="material" stroke={colors.chartText} style={{ fontSize: '0.75rem' }} angle={-15} textAnchor="end" height={80} />
                <YAxis stroke={colors.chartText} style={{ fontSize: '0.875rem' }} label={{ value: 'Weight (kg)', angle: -90, position: 'insideLeft', style: { fill: colors.chartText } }} />
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
                <Bar dataKey="listed" fill="#f59e0b" radius={[8, 8, 0, 0]} name="Total Listed (kg)" />
                <Bar dataKey="claimed" fill="#22c55e" radius={[8, 8, 0, 0]} name="Claimed (kg)" />
              </BarChart>
            </ResponsiveContainer>
          </div>
        </div>

        {/* Charts Row 3 - Product Categories */}
        <div style={{
          display: 'grid',
          gridTemplateColumns: 'repeat(auto-fit, minmax(min(100%, 500px), 1fr))',
          gap: '1.5rem',
          marginBottom: '2rem'
        }}>
          {/* Product Category Distribution */}
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
                  {stats.categoryBreakdown.map((_, index) => (
                    <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                  ))}
                </Pie>
                <Tooltip contentStyle={{ background: colors.cardBg, border: '1px solid ' + colors.border, color: colors.text }} />
              </PieChart>
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