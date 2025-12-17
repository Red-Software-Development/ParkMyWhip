import { serve } from "https://deno.land/std@0.177.0/http/server.ts";

serve(async (req) => {
  console.log("=== Incoming request to password-reset-redirect ===");
  console.log("Request URL:", req.url);

  try {
    const url = new URL(req.url);
    const token = url.searchParams.get("token");
    const type = url.searchParams.get("type") || "recovery";

    console.log("Extracted params:", { token, type });

    if (!token) {
      console.warn("❌ Missing token in query parameters");
      return new Response("Missing token", { status: 400 });
    }

    // Construct deep link for password reset
    const deepLink = `parkmywhip://parkmywhip.com/resetPassword?token=${token}&type=${type}`;

    console.log("✅ Redirecting to deep link:", deepLink);

    return new Response(null, {
      status: 302,
      headers: {
        Location: deepLink,
      },
    });
  } catch (err) {
    console.error("❌ Internal Server Error:", err);
    return new Response("Internal Server Error", { status: 500 });
  }
});
