/// The learner's self-assessment when reviewing a due card ("Lặp lại").
///
/// v1 is a binary grade (`docs/business/srs/srs-review.md`, UC-2): the learner
/// marks **Đúng** or **Sai**. No ease-factor grades (SM-2/FSRS) in v1.
enum ReviewGrade {
  /// Đúng — recalled correctly; the scheduler promotes the card (BR-3).
  pass,

  /// Sai — failed to recall; the scheduler demotes the card (BR-4).
  fail;

  bool get isPass => this == ReviewGrade.pass;
  bool get isFail => this == ReviewGrade.fail;
}
