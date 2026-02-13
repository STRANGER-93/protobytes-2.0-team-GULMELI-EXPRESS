// frontend/src/components/layout/Header.jsx
import { useState } from 'react';
import { Link, useNavigate, useLocation } from 'react-router-dom';
import { useAuth } from '../../contexts/AuthContext';

export default function Header() {
  const { user, logout } = useAuth();
  const navigate = useNavigate();
  const location = useLocation();
  const [menuOpen, setMenuOpen] = useState(false);

  const handleLogout = () => {
    logout();
    navigate('/login');
  };

  const getRoleLink = () => {
    if (!user) return null;
    if (user.role === 'provider') return { to: '/provider/dashboard', label: 'Dashboard' };
    if (user.role === 'municipality_admin') return { to: '/admin/dashboard', label: 'Dashboard' };
    return { to: '/providers/search', label: 'Find Services' };
  };

  const navLink = getRoleLink();

  return (
    <header style={{
      height: '64px',
      background: 'var(--slate-900)',
      borderBottom: '1px solid var(--slate-700)',
      position: 'sticky',
      top: 0,
      zIndex: 100,
      display: 'flex',
      alignItems: 'center',
    }}>
      <div style={{
        width: '100%',
        maxWidth: '1200px',
        margin: '0 auto',
        padding: '0 var(--space-6)',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'space-between',
      }}>
        {/* Logo */}
        <Link to="/" style={{
          display: 'flex',
          alignItems: 'center',
          gap: 'var(--space-3)',
          textDecoration: 'none',
        }}>
          <div style={{
            width: '32px',
            height: '32px',
            background: 'var(--saffron)',
            borderRadius: 'var(--r-sm)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            fontWeight: 800,
            fontSize: '1rem',
            color: 'white',
            flexShrink: 0,
          }}>
            J
          </div>
          <span style={{
            fontFamily: 'var(--font-sans)',
            fontWeight: 700,
            fontSize: '1.0625rem',
            color: 'white',
            letterSpacing: '-0.02em',
          }}>
            JanSewa
          </span>
          <span style={{
            fontSize: '0.625rem',
            fontWeight: 600,
            letterSpacing: '0.1em',
            textTransform: 'uppercase',
            color: 'var(--slate-400)',
            marginLeft: '-var(--space-1)',
          }}>
            Municipal
          </span>
        </Link>

        {/* Nav */}
        <nav style={{ display: 'flex', alignItems: 'center', gap: 'var(--space-4)' }}>
          {user ? (
            <>
              {navLink && (
                <Link to={navLink.to} style={{
                  color: location.pathname.startsWith(navLink.to) ? 'var(--saffron)' : 'var(--slate-300)',
                  fontWeight: 500,
                  fontSize: '0.9375rem',
                  textDecoration: 'none',
                  transition: 'color var(--t-fast)',
                }}>
                  {navLink.label}
                </Link>
              )}
              <Link to="/bookings" style={{
                color: location.pathname.startsWith('/bookings') ? 'var(--saffron)' : 'var(--slate-300)',
                fontWeight: 500,
                fontSize: '0.9375rem',
                textDecoration: 'none',
              }}>
                Bookings
              </Link>

              {/* User pill */}
              <div style={{ position: 'relative' }}>
                <button
                  onClick={() => setMenuOpen(!menuOpen)}
                  style={{
                    display: 'flex',
                    alignItems: 'center',
                    gap: 'var(--space-2)',
                    background: 'var(--slate-800)',
                    border: '1px solid var(--slate-600)',
                    borderRadius: 'var(--r-pill)',
                    padding: '6px var(--space-4) 6px var(--space-2)',
                    cursor: 'pointer',
                    color: 'white',
                    fontSize: '0.875rem',
                    fontWeight: 500,
                    transition: 'all var(--t-fast)',
                  }}
                >
                  <div style={{
                    width: '24px',
                    height: '24px',
                    borderRadius: '50%',
                    background: 'var(--saffron)',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    fontSize: '0.75rem',
                    fontWeight: 700,
                    color: 'white',
                    flexShrink: 0,
                  }}>
                    {user.name?.charAt(0).toUpperCase()}
                  </div>
                  <span style={{ maxWidth: '120px', overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
                    {user.name?.split(' ')[0]}
                  </span>
                  <span style={{ fontSize: '0.625rem', opacity: 0.6 }}>▼</span>
                </button>

                {menuOpen && (
                  <div style={{
                    position: 'absolute',
                    top: 'calc(100% + 8px)',
                    right: 0,
                    background: 'white',
                    border: '1px solid var(--border)',
                    borderRadius: 'var(--r-lg)',
                    boxShadow: 'var(--shadow-lg)',
                    minWidth: '180px',
                    overflow: 'hidden',
                    zIndex: 200,
                  }}>
                    <div style={{ padding: 'var(--space-3) var(--space-4)', borderBottom: '1px solid var(--border)' }}>
                      <div style={{ fontWeight: 600, fontSize: '0.875rem', color: 'var(--slate-800)' }}>{user.name}</div>
                      <div style={{ fontSize: '0.75rem', color: 'var(--text-muted)', textTransform: 'capitalize' }}>{user.role?.replace('_', ' ')}</div>
                    </div>
                    <Link to="/profile" onClick={() => setMenuOpen(false)} style={{
                      display: 'block',
                      padding: 'var(--space-3) var(--space-4)',
                      fontSize: '0.9rem',
                      color: 'var(--text)',
                      textDecoration: 'none',
                      transition: 'background var(--t-fast)',
                    }}
                    onMouseEnter={e => e.target.style.background = 'var(--slate-50)'}
                    onMouseLeave={e => e.target.style.background = 'transparent'}
                    >
                      Profile
                    </Link>
                    <button
                      onClick={() => { setMenuOpen(false); handleLogout(); }}
                      style={{
                        display: 'block',
                        width: '100%',
                        textAlign: 'left',
                        padding: 'var(--space-3) var(--space-4)',
                        fontSize: '0.9rem',
                        color: 'var(--danger)',
                        background: 'none',
                        border: 'none',
                        borderTop: '1px solid var(--border)',
                        cursor: 'pointer',
                        transition: 'background var(--t-fast)',
                      }}
                      onMouseEnter={e => e.target.style.background = 'var(--danger-light)'}
                      onMouseLeave={e => e.target.style.background = 'transparent'}
                    >
                      Sign out
                    </button>
                  </div>
                )}
              </div>
            </>
          ) : (
            <>
              <Link to="/login" style={{
                color: 'var(--slate-300)',
                fontWeight: 500,
                fontSize: '0.9375rem',
                textDecoration: 'none',
              }}>
                Login
              </Link>
              <Link to="/register" style={{
                background: 'var(--saffron)',
                color: 'white',
                fontWeight: 600,
                fontSize: '0.875rem',
                padding: '8px 18px',
                borderRadius: 'var(--r-md)',
                textDecoration: 'none',
              }}>
                Register
              </Link>
            </>
          )}
        </nav>
      </div>
      {/* Overlay */}
      {menuOpen && (
        <div
          style={{ position: 'fixed', inset: 0, zIndex: 99 }}
          onClick={() => setMenuOpen(false)}
        />
      )}
    </header>
  );
}
