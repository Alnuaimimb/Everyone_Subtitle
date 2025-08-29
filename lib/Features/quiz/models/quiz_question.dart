class QuizQuestion {
  final String id;
  final String text;
  final String type; // 'likert' or 'multi'
  final List<String>? options;

  QuizQuestion({
    required this.id,
    required this.text,
    required this.type,
    this.options,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'],
      text: json['text'],
      type: json['type'],
      options: json['options'] != null ? List<String>.from(json['options']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'type': type,
      'options': options,
    };
  }
}
