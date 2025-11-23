import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom'; 
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from 'recharts';
import { Recycle, TrendingUp, Package, AlertCircle, CheckCircle, Clock, Moon, Sun, ArrowLeft } from 'lucide-react';

interface Material {
  id: string;
  category: string;
  description: string;
  quantity: string | number;
  location: string;
  claim_status: 'available' | 'pending' | 'confirmed';
  uploader_id: string;
  created_at: string;
  title: string;
}

interface WasteStats {
  material: string;
  listed: number;
  claimed: number;
  claimRate: number;
  available: number;
}

const WasteListing: React.FC = () => {
  const navigate = useNavigate();
  const [theme, setTheme] = useState(() => localStorage.getItem('theme') || 'light');
  const isDark = theme === 'dark';

  const [wasteStats, setWasteStats] = useState<WasteStats[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  
  const [summary, setSummary] = useState({
    totalListed: 0,
    totalClaimed: 0,
    totalAvailable: 0,
    overallClaimRate: 0,
    totalWeight: 0
  });

  const colors = {
    background: isDark ? '#1a1a1a' : '#ECE8D6',
    cardBg: isDark ? '#2d2d2d' : '#F7F2E4',
    containerBg: isDark ? '#262626' : '#ffffff',
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

  const toggleTheme = () => {
    const newTheme = theme === 'light' ? 'dark' : 'light';
    setTheme(newTheme);
    localStorage.setItem('theme', newTheme);
  };

  useEffect(() => {
    fetchMaterials();
  }, []);

  const fetchMaterials = async () => {
    try {
      setLoading(true);
      const response = await fetch('https://junk-and-gems-api.onrender.com/api/analytics/materials');
      
      if (!response.ok) {
        throw new Error('Failed to fetch materials');
      }
      
      const data = await response.json();
      const materialsArray = Array.isArray(data) ? data : (data.materials || data.data || []);
      
      if (materialsArray.length === 0) {
        setError('No materials data available from API yet.');
        processWasteData([]);
      } else {
        processWasteData(materialsArray);
        setError('');
      }
    } catch (err) {
      console.error('Error fetching materials:', err);
      setError(`Failed to connect to API: ${err instanceof Error ? err.message : 'Unknown error'}`);
      processWasteData([]);
    } finally {
      setLoading(false);
    }
  };

  const processWasteData = (materialsData: Material[]) => {
    const categoryMap: { [key: string]: { listed: number; claimed: number; available: number } } = {
      'Plastic': { listed: 0, claimed: 0, available: 0 },
      'Fabric': { listed: 0, claimed: 0, available: 0 },
      'Glass': { listed: 0, claimed: 0, available: 0 },
      'Metal': { listed: 0, claimed: 0, available: 0 },
      'Wood': { listed: 0, claimed: 0, available: 0 },
      'Electronics': { listed: 0, claimed: 0, available: 0 },
      'Other': { listed: 0, claimed: 0, available: 0 }
    };

    let totalListed = 0;
    let totalClaimed = 0;
    let totalAvailable = 0;
    let totalWeight = 0;

    materialsData.forEach((material) => {
      const category = material.category;
      
      let itemCount = 1;
      if (typeof material.quantity === 'number') {
        itemCount = material.quantity;
      } else if (typeof material.quantity === 'string') {
        const parsed = parseFloat(material.quantity);
        if (!isNaN(parsed)) {
          itemCount = parsed;
        }
      }
      
      const estimatedWeight = itemCount * 0.5;
      totalWeight += estimatedWeight;
      
      if (categoryMap[category]) {
        categoryMap[category].listed += estimatedWeight;
        totalListed += estimatedWeight;
        
        if (material.claim_status === 'confirmed') {
          categoryMap[category].claimed += estimatedWeight;
          totalClaimed += estimatedWeight;
        } else if (material.claim_status === 'available' || material.claim_status === 'pending') {
          categoryMap[category].available += estimatedWeight;
          totalAvailable += estimatedWeight;
        }
      }
    });

    const stats: WasteStats[] = Object.entries(categoryMap).map(([material, data]) => ({
      material,
      listed: Math.round(data.listed * 10) / 10,
      claimed: Math.round(data.claimed * 10) / 10,
      available: Math.round(data.available * 10) / 10,
      claimRate: data.listed > 0 ? Math.round((data.claimed / data.listed) * 100) : 0
    }));

    setWasteStats(stats);
    setSummary({
      totalListed: Math.round(totalListed * 10) / 10,
      totalClaimed: Math.round(totalClaimed * 10) / 10,
      totalAvailable: Math.round(totalAvailable * 10) / 10,
      overallClaimRate: totalListed > 0 ? Math.round((totalClaimed / totalListed) * 100) : 0,
      totalWeight: Math.round(totalWeight * 10) / 10
    });
  };

  if (loading) {
    return (
      <div style={{ 
        display: 'flex', 
        justifyContent: 'center', 
        alignItems: 'center', 
        height: '100vh',
        background: colors.background,
        flexDirection: 'column',
        gap: '1rem'
      }}>
        <div style={{ 
          border: '4px solid ' + (isDark ? '#404040' : '#f3f3f3'),
          borderTop: '4px solid #88844D',
          borderRadius: '50%',
          width: '50px',
          height: '50px',
          animation: 'spin 1s linear infinite'
        }} />
        <p style={{ color: colors.text }}>Loading waste materials data...</p>
        <style>{`@keyframes spin { 0% { transform: rotate(0deg); } 100% { transform: rotate(360deg); }}`}</style>
      </div>
    );
  }

  return (
    <div style={{ 
      minHeight: '100vh',
      background: colors.background,
      padding: 'clamp(1rem, 3vw, 2rem)',
      transition: 'background 0.3s ease'
    }}>
      <div style={{ 
        maxWidth: '1400px', 
        margin: '0 auto',
        width: '100%'
      }}>
        {/* Header with Back Button and Theme Toggle */}
        <div style={{ 
          display: 'flex', 
          justifyContent: 'space-between', 
          alignItems: 'center',
          marginBottom: '2rem',
          flexWrap: 'wrap',
          gap: '1rem'
        }}>
          <button
            onClick={() => navigate('/')}
            style={{
              padding: '0.5rem 1rem',
              background: colors.primary,
              color: 'white',
              border: 'none',
              borderRadius: '6px',
              cursor: 'pointer',
              fontWeight: '600',
              display: 'flex',
              alignItems: 'center',
              gap: '0.5rem',
              transition: 'all 0.3s ease'
            }}
          >
            <ArrowLeft size={20} />
            Back
          </button>

          <button
            onClick={toggleTheme}
            style={{
              padding: '0.75rem',
              background: colors.containerBg,
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
        </div>

        {/* Title */}
        <div style={{ marginBottom: '2rem' }}>
          <h1 style={{ 
            fontSize: 'clamp(1.75rem, 4vw, 2rem)', 
            color: colors.text, 
            marginBottom: '0.5rem',
            transition: 'color 0.3s ease'
          }}>
            ♻️ Waste Material Tracking
          </h1>
          <p style={{ 
            color: colors.textSecondary, 
            fontSize: 'clamp(0.875rem, 2vw, 1rem)',
            transition: 'color 0.3s ease'
          }}>
            Monitor waste listings, claim rates, and material distribution across the platform
          </p>
        </div>

        {error && (
          <div style={{ 
            padding: '1rem', 
            background: isDark ? '#4c1d1d' : '#fee2e2', 
            border: '1px solid #ef4444', 
            borderRadius: '8px', 
            marginBottom: '1.5rem',
            display: 'flex',
            alignItems: 'flex-start',
            gap: '0.5rem'
          }}>
            <AlertCircle size={20} color="#ef4444" style={{ flexShrink: 0 }} />
            <div style={{ color: isDark ? '#fca5a5' : '#991b1b', fontSize: '0.9rem' }}>
              <strong>Error:</strong> {error}
            </div>
          </div>
        )}

        {/* Summary Cards */}
        <div style={{ 
          display: 'grid', 
          gridTemplateColumns: 'repeat(auto-fit, minmax(min(100%, 240px), 1fr))', 
          gap: '1.5rem', 
          marginBottom: '2rem' 
        }}>
          {[
            { label: 'Total Listed', value: `${summary.totalListed} kg`, icon: Package, color: colors.primary },
            { label: 'Total Claimed', value: `${summary.totalClaimed} kg`, icon: CheckCircle, color: colors.success },
            { label: 'Available', value: `${summary.totalAvailable} kg`, icon: Clock, color: colors.info },
            { label: 'Claim Rate', value: `${summary.overallClaimRate}%`, icon: TrendingUp, color: colors.warning }
          ].map((item, index) => (
            <div key={index} style={{ 
              background: colors.cardBg, 
              borderRadius: '12px', 
              padding: '1.5rem', 
              boxShadow: isDark ? '0 4px 12px rgba(0,0,0,0.3)' : '0 4px 6px rgba(0, 0, 0, 0.1)',
              borderLeft: `4px solid ${item.color}`,
              transition: 'all 0.3s ease'
            }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
                <div style={{ flex: 1 }}>
                  <h3 style={{ 
                    fontSize: '0.9rem', 
                    color: colors.textSecondary, 
                    margin: '0 0 0.5rem 0',
                    transition: 'color 0.3s ease'
                  }}>
                    {item.label}
                  </h3>
                  <div style={{ fontSize: 'clamp(1.5rem, 4vw, 2rem)', fontWeight: 'bold', color: item.color }}>
                    {item.value}
                  </div>
                </div>
                <item.icon size={32} color={item.color} />
              </div>
            </div>
          ))}
        </div>

        {/* Main Chart */}
        <div style={{ 
          background: colors.cardBg, 
          borderRadius: '12px', 
          padding: 'clamp(1rem, 3vw, 2rem)', 
          marginBottom: '2rem', 
          boxShadow: isDark ? '0 4px 12px rgba(0,0,0,0.3)' : '0 4px 6px rgba(0, 0, 0, 0.1)',
          transition: 'all 0.3s ease'
        }}>
          <h2 style={{ 
            color: colors.text, 
            marginBottom: '0.5rem',
            fontSize: 'clamp(1.25rem, 3vw, 1.5rem)',
            transition: 'color 0.3s ease'
          }}>
            ♻️ Waste Material Distribution
          </h2>
          <p style={{ 
            color: colors.textSecondary, 
            fontSize: 'clamp(0.875rem, 2vw, 0.95rem)', 
            marginBottom: '1.5rem',
            transition: 'color 0.3s ease'
          }}>
            Tracking waste listed vs. claimed across material types
          </p>
          
          <ResponsiveContainer width="100%" height={400}>
            <BarChart data={wasteStats} margin={{ top: 20, right: 30, left: 20, bottom: 60 }}>
              <CartesianGrid strokeDasharray="3 3" stroke={colors.chartGrid} />
              <XAxis 
                dataKey="material" 
                angle={-15} 
                textAnchor="end" 
                height={80}
                stroke={colors.chartText}
                style={{ fontSize: '0.85rem' }}
              />
              <YAxis 
                label={{ value: 'Weight (kg)', angle: -90, position: 'insideLeft', fill: colors.chartText }}
                stroke={colors.chartText}
                style={{ fontSize: '0.85rem' }}
              />
              <Tooltip 
                contentStyle={{ 
                  background: colors.containerBg, 
                  border: '1px solid ' + colors.border, 
                  borderRadius: '8px',
                  padding: '10px',
                  color: colors.text
                }}
              />
              <Legend wrapperStyle={{ paddingTop: '20px' }} />
              <Bar dataKey="listed" fill={colors.primary} name="Listed (kg)" radius={[8, 8, 0, 0]} />
              <Bar dataKey="claimed" fill={colors.success} name="Claimed (kg)" radius={[8, 8, 0, 0]} />
            </BarChart>
          </ResponsiveContainer>
        </div>

        {/* Material Breakdown Table */}
        <div style={{ 
          background: colors.cardBg, 
          borderRadius: '12px', 
          padding: 'clamp(1rem, 3vw, 2rem)', 
          boxShadow: isDark ? '0 4px 12px rgba(0,0,0,0.3)' : '0 4px 6px rgba(0, 0, 0, 0.1)',
          marginBottom: '2rem',
          transition: 'all 0.3s ease',
          overflowX: 'auto'
        }}>
          <h2 style={{ 
            color: colors.text, 
            marginBottom: '1.5rem',
            fontSize: 'clamp(1.25rem, 3vw, 1.5rem)',
            transition: 'color 0.3s ease'
          }}>
            📊 Detailed Material Breakdown
          </h2>
          
          <div style={{ overflowX: 'auto' }}>
            <table style={{ 
              width: '100%', 
              borderCollapse: 'collapse',
              background: colors.containerBg,
              borderRadius: '8px',
              overflow: 'hidden'
            }}>
              <thead>
                <tr style={{ background: colors.primary, color: 'white' }}>
                  <th style={{ padding: '1rem', textAlign: 'left', minWidth: '140px' }}>Material Type</th>
                  <th style={{ padding: '1rem', textAlign: 'center', minWidth: '100px' }}>Listed (kg)</th>
                  <th style={{ padding: '1rem', textAlign: 'center', minWidth: '100px' }}>Claimed (kg)</th>
                  <th style={{ padding: '1rem', textAlign: 'center', minWidth: '120px' }}>Available (kg)</th>
                  <th style={{ padding: '1rem', textAlign: 'center', minWidth: '100px' }}>Claim Rate</th>
                </tr>
              </thead>
              <tbody>
                {wasteStats.map((stat, index) => (
                  <tr 
                    key={stat.material}
                    style={{ 
                      borderBottom: '1px solid ' + colors.border,
                      background: index % 2 === 0 ? (isDark ? '#333' : '#fafafa') : colors.containerBg
                    }}
                  >
                    <td style={{ padding: '1rem', fontWeight: '600', color: colors.text }}>
                      <Recycle size={16} style={{ display: 'inline', marginRight: '8px', verticalAlign: 'middle' }} />
                      {stat.material}
                    </td>
                    <td style={{ padding: '1rem', textAlign: 'center', color: colors.text }}>{stat.listed}</td>
                    <td style={{ padding: '1rem', textAlign: 'center', color: colors.success, fontWeight: '600' }}>
                      {stat.claimed}
                    </td>
                    <td style={{ padding: '1rem', textAlign: 'center', color: colors.info }}>
                      {stat.available}
                    </td>
                    <td style={{ padding: '1rem', textAlign: 'center' }}>
                      <span style={{
                        padding: '0.25rem 0.75rem',
                        borderRadius: '12px',
                        background: stat.claimRate >= 70 ? '#d1fae5' : stat.claimRate >= 40 ? '#fef3c7' : '#fee2e2',
                        color: stat.claimRate >= 70 ? '#065f46' : stat.claimRate >= 40 ? '#92400e' : '#991b1b',
                        fontWeight: '600',
                        fontSize: '0.875rem'
                      }}>
                        {stat.claimRate}%
                      </span>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
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
            onClick={fetchMaterials}
            style={{ 
              padding: '0.75rem 1.5rem', 
              background: colors.primary, 
              color: 'white', 
              border: 'none', 
              borderRadius: '8px', 
              cursor: 'pointer',
              fontWeight: '600',
              fontSize: 'clamp(0.875rem, 2vw, 1rem)',
              transition: 'all 0.3s ease'
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
              fontSize: 'clamp(0.875rem, 2vw, 1rem)',
              transition: 'all 0.3s ease'
            }}
          >
            📥 Export Report
          </button>
        </div>
      </div>
    </div>
  );
};

export default WasteListing;