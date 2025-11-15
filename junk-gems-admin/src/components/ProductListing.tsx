import React, { useEffect, useState } from 'react';
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer, PieChart, Pie, Cell } from 'recharts';
import { ShoppingCart, TrendingUp, Package, AlertCircle, DollarSign, Eye } from 'lucide-react';
import type { PieLabelRenderProps } from 'recharts';

interface Product {
  id: string;
  category: string;
  title: string;
  price: number;
  status: 'available' | 'pending' | 'sold';
  created_at: string;
  views?: number;
  inquiries?: number;
}

interface ProductStats {
  category: string;
  listed: number;
  sold: number;
  available: number;
  revenue: number;
  [key: string]: string | number;
}

const ProductListing: React.FC = () => {
  const [productStats, setProductStats] = useState<ProductStats[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  
  const [summary, setSummary] = useState({
    totalListed: 0,
    totalSold: 0,
    totalAvailable: 0,
    totalRevenue: 0,
    avgPrice: 0,
    totalViews: 0,
    totalInquiries: 0
  });

  useEffect(() => {
    fetchProducts();
  }, []);

  const fetchProducts = async () => {
    try {
      setLoading(true);
      const response = await fetch('https://junk-and-gems-api.onrender.com/api/analytics/products');
      
      if (!response.ok) {
        throw new Error('Failed to fetch products');
      }
      
      const data = await response.json();
      console.log('Products API Response:', data);
      
      const productsArray = Array.isArray(data) ? data : (data.products || data.data || []);
      
      console.log('Products Count:', productsArray.length);
      
      if (productsArray.length === 0) {
        setError('No products data available from API yet.');
        processProductData([]);
      } else {
        console.log('Processing products...');
        processProductData(productsArray);
        setError('');
      }
    } catch (err) {
      console.error('Error fetching products:', err);
      setError(`Failed to connect to API: ${err instanceof Error ? err.message : 'Unknown error'}`);
      processProductData([]);
    } finally {
      setLoading(false);
    }
  };

  const processProductData = (productsData: Product[]) => {
    console.log('=== PROCESSING PRODUCT DATA ===');
    console.log('Input products:', productsData);
    
    const categoryMap: { [key: string]: { listed: number; sold: number; available: number; revenue: number } } = {
      'Furniture': { listed: 0, sold: 0, available: 0, revenue: 0 },
      'Decor': { listed: 0, sold: 0, available: 0, revenue: 0 },
      'Art': { listed: 0, sold: 0, available: 0, revenue: 0 },
      'Accessories': { listed: 0, sold: 0, available: 0, revenue: 0 },
      'Lighting': { listed: 0, sold: 0, available: 0, revenue: 0 },
      'Storage': { listed: 0, sold: 0, available: 0, revenue: 0 },
      'Other': { listed: 0, sold: 0, available: 0, revenue: 0 }
    };

    let totalListed = 0;
    let totalSold = 0;
    let totalAvailable = 0;
    let totalRevenue = 0;
    let totalViews = 0;
    let totalInquiries = 0;
    let priceSum = 0;

    productsData.forEach((product) => {
      const category = product.category || 'Other';
      const price = parseFloat(String(product.price)) || 0;
      
      if (categoryMap[category]) {
        categoryMap[category].listed += 1;
        totalListed += 1;
        priceSum += price;
        
        if (product.status === 'sold') {
          categoryMap[category].sold += 1;
          categoryMap[category].revenue += price;
          totalSold += 1;
          totalRevenue += price;
        } else if (product.status === 'available' || product.status === 'pending') {
          categoryMap[category].available += 1;
          totalAvailable += 1;
        }
      }
      
      totalViews += product.views || 0;
      totalInquiries += product.inquiries || 0;
    });

    console.log('Category Map:', categoryMap);

    const stats: ProductStats[] = Object.entries(categoryMap)
      .filter(([, data]) => data.listed > 0)
      .map(([category, data]) => ({
        category,
        listed: data.listed,
        sold: data.sold,
        available: data.available,
        revenue: Math.round(data.revenue * 100) / 100
      }));

    console.log('Final stats:', stats);

    setProductStats(stats);
    setSummary({
      totalListed,
      totalSold,
      totalAvailable,
      totalRevenue: Math.round(totalRevenue * 100) / 100,
      avgPrice: totalListed > 0 ? Math.round((priceSum / totalListed) * 100) / 100 : 0,
      totalViews,
      totalInquiries
    });
  };

  const COLORS = ['#88844D', '#BEC092', '#E4E5C2', '#6d6a3d', '#a5a26b', '#d4d2a8', '#8a8662'];

  if (loading) {
    return (
      <div style={{ padding: '2rem', textAlign: 'center' }}>
        <div style={{ fontSize: '1.2rem', color: '#88844D' }}>Loading upcycled products data...</div>
      </div>
    );
  }

  return (
    <div style={{ padding: '2rem', maxWidth: '1400px', margin: '0 auto', background: '#f9f9f9', minHeight: '100vh' }}>
      {/* Header */}
      <div style={{ marginBottom: '2rem' }}>
        <h1 style={{ fontSize: '2rem', color: '#88844D', marginBottom: '0.5rem' }}>
          🛒 Upcycled Products Analytics
        </h1>
        <p style={{ color: '#666', fontSize: '1rem' }}>
          Monitor product listings, sales, revenue, and category performance
        </p>
      </div>

      {error && (
        <div style={{ 
          padding: '1rem', 
          background: '#fee2e2', 
          border: '1px solid #ef4444', 
          borderRadius: '8px', 
          marginBottom: '1.5rem',
          display: 'flex',
          alignItems: 'center',
          gap: '0.5rem'
        }}>
          <AlertCircle size={20} color="#991b1b" />
          <div>
            <strong>Error:</strong> {error}
          </div>
        </div>
      )}

      {/* Summary Cards */}
      <div style={{ 
        display: 'grid', 
        gridTemplateColumns: 'repeat(auto-fit, minmax(220px, 1fr))', 
        gap: '1.5rem', 
        marginBottom: '2rem' 
      }}>
        <div style={{ 
          background: '#F7F2E4', 
          borderRadius: '12px', 
          padding: '1.5rem', 
          boxShadow: '0 4px 6px rgba(0, 0, 0, 0.1)',
          borderLeft: '4px solid #88844D'
        }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
            <div>
              <h3 style={{ fontSize: '0.9rem', color: '#666', margin: '0 0 0.5rem 0' }}>Total Listed</h3>
              <div style={{ fontSize: '2rem', fontWeight: 'bold', color: '#88844D' }}>
                {summary.totalListed}
              </div>
            </div>
            <Package size={32} color="#88844D" />
          </div>
        </div>

        <div style={{ 
          background: '#F7F2E4', 
          borderRadius: '12px', 
          padding: '1.5rem', 
          boxShadow: '0 4px 6px rgba(0, 0, 0, 0.1)',
          borderLeft: '4px solid #22c55e'
        }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
            <div>
              <h3 style={{ fontSize: '0.9rem', color: '#666', margin: '0 0 0.5rem 0' }}>Total Sold</h3>
              <div style={{ fontSize: '2rem', fontWeight: 'bold', color: '#22c55e' }}>
                {summary.totalSold}
              </div>
            </div>
            <ShoppingCart size={32} color="#22c55e" />
          </div>
        </div>

        <div style={{ 
          background: '#F7F2E4', 
          borderRadius: '12px', 
          padding: '1.5rem', 
          boxShadow: '0 4px 6px rgba(0, 0, 0, 0.1)',
          borderLeft: '4px solid #3b82f6'
        }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
            <div>
              <h3 style={{ fontSize: '0.9rem', color: '#666', margin: '0 0 0.5rem 0' }}>Total Revenue</h3>
              <div style={{ fontSize: '2rem', fontWeight: 'bold', color: '#3b82f6' }}>
                M{summary.totalRevenue}
              </div>
            </div>
            <DollarSign size={32} color="#3b82f6" />
          </div>
        </div>

        <div style={{ 
          background: '#F7F2E4', 
          borderRadius: '12px', 
          padding: '1.5rem', 
          boxShadow: '0 4px 6px rgba(0, 0, 0, 0.1)',
          borderLeft: '4px solid #BEC092'
        }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
            <div>
              <h3 style={{ fontSize: '0.9rem', color: '#666', margin: '0 0 0.5rem 0' }}>Avg Price</h3>
              <div style={{ fontSize: '2rem', fontWeight: 'bold', color: '#88844D' }}>
                M{summary.avgPrice}
              </div>
            </div>
            <TrendingUp size={32} color="#88844D" />
          </div>
        </div>
      </div>

      {/* Charts Section */}
      <div style={{ 
        display: 'grid', 
        gridTemplateColumns: 'repeat(auto-fit, minmax(500px, 1fr))', 
        gap: '1.5rem',
        marginBottom: '2rem' 
      }}>
        {/* Bar Chart */}
        <div style={{ 
          background: '#F7F2E4', 
          borderRadius: '12px', 
          padding: '2rem', 
          boxShadow: '0 4px 6px rgba(0, 0, 0, 0.1)' 
        }}>
          <h2 style={{ color: '#88844D', marginBottom: '1rem' }}>
            📊 Products by Category
          </h2>
          
          <ResponsiveContainer width="100%" height={350}>
            <BarChart data={productStats}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis 
                dataKey="category" 
                angle={-15} 
                textAnchor="end" 
                height={80}
              />
              <YAxis />
              <Tooltip />
              <Legend />
              <Bar dataKey="listed" fill="#88844D" name="Listed" radius={[8, 8, 0, 0]} />
              <Bar dataKey="sold" fill="#22c55e" name="Sold" radius={[8, 8, 0, 0]} />
            </BarChart>
          </ResponsiveContainer>
        </div>

        {/* Pie Chart */}
        <div style={{ 
          background: '#F7F2E4', 
          borderRadius: '12px', 
          padding: '2rem', 
          boxShadow: '0 4px 6px rgba(0, 0, 0, 0.1)' 
        }}>
          <h2 style={{ color: '#88844D', marginBottom: '1rem' }}>
            💰 Revenue Distribution
          </h2>
          
          {productStats.length > 0 ? (
            <ResponsiveContainer width="100%" height={350}>
              <PieChart>
                <Pie
                  data={productStats.filter(s => s.revenue > 0)}
                  cx="50%"
                  cy="50%"
                  labelLine={false}
                  label={(props: PieLabelRenderProps) => {
                    const entry = productStats.find((s) => s.category === props.name);
                    return entry ? `${entry.category}: M${entry.revenue}` : '';
                  }}
                  outerRadius={100}
                  fill="#8884d8"
                  dataKey="revenue"
                >
                  {productStats.map((entry, index) => (
                    <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                  ))}
                </Pie>
                <Tooltip />
              </PieChart>
            </ResponsiveContainer>
          ) : (
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', height: '350px', color: '#888' }}>
              No revenue data available
            </div>
          )}
        </div>
      </div>

      {/* Product Breakdown Table */}
      <div style={{ 
        background: '#F7F2E4', 
        borderRadius: '12px', 
        padding: '2rem', 
        boxShadow: '0 4px 6px rgba(0, 0, 0, 0.1)',
        marginBottom: '2rem'
      }}>
        <h2 style={{ color: '#88844D', marginBottom: '1.5rem' }}>
          📋 Detailed Category Breakdown
        </h2>
        
        <div style={{ overflowX: 'auto' }}>
          <table style={{ 
            width: '100%', 
            borderCollapse: 'collapse',
            background: 'white',
            borderRadius: '8px',
            overflow: 'hidden'
          }}>
            <thead>
              <tr style={{ background: '#88844D', color: 'white' }}>
                <th style={{ padding: '1rem', textAlign: 'left' }}>Category</th>
                <th style={{ padding: '1rem', textAlign: 'center' }}>Listed</th>
                <th style={{ padding: '1rem', textAlign: 'center' }}>Sold</th>
                <th style={{ padding: '1rem', textAlign: 'center' }}>Available</th>
                <th style={{ padding: '1rem', textAlign: 'center' }}>Revenue</th>
                <th style={{ padding: '1rem', textAlign: 'center' }}>Sell Rate</th>
              </tr>
            </thead>
            <tbody>
              {productStats.map((stat, index) => {
                const sellRate = stat.listed > 0 ? Math.round((stat.sold / stat.listed) * 100) : 0;
                return (
                  <tr 
                    key={stat.category}
                    style={{ 
                      borderBottom: '1px solid #e5e7eb',
                      background: index % 2 === 0 ? '#fafafa' : 'white'
                    }}
                  >
                    <td style={{ padding: '1rem', fontWeight: '600', color: '#88844D' }}>
                      <ShoppingCart size={16} style={{ display: 'inline', marginRight: '8px', verticalAlign: 'middle' }} />
                      {stat.category}
                    </td>
                    <td style={{ padding: '1rem', textAlign: 'center' }}>{stat.listed}</td>
                    <td style={{ padding: '1rem', textAlign: 'center', color: '#22c55e', fontWeight: '600' }}>
                      {stat.sold}
                    </td>
                    <td style={{ padding: '1rem', textAlign: 'center', color: '#3b82f6' }}>
                      {stat.available}
                    </td>
                    <td style={{ padding: '1rem', textAlign: 'center', fontWeight: '600' }}>
                      M{stat.revenue}
                    </td>
                    <td style={{ padding: '1rem', textAlign: 'center' }}>
                      <span style={{
                        padding: '0.25rem 0.75rem',
                        borderRadius: '12px',
                        background: sellRate >= 70 ? '#d1fae5' : sellRate >= 40 ? '#fef3c7' : '#fee2e2',
                        color: sellRate >= 70 ? '#065f46' : sellRate >= 40 ? '#92400e' : '#991b1b',
                        fontWeight: '600',
                        fontSize: '0.875rem'
                      }}>
                        {sellRate}%
                      </span>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
      </div>

      {/* Engagement Stats */}
      <div style={{ 
        background: '#F7F2E4', 
        borderRadius: '12px', 
        padding: '2rem', 
        boxShadow: '0 4px 6px rgba(0, 0, 0, 0.1)',
        marginBottom: '2rem'
      }}>
        <h2 style={{ color: '#88844D', marginBottom: '1.5rem' }}>
          👁️ User Engagement Metrics
        </h2>
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))', gap: '1.5rem' }}>
          <div style={{ padding: '1.5rem', background: 'white', borderRadius: '8px', textAlign: 'center' }}>
            <Eye size={32} color="#88844D" style={{ marginBottom: '0.5rem' }} />
            <div style={{ fontSize: '2rem', fontWeight: 'bold', color: '#88844D' }}>{summary.totalViews}</div>
            <div style={{ fontSize: '0.875rem', color: '#666' }}>Total Product Views</div>
          </div>
          <div style={{ padding: '1.5rem', background: 'white', borderRadius: '8px', textAlign: 'center' }}>
            <ShoppingCart size={32} color="#3b82f6" style={{ marginBottom: '0.5rem' }} />
            <div style={{ fontSize: '2rem', fontWeight: 'bold', color: '#3b82f6' }}>{summary.totalInquiries}</div>
            <div style={{ fontSize: '0.875rem', color: '#666' }}>Purchase Inquiries</div>
          </div>
          <div style={{ padding: '1.5rem', background: 'white', borderRadius: '8px', textAlign: 'center' }}>
            <TrendingUp size={32} color="#22c55e" style={{ marginBottom: '0.5rem' }} />
            <div style={{ fontSize: '2rem', fontWeight: 'bold', color: '#22c55e' }}>
              {summary.totalListed > 0 ? Math.round((summary.totalSold / summary.totalListed) * 100) : 0}%
            </div>
            <div style={{ fontSize: '0.875rem', color: '#666' }}>Overall Sell Rate</div>
          </div>
        </div>
      </div>

      {/* Action Buttons */}
      <div style={{ 
        display: 'flex', 
        gap: '1rem', 
        flexWrap: 'wrap',
        justifyContent: 'center'
      }}>
        <button 
          onClick={fetchProducts}
          style={{ 
            padding: '0.75rem 1.5rem', 
            background: '#88844D', 
            color: 'white', 
            border: 'none', 
            borderRadius: '8px', 
            cursor: 'pointer',
            fontWeight: '600',
            fontSize: '1rem'
          }}
        >
          🔄 Refresh Data
        </button>
        
        <button 
          onClick={() => alert('Export functionality would generate CSV/PDF report')}
          style={{ 
            padding: '0.75rem 1.5rem', 
            background: '#BEC092', 
            color: 'white', 
            border: 'none', 
            borderRadius: '8px', 
            cursor: 'pointer',
            fontWeight: '600',
            fontSize: '1rem'
          }}
        >
          📥 Export Report
        </button>
      </div>
    </div>
  );
};

export default ProductListing;