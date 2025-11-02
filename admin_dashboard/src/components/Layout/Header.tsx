import React from 'react';
import { useNavigate } from 'react-router-dom';
import styles from './Header.module.css';

const Header: React.FC = () => {
  const navigate = useNavigate();

  const handleLogout = () => {
    // Clear token
    localStorage.removeItem('adminToken');
    
    // Redirect to login
    navigate('/login');
  };

  return (
    <header className={styles.header}>
      <div className={styles.headerContent}>
        <h1>Admin Dashboard</h1>
        <div className={styles.headerActions}>
          <span>Welcome, Admin</span>
          <button onClick={handleLogout} className={styles.logoutBtn}>
        Logout
      </button>
        </div>
      </div>
    </header>
  );
};

export default Header;