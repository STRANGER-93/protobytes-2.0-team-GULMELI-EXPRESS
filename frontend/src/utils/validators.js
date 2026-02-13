// frontend/src/utils/validators.js

export const validators = {
  phone(value) {
    if (!value) return 'Phone number is required';
    if (!/^98\d{8}$/.test(value)) return 'Must be 10 digits starting with 98';
    return null;
  },
  name(value) {
    if (!value?.trim()) return 'Name is required';
    if (value.trim().length < 2) return 'Name must be at least 2 characters';
    return null;
  },
  otp(value) {
    if (!value) return 'OTP is required';
    if (!/^\d{6}$/.test(value)) return 'OTP must be 6 digits';
    return null;
  },
  required(value, label = 'This field') {
    if (!value && value !== 0) return `${label} is required`;
    return null;
  },
};
