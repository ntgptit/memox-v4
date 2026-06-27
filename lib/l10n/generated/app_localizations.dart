import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('vi'),
  ];

  /// No description provided for @tabToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get tabToday;

  /// No description provided for @tabLibrary.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get tabLibrary;

  /// No description provided for @tabStats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get tabStats;

  /// No description provided for @tabProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get tabProfile;

  /// No description provided for @addTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addTooltip;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @drawerActivityTitle.
  ///
  /// In en, this message translates to:
  /// **'Today\'s activity'**
  String get drawerActivityTitle;

  /// No description provided for @activityMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count} min'**
  String activityMinutes(int count);

  /// No description provided for @activityWords.
  ///
  /// In en, this message translates to:
  /// **'{count} words'**
  String activityWords(int count);

  /// No description provided for @drawerLanguagesTitle.
  ///
  /// In en, this message translates to:
  /// **'Language pairs'**
  String get drawerLanguagesTitle;

  /// No description provided for @drawerLanguagesEmpty.
  ///
  /// In en, this message translates to:
  /// **'Add a language pair to get started'**
  String get drawerLanguagesEmpty;

  /// No description provided for @drawerAddLanguage.
  ///
  /// In en, this message translates to:
  /// **'Add language'**
  String get drawerAddLanguage;

  /// No description provided for @drawerRemoveLanguage.
  ///
  /// In en, this message translates to:
  /// **'Remove language'**
  String get drawerRemoveLanguage;

  /// No description provided for @drawerImport.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get drawerImport;

  /// No description provided for @drawerExport.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get drawerExport;

  /// No description provided for @drawerStatistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get drawerStatistics;

  /// No description provided for @drawerTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get drawerTheme;

  /// No description provided for @drawerSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get drawerSettings;

  /// No description provided for @drawerFaq.
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get drawerFaq;

  /// No description provided for @drawerSendEmail.
  ///
  /// In en, this message translates to:
  /// **'Send email'**
  String get drawerSendEmail;

  /// No description provided for @drawerSync.
  ///
  /// In en, this message translates to:
  /// **'Sync (alpha)'**
  String get drawerSync;

  /// No description provided for @swapDirectionTooltip.
  ///
  /// In en, this message translates to:
  /// **'Swap display direction'**
  String get swapDirectionTooltip;

  /// No description provided for @addLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Add language pair'**
  String get addLanguageTitle;

  /// No description provided for @addLanguageLearning.
  ///
  /// In en, this message translates to:
  /// **'Learning language'**
  String get addLanguageLearning;

  /// No description provided for @addLanguageNative.
  ///
  /// In en, this message translates to:
  /// **'Native language'**
  String get addLanguageNative;

  /// No description provided for @addLanguageSubmit.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addLanguageSubmit;

  /// No description provided for @addLanguageErrorSame.
  ///
  /// In en, this message translates to:
  /// **'The two languages must differ'**
  String get addLanguageErrorSame;

  /// No description provided for @addLanguageErrorEmpty.
  ///
  /// In en, this message translates to:
  /// **'Pick both languages'**
  String get addLanguageErrorEmpty;

  /// No description provided for @removeLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove language pair'**
  String get removeLanguageTitle;

  /// No description provided for @removeLanguageEmpty.
  ///
  /// In en, this message translates to:
  /// **'No language pairs yet'**
  String get removeLanguageEmpty;

  /// No description provided for @removeLanguageConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove this pair?'**
  String get removeLanguageConfirmTitle;

  /// No description provided for @removeLanguageConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'All decks and cards in this pair will be deleted.'**
  String get removeLanguageConfirmBody;

  /// No description provided for @commonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;
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
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
