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
    
    // Check if this is coming from Supabase auth (has access_token in hash fragment)
    // or from our email template (has token in query params)
    const html = `
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Redirecting - ParkMyWhip</title>
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
    .spinner {
      border: 4px solid rgba(255, 255, 255, 0.3);
      border-top: 4px solid #FFD700;
      border-radius: 50%;
      width: 50px;
      height: 50px;
      animation: spin 1s linear infinite;
      margin: 20px auto;
    }
    @keyframes spin {
      0% { transform: rotate(0deg); }
      100% { transform: rotate(360deg); }
    }
    .error { color: #ff6b6b; }
  </style>
</head>
<body>
  <div class="container">
    <div class="spinner"></div>
    <h2>Opening ParkMyWhip...</h2>
    <p>If the app doesn't open automatically, <a href="#" id="fallback-link" style="color: #FFD700;">click here</a>.</p>
  </div>
  <script>
    // This script extracts tokens from either hash fragment (#) or query params (?)
    // and redirects to the deep link
    (function() {
      // First, check hash fragment (from Supabase auth redirect)
      const hashParams = new URLSearchParams(window.location.hash.substring(1));
      const accessToken = hashParams.get('access_token');
      const refreshToken = hashParams.get('refresh_token');
      const type = hashParams.get('type') || 'recovery';

      // If we have access_token from hash, use it
      if (accessToken) {
        console.log('Found access_token in hash fragment');
        const deepLink = \`parkmywhip://parkmywhip.com/reset-password?access_token=\${encodeURIComponent(accessToken)}&refresh_token=\${encodeURIComponent(refreshToken || '')}&type=\${encodeURIComponent(type)}\`;
        console.log('Redirecting to:', deepLink);
        
        document.getElementById('fallback-link').href = deepLink;
        window.location.href = deepLink;
        return;
      }

      // Otherwise, check query params (from email template with token)
      const queryParams = new URLSearchParams(window.location.search);
      const token = queryParams.get('token');
      const queryType = queryParams.get('type') || 'recovery';

      if (token) {
        console.log('Found token in query params');
        const deepLink = \`parkmywhip://parkmywhip.com/reset-password?token=\${encodeURIComponent(token)}&type=\${encodeURIComponent(queryType)}\`;
        console.log('Redirecting to:', deepLink);
        
        document.getElementById('fallback-link').href = deepLink;
        window.location.href = deepLink;
        return;
      }

      // No token found - show error
      document.querySelector('.container').innerHTML = \`
        <h2><span class="error">Error</span></h2>
        <p>Missing reset token. Please request a new password reset link.</p>
        <p><a href="parkmywhip://parkmywhip.com" style="color: #FFD700;">Open ParkMyWhip App</a></p>
      \`;
    })();
  </script>
</body>
</html>
`;

    return new Response(html, {
      status: 200,
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
