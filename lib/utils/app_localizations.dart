import 'package:flutter/material.dart';
import 'package:junk_and_gems/providers/language_provider.dart';
import 'package:provider/provider.dart';

class AppLocalizations {
  final bool isSesotho;

  AppLocalizations(this.isSesotho);

  static AppLocalizations of(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    return AppLocalizations(languageProvider.isSesotho);
  }

  // Helper method to get translation
  String translate(String key) {
    return isSesotho ? _sesothoTranslations[key] ?? key : _englishTranslations[key] ?? key;
  }

  // Common
  String get appName => translate('app_name');
  String get yes => translate('yes');
  String get no => translate('no');
  String get cancel => translate('cancel');
  String get save => translate('save');
  String get delete => translate('delete');
  String get edit => translate('edit');
  String get back => translate('back');
  String get next => translate('next');
  String get skip => translate('skip');
  String get getStarted => translate('get_started');
  String get done => translate('done');
  String get loading => translate('loading');
  String get error => translate('error');
  String get success => translate('success');
  
  // Auth
  String get signIn => translate('sign_in');
  String get signUp => translate('sign_up');
  String get signOut => translate('sign_out');
  String get email => translate('email');
  String get password => translate('password');
  String get confirmPassword => translate('confirm_password');
  String get forgotPassword => translate('forgot_password');
  String get resetPassword => translate('reset_password');
  String get name => translate('name');
  String get createAccount => translate('create_account');
  String get alreadyHaveAccount => translate('already_have_account');
  String get dontHaveAccount => translate('dont_have_account');
  
  // Onboarding
  String get onboardingTitle1 => translate('onboarding_title_1');
  String get onboardingDesc1 => translate('onboarding_desc_1');
  String get onboardingTitle2 => translate('onboarding_title_2');
  String get onboardingDesc2 => translate('onboarding_desc_2');
  String get onboardingTitle3 => translate('onboarding_title_3');
  String get onboardingDesc3 => translate('onboarding_desc_3');
  String get onboardingSubtitle => translate('onboarding_subtitle'); // ADDED
  String get learnMore => translate('learn_more');
  
  // Settings
  String get settings => translate('settings');
  String get quickSettings => translate('quick_settings');
  String get notifications => translate('notifications');
  String get darkMode => translate('dark_mode');
  String get preferences => translate('preferences');
  String get paymentsEarnings => translate('payments_earnings');
  String get appPreferences => translate('app_preferences');
  String get support => translate('support');
  String get helpSupport => translate('help_support');
  String get legalInfo => translate('legal_info');
  String get account => translate('account');
  String get deleteAccount => translate('delete_account');
  String get deleteAccountWarning => translate('delete_account_warning');
  String get signOutConfirm => translate('sign_out_confirm');
  
  // Language & Display
  String get language => translate('language');
  String get appLanguage => translate('app_language');
  String get english => translate('english');
  String get sesotho => translate('sesotho');
  String get fontSize => translate('font_size');
  String get fontSizeSmall => translate('font_size_small');
  String get fontSizeMedium => translate('font_size_medium');
  String get fontSizeLarge => translate('font_size_large');
  String get display => translate('display');
  String get preview => translate('preview');
  String get appPreview => translate('app_preview');
  String get previewText => translate('preview_text');
  
  // Materials/Donations
  String get materials => translate('materials');
  String get donate => translate('donate');
  String get donateMaterials => translate('donate_materials');
  String get myDonations => translate('my_donations');
  String get browse => translate('browse');
  String get browseMaterials => translate('browse_materials');
  String get category => translate('category');
  String get quantity => translate('quantity');
  String get location => translate('location');
  String get description => translate('description');
  String get addPhotos => translate('add_photos');
  String get uploadImages => translate('upload_images');
  String get submitDonation => translate('submit_donation');
  
  // Products/Shop
  String get shop => translate('shop');
  String get products => translate('products');
  String get myProducts => translate('my_products');
  String get addProduct => translate('add_product');
  String get price => translate('price');
  String get condition => translate('condition');
  String get materialsUsed => translate('materials_used');
  String get dimensions => translate('dimensions');
  String get addToCart => translate('add_to_cart');
  String get cart => translate('cart');
  String get checkout => translate('checkout');
  String get total => translate('total');
  
  // Community
  String get community => translate('community');
  String get artisans => translate('artisans');
  String get contributors => translate('contributors');
  String get messages => translate('messages');
  String get chat => translate('chat');
  String get sendMessage => translate('send_message');
  
  // Profile
  String get profile => translate('profile');
  String get editProfile => translate('edit_profile');
  String get myProfile => translate('my_profile');
  String get bio => translate('bio');
  String get specialty => translate('specialty');
  String get userType => translate('user_type');
  String get artisan => translate('artisan');
  String get contributor => translate('contributor');
  String get both => translate('both');
  
  // Gems & Rewards
  String get gems => translate('gems');
  String get availableGems => translate('available_gems');
  String get earnGems => translate('earn_gems');
  String get redeemGems => translate('redeem_gems');
  String get gemsEarned => translate('gems_earned');
  String get dailyReward => translate('daily_reward');
  String get claimReward => translate('claim_reward');
  
  // Impact
  String get impact => translate('impact');
  String get myImpact => translate('my_impact');
  String get piecesDonated => translate('pieces_donated');
  String get upcycledItems => translate('upcycled_items');
  String get coTwoSaved => translate('co2_saved');

  // Navigation
  String get home => translate('home');
  String get explore => translate('explore');
  String get add => translate('add');
  String get inbox => translate('inbox');
  
  // Status messages
  String get uploadSuccess => translate('upload_success');
  String get uploadFailed => translate('upload_failed');
  String get deleteSuccess => translate('delete_success');
  String get updateSuccess => translate('update_success');
  String get somethingWentWrong => translate('something_went_wrong');

  // English Translations
  static final Map<String, String> _englishTranslations = {
    'app_name': 'Junk & Gems',
    'yes': 'Yes',
    'no': 'No',
    'cancel': 'Cancel',
    'save': 'Save',
    'delete': 'Delete',
    'edit': 'Edit',
    'back': 'Back',
    'next': 'Next',
    'skip': 'Skip',
    'get_started': 'Get Started',
    'done': 'Done',
    'loading': 'Loading...',
    'error': 'Error',
    'success': 'Success',
    
    // Auth
    'sign_in': 'Sign In',
    'sign_up': 'Sign Up',
    'sign_out': 'Sign Out',
    'email': 'Email',
    'password': 'Password',
    'confirm_password': 'Confirm Password',
    'forgot_password': 'Forgot Password?',
    'reset_password': 'Reset Password',
    'name': 'Name',
    'create_account': 'Create Account',
    'already_have_account': 'Already have an account?',
    'dont_have_account': 'Don\'t have an account?',
    
    // Onboarding
    'onboarding_title_1': 'Turn Junk into Gems',
    'onboarding_desc_1': 'Donate unused materials and discover how waste can become wonderful',
    'onboarding_title_2': 'Earn Rewards',
    'onboarding_desc_2': 'Get gems for every contribution and unlock exclusive benefits',
    'onboarding_title_3': 'Build Community',
    'onboarding_desc_3': 'Connect with artisans and creators making a difference',
    'onboarding_subtitle': 'Turn your trash into treasure, together', 
    'learn_more': 'Learn More',
    
    // Settings
    'settings': 'Settings',
    'quick_settings': 'QUICK SETTINGS',
    'notifications': 'Notifications',
    'dark_mode': 'Dark Mode',
    'preferences': 'PREFERENCES',
    'payments_earnings': 'Payments & Earnings',
    'app_preferences': 'App Preferences',
    'support': 'SUPPORT',
    'help_support': 'Help & Support',
    'legal_info': 'Legal & Info',
    'account': 'ACCOUNT',
    'delete_account': 'Delete Account',
    'delete_account_warning': 'This action cannot be undone. All your data will be permanently deleted.',
    'sign_out_confirm': 'Are you sure you want to sign out?',
    
    // Language & Display
    'language': 'Language',
    'app_language': 'App Language',
    'english': 'English',
    'sesotho': 'Sesotho',
    'font_size': 'Font Size',
    'font_size_small': 'Small',
    'font_size_medium': 'Medium',
    'font_size_large': 'Large',
    'display': 'DISPLAY',
    'preview': 'Preview',
    'app_preview': 'App Preview',
    'preview_text': 'This is how your text will look with the selected font size.',
    
    // Materials
    'materials': 'Materials',
    'donate': 'Donate',
    'donate_materials': 'Donate Materials',
    'my_donations': 'My Donations',
    'browse': 'Browse',
    'browse_materials': 'Browse Materials',
    'category': 'Category',
    'quantity': 'Quantity',
    'location': 'Location',
    'description': 'Description',
    'add_photos': 'Add Photos',
    'upload_images': 'Upload Images',
    'submit_donation': 'Submit Donation',
    
    // Products
    'shop': 'Shop',
    'products': 'Products',
    'my_products': 'My Products',
    'add_product': 'Add Product',
    'price': 'Price',
    'condition': 'Condition',
    'materials_used': 'Materials Used',
    'dimensions': 'Dimensions',
    'add_to_cart': 'Add to Cart',
    'cart': 'Cart',
    'checkout': 'Checkout',
    'total': 'Total',
    
    // Community
    'community': 'Community',
    'artisans': 'Artisans',
    'contributors': 'Contributors',
    'messages': 'Messages',
    'chat': 'Chat',
    'send_message': 'Send Message',
    
    // Profile
    'profile': 'Profile',
    'edit_profile': 'Edit Profile',
    'my_profile': 'My Profile',
    'bio': 'Bio',
    'specialty': 'Specialty',
    'user_type': 'User Type',
    'artisan': 'Artisan',
    'contributor': 'Contributor',
    'both': 'Both',
    
    // Gems
    'gems': 'Gems',
    'available_gems': 'Available Gems',
    'earn_gems': 'Earn Gems',
    'redeem_gems': 'Redeem Gems',
    'gems_earned': 'Gems Earned',
    'daily_reward': 'Daily Reward',
    'claim_reward': 'Claim Reward',
    
    // Impact
    'impact': 'Impact',
    'my_impact': 'My Impact',
    'pieces_donated': 'Pieces Donated',
    'upcycled_items': 'Upcycled Items',
    'co2_saved': 'CO₂ Saved',
    
    // Navigation
    'home': 'Home',
    'explore': 'Explore',
    'add': 'Add',
    'inbox': 'Inbox',
    
    // Status
    'upload_success': 'Upload successful',
    'upload_failed': 'Upload failed',
    'delete_success': 'Deleted successfully',
    'update_success': 'Updated successfully',
    'something_went_wrong': 'Something went wrong',
  };

  // Sesotho Translations
  static final Map<String, String> _sesothoTranslations = {
    'app_name': 'Junk & Gems',
    'yes': 'ee',
    'no': 'che',
    'cancel': 'Hlakola',
    'save': 'Boloka',
    'delete': 'Hlakola',
    'edit': 'Lokisa',
    'back': 'Morao',
    'next': 'Latelang',
    'skip': 'Tlola',
    'get_started': 'Qala',
    'done': 'Qetile',
    'loading': '...',
    'error': 'Phoso',
    'success': 'Katleho',
    
    // Auth
    'sign_in': 'Kena',
    'sign_up': 'Ngolisa',
    'sign_out': 'Tsoa',
    'email': 'Email',
    'password': 'Password',
    'confirm_password': 'Tiiso Phasewete',
    'forgot_password': 'U lebetse Phasewete?',
    'reset_password': 'Seta Phasewete',
    'name': 'Lebitso',
    'create_account': 'Theha Ak\'haonte',
    'already_have_account': 'U se u na le Ak\'haonte?',
    'dont_have_account': 'Ha u na Ak\'haonte?',
    
    // Onboarding
    'onboarding_title_1': 'Fetola Matlakala Hore e be Majoe a Bohlokoa',
    'onboarding_desc_1': 'Fana ka lintho tseo u sa li hlokeng mme u bone hore na matlakala a ka fetoha joang lintho tse ntle',
    'onboarding_title_2': 'Fumana Meputso',
    'onboarding_desc_2': 'Fumana majoe bakeng sa ho kenya letsoho ka nngwe le nngwe mme u bulelle melemo e khethehileng',
    'onboarding_title_3': 'Aha Sechaba',
    'onboarding_desc_3': 'Hokahana le baetsi le bahoebi ba etsang phapang',
    
    // Settings
    'settings': 'Litlhophiso',
    'quick_settings': 'Litlhophiso tse Potlakileng',
    'notifications': 'Litsebiso',
    'dark_mode': 'Mokhoa o Lefifi',
    'preferences': 'Likhetho',
    'payments_earnings': 'Litefo',
    'app_preferences': 'Likhetho tsa App',
    'support': 'TŠEHETSO',
    'help_support': 'Thusa Tšehetso',
    'legal_info': 'Lintlha tsa Molao',
    'account': 'Ak\'haonte',
    'delete_account': 'Hlakola Ak\'haonte',
    'delete_account_warning': 'Sena ha se khone ho khutlisoa morao. Lintlha tsohle tsa hau li tla hlakoloa ka ho sa feleng.',
    'sign_out_confirm': 'U na u tiisitse hore u batla ho tsoa?',
    
    // Language & Display
    'language': 'Puo',
    'app_language': 'Puo ea App',
    'english': 'Sekhoa',
    'sesotho': 'Sesotho',
    'font_size': 'Boholo ba Fonte',
    'font_size_small': 'E Nyane',
    'font_size_medium': 'Mahareng',
    'font_size_large': 'E Kholo',
    'display': 'Bontsha',
    'preview': 'Ponelopele',
    'app_preview': 'Ponelopele ea App',
    'preview_text': 'Ke kamoo mongolo oa hau o tla sheba boholo bo khethiloeng.',
    
    // Materials
    'materials': 'Lintho',
    'donate': 'Fana',
    'donate_materials': 'Fana ka Lintho',
    'my_donations': 'Menehelo ea ka',
    'browse': 'Sheba',
    'browse_materials': 'Sheba Lintho',
    'category': 'Sehlopha',
    'quantity': 'Bongata',
    'location': 'Sebaka',
    'description': 'Tlhaloso',
    'add_photos': 'Kenya Lifoto',
    'upload_images': 'Kenya litšoantšo',
    'submit_donation': 'Fana ka Monehelo',
    
    // Products
    'shop': 'Lebenkele',
    'products': 'Lihlahisoa',
    'my_products': 'Lihlahisoa tsa ka',
    'add_product': 'Eketsa Sehlahisoa',
    'price': 'Theko',
    'condition': 'Boemo',
    'materials_used': 'Lintho tse Sebelisoang',
    'dimensions': 'Boholo',
    'add_to_cart': 'Eketsa ntho',
    'cart': 'Mokotla',
    'checkout': 'Reka',
    'total': 'Eketsa',
    
    // Community
    'community': 'Sechaba',
    'artisans': 'Litsebi tsa mesebetsi ea matsoho',
    'contributors': 'Bafani',
    'messages': 'Melaetsa',
    'chat': 'Chat',
    'send_message': 'Romela Molaetsa',
    
    // Profile
    'profile': 'Profaele',
    'edit_profile': 'Lokisa Profaele',
    'my_profile': 'Profaele ea Ka',
    'bio': 'Bio',
    'specialty': 'Specialty',
    'user_type': 'Mofuta oa Mosebelisi',
    'artisan': 'Setsebi sa mesebetsi ea matsoho',
    'contributor': 'Mofani',
    'both': 'Ka Bobeli',
    
    // Gems
    'gems': 'Majoe',
    'available_gems': 'Majoe a Fumanehang',
    'earn_gems': 'Fumana Majoe',
    'redeem_gems': 'Lopolla Majoe',
    'gems_earned': 'Majoe a Fumannoeng',
    'daily_reward': 'Moputso oa Letsatsi le Letsatsi',
    'claim_reward': 'Nka Moputso',
    
    // Impact
    'impact': 'Tšusumetso',
    'my_impact': 'Tšusumetso ea ka',
    'pieces_donated': 'Likotoana tse Fanoeng',
    'upcycled_items': 'Lintho tse Sebelitsoeng Hape',
    'co2_saved': 'CO₂ e Bolokiloeng',
    
    // Navigation
    'home': 'Hae',
    'explore': 'Hlahloba',
    'add': 'Eketsa',
    'inbox': 'Inbox',
    
    // Status
    'upload_success': 'Ho laelisa ho atlehile',
    'upload_failed': 'Ho laelisa ho hloleile',
    'delete_success': 'Ho hlakoloa ho atlehile',
    'update_success': 'Ho ntjafatsoa ho atlehile',
    'something_went_wrong': 'Ho etsahele ntho e seng hantle',
  };
}

// Extension method for easy access
extension BuildContextExtension on BuildContext {
  AppLocalizations get loc => AppLocalizations.of(this);
}