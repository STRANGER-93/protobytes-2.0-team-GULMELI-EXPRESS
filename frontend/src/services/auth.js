// frontend/src/services/auth.js
import api from './api';

export const authService = {
  async sendOTP(phone) {
    const res = await api.post('/auth/send-otp/', { phone });
    return res.data;
  },

  async verifyOTP(phone, otp, registrationData = null) {
    const body = { phone, otp, ...registrationData };
    const res = await api.post('/auth/verify-otp/', body);
    const { access, refresh, user } = res.data;
    localStorage.setItem('access_token', access);
    localStorage.setItem('refresh_token', refresh);
    localStorage.setItem('user', JSON.stringify(user));
    return { access, refresh, user };
  },

  logout() {
    localStorage.removeItem('access_token');
    localStorage.removeItem('refresh_token');
    localStorage.removeItem('user');
  },

  getCurrentUser() {
    try {
      return JSON.parse(localStorage.getItem('user'));
    } catch {
      return null;
    }
  },

  isAuthenticated() {
    return !!localStorage.getItem('access_token');
  },

  async getProfile() {
    const res = await api.get('/auth/me/');
    localStorage.setItem('user', JSON.stringify(res.data));
    return res.data;
  },

  async updateProfile(data) {
    const formData = new FormData();
    Object.keys(data).forEach(k => {
      if (data[k] !== null && data[k] !== undefined) formData.append(k, data[k]);
    });
    const res = await api.patch('/auth/me/', formData, {
      headers: { 'Content-Type': 'multipart/form-data' },
    });
    localStorage.setItem('user', JSON.stringify(res.data));
    return res.data;
  },
};
