now we are on verdsion 2.0

# Everyone Subtitle - Live Transcription App

## Features
- **Live Speech-to-Text**: Real-time transcription using AssemblyAI
- **Personalized Responses**: AI-generated responses based on your communication style
- **Personality Quiz**: Customized communication profile
- **Voice Output**: Text-to-speech for generated responses

## --------------  INITIALIZATION  ---------------- #
                                                                
     1️ Initialize Packages:                                                                       
       write the following in your terminal: `flutter pub get`.                                 
                                                                                                  
     2️ plug a physical device or download an emulator using android studio 
       
 
     3 run main.dart usin `flutter run` or VS code runner make sure to use
        the emulator or the physcial device before running the code

## --------------  API Setup  ---------------- #

### AssemblyAI Setup (Required for Live Transcription)
1. Get your API key from [AssemblyAI Platform](https://www.assemblyai.com/)
2. Run the app with your API key:
   ```bash
   flutter run --dart-define=ASSEMBLYAI_API_KEY=your_assemblyai_api_key_here
   ```

### OpenAI Setup (Required for Response Generation)
1. Get your API key from [OpenAI Platform](https://platform.openai.com/)
2. Run the app with your API key:
   ```bash
   flutter run --dart-define=OPENAI_API_KEY=your_openai_api_key_here
   ```

### Combined Setup
```bash
flutter run --dart-define=ASSEMBLYAI_API_KEY=your_assemblyai_key --dart-define=OPENAI_API_KEY=your_openai_key
```
### Firebase is 

## --------------  Code detail  ---------------- #
                                                                                      
    1️ you can find a good explination of the code here
      'https://www.youtube.com/watch?v=QDhaK7L09qI&list=PL5jb9EteFAOAusKTSuJ5eRl1BapQmMDT6&index=3'
                            
                                                                                                 
    2️ - **`models/`**: User and authentication data models

    #### `conversation
    - **Purpose**: Chat/conversation functionality
    - **Structure**: Screens, controllers, and models for conversation features
    
    #### `quiz
    - **Purpose**: Quiz/assessment functionality
    - **Structure**: Quiz screens, controllers, and question models
    
    #### `settings
    - **Purpose**: App settings and configuration
    - **Structure**: Settings screens and controllers
    
    #### `voice
    - **Purpose**: Voice-related features (likely voice-to-text or text-to-speech)
    - **Structure**: Voice processing screens, controllers, models, and widgets
    
    ### `utils - Centralized Configuration & Helper Functions
    The `utils` folder is the **central hub** for all app-wide configurations, styling, text content, and helper functions. This centralized approach ensures consistency and makes maintenance easier - when you need to change something, you only change it in one place.
    
    #### 🎨 **Styling & Theme 
    - **`theme.dart`**: Main theme configuration with Material 3 design
    - **`widget_themes/`**: Individual widget theme definitions (buttons, text fields, app bars, etc.)
    - **Centralized Styling**: All colors, fonts, and visual styles are defined here and used throughout the app
    - **Easy Customization**: Change the entire app's look by modifying these theme files
    
    #### **Text Content 
    - : Every piece of text displayed in the app is stored here as constants
    - **Easy Localization**: When you need to change text or add new languages, you only modify this file
    - **Examples**: Button labels, error messages, onboarding text, form labels, etc.
    - **Benefits**: 
      - No hardcoded strings scattered throughout the code
      - Consistent terminology across the app
      - Easy to update text without touching UI code
    
    #### **Helper Functions 
    - **`helper_functions.dart`**: General utility functions used across the app
      - Color conversion utilities
      - SnackBar and Alert dialogs
      - Navigation helpers
      - Text formatting (truncation, date formatting)
      - Screen size utilities
      - Dark mode detection
    - **`network_manager.dart`**: Network connectivity and API helpers
    - **`pricing_calculator.dart`**: Business logic for pricing calculations
    - **`cloud_helper_functions.dart`**: Cloud storage and file management utilities
    
    #### 🔧 **Other Utility Categories
    - **`constants/`**: All app constants (API endpoints, colors, sizes, enums)
    - **`device/`**: Platform-specific utilities and device detection
    - **`exceptions/`**: Custom error handling classes
    - **`formatters/`**: Data formatting utilities (dates, numbers, currency)
    - **`http/`**: Network request configurations
    - **`loaders/`**: Loading animations and states
    - **`local_storage/`**: Local data persistence helpers
    - **`logging/`**: Debug and error logging utilities
    - **`popups/`**: Reusable dialog and popup components
    - **`validators/`**: Form validation rules and utilities

    3 there is the assets I think the name say it all and there is pubsec.yamal which will contaim all the 
      dependencies splash.yamal is the place where we will add the splash screen 
 
    4 The other files and folders in the project aren't really necessary to understand 
    unless you're doing platform-specific development or adding new assets. The main code you'll work with is in the lib/ folder.

## --------------  Live Transcription  ---------------- #

### How to Use Live Transcription
1. Start the app with your AssemblyAI API key
2. Navigate to the Speech to Text screen
3. Tap the play button to start recording
4. Speak clearly and watch your words appear in real-time
5. Tap pause to stop recording
6. Use the Generate button to create AI responses

### Features
- **Real-time Display**: See your words appear as you speak
- **Live Status Indicators**: Visual feedback during transcription
- **Error Handling**: Clear messages if something goes wrong
- **Fallback Support**: Automatic fallback if real-time fails

For detailed setup instructions, see `ASSEMBLYAI_SETUP.md`
 
    

