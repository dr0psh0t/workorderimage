class Utils {
  static String correctSuccess(String jsonStr) {
    int start = jsonStr.indexOf('success');
    int end = jsonStr.lastIndexOf('s:')+1;
    String correctJson;

    correctJson = jsonStr.substring(0, start) + '"'
        + jsonStr.substring(start, end) + '"'
        + jsonStr.substring(end, jsonStr.length);
    return correctJson;
  }

  static String correctReason(String jsonStr) {
    int start = jsonStr.indexOf('reason');
    int end = jsonStr.lastIndexOf('n:')+1;
    String correctJson;

    correctJson = jsonStr.substring(0, start) + '"'
        + jsonStr.substring(start, end) + '"'
        + jsonStr.substring(end, jsonStr.length);
    return correctJson;
  }
}