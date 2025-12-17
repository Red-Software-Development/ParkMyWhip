import { serve } from "https://deno.land/std@0.177.0/http/server.ts";

const CORS_HEADERS = {
  "access-control-allow-origin": "*",
  "access-control-allow-headers": "authorization, x-client-info, apikey, content-type",
  "access-control-allow-methods": "GET, OPTIONS",
  "access-control-max-age": "86400",
};

serve(async (req) => {
  console.log("=== Incoming request to password-reset-redirect ===");
  console.log("Request URL:", req.url);

  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response(null, { headers: CORS_HEADERS });
  }

  try {
    // Parse query parameters from URL
    const url = new URL(req.url);
    const token = url.searchParams.get('token');
    const type = url.searchParams.get('type') || 'recovery';

    console.log('Query params:', { token: token ? 'present' : 'missing', type });

    // If token is present in query params, redirect directly
    if (token) {
      const deepLink = `parkmywhip://parkmywhip.com/resetPassword?token=${encodeURIComponent(token)}&type=${encodeURIComponent(type)}`;
      console.log('Redirecting to:', deepLink);

      // Return HTTP redirect
      return new Response(null, {
        status: 302,
        headers: {
          ...CORS_HEADERS,
          "Location": deepLink,
        },
      });
    }

    // If no token in query params, show error page
    const html = `
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Error - ParkMyWhip</title>
  <style>
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      display: flex;
      justify-content: center;
      align-items: center;
      height: 100vh;
      margin: 0;
      background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
      color: white;
    }
    .container {
      text-align: center;
      padding: 40px;
    }
    .error { color: #ff6b6b; }
    a { color: #FFD700; }
  </style>
</head>
<body>
  <div class="container">
    <h2><span class="error">Error</span></h2>
    <p>Missing reset token. Please request a new password reset link.</p>
    <p><a href="parkmywhip://parkmywhip.com">Open ParkMyWhip App</a></p>
  </div>
</body>
</html>
`;

    return new Response(html, {
      status: 400,
      headers: {
        ...CORS_HEADERS,
        "Content-Type": "text/html; charset=utf-8",
      },
    });
  } catch (err) {
    console.error("❌ Internal Server Error:", err);
    return new Response("Internal Server Error", { status: 500 });
  }
});
