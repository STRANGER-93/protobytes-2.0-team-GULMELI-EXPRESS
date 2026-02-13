// frontend/src/App.jsx
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider, useAuth } from './contexts/AuthContext';

// Layout
import Header from './components/layout/Header';
import Footer from './components/layout/Footer';

// Common
import LoadingSpinner from './components/common/LoadingSpinner';

// Pages
import Login from './pages/Auth/Login';
import Register from './pages/Auth/Register';
import Home from './pages/Home';
import ProviderOnboarding from './pages/ProviderOnboarding';
import ProviderSearch from './pages/ProviderSearch';
import ProviderDetail from './pages/ProviderDetail';
import CreateBooking from './pages/CreateBooking';
import MyBookings from './pages/MyBookings';
import BookingDetail from './pages/BookingDetail';
import ProviderDashboard from './pages/ProviderDashboard';
import MunicipalDashboard from './pages/MunicipalDashboard';
import Profile from './pages/Profile';

// ── Route Guards ────────────────────────────────────────

function ProtectedRoute({ children, allowedRoles = [] }) {
  const { user, loading } = useAuth();

  if (loading) return <LoadingSpinner />;
  if (!user) return <Navigate to="/login" replace />;
  if (allowedRoles.length > 0 && !allowedRoles.includes(user.role)) {
    return <Navigate to="/" replace />;
  }
  return children;
}

function PublicOnlyRoute({ children }) {
  const { user, loading } = useAuth();
  if (loading) return <LoadingSpinner />;
  if (user) return <Navigate to="/" replace />;
  return children;
}

// ── Layout wrapper ───────────────────────────────────────

function AppLayout({ children }) {
  return (
    <div style={{ display: 'flex', flexDirection: 'column', minHeight: '100vh' }}>
      <Header />
      <main style={{ flex: 1 }}>{children}</main>
      <Footer />
    </div>
  );
}

// Auth pages use a different layout (no header/footer)
function AuthLayout({ children }) {
  return <>{children}</>;
}

// ── Routes ───────────────────────────────────────────────

function AppRoutes() {
  return (
    <Routes>
      {/* ── Auth (no header) ── */}
      <Route path="/login" element={
        <AuthLayout>
          <PublicOnlyRoute><Login /></PublicOnlyRoute>
        </AuthLayout>
      } />
      <Route path="/register" element={
        <AuthLayout>
          <PublicOnlyRoute><Register /></PublicOnlyRoute>
        </AuthLayout>
      } />

      {/* ── Home (public + authenticated) ── */}
      <Route path="/" element={
        <AppLayout>
          <Home />
        </AppLayout>
      } />

      {/* ── Provider routes ── */}
      <Route path="/provider/onboarding" element={
        <AppLayout>
          <ProtectedRoute allowedRoles={['provider']}>
            <ProviderOnboarding />
          </ProtectedRoute>
        </AppLayout>
      } />

      <Route path="/provider/dashboard" element={
        <AppLayout>
          <ProtectedRoute allowedRoles={['provider']}>
            <ProviderDashboard />
          </ProtectedRoute>
        </AppLayout>
      } />

      <Route path="/provider/bookings" element={
        <AppLayout>
          <ProtectedRoute allowedRoles={['provider']}>
            <MyBookings />
          </ProtectedRoute>
        </AppLayout>
      } />

      {/* ── Provider search (citizen & admin can view) ── */}
      <Route path="/providers/search" element={
        <AppLayout>
          <ProtectedRoute>
            <ProviderSearch />
          </ProtectedRoute>
        </AppLayout>
      } />

      <Route path="/providers/:id" element={
        <AppLayout>
          <ProtectedRoute>
            <ProviderDetail />
          </ProtectedRoute>
        </AppLayout>
      } />

      {/* ── Citizen booking routes ── */}
      <Route path="/bookings/create" element={
        <AppLayout>
          <ProtectedRoute allowedRoles={['citizen']}>
            <CreateBooking />
          </ProtectedRoute>
        </AppLayout>
      } />

      <Route path="/bookings" element={
        <AppLayout>
          <ProtectedRoute>
            <MyBookings />
          </ProtectedRoute>
        </AppLayout>
      } />

      <Route path="/bookings/:id" element={
        <AppLayout>
          <ProtectedRoute>
            <BookingDetail />
          </ProtectedRoute>
        </AppLayout>
      } />

      {/* ── Municipality admin ── */}
      <Route path="/admin/dashboard" element={
        <AppLayout>
          <ProtectedRoute allowedRoles={['municipality_admin']}>
            <MunicipalDashboard />
          </ProtectedRoute>
        </AppLayout>
      } />

      <Route path="/admin/providers" element={
        <AppLayout>
          <ProtectedRoute allowedRoles={['municipality_admin']}>
            <MunicipalDashboard />
          </ProtectedRoute>
        </AppLayout>
      } />

      {/* ── Profile ── */}
      <Route path="/profile" element={
        <AppLayout>
          <ProtectedRoute>
            <Profile />
          </ProtectedRoute>
        </AppLayout>
      } />

      {/* ── Catch all ── */}
      <Route path="*" element={<Navigate to="/" replace />} />
    </Routes>
  );
}

export default function App() {
  return (
    <Router>
      <AuthProvider>
        <AppRoutes />
      </AuthProvider>
    </Router>
  );
}
