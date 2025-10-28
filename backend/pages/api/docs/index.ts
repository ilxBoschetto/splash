import type { NextApiRequest, NextApiResponse } from "next";
import withCors from "@/lib/withCors";

export default withCors(function handler(
  req: NextApiRequest,
  res: NextApiResponse
) {
  res.setHeader("Content-Type", "text/html");
  res.send(`
    <!DOCTYPE html>
    <html>
      <head>
        <title>API Docs</title>
        <meta charset="utf-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <style>
          body { margin: 0; padding: 0; }
          redoc { width: 100%; height: 100vh; display: block; }
        </style>
        <script src="https://cdn.redoc.ly/redoc/latest/bundles/redoc.standalone.js"></script>
      </head>
      <body>
        <redoc id="redoc-container"></redoc>
        <script>
          document.addEventListener('DOMContentLoaded', function() {
            Redoc.init('/api/docs/swagger', {}, document.getElementById('redoc-container'));
          });
        </script>
      </body>
    </html>
  `);
});
