import React from 'react';
import { Routes, Route } from 'react-router-dom';
import Sidebar from './Sidebar';
import Header from './Header';
import DashboardHome from '../../pages/DashboardHome';
import UserManagement from '../../pages/UserManagement';
import WasteListings from '../../pages/WasteListings';
import Transactions from '../../pages/Transactions';
import PointSystem from '../../pages/PointSystem';
import Security from '../../pages/Security';
import styles from './Dashboard.module.css';

const Dashboard: React.FC = () => {
  return (
    <div className={styles.dashboard}>
      <Sidebar />
      <div className={styles.mainContent}>
        <Header />
        <div className={styles.content}>
          <Routes>
            <Route path="/" element={<DashboardHome />} />
            <Route path="/users" element={<UserManagement />} />
            <Route path="/listings" element={<WasteListings />} />
            <Route path="/transactions" element={<Transactions />} />
            <Route path="/points" element={<PointSystem />} />
            <Route path="/security" element={<Security />} />
          </Routes>
        </div>
      </div>
    </div>
  );
};

export default Dashboard;