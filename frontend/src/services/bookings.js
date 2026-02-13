// frontend/src/services/bookings.js
import api from './api';

export const bookingService = {
    /**
     * List bookings (filtered by user role automatically on backend)
     * @param {Object} filters - Optional filters
     * @returns {Promise} Array of bookings
     */
    async listBookings(filters = {}) {
        const params = new URLSearchParams();

        Object.keys(filters).forEach(key => {
            if (filters[key] !== null && filters[key] !== undefined && filters[key] !== '') {
                params.append(key, filters[key]);
            }
        });

        const queryString = params.toString();
        const res = await api.get(`/bookings/${queryString ? '?' + queryString : ''}`);
        return res.data;
    },

    /**
     * Create new booking
     * @param {Object} data - { provider, skill_category, scheduled_time, description, location_address, amount }
     * @returns {Promise} Created booking data
     */
    async createBooking(data) {
        const res = await api.post('/bookings/create/', data);
        return res.data;
    },

    /**
     * Get booking detail by ID
     * @param {number} id - Booking ID
     * @returns {Promise} Booking data
     */
    async getBookingDetail(id) {
        const res = await api.get(`/bookings/${id}/`);
        return res.data;
    },

    /**
     * Confirm booking (provider only)
     * @param {number} id - Booking ID
     * @returns {Promise} Updated booking data
     */
    async confirmBooking(id) {
        const res = await api.post(`/bookings/${id}/confirm/`);
        return res.data;
    },

    /**
     * Mark booking as complete (provider only)
     * @param {number} id - Booking ID
     * @param {Object} data - { completion_notes } (optional)
     * @returns {Promise} Updated booking data
     */
    async completeBooking(id, data = {}) {
        const res = await api.post(`/bookings/${id}/complete/`, data);
        return res.data;
    },

    /**
     * Cancel booking (citizen or provider)
     * @param {number} id - Booking ID
     * @param {Object} data - { cancellation_reason }
     * @returns {Promise} Updated booking data
     */
    async cancelBooking(id, data) {
        const res = await api.post(`/bookings/${id}/cancel/`, data);
        return res.data;
    },
};
