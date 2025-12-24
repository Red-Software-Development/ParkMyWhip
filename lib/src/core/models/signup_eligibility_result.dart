/// Result of checking signup eligibility via RPC function
/// 
/// This model represents the response from 'check_user_and_grant_app_access' RPC
class SignupEligibilityResult {
  /// Whether the user can proceed with signup (new user)
  final bool canSignup;
  
  /// Whether the user has access to this app
  final bool hasAppAccess;
  
  /// User ID if user exists, null if new user
  final String? userId;
  
  /// Message to display to the user
  final String message;

  const SignupEligibilityResult({
    required this.canSignup,
    required this.hasAppAccess,
    this.userId,
    required this.message,
  });

  /// Creates result from RPC response
  /// 
  /// RPC returns: {'user': {...} | null, 'user_app': {...} | null}
  /// - user = null → New user, can signup
  /// - user != null, user_app != null → Existing user with app access
  /// - user != null, user_app = null → Should not happen (RPC grants access)
  factory SignupEligibilityResult.fromRpcResponse(Map<String, dynamic> response) {
    final userData = response['user'] as Map<String, dynamic>?;
    final userAppData = response['user_app'] as Map<String, dynamic>?;

    // New user - can proceed with signup
    if (userData == null) {
      return const SignupEligibilityResult(
        canSignup: true,
        hasAppAccess: false,
        userId: null,
        message: 'New user - can proceed with signup',
      );
    }

    // Existing user - app access was granted by RPC
    final userId = userData['id'] as String?;
    final hasAppAccess = userAppData != null;
    
    return SignupEligibilityResult(
      canSignup: false,
      hasAppAccess: hasAppAccess,
      userId: userId,
      message: 'Existing user - redirect to login',
    );
  }
}
