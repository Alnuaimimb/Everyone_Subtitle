import 'package:get/get.dart';
import 'package:everyone_subtitle/Features/quiz/models/quiz_question.dart';
import 'package:everyone_subtitle/utils/constants/quiz_questions.dart';

class QuizController extends GetxController {
  static QuizController get instance => Get.find();

  final RxList<QuizQuestion> questions = <QuizQuestion>[].obs;
  final RxInt currentIndex = 0.obs;
  final RxMap<String, String> answers = <String, String>{}.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    questions.assignAll(QuizQuestions.questions);
  }

  QuizQuestion get currentQuestion => questions[currentIndex.value];

  double get progress => (currentIndex.value + 1) / questions.length;

  bool get canGoNext => answers.containsKey(currentQuestion.id);
  bool get canGoPrevious => currentIndex.value > 0;
  bool get isLastQuestion => currentIndex.value == questions.length - 1;

  void selectAnswer(String answer) {
    answers[currentQuestion.id] = answer;
  }

  String? getSelectedAnswer() {
    return answers[currentQuestion.id];
  }

  void nextQuestion() {
    if (canGoNext && !isLastQuestion) {
      currentIndex.value++;
    }
  }

  void previousQuestion() {
    if (canGoPrevious) {
      currentIndex.value--;
    }
  }

  void skipQuestion() {
    if (!isLastQuestion) {
      currentIndex.value++;
    }
  }

  bool get isComplete => answers.length == questions.length;

  List<Map<String, String>> getAnswersForAI() {
    return questions.map((question) {
      return {
        'question': question.text,
        'answer': answers[question.id] ?? 'Skipped',
      };
    }).toList();
  }

  void reset() {
    currentIndex.value = 0;
    answers.clear();
  }
}
