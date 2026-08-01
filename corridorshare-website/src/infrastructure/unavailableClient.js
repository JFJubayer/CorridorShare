function unavailable(operation) {
  return Promise.resolve({
    data: null,
    error: new Error(`Cannot ${operation}: ${process.env.NEXT_PUBLIC_DATA_MODE || 'supabase'} data source is not configured.`),
  });
}

/**
 * Allows Next to render a useful configuration error instead of silently
 * changing the application to browser storage when live credentials are absent.
 */
export const unavailableClient = {
  auth: {
    getUser: () => unavailable('load the current user'),
    signInWithOtp: () => unavailable('send an OTP'),
    verifyOtp: () => unavailable('verify an OTP'),
    signOut: () => unavailable('sign out'),
    onAuthStateChange: () => ({ data: { subscription: { unsubscribe() {} } } }),
  },
  from: () => ({
    select: () => ({ then: (resolve) => resolve({ data: null, error: new Error('Data source is not configured.') }) }),
  }),
  rpc: () => unavailable('call a server operation'),
};
