// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get tabToday => 'Today';

  @override
  String get tabLibrary => 'Library';

  @override
  String get tabStats => 'Stats';

  @override
  String get tabProfile => 'Profile';

  @override
  String get addTooltip => 'Add';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get drawerActivityTitle => 'Today\'s activity';

  @override
  String activityMinutes(int count) {
    return '$count min';
  }

  @override
  String activityWords(int count) {
    return '$count words';
  }

  @override
  String get drawerLanguagesTitle => 'Language pairs';

  @override
  String get drawerLanguagesEmpty => 'Add a language pair to get started';

  @override
  String get drawerAddLanguage => 'Add language';

  @override
  String get drawerRemoveLanguage => 'Remove language';

  @override
  String get drawerImport => 'Import';

  @override
  String get drawerExport => 'Export';

  @override
  String get drawerStatistics => 'Statistics';

  @override
  String get drawerTheme => 'Theme';

  @override
  String get drawerSettings => 'Settings';

  @override
  String get drawerFaq => 'FAQ';

  @override
  String get drawerSendEmail => 'Send email';

  @override
  String get drawerSync => 'Sync (alpha)';

  @override
  String get swapDirectionTooltip => 'Swap display direction';

  @override
  String get addLanguageTitle => 'Add language pair';

  @override
  String get addLanguageLearning => 'Learning language';

  @override
  String get addLanguageNative => 'Native language';

  @override
  String get addLanguageSubmit => 'Add';

  @override
  String get addLanguageErrorSame => 'The two languages must differ';

  @override
  String get addLanguageErrorEmpty => 'Pick both languages';

  @override
  String get removeLanguageTitle => 'Remove language pair';

  @override
  String get removeLanguageEmpty => 'No language pairs yet';

  @override
  String get removeLanguageConfirmTitle => 'Remove this pair?';

  @override
  String get removeLanguageConfirmBody =>
      'All decks and cards in this pair will be deleted.';

  @override
  String get commonBack => 'Back';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonDelete => 'Delete';

  @override
  String get editorTitleNew => 'New card';

  @override
  String get editorTitleEdit => 'Edit card';

  @override
  String get editorSave => 'Save';

  @override
  String get editorTermLabel => 'Term';

  @override
  String get editorTermHint => 'Enter the word…';

  @override
  String get editorMeaningHint => 'Enter meaning, examples, notes…';

  @override
  String get editorAddMeaning => 'Secondary meaning';

  @override
  String get editorMeaningLanguage => 'Meaning language';

  @override
  String get editorGenderLabel => 'Gender';

  @override
  String get genderMasculine => 'Masculine';

  @override
  String get genderFeminine => 'Feminine';

  @override
  String get genderNeuter => 'Neuter';

  @override
  String get editorAudioLabel => 'Audio';

  @override
  String get editorAudioAuto => 'Auto from term';

  @override
  String get audioSpeak => 'Speak';

  @override
  String get editorHiddenLabel => 'Hidden';

  @override
  String get editorHiddenSubtitle =>
      'Excluded from study queues and due counts';

  @override
  String get editorErrorTermRequired => 'Term is required';

  @override
  String get editorErrorMeaningRequired => 'Meaning is required';

  @override
  String editorDuplicateMessage(String term) {
    return 'A card “$term” already exists in this deck';
  }

  @override
  String get editorDuplicateAddAnyway => 'Add anyway';

  @override
  String get editorDuplicateViewExisting => 'View existing';

  @override
  String get editorSaveError => 'Couldn\'t save the card';

  @override
  String get deckNewTitle => 'New deck';

  @override
  String get deckNameLabel => 'Deck name';

  @override
  String get deckNameHint => 'e.g. Travel verbs';

  @override
  String get deckCreate => 'Create';

  @override
  String get deckRename => 'Rename';

  @override
  String get deckMove => 'Move';

  @override
  String get deckMoveToRoot => 'Top level';

  @override
  String get deckMoveTitle => 'Move deck';

  @override
  String get deckDelete => 'Delete deck';

  @override
  String get deckDeleteConfirmTitle => 'Delete this deck?';

  @override
  String get deckDeleteConfirmBody =>
      'This deletes the deck and everything inside it — sub-decks, cards and progress.';

  @override
  String get libraryEmptyTitle => 'Nothing to study yet';

  @override
  String get libraryEmptySubtitle => 'Create a deck to start collecting words.';

  @override
  String get libraryCreateDeck => 'Create deck';

  @override
  String get libraryError => 'Couldn\'t load the library';

  @override
  String get commonRetry => 'Retry';

  @override
  String get sortLabel => 'Sort';

  @override
  String get sortAlphabet => 'Alphabetical';

  @override
  String get sortCreated => 'Date created';

  @override
  String get sortLastStudied => 'Last studied';

  @override
  String get sortAscending => 'Ascending';

  @override
  String get sortDescending => 'Descending';

  @override
  String deckWords(int count) {
    return '$count words';
  }

  @override
  String deckHiddenCount(int count) {
    return '$count hidden';
  }

  @override
  String get deckDetailSubdecks => 'Sub-decks';

  @override
  String get deckDetailCards => 'Cards';

  @override
  String get deckAddWord => 'Add word';

  @override
  String get deckNewSubdeck => 'New sub-deck';

  @override
  String get deckDetailEmpty =>
      'This deck is empty — add a word or a sub-deck.';

  @override
  String get deckNotFound => 'Deck not found';

  @override
  String get cardStatusNew => 'New';

  @override
  String get cardStatusDue => 'Due';

  @override
  String get cardStatusMastered => 'Mastered';

  @override
  String get cardStatusLearning => 'Learning';

  @override
  String get gameTitle => 'A game';

  @override
  String get gameMatching => 'Matching';

  @override
  String get gameMultipleChoice => 'Guess';

  @override
  String get gameRecall => 'Recall';

  @override
  String get gameTyping => 'Fill in';

  @override
  String get gameMatchingDesc => 'Match terms and meanings';

  @override
  String get gameMultipleChoiceDesc => 'Pick the right meaning';

  @override
  String get gameRecallDesc => 'Reveal and self-grade';

  @override
  String get gameTypingDesc => 'Type the term';

  @override
  String get gameScopeLabel => 'Repeat mode';

  @override
  String get gameScopeSpaced => 'Spaced';

  @override
  String get gameScopeAll => 'All';

  @override
  String get gameScopeNotMastered => 'Not mastered';

  @override
  String gameWordsHint(int count) {
    return '$count words per round';
  }

  @override
  String get gameNotEnoughTitle => 'Need more cards to play';

  @override
  String get gameComplete => 'Round complete!';

  @override
  String get gamePlayAgain => 'Play again';

  @override
  String get gameDone => 'Done';

  @override
  String get gameShow => 'Show';

  @override
  String get gameForgot => 'Forgot';

  @override
  String get gameRemembered => 'Remembered';

  @override
  String get gameCheck => 'Check';

  @override
  String get gameHelp => 'Help';

  @override
  String get gameRetry => 'Try again';

  @override
  String get gameAccept => 'Correct';

  @override
  String get gameTypingPlaceholder => 'Type the term…';

  @override
  String gameAnswerWas(String term) {
    return 'Answer: $term';
  }

  @override
  String get gameRelearn => 'You\'ll see this one again';

  @override
  String get studyNewLearn => 'Learn';

  @override
  String studyDueReview(int count) {
    return 'Repeat $count words';
  }

  @override
  String get studyReview => 'Review words';

  @override
  String get studyPlayer => 'Player';

  @override
  String get studyStageReview => 'Review';

  @override
  String get studyExitTitle => 'Exit session?';

  @override
  String get studyExitBody =>
      'Cards that haven\'t finished all 5 stages stay new.';

  @override
  String get studyExitConfirm => 'Exit';

  @override
  String get studyResultTitle => 'Session complete';

  @override
  String studyResultWords(int count) {
    return '$count words';
  }

  @override
  String studyResultAccuracy(int percent) {
    return '$percent% correct';
  }

  @override
  String get studyContinue => 'Continue';

  @override
  String get studyToLibrary => 'To library';

  @override
  String get reviewEnd => 'All reviewed';

  @override
  String get reviewStudyNow => 'Study now';

  @override
  String get playerEnd => 'Playback finished';

  @override
  String get playerReplay => 'Replay';

  @override
  String get commonClose => 'Close';

  @override
  String get dashboardGreeting => 'Hello';

  @override
  String get dashboardTodayLabel => 'TODAY';

  @override
  String get dashboardTimeStudiedLabel => 'time studied';

  @override
  String get dashboardWordsLearned => 'words learned';

  @override
  String get dashboardDayStreak => 'day streak';

  @override
  String get dashboardMasteredLabel => 'mastered';

  @override
  String get dashboardContinueStudying => 'Continue studying';

  @override
  String dashboardDecksDue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count decks due today',
      one: '1 deck due today',
      zero: 'No decks due today',
    );
    return '$_temp0';
  }

  @override
  String deckCardsDue(int cards, int due) {
    return '$cards cards · $due due';
  }

  @override
  String get commonSeeAll => 'See all';

  @override
  String get dashboardTimeStudied => 'Time studied';

  @override
  String get dashboardWords => 'Words';

  @override
  String get dashboardEmptyHint =>
      'No study yet today — start to keep your streak!';

  @override
  String get dashboardGoalTitle => 'Daily goal';

  @override
  String get dashboardGoalHint => 'Reach your minutes OR words';

  @override
  String get dashboardGoalNone => 'Set a daily goal in settings';

  @override
  String get dashboardGoalMet => 'Goal reached today 🎉';

  @override
  String get dashboardStreakTitle => 'Streak';

  @override
  String dashboardStreakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get dashboardStreakNone => 'Start your streak today';

  @override
  String get dashboardContinue => 'Continue learning';

  @override
  String dashboardDueCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cards due',
      one: '1 card due',
      zero: 'No cards due',
    );
    return '$_temp0';
  }

  @override
  String dashboardMastered(int percent) {
    return '$percent% mastered';
  }

  @override
  String get dashboardError => 'Couldn\'t load your dashboard';

  @override
  String get statsScopeCurrentPair => 'This pair';

  @override
  String get statsScopeAllApp => 'All app';

  @override
  String get statsOverviewTitle => 'Library overview';

  @override
  String get statsPairs => 'Pairs';

  @override
  String get statsDecks => 'Decks';

  @override
  String get statsAccuracyTitle => 'Review accuracy';

  @override
  String statsAccuracyDetail(int correct, int total) {
    return '$correct/$total correct';
  }

  @override
  String get statsHeatmapTitle => 'Activity (12 weeks)';

  @override
  String dashboardLongestStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return 'Best: $_temp0';
  }

  @override
  String get statsBoxTitle => 'Leitner boxes';

  @override
  String get statsForecastTitle => 'Due in the next 7 days';

  @override
  String get statsInsufficient => 'Study more to see statistics';

  @override
  String get statsError => 'Couldn\'t load statistics';

  @override
  String statsDayOffset(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+${count}d',
      one: 'Tomorrow',
      zero: 'Today',
    );
    return '$_temp0';
  }

  @override
  String get settingsGroupGame => 'Game';

  @override
  String get settingsWordsPerRound => 'Words per round';

  @override
  String get settingsGameRandom => 'Random selection';

  @override
  String get settingsGroupSrs => 'Spaced repetition';

  @override
  String get settingsBoxCount => 'Leitner boxes';

  @override
  String get settingsNewPerDay => 'New cards per day';

  @override
  String get settingsGroupGoal => 'Daily goal';

  @override
  String get settingsGoalMinutes => 'Goal: minutes';

  @override
  String get settingsGoalWords => 'Goal: words';

  @override
  String get settingsGroupReminder => 'Reminder';

  @override
  String get settingsReminderSummaryOff => 'Off';

  @override
  String get settingsGroupBackup => 'Backup & restore';

  @override
  String get settingsAutoBackup => 'Automatic backup';

  @override
  String get settingsBackupNow => 'Back up now';

  @override
  String get settingsRestore => 'Restore from backup';

  @override
  String get settingsBackupDone => 'Backup saved';

  @override
  String get settingsRestoreDone => 'Data restored';

  @override
  String get settingsBackupError => 'Backup failed';

  @override
  String get settingsSyncTitle => 'Sync with Google Drive';

  @override
  String get settingsSyncSubtitle => 'Multi-device backup (sign-in required)';

  @override
  String get settingsSyncPushed => 'Uploaded to Google Drive';

  @override
  String get settingsSyncPulled => 'Restored from Google Drive';

  @override
  String get settingsSyncSignInRequired => 'Sign in to Google to sync';

  @override
  String get settingsSyncError => 'Sync unavailable';

  @override
  String get settingsNotSet => 'Not set';

  @override
  String get reminderEnable => 'Daily reminder';

  @override
  String get reminderTimeLabel => 'Time';

  @override
  String get reminderComingSoon =>
      'Notifications are coming soon — the schedule is saved.';

  @override
  String get reminderActiveHint =>
      'You\'ll be reminded at the set time on the selected days.';

  @override
  String get reminderNotificationTitle => 'MemoX';

  @override
  String get reminderNotificationBody =>
      'Time to study — keep your streak alive!';

  @override
  String get weekdayMon => 'Mon';

  @override
  String get weekdayTue => 'Tue';

  @override
  String get weekdayWed => 'Wed';

  @override
  String get weekdayThu => 'Thu';

  @override
  String get weekdayFri => 'Fri';

  @override
  String get weekdaySat => 'Sat';

  @override
  String get weekdaySun => 'Sun';

  @override
  String get themeModeLabel => 'Color mode';

  @override
  String get themeModeSystem => 'System';

  @override
  String get themeModeLight => 'Light';

  @override
  String get themeModeDark => 'Dark';

  @override
  String get themeAccentLabel => 'Accent';

  @override
  String get themeAccentBrand => 'Brand';

  @override
  String get themeAccentWarm => 'Warm';

  @override
  String get themeAccentCool => 'Cool';

  @override
  String get themeFontLabel => 'Font size';

  @override
  String get themeFontSmall => 'Small';

  @override
  String get themeFontMedium => 'Medium';

  @override
  String get themeFontLarge => 'Large';

  @override
  String get themePreview => 'Preview';

  @override
  String get themePreviewBody =>
      'Learning a little every day keeps your streak alive.';

  @override
  String get importTitle => 'Import';

  @override
  String get importPickFile => 'Pick file';

  @override
  String get importPaste => 'Paste';

  @override
  String get importSeparator => 'Separator';

  @override
  String get importHasHeader => 'First row is a header';

  @override
  String get importTermColumn => 'Term column';

  @override
  String get importMeaningColumn => 'Meaning column';

  @override
  String get importPreview => 'Preview';

  @override
  String get importRun => 'Import';

  @override
  String importDone(int count, int dup) {
    return 'Imported $count cards ($dup duplicates)';
  }

  @override
  String get exportTitle => 'Export';

  @override
  String get exportScopeSubtree => 'Include sub-decks';

  @override
  String get exportIncludeSrs => 'Include review state';

  @override
  String get exportFormat => 'Format';

  @override
  String get exportRun => 'Export';

  @override
  String get transferError => 'Couldn\'t complete — please try again';

  @override
  String get exportCopied => 'Copied to clipboard';

  @override
  String exportSavedTo(String path) {
    return 'Saved to $path';
  }

  @override
  String get searchHint => 'Search by word or meaning';

  @override
  String get searchRecent => 'Recent';

  @override
  String get searchFilterAll => 'All';

  @override
  String searchNoResults(String query) {
    return 'No cards found for “$query”';
  }
}
