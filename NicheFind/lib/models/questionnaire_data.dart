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

  bool get isComplete {
    // TODO: Validate that all required fields are filled
    throw UnimplementedError();
  }

  Map<String, dynamic> toJson() {
    // TODO: Serialize questionnaire data for prompt building
    throw UnimplementedError();
  }
}
