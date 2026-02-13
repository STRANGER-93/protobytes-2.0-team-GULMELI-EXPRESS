// frontend/src/components/layout/Footer.jsx
export default function Footer() {
  return (
    <footer style={{
      background: 'var(--slate-900)',
      borderTop: '1px solid var(--slate-700)',
      padding: 'var(--space-8) 0',
      marginTop: 'auto',
    }}>
      <div className="container" style={{
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'space-between',
        flexWrap: 'wrap',
        gap: 'var(--space-4)',
      }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 'var(--space-3)' }}>
          <div style={{
            width: '28px',
            height: '28px',
            background: 'var(--saffron)',
            borderRadius: 'var(--r-sm)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            fontWeight: 800,
            fontSize: '0.875rem',
            color: 'white',
          }}>
            J
          </div>
          <div>
            <div style={{ fontWeight: 700, color: 'white', fontSize: '0.9375rem', letterSpacing: '-0.01em' }}>
              JanSewa
            </div>
            <div style={{ fontSize: '0.6875rem', color: 'var(--slate-400)', letterSpacing: '0.06em', textTransform: 'uppercase' }}>
              Municipal Economic Infrastructure
            </div>
          </div>
        </div>

        <div style={{ color: 'var(--slate-500)', fontSize: '0.8125rem' }}>
          Building circular local labor economies in Nepal
        </div>
      </div>
    </footer>
  );
}
