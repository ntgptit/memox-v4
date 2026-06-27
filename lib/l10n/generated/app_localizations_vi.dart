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

  @override
  String get editorTitleNew => 'Thẻ mới';

  @override
  String get editorTitleEdit => 'Sửa thẻ';

  @override
  String get editorSave => 'Lưu';

  @override
  String get editorTermLabel => 'Từ';

  @override
  String get editorTermHint => 'Nhập từ…';

  @override
  String get editorMeaningHint => 'Nhập nghĩa, có thể kèm ví dụ/ghi chú…';

  @override
  String get editorAddMeaning => 'Nghĩa ngôn ngữ phụ';

  @override
  String get editorMeaningLanguage => 'Ngôn ngữ của nghĩa';

  @override
  String get editorGenderLabel => 'Giới tính';

  @override
  String get genderMasculine => 'Giống đực';

  @override
  String get genderFeminine => 'Giống cái';

  @override
  String get genderNeuter => 'Trung tính';

  @override
  String get editorAudioLabel => 'Âm thanh';

  @override
  String get editorAudioAuto => 'Tự sinh từ term';

  @override
  String get editorHiddenLabel => 'Ẩn';

  @override
  String get editorHiddenSubtitle => 'Loại khỏi hàng đợi học và số đến hạn';

  @override
  String get editorErrorTermRequired => 'Bắt buộc nhập term';

  @override
  String get editorErrorMeaningRequired => 'Bắt buộc nhập nghĩa';

  @override
  String editorDuplicateMessage(String term) {
    return 'Đã có thẻ “$term” trong bộ thẻ này';
  }

  @override
  String get editorDuplicateAddAnyway => 'Vẫn thêm';

  @override
  String get editorDuplicateViewExisting => 'Xem thẻ đã có';

  @override
  String get editorSaveError => 'Không lưu được thẻ';
}
