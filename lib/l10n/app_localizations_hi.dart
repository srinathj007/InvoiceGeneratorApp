// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'इनवॉइस जेनरेटर';

  @override
  String get welcomeBack => 'वापसी पर स्वागत है';

  @override
  String get signInToPortfolio => 'अपने पोर्टफोलियो में साइन इन करें';

  @override
  String get emailAddress => 'ईमेल पता';

  @override
  String get enterEmail => 'name@example.com';

  @override
  String get password => 'पासवर्ड';

  @override
  String get enterPassword => 'अपना पासवर्ड दर्ज करें';

  @override
  String get forgotPassword => 'पासवर्ड भूल गए?';

  @override
  String get signIn => 'साइन इन';

  @override
  String get dontHaveAccount => 'खाता नहीं है? ';

  @override
  String get signUp => 'साइन अप';

  @override
  String get secureFinance => 'सुरक्षित वित्त';

  @override
  String get secureFinanceDesc =>
      'सुरक्षित और गतिशील वातावरण में अपने धन को बढ़ते हुए देखें।';

  @override
  String get createAccount => 'खाता बनाएं';

  @override
  String get joinCommunity => 'हमारे प्रीमियम वित्त समुदाय में शामिल हों';

  @override
  String get fullName => 'पूरा नाम';

  @override
  String get enterName => 'जॉन डो';

  @override
  String get createPassword => 'पासवर्ड बनाएं';

  @override
  String get alreadyHaveAccount => 'क्या आपके पास पहले से एक खाता मौजूद है? ';

  @override
  String get joinFuture => 'भविष्य में शामिल हों';

  @override
  String get joinFutureDesc =>
      'खाता बनाएं और आधुनिक विकास के लिए डिज़ाइन किए गए प्रीमियम वित्तीय टूल तक पहुंचें।';

  @override
  String get settings => 'सेटिंग्स';

  @override
  String get businessProfile => 'व्यापार प्रोफ़ाइल';

  @override
  String get editProfile => 'प्रोफ़ाइल संपादित करें';

  @override
  String get logout => 'लॉग आउट';

  @override
  String get logoutConfirmation => 'क्या आप वाकई लॉग आउट करना चाहते हैं?';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get annualEarnings => 'वार्षिक कमाई';

  @override
  String get monthlyEarnings => 'मासिक कमाई';

  @override
  String get realTimeData => 'वास्तविक समय डेटा';

  @override
  String get newInvoice => 'नई इनवॉइस';

  @override
  String get clients => 'ग्राहक';

  @override
  String get recentActivity => 'हाल की गतिविधि';

  @override
  String get noRecentInvoices => 'कोई हालिया इनवॉइस नहीं';

  @override
  String get invoiceDetails => 'इनवॉइस विवरण';

  @override
  String get delete => 'हटाएं';

  @override
  String get edit => 'संपादित करें';

  @override
  String get viewAndPrint => 'पूरी इनवॉइस देखें और प्रिंट करें';

  @override
  String get deleteInvoice => 'इनवॉइस हटाएं';

  @override
  String deleteConfirmation(Object number) {
    return 'इनवॉइस #$number हटाएं?';
  }

  @override
  String get deleteSuccess => 'सफलतापूर्वक हटाया गया';

  @override
  String get language => 'भाषा';

  @override
  String get selectLanguage => 'भाषा चुनें';

  @override
  String get item => 'वस्तु';

  @override
  String get qty => 'मात्रा';

  @override
  String get price => 'मूल्य';

  @override
  String get total => 'कुल';

  @override
  String get sharePdf => 'PDF साझा करें';

  @override
  String get printInvoice => 'चालान प्रिंट करें';

  @override
  String get createInvoice => 'चालान बनाएं';

  @override
  String get customerDetails => 'ग्राहक विवरण';

  @override
  String get customerName => 'ग्राहक का नाम';

  @override
  String get enterCustomerName => 'ग्राहक का नाम दर्ज करें';

  @override
  String get mobileNumber => 'मोबाइल नंबर';

  @override
  String get enterMobileNumber => 'मोबाइल नंबर दर्ज करें';

  @override
  String get invoiceDate => 'चालान की तारीख';

  @override
  String get addItem => 'वस्तु जोड़ें';

  @override
  String get itemName => 'वस्तु का नाम';

  @override
  String get addToInvoice => 'चालान में जोड़ें';

  @override
  String get noItemsAdded => 'कोई वस्तु नहीं जोड़ी गई';

  @override
  String get subtotal => 'उपयोग';

  @override
  String get discount => 'छूट';

  @override
  String get gst => 'GST';

  @override
  String get grandTotal => 'कुल योग';

  @override
  String get saveInvoice => 'चालान सहेजें';

  @override
  String get invoiceSaved => 'चालान सफलतापूर्वक सहेजा गया';

  @override
  String get invoiceUpdated => 'चालान सफलतापूर्वक अपडेट किया गया';

  @override
  String get errorSaving => 'चालान सहेजने में त्रुटि';

  @override
  String get invoices => 'चालान';

  @override
  String get searchPlaceholder => 'ग्राहक, चालान, विवरण खोजें...';

  @override
  String get newestFirst => 'सबसे नया पहले';

  @override
  String get oldestFirst => 'पुराना पहले';

  @override
  String get highestAmount => 'उच्चतम राशि';

  @override
  String get lowestAmount => 'न्यूनतम राशि';

  @override
  String get customerAZ => 'ग्राहक A-Z';

  @override
  String get noInvoicesFound => 'कोई चालान नहीं मिला';

  @override
  String get startCreatingInvoice => 'आरंभ करने के लिए एक नया चालान बनाएं';

  @override
  String get errorLoadingInvoices => 'चालान लोड करने में त्रुटि';

  @override
  String get filters => 'फ़िल्टर';

  @override
  String get reset => 'रीसेट';

  @override
  String get dateRange => 'तारीख सीमा';

  @override
  String get thisMonth => 'इस महीने';

  @override
  String get lastMonth => 'पिछले महीने';

  @override
  String get thisYear => 'इस साल';

  @override
  String get customRange => 'कस्टम सीमा';

  @override
  String get fromDate => 'शुरुआत की तारीख';

  @override
  String get toDate => 'अंतिम तारीख';

  @override
  String get apply => 'लागू करें';

  @override
  String get profileSettings => 'प्रोफ़ाइल सेटिंग्स';

  @override
  String get businessInfo => 'व्यापार जानकारी';

  @override
  String get companyLogo => 'कंपनी लोगो';

  @override
  String get businessName => 'व्यापार का नाम';

  @override
  String get enterBusinessName => 'जैसे श्रीनाथ मोटर्स';

  @override
  String get proprietorName => 'मालिक का नाम';

  @override
  String get enterProprietorName => 'जैसे श्रीनाथ';

  @override
  String get gstin => 'GSTIN';

  @override
  String get enterGstin => 'जैसे 36BXKPG2180H1ZH';

  @override
  String get customFields => 'कस्टम फ़ील्ड';

  @override
  String get customFieldLabel => 'कस्टम फ़ील्ड लेबल';

  @override
  String get enterCustomFieldLabel => 'जैसे संदर्भ संख्या';

  @override
  String get customFieldPlaceholder => 'कस्टम फ़ील्ड प्लेसहोल्डर';

  @override
  String get enterCustomFieldPlaceholder =>
      'जैसे संदर्भ या वाहन संख्या दर्ज करें';

  @override
  String get businessAssets => 'व्यापार संपत्तियां';

  @override
  String get proprietorSignature => 'मालिक के हस्ताक्षर';

  @override
  String get companionLogos => 'साथी लोगो';

  @override
  String get contactDetails => 'संपर्क विवरण';

  @override
  String get contactNumbers => 'संपर्क नंबर';

  @override
  String get enterContactNumbers => 'जैसे 9010123456';

  @override
  String get businessAddress => 'व्यापार पता';

  @override
  String get enterBusinessAddress => 'पूरी पता दर्ज करें...';

  @override
  String get saveBusinessProfile => 'व्यापार प्रोफ़ाइल सहेजें';

  @override
  String get profileSaved => 'प्रोफ़ाइल सफलतापूर्वक सहेजी गई';

  @override
  String get errorLoadingProfile => 'प्रोफ़ाइल लोड करने में त्रुटि';

  @override
  String get errorUploadingImage => 'छवि अपलोड करने में त्रुटि';

  @override
  String get uploading => 'अपलोड हो रहा है';

  @override
  String get uploadedSuccess => 'सफलतापूर्वक अपलोड किया गया';

  @override
  String get businessNameRequired => 'व्यापार का नाम आवश्यक है';

  @override
  String get enterEmailAddress => 'कृपया अपना ईमेल पता दर्ज करें';

  @override
  String get passwordResetSent =>
      'पासवर्ड रीसेट लिंक भेजा गया! अपना ईमेल देखें।';

  @override
  String get unexpectedError => 'एक अप्रत्याशित त्रुटि हुई';

  @override
  String get resetPassword => 'पासवर्ड रीसेट करें';

  @override
  String get recoveryInstructions =>
      'पुनर्प्राप्ति निर्देश प्राप्त करने के लिए अपना ईमेल दर्ज करें';

  @override
  String get sendResetLink => 'रीसेट लिंक भेजें';

  @override
  String get rememberPassword => 'अपना पासवर्ड याद है? ';

  @override
  String get accountRecovery => 'खाता पुनर्प्राप्ति';

  @override
  String get recoveryMessage =>
      'चिंता न करें! हमारे साथ भी ऐसा होता है। हम आपको जल्द ही आपके डैशबोर्ड पर वापस जाने में मदद करेंगे।';

  @override
  String get fillAllFields => 'कृपया सभी कोष्ठक भरें';

  @override
  String get registrationSuccess =>
      'पंजीकरण सफल! सत्यापन के लिए कृपया अपना ईमेल देखें।';

  @override
  String get accountExists =>
      'खाता पहले से मौजूद है। इसके बजाय साइन इन करने का प्रयास करें।';

  @override
  String get dashboard => 'डैशबोर्ड';

  @override
  String get email => 'ईमेल';

  @override
  String get userSessionExpired => 'उपयोगकर्ता सत्र समाप्त हो गया';

  @override
  String get switchBusiness => 'व्यापार बदलें';

  @override
  String get appTheme => 'ऐप थीम';

  @override
  String get about => 'के बारे में';

  @override
  String get switchLabel => 'बदलें';

  @override
  String get developedBy => 'द्वारा विकसित';

  @override
  String get modifyBusinessDetails => 'अपना व्यापार विवरण संशोधित करें';

  @override
  String get appVersion => 'ऐप संस्करण';

  @override
  String get active => 'सक्रिय';

  @override
  String get addNewBusiness => 'नया व्यापार जोड़ें';

  @override
  String get errorLoadingBusinesses => 'व्यापार लोड करने में त्रुटि';

  @override
  String get switchedSuccessfully => 'व्यापार सफलतापूर्वक बदल दिया गया';

  @override
  String get errorSwitchingBusiness => 'व्यापार बदलने में त्रुटि';
}
