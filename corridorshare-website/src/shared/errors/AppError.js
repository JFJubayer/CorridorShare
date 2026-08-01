export class AppError extends Error {
  constructor(message, { code = 'UNKNOWN', cause } = {}) {
    super(message, { cause });
    this.name = 'AppError';
    this.code = code;
  }
}

export function getErrorMessage(error, fallback = 'Something went wrong. Please try again.') {
  return error instanceof Error && error.message ? error.message : fallback;
}
