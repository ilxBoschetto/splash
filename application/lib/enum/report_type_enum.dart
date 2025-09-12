enum ReportType {
  wrongInformation(0),
  wrongImage(1),
  wrongPotability(2),
  nonExistentFontanella(3);

  final int value;
  const ReportType(this.value);
}
