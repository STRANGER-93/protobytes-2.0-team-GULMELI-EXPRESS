// frontend/src/components/common/LoadingSpinner.jsx
export default function LoadingSpinner({ message = 'Loading…', inline = false }) {
  if (inline) {
    return (
      <span style={{ display: 'inline-flex', alignItems: 'center', gap: '8px' }}>
        <span className="spinner spinner-sm" />
        {message && <span className="text-sm text-muted">{message}</span>}
      </span>
    );
  }

  return (
    <div className="loading-screen fade-in">
      <div className="spinner" />
      <p className="text-muted text-sm">{message}</p>
    </div>
  );
}
