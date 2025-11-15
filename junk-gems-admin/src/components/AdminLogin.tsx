import React, { useState } from 'react';
import { Lock, Mail, AlertCircle } from 'lucide-react';
import axios from 'axios';

const AdminLogin: React.FC = () => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const API_BASE_URL = 'https://junk-and-gems-api.onrender.com';

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError('');

    try {
      // Your backend uses /login endpoint
      const response = await axios.post(`${API_BASE_URL}/login`, {
        email,
        password
      });

      console.log('Login response:', response.data);

      // Your backend returns: { message, token, user }
      const token = response.data.token;
      const user = response.data.user;

      if (token) {
        // Store token in localStorage
        localStorage.setItem('token', token);
        
        // Store user info if available
        if (user) {
          localStorage.setItem('user', JSON.stringify(user));
        }

        // Show success message
        alert('Login successful! Redirecting to dashboard...');

        // Redirect to dashboard
        window.location.href = '/';
      } else {
        setError('Login successful but no token received. Please contact support.');
        console.error('No token in response:', response.data);
      }
    } catch (err) {
      console.error('Login error:', err);
      
      if (axios.isAxiosError(err)) {
        console.error('Error response:', err.response?.data);
        console.error('Error status:', err.response?.status);
        
        if (err.response?.status === 400) {
          setError(err.response.data.error || 'Invalid email or password.');
        } else if (err.response?.status === 401) {
          setError('Invalid email or password.');
        } else if (err.response?.status === 403) {
          setError('Access denied. Admin privileges required.');
        } else if (err.response?.status === 404) {
          setError('Login endpoint not found. Please check the API URL.');
        } else if (err.response?.data?.error) {
          setError(err.response.data.error);
        } else if (err.message === 'Network Error') {
          setError('Cannot connect to server. Please check if the API is running.');
        } else {
          setError('Login failed. Please check your connection and try again.');
        }
      } else {
        setError('An unexpected error occurred.');
      }
    } finally {
      setLoading(false);
    }
  };

  return (
    <div style={{
      minHeight: '100vh',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      background: 'linear-gradient(135deg, #F7F2E4 0%, #E4E5C2 100%)',
      padding: '1rem'
    }}>
      <div style={{
        background: 'white',
        borderRadius: '12px',
        padding: '2rem',
        maxWidth: '400px',
        width: '100%',
        boxShadow: '0 20px 40px rgba(0, 0, 0, 0.1)'
      }}>
        {/* Logo/Header */}
        <div style={{ textAlign: 'center', marginBottom: '2rem' }}>
          <div style={{
            width: '80px',
            height: '80px',
            margin: '0 auto 1rem',
            background: '#88844D',
            borderRadius: '50%',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            fontSize: '2.5rem'
          }}>
            🌍
          </div>
          <h1 style={{ color: '#88844D', margin: '0 0 0.5rem 0' }}>Junk & Gems</h1>
          <p style={{ color: '#666', fontSize: '0.95rem', margin: 0 }}>Admin Dashboard Login</p>
        </div>

        {/* Error Message */}
        {error && (
          <div style={{
            background: '#fee2e2',
            border: '2px solid #ef4444',
            borderRadius: '8px',
            padding: '1rem',
            marginBottom: '1.5rem',
            display: 'flex',
            alignItems: 'center',
            color: '#991b1b'
          }}>
            <AlertCircle size={20} style={{ marginRight: '12px', flexShrink: 0 }} />
            <div style={{ fontSize: '0.9rem' }}>{error}</div>
          </div>
        )}

        {/* Login Form */}
        <form onSubmit={handleLogin}>
          <div style={{ marginBottom: '1.5rem' }}>
            <label style={{ 
              display: 'block', 
              marginBottom: '0.5rem', 
              fontWeight: '600',
              color: '#88844D',
              fontSize: '0.9rem'
            }}>
              Email Address
            </label>
            <div style={{ position: 'relative' }}>
              <Mail size={20} style={{ 
                position: 'absolute', 
                left: '12px', 
                top: '50%', 
                transform: 'translateY(-50%)', 
                color: '#88844D' 
              }} />
              <input
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
                placeholder="admin@example.com"
                style={{
                  width: '100%',
                  padding: '0.75rem 1rem 0.75rem 2.5rem',
                  border: '2px solid #BEC092',
                  borderRadius: '8px',
                  fontSize: '0.95rem',
                  outline: 'none',
                  transition: 'border-color 0.2s',
                  boxSizing: 'border-box'
                }}
                onFocus={(e) => e.target.style.borderColor = '#88844D'}
                onBlur={(e) => e.target.style.borderColor = '#BEC092'}
              />
            </div>
          </div>

          <div style={{ marginBottom: '1.5rem' }}>
            <label style={{ 
              display: 'block', 
              marginBottom: '0.5rem', 
              fontWeight: '600',
              color: '#88844D',
              fontSize: '0.9rem'
            }}>
              Password
            </label>
            <div style={{ position: 'relative' }}>
              <Lock size={20} style={{ 
                position: 'absolute', 
                left: '12px', 
                top: '50%', 
                transform: 'translateY(-50%)', 
                color: '#88844D' 
              }} />
              <input
                type="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                required
                placeholder="Enter your password"
                style={{
                  width: '100%',
                  padding: '0.75rem 1rem 0.75rem 2.5rem',
                  border: '2px solid #BEC092',
                  borderRadius: '8px',
                  fontSize: '0.95rem',
                  outline: 'none',
                  transition: 'border-color 0.2s',
                  boxSizing: 'border-box'
                }}
                onFocus={(e) => e.target.style.borderColor = '#88844D'}
                onBlur={(e) => e.target.style.borderColor = '#BEC092'}
              />
            </div>
          </div>

          <button
            type="submit"
            disabled={loading}
            style={{
              width: '100%',
              padding: '0.875rem',
              background: loading ? '#BEC092' : '#88844D',
              color: 'white',
              border: 'none',
              borderRadius: '8px',
              fontSize: '1rem',
              fontWeight: '600',
              cursor: loading ? 'not-allowed' : 'pointer',
              transition: 'all 0.2s',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              gap: '0.5rem'
            }}
            onMouseEnter={(e) => {
              if (!loading) e.currentTarget.style.background = '#6d6a3d';
            }}
            onMouseLeave={(e) => {
              if (!loading) e.currentTarget.style.background = '#88844D';
            }}
          >
            {loading ? (
              <>
                <div style={{
                  width: '16px',
                  height: '16px',
                  border: '2px solid white',
                  borderTop: '2px solid transparent',
                  borderRadius: '50%',
                  animation: 'spin 0.8s linear infinite'
                }} />
                Logging in...
              </>
            ) : (
              'Login to Dashboard'
            )}
          </button>
        </form>

        {/* Development Mode - Skip Login */}
        <div style={{ marginTop: '1rem', textAlign: 'center' }}>
          <button
            onClick={async () => {
              // For development - try to get a real token with admin email
              try {
                const response = await axios.post(`${API_BASE_URL}/login`, {
                  email: 'admin@junkandgems.com',
                  password: 'admin123' // Update this to your actual password
                });
                
                const token = response.data.token;
                const user = response.data.user;
                
                if (token) {
                  localStorage.setItem('token', token);
                  if (user) {
                    localStorage.setItem('user', JSON.stringify(user));
                  }
                  alert('Dev mode: Logged in as admin@junkandgems.com');
                  window.location.href = '/';
                } else {
                  alert('Dev mode failed. Try logging in manually with admin@junkandgems.com');
                }
              } catch (err) {
                console.error('Dev login error:', err);
                if (axios.isAxiosError(err) && err.response?.data?.error) {
                  alert(`Dev mode failed: ${err.response.data.error}`);
                } else {
                  alert('Dev mode failed. Make sure you have updated a user email to admin@junkandgems.com in the database.');
                }
              }
            }}
            style={{
              padding: '0.5rem 1rem',
              background: 'transparent',
              color: '#88844D',
              border: '2px solid #88844D',
              borderRadius: '8px',
              fontSize: '0.85rem',
              fontWeight: '600',
              cursor: 'pointer',
              transition: 'all 0.2s'
            }}
            onMouseEnter={(e) => {
              e.currentTarget.style.background = '#88844D';
              e.currentTarget.style.color = 'white';
            }}
            onMouseLeave={(e) => {
              e.currentTarget.style.background = 'transparent';
              e.currentTarget.style.color = '#88844D';
            }}
          >
            🔧 Skip Login (Dev Mode)
          </button>
        </div>

        {/* Info Box */}
        <div style={{
          marginTop: '2rem',
          padding: '1rem',
          background: '#F7F2E4',
          borderRadius: '8px',
          fontSize: '0.85rem',
          color: '#666',
          textAlign: 'center'
        }}>
          <strong>Admin Access Only</strong><br />
          Contact support if you need admin credentials
        </div>

        <style>{`
          @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
          }
        `}</style>
      </div>
    </div>
  );
};

export default AdminLogin;