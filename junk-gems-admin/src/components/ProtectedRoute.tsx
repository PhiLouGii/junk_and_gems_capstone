import { Navigate } from 'react-router-dom';

interface ProtectedRouteProps {
  children: React.ReactNode;
}

const ProtectedRoute: React.FC<ProtectedRouteProps> = ({ children }) => {
  const token = localStorage.getItem('token');
  
  if (!token) {
    // Redirect to login if no token found
    return <Navigate to="/login" replace />;
  }
  
  // Render the protected component if token exists
  return <>{children}</>;
};

export default ProtectedRoute;