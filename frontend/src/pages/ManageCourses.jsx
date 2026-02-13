// frontend/src/pages/ManageCourses.jsx
import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { courseService } from '../services';
import { useAuth } from '../contexts/AuthContext';
import Button from '../components/common/Button';
import Card from '../components/common/Card';
import LoadingSpinner from '../components/common/LoadingSpinner';
import Message from '../components/common/Message';

export default function ManageCourses() {
    const navigate = useNavigate();
    const { user } = useAuth();
    const [courses, setCourses] = useState([]);
    const [enrollments, setEnrollments] = useState([]);
    const [loading, setLoading] = useState(true);
    const [view, setView] = useState('courses'); // courses, enrollments
    const [message, setMessage] = useState(null);
    const [showCreateForm, setShowCreateForm] = useState(false);
    const [formData, setFormData] = useState({
        title: '',
        description: '',
        start_date: '',
        end_date: '',
        capacity: 20,
        status: 'draft',
    });

    useEffect(() => {
        if (view === 'courses') loadCourses();
        else loadEnrollments();
    }, [view]);

    const loadCourses = async () => {
        try {
            setLoading(true);
            const data = await courseService.listCourses();
            setCourses(data);
        } catch (error) {
            console.error('Failed to load courses:', error);
        } finally {
            setLoading(false);
        }
    };

    const loadEnrollments = async () => {
        try {
            setLoading(true);
            const data = await courseService.listEnrollments();
            setEnrollments(data);
        } catch (error) {
            console.error('Failed to load enrollments:', error);
        } finally {
            setLoading(false);
        }
    };

    const handleCreateCourse = async (e) => {
        e.preventDefault();
        try {
            await courseService.createCourse({
                ...formData,
                municipality: user.municipality,
            });
            setMessage({ type: 'success', text: 'Course created successfully!' });
            setShowCreateForm(false);
            setFormData({ title: '', description: '', start_date: '', end_date: '', capacity: 20, status: 'draft' });
            loadCourses();
        } catch (error) {
            setMessage({ type: 'error', text: 'Failed to create course. Please try again.' });
        }
    };

    const handleUpdateEnrollment = async (id, status, admin_notes = '') => {
        try {
            await courseService.updateEnrollment(id, { status, admin_notes });
            setMessage({ type: 'success', text: `Enrollment ${status}!` });
            loadEnrollments();
        } catch (error) {
            setMessage({ type: 'error', text: 'Failed to update enrollment.' });
        }
    };

    const formatDate = (dateString) => {
        return new Date(dateString).toLocaleDateString('en-US', {
            year: 'numeric',
            month: 'short',
            day: 'numeric'
        });
    };

    return (
        <div className="page">
            <div className="container">
                <div className="page-header">
                    <p className="section-title">Municipality Admin</p>
                    <h1 className="page-title">Manage Courses</h1>
                    <p className="page-subtitle">
                        Create and manage training courses for service providers
                    </p>
                </div>

                {/* View Tabs */}
                <div style={{
                    display: 'flex',
                    gap: 'var(--space-2)',
                    marginBottom: 'var(--space-6)',
                    borderBottom: '1px solid var(--border)',
                }}>
                    {[
                        { key: 'courses', label: 'My Courses' },
                        { key: 'enrollments', label: 'Enrollment Requests' },
                    ].map(tab => (
                        <button
                            key={tab.key}
                            onClick={() => setView(tab.key)}
                            style={{
                                padding: 'var(--space-3) var(--space-4)',
                                background: 'none',
                                border: 'none',
                                borderBottom: view === tab.key ? '2px solid var(--primary)' : '2px solid transparent',
                                color: view === tab.key ? 'var(--primary)' : 'var(--text-muted)',
                                fontWeight: view === tab.key ? 600 : 400,
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

                {view === 'courses' && (
                    <>
                        <div style={{ marginBottom: 'var(--space-6)' }}>
                            <Button onClick={() => setShowCreateForm(!showCreateForm)}>
                                {showCreateForm ? 'Cancel' : '+ Create New Course'}
                            </Button>
                        </div>

                        {showCreateForm && (
                            <Card style={{ marginBottom: 'var(--space-6)' }}>
                                <h3 style={{ marginBottom: 'var(--space-4)' }}>Create New Course</h3>
                                <form onSubmit={handleCreateCourse}>
                                    <div className="form-group">
                                        <label className="form-label">Course Title *</label>
                                        <input
                                            type="text"
                                            className="form-input"
                                            required
                                            value={formData.title}
                                            onChange={(e) => setFormData({ ...formData, title: e.target.value })}
                                        />
                                    </div>

                                    <div className="form-group">
                                        <label className="form-label">Description *</label>
                                        <textarea
                                            className="form-input"
                                            rows="4"
                                            required
                                            value={formData.description}
                                            onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                                        />
                                    </div>

                                    <div className="grid grid-2">
                                        <div className="form-group">
                                            <label className="form-label">Start Date *</label>
                                            <input
                                                type="date"
                                                className="form-input"
                                                required
                                                value={formData.start_date}
                                                onChange={(e) => setFormData({ ...formData, start_date: e.target.value })}
                                            />
                                        </div>

                                        <div className="form-group">
                                            <label className="form-label">End Date *</label>
                                            <input
                                                type="date"
                                                className="form-input"
                                                required
                                                value={formData.end_date}
                                                onChange={(e) => setFormData({ ...formData, end_date: e.target.value })}
                                            />
                                        </div>
                                    </div>

                                    <div className="grid grid-2">
                                        <div className="form-group">
                                            <label className="form-label">Capacity *</label>
                                            <input
                                                type="number"
                                                className="form-input"
                                                required
                                                min="1"
                                                value={formData.capacity}
                                                onChange={(e) => setFormData({ ...formData, capacity: parseInt(e.target.value) })}
                                            />
                                        </div>

                                        <div className="form-group">
                                            <label className="form-label">Status *</label>
                                            <select
                                                className="form-select"
                                                value={formData.status}
                                                onChange={(e) => setFormData({ ...formData, status: e.target.value })}
                                            >
                                                <option value="draft">Draft</option>
                                                <option value="open">Open for Enrollment</option>
                                                <option value="closed">Closed</option>
                                            </select>
                                        </div>
                                    </div>

                                    <Button type="submit">Create Course</Button>
                                </form>
                            </Card>
                        )}

                        {loading ? (
                            <LoadingSpinner />
                        ) : courses.length === 0 ? (
                            <Card>
                                <div style={{ textAlign: 'center', padding: 'var(--space-8)' }}>
                                    <div style={{ fontSize: '3rem', marginBottom: 'var(--space-4)' }}>📚</div>
                                    <h3 style={{ marginBottom: 'var(--space-2)' }}>No Courses Yet</h3>
                                    <p style={{ color: 'var(--text-muted)' }}>
                                        Create your first training course for service providers.
                                    </p>
                                </div>
                            </Card>
                        ) : (
                            <div className="grid grid-2">
                                {courses.map(course => (
                                    <Card key={course.id}>
                                        <div style={{ marginBottom: 'var(--space-3)' }}>
                                            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'start', marginBottom: 'var(--space-2)' }}>
                                                <h3 style={{ marginBottom: 0 }}>{course.title}</h3>
                                                <span style={{
                                                    padding: '4px 10px',
                                                    borderRadius: 'var(--r-md)',
                                                    fontSize: '0.75rem',
                                                    fontWeight: 600,
                                                    background: course.status === 'open' ? 'var(--success-pale)' : 'var(--slate-100)',
                                                    color: course.status === 'open' ? 'var(--success)' : 'var(--text-muted)',
                                                }}>
                                                    {course.status}
                                                </span>
                                            </div>

                                            <p style={{ color: 'var(--text-muted)', fontSize: '0.875rem', marginBottom: 'var(--space-3)' }}>
                                                {course.description.substring(0, 100)}...
                                            </p>

                                            <div style={{ fontSize: '0.875rem', color: 'var(--text-muted)', marginBottom: 'var(--space-3)' }}>
                                                📅 {formatDate(course.start_date)} - {formatDate(course.end_date)}
                                            </div>

                                            <div style={{ fontSize: '0.875rem', color: 'var(--text-muted)' }}>
                                                👥 {course.available_slots} / {course.capacity} slots available
                                            </div>
                                        </div>
                                    </Card>
                                ))}
                            </div>
                        )}
                    </>
                )}

                {view === 'enrollments' && (
                    <>
                        {loading ? (
                            <LoadingSpinner />
                        ) : enrollments.length === 0 ? (
                            <Card>
                                <div style={{ textAlign: 'center', padding: 'var(--space-8)' }}>
                                    <div style={{ fontSize: '3rem', marginBottom: 'var(--space-4)' }}>📋</div>
                                    <h3 style={{ marginBottom: 'var(--space-2)' }}>No Enrollment Requests</h3>
                                    <p style={{ color: 'var(--text-muted)' }}>
                                        Enrollment requests will appear here for review.
                                    </p>
                                </div>
                            </Card>
                        ) : (
                            <div style={{ display: 'flex', flexDirection: 'column', gap: 'var(--space-4)' }}>
                                {enrollments.map(enrollment => (
                                    <Card key={enrollment.id}>
                                        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'start' }}>
                                            <div style={{ flex: 1 }}>
                                                <h4 style={{ marginBottom: 'var(--space-2)' }}>
                                                    {enrollment.provider_detail.name}
                                                </h4>
                                                <div style={{ fontSize: '0.875rem', color: 'var(--text-muted)', marginBottom: 'var(--space-2)' }}>
                                                    📞 {enrollment.provider_detail.phone}
                                                </div>
                                                <div style={{ fontSize: '0.875rem', color: 'var(--text-muted)', marginBottom: 'var(--space-3)' }}>
                                                    📚 Course: <strong>{enrollment.course_detail.title}</strong>
                                                </div>

                                                {enrollment.notes && (
                                                    <div style={{
                                                        padding: 'var(--space-3)',
                                                        background: 'var(--slate-50)',
                                                        borderRadius: 'var(--r-md)',
                                                        fontSize: '0.875rem',
                                                        marginBottom: 'var(--space-3)',
                                                    }}>
                                                        <strong>Provider notes:</strong> {enrollment.notes}
                                                    </div>
                                                )}

                                                <div style={{ fontSize: '0.75rem', color: 'var(--text-muted)' }}>
                                                    Enrolled: {formatDate(enrollment.enrolled_at)}
                                                </div>
                                            </div>

                                            {enrollment.status === 'pending' && (
                                                <div style={{ display: 'flex', gap: 'var(--space-2)', marginLeft: 'var(--space-4)' }}>
                                                    <Button
                                                        size="sm"
                                                        onClick={() => handleUpdateEnrollment(enrollment.id, 'approved', 'Approved - meets requirements')}
                                                    >
                                                        Approve
                                                    </Button>
                                                    <Button
                                                        size="sm"
                                                        variant="danger"
                                                        onClick={() => {
                                                            const reason = prompt('Rejection reason:');
                                                            if (reason) handleUpdateEnrollment(enrollment.id, 'rejected', reason);
                                                        }}
                                                    >
                                                        Reject
                                                    </Button>
                                                </div>
                                            )}

                                            {enrollment.status !== 'pending' && (
                                                <span style={{
                                                    padding: '6px 12px',
                                                    borderRadius: 'var(--r-md)',
                                                    fontSize: '0.75rem',
                                                    fontWeight: 600,
                                                    background: enrollment.status === 'approved' ? 'var(--success-pale)' : 'var(--error-pale)',
                                                    color: enrollment.status === 'approved' ? 'var(--success)' : 'var(--error)',
                                                }}>
                                                    {enrollment.status}
                                                </span>
                                            )}
                                        </div>
                                    </Card>
                                ))}
                            </div>
                        )}
                    </>
                )}
            </div>
        </div>
    );
}
