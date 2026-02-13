// frontend/src/pages/CreateBooking.jsx
import { useState, useEffect } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import api from '../services/api';
import Card from '../components/common/Card';
import Input from '../components/common/Input';
import Button from '../components/common/Button';
import Message from '../components/common/Message';
import LoadingSpinner from '../components/common/LoadingSpinner';
import TrustBadges from '../components/provider/TrustBadges';
import { getSkillLabel, getSkillIcon, SKILL_CATEGORIES } from '../utils/constants';

export default function CreateBooking() {
  const navigate = useNavigate();
  const [searchParams] = useSearchParams();
  const providerIdFromQuery = searchParams.get('provider');

  const [provider, setProvider] = useState(null);
  const [loadingProvider, setLoadingProvider] = useState(!!providerIdFromQuery);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const [form, setForm] = useState({
    provider: providerIdFromQuery || '',
    skill_category: '',
    scheduled_time: '',
    description: '',
    amount: '',
  });

  useEffect(() => {
    if (!providerIdFromQuery) return;
    const load = async () => {
      try {
        const res = await api.get(`/providers/${providerIdFromQuery}/`);
        setProvider(res.data);
        // Pre-select first skill if only one
        if (res.data.skill_categories?.length === 1) {
          setForm(f => ({ ...f, skill_category: res.data.skill_categories[0] }));
        }
      } catch {
        setError('Could not load provider details.');
      } finally {
        setLoadingProvider(false);
      }
    };
    load();
  }, [providerIdFromQuery]);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setLoading(true);
    try {
      const res = await api.post('/bookings/', {
        provider: parseInt(form.provider),
        skill_category: form.skill_category,
        scheduled_time: form.scheduled_time,
        description: form.description,
        amount: parseFloat(form.amount),
      });
      navigate(`/bookings/${res.data.id}?created=true`);
    } catch (err) {
      const d = err.response?.data;
      setError(d?.detail || d?.non_field_errors?.[0] || JSON.stringify(d) || 'Failed to create booking.');
    } finally {
      setLoading(false);
    }
  };

  const setF = (patch) => setForm(f => ({ ...f, ...patch }));

  const availableSkills = provider?.skill_categories
    ? SKILL_CATEGORIES.filter(s => provider.skill_categories.includes(s.value))
    : SKILL_CATEGORIES;

  // Minimum datetime: 1 hour from now
  const minDateTime = new Date(Date.now() + 60 * 60 * 1000).toISOString().slice(0, 16);

  return (
    <div className="page">
      <div className="container-md">
        <div className="page-header">
          <p className="section-title">New Booking</p>
          <h1 className="page-title">Book a Service</h1>
        </div>

        {loadingProvider ? (
          <LoadingSpinner message="Loading provider…" />
        ) : (
          <>
            {/* Provider preview */}
            {provider && (
              <Card className="mb-6">
                <div style={{ display: 'flex', alignItems: 'center', gap: 'var(--space-4)' }}>
                  <div style={{
                    width: 56, height: 56, borderRadius: '50%',
                    background: 'var(--saffron)',
                    display: 'flex', alignItems: 'center', justifyContent: 'center',
                    fontWeight: 800, fontSize: '1.5rem', color: 'white', flexShrink: 0,
                  }}>
                    {provider.user_detail?.name?.charAt(0).toUpperCase()}
                  </div>
                  <div style={{ flex: 1 }}>
                    <h3 style={{ marginBottom: 'var(--space-1)' }}>{provider.user_detail?.name}</h3>
                    <p style={{ fontSize: '0.875rem', color: 'var(--text-muted)', marginBottom: 'var(--space-3)' }}>
                      📍 {provider.user_detail?.municipality_detail?.name}
                    </p>
                    <TrustBadges provider={provider} showAll />
                  </div>
                  <Button variant="secondary" size="sm" onClick={() => navigate(`/providers/${provider.id}`)}>
                    View Profile
                  </Button>
                </div>
              </Card>
            )}

            <Card>
              {error && <Message type="error" onClose={() => setError('')}>{error}</Message>}

              <form onSubmit={handleSubmit}>
                {/* Provider ID (if no pre-selected) */}
                {!providerIdFromQuery && (
                  <Input
                    label="Provider ID"
                    type="number"
                    placeholder="Enter provider ID"
                    value={form.provider}
                    onChange={e => setF({ provider: e.target.value })}
                    required
                    hint="You can find the provider ID on their profile page"
                  />
                )}

                {/* Skill */}
                <div className="form-group">
                  <label className="form-label">
                    Service Required <span className="form-required">*</span>
                  </label>
                  <select className="form-select" value={form.skill_category}
                    onChange={e => setF({ skill_category: e.target.value })} required>
                    <option value="">Select a service…</option>
                    {availableSkills.map(s => (
                      <option key={s.value} value={s.value}>{s.icon} {s.label}</option>
                    ))}
                  </select>
                </div>

                {/* Date/time */}
                <Input
                  label="Scheduled Date & Time"
                  type="datetime-local"
                  value={form.scheduled_time}
                  onChange={e => setF({ scheduled_time: e.target.value })}
                  required
                  min={minDateTime}
                />

                {/* Description */}
                <div className="form-group">
                  <label className="form-label">
                    Description <span className="form-required">*</span>
                  </label>
                  <textarea className="form-textarea" rows={4}
                    placeholder="Describe the work you need done, any specific requirements, access instructions…"
                    value={form.description}
                    onChange={e => setF({ description: e.target.value })}
                    required />
                </div>

                {/* Amount */}
                <Input
                  label="Agreed Amount (NPR)"
                  type="number"
                  min="1"
                  step="0.01"
                  placeholder="500"
                  value={form.amount}
                  onChange={e => setF({ amount: e.target.value })}
                  required
                  hint="Agreed service charge in Nepali Rupees"
                />

                {/* Summary */}
                {form.amount && (
                  <div style={{
                    padding: 'var(--space-4)',
                    background: 'var(--saffron-pale)',
                    border: '1px solid rgba(232,129,10,0.3)',
                    borderRadius: 'var(--r-lg)',
                    marginBottom: 'var(--space-6)',
                  }}>
                    <p className="section-title" style={{ marginBottom: 'var(--space-2)' }}>Booking Summary</p>
                    <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                      <span style={{ color: 'var(--text-secondary)' }}>Service Amount</span>
                      <span style={{ fontWeight: 700, color: 'var(--saffron-dark)' }}>NPR {parseFloat(form.amount).toLocaleString()}</span>
                    </div>
                    <p style={{ fontSize: '0.8125rem', color: 'var(--text-muted)', marginTop: 'var(--space-2)', marginBottom: 0 }}>
                      Payment will be processed via mock gateway after booking confirmation.
                    </p>
                  </div>
                )}

                <div style={{ display: 'flex', gap: 'var(--space-4)' }}>
                  <Button type="button" variant="secondary" onClick={() => navigate(-1)}>
                    Cancel
                  </Button>
                  <Button type="submit" disabled={loading} style={{ flex: 1 }}>
                    {loading ? 'Creating Booking…' : 'Confirm Booking →'}
                  </Button>
                </div>
              </form>
            </Card>
          </>
        )}
      </div>
    </div>
  );
}
