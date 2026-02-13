// frontend/src/pages/Home.jsx
import { useEffect } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';
import Button from '../components/common/Button';
import Card from '../components/common/Card';

function GuestHome() {
  const navigate = useNavigate();

  return (
    <div style={{ minHeight: '100vh', background: 'var(--bg)' }}>
      {/* Hero */}
      <div style={{
        background: 'linear-gradient(160deg, var(--slate-900) 0%, var(--slate-800) 100%)',
        padding: 'var(--space-16) 0',
        position: 'relative',
        overflow: 'hidden',
      }}>
        {/* Decorative circles */}
        <div style={{
          position: 'absolute', top: '-80px', right: '-80px',
          width: '320px', height: '320px',
          borderRadius: '50%',
          background: 'radial-gradient(circle, rgba(232,129,10,0.15) 0%, transparent 70%)',
        }} />
        <div style={{
          position: 'absolute', bottom: '-60px', left: '10%',
          width: '200px', height: '200px',
          borderRadius: '50%',
          background: 'radial-gradient(circle, rgba(26,158,92,0.12) 0%, transparent 70%)',
        }} />

        <div className="container" style={{ position: 'relative', zIndex: 1 }}>
          <div style={{ maxWidth: '700px' }}>
            <div style={{
              display: 'inline-flex', alignItems: 'center', gap: 'var(--space-2)',
              background: 'rgba(232,129,10,0.15)',
              border: '1px solid rgba(232,129,10,0.3)',
              borderRadius: 'var(--r-pill)',
              padding: '4px 14px',
              marginBottom: 'var(--space-6)',
            }}>
              <span style={{ width: '6px', height: '6px', borderRadius: '50%', background: 'var(--saffron)', display: 'inline-block' }} />
              <span style={{ fontSize: '1.0125rem', fontWeight: 600, color: 'var(--saffron)', letterSpacing: '0.04em' }}>
                सिप | सेवा | स्वरोजगार |
              </span>
            </div>

            <h1 style={{ color: 'white', fontSize: 'clamp(2rem, 5vw, 3.25rem)', marginBottom: 'var(--space-5)', lineHeight: 1.15 }}>
              Local skills.<br />
              <span style={{ color: 'var(--saffron)' }}>Municipal trust.</span><br />
              Circular economy.
            </h1>

            <p style={{ color: 'var(--slate-400)', fontSize: '1.0625rem', lineHeight: 1.7, maxWidth: '560px', marginBottom: 'var(--space-8)' }}>
              JanSewa connects verified skilled workers with citizens within Nepal's municipalities —
              keeping earnings local and labor trusted.
            </p>

            <div style={{ display: 'flex', gap: 'var(--space-4)', flexWrap: 'wrap' }}>
              <Button size="lg" onClick={() => navigate('/register')}>
                Get Started →
              </Button>
              <Button size="lg" variant="secondary" onClick={() => navigate('/login')}>
                Sign In
              </Button>
            </div>
          </div>
        </div>
      </div>

      {/* Circular Loop Section */}
      <div className="container" style={{ padding: 'var(--space-12) var(--space-6)' }}>
        <div style={{ textAlign: 'center', marginBottom: 'var(--space-10)' }}>
          <p className="section-title">The Circular Loop</p>
          <h2 style={{ letterSpacing: '-0.02em' }}>Four layers. One economy.</h2>
        </div>

        <div className="grid grid-4">
          {[
            { icon: '🎓', num: '01', title: 'Skill Layer', desc: 'CTEVT certification tracking for Nepal\'s skilled workers' },
            { icon: '✓', num: '02', title: 'Trust Layer', desc: 'Municipal verification + job history + reviews build credibility' },
            { icon: '📋', num: '03', title: 'Market Layer', desc: 'Local-first bookings — money stays municipal' },
            { icon: '📊', num: '04', title: 'Governance', desc: 'Jobs created, verified providers, bookings, earnings' },
          ].map(item => (
            <div key={item.num} style={{
              background: 'white',
              border: '1px solid var(--border)',
              borderRadius: 'var(--r-xl)',
              padding: 'var(--space-6)',
              position: 'relative',
              overflow: 'hidden',
            }}>
              <div style={{
                position: 'absolute', top: 'var(--space-4)', right: 'var(--space-4)',
                font: '700 0.75rem var(--font-mono)',
                color: 'var(--border-strong)',
                letterSpacing: '0.06em',
              }}>{item.num}</div>
              <div style={{ fontSize: '2rem', marginBottom: 'var(--space-4)' }}>{item.icon}</div>
              <h4 style={{ marginBottom: 'var(--space-2)' }}>{item.title}</h4>
              <p style={{ fontSize: '0.875rem', color: 'var(--text-muted)', marginBottom: 0 }}>{item.desc}</p>
            </div>
          ))}
        </div>

        {/* CTA cards */}
        <div className="grid grid-2 mt-10">
          <div style={{
            background: 'linear-gradient(135deg, var(--slate-900) 0%, var(--slate-700) 100%)',
            borderRadius: 'var(--r-2xl)',
            padding: 'var(--space-8)',
            color: 'white',
          }}>
            <h3 style={{ color: 'white', marginBottom: 'var(--space-3)' }}>For Citizens</h3>
            <p style={{ color: 'var(--slate-300)', marginBottom: 'var(--space-6)', fontSize: '0.9375rem' }}>
              Find municipality-verified professionals in your area. Book with confidence.
            </p>
            <Button variant="primary" onClick={() => navigate('/register')}>
              Find Services
            </Button>
          </div>

          <div style={{
            background: 'var(--saffron-pale)',
            border: '2px solid var(--saffron)',
            borderRadius: 'var(--r-2xl)',
            padding: 'var(--space-8)',
          }}>
            <h3 style={{ marginBottom: 'var(--space-3)', color: 'var(--saffron-dark)' }}>For Providers</h3>
            <p style={{ color: 'var(--saffron-dark)', opacity: 0.8, marginBottom: 'var(--space-6)', fontSize: '0.9375rem' }}>
              Build trust through verification, earn locally, grow your skilled trade.
            </p>
            <Button onClick={() => navigate('/register')}>
              Register as Provider
            </Button>
          </div>
        </div>

        {/* Courses Section */}
        <div className="container" style={{ padding: 'var(--space-12) var(--space-6)', background: 'var(--slate-50)' }}>
          <div style={{ textAlign: 'center', marginBottom: 'var(--space-8)' }}>
            <p className="section-title">Upskilling Opportunities</p>
            <h2 style={{ letterSpacing: '-0.02em' }}>Apply for Training Courses</h2>
            <p style={{ color: 'var(--text-muted)', maxWidth: '600px', margin: '0 auto', marginTop: 'var(--space-3)' }}>
              Municipality-organized training programs to enhance your professional skills
            </p>
          </div>
          <div style={{ display: 'flex', justifyContent: 'center' }}>
            <Button size="lg" onClick={() => navigate('/courses')}>
              Browse Courses →
            </Button>
          </div>
        </div>
      </div>
    </div>
  );
}

function CitizenHome({ user }) {
  const navigate = useNavigate();
  return (
    <div className="page">
      <div className="container">
        <div className="page-header">
          <p className="section-title">Welcome back</p>
          <h1 className="page-title">{user.name}</h1>
          <p className="page-subtitle">
            📍 {user.municipality_detail?.name}, {user.municipality_detail?.district}
          </p>
        </div>

        <div className="grid grid-2">
          <Card>
            <div style={{ fontSize: '2rem', marginBottom: 'var(--space-4)' }}>🔍</div>
            <h3 style={{ marginBottom: 'var(--space-2)' }}>Find Services</h3>
            <p style={{ color: 'var(--text-muted)', fontSize: '0.9375rem', marginBottom: 'var(--space-5)' }}>
              Search verified providers in {user.municipality_detail?.name}.
            </p>
            <Button block onClick={() => navigate('/providers/search')}>Browse Providers</Button>
          </Card>

          <Card>
            <div style={{ fontSize: '2rem', marginBottom: 'var(--space-4)' }}>📋</div>
            <h3 style={{ marginBottom: 'var(--space-2)' }}>My Bookings</h3>
            <p style={{ color: 'var(--text-muted)', fontSize: '0.9375rem', marginBottom: 'var(--space-5)' }}>
              View and manage your service bookings.
            </p>
            <Button block variant="secondary" onClick={() => navigate('/bookings')}>View Bookings</Button>
          </Card>

          <Card>
            <div style={{ fontSize: '2rem', marginBottom: 'var(--space-4)' }}>👤</div>
            <h3 style={{ marginBottom: 'var(--space-2)' }}>My Profile</h3>
            <p style={{ color: 'var(--text-muted)', fontSize: '0.9375rem', marginBottom: 'var(--space-5)' }}>
              Update your personal information.
            </p>
            <Button block variant="secondary" onClick={() => navigate('/profile')}>Edit Profile</Button>
          </Card>
        </div>
      </div>
    </div>
  );
}

function ProviderHome({ user }) {
  const navigate = useNavigate();
  return (
    <div className="page">
      <div className="container">
        <div className="page-header">
          <p className="section-title">Provider Portal</p>
          <h1 className="page-title">{user.name}</h1>
          <p className="page-subtitle">📍 {user.municipality_detail?.name}</p>
        </div>

        <div className="grid grid-2">
          <Card>
            <div style={{ fontSize: '2rem', marginBottom: 'var(--space-4)' }}>📊</div>
            <h3 style={{ marginBottom: 'var(--space-2)' }}>My Dashboard</h3>
            <p style={{ color: 'var(--text-muted)', fontSize: '0.9375rem', marginBottom: 'var(--space-5)' }}>
              Earnings, jobs completed, and performance overview.
            </p>
            <Button block onClick={() => navigate('/provider/dashboard')}>View Dashboard</Button>
          </Card>

          <Card>
            <div style={{ fontSize: '2rem', marginBottom: 'var(--space-4)' }}>📋</div>
            <h3 style={{ marginBottom: 'var(--space-2)' }}>Incoming Bookings</h3>
            <p style={{ color: 'var(--text-muted)', fontSize: '0.9375rem', marginBottom: 'var(--space-5)' }}>
              Manage your service requests.
            </p>
            <Button block variant="secondary" onClick={() => navigate('/provider/bookings')}>View Bookings</Button>
          </Card>

          <Card>
            <div style={{ fontSize: '2rem', marginBottom: 'var(--space-4)' }}>👤</div>
            <h3 style={{ marginBottom: 'var(--space-2)' }}>My Profile</h3>
            <p style={{ color: 'var(--text-muted)', fontSize: '0.9375rem', marginBottom: 'var(--space-5)' }}>
              Update skills, bio, and documents.
            </p>
            <Button block variant="secondary" onClick={() => navigate('/profile')}>Edit Profile</Button>
          </Card>

          <Card>
            <div style={{ fontSize: '2rem', marginBottom: 'var(--space-4)' }}>📚</div>
            <h3 style={{ marginBottom: 'var(--space-2)' }}>My Courses</h3>
            <p style={{ color: 'var(--text-muted)', fontSize: '0.9375rem', marginBottom: 'var(--space-5)' }}>
              View your enrolled training courses.
            </p>
            <Button block variant="secondary" onClick={() => navigate('/provider/courses')}>View Courses</Button>
          </Card>
        </div>
      </div>
    </div>
  );
}

function AdminHome({ user }) {
  const navigate = useNavigate();
  return (
    <div className="page">
      <div className="container">
        <div className="page-header">
          <p className="section-title">Municipality Admin</p>
          <h1 className="page-title">{user.name}</h1>
          <p className="page-subtitle">📍 {user.municipality_detail?.name}</p>
        </div>

        <div className="grid grid-2">
          <Card>
            <div style={{ fontSize: '2rem', marginBottom: 'var(--space-4)' }}>📊</div>
            <h3 style={{ marginBottom: 'var(--space-2)' }}>Municipal Dashboard</h3>
            <p style={{ color: 'var(--text-muted)', fontSize: '0.9375rem', marginBottom: 'var(--space-5)' }}>
              Circular loop health metrics and local economic data.
            </p>
            <Button block onClick={() => navigate('/admin/dashboard')}>View Dashboard</Button>
          </Card>

          <Card>
            <div style={{ fontSize: '2rem', marginBottom: 'var(--space-4)' }}>✓</div>
            <h3 style={{ marginBottom: 'var(--space-2)' }}>Provider Verification</h3>
            <p style={{ color: 'var(--text-muted)', fontSize: '0.9375rem', marginBottom: 'var(--space-5)' }}>
              Review and verify service providers in your municipality.
            </p>
            <Button block variant="secondary" onClick={() => navigate('/admin/providers')}>Verify Providers</Button>
          </Card>

          <Card>
            <div style={{ fontSize: '2rem', marginBottom: 'var(--space-4)' }}>📚</div>
            <h3 style={{ marginBottom: 'var(--space-2)' }}>Manage Courses</h3>
            <p style={{ color: 'var(--text-muted)', fontSize: '0.9375rem', marginBottom: 'var(--space-5)' }}>
              Create and manage training courses for providers.
            </p>
            <Button block variant="secondary" onClick={() => navigate('/admin/courses')}>Manage Courses</Button>
          </Card>
        </div>
      </div>
    </div>
  );
}

export default function Home() {
  const { user, isAuthenticated, loading } = useAuth();
  const navigate = useNavigate();

  useEffect(() => {
    if (!loading && isAuthenticated && user?.role === 'provider') {
      // Check if provider has completed onboarding — handled in dashboard
    }
  }, [user, isAuthenticated, loading]);

  if (!isAuthenticated) return <GuestHome />;
  if (user?.role === 'citizen') return <CitizenHome user={user} />;
  if (user?.role === 'provider') return <ProviderHome user={user} />;
  if (user?.role === 'municipality_admin') return <AdminHome user={user} />;
  return <CitizenHome user={user} />;
}
