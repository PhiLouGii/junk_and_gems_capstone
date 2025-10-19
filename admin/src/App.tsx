import React from 'react';
import { Login } from './pages/Login';
import { Dashboard } from './pages/Dashboard';
import { useAuth } from './hooks/useAuth';
import styles from './App.module.css';

const App: React.FC = () => {
  const { isAuthenticated, loading } = useAuth();

  if (loading) {
    return <div className={styles.loading}>Loading...</div>;
  }

  return isAuthenticated ? <Dashboard /> : <Login />;
};

export default App;