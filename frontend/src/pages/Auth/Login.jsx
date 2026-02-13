// frontend/src/pages/Auth/Login.jsx
import { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { useAuth } from '../../contexts/AuthContext';
import { authService } from '../../services/auth';
import Button from '../../components/common/Button';
import Input from '../../components/common/Input';
import Message from '../../components/common/Message';

export default function Login() {
  const navigate = useNavigate();
  const { login } = useAuth();

  const [step, setStep] = useState('phone');
  const [phone, setPhone] = useState('');
  const [otp, setOtp] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [otpSent, setOtpSent] = useState(false);

  const handleSendOTP = async (e) => {
    e.preventDefault();
    setError('');
    setLoading(true);
    try {
      await authService.sendOTP(phone);
      setOtpSent(true);
      setStep('otp');
    } catch (err) {
      setError(err.response?.data?.error || err.response?.data?.phone?.[0] || 'Failed to send OTP.');
    } finally {
      setLoading(false);
    }
  };

  const handleVerify = async (e) => {
    e.preventDefault();
    setError('');
    setLoading(true);
    try {
      const user = await login(phone, otp);
      if (user.role === 'municipality_admin') navigate('/admin/dashboard');
      else if (user.role === 'provider') navigate('/provider/dashboard');
      else navigate('/');
    } catch (err) {
      if (err.response?.data?.is_new_user) {
        navigate('/register', { state: { phone, otp } });
      } else {
        setError(err.response?.data?.error || 'Invalid OTP.');
      }
    } finally {
      setLoading(false);
    }
  };

  return (
    <div style={{
      minHeight: '100vh',
      display: 'flex',
      background: 'var(--slate-900)',
    }}>
      {/* Left panel — brand */}
      <div style={{
        flex: '0 0 420px',
        background: 'linear-gradient(160deg, var(--slate-800) 0%, var(--slate-900) 100%)',
        borderRight: '1px solid var(--slate-700)',
        display: 'flex',
        flexDirection: 'column',
        justifyContent: 'space-between',
        padding: 'var(--space-12)',
        display: 'none', // hide on small viewports via inline style override below
      }}
      className="login-left-panel"
      >
        <div>
          <div style={{
            display: 'flex', alignItems: 'center', gap: 'var(--space-3)',
            marginBottom: 'var(--space-12)',
          }}>
            <div style={{
              width: '40px', height: '40px',
              background: 'var(--saffron)',
              borderRadius: 'var(--r-md)',
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              fontWeight: 800, fontSize: '1.25rem', color: 'white',
            }}>J</div>
            <span style={{ fontWeight: 700, fontSize: '1.25rem', color: 'white' }}>JanSewa</span>
          </div>
          <h1 style={{ color: 'white', fontSize: '2rem', lineHeight: 1.3, marginBottom: 'var(--space-6)' }}>
            Municipal<br />Economic<br />Infrastructure
          </h1>
          <p style={{ color: 'var(--slate-400)', lineHeight: 1.7 }}>
            A circular local labor economy connecting verified service providers
            with citizens within Nepal's municipalities.
          </p>
        </div>

        <div style={{ display: 'flex', flexDirection: 'column', gap: 'var(--space-4)' }}>
          {[
            { icon: '🎓', label: 'Skill Certification Layer' },
            { icon: '✓',  label: 'Municipal Trust Layer' },
            { icon: '📋', label: 'Local Bookings Layer' },
            { icon: '📊', label: 'Governance & Visibility' },
          ].map(item => (
            <div key={item.label} style={{ display: 'flex', gap: 'var(--space-3)', alignItems: 'center' }}>
              <span style={{ fontSize: '1rem', width: '24px', textAlign: 'center' }}>{item.icon}</span>
              <span style={{ color: 'var(--slate-400)', fontSize: '0.875rem' }}>{item.label}</span>
            </div>
          ))}
        </div>
      </div>

      {/* Right panel — form */}
      <div style={{
        flex: 1,
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        padding: 'var(--space-8)',
        background: 'var(--bg)',
      }}>
        <div style={{ width: '100%', maxWidth: '440px' }} className="slide-up">
          {/* Logo (visible when left panel hidden) */}
          <div style={{ display: 'flex', alignItems: 'center', gap: 'var(--space-3)', marginBottom: 'var(--space-10)' }}>
            <div style={{
              width: '36px', height: '36px',
              background: 'var(--saffron)',
              borderRadius: 'var(--r-md)',
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              fontWeight: 800, fontSize: '1.125rem', color: 'white',
            }}>J</div>
            <div>
              <div style={{ fontWeight: 700, fontSize: '1rem', color: 'var(--slate-900)', letterSpacing: '-0.01em' }}>JanSewa</div>
              <div style={{ fontSize: '0.6875rem', color: 'var(--text-muted)', textTransform: 'uppercase', letterSpacing: '0.07em' }}>Nepal</div>
            </div>
          </div>

          <div style={{ marginBottom: 'var(--space-8)' }}>
            <h2 style={{ marginBottom: 'var(--space-2)' }}>
              {step === 'phone' ? 'Sign in' : 'Enter OTP'}
            </h2>
            <p style={{ color: 'var(--text-secondary)', fontSize: '0.9375rem' }}>
              {step === 'phone'
                ? 'Enter your Nepal phone number to continue'
                : `We sent a code to ${phone}`}
            </p>
          </div>

          {error && <Message type="error" onClose={() => setError('')}>{error}</Message>}

          {step === 'phone' ? (
            <form onSubmit={handleSendOTP}>
              <Input
                label="Phone Number"
                type="tel"
                placeholder="98XXXXXXXX"
                value={phone}
                onChange={e => setPhone(e.target.value)}
                required
                pattern="98[0-9]{8}"
                title="10 digits starting with 98"
                hint="Nepal mobile number (e.g. 9841234567)"
              />
              <Button type="submit" block disabled={loading} size="lg" className="mt-2">
                {loading ? 'Sending…' : 'Send OTP →'}
              </Button>
            </form>
          ) : (
            <form onSubmit={handleVerify}>
              <div style={{ marginBottom: 'var(--space-5)' }}>
                <div style={{
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'space-between',
                  padding: 'var(--space-3) var(--space-4)',
                  background: 'var(--info-light)',
                  borderRadius: 'var(--r-md)',
                  border: '1px solid var(--info)',
                }}>
                  <span style={{ fontSize: '0.875rem', color: 'var(--info)' }}>Code sent to {phone}</span>
                  <button type="button" onClick={() => setStep('phone')} style={{
                    background: 'none', border: 'none', color: 'var(--info)',
                    fontWeight: 600, fontSize: '0.8125rem', cursor: 'pointer', textDecoration: 'underline',
                  }}>Change</button>
                </div>
              </div>

              <Input
                label="One-Time Password"
                type="text"
                inputMode="numeric"
                placeholder="123456"
                value={otp}
                onChange={e => setOtp(e.target.value.replace(/\D/g, '').slice(0, 6))}
                required
                maxLength={6}
                hint="(Dev: use 123456)"
                style={{ letterSpacing: '0.25em', fontSize: '1.25rem', textAlign: 'center' }}
              />

              <Button type="submit" block disabled={loading} size="lg" className="mt-2">
                {loading ? 'Verifying…' : 'Verify & Sign In'}
              </Button>
            </form>
          )}

          <div style={{
            marginTop: 'var(--space-6)',
            paddingTop: 'var(--space-6)',
            borderTop: '1px solid var(--border)',
            textAlign: 'center',
          }}>
            <span style={{ color: 'var(--text-muted)', fontSize: '0.9rem' }}>
              New to JanSewa?{' '}
            </span>
            <Link to="/register" style={{ fontWeight: 600 }}>Create account</Link>
          </div>
        </div>
      </div>
    </div>
  );
}
