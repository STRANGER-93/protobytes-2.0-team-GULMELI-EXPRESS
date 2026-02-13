// frontend/src/utils/constants.js

export const SKILL_CATEGORIES = [
  { value: 'electrician',  label: 'Electrician',       icon: '⚡' },
  { value: 'plumber',      label: 'Plumber',           icon: '🔧' },
  { value: 'carpenter',    label: 'Carpenter',         icon: '🪵' },
  { value: 'mason',        label: 'Mason',             icon: '🧱' },
  { value: 'painter',      label: 'Painter',           icon: '🎨' },
  { value: 'mechanic',     label: 'Mechanic',          icon: '🔩' },
  { value: 'cleaner',      label: 'Cleaning Services', icon: '🧹' },
  { value: 'gardener',     label: 'Gardening',         icon: '🌿' },
  { value: 'tailor',       label: 'Tailor',            icon: '🧵' },
  { value: 'beautician',   label: 'Beauty Services',   icon: '💄' },
  { value: 'cook',         label: 'Cooking Services',  icon: '🍲' },
  { value: 'tutor',        label: 'Tutoring',          icon: '📚' },
  { value: 'driver',       label: 'Driver',            icon: '🚗' },
  { value: 'other',        label: 'Other',             icon: '🛠️' },
];

export const CTEVT_STATUS = {
  pending:        { label: 'CTEVT Pending',     badge: 'warning'   },
  certified:      { label: 'CTEVT Certified',   badge: 'success'   },
  not_applicable: { label: 'CTEVT N/A',         badge: 'secondary' },
};

export const BOOKING_STATUS = {
  pending:   { label: 'Pending',   badge: 'warning'   },
  confirmed: { label: 'Confirmed', badge: 'info'      },
  completed: { label: 'Completed', badge: 'success'   },
  cancelled: { label: 'Cancelled', badge: 'secondary' },
};

export const USER_ROLES = {
  citizen:           'Citizen',
  provider:          'Service Provider',
  municipality_admin: 'Municipality Admin',
};

export const getSkillLabel = (value) =>
  SKILL_CATEGORIES.find(s => s.value === value)?.label ?? value;

export const getSkillIcon = (value) =>
  SKILL_CATEGORIES.find(s => s.value === value)?.icon ?? '🛠️';
