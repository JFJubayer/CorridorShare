import React from 'react';

export default function Button({ children, variant = 'primary', className = '', ...props }) {
  const baseStyle = "w-full py-3 px-5 rounded-full font-semibold text-sm transition-all tactile-btn cursor-pointer flex items-center justify-center gap-2 select-none focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-primary disabled:opacity-55 disabled:cursor-not-allowed disabled:transform-none";

  const variants = {
    primary: "bg-primary hover:bg-primary-700 text-white shadow-sm border border-primary/20",
    secondary: "bg-surface-container-lowest text-on-surface border border-outline hover:bg-primary/8 dark:hover:bg-primary/15",
    danger: "bg-error text-white hover:opacity-90 shadow-sm",
    success: "bg-secondary text-white hover:opacity-90 shadow-sm"
  };

  return (
    <button
      className={`${baseStyle} ${variants[variant] || variants.primary} ${className}`}
      {...props}
    >
      {children}
    </button>
  );
}
