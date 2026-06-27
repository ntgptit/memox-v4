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

  /// No description provided for @editorTitleNew.
  ///
  /// In en, this message translates to:
  /// **'New card'**
  String get editorTitleNew;

  /// No description provided for @editorTitleEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit card'**
  String get editorTitleEdit;

  /// No description provided for @editorSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get editorSave;

  /// No description provided for @editorTermLabel.
  ///
  /// In en, this message translates to:
  /// **'Term'**
  String get editorTermLabel;

  /// No description provided for @editorTermHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the word…'**
  String get editorTermHint;

  /// No description provided for @editorMeaningHint.
  ///
  /// In en, this message translates to:
  /// **'Enter meaning, examples, notes…'**
  String get editorMeaningHint;

  /// No description provided for @editorAddMeaning.
  ///
  /// In en, this message translates to:
  /// **'Secondary meaning'**
  String get editorAddMeaning;

  /// No description provided for @editorMeaningLanguage.
  ///
  /// In en, this message translates to:
  /// **'Meaning language'**
  String get editorMeaningLanguage;

  /// No description provided for @editorGenderLabel.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get editorGenderLabel;

  /// No description provided for @genderMasculine.
  ///
  /// In en, this message translates to:
  /// **'Masculine'**
  String get genderMasculine;

  /// No description provided for @genderFeminine.
  ///
  /// In en, this message translates to:
  /// **'Feminine'**
  String get genderFeminine;

  /// No description provided for @genderNeuter.
  ///
  /// In en, this message translates to:
  /// **'Neuter'**
  String get genderNeuter;

  /// No description provided for @editorAudioLabel.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get editorAudioLabel;

  /// No description provided for @editorAudioAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto from term'**
  String get editorAudioAuto;

  /// No description provided for @editorHiddenLabel.
  ///
  /// In en, this message translates to:
  /// **'Hidden'**
  String get editorHiddenLabel;

  /// No description provided for @editorHiddenSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Excluded from study queues and due counts'**
  String get editorHiddenSubtitle;

  /// No description provided for @editorErrorTermRequired.
  ///
  /// In en, this message translates to:
  /// **'Term is required'**
  String get editorErrorTermRequired;

  /// No description provided for @editorErrorMeaningRequired.
  ///
  /// In en, this message translates to:
  /// **'Meaning is required'**
  String get editorErrorMeaningRequired;

  /// No description provided for @editorDuplicateMessage.
  ///
  /// In en, this message translates to:
  /// **'A card “{term}” already exists in this deck'**
  String editorDuplicateMessage(String term);

  /// No description provided for @editorDuplicateAddAnyway.
  ///
  /// In en, this message translates to:
  /// **'Add anyway'**
  String get editorDuplicateAddAnyway;

  /// No description provided for @editorDuplicateViewExisting.
  ///
  /// In en, this message translates to:
  /// **'View existing'**
  String get editorDuplicateViewExisting;

  /// No description provided for @editorSaveError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save the card'**
  String get editorSaveError;

  /// No description provided for @deckNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New deck'**
  String get deckNewTitle;

  /// No description provided for @deckNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Deck name'**
  String get deckNameLabel;

  /// No description provided for @deckNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Travel verbs'**
  String get deckNameHint;

  /// No description provided for @deckCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get deckCreate;

  /// No description provided for @deckRename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get deckRename;

  /// No description provided for @deckMove.
  ///
  /// In en, this message translates to:
  /// **'Move'**
  String get deckMove;

  /// No description provided for @deckMoveToRoot.
  ///
  /// In en, this message translates to:
  /// **'Top level'**
  String get deckMoveToRoot;

  /// No description provided for @deckMoveTitle.
  ///
  /// In en, this message translates to:
  /// **'Move deck'**
  String get deckMoveTitle;

  /// No description provided for @deckDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete deck'**
  String get deckDelete;

  /// No description provided for @deckDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this deck?'**
  String get deckDeleteConfirmTitle;

  /// No description provided for @deckDeleteConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This deletes the deck and everything inside it — sub-decks, cards and progress.'**
  String get deckDeleteConfirmBody;

  /// No description provided for @libraryEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing to study yet'**
  String get libraryEmptyTitle;

  /// No description provided for @libraryEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create a deck to start collecting words.'**
  String get libraryEmptySubtitle;

  /// No description provided for @libraryCreateDeck.
  ///
  /// In en, this message translates to:
  /// **'Create deck'**
  String get libraryCreateDeck;

  /// No description provided for @libraryError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the library'**
  String get libraryError;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @sortLabel.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sortLabel;

  /// No description provided for @sortAlphabet.
  ///
  /// In en, this message translates to:
  /// **'Alphabetical'**
  String get sortAlphabet;

  /// No description provided for @sortCreated.
  ///
  /// In en, this message translates to:
  /// **'Date created'**
  String get sortCreated;

  /// No description provided for @sortLastStudied.
  ///
  /// In en, this message translates to:
  /// **'Last studied'**
  String get sortLastStudied;

  /// No description provided for @sortAscending.
  ///
  /// In en, this message translates to:
  /// **'Ascending'**
  String get sortAscending;

  /// No description provided for @sortDescending.
  ///
  /// In en, this message translates to:
  /// **'Descending'**
  String get sortDescending;

  /// No description provided for @deckWords.
  ///
  /// In en, this message translates to:
  /// **'{count} words'**
  String deckWords(int count);

  /// No description provided for @deckHiddenCount.
  ///
  /// In en, this message translates to:
  /// **'{count} hidden'**
  String deckHiddenCount(int count);

  /// No description provided for @deckDetailSubdecks.
  ///
  /// In en, this message translates to:
  /// **'Sub-decks'**
  String get deckDetailSubdecks;

  /// No description provided for @deckDetailCards.
  ///
  /// In en, this message translates to:
  /// **'Cards'**
  String get deckDetailCards;

  /// No description provided for @deckAddWord.
  ///
  /// In en, this message translates to:
  /// **'Add word'**
  String get deckAddWord;

  /// No description provided for @deckNewSubdeck.
  ///
  /// In en, this message translates to:
  /// **'New sub-deck'**
  String get deckNewSubdeck;

  /// No description provided for @deckDetailEmpty.
  ///
  /// In en, this message translates to:
  /// **'This deck is empty — add a word or a sub-deck.'**
  String get deckDetailEmpty;

  /// No description provided for @deckNotFound.
  ///
  /// In en, this message translates to:
  /// **'Deck not found'**
  String get deckNotFound;

  /// No description provided for @cardStatusNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get cardStatusNew;

  /// No description provided for @cardStatusDue.
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get cardStatusDue;

  /// No description provided for @cardStatusMastered.
  ///
  /// In en, this message translates to:
  /// **'Mastered'**
  String get cardStatusMastered;

  /// No description provided for @cardStatusLearning.
  ///
  /// In en, this message translates to:
  /// **'Learning'**
  String get cardStatusLearning;

  /// No description provided for @gameTitle.
  ///
  /// In en, this message translates to:
  /// **'A game'**
  String get gameTitle;

  /// No description provided for @gameMatching.
  ///
  /// In en, this message translates to:
  /// **'Matching'**
  String get gameMatching;

  /// No description provided for @gameMultipleChoice.
  ///
  /// In en, this message translates to:
  /// **'Guess'**
  String get gameMultipleChoice;

  /// No description provided for @gameRecall.
  ///
  /// In en, this message translates to:
  /// **'Recall'**
  String get gameRecall;

  /// No description provided for @gameTyping.
  ///
  /// In en, this message translates to:
  /// **'Fill in'**
  String get gameTyping;

  /// No description provided for @gameMatchingDesc.
  ///
  /// In en, this message translates to:
  /// **'Match terms and meanings'**
  String get gameMatchingDesc;

  /// No description provided for @gameMultipleChoiceDesc.
  ///
  /// In en, this message translates to:
  /// **'Pick the right meaning'**
  String get gameMultipleChoiceDesc;

  /// No description provided for @gameRecallDesc.
  ///
  /// In en, this message translates to:
  /// **'Reveal and self-grade'**
  String get gameRecallDesc;

  /// No description provided for @gameTypingDesc.
  ///
  /// In en, this message translates to:
  /// **'Type the term'**
  String get gameTypingDesc;

  /// No description provided for @gameScopeLabel.
  ///
  /// In en, this message translates to:
  /// **'Repeat mode'**
  String get gameScopeLabel;

  /// No description provided for @gameScopeSpaced.
  ///
  /// In en, this message translates to:
  /// **'Spaced'**
  String get gameScopeSpaced;

  /// No description provided for @gameScopeAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get gameScopeAll;

  /// No description provided for @gameScopeNotMastered.
  ///
  /// In en, this message translates to:
  /// **'Not mastered'**
  String get gameScopeNotMastered;

  /// No description provided for @gameWordsHint.
  ///
  /// In en, this message translates to:
  /// **'{count} words per round'**
  String gameWordsHint(int count);

  /// No description provided for @gameNotEnoughTitle.
  ///
  /// In en, this message translates to:
  /// **'Need more cards to play'**
  String get gameNotEnoughTitle;

  /// No description provided for @gameComplete.
  ///
  /// In en, this message translates to:
  /// **'Round complete!'**
  String get gameComplete;

  /// No description provided for @gamePlayAgain.
  ///
  /// In en, this message translates to:
  /// **'Play again'**
  String get gamePlayAgain;

  /// No description provided for @gameDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get gameDone;

  /// No description provided for @gameShow.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get gameShow;

  /// No description provided for @gameForgot.
  ///
  /// In en, this message translates to:
  /// **'Forgot'**
  String get gameForgot;

  /// No description provided for @gameRemembered.
  ///
  /// In en, this message translates to:
  /// **'Remembered'**
  String get gameRemembered;

  /// No description provided for @gameCheck.
  ///
  /// In en, this message translates to:
  /// **'Check'**
  String get gameCheck;

  /// No description provided for @gameHelp.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get gameHelp;

  /// No description provided for @gameRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get gameRetry;

  /// No description provided for @gameAccept.
  ///
  /// In en, this message translates to:
  /// **'Correct'**
  String get gameAccept;

  /// No description provided for @gameTypingPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Type the term…'**
  String get gameTypingPlaceholder;

  /// No description provided for @gameAnswerWas.
  ///
  /// In en, this message translates to:
  /// **'Answer: {term}'**
  String gameAnswerWas(String term);

  /// No description provided for @gameRelearn.
  ///
  /// In en, this message translates to:
  /// **'You\'ll see this one again'**
  String get gameRelearn;
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
