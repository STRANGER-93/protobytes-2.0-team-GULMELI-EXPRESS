// frontend/src/services/providers.js
import api from './api';

export const providerService = {
  /**
   * Provider Onboarding - Create provider profile
   * @param {Object} data - { skill_categories, bio, experience_years, citizenship_photo, ctevt_certificate_upload, ctevt_certificate_link, ctevt_status }
   * @returns {Promise} Provider profile data
   */
  async register(data) {
    const formData = new FormData();
    
    // Handle skill_categories as JSON array
    if (data.skill_categories) {
      formData.append('skill_categories', JSON.stringify(data.skill_categories));
    }
    
    // Handle other fields
    Object.keys(data).forEach(key => {
      if (key !== 'skill_categories' && data[key] !== null && data[key] !== undefined) {
        formData.append(key, data[key]);
      }
    });
    
    const res = await api.post('/providers/register/', formData, {
      headers: { 'Content-Type': 'multipart/form-data' },
    });
    return res.data;
  },

  /**
   * Get own provider profile
   * @returns {Promise} Provider profile data
   */
  async getMyProfile() {
    const res = await api.get('/providers/me/');
    return res.data;
  },

  /**
   * Update own provider profile
   * @param {Object} data - { skill_categories, bio, experience_years, ctevt_certificate_upload, ctevt_certificate_link, is_active }
   * @returns {Promise} Updated provider profile data
   */
  async updateMyProfile(data) {
    const formData = new FormData();
    
    // Handle skill_categories as JSON array
    if (data.skill_categories) {
      formData.append('skill_categories', JSON.stringify(data.skill_categories));
    }
    
    // Handle other fields
    Object.keys(data).forEach(key => {
      if (key !== 'skill_categories' && data[key] !== null && data[key] !== undefined) {
        formData.append(key, data[key]);
      }
    });
    
    const res = await api.patch('/providers/me/', formData, {
      headers: { 'Content-Type': 'multipart/form-data' },
    });
    return res.data;
  },

  /**
   * Search providers with filters
   * @param {Object} filters - { municipality, skill, min_rating, verified_only, ctevt_status, search }
   * @returns {Promise} Array of provider profiles
   */
  async searchProviders(filters = {}) {
    const params = new URLSearchParams();
    
    Object.keys(filters).forEach(key => {
      if (filters[key] !== null && filters[key] !== undefined && filters[key] !== '') {
        params.append(key, filters[key]);
      }
    });
    
    const res = await api.get(`/providers/search/?${params.toString()}`);
    return res.data;
  },

  /**
   * Get provider detail by ID
   * @param {number} id - Provider ID
   * @returns {Promise} Provider profile data
   */
  async getProviderDetail(id) {
    const res = await api.get(`/providers/${id}/`);
    return res.data;
  },

  /**
   * Get provider statistics
   * @param {number} id - Provider ID
   * @returns {Promise} Provider statistics
   */
  async getProviderStats(id) {
    const res = await api.get(`/providers/${id}/stats/`);
    return res.data;
  },

  /**
   * Verify provider (municipality admin only)
   * @param {number} id - Provider ID
   * @param {Object} data - { municipality_verified, verification_notes, ctevt_status }
   * @returns {Promise} Updated provider profile data
   */
  async verifyProvider(id, data) {
    const res = await api.patch(`/providers/${id}/verify/`, data);
    return res.data;
  },

  /**
   * List providers pending verification (municipality admin only)
   * @returns {Promise} Array of provider profiles
   */
  async getPendingVerification() {
    const res = await api.get('/providers/pending-verification/');
    return res.data;
  },
};
