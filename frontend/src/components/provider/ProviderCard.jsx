// frontend/src/components/provider/ProviderCard.jsx
import { useNavigate } from 'react-router-dom';
import Button from '../common/Button';
import TrustBadges from './TrustBadges';
import { getSkillLabel, getSkillIcon } from '../../utils/constants';

export default function ProviderCard({ provider }) {
  const navigate = useNavigate();
  const { user_detail, skill_categories, bio, experience_years, avg_rating, jobs_completed } = provider;

  return (
    <div style={{
      background: 'var(--bg-white)',
      border: '1px solid var(--border)',
      borderRadius: 'var(--r-xl)',
      overflow: 'hidden',
      transition: 'all var(--t-base)',
      boxShadow: 'var(--shadow-sm)',
    }}
    onMouseEnter={e => {
      e.currentTarget.style.boxShadow = 'var(--shadow-md)';
      e.currentTarget.style.transform = 'translateY(-2px)';
      e.currentTarget.style.borderColor = 'var(--saffron)';
    }}
    onMouseLeave={e => {
      e.currentTarget.style.boxShadow = 'var(--shadow-sm)';
      e.currentTarget.style.transform = 'translateY(0)';
      e.currentTarget.style.borderColor = 'var(--border)';
    }}
    >
      {/* Colored top strip based on verification */}
      <div style={{
        height: '4px',
        background: provider.municipality_verified
          ? 'linear-gradient(90deg, var(--success), var(--saffron))'
          : 'var(--slate-200)',
      }} />

      <div style={{ padding: 'var(--space-5)' }}>
        {/* Header */}
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: 'var(--space-4)' }}>
          <div style={{ flex: 1, minWidth: 0 }}>
            <h3 style={{
              fontSize: '1.0625rem',
              fontWeight: 700,
              color: 'var(--slate-900)',
              marginBottom: 'var(--space-1)',
              letterSpacing: '-0.01em',
            }}>
              {user_detail?.name}
            </h3>
            <p style={{ fontSize: '0.8125rem', color: 'var(--text-muted)' }}>
              📍 {user_detail?.municipality_detail?.name}
            </p>
          </div>
          {user_detail?.photo ? (
            <img
              src={user_detail.photo}
              alt={user_detail.name}
              style={{ width: 48, height: 48, borderRadius: '50%', objectFit: 'cover', flexShrink: 0, marginLeft: 'var(--space-3)', border: '2px solid var(--border)' }}
            />
          ) : (
            <div style={{
              width: 48, height: 48, borderRadius: '50%',
              background: 'var(--saffron)',
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              fontWeight: 700, fontSize: '1.25rem', color: 'white',
              flexShrink: 0, marginLeft: 'var(--space-3)',
            }}>
              {user_detail?.name?.charAt(0).toUpperCase()}
            </div>
          )}
        </div>

        <TrustBadges provider={provider} showAll />

        {/* Skills */}
        <div style={{ marginBottom: 'var(--space-4)' }}>
          <div className="flex flex-wrap gap-2">
            {skill_categories?.slice(0, 3).map(skill => (
              <span key={skill} style={{
                fontSize: '0.8125rem',
                color: 'var(--slate-600)',
                background: 'var(--slate-100)',
                padding: '2px 10px',
                borderRadius: 'var(--r-pill)',
                fontWeight: 500,
              }}>
                {getSkillIcon(skill)} {getSkillLabel(skill)}
              </span>
            ))}
            {skill_categories?.length > 3 && (
              <span style={{ fontSize: '0.8125rem', color: 'var(--text-muted)' }}>
                +{skill_categories.length - 3} more
              </span>
            )}
          </div>
        </div>

        {/* Stats row */}
        <div style={{
          display: 'flex',
          gap: 'var(--space-4)',
          paddingTop: 'var(--space-4)',
          borderTop: '1px solid var(--border)',
          marginBottom: 'var(--space-4)',
        }}>
          <div>
            <div style={{ fontSize: '1.125rem', fontWeight: 700, color: 'var(--slate-800)', lineHeight: 1.2 }}>
              {parseFloat(avg_rating || 0).toFixed(1)}
            </div>
            <div style={{ fontSize: '0.6875rem', color: 'var(--text-muted)', textTransform: 'uppercase', letterSpacing: '0.06em' }}>
              Rating
            </div>
          </div>
          <div>
            <div style={{ fontSize: '1.125rem', fontWeight: 700, color: 'var(--slate-800)', lineHeight: 1.2 }}>
              {jobs_completed || 0}
            </div>
            <div style={{ fontSize: '0.6875rem', color: 'var(--text-muted)', textTransform: 'uppercase', letterSpacing: '0.06em' }}>
              Jobs
            </div>
          </div>
          {experience_years > 0 && (
            <div>
              <div style={{ fontSize: '1.125rem', fontWeight: 700, color: 'var(--slate-800)', lineHeight: 1.2 }}>
                {experience_years}y
              </div>
              <div style={{ fontSize: '0.6875rem', color: 'var(--text-muted)', textTransform: 'uppercase', letterSpacing: '0.06em' }}>
                Exp
              </div>
            </div>
          )}
        </div>

        <Button block onClick={() => navigate(`/providers/${provider.id}`)}>
          View Profile
        </Button>
      </div>
    </div>
  );
}
