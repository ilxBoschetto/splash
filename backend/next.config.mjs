import path from 'path';

/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  webpack(config) {
    config.resolve.alias['@models'] = path.resolve('./models');
    config.resolve.alias['@lib'] = path.resolve('./lib');
    config.resolve.alias['@controllers'] = path.resolve('./controllers');
    config.resolve.alias['@api'] = path.resolve('./pages/api');
    config.resolve.alias['@helpers'] = path.resolve('./helpers');
    return config;
  },
  async headers() {
    return [
      {
        source: '/uploads/:path*',
        headers: [
          {
            key: 'Cache-Control',
            value: 'no-store',
          },
        ],
      },
    ];
  },
};

export default nextConfig;
