// frontend/src/pages/Auth/Register.jsx
import { useState, useEffect } from 'react';
import { useNavigate, useLocation, Link } from 'react-router-dom';
import { useAuth } from '../../contexts/AuthContext';
import { authService } from '../../services/auth';
import api from '../../services/api';
import Button from '../../components/common/Button';
import Input from '../../components/common/Input';
import Message from '../../components/common/Message';
import LoadingSpinner from '../../components/common/LoadingSpinner';

const STEPS = ['phone', 'otp', 'details'];

export default function Register() {
  const navigate = useNavigate();
  const location = useLocation();
  const { login } = useAuth();

  const [step, setStep] = useState(
    location.state?.phone && location.state?.otp ? 'details' : 'phone'
  );
  const [phone, setPhone] = useState(location.state?.phone || '');
  const [otp, setOtp] = useState(location.state?.otp || '');
  const [name, setName] = useState('');
  const [role, setRole] = useState('citizen');
  const [municipalityId, setMunicipalityId] = useState('');
  const [municipalities, setMunicipalities] = useState([]);
  const [loadingMunis, setLoadingMunis] = useState(true);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');

  useEffect(() => {
    const load = async () => {
      try {
        const res = await api.get('/municipalities/');
        setMunicipalities(res.data);
      } catch {
        console.error('Failed to load municipalities');
      } finally {
        setLoadingMunis(false);
      }
    };
    load();
  }, []);

  const handleSendOTP = async (e) => {
    e.preventDefault();
    setError('');
    setLoading(true);
    try {
      await authService.sendOTP(phone);
      setSuccess('OTP sent! (Dev: use 123456)');
      setStep('otp');
    } catch (err) {
      setError(err.response?.data?.error || err.response?.data?.phone?.[0] || 'Failed to send OTP.');
    } finally {
      setLoading(false);
    }
  };

  const handleVerifyOTP = (e) => {
    e.preventDefault();
    if (!otp || otp.length !== 6) { setError('Enter the 6-digit OTP.'); return; }
    setError('');
    setStep('details');
  };

  const handleRegister = async (e) => {
    e.preventDefault();
    setError('');
    if (!name.trim()) { setError('Full name is required.'); return; }
    if (!municipalityId) { setError('Please select your municipality.'); return; }
    setLoading(true);
    try {
      const user = await login(phone, otp, {
        name: name.trim(),
        role,
        municipality: parseInt(municipalityId),
      });
      if (user.role === 'provider') navigate('/provider/onboarding');
      else navigate('/');
    } catch (err) {
      setError(err.response?.data?.error || 'Registration failed. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  const stepNum = STEPS.indexOf(step) + 1;

  return (
    <div style={{
      minHeight: '100vh',
      background: 'var(--bg)',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      padding: 'var(--space-8)',
    }}>
      <div style={{ width: '100%', maxWidth: '480px' }} className="slide-up">
        {/* Logo */}
        <div style={{ display: 'flex', alignItems: 'center', gap: 'var(--space-3)', marginBottom: 'var(--space-8)' }}>
          <div style={{
            width: '36px', height: '36px',
            background: 'var(--saffron)',
            borderRadius: 'var(--r-md)',
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            fontWeight: 800, fontSize: '1.125rem', color: 'white',
          }}>J</div>
          <span style={{ fontWeight: 700, fontSize: '1rem', color: 'var(--slate-900)', letterSpacing: '-0.01em' }}>JanSewa</span>
        </div>

        {/* Step indicator */}
        <div style={{ display: 'flex', gap: 'var(--space-2)', marginBottom: 'var(--space-6)' }}>
          {STEPS.map((s, i) => (
            <div key={s} style={{
              flex: 1,
              height: '3px',
              borderRadius: 'var(--r-pill)',
              background: i < stepNum ? 'var(--saffron)' : 'var(--border)',
              transition: 'background var(--t-slow)',
            }} />
          ))}
        </div>

        <div style={{ marginBottom: 'var(--space-8)' }}>
          <h2 style={{ marginBottom: 'var(--space-2)' }}>
            {step === 'phone' && 'Create account'}
            {step === 'otp' && 'Verify phone'}
            {step === 'details' && 'Your details'}
          </h2>
          <p style={{ color: 'var(--text-secondary)', fontSize: '0.9375rem' }}>
            {step === 'phone' && 'Enter your Nepal mobile number to get started'}
            {step === 'otp' && `OTP sent to ${phone}. Enter it below.`}
            {step === 'details' && 'Almost done — tell us about yourself'}
          </p>
        </div>

        {error && <Message type="error" onClose={() => setError('')}>{error}</Message>}
        {success && <Message type="success">{success}</Message>}

        {/* ── Phone step ── */}
        {step === 'phone' && (
          <form onSubmit={handleSendOTP}>
            <Input
              label="Phone Number"
              type="tel"
              placeholder="98XXXXXXXX"
              value={phone}
              onChange={e => setPhone(e.target.value)}
              required
              pattern="98[0-9]{8}"
              hint="Nepal mobile number"
            />
            <Button type="submit" block disabled={loading} size="lg">
              {loading ? 'Sending…' : 'Send OTP →'}
            </Button>
          </form>
        )}

        {/* ── OTP step ── */}
        {step === 'otp' && (
          <form onSubmit={handleVerifyOTP}>
            <div style={{
              display: 'flex', alignItems: 'center', justifyContent: 'space-between',
              padding: 'var(--space-3) var(--space-4)',
              background: 'var(--info-light)',
              borderRadius: 'var(--r-md)',
              border: '1px solid var(--info)',
              marginBottom: 'var(--space-5)',
            }}>
              <span style={{ fontSize: '0.875rem', color: 'var(--info)' }}>Code sent to {phone}</span>
              <button type="button" onClick={() => { setStep('phone'); setError(''); setSuccess(''); }} style={{
                background: 'none', border: 'none', color: 'var(--info)', fontWeight: 600,
                fontSize: '0.8125rem', cursor: 'pointer', textDecoration: 'underline',
              }}>Change</button>
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
            <Button type="submit" block disabled={loading} size="lg">
              Continue →
            </Button>
          </form>
        )}

        {/* ── Details step ── */}
        {step === 'details' && (
          <form onSubmit={handleRegister}>
            <Input
              label="Full Name"
              placeholder="Sita Devi / Ram Bahadur"
              value={name}
              onChange={e => setName(e.target.value)}
              required
            />

            <div className="form-group">
              <label className="form-label">I want to</label>
              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 'var(--space-3)' }}>
                {[
                  { value: 'citizen',  label: 'Find Services', icon: '🔍', desc: 'Book verified providers' },
                  { value: 'provider', label: 'Provide Services', icon: '🛠️', desc: 'Earn locally' },
                ].map(opt => (
                  <label key={opt.value} style={{
                    display: 'flex',
                    flexDirection: 'column',
                    gap: 'var(--space-1)',
                    padding: 'var(--space-4)',
                    border: `2px solid ${role === opt.value ? 'var(--saffron)' : 'var(--border)'}`,
                    borderRadius: 'var(--r-lg)',
                    cursor: 'pointer',
                    background: role === opt.value ? 'var(--saffron-pale)' : 'white',
                    transition: 'all var(--t-base)',
                  }}>
                    <input type="radio" name="role" value={opt.value} checked={role === opt.value}
                      onChange={e => setRole(e.target.value)} style={{ display: 'none' }} />
                    <span style={{ fontSize: '1.5rem' }}>{opt.icon}</span>
                    <span style={{ fontWeight: 700, fontSize: '0.9375rem', color: role === opt.value ? 'var(--saffron-dark)' : 'var(--slate-800)' }}>
                      {opt.label}
                    </span>
                    <span style={{ fontSize: '0.8125rem', color: 'var(--text-muted)' }}>{opt.desc}</span>
                  </label>
                ))}
              </div>
            </div>

            <div className="form-group">
              <label className="form-label">Municipality <span className="form-required">*</span></label>
              {loadingMunis ? (
                <LoadingSpinner inline message="Loading…" />
              ) : (
                <select className="form-select" value={municipalityId}
                  onChange={e => setMunicipalityId(e.target.value)} required>
                  <option value="">Select your municipality</option>
                  {municipalities.map(m => (
                    <option key={m.id} value={m.id}>{m.name}, {m.district}</option>
                  ))}
                </select>
              )}
            </div>

            <Button type="submit" block disabled={loading} size="lg">
              {loading ? 'Creating account…' : 'Complete Registration'}
            </Button>
          </form>
        )}

        <div style={{
          marginTop: 'var(--space-6)',
          paddingTop: 'var(--space-6)',
          borderTop: '1px solid var(--border)',
          textAlign: 'center',
        }}>
          <span style={{ color: 'var(--text-muted)', fontSize: '0.9rem' }}>Already have an account? </span>
          <Link to="/login" style={{ fontWeight: 600 }}>Sign in</Link>
        </div>
      </div>
    </div>
  );
}
