// frontend/src/services/reviews.js
import api from './api';

export const reviewService = {
    /**
     * Create review for completed booking
     * @param {Object} data - { booking, rating, comment }
     * @returns {Promise} Created review data
     */
    async createReview(data) {
        const res = await api.post('/reviews/create/', data);
        return res.data;
    },

    /**
     * Get reviews for a provider
     * @param {number} providerId - Provider ID
     * @returns {Promise} Array of reviews
     */
    async getProviderReviews(providerId) {
        const res = await api.get(`/reviews/provider/${providerId}/`);
        return res.data;
    },

    /**
     * Get review for a booking
     * @param {number} bookingId - Booking ID
     * @returns {Promise} Review data or null
     */
    async getBookingReview(bookingId) {
        const res = await api.get(`/reviews/booking/${bookingId}/`);
        return res.data;
    },
};
