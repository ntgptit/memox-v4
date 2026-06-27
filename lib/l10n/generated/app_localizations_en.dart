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
}
