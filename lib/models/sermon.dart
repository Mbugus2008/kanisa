class Sermon {
  final String? key;
  final String? title;
  final String? preacher;
  final DateTime? date;
  final String? duration;
  final String? thumbnailUrl;

  Sermon({
    this.key,
    this.title,
    this.preacher,
    this.date,
    this.duration,
    this.thumbnailUrl,
  });

  factory Sermon.fromJson(Map<String, dynamic> json) {
    return Sermon(
      key: json['key'],
      title: json['title'],
      preacher: json['preacher'],
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      duration: json['duration'],
      thumbnailUrl: json['thumbnailUrl'],
    );
  }

  Map<String, dynamic> toJson() => {
        'key': key,
        'title': title,
        'preacher': preacher,
        'date': date?.toIso8601String(),
        'duration': duration,
        'thumbnailUrl': thumbnailUrl,
      };
}
