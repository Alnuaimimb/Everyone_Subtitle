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
       (I am going to how go watch youtube )  
       
 
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

## --------------  Code detail  ---------------- #
                                                                                      
    1️ you can find a good explination of the code here
      'https://www.youtube.com/watch?v=QDhaK7L09qI&list=PL5jb9EteFAOAusKTSuJ5eRl1BapQmMDT6&index=3'
                            
                                                                                                 
    2️ basicly there is the lib folder where your code will be and there is the utils folder which contain some 
      styling and all the text that the app will have so when we need to change it we change it from one place 
      Also inside the utils you will find some helperfunctions 

    3 there is the assets I think the name say it all and there is pubsec.yamal which will contaim all the 
      dependencies splash.yamal is the place where we will add the splash screen 
 
    4 you don't need to know the reset unliss you want to add some device specific feature such as camera
      location ect and if you get any problem with the code just tell me it will most likely be due to the  
      android build.gradle 

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
 
    

