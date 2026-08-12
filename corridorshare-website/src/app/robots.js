export default function robots() {
  return {
    rules: {
      userAgent: '*',
      allow: '/',
      disallow: ['/admin-portal', '/admin/'],
    },
    sitemap: 'https://corridorshare-tan.vercel.app/sitemap.xml',
  };
}
