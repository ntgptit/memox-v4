// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get tabToday => 'Hôm nay';

  @override
  String get tabLibrary => 'Thư viện';

  @override
  String get tabStats => 'Thống kê';

  @override
  String get tabProfile => 'Cá nhân';

  @override
  String get addTooltip => 'Thêm';

  @override
  String get comingSoon => 'Sắp ra mắt';

  @override
  String get drawerActivityTitle => 'Hoạt động hôm nay';

  @override
  String activityMinutes(int count) {
    return '$count phút';
  }

  @override
  String activityWords(int count) {
    return '$count từ';
  }

  @override
  String get drawerLanguagesTitle => 'Cặp ngôn ngữ';

  @override
  String get drawerLanguagesEmpty => 'Thêm một cặp ngôn ngữ để bắt đầu';

  @override
  String get drawerAddLanguage => 'Thêm ngôn ngữ';

  @override
  String get drawerRemoveLanguage => 'Xóa ngôn ngữ';

  @override
  String get drawerImport => 'Nhập';

  @override
  String get drawerExport => 'Xuất';

  @override
  String get drawerStatistics => 'Thống kê';

  @override
  String get drawerTheme => 'Chủ đề';

  @override
  String get drawerSettings => 'Cài đặt';

  @override
  String get drawerFaq => 'Câu hỏi thường gặp';

  @override
  String get drawerSendEmail => 'Gửi email';

  @override
  String get drawerSync => 'Đồng bộ (alpha)';

  @override
  String get swapDirectionTooltip => 'Đảo chiều hiển thị';

  @override
  String get addLanguageTitle => 'Thêm cặp ngôn ngữ';

  @override
  String get addLanguageLearning => 'Ngôn ngữ đang học';

  @override
  String get addLanguageNative => 'Tiếng mẹ đẻ';

  @override
  String get addLanguageSubmit => 'Thêm';

  @override
  String get addLanguageErrorSame => 'Hai ngôn ngữ phải khác nhau';

  @override
  String get addLanguageErrorEmpty => 'Hãy chọn cả hai ngôn ngữ';

  @override
  String get removeLanguageTitle => 'Xóa cặp ngôn ngữ';

  @override
  String get removeLanguageEmpty => 'Chưa có cặp ngôn ngữ nào';

  @override
  String get removeLanguageConfirmTitle => 'Xóa cặp này?';

  @override
  String get removeLanguageConfirmBody =>
      'Toàn bộ bộ thẻ và thẻ của cặp này sẽ bị xóa.';

  @override
  String get commonBack => 'Quay lại';

  @override
  String get commonCancel => 'Hủy';

  @override
  String get commonDelete => 'Xóa';
}
