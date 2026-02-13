// frontend/src/services/municipalities.js
import api from './api';

export const municipalityService = {
    /**
     * List all municipalities
     * @returns {Promise} Array of municipalities
     */
    async listMunicipalities() {
        const res = await api.get('/municipalities/');
        return res.data;
    },

    /**
     * Get municipality detail by ID
     * @param {number} id - Municipality ID
     * @returns {Promise} Municipality data
     */
    async getMunicipalityDetail(id) {
        const res = await api.get(`/municipalities/${id}/`);
        return res.data;
    },
};
