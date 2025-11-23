import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Users, Search, Filter, Mail, Calendar, Award, Ban, CheckCircle, XCircle, Eye, Trash2, UserCheck, AlertCircle, Moon, Sun, ArrowLeft } from 'lucide-react';
import axios from 'axios';

interface User {
  _id: string;
  name: string;
  email: string;
  createdAt: string;
  role?: string;
  status?: 'active' | 'banned' | 'suspended';
  points?: number;
  listings?: number;
  claims?: number;
  lastActive?: string;
  verified?: boolean;
}

const UserManagement: React.FC = () => {
  const navigate = useNavigate();
  const [theme, setTheme] = useState(() => localStorage.getItem('theme') || 'light');
  const isDark = theme === 'dark';

  const [users, setUsers] = useState<User[]>([]);
  const [filteredUsers, setFilteredUsers] = useState<User[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [searchTerm, setSearchTerm] = useState('');
  const [filterStatus, setFilterStatus] = useState<'all' | 'active' | 'banned' | 'suspended'>('all');
  const [selectedUser, setSelectedUser] = useState<User | null>(null);
  const [showModal, setShowModal] = useState(false);

  const API_BASE_URL = 'https://junk-and-gems-api.onrender.com';

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
    tableBg: isDark ? '#333' : 'white',
    tableAltBg: isDark ? '#2a2a2a' : 'transparent',
    inputBg: isDark ? '#333' : 'white'
  };

  const toggleTheme = () => {
    const newTheme = theme === 'light' ? 'dark' : 'light';
    setTheme(newTheme);
    localStorage.setItem('theme', newTheme);
  };

  useEffect(() => {
    fetchUsers();
  }, []);

  useEffect(() => {
    filterUsers();
  }, [searchTerm, filterStatus, users]);

  interface ApiUser {
    id: string;
    name: string;
    email: string;
    username?: string;
    user_type?: string;
    available_gems?: number;
    donation_count?: number;
    created_at: string;
    profile_image_url?: string;
    phone_number?: string;
    banned?: boolean;
    ban_reason?: string;
  }

  interface AnalyticsResponse {
    success: boolean;
    users: ApiUser[];
    summary?: {
      totalUsers: number;
      activeUsers: number;
      bannedUsers: number;
      verifiedUsers: number;
    };
  }

  const fetchUsers = async () => {
    try {
      setLoading(true);
      const token = localStorage.getItem('token');

      try {
        const response = await axios.get<AnalyticsResponse>(`${API_BASE_URL}/api/analytics/users`);
        
        if (response.data.success && response.data.users) {
          const apiUsers: User[] = response.data.users.map((user: ApiUser) => ({
            _id: user.id,
            name: user.name || 'Unknown User',
            email: user.email,
            createdAt: user.created_at,
            role: user.user_type || 'user',
            status: user.banned ? 'banned' : 'active',
            points: user.available_gems || 0,
            listings: user.donation_count || 0,
            claims: 0,
            lastActive: user.created_at,
            verified: true
          }));
          
          setUsers(apiUsers);
          setError('');
          setLoading(false);
          return;
        }
      } catch {
        console.log('Analytics endpoint failed, trying admin endpoint...');
      }

      if (!token) {
        setError('Authentication required. Please log in as an admin.');
        setUsers([]);
        setLoading(false);
        return;
      }

      const response = await axios.get<ApiUser[]>(`${API_BASE_URL}/admin/users`, {
        headers: { 'Authorization': `Bearer ${token}` }
      });
      
      const apiUsers: User[] = response.data.map((user: ApiUser) => ({
        _id: user.id,
        name: user.name || 'Unknown User',
        email: user.email,
        createdAt: user.created_at,
        role: user.user_type || 'user',
        status: user.banned ? 'banned' : 'active',
        points: user.available_gems || 0,
        listings: user.donation_count || 0,
        claims: 0,
        lastActive: user.created_at,
        verified: true
      }));
      
      setUsers(apiUsers);
      setError('');
    } catch (err) {
      console.error('Failed to fetch users:', err);
      
      if (axios.isAxiosError(err)) {
        if (err.response?.status === 401) {
          setError('Session expired. Please log in again as an admin.');
        } else if (err.response?.status === 403) {
          setError('Access denied. Admin privileges required.');
        } else {
          setError('Failed to load users from server. Please check your connection.');
        }
      } else {
        setError('An unexpected error occurred.');
      }
      
      setUsers([]);
    } finally {
      setLoading(false);
    }
  };

  const filterUsers = () => {
    let filtered = users;

    if (searchTerm) {
      filtered = filtered.filter(user =>
        user.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
        user.email.toLowerCase().includes(searchTerm.toLowerCase())
      );
    }

    if (filterStatus !== 'all') {
      filtered = filtered.filter(user => user.status === filterStatus);
    }

    setFilteredUsers(filtered);
  };

  const handleBanUser = async (userId: string) => {
    if (!confirm('Are you sure you want to ban this user?')) return;

    try {
      const token = localStorage.getItem('token');
      if (!token) {
        alert('Authentication required. Please log in.');
        return;
      }

      await axios.post(
        `${API_BASE_URL}/admin/users/${userId}/ban`,
        { reason: 'Admin action' },
        { headers: { 'Authorization': `Bearer ${token}` } }
      );
      
      await fetchUsers();
      alert('User banned successfully');
    } catch (err) {
      console.error('Failed to ban user:', err);
      alert('Failed to ban user. Please try again.');
    }
  };

  const handleUnbanUser = async (userId: string) => {
    try {
      const token = localStorage.getItem('token');
      if (!token) {
        alert('Authentication required. Please log in.');
        return;
      }

      await axios.post(
        `${API_BASE_URL}/admin/users/${userId}/unban`,
        {},
        { headers: { 'Authorization': `Bearer ${token}` } }
      );
      
      await fetchUsers();
      alert('User unbanned successfully');
    } catch (err) {
      console.error('Failed to unban user:', err);
      alert('Failed to unban user. Please try again.');
    }
  };

  const handleDeleteUser = async (userId: string) => {
    if (!confirm('Are you sure you want to delete this user? This action cannot be undone.')) return;

    try {
      const token = localStorage.getItem('token');
      if (!token) {
        alert('Authentication required. Please log in.');
        return;
      }

      await axios.delete(
        `${API_BASE_URL}/admin/users/${userId}`,
        { headers: { 'Authorization': `Bearer ${token}` } }
      );
      
      await fetchUsers();
      alert('User deleted successfully');
    } catch (err) {
      console.error('Failed to delete user:', err);
      alert('Failed to delete user. Please try again.');
    }
  };

  const formatDate = (dateString: string) => {
    const date = new Date(dateString);
    return date.toLocaleDateString('en-US', { year: 'numeric', month: 'short', day: 'numeric' });
  };

  const getTimeAgo = (dateString: string) => {
    const seconds = Math.floor((new Date().getTime() - new Date(dateString).getTime()) / 1000);
    if (seconds < 60) return 'Just now';
    if (seconds < 3600) return `${Math.floor(seconds / 60)}m ago`;
    if (seconds < 86400) return `${Math.floor(seconds / 3600)}h ago`;
    if (seconds < 604800) return `${Math.floor(seconds / 86400)}d ago`;
    return formatDate(dateString);
  };

  const stats = {
    totalUsers: users.length,
    activeUsers: users.filter(u => u.status === 'active').length,
    bannedUsers: users.filter(u => u.status === 'banned').length,
    verifiedUsers: users.filter(u => u.verified).length,
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
        <p style={{ color: colors.text }}>Loading users from database...</p>
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
            transition: 'color 0.3s ease',
            margin: '0 0 0.5rem 0'
          }}>
            👥 User Management
          </h1>
          <p style={{ 
            color: colors.textSecondary, 
            fontSize: 'clamp(0.875rem, 2vw, 0.95rem)',
            transition: 'color 0.3s ease',
            margin: 0
          }}>
            Manage platform users, monitor activity, and moderate accounts
          </p>
        </div>

        {error && (
          <div style={{
            background: isDark ? '#4c1d1d' : '#fee2e2',
            border: '2px solid #ef4444',
            borderRadius: '8px',
            padding: '1rem',
            marginBottom: '2rem',
            display: 'flex',
            alignItems: 'center',
            color: isDark ? '#fca5a5' : '#991b1b'
          }}>
            <AlertCircle size={20} style={{ marginRight: '12px', flexShrink: 0 }} />
            <div>
              <strong>Error:</strong> {error}
            </div>
          </div>
        )}

        {/* Stats Overview */}
        <div style={{ 
          display: 'grid', 
          gridTemplateColumns: 'repeat(auto-fit, minmax(min(100%, 240px), 1fr))', 
          gap: '1.5rem', 
          marginBottom: '2rem' 
        }}>
          {[
            { label: 'Total Users', value: stats.totalUsers, icon: Users, subtext: 'Registered accounts' },
            { label: 'Active Users', value: stats.activeUsers, icon: UserCheck, subtext: `${stats.totalUsers > 0 ? Math.round((stats.activeUsers / stats.totalUsers) * 100) : 0}% of total`, color: colors.success },
            { label: 'Verified Users', value: stats.verifiedUsers, icon: CheckCircle, subtext: 'Email verified', color: colors.info },
            { label: 'Banned Users', value: stats.bannedUsers, icon: Ban, subtext: stats.bannedUsers > 0 ? 'Requires attention' : 'All clear', color: '#ef4444' }
          ].map((item, index) => (
            <div key={index} style={{ 
              background: colors.cardBg, 
              borderRadius: '12px', 
              padding: '1.5rem', 
              boxShadow: isDark ? '0 4px 12px rgba(0,0,0,0.3)' : '0 4px 6px rgba(0, 0, 0, 0.1)',
              transition: 'all 0.3s ease'
            }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
                <div style={{ flex: 1 }}>
                  <h3 style={{ fontSize: '0.95rem', color: colors.textSecondary, margin: '0 0 0.5rem 0' }}>
                    {item.label}
                  </h3>
                  <div style={{ fontSize: 'clamp(2rem, 5vw, 2.5rem)', fontWeight: 'bold', color: colors.text }}>
                    {item.value}
                  </div>
                  <div style={{ 
                    color: item.color || colors.textSecondary, 
                    fontSize: '0.875rem', 
                    marginTop: '0.5rem' 
                  }}>
                    {item.subtext}
                  </div>
                </div>
                <item.icon size={36} color={colors.primary} strokeWidth={2} />
              </div>
            </div>
          ))}
        </div>

        {/* Search and Filter Bar */}
        <div style={{ 
          background: colors.cardBg, 
          borderRadius: '12px', 
          padding: '1.5rem', 
          marginBottom: '2rem',
          boxShadow: isDark ? '0 4px 12px rgba(0,0,0,0.3)' : '0 4px 6px rgba(0, 0, 0, 0.1)',
          transition: 'all 0.3s ease'
        }}>
          <div style={{ display: 'flex', gap: '1rem', flexWrap: 'wrap', alignItems: 'center' }}>
            <div style={{ flex: '1 1 300px', position: 'relative' }}>
              <Search size={20} style={{ 
                position: 'absolute', 
                left: '12px', 
                top: '50%', 
                transform: 'translateY(-50%)', 
                color: colors.primary 
              }} />
              <input
                type="text"
                placeholder="Search by name or email..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                style={{
                  width: '100%',
                  padding: '0.75rem 1rem 0.75rem 2.5rem',
                  border: '2px solid ' + colors.border,
                  borderRadius: '8px',
                  fontSize: '0.95rem',
                  outline: 'none',
                  transition: 'border-color 0.2s',
                  background: colors.inputBg,
                  color: colors.text
                }}
                onFocus={(e) => e.target.style.borderColor = colors.primary}
                onBlur={(e) => e.target.style.borderColor = colors.border}
              />
            </div>

            <div style={{ display: 'flex', gap: '0.5rem', alignItems: 'center' }}>
              <Filter size={20} color={colors.primary} />
              <select
                value={filterStatus}
                onChange={(e) => setFilterStatus(e.target.value as 'all' | 'active' | 'banned' | 'suspended')}
                style={{
                  padding: '0.75rem 1rem',
                  border: '2px solid ' + colors.border,
                  borderRadius: '8px',
                  fontSize: '0.95rem',
                  background: colors.inputBg,
                  color: colors.text,
                  fontWeight: '600',
                  cursor: 'pointer',
                  outline: 'none'
                }}
              >
                <option value="all">All Users</option>
                <option value="active">Active Only</option>
                <option value="banned">Banned Only</option>
                <option value="suspended">Suspended Only</option>
              </select>
            </div>

            <div style={{ color: colors.textSecondary, fontSize: '0.9rem' }}>
              Showing {filteredUsers.length} of {users.length} users
            </div>

            <button
              onClick={fetchUsers}
              style={{
                padding: '0.75rem 1rem',
                background: colors.primary,
                color: 'white',
                border: 'none',
                borderRadius: '8px',
                fontSize: '0.95rem',
                fontWeight: '600',
                cursor: 'pointer',
                transition: 'all 0.2s'
              }}
            >
              🔄 Refresh
            </button>
          </div>
        </div>

        {/* Users Table */}
        <div style={{ 
          background: colors.cardBg, 
          borderRadius: '12px', 
          padding: 'clamp(1rem, 3vw, 1.5rem)',
          boxShadow: isDark ? '0 4px 12px rgba(0,0,0,0.3)' : '0 4px 6px rgba(0, 0, 0, 0.1)',
          overflow: 'auto',
          transition: 'all 0.3s ease'
        }}>
          <h2 style={{ 
            marginBottom: '1.5rem',
            color: colors.text,
            fontSize: 'clamp(1.25rem, 3vw, 1.5rem)'
          }}>
            📋 User Directory
          </h2>
          
          {filteredUsers.length === 0 ? (
            <div style={{ textAlign: 'center', padding: '3rem', color: colors.textSecondary }}>
              <Users size={48} color={colors.border} style={{ margin: '0 auto 1rem' }} />
              <p>{users.length === 0 ? 'No users in database yet' : 'No users found matching your criteria'}</p>
            </div>
          ) : (
            <div style={{ overflowX: 'auto' }}>
              <table style={{ width: '100%', borderCollapse: 'collapse' }}>
                <thead>
                  <tr style={{ borderBottom: '2px solid ' + colors.border }}>
                    <th style={{ padding: '1rem', textAlign: 'left', color: colors.text, fontWeight: '600', minWidth: '200px' }}>User</th>
                    <th style={{ padding: '1rem', textAlign: 'left', color: colors.text, fontWeight: '600', minWidth: '100px' }}>Status</th>
                    <th style={{ padding: '1rem', textAlign: 'center', color: colors.text, fontWeight: '600', minWidth: '80px' }}>Points</th>
                    <th style={{ padding: '1rem', textAlign: 'center', color: colors.text, fontWeight: '600', minWidth: '100px' }}>Activity</th>
                    <th style={{ padding: '1rem', textAlign: 'left', color: colors.text, fontWeight: '600', minWidth: '120px' }}>Joined</th>
                    <th style={{ padding: '1rem', textAlign: 'center', color: colors.text, fontWeight: '600', minWidth: '140px' }}>Actions</th>
                  </tr>
                </thead>
                <tbody>
                  {filteredUsers.map((user) => (
                    <tr 
                      key={user._id}
                      style={{ 
                        borderBottom: '1px solid ' + colors.border,
                        transition: 'background 0.2s'
                      }}
                      onMouseEnter={(e) => e.currentTarget.style.background = isDark ? 'rgba(136, 132, 77, 0.1)' : 'rgba(136, 132, 77, 0.05)'}
                      onMouseLeave={(e) => e.currentTarget.style.background = 'transparent'}
                    >
                      <td style={{ padding: '1rem' }}>
                        <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem' }}>
                          <div style={{
                            width: '40px',
                            height: '40px',
                            borderRadius: '50%',
                            background: colors.primary,
                            color: 'white',
                            display: 'flex',
                            alignItems: 'center',
                            justifyContent: 'center',
                            fontWeight: 'bold',
                            fontSize: '1.1rem',
                            flexShrink: 0
                          }}>
                            {user.name.charAt(0).toUpperCase()}
                          </div>
                          <div>
                            <div style={{ 
                              fontWeight: '600', 
                              color: colors.text, 
                              display: 'flex', 
                              alignItems: 'center', 
                              gap: '0.5rem',
                              flexWrap: 'wrap'
                            }}>
                              {user.name}
                              {user.verified && <CheckCircle size={14} color={colors.success} />}
                            </div>
                            <div style={{ 
                              fontSize: '0.85rem', 
                              color: colors.textSecondary, 
                              display: 'flex', 
                              alignItems: 'center', 
                              gap: '0.25rem' 
                            }}>
                              <Mail size={12} />
                              {user.email}
                            </div>
                          </div>
                        </div>
                      </td>
                      <td style={{ padding: '1rem' }}>
                        <span style={{
                          padding: '0.4rem 0.8rem',
                          borderRadius: '20px',
                          fontSize: '0.75rem',
                          fontWeight: '600',
                          textTransform: 'uppercase',
                          background: user.status === 'active' ? '#d1fae5' : 
                                     user.status === 'banned' ? '#fee2e2' : '#fef3c7',
                          color: user.status === 'active' ? '#065f46' : 
                                 user.status === 'banned' ? '#991b1b' : '#92400e'
                        }}>
                          {user.status}
                        </span>
                      </td>
                      <td style={{ padding: '1rem', textAlign: 'center' }}>
                        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '0.25rem' }}>
                          <Award size={16} color={colors.primary} />
                          <strong style={{ color: colors.text }}>{user.points}</strong>
                        </div>
                      </td>
                      <td style={{ padding: '1rem' }}>
                        <div style={{ fontSize: '0.85rem', color: colors.textSecondary, textAlign: 'center' }}>
                          <div>{user.listings} listings</div>
                          <div>{user.claims} claims</div>
                        </div>
                      </td>
                      <td style={{ padding: '1rem' }}>
                        <div style={{ fontSize: '0.85rem', color: colors.textSecondary }}>
                          <div style={{ display: 'flex', alignItems: 'center', gap: '0.25rem' }}>
                            <Calendar size={12} />
                            {formatDate(user.createdAt)}
                          </div>
                          {user.lastActive && (
                            <div style={{ marginTop: '0.25rem', fontSize: '0.8rem' }}>
                              Last: {getTimeAgo(user.lastActive)}
                            </div>
                          )}
                        </div>
                      </td>
                      <td style={{ padding: '1rem' }}>
                        <div style={{ display: 'flex', gap: '0.5rem', justifyContent: 'center', flexWrap: 'wrap' }}>
                          <button
                            onClick={() => {
                              setSelectedUser(user);
                              setShowModal(true);
                            }}
                            style={{
                              padding: '0.5rem',
                              background: colors.primary,
                              color: 'white',
                              border: 'none',
                              borderRadius: '6px',
                              cursor: 'pointer',
                              transition: 'all 0.2s'
                            }}
                            title="View Details"
                          >
                            <Eye size={16} />
                          </button>
                          {user.status === 'active' ? (
                            <button
                              onClick={() => handleBanUser(user._id)}
                              style={{
                                padding: '0.5rem',
                                background: '#ef4444',
                                color: 'white',
                                border: 'none',
                                borderRadius: '6px',
                                cursor: 'pointer',
                                transition: 'all 0.2s'
                              }}
                              title="Ban User"
                            >
                              <Ban size={16} />
                            </button>
                          ) : (
                            <button
                              onClick={() => handleUnbanUser(user._id)}
                              style={{
                                padding: '0.5rem',
                                background: colors.success,
                                color: 'white',
                                border: 'none',
                                borderRadius: '6px',
                                cursor: 'pointer',
                                transition: 'all 0.2s'
                              }}
                              title="Unban User"
                            >
                              <CheckCircle size={16} />
                            </button>
                          )}
                          <button
                            onClick={() => handleDeleteUser(user._id)}
                            style={{
                              padding: '0.5rem',
                              background: '#991b1b',
                              color: 'white',
                              border: 'none',
                              borderRadius: '6px',
                              cursor: 'pointer',
                              transition: 'all 0.2s'
                            }}
                            title="Delete User"
                          >
                            <Trash2 size={16} />
                          </button>
                        </div>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </div>

        {/* User Detail Modal */}
        {showModal && selectedUser && (
          <div style={{
            position: 'fixed',
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            background: 'rgba(0, 0, 0, 0.5)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            zIndex: 1000,
            padding: '1rem'
          }}
          onClick={() => setShowModal(false)}
          >
            <div 
              style={{
                background: colors.cardBg,
                borderRadius: '12px',
                padding: 'clamp(1.5rem, 4vw, 2rem)',
                maxWidth: '600px',
                width: '100%',
                maxHeight: '90vh',
                overflow: 'auto',
                boxShadow: '0 20px 40px rgba(0, 0, 0, 0.3)'
              }}
              onClick={(e) => e.stopPropagation()}
            >
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'start', marginBottom: '1.5rem' }}>
                <h2 style={{ margin: 0, color: colors.text }}>👤 User Details</h2>
                <button
                  onClick={() => setShowModal(false)}
                  style={{
                    background: 'none',
                    border: 'none',
                    fontSize: '1.5rem',
                    cursor: 'pointer',
                    color: colors.text,
                    padding: '0',
                    width: '30px',
                    height: '30px'
                  }}
                >
                  ×
                </button>
              </div>

              <div style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
                <div style={{ background: colors.containerBg, padding: '1rem', borderRadius: '8px' }}>
                  <div style={{ fontWeight: '600', color: colors.primary, marginBottom: '0.5rem' }}>User ID</div>
                  <div style={{ fontSize: '0.85rem', color: colors.textSecondary }}>{selectedUser._id}</div>
                </div>

                <div style={{ background: colors.containerBg, padding: '1rem', borderRadius: '8px' }}>
                  <div style={{ fontWeight: '600', color: colors.primary, marginBottom: '0.5rem' }}>Name</div>
                  <div style={{ color: colors.text }}>{selectedUser.name}</div>
                </div>

                <div style={{ background: colors.containerBg, padding: '1rem', borderRadius: '8px' }}>
                  <div style={{ fontWeight: '600', color: colors.primary, marginBottom: '0.5rem' }}>Email</div>
                  <div style={{ color: colors.text }}>{selectedUser.email}</div>
                </div>

                <div style={{ background: colors.containerBg, padding: '1rem', borderRadius: '8px' }}>
                  <div style={{ fontWeight: '600', color: colors.primary, marginBottom: '0.5rem' }}>Role</div>
                  <div style={{ 
                    display: 'inline-block',
                    padding: '0.25rem 0.75rem',
                    borderRadius: '20px',
                    background: selectedUser.role === 'admin' ? '#dbeafe' : '#f3f4f6',
                    color: selectedUser.role === 'admin' ? '#1e40af' : '#374151',
                    fontSize: '0.875rem',
                    fontWeight: '600'
                  }}>
                    {selectedUser.role?.toUpperCase()}
                  </div>
                </div>

                <div style={{ background: colors.containerBg, padding: '1rem', borderRadius: '8px' }}>
                  <div style={{ fontWeight: '600', color: colors.primary, marginBottom: '0.5rem' }}>Status</div>
                  <span style={{
                    padding: '0.4rem 0.8rem',
                    borderRadius: '20px',
                    fontSize: '0.75rem',
                    fontWeight: '600',
                    textTransform: 'uppercase',
                    background: selectedUser.status === 'active' ? '#d1fae5' : 
                               selectedUser.status === 'banned' ? '#fee2e2' : '#fef3c7',
                    color: selectedUser.status === 'active' ? '#065f46' : 
                           selectedUser.status === 'banned' ? '#991b1b' : '#92400e'
                  }}>
                    {selectedUser.status}
                  </span>
                </div>

                <div style={{ background: colors.containerBg, padding: '1rem', borderRadius: '8px' }}>
                  <div style={{ fontWeight: '600', color: colors.primary, marginBottom: '0.5rem' }}>Gems (Points)</div>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                    <Award size={20} color={colors.primary} />
                    <strong style={{ fontSize: '1.25rem', color: colors.text }}>{selectedUser.points} Gems</strong>
                  </div>
                </div>

                <div style={{ background: colors.containerBg, padding: '1rem', borderRadius: '8px' }}>
                  <div style={{ fontWeight: '600', color: colors.primary, marginBottom: '0.5rem' }}>Activity Summary</div>
                  <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '1rem', marginTop: '0.5rem' }}>
                    <div style={{ textAlign: 'center', padding: '0.5rem', background: colors.cardBg, borderRadius: '6px' }}>
                      <div style={{ fontSize: '1.5rem', fontWeight: 'bold', color: colors.text }}>{selectedUser.listings}</div>
                      <div style={{ fontSize: '0.85rem', color: colors.textSecondary }}>Listings</div>
                    </div>
                    <div style={{ textAlign: 'center', padding: '0.5rem', background: colors.cardBg, borderRadius: '6px' }}>
                      <div style={{ fontSize: '1.5rem', fontWeight: 'bold', color: colors.text }}>{selectedUser.claims}</div>
                      <div style={{ fontSize: '0.85rem', color: colors.textSecondary }}>Claims</div>
                    </div>
                  </div>
                </div>

                <div style={{ background: colors.containerBg, padding: '1rem', borderRadius: '8px' }}>
                  <div style={{ fontWeight: '600', color: colors.primary, marginBottom: '0.5rem' }}>Account Created</div>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', color: colors.text }}>
                    <Calendar size={16} color={colors.primary} />
                    {formatDate(selectedUser.createdAt)}
                  </div>
                </div>

                {selectedUser.lastActive && (
                  <div style={{ background: colors.containerBg, padding: '1rem', borderRadius: '8px' }}>
                    <div style={{ fontWeight: '600', color: colors.primary, marginBottom: '0.5rem' }}>Last Active</div>
                    <div style={{ color: colors.text }}>{getTimeAgo(selectedUser.lastActive)}</div>
                  </div>
                )}

                <div style={{ background: colors.containerBg, padding: '1rem', borderRadius: '8px' }}>
                  <div style={{ fontWeight: '600', color: colors.primary, marginBottom: '0.5rem' }}>Email Verification</div>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                    {selectedUser.verified ? (
                      <>
                        <CheckCircle size={16} color={colors.success} />
                        <span style={{ color: colors.success, fontWeight: '600' }}>Verified</span>
                      </>
                    ) : (
                      <>
                        <XCircle size={16} color="#ef4444" />
                        <span style={{ color: '#ef4444', fontWeight: '600' }}>Not Verified</span>
                      </>
                    )}
                  </div>
                </div>
              </div>

              <div style={{ marginTop: '1.5rem', display: 'flex', gap: '0.5rem', flexWrap: 'wrap' }}>
                {selectedUser.status === 'active' ? (
                  <button
                    onClick={() => {
                      setShowModal(false);
                      handleBanUser(selectedUser._id);
                    }}
                    style={{
                      flex: 1,
                      padding: '0.75rem',
                      background: '#ef4444',
                      color: 'white',
                      border: 'none',
                      borderRadius: '8px',
                      fontWeight: '600',
                      cursor: 'pointer',
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center',
                      gap: '0.5rem',
                      minWidth: '140px'
                    }}
                  >
                    <Ban size={16} />
                    Ban User
                  </button>
                ) : (
                  <button
                    onClick={() => {
                      setShowModal(false);
                      handleUnbanUser(selectedUser._id);
                    }}
                    style={{
                      flex: 1,
                      padding: '0.75rem',
                      background: colors.success,
                      color: 'white',
                      border: 'none',
                      borderRadius: '8px',
                      fontWeight: '600',
                      cursor: 'pointer',
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center',
                      gap: '0.5rem',
                      minWidth: '140px'
                    }}
                  >
                    <CheckCircle size={16} />
                    Unban User
                  </button>
                )}
                <button
                  onClick={() => setShowModal(false)}
                  style={{
                    flex: 1,
                    padding: '0.75rem',
                    background: colors.primary,
                    color: 'white',
                    border: 'none',
                    borderRadius: '8px',
                    fontWeight: '600',
                    cursor: 'pointer',
                    minWidth: '140px'
                  }}
                >
                  Close
                </button>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
};

export default UserManagement;