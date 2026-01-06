import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_te.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
    Locale('te'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Invoice Generator'**
  String get appTitle;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @signInToPortfolio.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your portfolio'**
  String get signInToPortfolio;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'name@example.com'**
  String get enterEmail;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterPassword;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get dontHaveAccount;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @secureFinance.
  ///
  /// In en, this message translates to:
  /// **'Secure Finance'**
  String get secureFinance;

  /// No description provided for @secureFinanceDesc.
  ///
  /// In en, this message translates to:
  /// **'Experience your wealth grow in a safe and high-motion digital environment.'**
  String get secureFinanceDesc;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @joinCommunity.
  ///
  /// In en, this message translates to:
  /// **'Join our premium finance community'**
  String get joinCommunity;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @enterName.
  ///
  /// In en, this message translates to:
  /// **'John Doe'**
  String get enterName;

  /// No description provided for @createPassword.
  ///
  /// In en, this message translates to:
  /// **'Create a password'**
  String get createPassword;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// No description provided for @joinFuture.
  ///
  /// In en, this message translates to:
  /// **'Join the Future'**
  String get joinFuture;

  /// No description provided for @joinFutureDesc.
  ///
  /// In en, this message translates to:
  /// **'Create an account and access premium financial tools designed for modern growth.'**
  String get joinFutureDesc;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @businessProfile.
  ///
  /// In en, this message translates to:
  /// **'Business Profile'**
  String get businessProfile;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logout;

  /// No description provided for @logoutConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get logoutConfirmation;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @annualEarnings.
  ///
  /// In en, this message translates to:
  /// **'Annual Earnings'**
  String get annualEarnings;

  /// No description provided for @monthlyEarnings.
  ///
  /// In en, this message translates to:
  /// **'Monthly Earnings'**
  String get monthlyEarnings;

  /// No description provided for @realTimeData.
  ///
  /// In en, this message translates to:
  /// **'Real-time data'**
  String get realTimeData;

  /// No description provided for @newInvoice.
  ///
  /// In en, this message translates to:
  /// **'New Invoice'**
  String get newInvoice;

  /// No description provided for @clients.
  ///
  /// In en, this message translates to:
  /// **'Clients'**
  String get clients;

  /// No description provided for @recentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get recentActivity;

  /// No description provided for @noRecentInvoices.
  ///
  /// In en, this message translates to:
  /// **'No recent invoices'**
  String get noRecentInvoices;

  /// No description provided for @invoiceDetails.
  ///
  /// In en, this message translates to:
  /// **'Invoice Details'**
  String get invoiceDetails;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @viewAndPrint.
  ///
  /// In en, this message translates to:
  /// **'View Full Invoice & Print'**
  String get viewAndPrint;

  /// No description provided for @deleteInvoice.
  ///
  /// In en, this message translates to:
  /// **'Delete Invoice'**
  String get deleteInvoice;

  /// No description provided for @deleteConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Delete Invoice #{number}?'**
  String deleteConfirmation(Object number);

  /// No description provided for @deleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Deleted successfully'**
  String get deleteSuccess;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @item.
  ///
  /// In en, this message translates to:
  /// **'ITEM'**
  String get item;

  /// No description provided for @qty.
  ///
  /// In en, this message translates to:
  /// **'QTY'**
  String get qty;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'PRICE'**
  String get price;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'TOTAL'**
  String get total;

  /// No description provided for @sharePdf.
  ///
  /// In en, this message translates to:
  /// **'Share PDF'**
  String get sharePdf;

  /// No description provided for @printInvoice.
  ///
  /// In en, this message translates to:
  /// **'Print Invoice'**
  String get printInvoice;

  /// No description provided for @createInvoice.
  ///
  /// In en, this message translates to:
  /// **'Create Invoice'**
  String get createInvoice;

  /// No description provided for @customerDetails.
  ///
  /// In en, this message translates to:
  /// **'Customer Details'**
  String get customerDetails;

  /// No description provided for @customerName.
  ///
  /// In en, this message translates to:
  /// **'Customer Name'**
  String get customerName;

  /// No description provided for @enterCustomerName.
  ///
  /// In en, this message translates to:
  /// **'Enter customer name'**
  String get enterCustomerName;

  /// No description provided for @mobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Mobile Number'**
  String get mobileNumber;

  /// No description provided for @enterMobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter mobile number'**
  String get enterMobileNumber;

  /// No description provided for @invoiceDate.
  ///
  /// In en, this message translates to:
  /// **'Invoice Date'**
  String get invoiceDate;

  /// No description provided for @addItem.
  ///
  /// In en, this message translates to:
  /// **'Add Item'**
  String get addItem;

  /// No description provided for @itemName.
  ///
  /// In en, this message translates to:
  /// **'Item Name'**
  String get itemName;

  /// No description provided for @addToInvoice.
  ///
  /// In en, this message translates to:
  /// **'Add to Invoice'**
  String get addToInvoice;

  /// No description provided for @noItemsAdded.
  ///
  /// In en, this message translates to:
  /// **'No items added'**
  String get noItemsAdded;

  /// No description provided for @subtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// No description provided for @discount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get discount;

  /// No description provided for @gst.
  ///
  /// In en, this message translates to:
  /// **'GST'**
  String get gst;

  /// No description provided for @grandTotal.
  ///
  /// In en, this message translates to:
  /// **'Grand Total'**
  String get grandTotal;

  /// No description provided for @saveInvoice.
  ///
  /// In en, this message translates to:
  /// **'Save Invoice'**
  String get saveInvoice;

  /// No description provided for @invoiceSaved.
  ///
  /// In en, this message translates to:
  /// **'Invoice saved successfully'**
  String get invoiceSaved;

  /// No description provided for @invoiceUpdated.
  ///
  /// In en, this message translates to:
  /// **'Invoice updated successfully'**
  String get invoiceUpdated;

  /// No description provided for @errorSaving.
  ///
  /// In en, this message translates to:
  /// **'Error saving invoice'**
  String get errorSaving;

  /// No description provided for @invoices.
  ///
  /// In en, this message translates to:
  /// **'Invoices'**
  String get invoices;

  /// No description provided for @searchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search customer, invoice, details...'**
  String get searchPlaceholder;

  /// No description provided for @newestFirst.
  ///
  /// In en, this message translates to:
  /// **'Newest First'**
  String get newestFirst;

  /// No description provided for @oldestFirst.
  ///
  /// In en, this message translates to:
  /// **'Oldest First'**
  String get oldestFirst;

  /// No description provided for @highestAmount.
  ///
  /// In en, this message translates to:
  /// **'Highest Amount'**
  String get highestAmount;

  /// No description provided for @lowestAmount.
  ///
  /// In en, this message translates to:
  /// **'Lowest Amount'**
  String get lowestAmount;

  /// No description provided for @customerAZ.
  ///
  /// In en, this message translates to:
  /// **'Customer A-Z'**
  String get customerAZ;

  /// No description provided for @noInvoicesFound.
  ///
  /// In en, this message translates to:
  /// **'No invoices found'**
  String get noInvoicesFound;

  /// No description provided for @startCreatingInvoice.
  ///
  /// In en, this message translates to:
  /// **'Create a new invoice to get started'**
  String get startCreatingInvoice;

  /// No description provided for @errorLoadingInvoices.
  ///
  /// In en, this message translates to:
  /// **'Error loading invoices'**
  String get errorLoadingInvoices;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @dateRange.
  ///
  /// In en, this message translates to:
  /// **'DATE RANGE'**
  String get dateRange;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// No description provided for @lastMonth.
  ///
  /// In en, this message translates to:
  /// **'Last Month'**
  String get lastMonth;

  /// No description provided for @thisYear.
  ///
  /// In en, this message translates to:
  /// **'This Year'**
  String get thisYear;

  /// No description provided for @customRange.
  ///
  /// In en, this message translates to:
  /// **'CUSTOM RANGE'**
  String get customRange;

  /// No description provided for @fromDate.
  ///
  /// In en, this message translates to:
  /// **'From Date'**
  String get fromDate;

  /// No description provided for @toDate.
  ///
  /// In en, this message translates to:
  /// **'To Date'**
  String get toDate;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @profileSettings.
  ///
  /// In en, this message translates to:
  /// **'Profile Settings'**
  String get profileSettings;

  /// No description provided for @businessInfo.
  ///
  /// In en, this message translates to:
  /// **'Business Info'**
  String get businessInfo;

  /// No description provided for @companyLogo.
  ///
  /// In en, this message translates to:
  /// **'Company Logo'**
  String get companyLogo;

  /// No description provided for @businessName.
  ///
  /// In en, this message translates to:
  /// **'Business Name'**
  String get businessName;

  /// No description provided for @enterBusinessName.
  ///
  /// In en, this message translates to:
  /// **'e.g. Srinath Motors'**
  String get enterBusinessName;

  /// No description provided for @proprietorName.
  ///
  /// In en, this message translates to:
  /// **'Proprietor Name'**
  String get proprietorName;

  /// No description provided for @enterProprietorName.
  ///
  /// In en, this message translates to:
  /// **'e.g. Srinath'**
  String get enterProprietorName;

  /// No description provided for @gstin.
  ///
  /// In en, this message translates to:
  /// **'GSTIN'**
  String get gstin;

  /// No description provided for @enterGstin.
  ///
  /// In en, this message translates to:
  /// **'e.g. 36BXKPG2180H1ZH'**
  String get enterGstin;

  /// No description provided for @customFields.
  ///
  /// In en, this message translates to:
  /// **'Custom Fields'**
  String get customFields;

  /// No description provided for @customFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Custom Field Label'**
  String get customFieldLabel;

  /// No description provided for @enterCustomFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'e.g. Reference No, Order ID'**
  String get enterCustomFieldLabel;

  /// No description provided for @customFieldPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Custom Field Placeholder'**
  String get customFieldPlaceholder;

  /// No description provided for @enterCustomFieldPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'e.g. Enter reference or vehicle number'**
  String get enterCustomFieldPlaceholder;

  /// No description provided for @businessAssets.
  ///
  /// In en, this message translates to:
  /// **'Business Assets'**
  String get businessAssets;

  /// No description provided for @proprietorSignature.
  ///
  /// In en, this message translates to:
  /// **'Proprietor Signature'**
  String get proprietorSignature;

  /// No description provided for @companionLogos.
  ///
  /// In en, this message translates to:
  /// **'Companion Logos'**
  String get companionLogos;

  /// No description provided for @contactDetails.
  ///
  /// In en, this message translates to:
  /// **'Contact Details'**
  String get contactDetails;

  /// No description provided for @contactNumbers.
  ///
  /// In en, this message translates to:
  /// **'Contact Numbers'**
  String get contactNumbers;

  /// No description provided for @enterContactNumbers.
  ///
  /// In en, this message translates to:
  /// **'e.g. 9010123456, 7777123456'**
  String get enterContactNumbers;

  /// No description provided for @businessAddress.
  ///
  /// In en, this message translates to:
  /// **'Business Address'**
  String get businessAddress;

  /// No description provided for @enterBusinessAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter full address...'**
  String get enterBusinessAddress;

  /// No description provided for @saveBusinessProfile.
  ///
  /// In en, this message translates to:
  /// **'Save Business Profile'**
  String get saveBusinessProfile;

  /// No description provided for @profileSaved.
  ///
  /// In en, this message translates to:
  /// **'Profile saved successfully'**
  String get profileSaved;

  /// No description provided for @errorLoadingProfile.
  ///
  /// In en, this message translates to:
  /// **'Error loading profile'**
  String get errorLoadingProfile;

  /// No description provided for @errorUploadingImage.
  ///
  /// In en, this message translates to:
  /// **'Error uploading image'**
  String get errorUploadingImage;

  /// No description provided for @uploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading'**
  String get uploading;

  /// No description provided for @uploadedSuccess.
  ///
  /// In en, this message translates to:
  /// **'uploaded successfully'**
  String get uploadedSuccess;

  /// No description provided for @businessNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Business Name is required'**
  String get businessNameRequired;

  /// No description provided for @enterEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email address'**
  String get enterEmailAddress;

  /// No description provided for @passwordResetSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset link sent! Check your email.'**
  String get passwordResetSent;

  /// No description provided for @unexpectedError.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred'**
  String get unexpectedError;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @recoveryInstructions.
  ///
  /// In en, this message translates to:
  /// **'Enter your email to receive recovery instructions'**
  String get recoveryInstructions;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get sendResetLink;

  /// No description provided for @rememberPassword.
  ///
  /// In en, this message translates to:
  /// **'Remember your password? '**
  String get rememberPassword;

  /// No description provided for @accountRecovery.
  ///
  /// In en, this message translates to:
  /// **'Account Recovery'**
  String get accountRecovery;

  /// No description provided for @recoveryMessage.
  ///
  /// In en, this message translates to:
  /// **'Don\'t worry! It happens to the best of us. We\'ll help you get back to your dashboard in no time.'**
  String get recoveryMessage;

  /// No description provided for @fillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all fields'**
  String get fillAllFields;

  /// No description provided for @registrationSuccess.
  ///
  /// In en, this message translates to:
  /// **'Registration successful! Please check your email for verification.'**
  String get registrationSuccess;

  /// No description provided for @accountExists.
  ///
  /// In en, this message translates to:
  /// **'Account already exists. Try signing in instead.'**
  String get accountExists;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @userSessionExpired.
  ///
  /// In en, this message translates to:
  /// **'User session expired'**
  String get userSessionExpired;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi', 'te'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'te':
      return AppLocalizationsTe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
