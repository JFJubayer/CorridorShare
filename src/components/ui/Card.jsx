import React from 'react';

export default function Card({ children, className = '', ...props }) {
  return (
    <div
      className={`bg-surface-container-lowest border border-outline-variant/80 rounded-[28px] p-6 shadow-sm card-spring-hover hover:border-orange-500/40 ${className}`}
      {...props}
    >
      {children}
    </div>
  );
}

