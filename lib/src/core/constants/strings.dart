class AppStrings {
  static const String appName = 'ParkMyWhip';
}

class AuthStrings {
  // Register
  static const String welcomeTitle = 'Welcome to ParkMyWhip!';
  static const String createAccount = 'Let’s create your account';
  static const String nameLabel = 'Your first and last name';
  static const String nameHint = 'Example: John Doe';
  static const String emailLabel = 'Your email';
  static const String emailHint = 'Enter your email';
  static const String alreadyHaveAccount = 'Already have an account? ';
  static const String signIn = 'Sign in';
  static const String continueText = 'Continue';
  static const String otpTitle = 'Enter the OTP code';
  static const String otpSubtitle =
      "We've just emailed a code to your inbox. Please enter it below.";
  static const String createPassword = 'Create password';
  static const String passwordLabel = 'Create your password';
  static const String confirmPasswordLabel = 'Confirm password';

  // Login
  static const String welcomeBack = 'Welcome Back!';
  static const String loginToApp = 'Log in to ParkMyWhip';
  static const String emailLabelShort = 'Email';
  static const String emailHintExample = 'Wade@gmail.com';
  static const String passwordLabelShort = 'Password';
  static const String forgotPassword = 'Forgot password?';
  static const String dontHaveAccount = 'Do not have an account? ';
  static const String signUp = 'Signup';
  static const String login = 'Login';

  // Forgot Password
  static const String confirmYourEmail = 'Confirm your email';
  static const String resetPasswordSubtitle = "We'll email you a link to reset your password";
  static const String resetLinkSent = 'Reset Link Sent';
  static const String resetLinkSentSubtitle = "You should receive an email in your inbox shortly to reset your account's password";
  static const String goToLogin = 'Go to login';
  static const String resend = 'Resend';
  static const String resendIn = 'Resend in';
  
  // Reset Password
  static const String resetYourPassword = 'Reset your password';
  static const String passwordMinCharacters = 'Be a minimum of 12 characters';
  static const String passwordUppercase = 'Include at least one uppercase letter (A-Z)';
  static const String passwordLowercase = 'Include at least one lowercase (a-z)';
  static const String passwordNumber = 'Include at least one number (0-9)';
}

class FirebaseStrings {
  // TODO: Add Firebase collection names here
  static const String users = 'users';
}

class SharedPrefStrings {
  static const String userId = 'user_id';
  static const String supabaseUserProfile = 'supabase_user_profile';
}

class HomeStrings {
  // patrol
  static const String greeting = 'Good Morning,';
  static const String checkSiteTitle = 'What site would you like to check?';
  static const String searchSiteHint = 'Search a site';
  static const String patrol = 'Patrol';
  static const String activePermits = 'Active Permits';
  static const String searchPlateLabel = 'Search plate';
  static const String plateNumberHint = 'Enter plate number';
  static const String noPermitFound = 'No Permit Found';
  static const String permit = 'Permit: ';
  static const String expires = 'Expires: ';
  static const String spotNumber = 'Spot Number';
  static const String towCar = 'Tow this car';
  static const String backToSite = 'Back to site permits';
  static const String permitFound = 'Permit Found';
  static const String noLocationsFound = 'No locations found';
  // reports
  static const String reports = 'Reports';
  static const String activeTab = 'Active';
  static const String historyTab = 'History';
  static const String submitTimeLabel = 'Submit Time:';
  static const String plateNumberLabel = 'Plate Number';
  static const String additionalNotesLabel = 'Additional Notes';
  static const String reportedByLabel = 'Reported by';
  static const String towedByLabel = 'Towed by';
  static const String attachedImagesLabel = 'Attached Images';
  static const String viewAction = 'View';
  static const String dismissAction = 'Dismiss';
  static const String filtersAction = 'Filters';
  static const String markAsTowedAction = 'Mark as Towed';
  static const String noActiveReports = 'No Active Reports';
  static const String noHistoryReports = 'No History Reports';

  // Tow a car
  static const String towACarTitle = 'Tow a car';
  static const String newTowingEntry = 'New towing entry';
  static const String enterPlateNumberTitle = 'Enter Plate Number';
  static const String plateNumber = 'Plate Number';
  static const String plateNumberExample = 'AB12CDE';
  static const String next = 'Next';
  static const String selectViolationReason = 'Select Violation reason';
  static const String unauthorizedParking = 'Unauthorized parking';
  static const String parkedInReservedZone = 'Parked in reserved zone';
  static const String expiredPermit = 'Expired Permit';
  static const String attachAnImage = 'Attach an Image';
  static const String image = 'Image';
  static const String attachImage = 'Attach image';
  static const String changeImage = 'Change image';
  static const String selectImageSource = 'Select Image Source';
  static const String camera = 'Camera';
  static const String gallery = 'Gallery';
  static const String cancel = 'Cancel';
  static const String addNotes = 'Add notes';
  static const String note = 'Note';
  static const String addCommentHint = 'Add your comment here...';
  static const String towingSummary = 'Towing Summary';
  static const String attachedImages = 'Attached Images';
  static const String towingConfirmed = 'Towing confirmed!';
  static const String towingThankYou =
      'Thank you for helping to create a better place!';
  static const String confirm = 'Confirm';
  static const String backToHome = 'Back to Home';
  // History
  static const String history = 'History';
  static const String historyOfTows = 'History of Tows';
  static const String towingDate = 'Towing date:';
  static const String review = 'Review';
  static const String noTowingHistory = 'No Towing History';
  static const String timeRange = 'Time range';
  static const String lastYear = 'Last year';
  static const String lastMonth = 'Last month';
  static const String lastWeek = 'Last week';
  static const String violationType = 'Violation type';
  static const String parkedInFireLaneZone = 'Parked in Fire Lane zone';
  static const String residentAdmin = 'Resident Admin';
  static const String permitControl = 'Permit Control';
  static const String superAdmin = 'Super Admin';
  static const String filter = 'Filter';
  static const String all = 'All';

  static const String view = 'View';
  static const String towingDetails = 'Towing Details';

  // Profile
  static const String profile = 'Profile';
  static const String yourProfile = 'Your profile';
  static const String username = 'Username';
  static const String email = 'Email';
  static const String change = 'Change';
  static const String changePassword = 'Change password';
  static const String logOut = 'Log out';
  static const String deleteAccount = 'Delete account';
}
