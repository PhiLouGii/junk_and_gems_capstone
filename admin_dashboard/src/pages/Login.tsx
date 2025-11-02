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

  const createAdminUser = async () => {
  try {
    console.log('Attempting to create admin user...');
    const signupData = {
      email: 'admin@junkandgems.com',
      password: 'admin123',
      name: 'Admin User',
      role: 'admin'
    };
    
    const response = await currentAPI.signup(signupData);
    console.log('Signup response:', response);
    alert('Admin user created! Try logging in now.');
  } catch (err: any) {
    console.error('Signup error:', err);
    alert(`Signup failed: ${err.response?.data?.message || err.message}`);
  }
};

// Add this button to the JSX, before the form:
<button type="button" onClick={createAdminUser} className={styles.createAdminBtn}>
  Create Admin User (First Time Setup)
</button>

  const handleLogin = async (e: React.FormEvent) => {
  e.preventDefault();
  setLoading(true);
  setError('');

  try {
    console.log('Attempting login with:', { email, password });
    const response = await currentAPI.login({ email, password });
    console.log('Login response:', response);
    
    const token = response.data.token;
    
    if (token) {
      localStorage.setItem('adminToken', token);
      console.log('Login successful, redirecting to dashboard...');
      
      // Redirect to root path (dashboard)
      navigate('/');
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

  // Common admin credentials to try
  const tryCommonCredentials = (type: string) => {
    switch(type) {
      case 'admin':
        setEmail('admin@junkandgems.com');
        setPassword('admin123');
        break;
      case 'test':
        setEmail('test@test.com');
        setPassword('test123');
        break;
      case 'demo':
        setEmail('demo@junkandgems.com');
        setPassword('demo123');
        break;
    }
  };

  return (
    <div className={styles.loginContainer}>
      <div className={styles.loginCard}>
        <h1>Admin Dashboard</h1>
        <h2>Junk & Gems</h2>
        
        <div className={styles.credentialButtons}>
          <p>Try common credentials:</p>
          <button type="button" onClick={() => tryCommonCredentials('admin')} className={styles.credentialBtn}>
            Admin Credentials
          </button>
          <button type="button" onClick={() => tryCommonCredentials('test')} className={styles.credentialBtn}>
            Test Credentials  
          </button>
          <button type="button" onClick={() => tryCommonCredentials('demo')} className={styles.credentialBtn}>
            Demo Credentials
          </button>
        </div>

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
          <p><strong>If login fails:</strong> Check that admin users exist in your database</p>
        </div>
      </div>
    </div>
  );
};

export default Login;