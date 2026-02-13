// frontend/src/pages/CourseDetail.jsx
import { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { courseService } from '../services';
import { useAuth } from '../contexts/AuthContext';
import Button from '../components/common/Button';
import Card from '../components/common/Card';
import LoadingSpinner from '../components/common/LoadingSpinner';
import Message from '../components/common/Message';

export default function CourseDetail() {
    const { id } = useParams();
    const navigate = useNavigate();
    const { user, isAuthenticated } = useAuth();
    const [course, setCourse] = useState(null);
    const [loading, setLoading] = useState(true);
    const [enrolling, setEnrolling] = useState(false);
    const [message, setMessage] = useState(null);
    const [notes, setNotes] = useState('');

    useEffect(() => {
        loadCourse();
    }, [id]);

    const loadCourse = async () => {
        try {
            setLoading(true);
            const data = await courseService.getCourseDetail(id);
            setCourse(data);
        } catch (error) {
            setMessage({ type: 'error', text: 'Failed to load course details' });
        } finally {
            setLoading(false);
        }
    };

    const handleEnroll = async () => {
        if (!isAuthenticated) {
            navigate('/login');
            return;
        }

        if (user.role !== 'provider') {
            setMessage({ type: 'error', text: 'Only providers can enroll in courses' });
            return;
        }

        try {
            setEnrolling(true);
            await courseService.enrollInCourse({ course: id, notes });
            setMessage({ type: 'success', text: 'Enrollment request submitted! Check "My Courses" for status.' });
            setNotes('');
            loadCourse(); // Refresh to update available slots
        } catch (error) {
            const errorMsg = error.response?.data?.course?.[0] ||
                error.response?.data?.detail ||
                'Failed to enroll. Please try again.';
            setMessage({ type: 'error', text: errorMsg });
        } finally {
            setEnrolling(false);
        }
    };

    const formatDate = (dateString) => {
        return new Date(dateString).toLocaleDateString('en-US', {
            year: 'numeric',
            month: 'long',
            day: 'numeric'
        });
    };

    if (loading) return <LoadingSpinner />;
    if (!course) return <Message type="error">Course not found</Message>;

    const canEnroll = isAuthenticated &&
        user?.role === 'provider' &&
        course.status === 'open' &&
        !course.is_full;

    return (
        <div className="page">
            <div className="container" style={{ maxWidth: '900px' }}>
                {/* Back button */}
                <Button variant="secondary" size="sm" onClick={() => navigate('/courses')} style={{ marginBottom: 'var(--space-6)' }}>
                    ← Back to Courses
                </Button>

                {/* Course Header */}
                <div style={{ marginBottom: 'var(--space-8)' }}>
                    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'start', marginBottom: 'var(--space-4)' }}>
                        <div>
                            <p className="section-title">Training Course</p>
                            <h1 className="page-title" style={{ marginBottom: 'var(--space-2)' }}>{course.title}</h1>
                        </div>
                        <span style={{
                            padding: '6px 14px',
                            borderRadius: 'var(--r-md)',
                            fontSize: '0.875rem',
                            fontWeight: 600,
                            background: course.status === 'open' ? 'var(--success-pale)' : 'var(--slate-100)',
                            color: course.status === 'open' ? 'var(--success)' : 'var(--text-muted)',
                        }}>
                            {course.status === 'open' ? 'Open for Enrollment' : course.status}
                        </span>
                    </div>

                    <div style={{ display: 'flex', gap: 'var(--space-6)', fontSize: '0.9375rem', color: 'var(--text-muted)' }}>
                        <div>
                            <span style={{ marginRight: 'var(--space-1)' }}>📍</span>
                            {course.municipality_detail?.name}, {course.municipality_detail?.district}
                        </div>
                        <div>
                            <span style={{ marginRight: 'var(--space-1)' }}>📅</span>
                            {formatDate(course.start_date)} - {formatDate(course.end_date)}
                        </div>
                        <div>
                            <span style={{ marginRight: 'var(--space-1)' }}>👥</span>
                            {course.available_slots} / {course.capacity} slots available
                        </div>
                    </div>
                </div>

                {message && (
                    <Message type={message.type} onClose={() => setMessage(null)}>
                        {message.text}
                    </Message>
                )}

                <div className="grid grid-3-1">
                    {/* Main Content */}
                    <div>
                        <Card>
                            <h3 style={{ marginBottom: 'var(--space-4)' }}>About This Course</h3>
                            <p style={{ color: 'var(--text-muted)', lineHeight: 1.7, whiteSpace: 'pre-wrap' }}>
                                {course.description}
                            </p>
                        </Card>

                        {course.created_by_detail && (
                            <Card style={{ marginTop: 'var(--space-6)' }}>
                                <h4 style={{ marginBottom: 'var(--space-3)' }}>Organized By</h4>
                                <div style={{ display: 'flex', alignItems: 'center', gap: 'var(--space-3)' }}>
                                    <div style={{
                                        width: '48px',
                                        height: '48px',
                                        borderRadius: 'var(--r-md)',
                                        background: 'var(--slate-100)',
                                        display: 'flex',
                                        alignItems: 'center',
                                        justifyContent: 'center',
                                        fontSize: '1.5rem',
                                    }}>
                                        🏛️
                                    </div>
                                    <div>
                                        <div style={{ fontWeight: 600 }}>{course.created_by_detail.name}</div>
                                        <div style={{ fontSize: '0.875rem', color: 'var(--text-muted)' }}>
                                            {course.municipality_detail?.name} Municipality
                                        </div>
                                    </div>
                                </div>
                            </Card>
                        )}
                    </div>

                    {/* Sidebar - Enrollment */}
                    <div>
                        <Card>
                            <h4 style={{ marginBottom: 'var(--space-4)' }}>Enrollment</h4>

                            {!isAuthenticated ? (
                                <>
                                    <p style={{ color: 'var(--text-muted)', fontSize: '0.875rem', marginBottom: 'var(--space-4)' }}>
                                        Sign in as a provider to enroll in this course.
                                    </p>
                                    <Button block onClick={() => navigate('/login')}>
                                        Sign In
                                    </Button>
                                </>
                            ) : user.role !== 'provider' ? (
                                <p style={{ color: 'var(--text-muted)', fontSize: '0.875rem' }}>
                                    Only service providers can enroll in training courses.
                                </p>
                            ) : course.status !== 'open' ? (
                                <p style={{ color: 'var(--text-muted)', fontSize: '0.875rem' }}>
                                    This course is not currently open for enrollment.
                                </p>
                            ) : course.is_full ? (
                                <p style={{ color: 'var(--text-muted)', fontSize: '0.875rem' }}>
                                    This course is full. No more slots available.
                                </p>
                            ) : (
                                <>
                                    <div className="form-group">
                                        <label className="form-label">Why do you want to join? (Optional)</label>
                                        <textarea
                                            className="form-input"
                                            rows="4"
                                            placeholder="Share your motivation or goals..."
                                            value={notes}
                                            onChange={(e) => setNotes(e.target.value)}
                                        />
                                    </div>

                                    <Button
                                        block
                                        onClick={handleEnroll}
                                        disabled={enrolling}
                                    >
                                        {enrolling ? 'Enrolling...' : 'Enroll Now'}
                                    </Button>

                                    <p style={{ fontSize: '0.75rem', color: 'var(--text-muted)', marginTop: 'var(--space-3)', marginBottom: 0 }}>
                                        Your enrollment will be reviewed by the municipality admin.
                                    </p>
                                </>
                            )}
                        </Card>
                    </div>
                </div>
            </div>
        </div>
    );
}
