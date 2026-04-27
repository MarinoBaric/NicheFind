class QuestionnaireData {
  List<String> interests;
  String goal;
  String skillLevel;
  String timeCommitment;
  String additionalNotes;

  QuestionnaireData({
    this.interests = const [],
    this.goal = '',
    this.skillLevel = '',
    this.timeCommitment = '',
    this.additionalNotes = '',
  });

  bool get isComplete =>
      interests.isNotEmpty &&
      goal.isNotEmpty &&
      skillLevel.isNotEmpty &&
      timeCommitment.isNotEmpty;

  Map<String, dynamic> toJson() => {
        'interests': interests,
        'goal': goal,
        'skillLevel': skillLevel,
        'timeCommitment': timeCommitment,
        'additionalNotes': additionalNotes,
      };
}
