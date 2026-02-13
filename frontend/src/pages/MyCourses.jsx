// frontend/src/pages/MyCourses.jsx
import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { courseService } from '../services';
import Button from '../components/common/Button';
import Card from '../components/common/Card';
import LoadingSpinner from '../components/common/LoadingSpinner';
import Message from '../components/common/Message';

export default function MyCourses() {
    const navigate = useNavigate();
    const [enrollments, setEnrollments] = useState([]);
    const [loading, setLoading] = useState(true);
    const [filter, setFilter] = useState('all'); // all, pending, approved
    const [message, setMessage] = useState(null);

    useEffect(() => {
        loadEnrollments();
    }, [filter]);

    const loadEnrollments = async () => {
        try {
            setLoading(true);
            const filters = filter === 'all' ? {} : { status: filter };
            const data = await courseService.listEnrollments(filters);
            setEnrollments(data);
        } catch (error) {
            console.error('Failed to load enrollments:', error);
        } finally {
            setLoading(false);
        }
    };

    const handleWithdraw = async (id) => {
        if (!confirm('Are you sure you want to withdraw from this course?')) return;

        try {
            await courseService.withdrawEnrollment(id);
            setMessage({ type: 'success', text: 'Successfully withdrawn from course' });
            loadEnrollments();
        } catch (error) {
            setMessage({ type: 'error', text: 'Failed to withdraw. Please try again.' });
        }
    };

    const formatDate = (dateString) => {
        return new Date(dateString).toLocaleDateString('en-US', {
            year: 'numeric',
            month: 'short',
            day: 'numeric'
        });
    };

    const getStatusColor = (status) => {
        switch (status) {
            case 'approved': return { bg: 'var(--success-pale)', color: 'var(--success)' };
            case 'pending': return { bg: 'var(--warning-pale)', color: 'var(--warning)' };
            case 'rejected': return { bg: 'var(--error-pale)', color: 'var(--error)' };
            case 'withdrawn': return { bg: 'var(--slate-100)', color: 'var(--text-muted)' };
            default: return { bg: 'var(--slate-100)', color: 'var(--text-muted)' };
        }
    };

    return (
        <div className="page">
            <div className="container">
                <div className="page-header">
                    <p className="section-title">Provider Portal</p>
                    <h1 className="page-title">My Courses</h1>
                    <p className="page-subtitle">
                        View and manage your course enrollments
                    </p>
                </div>

                {/* Filter Tabs */}
                <div style={{
                    display: 'flex',
                    gap: 'var(--space-2)',
                    marginBottom: 'var(--space-6)',
                    borderBottom: '1px solid var(--border)',
                }}>
                    {[
                        { key: 'all', label: 'All Enrollments' },
                        { key: 'pending', label: 'Pending' },
                        { key: 'approved', label: 'Approved' },
                    ].map(tab => (
                        <button
                            key={tab.key}
                            onClick={() => setFilter(tab.key)}
                            style={{
                                padding: 'var(--space-3) var(--space-4)',
                                background: 'none',
                                border: 'none',
                                borderBottom: filter === tab.key ? '2px solid var(--primary)' : '2px solid transparent',
                                color: filter === tab.key ? 'var(--primary)' : 'var(--text-muted)',
                                fontWeight: filter === tab.key ? 600 : 400,
                                cursor: 'pointer',
                                transition: 'all 0.2s',
                            }}
                        >
                            {tab.label}
                        </button>
                    ))}
                </div>

                {message && (
                    <Message type={message.type} onClose={() => setMessage(null)}>
                        {message.text}
                    </Message>
                )}

                {loading ? (
                    <LoadingSpinner />
                ) : enrollments.length === 0 ? (
                    <Card>
                        <div style={{ textAlign: 'center', padding: 'var(--space-8)' }}>
                            <div style={{ fontSize: '3rem', marginBottom: 'var(--space-4)' }}>📚</div>
                            <h3 style={{ marginBottom: 'var(--space-2)' }}>No Enrollments Yet</h3>
                            <p style={{ color: 'var(--text-muted)', marginBottom: 'var(--space-6)' }}>
                                Browse available courses and enroll to upskill yourself.
                            </p>
                            <Button onClick={() => navigate('/courses')}>
                                Browse Courses
                            </Button>
                        </div>
                    </Card>
                ) : (
                    <div style={{ display: 'flex', flexDirection: 'column', gap: 'var(--space-4)' }}>
                        {enrollments.map(enrollment => {
                            const statusStyle = getStatusColor(enrollment.status);
                            return (
                                <Card key={enrollment.id}>
                                    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'start' }}>
                                        <div style={{ flex: 1 }}>
                                            <div style={{ display: 'flex', alignItems: 'center', gap: 'var(--space-3)', marginBottom: 'var(--space-2)' }}>
                                                <h3 style={{ marginBottom: 0 }}>{enrollment.course_detail.title}</h3>
                                                <span style={{
                                                    padding: '4px 10px',
                                                    borderRadius: 'var(--r-md)',
                                                    fontSize: '0.75rem',
                                                    fontWeight: 600,
                                                    background: statusStyle.bg,
                                                    color: statusStyle.color,
                                                }}>
                                                    {enrollment.status}
                                                </span>
                                            </div>

                                            <div style={{
                                                display: 'flex',
                                                gap: 'var(--space-4)',
                                                fontSize: '0.875rem',
                                                color: 'var(--text-muted)',
                                                marginBottom: 'var(--space-3)',
                                            }}>
                                                <div>
                                                    <span style={{ marginRight: 'var(--space-1)' }}>📍</span>
                                                    {enrollment.course_detail.municipality_name}
                                                </div>
                                                <div>
                                                    <span style={{ marginRight: 'var(--space-1)' }}>📅</span>
                                                    {formatDate(enrollment.course_detail.start_date)}
                                                </div>
                                                <div>
                                                    <span style={{ marginRight: 'var(--space-1)' }}>🕒</span>
                                                    Enrolled {formatDate(enrollment.enrolled_at)}
                                                </div>
                                            </div>

                                            {enrollment.notes && (
                                                <div style={{
                                                    padding: 'var(--space-3)',
                                                    background: 'var(--slate-50)',
                                                    borderRadius: 'var(--r-md)',
                                                    fontSize: '0.875rem',
                                                    marginBottom: 'var(--space-3)',
                                                }}>
                                                    <strong>Your notes:</strong> {enrollment.notes}
                                                </div>
                                            )}

                                            {enrollment.admin_notes && (
                                                <div style={{
                                                    padding: 'var(--space-3)',
                                                    background: enrollment.status === 'approved' ? 'var(--success-pale)' : 'var(--error-pale)',
                                                    borderRadius: 'var(--r-md)',
                                                    fontSize: '0.875rem',
                                                }}>
                                                    <strong>Admin notes:</strong> {enrollment.admin_notes}
                                                </div>
                                            )}
                                        </div>

                                        <div style={{ display: 'flex', gap: 'var(--space-2)', marginLeft: 'var(--space-4)' }}>
                                            <Button
                                                size="sm"
                                                variant="secondary"
                                                onClick={() => navigate(`/courses/${enrollment.course_detail.id}`)}
                                            >
                                                View Course
                                            </Button>
                                            {enrollment.status === 'pending' && (
                                                <Button
                                                    size="sm"
                                                    variant="danger"
                                                    onClick={() => handleWithdraw(enrollment.id)}
                                                >
                                                    Withdraw
                                                </Button>
                                            )}
                                        </div>
                                    </div>
                                </Card>
                            );
                        })}
                    </div>
                )}
            </div>
        </div>
    );
}
