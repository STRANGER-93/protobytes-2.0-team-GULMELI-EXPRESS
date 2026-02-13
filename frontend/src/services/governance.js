// frontend/src/services/governance.js
import api from './api';

export const governanceService = {
    /**
     * Get municipality economic loop metrics (municipality admin only)
     * @returns {Promise} Dashboard metrics data
     */
    async getMunicipalityDashboard() {
        const res = await api.get('/governance/dashboard/');
        return res.data;
    },

    /**
     * Get provider earnings & stats (provider only)
     * @returns {Promise} Provider dashboard data
     */
    async getProviderDashboard() {
        const res = await api.get('/governance/provider/dashboard/');
        return res.data;
    },
};
