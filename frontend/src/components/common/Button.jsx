// frontend/src/components/common/Button.jsx
export default function Button({ 
  children, 
  variant = 'primary', 
  size = 'md',
  block = false,
  disabled = false,
  onClick,
  type = 'button',
  ...props 
}) {
  const baseClass = 'btn';
  const variantClass = `btn-${variant}`;
  const sizeClass = size !== 'md' ? `btn-${size}` : '';
  const blockClass = block ? 'btn-block' : '';
  
  const className = [baseClass, variantClass, sizeClass, blockClass]
    .filter(Boolean)
    .join(' ');

  return (
    <button
      type={type}
      className={className}
      disabled={disabled}
      onClick={onClick}
      {...props}
    >
      {children}
    </button>
  );
}