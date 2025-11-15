import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import AdminLogin from './components/AdminLogin';
import ProtectedRoute from './components/ProtectedRoute';
import DashboardHome from './components/DashboardHome';
import UserManagement from './components/UserManagement';
import WasteListing from './components/WasteListing';
import ProductListing from './components/ProductListing';

function App() {
  return (
    <Router>
      <Routes>
        {/* Public route - no authentication needed */}
        <Route path="/login" element={<AdminLogin />} />
        
        {/* Protected routes - require authentication */}
        <Route path="/" element={
          <ProtectedRoute>
            <DashboardHome />
          </ProtectedRoute>
        } />
        
        <Route path="/users" element={
          <ProtectedRoute>
            <UserManagement />
          </ProtectedRoute>
        } />
        <Route path="/waste-listing" element={
          <ProtectedRoute>
            <WasteListing />
          </ProtectedRoute>
        } />
        <Route path="/product-listing" element={
          <ProtectedRoute>
            <ProductListing/>
          </ProtectedRoute>
        } />
      </Routes>
    </Router>
  );
}

export default App;