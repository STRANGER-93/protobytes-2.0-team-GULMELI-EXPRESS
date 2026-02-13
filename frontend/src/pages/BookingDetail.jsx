// frontend/src/pages/BookingDetail.jsx
import { useState, useEffect } from 'react';
import { useParams, useNavigate, useSearchParams, Link } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';
import { bookingService, paymentService, reviewService } from '../services';
import Card from '../components/common/Card';
import Badge from '../components/common/Badge';
import Button from '../components/common/Button';
import Message from '../components/common/Message';
import LoadingSpinner from '../components/common/LoadingSpinner';
import { BOOKING_STATUS, getSkillLabel, getSkillIcon } from '../utils/constants';

export default function BookingDetail() {
  const { id } = useParams();
  const [searchParams] = useSearchParams();
  const navigate = useNavigate();
  const { user } = useAuth();

  const [booking, setBooking] = useState(null);
  const [loading, setLoading] = useState(true);
  const [actionLoading, setActionLoading] = useState('');
  const [error, setError] = useState('');
  const [success, setSuccess] = useState(searchParams.get('created') ? '🎉 Booking created successfully!' : '');

  const [reviewForm, setReviewForm] = useState({ rating: 5, comment: '' });
  const [submittingReview, setSubmittingReview] = useState(false);
  const [reviewSubmitted, setReviewSubmitted] = useState(false);

  const load = async () => {
    setLoading(true);
    try {
      const data = await bookingService.getBookingDetail(id);
      setBooking(data);
    } catch {
      setError('Booking not found.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { load(); }, [id]);

  const handleAction = async (action) => {
    setActionLoading(action);
    setError('');
    try {
      if (action === 'confirm') await bookingService.confirmBooking(id);
      else if (action === 'complete') await bookingService.completeBooking(id);
      else if (action === 'cancel') await bookingService.cancelBooking(id, { cancellation_reason: 'User cancelled' });
      await load();
      setSuccess(`Booking ${action}ed successfully.`);
    } catch (err) {
      setError(err.response?.data?.detail || `Failed to ${action} booking.`);
    } finally {
      setActionLoading('');
    }
  };

  const handlePayment = async () => {
    setActionLoading('pay');
    try {
      const res = await paymentService.initiatePayment({
        booking: booking.id,
        amount: booking.amount,
        payment_method: 'mock',
      });
      // Simulate 2s payment processing
      setTimeout(async () => {
        try {
          await paymentService.verifyPayment({ payment_reference: res.reference });
          await load();
          setSuccess('💳 Payment successful! Booking is now confirmed.');
        } catch {
          setError('Payment failed. Please try again.');
        } finally {
          setActionLoading('');
        }
      }, 2000);
    } catch (err) {
      setError(err.response?.data?.detail || 'Could not initiate payment.');
      setActionLoading('');
    }
  };

  const handleReview = async (e) => {
    e.preventDefault();
    setSubmittingReview(true);
    try {
      await reviewService.createReview({
        booking: booking.id,
        rating: reviewForm.rating,
        comment: reviewForm.comment,
      });
      setReviewSubmitted(true);
      setSuccess('⭐ Review submitted! Thank you.');
    } catch (err) {
      setError(err.response?.data?.detail || 'Failed to submit review.');
    } finally {
      setSubmittingReview(false);
    }
  };

  if (loading) return <LoadingSpinner message="Loading booking…" />;
  if (error && !booking) return (
    <div className="page container-md">
      <Message type="error">{error}</Message>
      <Link to="/bookings" className="back-link mt-4">← My Bookings</Link>
    </div>
  );
  if (!booking) return null;

  const isCitizen = user?.role === 'citizen';
  const isProvider = user?.role === 'provider';
  const statusInfo = BOOKING_STATUS[booking.status] ?? { label: booking.status, badge: 'secondary' };
  const canReview = isCitizen && booking.status === 'completed' && !booking.review && !reviewSubmitted;

  return (
    <div className="page">
      <div className="container-md">
        <Link to="/bookings" className="back-link">← My Bookings</Link>

        {success && <Message type="success" onClose={() => setSuccess('')}>{success}</Message>}
        {error && <Message type="error" onClose={() => setError('')}>{error}</Message>}

        {/* Main card */}
        <Card className="mb-6">
          {/* Status strip */}
          <div style={{
            margin: '-var(--space-6) -var(--space-6) var(--space-6) -var(--space-6)',
            height: '4px',
            background: booking.status === 'completed' ? 'var(--success)'
              : booking.status === 'confirmed' ? 'var(--info)'
                : booking.status === 'cancelled' ? 'var(--slate-300)'
                  : 'var(--saffron)',
            borderRadius: 'var(--r-xl) var(--r-xl) 0 0',
            marginTop: 'calc(-1 * var(--space-6))',
            marginLeft: 'calc(-1 * var(--space-6))',
            marginRight: 'calc(-1 * var(--space-6))',
          }} />

          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', flexWrap: 'wrap', gap: 'var(--space-4)', marginBottom: 'var(--space-6)' }}>
            <div>
              <div className="flex gap-3" style={{ alignItems: 'center', marginBottom: 'var(--space-2)' }}>
                <h2 style={{ marginBottom: 0 }}>
                  {getSkillIcon(booking.skill_category)} {getSkillLabel(booking.skill_category)}
                </h2>
                <Badge variant={statusInfo.badge}>{statusInfo.label}</Badge>
              </div>
              <p style={{ color: 'var(--text-muted)', fontSize: '0.875rem' }}>
                Booking #{booking.id} &nbsp;·&nbsp; Created {new Date(booking.created_at).toLocaleDateString()}
              </p>
            </div>
            <div style={{ textAlign: 'right' }}>
              <div style={{ fontSize: '1.75rem', fontWeight: 800, color: 'var(--saffron-dark)', letterSpacing: '-0.02em' }}>
                NPR {parseFloat(booking.amount).toLocaleString()}
              </div>
              <Badge variant={booking.payment_status === 'success' ? 'success' : 'warning'}>
                {booking.payment_status === 'success' ? '💳 Paid' : '⏳ Payment pending'}
              </Badge>
            </div>
          </div>

          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 'var(--space-6)' }}>
            <div>
              <p className="section-title">Scheduled For</p>
              <p style={{ fontWeight: 600, color: 'var(--slate-800)' }}>
                {new Date(booking.scheduled_time).toLocaleString()}
              </p>
            </div>
            <div>
              <p className="section-title">Municipality</p>
              <p style={{ fontWeight: 600, color: 'var(--slate-800)' }}>
                {booking.municipality_detail?.name ?? '—'}
              </p>
            </div>
          </div>

          {booking.description && (
            <div style={{ marginTop: 'var(--space-5)', paddingTop: 'var(--space-5)', borderTop: '1px solid var(--border)' }}>
              <p className="section-title">Description</p>
              <p style={{ color: 'var(--text-secondary)', lineHeight: 1.7 }}>{booking.description}</p>
            </div>
          )}

          {booking.completed_at && (
            <div style={{ marginTop: 'var(--space-5)', paddingTop: 'var(--space-5)', borderTop: '1px solid var(--border)' }}>
              <p className="section-title">Completed</p>
              <p style={{ fontWeight: 600, color: 'var(--success)' }}>
                {new Date(booking.completed_at).toLocaleString()}
              </p>
            </div>
          )}
        </Card>

        {/* People cards */}
        <div className="grid grid-2 mb-6">
          {booking.citizen_detail && (
            <Card title="Client">
              <p style={{ fontWeight: 600 }}>{booking.citizen_detail.name}</p>
              <p style={{ color: 'var(--text-muted)', fontSize: '0.875rem' }}>{booking.citizen_detail.phone}</p>
            </Card>
          )}
          {booking.provider_detail && (
            <Card title="Service Provider">
              <p style={{ fontWeight: 600 }}>{booking.provider_detail.user_detail?.name ?? booking.provider_detail.name}</p>
              <Button size="sm" variant="secondary" onClick={() => navigate(`/providers/${booking.provider}`)}>
                View Profile
              </Button>
            </Card>
          )}
        </div>

        {/* Actions */}
        <Card title="Actions" className="mb-6">
          <div className="flex flex-wrap gap-3">
            {/* Payment (citizen, booking pending/no payment) */}
            {isCitizen && booking.status !== 'cancelled' && booking.payment_status !== 'success' && (
              <Button onClick={handlePayment} disabled={actionLoading === 'pay'}>
                {actionLoading === 'pay' ? '⏳ Processing Payment…' : '💳 Pay Now (Mock)'}
              </Button>
            )}

            {/* Provider: confirm */}
            {isProvider && booking.status === 'pending' && (
              <Button variant="success" onClick={() => handleAction('confirm')} disabled={!!actionLoading}>
                {actionLoading === 'confirm' ? 'Confirming…' : '✓ Confirm Booking'}
              </Button>
            )}

            {/* Provider: complete */}
            {isProvider && booking.status === 'confirmed' && (
              <Button variant="success" onClick={() => handleAction('complete')} disabled={!!actionLoading}>
                {actionLoading === 'complete' ? 'Completing…' : '✅ Mark as Completed'}
              </Button>
            )}

            {/* Cancel */}
            {booking.status === 'pending' && (
              <Button variant="danger" onClick={() => handleAction('cancel')} disabled={!!actionLoading}>
                {actionLoading === 'cancel' ? 'Cancelling…' : 'Cancel Booking'}
              </Button>
            )}
          </div>

          {!isCitizen && !isProvider && (
            <p style={{ color: 'var(--text-muted)', fontSize: '0.875rem' }}>No actions available.</p>
          )}
        </Card>

        {/* Review form */}
        {canReview && (
          <Card title="Leave a Review">
            <form onSubmit={handleReview}>
              <div className="form-group">
                <label className="form-label">Rating</label>
                <div className="flex gap-2">
                  {[1, 2, 3, 4, 5].map(n => (
                    <button key={n} type="button" onClick={() => setReviewForm(f => ({ ...f, rating: n }))} style={{
                      fontSize: '1.75rem',
                      background: 'none', border: 'none', cursor: 'pointer',
                      opacity: n <= reviewForm.rating ? 1 : 0.3,
                      transition: 'opacity var(--t-fast)',
                      padding: '4px',
                    }}>
                      ⭐
                    </button>
                  ))}
                  <span style={{ marginLeft: 'var(--space-2)', alignSelf: 'center', fontWeight: 700, color: 'var(--saffron)' }}>
                    {reviewForm.rating} / 5
                  </span>
                </div>
              </div>

              <div className="form-group">
                <label className="form-label">Comment (Optional)</label>
                <textarea className="form-textarea" rows={3}
                  placeholder="Share your experience with this provider…"
                  value={reviewForm.comment}
                  onChange={e => setReviewForm(f => ({ ...f, comment: e.target.value }))} />
              </div>

              <Button type="submit" disabled={submittingReview}>
                {submittingReview ? 'Submitting…' : 'Submit Review'}
              </Button>
            </form>
          </Card>
        )}
      </div>
    </div>
  );
}
