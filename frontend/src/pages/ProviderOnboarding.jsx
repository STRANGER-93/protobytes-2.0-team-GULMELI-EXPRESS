// frontend/src/pages/ProviderOnboarding.jsx
import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';
import api from '../services/api';
import Card from '../components/common/Card';
import Input from '../components/common/Input';
import Button from '../components/common/Button';
import Message from '../components/common/Message';
import LoadingSpinner from '../components/common/LoadingSpinner';
import { SKILL_CATEGORIES } from '../utils/constants';

export default function ProviderOnboarding() {
  const navigate = useNavigate();
  const { user, updateUser } = useAuth();

  const [checking, setChecking] = useState(true);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const [selectedSkills, setSelectedSkills] = useState([]);
  const [bio, setBio] = useState('');
  const [expYears, setExpYears] = useState('0');
  const [ctevtStatus, setCtevtStatus] = useState('pending');
  const [ctevtLink, setCtevtLink] = useState('');
  const [citizenshipFile, setCitizenshipFile] = useState(null);
  const [ctevtFile, setCtevtFile] = useState(null);

  useEffect(() => {
    const check = async () => {
      try {
        await api.get('/providers/me/');
        navigate('/provider/dashboard', { replace: true });
      } catch (err) {
        if (err.response?.status !== 404) console.error(err);
      } finally {
        setChecking(false);
      }
    };
    check();
  }, [navigate]);

  const toggleSkill = (val) => {
    setSelectedSkills(prev =>
      prev.includes(val) ? prev.filter(s => s !== val) : [...prev, val]
    );
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');

    if (selectedSkills.length === 0) { setError('Select at least one skill.'); return; }
    if (!citizenshipFile) { setError('Citizenship card photo is required.'); return; }
    if (ctevtStatus === 'certified' && !ctevtFile && !ctevtLink) {
      setError('Provide a CTEVT certificate upload or link for certified status.');
      return;
    }

    setLoading(true);
    try {
      const fd = new FormData();
      fd.append('skill_categories', JSON.stringify(selectedSkills));
      fd.append('bio', bio);
      fd.append('experience_years', expYears);
      fd.append('ctevt_status', ctevtStatus);
      fd.append('citizenship_photo', citizenshipFile);
      if (ctevtLink) fd.append('ctevt_certificate_link', ctevtLink);
      if (ctevtFile) fd.append('ctevt_certificate_upload', ctevtFile);

      await api.post('/providers/register/', fd, {
        headers: { 'Content-Type': 'multipart/form-data' },
      });

      const profileRes = await api.get('/auth/me/');
      updateUser(profileRes.data);
      navigate('/provider/dashboard');
    } catch (err) {
      const d = err.response?.data;
      setError(d?.detail || d?.error || JSON.stringify(d) || 'Submission failed. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  if (user?.role !== 'provider') {
    return (
      <div className="page">
        <div className="container-sm">
          <Message type="error">Only users registered as providers can access this page.</Message>
        </div>
      </div>
    );
  }

  if (checking) return <LoadingSpinner message="Checking profile…" />;

  return (
    <div className="page">
      <div className="container-md">
        {/* Header */}
        <div style={{ marginBottom: 'var(--space-10)' }}>
          <p className="section-title">Provider Portal</p>
          <h1 style={{ marginBottom: 'var(--space-3)' }}>Complete your profile</h1>
          <p style={{ color: 'var(--text-secondary)', maxWidth: '520px' }}>
            Submit your skills and documents. Once your municipality admin verifies your profile,
            citizens can book your services.
          </p>
        </div>

        {/* Progress hint */}
        <div style={{
          display: 'flex',
          gap: 'var(--space-4)',
          marginBottom: 'var(--space-8)',
          padding: 'var(--space-4) var(--space-5)',
          background: 'var(--saffron-pale)',
          border: '1px solid rgba(232,129,10,0.25)',
          borderRadius: 'var(--r-lg)',
          fontSize: '0.875rem',
          color: 'var(--saffron-dark)',
          flexWrap: 'wrap',
        }}>
          {['Submit profile', 'Admin reviews', 'Get verified', 'Receive bookings'].map((s, i) => (
            <div key={s} style={{ display: 'flex', alignItems: 'center', gap: 'var(--space-2)' }}>
              <span style={{
                width: '20px', height: '20px',
                borderRadius: '50%',
                background: i === 0 ? 'var(--saffron)' : 'rgba(232,129,10,0.25)',
                color: i === 0 ? 'white' : 'var(--saffron)',
                display: 'flex', alignItems: 'center', justifyContent: 'center',
                fontSize: '0.6875rem', fontWeight: 700, flexShrink: 0,
              }}>{i + 1}</span>
              <span>{s}</span>
              {i < 3 && <span style={{ color: 'rgba(232,129,10,0.4)' }}>→</span>}
            </div>
          ))}
        </div>

        <form onSubmit={handleSubmit}>
          {error && <Message type="error" onClose={() => setError('')}>{error}</Message>}

          {/* Skills */}
          <Card title="Your Skills" className="mb-6">
            <p style={{ color: 'var(--text-muted)', fontSize: '0.875rem', marginBottom: 'var(--space-5)' }}>
              Select all services you can provide. Choose at least one.
            </p>
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(170px, 1fr))', gap: 'var(--space-3)' }}>
              {SKILL_CATEGORIES.map(skill => (
                <label key={skill.value} className={`checkbox-card ${selectedSkills.includes(skill.value) ? 'checked' : ''}`}>
                  <input type="checkbox" checked={selectedSkills.includes(skill.value)}
                    onChange={() => toggleSkill(skill.value)} />
                  <span style={{ fontSize: '1.125rem' }}>{skill.icon}</span>
                  <span>{skill.label}</span>
                </label>
              ))}
            </div>
          </Card>

          {/* Experience */}
          <Card title="Experience & Bio" className="mb-6">
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 200px', gap: 'var(--space-5)', alignItems: 'start' }}>
              <div className="form-group mb-0">
                <label className="form-label">About You</label>
                <textarea
                  className="form-textarea"
                  placeholder="Describe your experience, specializations, and what makes you reliable…"
                  value={bio}
                  onChange={e => setBio(e.target.value)}
                  rows={4}
                />
              </div>
              <Input
                label="Years of Experience"
                type="number"
                min="0"
                max="50"
                value={expYears}
                onChange={e => setExpYears(e.target.value)}
              />
            </div>
          </Card>

          {/* Documents */}
          <Card title="Documents" className="mb-6">
            <div className="form-group">
              <label className="form-label">
                Citizenship Card Photo <span className="form-required">*</span>
              </label>
              <label className="form-file">
                <input type="file" accept="image/*" style={{ display: 'none' }}
                  onChange={e => setCitizenshipFile(e.target.files[0])} required />
                {citizenshipFile
                  ? <span style={{ color: 'var(--success)', fontWeight: 600 }}>✓ {citizenshipFile.name}</span>
                  : <span>📷 Click to upload citizenship card (front side)</span>
                }
              </label>
              <p className="form-hint">Clear photo of your citizenship card.</p>
            </div>
          </Card>

          {/* CTEVT */}
          <Card title="CTEVT Certification (Optional)" className="mb-8">
            <div className="form-group">
              <label className="form-label">Certification Status</label>
              <select className="form-select" value={ctevtStatus} onChange={e => setCtevtStatus(e.target.value)}>
                <option value="pending">Pending / Not Yet Certified</option>
                <option value="certified">I have CTEVT Certification</option>
                <option value="not_applicable">Not Applicable to My Skill</option>
              </select>
              <p className="form-hint">
                CTEVT (Council for Technical Education and Vocational Training) certification adds a trust badge to your profile.
              </p>
            </div>

            {ctevtStatus === 'certified' && (
              <>
                <div className="form-group">
                  <label className="form-label">Upload Certificate</label>
                  <label className="form-file">
                    <input type="file" accept="image/*,.pdf" style={{ display: 'none' }}
                      onChange={e => setCtevtFile(e.target.files[0])} />
                    {ctevtFile
                      ? <span style={{ color: 'var(--success)', fontWeight: 600 }}>✓ {ctevtFile.name}</span>
                      : <span>📎 Upload certificate (image or PDF)</span>
                    }
                  </label>
                </div>
                <Input
                  label="Or Paste Certificate URL"
                  type="url"
                  placeholder="https://ctevt.org.np/..."
                  value={ctevtLink}
                  onChange={e => setCtevtLink(e.target.value)}
                  hint="Link to your CTEVT verification page"
                />
                <Message type="info">
                  Your CTEVT status will be confirmed by the municipality admin during verification.
                </Message>
              </>
            )}
          </Card>

          <Button type="submit" block size="lg" disabled={loading}>
            {loading ? <><span className="spinner spinner-sm" style={{ display: 'inline-block' }} />&nbsp;Submitting…</> : 'Submit for Municipality Verification'}
          </Button>
        </form>
      </div>
    </div>
  );
}
