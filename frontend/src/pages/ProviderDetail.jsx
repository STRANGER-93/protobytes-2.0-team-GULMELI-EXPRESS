// frontend/src/pages/ProviderDetail.jsx
import { useState, useEffect } from 'react';
import { useParams, useNavigate, Link } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';
import api from '../services/api';
import Card from '../components/common/Card';
import Button from '../components/common/Button';
import Badge from '../components/common/Badge';
import Message from '../components/common/Message';
import LoadingSpinner from '../components/common/LoadingSpinner';
import TrustBadges from '../components/provider/TrustBadges';
import { getSkillLabel, getSkillIcon, CTEVT_STATUS } from '../utils/constants';

export default function ProviderDetail() {
  const { id } = useParams();
  const navigate = useNavigate();
  const { user } = useAuth();
  const [provider, setProvider] = useState(null);
  const [reviews, setReviews] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    const load = async () => {
      try {
        const [pRes, rRes] = await Promise.allSettled([
          api.get(`/providers/${id}/`),
          api.get(`/reviews/?provider=${id}`),
        ]);
        if (pRes.status === 'fulfilled') setProvider(pRes.value.data);
        else throw new Error('Provider not found');
        if (rRes.status === 'fulfilled') {
          setReviews(rRes.value.data.results ?? rRes.value.data ?? []);
        }
      } catch {
        setError('Failed to load provider details.');
      } finally {
        setLoading(false);
      }
    };
    load();
  }, [id]);

  if (loading) return <LoadingSpinner message="Loading provider…" />;
  if (error) return (
    <div className="page container-md">
      <Message type="error">{error}</Message>
      <Link to="/providers/search" className="back-link mt-4">← Back to Search</Link>
    </div>
  );
  if (!provider) return null;

  const { user_detail, skill_categories, bio, experience_years, jobs_completed, avg_rating, total_earnings } = provider;
  const ctevtInfo = CTEVT_STATUS[provider.ctevt_status];

  const canBook = user?.role === 'citizen';

  return (
    <div className="page">
      <div className="container" style={{ maxWidth: '960px' }}>
        <Link to="/providers/search" className="back-link">← Back to Search</Link>

        {/* Hero card */}
        <div style={{
          background: 'white',
          border: '1px solid var(--border)',
          borderRadius: 'var(--r-2xl)',
          overflow: 'hidden',
          marginBottom: 'var(--space-6)',
          boxShadow: 'var(--shadow-md)',
        }}>
          {/* Top bar */}
          <div style={{
            height: '6px',
            background: provider.municipality_verified
              ? 'linear-gradient(90deg, var(--success), var(--saffron), var(--info))'
              : 'var(--slate-200)',
          }} />

          <div style={{ padding: 'var(--space-8)' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', gap: 'var(--space-6)', flexWrap: 'wrap' }}>
              <div style={{ flex: 1, minWidth: '240px' }}>
                <h1 style={{ marginBottom: 'var(--space-2)' }}>{user_detail?.name}</h1>
                <p style={{ color: 'var(--text-muted)', marginBottom: 'var(--space-5)' }}>
                  📍 {user_detail?.municipality_detail?.name}, {user_detail?.municipality_detail?.district}
                </p>
                <TrustBadges provider={provider} showAll />

                {/* Skills */}
                <div className="flex flex-wrap gap-2 mt-4">
                  {skill_categories?.map(skill => (
                    <span key={skill} style={{
                      padding: '4px 14px',
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
              </div>

              {/* Avatar */}
              {user_detail?.photo ? (
                <img src={user_detail.photo} alt={user_detail.name} style={{
                  width: 120, height: 120, borderRadius: '50%', objectFit: 'cover',
                  border: '4px solid var(--border)', flexShrink: 0,
                }} />
              ) : (
                <div style={{
                  width: 120, height: 120, borderRadius: '50%',
                  background: 'linear-gradient(135deg, var(--saffron), var(--saffron-dark))',
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                  fontWeight: 800, fontSize: '3rem', color: 'white', flexShrink: 0,
                }}>
                  {user_detail?.name?.charAt(0).toUpperCase()}
                </div>
              )}
            </div>
          </div>
        </div>

        <div style={{ display: 'grid', gridTemplateColumns: '1fr 320px', gap: 'var(--space-6)', alignItems: 'start' }}>
          {/* Left column */}
          <div>
            {/* Stats */}
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: 'var(--space-4)', marginBottom: 'var(--space-6)' }}>
              {[
                { value: parseFloat(avg_rating || 0).toFixed(1), label: 'Rating', icon: '⭐' },
                { value: jobs_completed ?? 0, label: 'Jobs Done', icon: '✅' },
                { value: experience_years > 0 ? `${experience_years}y` : '—', label: 'Experience', icon: '📅' },
              ].map(s => (
                <div key={s.label} className="stat-card">
                  <div style={{ fontSize: '1.25rem', marginBottom: 'var(--space-2)' }}>{s.icon}</div>
                  <div className="stat-value">{s.value}</div>
                  <div className="stat-label">{s.label}</div>
                </div>
              ))}
            </div>

            {/* Bio */}
            {bio && (
              <Card title="About" className="mb-6">
                <p style={{ color: 'var(--text-secondary)', lineHeight: 1.7, whiteSpace: 'pre-wrap' }}>
                  {bio}
                </p>
              </Card>
            )}

            {/* Reviews */}
            <Card title={`Reviews (${reviews.length})`}>
              {reviews.length === 0 ? (
                <div className="empty-state" style={{ padding: 'var(--space-8)' }}>
                  <div className="empty-state-icon">💬</div>
                  <div className="empty-state-title">No reviews yet</div>
                </div>
              ) : (
                <div style={{ display: 'flex', flexDirection: 'column', gap: 'var(--space-4)' }}>
                  {reviews.map(r => (
                    <div key={r.id} style={{
                      padding: 'var(--space-4)',
                      background: 'var(--bg)',
                      borderRadius: 'var(--r-lg)',
                      border: '1px solid var(--border)',
                    }}>
                      <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 'var(--space-2)' }}>
                        <span style={{ fontWeight: 600, fontSize: '0.9rem' }}>
                          {'⭐'.repeat(r.rating)}
                        </span>
                        <span style={{ fontSize: '0.8125rem', color: 'var(--text-muted)' }}>
                          {new Date(r.created_at).toLocaleDateString()}
                        </span>
                      </div>
                      {r.comment && <p style={{ color: 'var(--text-secondary)', fontSize: '0.9375rem', marginBottom: 0 }}>{r.comment}</p>}
                    </div>
                  ))}
                </div>
              )}
            </Card>
          </div>

          {/* Right column — sticky booking panel */}
          <div style={{ position: 'sticky', top: '80px' }}>
            <Card>
              <h3 style={{ marginBottom: 'var(--space-5)' }}>Verification Status</h3>

              {/* Municipal */}
              <div style={{ marginBottom: 'var(--space-4)' }}>
                <p className="section-title" style={{ marginBottom: 'var(--space-2)' }}>Municipality</p>
                {provider.municipality_verified ? (
                  <div style={{ display: 'flex', gap: 'var(--space-2)', alignItems: 'center', color: 'var(--success)', fontWeight: 600 }}>
                    <span>✓</span>
                    <span>Verified</span>
                    {provider.verified_at && (
                      <span style={{ fontSize: '0.8125rem', fontWeight: 400, color: 'var(--text-muted)' }}>
                        {new Date(provider.verified_at).toLocaleDateString()}
                      </span>
                    )}
                  </div>
                ) : (
                  <Badge variant="warning">Pending Verification</Badge>
                )}
              </div>

              {/* CTEVT */}
              <div style={{ marginBottom: 'var(--space-5)', paddingBottom: 'var(--space-5)', borderBottom: '1px solid var(--border)' }}>
                <p className="section-title" style={{ marginBottom: 'var(--space-2)' }}>CTEVT Certification</p>
                <Badge variant={ctevtInfo?.badge ?? 'secondary'}>
                  {ctevtInfo?.label ?? provider.ctevt_status}
                </Badge>
                {provider.ctevt_certificate_link && (
                  <a href={provider.ctevt_certificate_link} target="_blank" rel="noreferrer"
                    style={{ display: 'block', marginTop: 'var(--space-2)', fontSize: '0.8125rem', color: 'var(--saffron)' }}>
                    View certificate ↗
                  </a>
                )}
              </div>

              {canBook ? (
                <>
                  <Button block size="lg" onClick={() => navigate(`/bookings/create?provider=${id}`)}>
                    Book This Provider
                  </Button>
                  {!provider.municipality_verified && (
                    <Message type="warning" className="mt-4">
                      This provider is not yet municipality-verified. Proceed with caution.
                    </Message>
                  )}
                </>
              ) : (
                <p style={{ fontSize: '0.875rem', color: 'var(--text-muted)', textAlign: 'center' }}>
                  {user?.role === 'provider' ? 'Switch to a citizen account to book services.' : 'Login as a citizen to book.'}
                </p>
              )}
            </Card>
          </div>
        </div>
      </div>
    </div>
  );
}
