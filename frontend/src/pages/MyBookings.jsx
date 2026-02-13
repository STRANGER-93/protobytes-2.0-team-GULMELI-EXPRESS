// frontend/src/pages/MyBookings.jsx
import { useState, useEffect } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';
import api from '../services/api';
import Card from '../components/common/Card';
import Badge from '../components/common/Badge';
import Button from '../components/common/Button';
import Message from '../components/common/Message';
import LoadingSpinner from '../components/common/LoadingSpinner';
import { BOOKING_STATUS, getSkillLabel, getSkillIcon } from '../utils/constants';

export default function MyBookings() {
  const { user } = useAuth();
  const navigate = useNavigate();
  const isProvider = user?.role === 'provider';

  const [bookings, setBookings] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [statusFilter, setStatusFilter] = useState('');

  const load = async () => {
    setLoading(true);
    setError('');
    try {
      const params = new URLSearchParams();
      params.append('role', isProvider ? 'provider' : 'citizen');
      if (statusFilter) params.append('status', statusFilter);
      const res = await api.get(`/bookings/?${params.toString()}`);
      setBookings(res.data.results ?? res.data ?? []);
    } catch {
      setError('Failed to load bookings.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { load(); }, [statusFilter]);

  const handleAction = async (bookingId, action) => {
    try {
      await api.patch(`/bookings/${bookingId}/${action}/`);
      load();
    } catch (err) {
      setError(err.response?.data?.detail || `Failed to ${action} booking.`);
    }
  };

  const statusCounts = bookings.reduce((acc, b) => {
    acc[b.status] = (acc[b.status] || 0) + 1;
    return acc;
  }, {});

  return (
    <div className="page">
      <div className="container">
        <div className="page-header" style={{ display: 'flex', alignItems: 'flex-end', justifyContent: 'space-between', flexWrap: 'wrap', gap: 'var(--space-4)' }}>
          <div>
            <p className="section-title">{isProvider ? 'Provider' : 'Citizen'}</p>
            <h1 className="page-title">My Bookings</h1>
          </div>
          {!isProvider && (
            <Button onClick={() => navigate('/providers/search')}>+ Book a Service</Button>
          )}
        </div>

        {/* Status filter pills */}
        <div className="flex flex-wrap gap-2 mb-6">
          {['', 'pending', 'confirmed', 'completed', 'cancelled'].map(s => (
            <button key={s} onClick={() => setStatusFilter(s)} style={{
              padding: '6px 16px',
              borderRadius: 'var(--r-pill)',
              border: `2px solid ${statusFilter === s ? 'var(--saffron)' : 'var(--border)'}`,
              background: statusFilter === s ? 'var(--saffron-pale)' : 'white',
              color: statusFilter === s ? 'var(--saffron-dark)' : 'var(--text-secondary)',
              fontWeight: 600,
              fontSize: '0.8125rem',
              cursor: 'pointer',
              transition: 'all var(--t-fast)',
            }}>
              {s === '' ? 'All' : s.charAt(0).toUpperCase() + s.slice(1)}
              {s && statusCounts[s] ? ` (${statusCounts[s]})` : ''}
            </button>
          ))}
        </div>

        {error && <Message type="error" onClose={() => setError('')}>{error}</Message>}

        {loading ? (
          <LoadingSpinner message="Loading bookings…" />
        ) : bookings.length === 0 ? (
          <div className="empty-state">
            <div className="empty-state-icon">📋</div>
            <div className="empty-state-title">No bookings found</div>
            {!isProvider && (
              <Button className="mt-5" onClick={() => navigate('/providers/search')}>
                Find a Service Provider
              </Button>
            )}
          </div>
        ) : (
          <div style={{ display: 'flex', flexDirection: 'column', gap: 'var(--space-4)' }}>
            {bookings.map(b => {
              const statusInfo = BOOKING_STATUS[b.status] ?? { label: b.status, badge: 'secondary' };
              const otherParty = isProvider ? b.citizen_detail : b.provider_detail;

              return (
                <div key={b.id} style={{
                  background: 'white',
                  border: '1px solid var(--border)',
                  borderRadius: 'var(--r-xl)',
                  overflow: 'hidden',
                  transition: 'box-shadow var(--t-base)',
                }}
                onMouseEnter={e => e.currentTarget.style.boxShadow = 'var(--shadow-md)'}
                onMouseLeave={e => e.currentTarget.style.boxShadow = 'none'}
                >
                  {/* Status bar */}
                  <div style={{
                    height: '3px',
                    background: b.status === 'completed' ? 'var(--success)'
                      : b.status === 'confirmed' ? 'var(--info)'
                      : b.status === 'cancelled' ? 'var(--slate-300)'
                      : 'var(--saffron)',
                  }} />

                  <div style={{ padding: 'var(--space-5)' }}>
                    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', gap: 'var(--space-4)', flexWrap: 'wrap' }}>
                      <div style={{ flex: 1 }}>
                        <div className="flex gap-3" style={{ marginBottom: 'var(--space-3)', alignItems: 'center', flexWrap: 'wrap' }}>
                          <span style={{ fontWeight: 700, fontSize: '1rem' }}>
                            {getSkillIcon(b.skill_category)} {getSkillLabel(b.skill_category)}
                          </span>
                          <Badge variant={statusInfo.badge}>{statusInfo.label}</Badge>
                          {b.payment_status === 'success' && <Badge variant="success">💳 Paid</Badge>}
                        </div>

                        <p style={{ color: 'var(--text-muted)', fontSize: '0.875rem', marginBottom: 'var(--space-2)' }}>
                          📅 {new Date(b.scheduled_time).toLocaleString()} &nbsp;·&nbsp; Booking #{b.id}
                        </p>

                        {otherParty && (
                          <p style={{ fontSize: '0.875rem', color: 'var(--text-secondary)', marginBottom: 'var(--space-3)' }}>
                            {isProvider ? '👤 Client:' : '🛠 Provider:'} <strong>{otherParty.name ?? otherParty.user_detail?.name}</strong>
                          </p>
                        )}

                        {b.description && (
                          <p style={{
                            fontSize: '0.875rem',
                            color: 'var(--text-muted)',
                            marginBottom: 0,
                            maxWidth: '480px',
                            overflow: 'hidden',
                            textOverflow: 'ellipsis',
                            whiteSpace: 'nowrap',
                          }}>{b.description}</p>
                        )}
                      </div>

                      <div style={{ textAlign: 'right', flexShrink: 0 }}>
                        <div style={{ fontWeight: 700, fontSize: '1.25rem', color: 'var(--saffron-dark)', letterSpacing: '-0.01em' }}>
                          NPR {parseFloat(b.amount).toLocaleString()}
                        </div>

                        <div className="flex gap-2 mt-3" style={{ justifyContent: 'flex-end' }}>
                          <Button size="sm" variant="secondary" onClick={() => navigate(`/bookings/${b.id}`)}>
                            Details
                          </Button>
                          {/* Provider actions */}
                          {isProvider && b.status === 'pending' && (
                            <Button size="sm" variant="success" onClick={() => handleAction(b.id, 'confirm')}>
                              Confirm
                            </Button>
                          )}
                          {isProvider && b.status === 'confirmed' && (
                            <Button size="sm" variant="success" onClick={() => handleAction(b.id, 'complete')}>
                              Mark Complete
                            </Button>
                          )}
                          {/* Cancel (citizen or provider) */}
                          {(b.status === 'pending') && (
                            <Button size="sm" variant="danger" onClick={() => handleAction(b.id, 'cancel')}>
                              Cancel
                            </Button>
                          )}
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              );
            })}
          </div>
        )}
      </div>
    </div>
  );
}
