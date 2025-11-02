import React from 'react';
import { Link, useLocation } from 'react-router-dom';
import styles from './Sidebar.module.css';

const Sidebar: React.FC = () => {
  const location = useLocation();

  const menuItems = [
    { path: '/', label: 'Dashboard', icon: '📊' },
    { path: '/users', label: 'User Management', icon: '👥' },
    { path: '/listings', label: 'Upcycled Products', icon: '🗑️' },
    { path: '/transactions', label: 'Transactions', icon: '💳' },
    { path: '/points', label: 'Point System', icon: '⭐' },
    { path: '/security', label: 'Security', icon: '🔒' },
  ];

  return (
    <div className={styles.sidebar}>
      <div className={styles.logo}>
        <h2>Junk & Gems</h2>
        <span>Admin</span>
      </div>
      <nav className={styles.nav}>
        {menuItems.map((item) => (
          <Link
            key={item.path}
            to={item.path}
            className={`${styles.navItem} ${
              location.pathname === item.path ? styles.active : ''
            }`}
          >
            <span className={styles.icon}>{item.icon}</span>
            <span className={styles.label}>{item.label}</span>
          </Link>
        ))}
      </nav>
    </div>
  );
};

export default Sidebar;