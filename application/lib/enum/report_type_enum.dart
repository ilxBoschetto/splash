enum ReportType {
  wrongInformation(0, "report.wrong_information"),
  wrongImage(1, "report.wrong_image"),
  wrongPotability(2, "report.wrong_potability"),
  nonExistentFontanella(3, "report.non_existent_fontanella");

  final int value;
  final String translationKey;

  const ReportType(this.value, this.translationKey);
}
