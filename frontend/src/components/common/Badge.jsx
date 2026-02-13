// frontend/src/components/common/Badge.jsx
export default function Badge({ children, variant = 'secondary', className = '' }) {
  return (
    <span className={`badge badge-${variant} ${className}`}>
      {children}
    </span>
  );
}
