// frontend/src/components/common/Message.jsx
const ICONS = {
  success: '✓',
  error:   '✕',
  warning: '⚠',
  info:    'ℹ',
};

export default function Message({ type = 'info', children, onClose, className = '' }) {
  return (
    <div className={`alert alert-${type} ${className}`} role="alert">
      <span style={{ fontWeight: 700, flexShrink: 0 }}>{ICONS[type]}</span>
      <span>{children}</span>
      {onClose && (
        <button className="alert-close" onClick={onClose} aria-label="Dismiss">
          ×
        </button>
      )}
    </div>
  );
}
