/// Centralized string map for Nepali / English.
class AppStrings {
  static const Map<String, Map<String, String>> _strings = {
    // ── Login ──
    'namaste': {'ne': 'नमस्ते!', 'en': 'Namaste!'},
    'welcomeSipalu': {'ne': 'जनसेवामा स्वागत छ', 'en': 'Welcome to JanSawa'},
    'username': {'ne': 'प्रयोगकर्ता नाम', 'en': 'Username'},
    'usernameHint': {
      'ne': 'आफ्नो प्रयोगकर्ता नाम लेख्नुहोस्',
      'en': 'Enter your username',
    },
    'usernameRequired': {
      'ne': 'प्रयोगकर्ता नाम आवश्यक छ',
      'en': 'Username is required',
    },
    'password': {'ne': 'पासवर्ड', 'en': 'Password'},
    'passwordHint': {
      'ne': 'आफ्नो पासवर्ड लेख्नुहोस्',
      'en': 'Enter your password',
    },
    'passwordRequired': {
      'ne': 'पासवर्ड आवश्यक छ',
      'en': 'Password is required',
    },
    'passwordMin4': {
      'ne': 'पासवर्ड कम्तिमा ४ अक्षरको हुनुपर्छ',
      'en': 'Password must be at least 4 characters',
    },
    'forgotPassword': {'ne': 'पासवर्ड बिर्सनुभयो?', 'en': 'Forgot password?'},
    'login': {'ne': 'लगइन गर्नुहोस्', 'en': 'Login'},
    'loginFailed': {
      'ne': 'लगइन असफल भयो। पुन: प्रयास गर्नुहोस्।',
      'en': 'Login failed. Please try again.',
    },
    'or': {'ne': 'वा', 'en': 'or'},
    'createAccount': {'ne': 'नयाँ खाता बनाउनुहोस्', 'en': 'Create new account'},
    'madeForNepal': {
      'ne': 'नेपालको लागि निर्मित 🇳🇵',
      'en': 'Made for Nepal 🇳🇵',
    },

    // ── Sign up ──
    'createAccountTitle': {
      'ne': 'नयाँ खाता बनाउनुहोस्',
      'en': 'Create Account',
    },
    'joinSipalu': {'ne': 'जनसेवामा सामेल हुनुहोस्', 'en': 'Join JanSawa'},
    'fullName': {'ne': 'पूरा नाम', 'en': 'Full Name'},
    'fullNameHint': {
      'ne': 'आफ्नो पूरा नाम लेख्नुहोस्',
      'en': 'Enter your full name',
    },
    'fullNameRequired': {
      'ne': 'पूरा नाम आवश्यक छ',
      'en': 'Full name is required',
    },
    'email': {'ne': 'इमेल', 'en': 'Email'},
    'emailRequired': {'ne': 'इमेल आवश्यक छ', 'en': 'Email is required'},
    'emailInvalid': {
      'ne': 'कृपया सही इमेल लेख्नुहोस्',
      'en': 'Please enter a valid email',
    },
    'usernameChoose': {
      'ne': 'आफ्नो प्रयोगकर्ता नाम छान्नुहोस्',
      'en': 'Choose a username',
    },
    'usernameMin3': {
      'ne': 'कम्तिमा ३ अक्षर आवश्यक छ',
      'en': 'Minimum 3 characters required',
    },
    'passwordMin6Hint': {
      'ne': 'कम्तिमा ६ अक्षर',
      'en': 'At least 6 characters',
    },
    'passwordMin6': {
      'ne': 'पासवर्ड कम्तिमा ६ अक्षरको हुनुपर्छ',
      'en': 'Password must be at least 6 characters',
    },
    'confirmPassword': {
      'ne': 'पासवर्ड पुष्टि गर्नुहोस्',
      'en': 'Confirm Password',
    },
    'confirmPasswordHint': {
      'ne': 'पासवर्ड फेरि लेख्नुहोस्',
      'en': 'Re-enter your password',
    },
    'confirmPasswordRequired': {
      'ne': 'पासवर्ड पुष्टि आवश्यक छ',
      'en': 'Please confirm your password',
    },
    'passwordMismatch': {
      'ne': 'पासवर्ड मेल खाएन',
      'en': 'Passwords do not match',
    },
    'register': {'ne': 'दर्ता गर्नुहोस्', 'en': 'Register'},
    'registerSuccess': {
      'ne': 'खाता सफलतापूर्वक बनाइयो! कृपया लगइन गर्नुहोस्।',
      'en': 'Account created! Please login.',
    },
    'registerFailed': {
      'ne': 'दर्ता असफल भयो। पुन: प्रयास गर्नुहोस्।',
      'en': 'Registration failed. Please try again.',
    },
    'alreadyHaveAccount': {
      'ne': 'पहिले नै खाता छ? लगइन गर्नुहोस्',
      'en': 'Already have an account? Login',
    },
  };

  static String get(String key, String lang) {
    return _strings[key]?[lang] ?? _strings[key]?['en'] ?? key;
  }
}
