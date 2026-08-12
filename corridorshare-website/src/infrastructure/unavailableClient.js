function unavailable(operation) {
  return Promise.resolve({
    data: null,
    error: new Error(`Cannot ${operation}: live data is not connected. Configure Supabase credentials or use demo mode locally.`),
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
    select: () => ({ then: (resolve) => resolve({ data: null, error: new Error('Live data is not connected.') }) }),
    insert: () => ({ then: (resolve) => resolve({ data: null, error: new Error('Live data is not connected.') }) }),
    update: () => ({ eq: () => ({ then: (resolve) => resolve({ data: null, error: new Error('Live data is not connected.') }) }) }),
  }),
  rpc: () => unavailable('call a server operation'),
  storage: {
    from: () => ({
      upload: () => unavailable('upload a file'),
      getPublicUrl: () => ({ data: { publicUrl: '' } }),
    }),
  },
};
