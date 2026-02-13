// frontend/src/services/courses.js
import api from './api';

export const courseService = {
    /**
     * List courses (public/authenticated)
     * @param {Object} filters - Optional filters (municipality, status)
     * @returns {Promise} Array of courses
     */
    async listCourses(filters = {}) {
        const params = new URLSearchParams();

        Object.keys(filters).forEach(key => {
            if (filters[key] !== null && filters[key] !== undefined && filters[key] !== '') {
                params.append(key, filters[key]);
            }
        });

        const queryString = params.toString();
        const res = await api.get(`/courses/${queryString ? '?' + queryString : ''}`);
        return res.data;
    },

    /**
     * Get course detail by ID
     * @param {number} id - Course ID
     * @returns {Promise} Course data
     */
    async getCourseDetail(id) {
        const res = await api.get(`/courses/${id}/`);
        return res.data;
    },

    /**
     * Create new course (municipality admin only)
     * @param {Object} data - { title, description, municipality, start_date, end_date, capacity, status }
     * @returns {Promise} Created course data
     */
    async createCourse(data) {
        const res = await api.post('/courses/', data);
        return res.data;
    },

    /**
     * Update course (municipality admin only)
     * @param {number} id - Course ID
     * @param {Object} data - Fields to update
     * @returns {Promise} Updated course data
     */
    async updateCourse(id, data) {
        const res = await api.patch(`/courses/${id}/`, data);
        return res.data;
    },

    /**
     * Delete course (municipality admin only)
     * @param {number} id - Course ID
     * @returns {Promise}
     */
    async deleteCourse(id) {
        const res = await api.delete(`/courses/${id}/`);
        return res.data;
    },

    /**
     * List enrollments (filtered by user role on backend)
     * @param {Object} filters - Optional filters (course, status)
     * @returns {Promise} Array of enrollments
     */
    async listEnrollments(filters = {}) {
        const params = new URLSearchParams();

        Object.keys(filters).forEach(key => {
            if (filters[key] !== null && filters[key] !== undefined && filters[key] !== '') {
                params.append(key, filters[key]);
            }
        });

        const queryString = params.toString();
        const res = await api.get(`/enrollments/${queryString ? '?' + queryString : ''}`);
        return res.data;
    },

    /**
     * Enroll in course (provider only)
     * @param {Object} data - { course, notes }
     * @returns {Promise} Created enrollment data
     */
    async enrollInCourse(data) {
        const res = await api.post('/enrollments/', data);
        return res.data;
    },

    /**
     * Update enrollment status (admin only)
     * @param {number} id - Enrollment ID
     * @param {Object} data - { status, admin_notes }
     * @returns {Promise} Updated enrollment data
     */
    async updateEnrollment(id, data) {
        const res = await api.patch(`/enrollments/${id}/`, data);
        return res.data;
    },

    /**
     * Withdraw from course (provider only)
     * @param {number} id - Enrollment ID
     * @returns {Promise} Updated enrollment data
     */
    async withdrawEnrollment(id) {
        const res = await api.post(`/enrollments/${id}/withdraw/`);
        return res.data;
    },
};
