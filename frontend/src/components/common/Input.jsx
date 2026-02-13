// frontend/src/components/common/Input.jsx
export default function Input({
  label,
  error,
  hint,
  required = false,
  type = 'text',
  className = '',
  ...props
}) {
  return (
    <div className={`form-group ${className}`}>
      {label && (
        <label className="form-label">
          {label}
          {required && <span className="form-required">*</span>}
        </label>
      )}
      <input type={type} className="form-input" required={required} {...props} />
      {hint && !error && <div className="form-hint">{hint}</div>}
      {error && <div className="form-error">⚠ {error}</div>}
    </div>
  );
}
