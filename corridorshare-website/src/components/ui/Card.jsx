import React from 'react';

export default function Card({ children, className = '', ...props }) {
  return (
    <div
      className={`bg-surface-container-lowest border border-outline-variant rounded-xl p-6 shadow-sm card-spring-hover hover:border-primary/30 ${className}`}
      {...props}
    >
      {children}
    </div>
  );
}
