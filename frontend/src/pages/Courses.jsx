// frontend/src/pages/Courses.jsx
import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { courseService } from '../services';
import { useAuth } from '../contexts/AuthContext';
import Button from '../components/common/Button';
import Card from '../components/common/Card';
import LoadingSpinner from '../components/common/LoadingSpinner';

export default function Courses() {
    const navigate = useNavigate();
    const { user } = useAuth();
    const [courses, setCourses] = useState([]);
    const [loading, setLoading] = useState(true);
    const [filter, setFilter] = useState('open'); // open, all

    useEffect(() => {
        loadCourses();
    }, [filter]);

    const loadCourses = async () => {
        try {
            setLoading(true);
            const filters = filter === 'all' ? {} : { status: filter };
            const data = await courseService.listCourses(filters);
            setCourses(data);
        } catch (error) {
            console.error('Failed to load courses:', error);
        } finally {
            setLoading(false);
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
                    <p className="section-title">Training & Upskilling</p>
                    <h1 className="page-title">Available Courses</h1>
                    <p className="page-subtitle">
                        Municipality-organized training programs for service providers
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
                        { key: 'open', label: 'Open for Enrollment' },
                        { key: 'all', label: 'All Courses' },
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

                {loading ? (
                    <LoadingSpinner />
                ) : courses.length === 0 ? (
                    <Card>
                        <div style={{ textAlign: 'center', padding: 'var(--space-8)' }}>
                            <div style={{ fontSize: '3rem', marginBottom: 'var(--space-4)' }}>📚</div>
                            <h3 style={{ marginBottom: 'var(--space-2)' }}>No Courses Available</h3>
                            <p style={{ color: 'var(--text-muted)' }}>
                                {filter === 'open'
                                    ? 'No courses are currently open for enrollment. Check back later!'
                                    : 'No courses have been created yet.'}
                            </p>
                        </div>
                    </Card>
                ) : (
                    <div className="grid grid-2">
                        {courses.map(course => (
                            <Card key={course.id} hover>
                                <div style={{ marginBottom: 'var(--space-4)' }}>
                                    <div style={{
                                        display: 'flex',
                                        justifyContent: 'space-between',
                                        alignItems: 'start',
                                        marginBottom: 'var(--space-3)',
                                    }}>
                                        <h3 style={{ marginBottom: 0 }}>{course.title}</h3>
                                        <span style={{
                                            padding: '4px 10px',
                                            borderRadius: 'var(--r-md)',
                                            fontSize: '0.75rem',
                                            fontWeight: 600,
                                            background: course.status === 'open' ? 'var(--success-pale)' : 'var(--slate-100)',
                                            color: course.status === 'open' ? 'var(--success)' : 'var(--text-muted)',
                                        }}>
                                            {course.status === 'open' ? 'Open' : course.status}
                                        </span>
                                    </div>

                                    <p style={{
                                        color: 'var(--text-muted)',
                                        fontSize: '0.875rem',
                                        marginBottom: 'var(--space-4)',
                                        display: '-webkit-box',
                                        WebkitLineClamp: 2,
                                        WebkitBoxOrient: 'vertical',
                                        overflow: 'hidden',
                                    }}>
                                        {course.description}
                                    </p>

                                    <div style={{
                                        display: 'flex',
                                        gap: 'var(--space-4)',
                                        fontSize: '0.875rem',
                                        color: 'var(--text-muted)',
                                        marginBottom: 'var(--space-4)',
                                    }}>
                                        <div>
                                            <span style={{ marginRight: 'var(--space-1)' }}>📍</span>
                                            {course.municipality_name}
                                        </div>
                                        <div>
                                            <span style={{ marginRight: 'var(--space-1)' }}>📅</span>
                                            {formatDate(course.start_date)}
                                        </div>
                                    </div>

                                    <div style={{
                                        display: 'flex',
                                        justifyContent: 'space-between',
                                        alignItems: 'center',
                                        paddingTop: 'var(--space-3)',
                                        borderTop: '1px solid var(--border)',
                                    }}>
                                        <div style={{ fontSize: '0.875rem', color: 'var(--text-muted)' }}>
                                            <strong>{course.available_slots}</strong> / {course.capacity} slots available
                                        </div>
                                        <Button
                                            size="sm"
                                            onClick={() => navigate(`/courses/${course.id}`)}
                                        >
                                            View Details
                                        </Button>
                                    </div>
                                </div>
                            </Card>
                        ))}
                    </div>
                )}
            </div>
        </div>
    );
}
