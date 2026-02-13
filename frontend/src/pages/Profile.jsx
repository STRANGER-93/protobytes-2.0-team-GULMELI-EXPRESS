// frontend/src/pages/Profile.jsx
import { useState, useRef } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';
import { authService } from '../services/auth';
import Card from '../components/common/Card';
import Button from '../components/common/Button';
import Input from '../components/common/Input';
import Message from '../components/common/Message';
import Badge from '../components/common/Badge';

export default function Profile() {
  const { user, updateUser, logout } = useAuth();
  const navigate = useNavigate();
  const fileRef = useRef();

  const [name, setName] = useState(user?.name || '');
  const [photo, setPhoto] = useState(null);
  const [photoPreview, setPhotoPreview] = useState(user?.photo || null);
  const [loading, setLoading] = useState(false);
  const [success, setSuccess] = useState('');
  const [error, setError] = useState('');

  const handlePhotoChange = (e) => {
    const file = e.target.files[0];
    if (!file) return;
    setPhoto(file);
    const reader = new FileReader();
    reader.onload = () => setPhotoPreview(reader.result);
    reader.readAsDataURL(file);
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setSuccess('');
    setLoading(true);
    try {
      const data = { name };
      if (photo) data.photo = photo;
      const updated = await authService.updateProfile(data);
      updateUser(updated);
      setSuccess('Profile updated successfully!');
      setPhoto(null);
    } catch (err) {
      setError(err.response?.data?.detail || 'Failed to update profile.');
    } finally {
      setLoading(false);
    }
  };

  const handleLogout = () => {
    logout();
    navigate('/login');
  };

  const getRoleBadge = () => {
    const map = {
      citizen: { label: 'Citizen', variant: 'info' },
      provider: { label: 'Service Provider', variant: 'primary' },
      municipality_admin: { label: 'Municipality Admin', variant: 'success' },
    };
    return map[user?.role] ?? { label: user?.role, variant: 'secondary' };
  };

  const rb = getRoleBadge();

  return (
    <div className="page">
      <div className="container-sm">
        <div className="page-header">
          <p className="section-title">Account</p>
          <h1 className="page-title">My Profile</h1>
        </div>

        {/* Profile hero */}
        <Card className="mb-6">
          <div style={{ display: 'flex', alignItems: 'center', gap: 'var(--space-5)', flexWrap: 'wrap' }}>
            {/* Avatar */}
            <div style={{ position: 'relative', flexShrink: 0 }}>
              {photoPreview ? (
                <img src={photoPreview} alt="Profile"
                  style={{ width: 80, height: 80, borderRadius: '50%', objectFit: 'cover', border: '3px solid var(--border)' }} />
              ) : (
                <div style={{
                  width: 80, height: 80, borderRadius: '50%',
                  background: 'linear-gradient(135deg, var(--saffron), var(--saffron-dark))',
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                  fontWeight: 800, fontSize: '2rem', color: 'white',
                }}>
                  {user?.name?.charAt(0).toUpperCase()}
                </div>
              )}
              <button onClick={() => fileRef.current?.click()} style={{
                position: 'absolute', bottom: 0, right: 0,
                width: '24px', height: '24px',
                background: 'var(--saffron)', border: '2px solid white',
                borderRadius: '50%', display: 'flex', alignItems: 'center', justifyContent: 'center',
                cursor: 'pointer', fontSize: '0.625rem', color: 'white', fontWeight: 700,
              }} title="Change photo">✎</button>
              <input ref={fileRef} type="file" accept="image/*" style={{ display: 'none' }} onChange={handlePhotoChange} />
            </div>

            <div>
              <h2 style={{ marginBottom: 'var(--space-2)' }}>{user?.name}</h2>
              <div className="flex gap-2 flex-wrap" style={{ marginBottom: 'var(--space-2)' }}>
                <Badge variant={rb.variant}>{rb.label}</Badge>
              </div>
              <p style={{ color: 'var(--text-muted)', fontSize: '0.875rem' }}>
                📍 {user?.municipality_detail?.name}, {user?.municipality_detail?.district}
              </p>
              <p style={{ color: 'var(--text-muted)', fontSize: '0.875rem' }}>
                📱 {user?.phone}
              </p>
            </div>
          </div>
        </Card>

        {/* Edit form */}
        <Card title="Edit Profile" className="mb-6">
          {success && <Message type="success" onClose={() => setSuccess('')}>{success}</Message>}
          {error && <Message type="error" onClose={() => setError('')}>{error}</Message>}

          <form onSubmit={handleSubmit}>
            <Input
              label="Full Name"
              value={name}
              onChange={e => setName(e.target.value)}
              required
            />

            <div className="form-group">
              <label className="form-label">Phone Number</label>
              <input className="form-input" value={user?.phone} disabled
                style={{ opacity: 0.6, cursor: 'not-allowed', background: 'var(--bg)' }} />
              <p className="form-hint">Phone number cannot be changed. It is your primary identifier.</p>
            </div>

            <div className="form-group">
              <label className="form-label">Municipality</label>
              <input className="form-input" value={`${user?.municipality_detail?.name}, ${user?.municipality_detail?.district}`}
                disabled style={{ opacity: 0.6, cursor: 'not-allowed', background: 'var(--bg)' }} />
              <p className="form-hint">Contact support to change your municipality.</p>
            </div>

            <div style={{ display: 'flex', gap: 'var(--space-4)' }}>
              <Button type="submit" disabled={loading}>
                {loading ? 'Saving…' : 'Save Changes'}
              </Button>
              {user?.role === 'provider' && (
                <Button type="button" variant="secondary" onClick={() => navigate('/provider/dashboard')}>
                  Provider Dashboard
                </Button>
              )}
            </div>
          </form>
        </Card>

        {/* Role-specific quick links */}
        <Card title="Quick Links" className="mb-6">
          <div style={{ display: 'flex', flexDirection: 'column', gap: 'var(--space-3)' }}>
            {user?.role === 'citizen' && (
              <>
                <Button block variant="secondary" onClick={() => navigate('/providers/search')}>
                  🔍 Find Service Providers
                </Button>
                <Button block variant="secondary" onClick={() => navigate('/bookings')}>
                  📋 My Bookings
                </Button>
              </>
            )}
            {user?.role === 'provider' && (
              <>
                <Button block variant="secondary" onClick={() => navigate('/provider/dashboard')}>
                  📊 Provider Dashboard
                </Button>
                <Button block variant="secondary" onClick={() => navigate('/provider/bookings')}>
                  📋 My Bookings
                </Button>
              </>
            )}
            {user?.role === 'municipality_admin' && (
              <>
                <Button block variant="secondary" onClick={() => navigate('/admin/dashboard')}>
                  📊 Municipal Dashboard
                </Button>
                <Button block variant="secondary" onClick={() => navigate('/admin/providers')}>
                  ✓ Provider Verification
                </Button>
              </>
            )}
          </div>
        </Card>

        {/* Danger zone */}
        <Card>
          <h3 style={{ marginBottom: 'var(--space-3)', color: 'var(--danger)' }}>Sign Out</h3>
          <p style={{ color: 'var(--text-muted)', fontSize: '0.875rem', marginBottom: 'var(--space-4)' }}>
            You will be returned to the login screen.
          </p>
          <Button variant="danger" onClick={handleLogout}>
            Sign Out of JanSewa
          </Button>
        </Card>
      </div>
    </div>
  );
}
