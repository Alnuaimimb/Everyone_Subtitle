# Personality Quiz Feature Setup

## Overview
The personality quiz feature allows users to take a 30-question assessment that generates a personalized communication profile using ChatGPT. This profile is then used to tailor response suggestions in the conversation feature.

## Features Implemented

### 1. Quiz Flow
- **Quiz Intro Screen**: Explains the purpose and starts the quiz
- **Quiz Question Screen**: Displays questions with progress tracking
- **Quiz Result Screen**: Shows loading while generating profile, then displays results

### 2. User Profile Generation
- 30 comprehensive questions covering communication style, empathy, assertiveness, etc.
- OpenAI GPT-3.5-turbo integration for profile generation
- Profile includes: summary, traits, tone preferences, speaking style

### 3. Integration
- Automatic routing to quiz after signup (if not completed)
- Profile stored in Firestore and local storage
- Response personalization based on user profile
- Settings screen with option to retake quiz

## Setup Instructions

### 1. OpenAI API Key Configuration

You need to set up your OpenAI API key. Choose one of these methods:

#### Method A: Build-time configuration (Recommended)
```bash
flutter run --dart-define=OPENAI_API_KEY=your_openai_api_key_here
```

#### Method B: Environment file
1. Create a `.env` file in the project root
2. Add: `OPENAI_API_KEY=your_openai_api_key_here`
3. Add `flutter_dotenv: ^5.1.0` to pubspec.yaml
4. Update `OpenAIService` to use `dotenv.env['OPENAI_API_KEY']`

### 2. Get OpenAI API Key
1. Go to [OpenAI Platform](https://platform.openai.com/)
2. Sign up or log in
3. Navigate to API Keys section
4. Create a new API key
5. Copy the key (starts with `sk-`)

### 3. Test the Feature
1. Run the app with your API key
2. Sign up as a new user
3. You should be automatically redirected to the quiz
4. Complete the 30 questions
5. Wait for profile generation
6. Test personalized responses in the conversation feature

## File Structure

```
lib/
├── Features/
│   ├── quiz/
│   │   ├── controllers/
│   │   │   └── quiz_controller.dart
│   │   ├── models/
│   │   │   ├── quiz_question.dart
│   │   │   └── user_profile.dart
│   │   └── screens/
│   │       ├── quiz_intro_screen.dart
│   │       ├── quiz_question_screen.dart
│   │       └── quiz_result_screen.dart
│   └── settings/
│       └── screens/
│           └── settings_screen.dart
├── data/
│   └── services/
│       └── ai/
│           └── openai_service.dart
└── utils/
    └── constants/
        └── quiz_questions.dart
```

## Quiz Questions Categories

The 30 questions cover:
- **Communication Style** (3 questions)
- **Empathy & Understanding** (3 questions)
- **Assertiveness** (3 questions)
- **Social Preferences** (3 questions)
- **Conflict Resolution** (3 questions)
- **Communication Preferences** (3 questions)
- **Emotional Expression** (3 questions)
- **Leadership & Influence** (3 questions)
- **Adaptability** (3 questions)
- **Communication Context** (3 questions)

## Response Personalization

The system personalizes responses based on:
- **Speaking Style**: Formal vs casual language
- **Personality Traits**: Empathy, assertiveness, etc.
- **Tone Preferences**: Professional, friendly, direct, etc.

## Error Handling

- Network errors during profile generation
- Invalid API key handling
- Fallback profiles if generation fails
- Option to skip quiz and retake later

## Future Enhancements

- More sophisticated personalization algorithms
- Profile refinement over time
- Multiple language support
- Advanced tone analysis
- Integration with speech-to-text for real-time adaptation
