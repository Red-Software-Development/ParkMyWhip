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
    // Return an HTML page with JavaScript to handle hash fragment
    // Supabase Auth sends tokens as hash fragments (#access_token=xxx)
    // which browsers don't send to servers, so we need client-side JS
    const html = `
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Redirecting to ParkMyWhip...</title>
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
      border: 3px solid rgba(255,255,255,0.2);
      border-top: 3px solid #FFD700;
      border-radius: 50%;
      width: 40px;
      height: 40px;
      animation: spin 1s linear infinite;
      margin: 0 auto 20px;
    }
    @keyframes spin {
      0% { transform: rotate(0deg); }
      100% { transform: rotate(360deg); }
    }
    h2 { margin-bottom: 10px; }
    p { opacity: 0.8; }
    .error { color: #ff6b6b; }
    a { color: #FFD700; }
  </style>
</head>
<body>
  <div class="container">
    <div class="spinner" id="spinner"></div>
    <h2 id="title">Redirecting to ParkMyWhip...</h2>
    <p id="message">Please wait while we redirect you to reset your password.</p>
  </div>

  <script>
    (function() {
      const hash = window.location.hash.substring(1);
      const params = new URLSearchParams(hash);
      
      const accessToken = params.get('access_token');
      const refreshToken = params.get('refresh_token');
      const type = params.get('type') || 'recovery';

      console.log('Hash params:', { accessToken: accessToken ? 'present' : 'missing', type });

      if (!accessToken) {
        document.getElementById('spinner').style.display = 'none';
        document.getElementById('title').innerHTML = '<span class="error">Error</span>';
        document.getElementById('message').innerHTML = 
          'Missing authentication token. Please request a new password reset link.<br><br>' +
          '<a href="parkmywhip://parkmywhip.com">Open ParkMyWhip App</a>';
        return;
      }

      // Construct deep link with access token
      const deepLink = 'parkmywhip://parkmywhip.com/resetPassword' +
        '?access_token=' + encodeURIComponent(accessToken) +
        '&refresh_token=' + encodeURIComponent(refreshToken || '') +
        '&type=' + encodeURIComponent(type);

      console.log('Redirecting to:', deepLink);

      // Redirect to deep link
      window.location.href = deepLink;

      // Fallback message after 3 seconds if redirect doesn't work
      setTimeout(function() {
        document.getElementById('spinner').style.display = 'none';
        document.getElementById('title').textContent = 'Open the App';
        document.getElementById('message').innerHTML = 
          'If the app did not open automatically, <a href="' + deepLink + '">tap here to open ParkMyWhip</a>';
      }, 3000);
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
