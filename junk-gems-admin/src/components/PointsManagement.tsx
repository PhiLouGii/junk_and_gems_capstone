import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Award, TrendingUp, Users, Gift, AlertCircle } from 'lucide-react';

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
  const [gemsData, setGemsData] = useState<GemsData | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [adjustingUserId, setAdjustingUserId] = useState<number | null>(null);
  const [adjustmentAmount, setAdjustmentAmount] = useState('');
  const [adjustmentReason, setAdjustmentReason] = useState('');

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
      console.log('Gems Data:', data);
      
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
      // Note: You'll need to get the auth token from your auth context/storage
      const token = localStorage.getItem('adminToken'); // Adjust based on your auth implementation
      
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
      fetchGemsData(); // Refresh data
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
        flexDirection: 'column',
        gap: '1rem'
      }}>
        <div style={{ 
          border: '4px solid #f3f3f3',
          borderTop: '4px solid #88844D',
          borderRadius: '50%',
          width: '50px',
          height: '50px',
          animation: 'spin 1s linear infinite'
        }} />
        <p>Loading products from database...</p>
        <style>{`
          @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
          }
        `}</style>
      </div>
    );
  }

  if (!gemsData) {
    return (
      <div style={{ padding: '2rem', textAlign: 'center', color: '#ef4444' }}>
        Failed to load gems data
      </div>
    );
  }

  return (
    <div style={{ 
      minHeight: '100vh',
      background: '#ECE8D6',
      display: 'flex',
      margin: '2rem 8rem', 
      justifyContent: 'center',
      alignItems: 'flex-start',
      padding: '2rem',
      boxSizing: 'border-box'
    }}>
    <div style={{
        maxWidth: '1400px',
        width: '100%',
        background: '#fff',
        padding: '2rem',
        borderRadius: '12px',
        boxShadow: '0 4px 12px rgba(0,0,0,0.15)',
        boxSizing: 'border-box'
      }}>

      {/* Back Button */}
      <div style={{ marginBottom: '1rem' }}>
        <button
          onClick={() => navigate('/')}
          style={{
            padding: '0.5rem 1rem',
            background: '#88844D',
            color: 'white',
            border: 'none',
            borderRadius: '6px',
            cursor: 'pointer',
            fontWeight: '600',
            display: 'flex',
            alignItems: 'center',
            gap: '0.5rem'
          }}
        >
          ← Back
        </button>
      </div>
      <div style={{ marginBottom: '2rem' }}>
        <h1>💎Gems Management</h1>
        <p style={{ color: '#666', fontSize: '0.95rem' }}>
          Manage platform users, monitor activity, and moderate accounts
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
              <h3 style={{ fontSize: '0.9rem', color: '#666', margin: '0 0 0.5rem 0' }}>Total Gems</h3>
              <div style={{ fontSize: '2rem', fontWeight: 'bold', color: '#88844D' }}>
                {gemsData.summary.totalGems.toLocaleString()}
              </div>
            </div>
            <Award size={32} color="#88844D" />
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
              <h3 style={{ fontSize: '0.9rem', color: '#666', margin: '0 0 0.5rem 0' }}>Active Users</h3>
              <div style={{ fontSize: '2rem', fontWeight: 'bold', color: '#22c55e' }}>
                {gemsData.summary.activeUsers}
              </div>
            </div>
            <Users size={32} color="#22c55e" />
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
              <h3 style={{ fontSize: '0.9rem', color: '#666', margin: '0 0 0.5rem 0' }}>Total Donations</h3>
              <div style={{ fontSize: '2rem', fontWeight: 'bold', color: '#3b82f6' }}>
                {gemsData.summary.totalDonations}
              </div>
            </div>
            <Gift size={32} color="#3b82f6" />
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
              <h3 style={{ fontSize: '0.9rem', color: '#666', margin: '0 0 0.5rem 0' }}>Avg per User</h3>
              <div style={{ fontSize: '2rem', fontWeight: 'bold', color: '#88844D' }}>
                {Math.round(gemsData.summary.totalGems / gemsData.summary.totalUsers)}
              </div>
            </div>
            <TrendingUp size={32} color="#88844D" />
          </div>
        </div>
      </div>

      {/* Leaderboard Table */}
      <div style={{ 
        background: '#F7F2E4', 
        borderRadius: '12px', 
        padding: '2rem', 
        boxShadow: '0 4px 6px rgba(0, 0, 0, 0.1)',
        marginBottom: '2rem'
      }}>
        <h2 style={{ color: '#88844D', marginBottom: '1.5rem' }}>
          🏆 Gems Leaderboard
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
                <th style={{ padding: '1rem', textAlign: 'left' }}>Rank</th>
                <th style={{ padding: '1rem', textAlign: 'left' }}>User</th>
                <th style={{ padding: '1rem', textAlign: 'center' }}>Gems</th>
                <th style={{ padding: '1rem', textAlign: 'center' }}>Donations</th>
                <th style={{ padding: '1rem', textAlign: 'center' }}>User Type</th>
                <th style={{ padding: '1rem', textAlign: 'center' }}>Actions</th>
              </tr>
            </thead>
            <tbody>
              {gemsData.users.slice(0, 50).map((user, index) => (
                <tr 
                  key={user.id}
                  style={{ 
                    borderBottom: '1px solid #e5e7eb',
                    background: index % 2 === 0 ? '#fafafa' : 'white'
                  }}
                >
                  <td style={{ padding: '1rem', fontWeight: '600', color: '#88844D' }}>
                    {index === 0 && '🥇'}
                    {index === 1 && '🥈'}
                    {index === 2 && '🥉'}
                    {index > 2 && `#${index + 1}`}
                  </td>
                  <td style={{ padding: '1rem' }}>
                    <div>
                      <div style={{ fontWeight: '600', color: '#88844D' }}>{user.name}</div>
                      <div style={{ fontSize: '0.875rem', color: '#666' }}>{user.email}</div>
                    </div>
                  </td>
                  <td style={{ padding: '1rem', textAlign: 'center', fontWeight: '600', color: '#88844D' }}>
                    {user.available_gems || 0}
                  </td>
                  <td style={{ padding: '1rem', textAlign: 'center' }}>
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
                            border: '1px solid #d1d5db',
                            borderRadius: '4px',
                            width: '100px'
                          }}
                        />
                        <input
                          type="text"
                          placeholder="Reason"
                          value={adjustmentReason}
                          onChange={(e) => setAdjustmentReason(e.target.value)}
                          style={{
                            padding: '0.4rem',
                            border: '1px solid #d1d5db',
                            borderRadius: '4px',
                            width: '150px'
                          }}
                        />
                        <div style={{ display: 'flex', gap: '0.5rem' }}>
                          <button
                            onClick={() => handleAdjustGems(user.id)}
                            style={{
                              padding: '0.4rem 0.8rem',
                              background: '#22c55e',
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
                          background: '#88844D',
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
          onClick={() => alert('Export functionality would generate CSV report')}
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
          📥 Export Leaderboard
        </button>
      </div>
    </div>
  </div>
  );
};

export default PointsManagement;