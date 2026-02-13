// frontend/src/components/provider/TrustBadges.jsx
import Badge from '../common/Badge';
import { CTEVT_STATUS } from '../../utils/constants';

export default function TrustBadges({ provider, showAll = false }) {
  const { municipality_verified, ctevt_status, avg_rating, jobs_completed } = provider;

  return (
    <div className="flex flex-wrap gap-2" style={{ marginBottom: 'var(--space-4)' }}>
      {municipality_verified && (
        <Badge variant="success">✓ Municipality Verified</Badge>
      )}

      {!municipality_verified && (
        <Badge variant="warning">⏳ Awaiting Verification</Badge>
      )}

      {ctevt_status && ctevt_status !== 'not_applicable' && (
        <Badge variant={CTEVT_STATUS[ctevt_status]?.badge ?? 'secondary'}>
          {ctevt_status === 'certified' ? '🎓 ' : ''}
          {CTEVT_STATUS[ctevt_status]?.label ?? ctevt_status}
        </Badge>
      )}

      {showAll && parseFloat(avg_rating) > 0 && (
        <Badge variant="primary">
          ⭐ {parseFloat(avg_rating).toFixed(1)}
        </Badge>
      )}

      {showAll && jobs_completed > 0 && (
        <Badge variant="secondary">
          {jobs_completed} jobs
        </Badge>
      )}
    </div>
  );
}
