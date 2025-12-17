class Validators {
  String? nameValidator(String? value) {
    if (value == null || value.isEmpty || value.trim() == '') {
      return 'You need to fill this field';
    }

    final trimmedValue = value.trim();

    // Check minimum length (at least 2 characters)
    if (trimmedValue.length < 2) {
      return 'Name must be at least 2 characters';
    }

    // Split by spaces and filter out empty strings
    final nameParts = trimmedValue
        .split(' ')
        .where((part) => part.isNotEmpty)
        .toList();

    if (nameParts.length < 2) {
      return 'Please enter both first and last name';
    }

    // Allow letters, spaces, hyphens, and apostrophes (for names like O'Brien, Mary-Jane)
    final validCharacters = RegExp(r"^[a-zA-Z\s\-']+$");
    if (!validCharacters.hasMatch(trimmedValue)) {
      return 'Name should only contain letters, spaces, hyphens, and apostrophes';
    }

    return null;
  }

  String? emailValidator(String? value) {
    if (value == null || value.isEmpty || value.trim() == '') {
      return 'You need to fill this field';
    }

    // Standard email regex pattern
    final validEmail = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!validEmail.hasMatch(value.trim())) {
      return 'Enter valid email address';
    }

    return null;
  }

  String? passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'You need to fill this field';
    }

    if (value.length < 12) {
      return 'Password must be at least 12 characters long';
    }

    // Uppercase check
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }

    // Lowercase check
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }

    // Digit check
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }

    return null;
  }

  String? conformPasswordValidator(String? firstPass, String? secondPass) {
    if (firstPass != secondPass) {
      return 'passwords do not match';
    } else {
      return passwordValidator(secondPass);
    }
  }

  String? loginPasswordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'You need to fill this field';
    }
    return null;
  }

  String? plateNumberValidator(String? value) {
    if (value == null || value.isEmpty || value.trim() == '') {
      return 'You need to fill this field';
    }

    final trimmedValue = value.trim().toUpperCase().replaceAll(' ', '');

    // UK plate format: 2 letters + 2 numbers + 3 letters (e.g., AB12CDE)
    // Also accepts old format: 1 letter + 1-3 numbers + 3 letters (e.g., A123BCD)
    final ukPlateFormat = RegExp(r'^[A-Z]{2}\d{2}[A-Z]{3}$|^[A-Z]\d{1,3}[A-Z]{3}$');
    
    if (!ukPlateFormat.hasMatch(trimmedValue)) {
      return 'Invalid UK plate format (e.g., AB12CDE)';
    }

    return null;
  }
}
