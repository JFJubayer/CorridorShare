import React from 'react';

export default function Button({ children, variant = 'primary', className = '', ...props }) {
  const baseStyle = "w-full py-3 px-5 rounded-full font-bold text-sm transition-all tactile-btn cursor-pointer flex items-center justify-center gap-2 select-none";
  
  const variants = {
    primary: "bg-gradient-to-r from-orange-600 via-orange-500 to-amber-500 hover:from-orange-500 hover:to-amber-400 text-white shadow-md shadow-orange-500/25 border border-orange-400/30",
    secondary: "bg-surface-container-low text-on-surface border border-outline hover:bg-orange-500/10 dark:hover:bg-orange-500/20",
    danger: "bg-red-600 text-white hover:bg-red-700 shadow-sm shadow-red-500/20",
    success: "bg-amber-600 text-white hover:bg-amber-700 shadow-sm shadow-amber-500/20"
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

