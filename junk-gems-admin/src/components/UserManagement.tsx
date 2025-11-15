import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Users, Search, Filter, Mail, Calendar, Award, Ban, CheckCircle, XCircle, Eye, Trash2, UserCheck, AlertCircle } from 'lucide-react';
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

  const [users, setUsers] = useState<User[]>([]);
  const [filteredUsers, setFilteredUsers] = useState<User[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [searchTerm, setSearchTerm] = useState('');
  const [filterStatus, setFilterStatus] = useState<'all' | 'active' | 'banned' | 'suspended'>('all');
  const [selectedUser, setSelectedUser] = useState<User | null>(null);
  const [showModal, setShowModal] = useState(false);

  const API_BASE_URL = 'https://junk-and-gems-api.onrender.com';

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
      
      // Get authentication token from localStorage
      const token = localStorage.getItem('token');

      // Try analytics endpoint first (doesn't require admin auth)
      try {
        console.log('Trying analytics endpoint...');
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

      // Fallback to admin endpoint if analytics fails
      if (!token) {
        setError('Authentication required. Please log in as an admin.');
        setUsers([]);
        setLoading(false);
        return;
      }

      const response = await axios.get<ApiUser[]>(`${API_BASE_URL}/admin/users`, {
        headers: {
          'Authorization': `Bearer ${token}`
        }
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

    // Filter by search term
    if (searchTerm) {
      filtered = filtered.filter(user =>
        user.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
        user.email.toLowerCase().includes(searchTerm.toLowerCase())
      );
    }

    // Filter by status
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
        {
          headers: { 'Authorization': `Bearer ${token}` }
        }
      );
      
      // Refresh the users list to get updated data
      await fetchUsers();
      alert('User banned successfully');
    } catch (err) {
      console.error('Failed to ban user:', err);
      if (axios.isAxiosError(err)) {
        if (err.response?.status === 401 || err.response?.status === 403) {
          alert('Authentication failed. Please log in as admin.');
        } else {
          alert('Failed to ban user. Please try again.');
        }
      } else {
        alert('An unexpected error occurred.');
      }
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
        {
          headers: { 'Authorization': `Bearer ${token}` }
        }
      );
      
      // Refresh the users list to get updated data
      await fetchUsers();
      alert('User unbanned successfully');
    } catch (err) {
      console.error('Failed to unban user:', err);
      if (axios.isAxiosError(err)) {
        if (err.response?.status === 401 || err.response?.status === 403) {
          alert('Authentication failed. Please log in as admin.');
        } else {
          alert('Failed to unban user. Please try again.');
        }
      } else {
        alert('An unexpected error occurred.');
      }
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
        {
          headers: { 'Authorization': `Bearer ${token}` }
        }
      );
      
      // Refresh the users list
      await fetchUsers();
      alert('User deleted successfully');
    } catch (err) {
      console.error('Failed to delete user:', err);
      if (axios.isAxiosError(err)) {
        if (err.response?.status === 401 || err.response?.status === 403) {
          alert('Authentication failed. Please log in as admin.');
        } else if (err.response?.status === 404) {
          alert('Delete endpoint not implemented yet. Please contact support.');
        } else {
          alert('Failed to delete user. Please try again.');
        }
      } else {
        alert('An unexpected error occurred.');
      }
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
        <p>Loading users from database...</p>
        <style>{`
          @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
          }
        `}</style>
      </div>
    );
  }

  return (
    <div style={{ 
      minHeight: '100vh',
      background: '#ECE8D6',
      display: 'flex',
      margin: '6rem 6rem', 
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
        <h1>👥 User Management</h1>
        <p style={{ color: '#666', fontSize: '0.95rem' }}>
          Manage platform users, monitor activity, and moderate accounts
        </p>
      </div>

      {error && (
        <div style={{
          background: '#fee2e2',
          border: '2px solid #ef4444',
          borderRadius: '8px',
          padding: '1rem',
          marginBottom: '2rem',
          display: 'flex',
          alignItems: 'center',
          color: '#991b1b'
        }}>
          <AlertCircle size={20} style={{ marginRight: '12px', flexShrink: 0 }} />
          <div>
            <strong>Error:</strong> {error}
          </div>
        </div>
      )}

      {/* Stats Overview */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(250px, 1fr))', gap: '1.5rem', marginBottom: '2rem' }}>
        <div style={{ background: '#F7F2E4', borderRadius: '12px', padding: '1.5rem', boxShadow: '0 4px 6px rgba(0, 0, 0, 0.1)' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
            <div style={{ flex: 1 }}>
              <h3 style={{ fontSize: '0.95rem', color: '#666', margin: '0 0 0.5rem 0' }}>Total Users</h3>
              <div style={{ fontSize: '2.5rem', fontWeight: 'bold', color: '#88844D' }}>{stats.totalUsers}</div>
              <div style={{ color: '#666', fontSize: '0.875rem', marginTop: '0.5rem' }}>
                Registered accounts
              </div>
            </div>
            <Users size={36} color="#88844D" strokeWidth={2} />
          </div>
        </div>

        <div style={{ background: '#F7F2E4', borderRadius: '12px', padding: '1.5rem', boxShadow: '0 4px 6px rgba(0, 0, 0, 0.1)' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
            <div style={{ flex: 1 }}>
              <h3 style={{ fontSize: '0.95rem', color: '#666', margin: '0 0 0.5rem 0' }}>Active Users</h3>
              <div style={{ fontSize: '2.5rem', fontWeight: 'bold', color: '#88844D' }}>{stats.activeUsers}</div>
              <div style={{ color: '#22c55e', fontSize: '0.875rem', marginTop: '0.5rem' }}>
                {stats.totalUsers > 0 ? Math.round((stats.activeUsers / stats.totalUsers) * 100) : 0}% of total
              </div>
            </div>
            <UserCheck size={36} color="#88844D" strokeWidth={2} />
          </div>
        </div>

        <div style={{ background: '#F7F2E4', borderRadius: '12px', padding: '1.5rem', boxShadow: '0 4px 6px rgba(0, 0, 0, 0.1)' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
            <div style={{ flex: 1 }}>
              <h3 style={{ fontSize: '0.95rem', color: '#666', margin: '0 0 0.5rem 0' }}>Verified Users</h3>
              <div style={{ fontSize: '2.5rem', fontWeight: 'bold', color: '#88844D' }}>{stats.verifiedUsers}</div>
              <div style={{ color: '#3b82f6', fontSize: '0.875rem', marginTop: '0.5rem' }}>
                Email verified
              </div>
            </div>
            <CheckCircle size={36} color="#88844D" strokeWidth={2} />
          </div>
        </div>

        <div style={{ background: '#F7F2E4', borderRadius: '12px', padding: '1.5rem', boxShadow: '0 4px 6px rgba(0, 0, 0, 0.1)' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
            <div style={{ flex: 1 }}>
              <h3 style={{ fontSize: '0.95rem', color: '#666', margin: '0 0 0.5rem 0' }}>Banned Users</h3>
              <div style={{ fontSize: '2.5rem', fontWeight: 'bold', color: '#88844D' }}>{stats.bannedUsers}</div>
              <div style={{ color: stats.bannedUsers > 0 ? '#ef4444' : '#666', fontSize: '0.875rem', marginTop: '0.5rem' }}>
                {stats.bannedUsers > 0 ? 'Requires attention' : 'All clear'}
              </div>
            </div>
            <Ban size={36} color="#88844D" strokeWidth={2} />
          </div>
        </div>
      </div>

      {/* Search and Filter Bar */}
      <div style={{ 
        background: '#F7F2E4', 
        borderRadius: '12px', 
        padding: '1.5rem', 
        marginBottom: '2rem',
        boxShadow: '0 4px 6px rgba(0, 0, 0, 0.1)'
      }}>
        <div style={{ display: 'flex', gap: '1rem', flexWrap: 'wrap', alignItems: 'center' }}>
          {/* Search */}
          <div style={{ flex: '1 1 300px', position: 'relative' }}>
            <Search size={20} style={{ position: 'absolute', left: '12px', top: '50%', transform: 'translateY(-50%)', color: '#88844D' }} />
            <input
              type="text"
              placeholder="Search by name or email..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              style={{
                width: '100%',
                padding: '0.75rem 1rem 0.75rem 2.5rem',
                border: '2px solid #BEC092',
                borderRadius: '8px',
                fontSize: '0.95rem',
                outline: 'none',
                transition: 'border-color 0.2s'
              }}
              onFocus={(e) => e.target.style.borderColor = '#88844D'}
              onBlur={(e) => e.target.style.borderColor = '#BEC092'}
            />
          </div>

          {/* Filter */}
          <div style={{ display: 'flex', gap: '0.5rem', alignItems: 'center' }}>
            <Filter size={20} color="#88844D" />
            <select
              value={filterStatus}
              onChange={(e) => setFilterStatus(e.target.value as 'all' | 'active' | 'banned' | 'suspended')}
              style={{
                padding: '0.75rem 1rem',
                border: '2px solid #BEC092',
                borderRadius: '8px',
                fontSize: '0.95rem',
                background: 'white',
                color: '#88844D',
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

          <div style={{ color: '#666', fontSize: '0.9rem' }}>
            Showing {filteredUsers.length} of {users.length} users
          </div>

          {/* Refresh Button */}
          <button
            onClick={fetchUsers}
            style={{
              padding: '0.75rem 1rem',
              background: '#88844D',
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
        background: '#F7F2E4', 
        borderRadius: '12px', 
        padding: '1.5rem',
        boxShadow: '0 4px 6px rgba(0, 0, 0, 0.1)',
        overflow: 'auto'
      }}>
        <h2 style={{ marginBottom: '1.5rem' }}>📋 User Directory</h2>
        
        {filteredUsers.length === 0 ? (
          <div style={{ textAlign: 'center', padding: '3rem', color: '#666' }}>
            <Users size={48} color="#BEC092" style={{ margin: '0 auto 1rem' }} />
            <p>{users.length === 0 ? 'No users in database yet' : 'No users found matching your criteria'}</p>
          </div>
        ) : (
          <div style={{ overflowX: 'auto' }}>
            <table style={{ width: '100%', borderCollapse: 'collapse' }}>
              <thead>
                <tr style={{ borderBottom: '2px solid #BEC092' }}>
                  <th style={{ padding: '1rem', textAlign: 'left', color: '#88844D', fontWeight: '600' }}>User</th>
                  <th style={{ padding: '1rem', textAlign: 'left', color: '#88844D', fontWeight: '600' }}>Status</th>
                  <th style={{ padding: '1rem', textAlign: 'center', color: '#88844D', fontWeight: '600' }}>Points</th>
                  <th style={{ padding: '1rem', textAlign: 'center', color: '#88844D', fontWeight: '600' }}>Activity</th>
                  <th style={{ padding: '1rem', textAlign: 'left', color: '#88844D', fontWeight: '600' }}>Joined</th>
                  <th style={{ padding: '1rem', textAlign: 'center', color: '#88844D', fontWeight: '600' }}>Actions</th>
                </tr>
              </thead>
              <tbody>
                {filteredUsers.map((user) => (
                  <tr 
                    key={user._id}
                    style={{ 
                      borderBottom: '1px solid #E4E5C2',
                      transition: 'background 0.2s'
                    }}
                    onMouseEnter={(e) => e.currentTarget.style.background = 'rgba(136, 132, 77, 0.05)'}
                    onMouseLeave={(e) => e.currentTarget.style.background = 'transparent'}
                  >
                    <td style={{ padding: '1rem' }}>
                      <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem' }}>
                        <div style={{
                          width: '40px',
                          height: '40px',
                          borderRadius: '50%',
                          background: '#88844D',
                          color: 'white',
                          display: 'flex',
                          alignItems: 'center',
                          justifyContent: 'center',
                          fontWeight: 'bold',
                          fontSize: '1.1rem'
                        }}>
                          {user.name.charAt(0).toUpperCase()}
                        </div>
                        <div>
                          <div style={{ fontWeight: '600', color: '#88844D', display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                            {user.name}
                            {user.verified && <CheckCircle size={14} color="#22c55e" />}
                          </div>
                          <div style={{ fontSize: '0.85rem', color: '#666', display: 'flex', alignItems: 'center', gap: '0.25rem' }}>
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
                        <Award size={16} color="#88844D" />
                        <strong style={{ color: '#88844D' }}>{user.points}</strong>
                      </div>
                    </td>
                    <td style={{ padding: '1rem' }}>
                      <div style={{ fontSize: '0.85rem', color: '#666', textAlign: 'center' }}>
                        <div>{user.listings} listings</div>
                        <div>{user.claims} claims</div>
                      </div>
                    </td>
                    <td style={{ padding: '1rem' }}>
                      <div style={{ fontSize: '0.85rem', color: '#666' }}>
                        <div style={{ display: 'flex', alignItems: 'center', gap: '0.25rem' }}>
                          <Calendar size={12} />
                          {formatDate(user.createdAt)}
                        </div>
                        {user.lastActive && (
                          <div style={{ marginTop: '0.25rem', fontSize: '0.8rem', color: '#999' }}>
                            Last: {getTimeAgo(user.lastActive)}
                          </div>
                        )}
                      </div>
                    </td>
                    <td style={{ padding: '1rem' }}>
                      <div style={{ display: 'flex', gap: '0.5rem', justifyContent: 'center' }}>
                        <button
                          onClick={() => {
                            setSelectedUser(user);
                            setShowModal(true);
                          }}
                          style={{
                            padding: '0.5rem',
                            background: '#88844D',
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
                              background: '#22c55e',
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
              background: '#F7F2E4',
              borderRadius: '12px',
              padding: '2rem',
              maxWidth: '600px',
              width: '100%',
              maxHeight: '90vh',
              overflow: 'auto',
              boxShadow: '0 20px 40px rgba(0, 0, 0, 0.3)'
            }}
            onClick={(e) => e.stopPropagation()}
          >
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'start', marginBottom: '1.5rem' }}>
              <h2 style={{ margin: 0 }}>👤 User Details</h2>
              <button
                onClick={() => setShowModal(false)}
                style={{
                  background: 'none',
                  border: 'none',
                  fontSize: '1.5rem',
                  cursor: 'pointer',
                  color: '#88844D',
                  padding: '0',
                  width: '30px',
                  height: '30px'
                }}
              >
                ×
              </button>
            </div>

            <div style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
              <div style={{ background: 'white', padding: '1rem', borderRadius: '8px' }}>
                <div style={{ fontWeight: '600', color: '#88844D', marginBottom: '0.5rem' }}>User ID</div>
                <div style={{ fontSize: '0.85rem', color: '#666' }}>{selectedUser._id}</div>
              </div>

              <div style={{ background: 'white', padding: '1rem', borderRadius: '8px' }}>
                <div style={{ fontWeight: '600', color: '#88844D', marginBottom: '0.5rem' }}>Name</div>
                <div>{selectedUser.name}</div>
              </div>

              <div style={{ background: 'white', padding: '1rem', borderRadius: '8px' }}>
                <div style={{ fontWeight: '600', color: '#88844D', marginBottom: '0.5rem' }}>Email</div>
                <div>{selectedUser.email}</div>
              </div>

              <div style={{ background: 'white', padding: '1rem', borderRadius: '8px' }}>
                <div style={{ fontWeight: '600', color: '#88844D', marginBottom: '0.5rem' }}>Role</div>
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

              <div style={{ background: 'white', padding: '1rem', borderRadius: '8px' }}>
                <div style={{ fontWeight: '600', color: '#88844D', marginBottom: '0.5rem' }}>Status</div>
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

              <div style={{ background: 'white', padding: '1rem', borderRadius: '8px' }}>
                <div style={{ fontWeight: '600', color: '#88844D', marginBottom: '0.5rem' }}>Gems (Points)</div>
                <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                  <Award size={20} color="#88844D" />
                  <strong style={{ fontSize: '1.25rem' }}>{selectedUser.points} Gems</strong>
                </div>
              </div>

              <div style={{ background: 'white', padding: '1rem', borderRadius: '8px' }}>
                <div style={{ fontWeight: '600', color: '#88844D', marginBottom: '0.5rem' }}>Activity Summary</div>
                <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '1rem', marginTop: '0.5rem' }}>
                  <div style={{ textAlign: 'center', padding: '0.5rem', background: '#F7F2E4', borderRadius: '6px' }}>
                    <div style={{ fontSize: '1.5rem', fontWeight: 'bold', color: '#88844D' }}>{selectedUser.listings}</div>
                    <div style={{ fontSize: '0.85rem', color: '#666' }}>Listings</div>
                  </div>
                  <div style={{ textAlign: 'center', padding: '0.5rem', background: '#F7F2E4', borderRadius: '6px' }}>
                    <div style={{ fontSize: '1.5rem', fontWeight: 'bold', color: '#88844D' }}>{selectedUser.claims}</div>
                    <div style={{ fontSize: '0.85rem', color: '#666' }}>Claims</div>
                  </div>
                </div>
              </div>

              <div style={{ background: 'white', padding: '1rem', borderRadius: '8px' }}>
                <div style={{ fontWeight: '600', color: '#88844D', marginBottom: '0.5rem' }}>Account Created</div>
                <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                  <Calendar size={16} color="#88844D" />
                  {formatDate(selectedUser.createdAt)}
                </div>
              </div>

              {selectedUser.lastActive && (
                <div style={{ background: 'white', padding: '1rem', borderRadius: '8px' }}>
                  <div style={{ fontWeight: '600', color: '#88844D', marginBottom: '0.5rem' }}>Last Active</div>
                  <div>{getTimeAgo(selectedUser.lastActive)}</div>
                </div>
              )}

              <div style={{ background: 'white', padding: '1rem', borderRadius: '8px' }}>
                <div style={{ fontWeight: '600', color: '#88844D', marginBottom: '0.5rem' }}>Email Verification</div>
                <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                  {selectedUser.verified ? (
                    <>
                      <CheckCircle size={16} color="#22c55e" />
                      <span style={{ color: '#22c55e', fontWeight: '600' }}>Verified</span>
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

            <div style={{ marginTop: '1.5rem', display: 'flex', gap: '0.5rem' }}>
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
                    gap: '0.5rem'
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
                    background: '#22c55e',
                    color: 'white',
                    border: 'none',
                    borderRadius: '8px',
                    fontWeight: '600',
                    cursor: 'pointer',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    gap: '0.5rem'
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
                  background: '#88844D',
                  color: 'white',
                  border: 'none',
                  borderRadius: '8px',
                  fontWeight: '600',
                  cursor: 'pointer'
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