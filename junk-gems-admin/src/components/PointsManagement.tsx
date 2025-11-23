import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Award, TrendingUp, Users, Gift, AlertCircle, Moon, Sun, ArrowLeft } from 'lucide-react';

interface User {
  id: number;
  name: string;
  email: string;
  available_gems: number;
  donation_count: number;
  user_type: string;
  created_at: string;
  profile_image_url?: string;
}

interface GemsData {
  users: User[];
  summary: {
    totalGems: number;
    totalDonations: number;
    activeUsers: number;
    totalUsers: number;
  };
}

const PointsManagement: React.FC = () => {
  const navigate = useNavigate();
  const [theme, setTheme] = useState(() => localStorage.getItem('theme') || 'light');
  const isDark = theme === 'dark';

  const [gemsData, setGemsData] = useState<GemsData | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [adjustingUserId, setAdjustingUserId] = useState<number | null>(null);
  const [adjustmentAmount, setAdjustmentAmount] = useState('');
  const [adjustmentReason, setAdjustmentReason] = useState('');

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
    tableBg: isDark ? '#333' : 'white',
    tableAltBg: isDark ? '#2a2a2a' : '#fafafa'
  };

  const toggleTheme = () => {
    const newTheme = theme === 'light' ? 'dark' : 'light';
    setTheme(newTheme);
    localStorage.setItem('theme', newTheme);
  };

  useEffect(() => {
    fetchGemsData();
  }, []);

  const fetchGemsData = async () => {
    try {
      setLoading(true);
      const response = await fetch('https://junk-and-gems-api.onrender.com/api/analytics/gems');
      
      if (!response.ok) {
        throw new Error('Failed to fetch gems data');
      }
      
      const data = await response.json();
      setGemsData(data);
      setError('');
    } catch (err) {
      console.error('Error fetching gems data:', err);
      setError(`Failed to connect to API: ${err instanceof Error ? err.message : 'Unknown error'}`);
    } finally {
      setLoading(false);
    }
  };

  const handleAdjustGems = async (userId: number) => {
    if (!adjustmentAmount || adjustmentAmount === '0') {
      alert('Please enter a valid amount');
      return;
    }

    if (!adjustmentReason.trim()) {
      alert('Please provide a reason for adjustment');
      return;
    }

    try {
      const token = localStorage.getItem('adminToken');
      
      const response = await fetch(`https://junk-and-gems-api.onrender.com/admin/points/${userId}`, {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`
        },
        body: JSON.stringify({
          gems: parseInt(adjustmentAmount),
          reason: adjustmentReason
        })
      });

      if (!response.ok) {
        throw new Error('Failed to adjust gems');
      }

      alert('Gems adjusted successfully!');
      setAdjustingUserId(null);
      setAdjustmentAmount('');
      setAdjustmentReason('');
      fetchGemsData();
    } catch (err) {
      console.error('Error adjusting gems:', err);
      alert('Failed to adjust gems. Please try again.');
    }
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
        <p style={{ color: colors.text }}>Loading gems data...</p>
        <style>{`@keyframes spin { 0% { transform: rotate(0deg); } 100% { transform: rotate(360deg); }}`}</style>
      </div>
    );
  }

  if (!gemsData) {
    return (
      <div style={{ 
        padding: '2rem', 
        textAlign: 'center', 
        color: '#ef4444',
        background: colors.background,
        minHeight: '100vh'
      }}>
        Failed to load gems data
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
            transition: 'color 0.3s ease',
            margin: '0 0 0.5rem 0'
          }}>
            💎 Gems Management
          </h1>
          <p style={{ 
            color: colors.textSecondary, 
            fontSize: 'clamp(0.875rem, 2vw, 0.95rem)',
            transition: 'color 0.3s ease',
            margin: 0
          }}>
            Manage user gems, track donations, and view leaderboard
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
          gridTemplateColumns: 'repeat(auto-fit, minmax(min(100%, 220px), 1fr))', 
          gap: '1.5rem', 
          marginBottom: '2rem' 
        }}>
          {[
            { label: 'Total Gems', value: gemsData.summary.totalGems.toLocaleString(), icon: Award, color: colors.primary },
            { label: 'Active Users', value: gemsData.summary.activeUsers, icon: Users, color: colors.success },
            { label: 'Total Donations', value: gemsData.summary.totalDonations, icon: Gift, color: colors.info },
            { label: 'Avg per User', value: Math.round(gemsData.summary.totalGems / gemsData.summary.totalUsers), icon: TrendingUp, color: '#BEC092' }
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

        {/* Leaderboard Table */}
        <div style={{ 
          background: colors.cardBg, 
          borderRadius: '12px', 
          padding: 'clamp(1rem, 3vw, 2rem)', 
          boxShadow: isDark ? '0 4px 12px rgba(0,0,0,0.3)' : '0 4px 6px rgba(0, 0, 0, 0.1)',
          marginBottom: '2rem',
          transition: 'all 0.3s ease'
        }}>
          <h2 style={{ 
            color: colors.text, 
            marginBottom: '1.5rem',
            fontSize: 'clamp(1.25rem, 3vw, 1.5rem)',
            transition: 'color 0.3s ease'
          }}>
            🏆 Gems Leaderboard
          </h2>
          
          <div style={{ overflowX: 'auto' }}>
            <table style={{ 
              width: '100%', 
              borderCollapse: 'collapse',
              background: colors.tableBg,
              borderRadius: '8px',
              overflow: 'hidden'
            }}>
              <thead>
                <tr style={{ background: colors.primary, color: 'white' }}>
                  <th style={{ padding: '1rem', textAlign: 'left', minWidth: '80px' }}>Rank</th>
                  <th style={{ padding: '1rem', textAlign: 'left', minWidth: '200px' }}>User</th>
                  <th style={{ padding: '1rem', textAlign: 'center', minWidth: '100px' }}>Gems</th>
                  <th style={{ padding: '1rem', textAlign: 'center', minWidth: '100px' }}>Donations</th>
                  <th style={{ padding: '1rem', textAlign: 'center', minWidth: '120px' }}>User Type</th>
                  <th style={{ padding: '1rem', textAlign: 'center', minWidth: '150px' }}>Actions</th>
                </tr>
              </thead>
              <tbody>
                {gemsData.users.slice(0, 50).map((user, index) => (
                  <tr 
                    key={user.id}
                    style={{ 
                      borderBottom: '1px solid ' + colors.border,
                      background: index % 2 === 0 ? colors.tableAltBg : colors.tableBg
                    }}
                  >
                    <td style={{ padding: '1rem', fontWeight: '600', color: colors.primary }}>
                      {index === 0 && '🥇'}
                      {index === 1 && '🥈'}
                      {index === 2 && '🥉'}
                      {index > 2 && `#${index + 1}`}
                    </td>
                    <td style={{ padding: '1rem' }}>
                      <div>
                        <div style={{ fontWeight: '600', color: colors.text }}>{user.name}</div>
                        <div style={{ fontSize: '0.875rem', color: colors.textSecondary }}>{user.email}</div>
                      </div>
                    </td>
                    <td style={{ padding: '1rem', textAlign: 'center', fontWeight: '600', color: colors.primary }}>
                      {user.available_gems || 0}
                    </td>
                    <td style={{ padding: '1rem', textAlign: 'center', color: colors.text }}>
                      {user.donation_count || 0}
                    </td>
                    <td style={{ padding: '1rem', textAlign: 'center' }}>
                      <span style={{
                        padding: '0.25rem 0.75rem',
                        borderRadius: '12px',
                        fontSize: '0.75rem',
                        fontWeight: '600',
                        background: user.user_type === 'artisan' ? '#fef3c7' : 
                                   user.user_type === 'donor' ? '#dbeafe' : '#e0e7ff',
                        color: user.user_type === 'artisan' ? '#92400e' : 
                               user.user_type === 'donor' ? '#1e40af' : '#4338ca'
                      }}>
                        {user.user_type || 'user'}
                      </span>
                    </td>
                    <td style={{ padding: '1rem', textAlign: 'center' }}>
                      {adjustingUserId === user.id ? (
                        <div style={{ display: 'flex', flexDirection: 'column', gap: '0.5rem', alignItems: 'center' }}>
                          <input
                            type="number"
                            placeholder="Amount (+/-)"
                            value={adjustmentAmount}
                            onChange={(e) => setAdjustmentAmount(e.target.value)}
                            style={{
                              padding: '0.4rem',
                              border: '1px solid ' + colors.border,
                              borderRadius: '4px',
                              width: '100px',
                              background: colors.containerBg,
                              color: colors.text
                            }}
                          />
                          <input
                            type="text"
                            placeholder="Reason"
                            value={adjustmentReason}
                            onChange={(e) => setAdjustmentReason(e.target.value)}
                            style={{
                              padding: '0.4rem',
                              border: '1px solid ' + colors.border,
                              borderRadius: '4px',
                              width: '150px',
                              background: colors.containerBg,
                              color: colors.text
                            }}
                          />
                          <div style={{ display: 'flex', gap: '0.5rem' }}>
                            <button
                              onClick={() => handleAdjustGems(user.id)}
                              style={{
                                padding: '0.4rem 0.8rem',
                                background: colors.success,
                                color: 'white',
                                border: 'none',
                                borderRadius: '4px',
                                cursor: 'pointer',
                                fontSize: '0.8rem'
                              }}
                            >
                              Save
                            </button>
                            <button
                              onClick={() => {
                                setAdjustingUserId(null);
                                setAdjustmentAmount('');
                                setAdjustmentReason('');
                              }}
                              style={{
                                padding: '0.4rem 0.8rem',
                                background: '#ef4444',
                                color: 'white',
                                border: 'none',
                                borderRadius: '4px',
                                cursor: 'pointer',
                                fontSize: '0.8rem'
                              }}
                            >
                              Cancel
                            </button>
                          </div>
                        </div>
                      ) : (
                        <button
                          onClick={() => setAdjustingUserId(user.id)}
                          style={{
                            padding: '0.4rem 0.8rem',
                            background: colors.primary,
                            color: 'white',
                            border: 'none',
                            borderRadius: '4px',
                            cursor: 'pointer',
                            fontSize: '0.85rem',
                            fontWeight: '600'
                          }}
                        >
                          Adjust Gems
                        </button>
                      )}
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
            onClick={fetchGemsData}
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
            onClick={() => alert('Export functionality would generate CSV report')}
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
            📥 Export Leaderboard
          </button>
        </div>
      </div>
    </div>
  );
};

export default PointsManagement;