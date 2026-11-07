/// Strings and configuration for the account settings pages reached from both
/// the traveller and the partner profile: payment methods, language,
/// feedback, customer support and about.
abstract final class AccountSettingsStrings {
  // ── Payment methods ──
  static const paymentTitle = 'Payment Method';
  static const upiTitle = 'UPI';
  static const upiCaption = 'Pay by any UPI app.';
  static const googlePay = 'Google Pay';
  static const phonePe = 'PhonePe';
  static const paytm = 'Paytm';
  static const addOtherUpi = 'Add other UPI app';
  static const addOtherUpiCaption = 'Choose your app';
  static const upiIdHint = 'name@bank';
  static const upiIdTitle = 'Add a UPI ID';
  static const cardTitle = 'Debit/Credit Card';
  static const cardCaption = 'Add card details';
  static const add = 'ADD';
  static const edit = 'Edit';
  static const save = 'Save';
  static const remove = 'Remove';
  static const nameOnCard = 'Name on card';
  static const nameHint = 'Name';
  static const cardNumber = 'Card number';
  static const cardNumberHint = 'XXXX XXXX XXXX XXXX';
  static const cardExpiry = 'Card expire date';
  static const cardExpiryHint = 'MM / YY';
  static const cardNumberNote =
      'Only the last 4 digits are saved. The full card number never leaves '
      'this phone.';
  static const defaultBadge = 'Default';
  static const expiredBadge = 'Expired';
  static const invalidCardNumber = 'Enter a valid card number.';
  static const invalidExpiry = 'Enter the expiry as MM / YY.';
  static const nameRequired = 'Enter the name on the card.';
  static const invalidUpi = 'Enter a UPI ID like name@bank.';
  static const removeTitle = 'Remove payment method?';
  static String removeMessage(String name) => '$name will be removed.';
  static const cancel = 'Cancel';
  static const saved = 'Saved';

  // ── Language ──
  static const languageTitle = 'Language';
  static const languageSaved = 'Language updated';

  // ── Feedback ──
  static const feedbackTitle = 'Feedback';
  static const feedbackHint = 'Enter your feedbacks';
  static const reset = 'Reset';
  static const enter = 'Enter';
  static const feedbackThanks = 'Thanks for your feedback';
  static const feedbackTooShort =
      'Please write at least $minMessageLength characters.';

  // ── Customer support ──
  static const supportTitle = 'Customer Support';
  static const supportHint = 'Enter your problem';
  static const submit = 'SUBMIT';
  static const supportSent =
      'We have your message and will get back to you soon.';
  static const supportLineUnavailable =
      'This support line is not available yet.';
  static const callFailed = 'Could not start a call on this device.';

  // ── About ──
  static const aboutTitle = 'About';

  static const errorTitle = 'Something went wrong';

  /// The backend's minimum for a feedback or support message.
  static const minMessageLength = 10;
  static const maxMessageLength = 2000;
}

/// A language the app can be switched to.
class AppLanguage {
  const AppLanguage({
    required this.code,
    required this.nativeName,
    required this.englishName,
  });

  final String code;
  final String nativeName;
  final String englishName;
}

/// A support phone line shown on the Customer Support page.
class SupportLine {
  const SupportLine({required this.label, required this.phone});

  final String label;

  /// Empty until the support team's number is configured; the button then
  /// explains the line is not available rather than dialling nothing.
  final String phone;
}

abstract final class AccountSettingsConfig {
  static const languages = [
    AppLanguage(code: 'en', nativeName: 'English', englishName: 'English'),
    AppLanguage(code: 'hi', nativeName: 'हिंदी', englishName: 'Hindi'),
    AppLanguage(code: 'ml', nativeName: 'മലയാളം', englishName: 'Malayalam'),
    AppLanguage(code: 'ta', nativeName: 'தமிழ்', englishName: 'Tamil'),
    AppLanguage(code: 'kn', nativeName: 'ಕನ್ನಡ', englishName: 'Kannada'),
  ];

  static const defaultLanguageCode = 'en';

  // TODO(support): fill in the support team's numbers before release.
  static const supportLines = [
    SupportLine(label: 'Customer Support 1', phone: ''),
    SupportLine(label: 'Customer Support 2', phone: ''),
  ];
}

/// Which side of the platform opened the About page.
enum AboutAudience { traveller, partner }

abstract final class AboutContent {
  static const partner = '''
Welcome to TripTriva — your partner in growing local tourism!

TripTriva is a digital platform that connects tourism businesses and experience providers with travelers looking for memorable things to do. We help local businesses showcase their activities, reach potential customers, and make their experiences easier to discover and book online.

Whether you offer houseboat cruises, adventure activities, guided tours, local experiences, or other tourism services, TripTriva gives you an opportunity to bring your offerings to more travelers.

Our mission is to support local tourism businesses by making their experiences more visible and accessible in the digital world.

Why Partner with TripTriva?
- Reach More Travelers: Showcase your experiences to potential customers.
- Increase Visibility: Make your tourism activities easier to discover online.
- Connect with Customers: Attract travelers searching for experiences like yours.
- Grow Your Business: Expand your reach through an online tourism marketplace.

We believe every local experience has a story worth sharing. Together, we can help more travelers discover it.

Partner with TripTriva. Reach more travelers. Grow your business.''';

  static const traveller = '''
Discover More. Experience More.

TripTriva is a travel experiences platform that makes discovering and booking exciting local activities simple and accessible. We connect travellers with local activity providers, helping them explore destinations through authentic experiences, adventures, and memorable moments.

From peaceful houseboat rides and scenic hilltop adventures to thrilling outdoor activities and unique local experiences, TripTriva helps you discover more of what every destination has to offer.

Our Mission
To make discovering and booking authentic travel experiences simple, convenient, and accessible for everyone.

Our Vision
To become India's leading marketplace for local tourism experiences, connecting travellers with small tourism businesses across the country.

What We Do
- Discover Experiences: Explore activities and attractions at your favourite destinations.
- Easy Booking: Find and book experiences conveniently through our platform.
- Support Local Businesses: Help local activity providers reach more travellers.
- Explore Your Way: Find experiences that match your interests, travel style, and budget.

Our Promise
At TripTriva, we believe every journey is an opportunity to create unforgettable memories. We're building a platform that brings travellers and local experiences closer together, making it easier to explore, experience, and enjoy more of India.

Your journey. Your choices. Your experiences.
Welcome to TripTriva!''';
}
