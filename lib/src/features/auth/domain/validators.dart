class Validators {
  String? nameValidator(String? value) {
    if (value == null || value.isEmpty || value.trim() == '') {
      return 'You need to fill this field';
    }

    // Split by spaces and filter out empty strings
    final nameParts = value
        .trim()
        .split(' ')
        .where((part) => part.isNotEmpty)
        .toList();

    if (nameParts.length < 2) {
      return 'Please enter both first and last name';
    }

    // Check if all parts contain only letters
    final validCharacters = RegExp(r'^[a-zA-Z]+$');
    for (final part in nameParts) {
      if (!validCharacters.hasMatch(part)) {
        return 'Name should only contain letters';
      }
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

    // Symbol check
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=~`;/\[\]\\]'))) {
      return 'Password must contain at least one special character';
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
}
