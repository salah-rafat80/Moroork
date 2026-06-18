/// Represents the possible statuses of a driving licence.
enum LicenseStatus {
  /// الرخصة سارية — licence is active and valid.
  valid,

  /// الرخصة منتهية — licence has expired.
  expired,

  /// الرخصة مسحوبة — licence has been withdrawn.
  withdrawn,

  /// الرخصة موقوفة — licence is suspended.
  suspended,
}
