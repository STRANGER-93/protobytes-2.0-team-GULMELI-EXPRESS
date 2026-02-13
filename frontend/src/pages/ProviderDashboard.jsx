// frontend/src/pages/ProviderDashboard.jsx
import { useState, useEffect } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';
import api from '../services/api';
import Card from '../components/common/Card';
import Badge from '../components/common/Badge';
import Button from '../components/common/Button';
import Message from '../components/common/Message';
import LoadingSpinner from '../components/common/LoadingSpinner';
import TrustBadges from '../components/provider/TrustBadges';
import { SKILL_CATEGORIES, getSkillIcon, getSkillLabel } from '../utils/constants';

export default function ProviderDashboard() {
  const { user } = useAuth();
  const navigate = useNavigate();
  const [profile, setProfile] = useState(null);
  const [recentBookings, setRecentBookings] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    const load = async () => {
      try {
        const [pRes, bRes] = await Promise.all([
          api.get('/providers/me/'),
          api.get('/bookings/?role=provider'),
        ]);
        setProfile(pRes.data);
        const bookings = bRes.data.results ?? bRes.data ?? [];
        setRecentBookings(bookings.slice(0, 5));
      } catch (err) {
        if (err.response?.status === 404) {
          navigate('/provider/onboarding', { replace: true });
        } else {
          setError('Failed to load dashboard.');
        }
      } finally {
        setLoading(false);
      }
    };
    load();
  }, [navigate]);

  if (loading) return <LoadingSpinner message="Loading dashboard…" />;
  if (error) return <div className="page container"><Message type="error">{error}</Message></div>;
  if (!profile) return null;

  const trustScore = profile.trust_score ?? 0;

  return (
    <div className="page">
      <div className="container">
        {/* Header */}
        <div className="page-header" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-end', flexWrap: 'wrap', gap: 'var(--space-4)' }}>
          <div>
            <p className="section-title">Provider Dashboard</p>
            <h1 className="page-title">{user?.name}</h1>
            <p className="page-subtitle">📍 {user?.municipality_detail?.name}</p>
          </div>
          <Button variant="secondary" onClick={() => navigate('/provider/bookings')}>
            View All Bookings →
          </Button>
        </div>

        {/* Verification alert */}
        {!profile.municipality_verified && (
          <Message type="warning" className="mb-6">
            Your profile is pending municipality verification. You'll become visible to citizens once verified by your local admin.
          </Message>
        )}

        {/* Stats grid */}
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(160px, 1fr))', gap: 'var(--space-4)', marginBottom: 'var(--space-8)' }}>
          {[
            {
              value: `NPR ${parseFloat(profile.total_earnings || 0).toLocaleString()}`,
              label: 'Total Earnings',
              icon: '💰',
              color: 'var(--success)',
            },
            {
              value: profile.jobs_completed ?? 0,
              label: 'Jobs Completed',
              icon: '✅',
              color: 'var(--info)',
            },
            {
              value: parseFloat(profile.avg_rating || 0).toFixed(1),
              label: 'Avg. Rating',
              icon: '⭐',
              color: 'var(--saffron)',
            },
            {
              value: `${trustScore}/100`,
              label: 'Trust Score',
              icon: '🛡',
              color: trustScore >= 70 ? 'var(--success)' : trustScore >= 40 ? 'var(--warning)' : 'var(--danger)',
            },
          ].map(s => (
            <div key={s.label} style={{
              background: 'white',
              border: '1px solid var(--border)',
              borderRadius: 'var(--r-xl)',
              padding: 'var(--space-5)',
              transition: 'all var(--t-base)',
            }}
            onMouseEnter={e => { e.currentTarget.style.transform = 'translateY(-2px)'; e.currentTarget.style.boxShadow = 'var(--shadow-md)'; }}
            onMouseLeave={e => { e.currentTarget.style.transform = 'translateY(0)'; e.currentTarget.style.boxShadow = 'none'; }}
            >
              <div style={{ fontSize: '1.5rem', marginBottom: 'var(--space-3)' }}>{s.icon}</div>
              <div style={{ fontSize: '1.5rem', fontWeight: 800, color: s.color, letterSpacing: '-0.02em', lineHeight: 1.2, marginBottom: 'var(--space-1)' }}>
                {s.value}
              </div>
              <div style={{ fontSize: '0.75rem', fontWeight: 700, color: 'var(--text-muted)', textTransform: 'uppercase', letterSpacing: '0.07em' }}>
                {s.label}
              </div>
            </div>
          ))}
        </div>

        <div style={{ display: 'grid', gridTemplateColumns: '1fr 360px', gap: 'var(--space-6)', alignItems: 'start' }}>
          {/* Left: recent bookings */}
          <div>
            <Card title="Recent Bookings" titleRight={
              <Link to="/provider/bookings" style={{ fontSize: '0.875rem', fontWeight: 600, color: 'var(--saffron)' }}>View all</Link>
            }>
              {recentBookings.length === 0 ? (
                <div className="empty-state" style={{ padding: 'var(--space-8)' }}>
                  <div className="empty-state-icon">📋</div>
                  <div className="empty-state-title">No bookings yet</div>
                  <p style={{ color: 'var(--text-muted)', fontSize: '0.875rem' }}>
                    Bookings will appear here once citizens start booking your services.
                  </p>
                </div>
              ) : (
                <div style={{ display: 'flex', flexDirection: 'column', gap: 'var(--space-3)' }}>
                  {recentBookings.map(b => (
                    <div key={b.id} style={{
                      display: 'flex', justifyContent: 'space-between', alignItems: 'center',
                      padding: 'var(--space-4)', background: 'var(--bg)', borderRadius: 'var(--r-lg)',
                      border: '1px solid var(--border)', gap: 'var(--space-4)', flexWrap: 'wrap',
                    }}>
                      <div>
                        <span style={{ fontWeight: 600 }}>{getSkillIcon(b.skill_category)} {getSkillLabel(b.skill_category)}</span>
                        <span style={{ marginLeft: 'var(--space-3)' }}>
                          <Badge variant={b.status === 'completed' ? 'success' : b.status === 'confirmed' ? 'info' : 'warning'}>
                            {b.status}
                          </Badge>
                        </span>
                        <p style={{ fontSize: '0.8125rem', color: 'var(--text-muted)', marginTop: 'var(--space-1)', marginBottom: 0 }}>
                          {new Date(b.scheduled_time).toLocaleDateString()}
                        </p>
                      </div>
                      <div style={{ textAlign: 'right' }}>
                        <div style={{ fontWeight: 700, color: 'var(--saffron-dark)' }}>
                          NPR {parseFloat(b.amount).toLocaleString()}
                        </div>
                        <Button size="sm" variant="secondary" onClick={() => navigate(`/bookings/${b.id}`)} className="mt-2">
                          View
                        </Button>
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </Card>
          </div>

          {/* Right: profile status */}
          <div style={{ display: 'flex', flexDirection: 'column', gap: 'var(--space-4)' }}>
            <Card title="Verification Status">
              <TrustBadges provider={profile} showAll />

              {/* Trust score bar */}
              <div style={{ marginTop: 'var(--space-4)' }}>
                <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 'var(--space-2)' }}>
                  <span style={{ fontSize: '0.875rem', fontWeight: 600, color: 'var(--text-secondary)' }}>Trust Score</span>
                  <span style={{ fontWeight: 700, color: trustScore >= 70 ? 'var(--success)' : 'var(--warning)' }}>{trustScore}/100</span>
                </div>
                <div style={{ height: '8px', background: 'var(--border)', borderRadius: 'var(--r-pill)', overflow: 'hidden' }}>
                  <div style={{
                    height: '100%',
                    width: `${trustScore}%`,
                    background: trustScore >= 70 ? 'var(--success)' : trustScore >= 40 ? 'var(--warning)' : 'var(--danger)',
                    borderRadius: 'var(--r-pill)',
                    transition: 'width 0.8s ease',
                  }} />
                </div>
                <p style={{ fontSize: '0.75rem', color: 'var(--text-muted)', marginTop: 'var(--space-2)', marginBottom: 0 }}>
                  Earn points: municipality verification (+40), CTEVT (+30), rating ≥4 (+20), 10+ jobs (+10)
                </p>
              </div>
            </Card>

            <Card title="My Skills">
              <div className="flex flex-wrap gap-2">
                {profile.skill_categories?.map(skill => (
                  <span key={skill} style={{
                    padding: '4px 12px',
                    background: 'var(--slate-100)',
                    borderRadius: 'var(--r-pill)',
                    fontSize: '0.875rem',
                    fontWeight: 500,
                    color: 'var(--slate-700)',
                  }}>
                    {getSkillIcon(skill)} {getSkillLabel(skill)}
                  </span>
                ))}
              </div>
            </Card>

            <Card title="Profile">
              <p style={{ color: 'var(--text-muted)', fontSize: '0.875rem', marginBottom: 'var(--space-4)' }}>
                {profile.bio || 'No bio added yet.'}
              </p>
              <Button block variant="secondary" onClick={() => navigate('/profile')}>
                Edit Profile
              </Button>
            </Card>
          </div>
        </div>
      </div>
    </div>
  );
}
