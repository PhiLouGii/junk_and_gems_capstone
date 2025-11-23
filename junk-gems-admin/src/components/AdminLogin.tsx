import React, { useState } from 'react';
import { Lock, Mail, AlertCircle, Moon, Sun } from 'lucide-react';
import axios from 'axios';

const AdminLogin: React.FC = () => {
  const [theme, setTheme] = useState(() => localStorage.getItem('theme') || 'light');
  const isDark = theme === 'dark';
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const API_BASE_URL = 'https://junk-and-gems-api.onrender.com';

  const colors = {
    background: isDark ? 'linear-gradient(135deg, #1a1a1a 0%, #2d2d2d 100%)' : 'linear-gradient(135deg, #F7F2E4 0%, #E4E5C2 100%)',
    cardBg: isDark ? '#2d2d2d' : 'white',
    text: isDark ? '#e5e7eb' : '#1f2937',
    textSecondary: isDark ? '#9ca3af' : '#666',
    border: isDark ? '#404040' : '#BEC092',
    inputBg: isDark ? '#1a1a1a' : 'white',
    infoBg: isDark ? '#262626' : '#F7F2E4',
    primary: '#88844D'
  };

  const toggleTheme = () => {
    const newTheme = theme === 'light' ? 'dark' : 'light';
    setTheme(newTheme);
    localStorage.setItem('theme', newTheme);
  };

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError('');

    try {
      const response = await axios.post(`${API_BASE_URL}/login`, {
        email,
        password
      });

      const token = response.data.token;
      const user = response.data.user;

      if (token) {
        localStorage.setItem('token', token);
        
        if (user) {
          localStorage.setItem('user', JSON.stringify(user));
        }

        alert('Login successful! Redirecting to dashboard...');
        window.location.href = '/';
      } else {
        setError('Login successful but no token received. Please contact support.');
      }
    } catch (err) {
      console.error('Login error:', err);
      
      if (axios.isAxiosError(err)) {
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
      position: 'fixed',
      top: 0,
      left: 0,
      right: 0,
      bottom: 0,
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      background: colors.background,
      padding: '1rem',
      transition: 'background 0.3s ease'
    }}>
      <div style={{
        background: colors.cardBg,
        borderRadius: '12px',
        padding: 'clamp(1.5rem, 4vw, 2.5rem)',
        width: '100%',
        maxWidth: '420px',
        boxShadow: isDark ? '0 20px 40px rgba(0, 0, 0, 0.5)' : '0 20px 40px rgba(0, 0, 0, 0.1)',
        transition: 'all 0.3s ease'
      }}>
        {/* Theme Toggle */}
        <div style={{ display: 'flex', justifyContent: 'flex-end', marginBottom: '1rem' }}>
          <button
            onClick={toggleTheme}
            style={{
              padding: '0.5rem',
              background: colors.infoBg,
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

        {/* Logo/Header */}
        <div style={{ textAlign: 'center', marginBottom: '2rem' }}>
          <div style={{
            width: '80px',
            height: '80px',
            margin: '0 auto 1rem',
            background: colors.primary,
            borderRadius: '50%',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            overflow: 'hidden'
          }}>
            <img 
              src="/logo.jpg"
              alt="Junk & Gems Logo" 
              style={{
                width: '100%',
                height: '100%',
                objectFit: 'cover'
              }}
              onError={(e) => {
                e.currentTarget.style.display = 'none';
                if (e.currentTarget.parentElement) {
                  e.currentTarget.parentElement.innerHTML = '<span style="font-size: 2.5rem">🌍</span>';
                }
              }}
            />
          </div>
          <h1 style={{ 
            color: colors.text, 
            margin: '0 0 0.5rem 0',
            fontSize: 'clamp(1.5rem, 4vw, 1.75rem)',
            transition: 'color 0.3s ease'
          }}>
            Junk & Gems
          </h1>
          <p style={{ 
            color: colors.textSecondary, 
            fontSize: 'clamp(0.875rem, 2vw, 0.95rem)', 
            margin: 0,
            transition: 'color 0.3s ease'
          }}>
            Admin Dashboard Login
          </p>
        </div>

        {/* Error Message */}
        {error && (
          <div style={{
            background: isDark ? '#4c1d1d' : '#fee2e2',
            border: '2px solid #ef4444',
            borderRadius: '8px',
            padding: '1rem',
            marginBottom: '1.5rem',
            display: 'flex',
            alignItems: 'center',
            color: isDark ? '#fca5a5' : '#991b1b'
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
              color: colors.primary,
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
                color: colors.primary 
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
                  border: '2px solid ' + colors.border,
                  borderRadius: '8px',
                  fontSize: '0.95rem',
                  outline: 'none',
                  transition: 'border-color 0.2s',
                  boxSizing: 'border-box',
                  background: colors.inputBg,
                  color: colors.text
                }}
                onFocus={(e) => e.target.style.borderColor = colors.primary}
                onBlur={(e) => e.target.style.borderColor = colors.border}
              />
            </div>
          </div>

          <div style={{ marginBottom: '1.5rem' }}>
            <label style={{ 
              display: 'block', 
              marginBottom: '0.5rem', 
              fontWeight: '600',
              color: colors.primary,
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
                color: colors.primary 
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
                  border: '2px solid ' + colors.border,
                  borderRadius: '8px',
                  fontSize: '0.95rem',
                  outline: 'none',
                  transition: 'border-color 0.2s',
                  boxSizing: 'border-box',
                  background: colors.inputBg,
                  color: colors.text
                }}
                onFocus={(e) => e.target.style.borderColor = colors.primary}
                onBlur={(e) => e.target.style.borderColor = colors.border}
              />
            </div>
          </div>

          <button
            type="submit"
            disabled={loading}
            style={{
              width: '100%',
              padding: '0.875rem',
              background: loading ? '#BEC092' : colors.primary,
              color: 'white',
              border: 'none',
              borderRadius: '8px',
              fontSize: 'clamp(0.95rem, 2vw, 1rem)',
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
              if (!loading) e.currentTarget.style.background = colors.primary;
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

        {/* Info Box */}
        <div style={{
          marginTop: '2rem',
          padding: '1rem',
          background: colors.infoBg,
          borderRadius: '8px',
          fontSize: 'clamp(0.8rem, 2vw, 0.85rem)',
          color: colors.textSecondary,
          textAlign: 'center',
          transition: 'all 0.3s ease'
        }}>
          <strong style={{ color: colors.text }}>Admin Access Only</strong><br />
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