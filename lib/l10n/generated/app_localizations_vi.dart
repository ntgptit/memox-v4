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

  @override
  String get deckNewTitle => 'Bộ thẻ mới';

  @override
  String get deckNameLabel => 'Tên bộ thẻ';

  @override
  String get deckNameHint => 'vd Động từ du lịch';

  @override
  String get deckCreate => 'Tạo';

  @override
  String get deckRename => 'Đổi tên';

  @override
  String get deckMove => 'Di chuyển';

  @override
  String get deckMoveToRoot => 'Ra gốc';

  @override
  String get deckMoveTitle => 'Di chuyển bộ thẻ';

  @override
  String get deckDelete => 'Xóa bộ thẻ';

  @override
  String get deckDeleteConfirmTitle => 'Xóa bộ thẻ này?';

  @override
  String get deckDeleteConfirmBody =>
      'Xóa bộ thẻ này và toàn bộ nội dung bên trong — bộ thẻ con, thẻ và tiến độ.';

  @override
  String get libraryEmptyTitle => 'Chưa có gì để học';

  @override
  String get libraryEmptySubtitle => 'Tạo một bộ thẻ để bắt đầu gom từ.';

  @override
  String get libraryCreateDeck => 'Tạo bộ thẻ';

  @override
  String get libraryError => 'Không tải được thư viện';

  @override
  String get commonRetry => 'Thử lại';

  @override
  String get sortLabel => 'Sắp xếp';

  @override
  String get sortAlphabet => 'Bảng chữ cái';

  @override
  String get sortCreated => 'Ngày tạo';

  @override
  String get sortLastStudied => 'Ngày học';

  @override
  String get sortAscending => 'Tăng dần';

  @override
  String get sortDescending => 'Giảm dần';

  @override
  String deckWords(int count) {
    return '$count từ';
  }

  @override
  String deckHiddenCount(int count) {
    return '$count ẩn';
  }

  @override
  String get deckDetailSubdecks => 'Bộ thẻ con';

  @override
  String get deckDetailCards => 'Thẻ';

  @override
  String get deckAddWord => 'Thêm từ';

  @override
  String get deckNewSubdeck => 'Bộ thẻ con mới';

  @override
  String get deckDetailEmpty =>
      'Bộ thẻ trống — thêm một từ hoặc một bộ thẻ con.';

  @override
  String get deckNotFound => 'Không tìm thấy bộ thẻ';

  @override
  String get cardStatusNew => 'Mới';

  @override
  String get cardStatusDue => 'Đến hạn';

  @override
  String get cardStatusMastered => 'Đã thuộc';

  @override
  String get cardStatusLearning => 'Đang học';

  @override
  String get gameTitle => 'Một trò chơi';

  @override
  String get gameMatching => 'Ghép đôi';

  @override
  String get gameMultipleChoice => 'Đoán';

  @override
  String get gameRecall => 'Nhớ lại';

  @override
  String get gameTyping => 'Điền';

  @override
  String get gameMatchingDesc => 'Ghép term với nghĩa';

  @override
  String get gameMultipleChoiceDesc => 'Chọn nghĩa đúng';

  @override
  String get gameRecallDesc => 'Lộ nghĩa rồi tự chấm';

  @override
  String get gameTypingDesc => 'Gõ lại term';

  @override
  String get gameScopeLabel => 'Chế độ lặp lại giãn cách';

  @override
  String get gameScopeSpaced => 'Theo giãn cách';

  @override
  String get gameScopeAll => 'Tất cả';

  @override
  String get gameScopeNotMastered => 'Chỉ thẻ chưa thuộc';

  @override
  String gameWordsHint(int count) {
    return '$count từ mỗi ván';
  }

  @override
  String get gameNotEnoughTitle => 'Cần thêm thẻ để chơi';

  @override
  String get gameComplete => 'Hoàn thành ván!';

  @override
  String get gamePlayAgain => 'Chơi lại';

  @override
  String get gameDone => 'Xong';

  @override
  String get gameShow => 'Hiển thị';

  @override
  String get gameForgot => 'Đã quên';

  @override
  String get gameRemembered => 'Nhớ được';

  @override
  String get gameCheck => 'Kiểm tra';

  @override
  String get gameHelp => 'Trợ giúp';

  @override
  String get gameRetry => 'Thử lại';

  @override
  String get gameAccept => 'Đúng';

  @override
  String get gameTypingPlaceholder => 'Gõ lại term…';

  @override
  String gameAnswerWas(String term) {
    return 'Đáp án: $term';
  }

  @override
  String get gameRelearn => 'Sẽ học lại từ này';

  @override
  String get studyNewLearn => 'Học';

  @override
  String studyDueReview(int count) {
    return 'Lặp lại $count từ';
  }

  @override
  String get studyReview => 'Xem lại các từ';

  @override
  String get studyPlayer => 'Trình phát';

  @override
  String get studyStageReview => 'Xem lại';

  @override
  String get studyExitTitle => 'Thoát phiên?';

  @override
  String get studyExitBody => 'Thẻ chưa hoàn thành 5 chặng sẽ vẫn là Mới.';

  @override
  String get studyExitConfirm => 'Thoát';

  @override
  String get studyResultTitle => 'Hoàn thành phiên';

  @override
  String studyResultWords(int count) {
    return '$count từ';
  }

  @override
  String studyResultAccuracy(int percent) {
    return '$percent% đúng';
  }

  @override
  String get studyContinue => 'Tiếp tục';

  @override
  String get studyToLibrary => 'Về thư viện';

  @override
  String get reviewEnd => 'Đã xem hết';

  @override
  String get reviewStudyNow => 'Học ngay';

  @override
  String get playerEnd => 'Đã phát hết';

  @override
  String get playerReplay => 'Phát lại';

  @override
  String get commonClose => 'Đóng';

  @override
  String get dashboardGreeting => 'Xin chào';

  @override
  String get dashboardTimeStudied => 'Thời gian học';

  @override
  String get dashboardWords => 'Số từ';

  @override
  String get dashboardEmptyHint => 'Hôm nay chưa học — bắt đầu để giữ streak!';

  @override
  String get dashboardGoalTitle => 'Mục tiêu ngày';

  @override
  String get dashboardGoalHint => 'Đạt khi hoàn thành số phút HOẶC số từ';

  @override
  String get dashboardGoalNone => 'Đặt mục tiêu ngày trong cài đặt';

  @override
  String get dashboardGoalMet => 'Đã đạt mục tiêu hôm nay 🎉';

  @override
  String get dashboardStreakTitle => 'Chuỗi ngày';

  @override
  String dashboardStreakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ngày',
    );
    return '$_temp0';
  }

  @override
  String get dashboardStreakNone => 'Bắt đầu chuỗi hôm nay';

  @override
  String get dashboardContinue => 'Tiếp tục học';

  @override
  String dashboardDueCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count thẻ đến hạn',
      zero: 'Không có thẻ đến hạn',
    );
    return '$_temp0';
  }

  @override
  String dashboardMastered(int percent) {
    return 'Đã thuộc $percent%';
  }

  @override
  String get dashboardError => 'Không tải được bảng hôm nay';

  @override
  String get statsScopeCurrentPair => 'Cặp này';

  @override
  String get statsScopeAllApp => 'Toàn app';

  @override
  String get statsOverviewTitle => 'Tổng quan thư viện';

  @override
  String get statsPairs => 'Cặp';

  @override
  String get statsDecks => 'Bộ thẻ';

  @override
  String get statsBoxTitle => 'Phân bố ô Leitner';

  @override
  String get statsForecastTitle => 'Đến hạn trong 7 ngày tới';

  @override
  String get statsActivityTitle => 'Hoạt động (14 ngày)';

  @override
  String get statsInsufficient => 'Học thêm để xem thống kê';

  @override
  String get statsError => 'Không tải được thống kê';

  @override
  String statsDayOffset(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$count ngày',
      one: 'Ngày mai',
      zero: 'Hôm nay',
    );
    return '$_temp0';
  }

  @override
  String get searchHint => 'Tìm theo từ hoặc nghĩa';

  @override
  String get searchRecent => 'Tìm gần đây';

  @override
  String get searchFilterAll => 'Tất cả';

  @override
  String searchNoResults(String query) {
    return 'Không tìm thấy thẻ nào cho ‘$query’';
  }
}
