class ResumeVideoModel {
  String? postId;
  String? watchedTime;
  String? watchedTotalTime;
  String? watchedTimePercentage;

  ResumeVideoModel({this.postId, this.watchedTime, this.watchedTimePercentage, this.watchedTotalTime});

  factory ResumeVideoModel.fromJson(Map<String, dynamic> json) {
    return ResumeVideoModel(
      postId: json['post_id'],
      watchedTime: json['watched_time'],
      watchedTimePercentage: json['watched_time_percentage'],
      watchedTotalTime: json['watched_total_time'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'post_id': this.postId,
      'watched_time': this.watchedTime,
      'watched_time_percentage': this.watchedTimePercentage,
      'watched_total_time': this.watchedTotalTime,
    };
  }
}
