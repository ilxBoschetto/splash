enum ReportStatus {
  pending(0),
  accepted(1),
  rejected(2);

  final int value;
  const ReportStatus(this.value);
}
