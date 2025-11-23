import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import AdminLogin from './components/AdminLogin';
import ProtectedRoute from './components/ProtectedRoute';
import ModernAdminDashboard from './components/Dashboard/ModernDashboard';
import UserManagement from './components/UserManagement';
import WasteListing from './components/WasteListing';
import ProductListing from './components/ProductListing';
import PointsManagement from './components/PointsManagement';

function App() {
  return (
    <Router>
      <Routes>
        {/* Public route - no authentication needed */}
        <Route path="/login" element={<AdminLogin />} />
        
        {/* Protected routes - require authentication */}
        <Route path="/" element={
          <ProtectedRoute>
            <ModernAdminDashboard />
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
        <Route path="/points-management" element={
          <ProtectedRoute>
            <PointsManagement/>
          </ProtectedRoute>
        } />
      </Routes>
    </Router>
  );
}

export default App;