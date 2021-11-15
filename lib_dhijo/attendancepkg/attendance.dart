class Attendance {

  final String log_text;
  final String date_time;

  Attendance({this.log_text, this.date_time});

  Map<String, dynamic> toMap() {
    return {
      'log_text': log_text,
      'date_time': date_time,
    };
  }
}
