// frontend/src/pages/MunicipalDashboard.jsx
import { useState, useEffect } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';
import { governanceService, providerService } from '../services';
import Card from '../components/common/Card';
import Badge from '../components/common/Badge';
import Button from '../components/common/Button';
import Message from '../components/common/Message';
import LoadingSpinner from '../components/common/LoadingSpinner';
import { getSkillIcon, getSkillLabel } from '../utils/constants';

export default function MunicipalDashboard() {
  const { user } = useAuth();
  const navigate = useNavigate();
  const [stats, setStats] = useState(null);
  const [pendingProviders, setPendingProviders] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [verifying, setVerifying] = useState(null);

  const load = async () => {
    setLoading(true);
    setError('');
    try {
      const [sRes, pRes] = await Promise.all([
        governanceService.getMunicipalityDashboard(),
        providerService.getPendingVerification(),
      ]);
      setStats(sRes);
      const pending = pRes.results ?? pRes ?? [];
      setPendingProviders(pending);
    } catch (err) {
      setError('Failed to load dashboard data.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { load(); }, []);

  const handleVerify = async (providerId, verifyData) => {
    setVerifying(providerId);
    try {
      await providerService.verifyProvider(providerId, verifyData);
      await load();
    } catch (err) {
      setError(err.response?.data?.detail || 'Verification failed.');
    } finally {
      setVerifying(null);
    }
  };

  if (loading) return <LoadingSpinner message="Loading municipal dashboard…" />;

  return (
    <div className="page">
      <div className="container">
        {/* Header */}
        <div className="page-header">
          <p className="section-title">Municipal Administration</p>
          <h1 className="page-title">Governance Dashboard</h1>
          <p className="page-subtitle">
            📍 {user?.municipality_detail?.name} — Circular Economy Loop Health
          </p>
        </div>

        {error && <Message type="error" onClose={() => setError('')}>{error}</Message>}

        {/* Loop Health Metrics */}
        {stats && (
          <>
            <div style={{ marginBottom: 'var(--space-3)' }}>
              <p className="section-title">Loop Health Metrics</p>
            </div>
            <div style={{
              display: 'grid',
              gridTemplateColumns: 'repeat(auto-fit, minmax(180px, 1fr))',
              gap: 'var(--space-4)',
              marginBottom: 'var(--space-8)',
            }}>
              {[
                { value: stats.verified_providers ?? 0, label: 'Verified Providers', icon: '✓', color: 'var(--success)' },
                { value: stats.total_providers ?? 0, label: 'Total Providers', icon: '👥', color: 'var(--slate-600)' },
                { value: stats.completed_bookings ?? 0, label: 'Completed Bookings', icon: '✅', color: 'var(--info)' },
                { value: `NPR ${(stats.total_earnings ?? 0).toLocaleString()}`, label: 'Local Earnings', icon: '💰', color: 'var(--saffron)' },
                { value: `${stats.completion_rate ?? 0}%`, label: 'Completion Rate', icon: '📈', color: 'var(--success)' },
              ].map(s => (
                <div key={s.label} style={{
                  background: 'white',
                  border: '1px solid var(--border)',
                  borderRadius: 'var(--r-xl)',
                  padding: 'var(--space-5)',
                  transition: 'all var(--t-base)',
                  cursor: 'default',
                }}
                  onMouseEnter={e => { e.currentTarget.style.transform = 'translateY(-3px)'; e.currentTarget.style.boxShadow = 'var(--shadow-md)'; e.currentTarget.style.borderColor = 'var(--saffron)'; }}
                  onMouseLeave={e => { e.currentTarget.style.transform = 'translateY(0)'; e.currentTarget.style.boxShadow = 'none'; e.currentTarget.style.borderColor = 'var(--border)'; }}
                >
                  <div style={{ fontSize: '1.5rem', marginBottom: 'var(--space-3)' }}>{s.icon}</div>
                  <div style={{ fontSize: '1.375rem', fontWeight: 800, color: s.color, letterSpacing: '-0.02em', lineHeight: 1.2, marginBottom: 'var(--space-1)' }}>
                    {s.value}
                  </div>
                  <div style={{ fontSize: '0.6875rem', fontWeight: 700, color: 'var(--text-muted)', textTransform: 'uppercase', letterSpacing: '0.08em' }}>
                    {s.label}
                  </div>
                </div>
              ))}
            </div>

            {/* Top Skills */}
            {stats.top_skills?.length > 0 && (
              <Card title="Top Active Skills" className="mb-8">
                <div style={{ display: 'flex', flexDirection: 'column', gap: 'var(--space-3)' }}>
                  {stats.top_skills.map((skill, idx) => (
                    <div key={skill.skill} style={{
                      display: 'flex', alignItems: 'center', gap: 'var(--space-4)',
                    }}>
                      <span style={{ fontWeight: 700, color: 'var(--text-muted)', width: '20px', textAlign: 'center', fontSize: '0.875rem' }}>
                        {idx + 1}
                      </span>
                      <span style={{ minWidth: '140px', fontWeight: 600 }}>
                        {getSkillIcon(skill.skill)} {getSkillLabel(skill.skill)}
                      </span>
                      <div style={{ flex: 1, height: '8px', background: 'var(--border)', borderRadius: 'var(--r-pill)', overflow: 'hidden' }}>
                        <div style={{
                          height: '100%',
                          width: `${Math.min((skill.count / (stats.top_skills[0]?.count || 1)) * 100, 100)}%`,
                          background: `hsl(${220 - idx * 30}, 70%, 55%)`,
                          borderRadius: 'var(--r-pill)',
                        }} />
                      </div>
                      <span style={{ fontWeight: 700, minWidth: '40px', textAlign: 'right', color: 'var(--text-secondary)', fontSize: '0.875rem' }}>
                        {skill.count}
                      </span>
                    </div>
                  ))}
                </div>
              </Card>
            )}
          </>
        )}

        {/* Provider Verification Queue */}
        <div style={{ marginBottom: 'var(--space-3)' }}>
          <p className="section-title">Verification Queue ({pendingProviders.length})</p>
        </div>

        {pendingProviders.length === 0 ? (
          <Card>
            <div className="empty-state" style={{ padding: 'var(--space-8)' }}>
              <div className="empty-state-icon">✓</div>
              <div className="empty-state-title">All providers verified</div>
              <p style={{ color: 'var(--text-muted)', fontSize: '0.875rem' }}>No pending verifications.</p>
            </div>
          </Card>
        ) : (
          <div style={{ display: 'flex', flexDirection: 'column', gap: 'var(--space-4)' }}>
            {pendingProviders.map(p => (
              <div key={p.id} style={{
                background: 'white',
                border: `1px solid ${p.municipality_verified ? 'var(--success)' : 'var(--border)'}`,
                borderRadius: 'var(--r-xl)',
                overflow: 'hidden',
                boxShadow: 'var(--shadow-sm)',
              }}>
                <div style={{
                  height: '3px',
                  background: p.municipality_verified ? 'var(--success)' : 'var(--saffron)',
                }} />
                <div style={{ padding: 'var(--space-5)' }}>
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', gap: 'var(--space-4)', flexWrap: 'wrap' }}>
                    <div>
                      <div className="flex gap-3" style={{ alignItems: 'center', marginBottom: 'var(--space-2)' }}>
                        <h3 style={{ marginBottom: 0 }}>{p.user_detail?.name}</h3>
                        {p.municipality_verified
                          ? <Badge variant="success">✓ Verified</Badge>
                          : <Badge variant="warning">Awaiting Verification</Badge>
                        }
                        <Badge variant={p.ctevt_status === 'certified' ? 'success' : 'secondary'}>
                          CTEVT: {p.ctevt_status}
                        </Badge>
                      </div>

                      <p style={{ color: 'var(--text-muted)', fontSize: '0.875rem', marginBottom: 'var(--space-3)' }}>
                        📱 {p.user_detail?.phone}
                        &nbsp;·&nbsp; 📅 Joined {new Date(p.created_at).toLocaleDateString()}
                      </p>

                      <div className="flex flex-wrap gap-2">
                        {p.skill_categories?.map(s => (
                          <span key={s} style={{
                            padding: '2px 10px',
                            background: 'var(--slate-100)',
                            borderRadius: 'var(--r-pill)',
                            fontSize: '0.8125rem',
                            fontWeight: 500,
                          }}>
                            {getSkillIcon(s)} {getSkillLabel(s)}
                          </span>
                        ))}
                      </div>
                    </div>

                    <div className="flex gap-3" style={{ flexShrink: 0 }}>
                      <Button size="sm" variant="secondary" onClick={() => navigate(`/providers/${p.id}`)}>
                        View Profile
                      </Button>
                      {!p.municipality_verified && (
                        <Button
                          size="sm"
                          variant="success"
                          disabled={verifying === p.id}
                          onClick={() => handleVerify(p.id, {
                            municipality_verified: true,
                            verification_notes: 'Verified by municipality admin',
                          })}
                        >
                          {verifying === p.id ? 'Verifying…' : '✓ Verify'}
                        </Button>
                      )}
                    </div>
                  </div>

                  {/* Document links */}
                  {(p.citizenship_photo || p.ctevt_certificate_upload || p.ctevt_certificate_link) && (
                    <div style={{
                      marginTop: 'var(--space-4)',
                      paddingTop: 'var(--space-4)',
                      borderTop: '1px solid var(--border)',
                      display: 'flex', gap: 'var(--space-4)', flexWrap: 'wrap',
                    }}>
                      <p className="section-title" style={{ width: '100%', marginBottom: 'var(--space-2)' }}>Documents</p>
                      {p.citizenship_photo && (
                        <a href={p.citizenship_photo} target="_blank" rel="noreferrer" style={{ fontSize: '0.875rem', color: 'var(--info)' }}>
                          📷 Citizenship Card
                        </a>
                      )}
                      {p.ctevt_certificate_upload && (
                        <a href={p.ctevt_certificate_upload} target="_blank" rel="noreferrer" style={{ fontSize: '0.875rem', color: 'var(--info)' }}>
                          🎓 CTEVT Certificate
                        </a>
                      )}
                      {p.ctevt_certificate_link && (
                        <a href={p.ctevt_certificate_link} target="_blank" rel="noreferrer" style={{ fontSize: '0.875rem', color: 'var(--info)' }}>
                          🔗 CTEVT Link
                        </a>
                      )}
                    </div>
                  )}
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
