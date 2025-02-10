import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_th.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen_l10n/app_localizations.dart';
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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('th')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Life Countdown'**
  String get appTitle;

  /// No description provided for @startButton.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get startButton;

  /// No description provided for @aboutUsButton.
  ///
  /// In en, this message translates to:
  /// **'About Us'**
  String get aboutUsButton;

  /// No description provided for @supportButton.
  ///
  /// In en, this message translates to:
  /// **'Support Us'**
  String get supportButton;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'This app will encourage us to realize that we have limited time in life. Therefore, it is imperative to do important things without negligence before the time runs out.'**
  String get description;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageThai.
  ///
  /// In en, this message translates to:
  /// **'Thai'**
  String get languageThai;

  /// No description provided for @appBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get appBarTitle;

  /// No description provided for @selectDateHeader.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDateHeader;

  /// No description provided for @selectDateSubHeader.
  ///
  /// In en, this message translates to:
  /// **'When were you born?'**
  String get selectDateSubHeader;

  /// No description provided for @yearLabel.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get yearLabel;

  /// No description provided for @monthLabel.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get monthLabel;

  /// No description provided for @dayLabel.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get dayLabel;

  /// No description provided for @nextButton.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextButton;

  /// No description provided for @snackBarMessage.
  ///
  /// In en, this message translates to:
  /// **'Selected date: {date}'**
  String snackBarMessage(Object date);

  /// No description provided for @january.
  ///
  /// In en, this message translates to:
  /// **'January'**
  String get january;

  /// No description provided for @february.
  ///
  /// In en, this message translates to:
  /// **'February'**
  String get february;

  /// No description provided for @march.
  ///
  /// In en, this message translates to:
  /// **'March'**
  String get march;

  /// No description provided for @april.
  ///
  /// In en, this message translates to:
  /// **'April'**
  String get april;

  /// No description provided for @may.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get may;

  /// No description provided for @june.
  ///
  /// In en, this message translates to:
  /// **'June'**
  String get june;

  /// No description provided for @july.
  ///
  /// In en, this message translates to:
  /// **'July'**
  String get july;

  /// No description provided for @august.
  ///
  /// In en, this message translates to:
  /// **'August'**
  String get august;

  /// No description provided for @september.
  ///
  /// In en, this message translates to:
  /// **'September'**
  String get september;

  /// No description provided for @october.
  ///
  /// In en, this message translates to:
  /// **'October'**
  String get october;

  /// No description provided for @november.
  ///
  /// In en, this message translates to:
  /// **'November'**
  String get november;

  /// No description provided for @december.
  ///
  /// In en, this message translates to:
  /// **'December'**
  String get december;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @nextStepDescription.
  ///
  /// In en, this message translates to:
  /// **'Next, the website will ask for the day-month-year that you expect to be the time of your death. to estimate the time remaining on this planet.'**
  String get nextStepDescription;

  /// No description provided for @disclaimer.
  ///
  /// In en, this message translates to:
  /// **'This program is not a forecast program. So the time in your life may run out before or after this.'**
  String get disclaimer;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @readyToStartCountdown.
  ///
  /// In en, this message translates to:
  /// **'Click the \'Next\' to countdown your remaining days.'**
  String get readyToStartCountdown;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @selectAll.
  ///
  /// In en, this message translates to:
  /// **'Please select all items'**
  String get selectAll;

  /// No description provided for @agree.
  ///
  /// In en, this message translates to:
  /// **'Agree'**
  String get agree;

  /// No description provided for @pleaseSelectMonth.
  ///
  /// In en, this message translates to:
  /// **'Please select a month first'**
  String get pleaseSelectMonth;

  /// No description provided for @deathYear.
  ///
  /// In en, this message translates to:
  /// **'Death Year'**
  String get deathYear;

  /// No description provided for @deathYearQuestion.
  ///
  /// In en, this message translates to:
  /// **'What year do you think you will die?'**
  String get deathYearQuestion;

  /// No description provided for @yearLabel_lv1.
  ///
  /// In en, this message translates to:
  /// **''**
  String get yearLabel_lv1;

  /// No description provided for @ageWithYear.
  ///
  /// In en, this message translates to:
  /// **'Age {ageInThatYear} '**
  String ageWithYear(Object ageInThatYear);

  /// No description provided for @deathMonthTitle.
  ///
  /// In en, this message translates to:
  /// **'Death Month'**
  String get deathMonthTitle;

  /// No description provided for @deathMonthQuestion.
  ///
  /// In en, this message translates to:
  /// **'Which month do you think you will die?'**
  String get deathMonthQuestion;

  /// No description provided for @deathDayTitle.
  ///
  /// In en, this message translates to:
  /// **'Death Day'**
  String get deathDayTitle;

  /// No description provided for @deathDayQuestion.
  ///
  /// In en, this message translates to:
  /// **'What day do you think you\'ll die?'**
  String get deathDayQuestion;

  /// No description provided for @sunday.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get sunday;

  /// No description provided for @monday.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get saturday;

  /// No description provided for @deathTimeTitle.
  ///
  /// In en, this message translates to:
  /// **'Death Time'**
  String get deathTimeTitle;

  /// No description provided for @deathTimeQuestion.
  ///
  /// In en, this message translates to:
  /// **'What time do you think you\'ll die?'**
  String get deathTimeQuestion;

  /// No description provided for @midnight.
  ///
  /// In en, this message translates to:
  /// **'Midnight'**
  String get midnight;

  /// No description provided for @threeAM.
  ///
  /// In en, this message translates to:
  /// **'3 AM'**
  String get threeAM;

  /// No description provided for @sixAM.
  ///
  /// In en, this message translates to:
  /// **'6 AM'**
  String get sixAM;

  /// No description provided for @nineAM.
  ///
  /// In en, this message translates to:
  /// **'9 AM'**
  String get nineAM;

  /// No description provided for @noon.
  ///
  /// In en, this message translates to:
  /// **'Noon'**
  String get noon;

  /// No description provided for @threePM.
  ///
  /// In en, this message translates to:
  /// **'3 PM'**
  String get threePM;

  /// No description provided for @sixPM.
  ///
  /// In en, this message translates to:
  /// **'6 PM'**
  String get sixPM;

  /// No description provided for @ninePM.
  ///
  /// In en, this message translates to:
  /// **'9 PM'**
  String get ninePM;

  /// No description provided for @customTime.
  ///
  /// In en, this message translates to:
  /// **'Set Custom Time'**
  String get customTime;

  /// No description provided for @customTimeDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Set Custom Time'**
  String get customTimeDialogTitle;

  /// No description provided for @customTimeDialogHint.
  ///
  /// In en, this message translates to:
  /// **'Please enter time in 24-hour format (HH:MM)'**
  String get customTimeDialogHint;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @invalidTimeFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid time format'**
  String get invalidTimeFormat;

  /// No description provided for @deathDateTimeMessage.
  ///
  /// In en, this message translates to:
  /// **'You have set your death date and time at'**
  String get deathDateTimeMessage;

  /// No description provided for @calculateButtonMessage.
  ///
  /// In en, this message translates to:
  /// **'Please press the calculate button first'**
  String get calculateButtonMessage;

  /// No description provided for @timeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get timeLabel;

  /// No description provided for @nextStepMessage.
  ///
  /// In en, this message translates to:
  /// **'The next page is an estimate of how much time you have left of your life.'**
  String get nextStepMessage;

  /// No description provided for @breatheAndPressMessage.
  ///
  /// In en, this message translates to:
  /// **'Take a deep breath and see your results.'**
  String get breatheAndPressMessage;

  /// No description provided for @viewResults.
  ///
  /// In en, this message translates to:
  /// **'View Results'**
  String get viewResults;

  /// No description provided for @appTitle_1.
  ///
  /// In en, this message translates to:
  /// **'Life Countdown'**
  String get appTitle_1;

  /// No description provided for @timeRemainingTitle.
  ///
  /// In en, this message translates to:
  /// **'You have remaining time'**
  String get timeRemainingTitle;

  /// No description provided for @timeElapsedTitle.
  ///
  /// In en, this message translates to:
  /// **'Passed'**
  String get timeElapsedTitle;

  /// No description provided for @birthTitle.
  ///
  /// In en, this message translates to:
  /// **'Born'**
  String get birthTitle;

  /// No description provided for @deathTitle.
  ///
  /// In en, this message translates to:
  /// **'Death'**
  String get deathTitle;

  /// No description provided for @saveImage.
  ///
  /// In en, this message translates to:
  /// **'Save Image'**
  String get saveImage;

  /// No description provided for @resetButton.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get resetButton;

  /// No description provided for @dayLabel_1.
  ///
  /// In en, this message translates to:
  /// **'day'**
  String get dayLabel_1;

  /// No description provided for @hourLabel.
  ///
  /// In en, this message translates to:
  /// **'hour'**
  String get hourLabel;

  /// No description provided for @minuteLabel.
  ///
  /// In en, this message translates to:
  /// **'minute'**
  String get minuteLabel;

  /// No description provided for @secondLabel.
  ///
  /// In en, this message translates to:
  /// **'second'**
  String get secondLabel;

  /// No description provided for @saveImageButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Save Image'**
  String get saveImageButtonLabel;

  /// No description provided for @closeButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeButtonLabel;

  /// No description provided for @shareTitle.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get shareTitle;

  /// No description provided for @created_by.
  ///
  /// In en, this message translates to:
  /// **'Created by'**
  String get created_by;

  /// No description provided for @sponsored_by.
  ///
  /// In en, this message translates to:
  /// **'Sponsored by'**
  String get sponsored_by;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'th'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'th': return AppLocalizationsTh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
