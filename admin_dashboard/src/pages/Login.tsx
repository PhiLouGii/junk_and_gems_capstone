import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { currentAPI } from '../services/api';
import styles from './Login.module.css';
import axios from 'axios';

const Login: React.FC = () => {
  const [email, setEmail] = useState('admin@junkandgems.com');
  const [password, setPassword] = useState('admin123');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const navigate = useNavigate();

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError('');

    try {
      const response = await currentAPI.login({ email, password });
      // Store the token - adjust based on your API response
      const token = response.data.token || response.data.accessToken;
      if (token) {
        localStorage.setItem('adminToken', token);
        navigate('/');
      } else {
        setError('No token received from server');
      }
    } catch (err: any) {
      setError(err.response?.data?.message || err.response?.data?.error || 'Login failed');
      console.error('Login error:', err);
    } finally {
      setLoading(false);
    }
  };

  const testConnection = async () => {
    try {
      const response = await axios.get('https://junk-and-gems-api.onrender.com');
      console.log('Backend connection successful:', response.data);
      alert('Backend is connected! Check console for details.');
    } catch (error) {
      console.error('Backend connection failed:', error);
      alert('Backend connection failed. Check console for details.');
    }
  };

  return (
    <div className={styles.loginContainer}>
      <div className={styles.loginCard}>
        <h1>Admin Dashboard</h1>
        <h2>Junk & Gems</h2>
        
        <button onClick={testConnection} className={styles.testBtn} type="button">
          Test Backend Connection
        </button>

        <form onSubmit={handleLogin} className={styles.loginForm}>
          {error && <div className={styles.error}>{error}</div>}
          <div className={styles.formGroup}>
            <label>Email</label>
            <input
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
            />
          </div>
          <div className={styles.formGroup}>
            <label>Password</label>
            <input
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
            />
          </div>
          <button type="submit" disabled={loading}>
            {loading ? 'Logging in...' : 'Login'}
          </button>
        </form>
      </div>
    </div>
  );
};

export default Login;