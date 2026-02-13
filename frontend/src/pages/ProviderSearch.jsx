// frontend/src/pages/ProviderSearch.jsx
import { useState, useEffect } from 'react';
import { useAuth } from '../contexts/AuthContext';
import api from '../services/api';
import Card from '../components/common/Card';
import Button from '../components/common/Button';
import Message from '../components/common/Message';
import LoadingSpinner from '../components/common/LoadingSpinner';
import ProviderCard from '../components/provider/ProviderCard';
import { SKILL_CATEGORIES } from '../utils/constants';

export default function ProviderSearch() {
  const { user } = useAuth();
  const [providers, setProviders] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [total, setTotal] = useState(null);

  const [filters, setFilters] = useState({
    skill: '',
    min_rating: '',
    verified_only: false,
    search: '',
  });

  const fetchProviders = async (f = filters) => {
    setLoading(true);
    setError('');
    try {
      const p = new URLSearchParams();
      if (f.skill) p.append('skill', f.skill);
      if (f.min_rating) p.append('min_rating', f.min_rating);
      if (f.verified_only) p.append('verified_only', 'true');
      if (f.search) p.append('search', f.search);

      const res = await api.get(`/providers/search/?${p.toString()}`);
      const results = res.data.results ?? res.data;
      setProviders(results);
      setTotal(res.data.count ?? results.length);
    } catch {
      setError('Failed to load providers. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { fetchProviders(); }, []);

  const handleSearch = (e) => { e.preventDefault(); fetchProviders(); };

  const reset = () => {
    const cleared = { skill: '', min_rating: '', verified_only: false, search: '' };
    setFilters(cleared);
    fetchProviders(cleared);
  };

  const setF = (patch) => setFilters(prev => ({ ...prev, ...patch }));

  return (
    <div className="page">
      <div className="container">
        {/* Page header */}
        <div className="page-header">
          <p className="section-title">Marketplace</p>
          <h1 className="page-title">Find Service Providers</h1>
          <p className="page-subtitle">
            Verified professionals in {user?.municipality_detail?.name}
          </p>
        </div>

        {/* Filters */}
        <Card className="mb-8">
          <form onSubmit={handleSearch}>
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))', gap: 'var(--space-4)', marginBottom: 'var(--space-4)' }}>
              <div className="form-group mb-0">
                <label className="form-label">Search by name</label>
                <input type="text" className="form-input" placeholder="Provider name…"
                  value={filters.search} onChange={e => setF({ search: e.target.value })} />
              </div>

              <div className="form-group mb-0">
                <label className="form-label">Skill</label>
                <select className="form-select" value={filters.skill}
                  onChange={e => setF({ skill: e.target.value })}>
                  <option value="">All Skills</option>
                  {SKILL_CATEGORIES.map(s => (
                    <option key={s.value} value={s.value}>{s.icon} {s.label}</option>
                  ))}
                </select>
              </div>

              <div className="form-group mb-0">
                <label className="form-label">Min. Rating</label>
                <select className="form-select" value={filters.min_rating}
                  onChange={e => setF({ min_rating: e.target.value })}>
                  <option value="">Any Rating</option>
                  <option value="3.0">3.0+ Stars</option>
                  <option value="4.0">4.0+ Stars</option>
                  <option value="4.5">4.5+ Stars</option>
                </select>
              </div>

              <div className="form-group mb-0" style={{ display: 'flex', flexDirection: 'column', justifyContent: 'flex-end' }}>
                <label className="form-label">Verification</label>
                <label className="checkbox-card" style={{ marginTop: 0 }}>
                  <input type="checkbox" checked={filters.verified_only}
                    onChange={e => setF({ verified_only: e.target.checked })} />
                  <span>Municipality verified only</span>
                </label>
              </div>
            </div>

            <div style={{ display: 'flex', gap: 'var(--space-3)', alignItems: 'center' }}>
              <Button type="submit" disabled={loading}>
                {loading ? 'Searching…' : '🔍 Search'}
              </Button>
              <Button type="button" variant="secondary" onClick={reset}>Reset</Button>
              {total !== null && (
                <span style={{ marginLeft: 'auto', color: 'var(--text-muted)', fontSize: '0.875rem' }}>
                  <strong style={{ color: 'var(--text)' }}>{total}</strong> provider{total !== 1 ? 's' : ''} found
                </span>
              )}
            </div>
          </form>
        </Card>

        {error && <Message type="error" onClose={() => setError('')}>{error}</Message>}

        {loading ? (
          <LoadingSpinner message="Searching providers…" />
        ) : providers.length === 0 ? (
          <div className="empty-state">
            <div className="empty-state-icon">🔍</div>
            <div className="empty-state-title">No providers found</div>
            <p style={{ color: 'var(--text-muted)', maxWidth: '360px' }}>
              Try adjusting your filters, or check back later as more providers get verified.
            </p>
            <Button variant="secondary" onClick={reset} className="mt-5">Clear Filters</Button>
          </div>
        ) : (
          <div className="grid grid-2 fade-in">
            {providers.map(p => <ProviderCard key={p.id} provider={p} />)}
          </div>
        )}
      </div>
    </div>
  );
}
