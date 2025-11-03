import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import Login from './pages/Login';
import Dashboard from './components/Layout/Dashboard';
import './App.css';

function App() {
  const isAuthenticated = !!localStorage.getItem('adminToken');

  return (
    <Router>
      <div className="App">
        <h1>Junk and Gems Admin Dashboard</h1>
        <p>Welcome to the admin dashboard!</p>
        <Routes>
          <Route 
            path="/login" 
            element={isAuthenticated ? <Navigate to="/" /> : <Login />} 
          />
          <Route 
            path="/*" 
            element={isAuthenticated ? <Dashboard /> : <Navigate to="/login" />} 
          />
        </Routes>
      </div>
    </Router>
  );
}

export default App;