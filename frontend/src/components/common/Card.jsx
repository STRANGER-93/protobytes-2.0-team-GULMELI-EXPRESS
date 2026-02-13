// frontend/src/components/common/Card.jsx
export default function Card({ title, titleRight, children, className = '', padding, ...props }) {
  const style = padding !== undefined ? { padding } : undefined;

  return (
    <div className={`card ${className}`} style={style} {...props}>
      {title && (
        <div className="card-header">
          <h3 className="card-title">{title}</h3>
          {titleRight && <div>{titleRight}</div>}
        </div>
      )}
      {children}
    </div>
  );
}
