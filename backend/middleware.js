// middleware.js (metti nella root del progetto Next.js)

import { NextResponse } from 'next/server';

export function middleware(req) {
  const res = NextResponse.next();

  res.headers.set('Access-Control-Allow-Origin', '*');
  res.headers.set('Access-Control-Allow-Methods', 'GET,POST,PUT,DELETE,OPTIONS');
  res.headers.set('Access-Control-Allow-Headers', 'Content-Type');

  // per gestire OPTIONS preflight
  if (req.method === 'OPTIONS') {
    return new Response(null, {
      status: 204,
      headers: res.headers,
    });
  }

  return res;
}

export const config = {
  matcher: '/api/:path*', // intercetta tutte le API
};
