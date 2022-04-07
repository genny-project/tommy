class AppState {
  AppState(
      {required this.DISPLAY,
      required this.DRAWER,
      required this.DIALOG,
      this.TOAST,
      this.DASHBOARD_COUNTS,
      required this.NOTES,
      required this.DUPLICATE_EMAILS,
      this.lastSentMessage,
      this.lastReceivedMessage,
      required this.highlightedQuestion}) {}
  // [key; String]; String | object | Array<String> | null
  String DISPLAY;
  String DRAWER;
  String DIALOG;
  Map<String, dynamic>? TOAST;
  List<String>? DASHBOARD_COUNTS;
  String NOTES;
  String DUPLICATE_EMAILS;
  dynamic lastSentMessage;
  dynamic lastReceivedMessage;
  String highlightedQuestion;
}
