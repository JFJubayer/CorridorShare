export default function robots() {
  return {
    rules: {
      userAgent: '*',
      allow: '/',
      disallow: ['/admin-portal', '/admin/'],
    },
    sitemap: 'https://corridorshare.vercel.app/sitemap.xml',
  };
}
