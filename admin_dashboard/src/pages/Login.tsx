import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { currentAPI } from '../services/api';
import styles from './Login.module.css';

const Login: React.FC = () => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const navigate = useNavigate();

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError('');

    try {
      console.log('Attempting login with:', { email });
      const response = await currentAPI.login({ email, password });
      console.log('Login response:', response);
      
      const token = response.data.token;
      
      if (token) {
        localStorage.setItem('adminToken', token);
        console.log('Token stored, redirecting to dashboard...');
        
        // Force navigation to dashboard
        window.location.href = '/';
      } else {
        console.error('No token found in response');
        setError('Login successful but no token received');
      }
    } catch (err: any) {
      console.error('Login error:', err);
      setError(err.response?.data?.message || err.response?.data?.error || 'Login failed - check credentials');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className={styles.loginContainer}>
      <div className={styles.loginCard}>
        <h1>Admin Dashboard</h1>
        <h2>Junk & Gems</h2>

        <form onSubmit={handleLogin} className={styles.loginForm}>
          {error && <div className={styles.error}>{error}</div>}
          
          <div className={styles.formGroup}>
            <label>Email</label>
            <input
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              placeholder="Enter admin email"
              required
            />
          </div>
          
          <div className={styles.formGroup}>
            <label>Password</label>
            <input
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              placeholder="Enter password"
              required
            />
          </div>
          
          <button type="submit" disabled={loading} className={styles.loginBtn}>
            {loading ? 'Logging in...' : 'Login'}
          </button>
        </form>

        <div className={styles.debugInfo}>
          <p><strong>Backend:</strong> https://junk-and-gems-api.onrender.com</p>
        </div>
      </div>
    </div>
  );
};

export default Login;