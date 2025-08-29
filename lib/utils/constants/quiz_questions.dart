import 'package:everyone_subtitle/Features/quiz/models/quiz_question.dart';

class QuizQuestions {
  static List<QuizQuestion> questions = [
    // Communication Style
    QuizQuestion(
      id: '1',
      text: 'How do you prefer to communicate with others?',
      type: 'multi',
      options: ['Direct and to the point', 'Warm and friendly', 'Professional and formal', 'Casual and relaxed'],
    ),
    QuizQuestion(
      id: '2',
      text: 'When someone disagrees with you, you tend to:',
      type: 'multi',
      options: ['Listen and find common ground', 'Defend your position strongly', 'Ask questions to understand', 'Avoid conflict'],
    ),
    QuizQuestion(
      id: '3',
      text: 'How often do you use humor in conversations?',
      type: 'likert',
      options: ['Never', 'Rarely', 'Sometimes', 'Often', 'Always'],
    ),
    
    // Empathy & Understanding
    QuizQuestion(
      id: '4',
      text: 'When someone is upset, you usually:',
      type: 'multi',
      options: ['Offer emotional support', 'Try to solve their problem', 'Give them space', 'Share similar experiences'],
    ),
    QuizQuestion(
      id: '5',
      text: 'How important is it to understand others\' perspectives?',
      type: 'likert',
      options: ['Not important', 'Somewhat important', 'Important', 'Very important', 'Extremely important'],
    ),
    QuizQuestion(
      id: '6',
      text: 'When giving feedback, you prefer to:',
      type: 'multi',
      options: ['Be direct and honest', 'Start with positives', 'Ask questions first', 'Write it down'],
    ),
    
    // Assertiveness
    QuizQuestion(
      id: '7',
      text: 'In group discussions, you typically:',
      type: 'multi',
      options: ['Speak up frequently', 'Listen more than speak', 'Take a leadership role', 'Wait for your turn'],
    ),
    QuizQuestion(
      id: '8',
      text: 'How comfortable are you expressing disagreement?',
      type: 'likert',
      options: ['Very uncomfortable', 'Somewhat uncomfortable', 'Neutral', 'Comfortable', 'Very comfortable'],
    ),
    QuizQuestion(
      id: '9',
      text: 'When making decisions, you rely on:',
      type: 'multi',
      options: ['Logic and facts', 'Intuition and feelings', 'Others\' opinions', 'Past experiences'],
    ),
    
    // Social Preferences
    QuizQuestion(
      id: '10',
      text: 'In social situations, you prefer:',
      type: 'multi',
      options: ['Large groups', 'Small groups', 'One-on-one', 'Alone time'],
    ),
    QuizQuestion(
      id: '11',
      text: 'How do you handle small talk?',
      type: 'multi',
      options: ['Enjoy it naturally', 'Find it awkward', 'Use it to connect', 'Keep it brief'],
    ),
    QuizQuestion(
      id: '12',
      text: 'When meeting new people, you:',
      type: 'multi',
      options: ['Ask many questions', 'Share about yourself', 'Observe first', 'Find common interests'],
    ),
    
    // Conflict Resolution
    QuizQuestion(
      id: '13',
      text: 'During conflicts, you usually:',
      type: 'multi',
      options: ['Seek compromise', 'Stand your ground', 'Avoid confrontation', 'Mediate between parties'],
    ),
    QuizQuestion(
      id: '14',
      text: 'How do you prefer to resolve misunderstandings?',
      type: 'multi',
      options: ['Face-to-face conversation', 'Written communication', 'Through a third party', 'Let time resolve it'],
    ),
    QuizQuestion(
      id: '15',
      text: 'When someone is wrong, you:',
      type: 'multi',
      options: ['Correct them directly', 'Let it slide', 'Find a gentle way to mention it', 'Wait for the right moment'],
    ),
    
    // Communication Preferences
    QuizQuestion(
      id: '16',
      text: 'How do you prefer to receive important information?',
      type: 'multi',
      options: ['Verbal explanation', 'Written document', 'Visual presentation', 'Combination of methods'],
    ),
    QuizQuestion(
      id: '17',
      text: 'When explaining complex topics, you:',
      type: 'multi',
      options: ['Use simple language', 'Provide detailed explanations', 'Use analogies', 'Show examples'],
    ),
    QuizQuestion(
      id: '18',
      text: 'How often do you ask for clarification?',
      type: 'likert',
      options: ['Never', 'Rarely', 'Sometimes', 'Often', 'Always'],
    ),
    
    // Emotional Expression
    QuizQuestion(
      id: '19',
      text: 'How do you express emotions?',
      type: 'multi',
      options: ['Openly and directly', 'Privately', 'Through actions', 'Rarely express them'],
    ),
    QuizQuestion(
      id: '20',
      text: 'When you\'re stressed, you prefer others to:',
      type: 'multi',
      options: ['Give you space', 'Offer support', 'Help solve problems', 'Distract you'],
    ),
    QuizQuestion(
      id: '21',
      text: 'How comfortable are you with emotional conversations?',
      type: 'likert',
      options: ['Very uncomfortable', 'Somewhat uncomfortable', 'Neutral', 'Comfortable', 'Very comfortable'],
    ),
    
    // Leadership & Influence
    QuizQuestion(
      id: '22',
      text: 'In team settings, you naturally:',
      type: 'multi',
      options: ['Take charge', 'Support others', 'Contribute ideas', 'Follow directions'],
    ),
    QuizQuestion(
      id: '23',
      text: 'How do you motivate others?',
      type: 'multi',
      options: ['By example', 'Through encouragement', 'By setting goals', 'Through rewards'],
    ),
    QuizQuestion(
      id: '24',
      text: 'When others look to you for guidance, you:',
      type: 'multi',
      options: ['Provide clear direction', 'Help them figure it out', 'Share your experience', 'Ask questions'],
    ),
    
    // Adaptability
    QuizQuestion(
      id: '25',
      text: 'How do you handle change?',
      type: 'multi',
      options: ['Embrace it quickly', 'Need time to adjust', 'Resist initially', 'Analyze the impact'],
    ),
    QuizQuestion(
      id: '26',
      text: 'When plans change unexpectedly, you:',
      type: 'multi',
      options: ['Adapt easily', 'Feel frustrated', 'Create new plans', 'Wait for direction'],
    ),
    QuizQuestion(
      id: '27',
      text: 'How flexible are you with others\' preferences?',
      type: 'likert',
      options: ['Not flexible', 'Somewhat flexible', 'Flexible', 'Very flexible', 'Extremely flexible'],
    ),
    
    // Communication Context
    QuizQuestion(
      id: '28',
      text: 'In professional settings, you prefer:',
      type: 'multi',
      options: ['Formal communication', 'Casual but respectful', 'Direct and efficient', 'Collaborative discussion'],
    ),
    QuizQuestion(
      id: '29',
      text: 'When communicating with authority figures, you:',
      type: 'multi',
      options: ['Show respect and deference', 'Be direct and honest', 'Ask questions', 'Listen carefully'],
    ),
    QuizQuestion(
      id: '30',
      text: 'How do you prefer to end conversations?',
      type: 'multi',
      options: ['Summarize key points', 'End with a positive note', 'Make clear next steps', 'Simply say goodbye'],
    ),
  ];
}
