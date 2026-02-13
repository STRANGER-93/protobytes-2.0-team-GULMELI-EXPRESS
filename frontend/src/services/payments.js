// frontend/src/services/payments.js
import api from './api';

export const paymentService = {
    /**
     * Initiate payment for booking (mock gateway)
     * @param {Object} data - { booking, amount, payment_method }
     * @returns {Promise} Payment initiation data with reference
     */
    async initiatePayment(data) {
        const res = await api.post('/payments/initiate/', data);
        return res.data;
    },

    /**
     * Verify payment status
     * @param {Object} data - { payment_reference }
     * @returns {Promise} Payment verification data
     */
    async verifyPayment(data) {
        const res = await api.post('/payments/verify/', data);
        return res.data;
    },

    /**
     * Get payment details for a booking
     * @param {number} bookingId - Booking ID
     * @returns {Promise} Payment data
     */
    async getBookingPayment(bookingId) {
        const res = await api.get(`/payments/booking/${bookingId}/`);
        return res.data;
    },
};
