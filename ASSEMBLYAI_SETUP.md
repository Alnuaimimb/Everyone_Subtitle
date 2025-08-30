# AssemblyAI Live Transcription Setup

## Overview
The app now features **live transcription** using AssemblyAI's real-time speech-to-text API. As you speak, your words appear in real-time in the transcript card above the speech input screen.

## Features
- **Real-time transcription**: See your words appear as you speak
- **Live status indicators**: Visual feedback showing transcription status
- **Fallback support**: Automatic fallback to file-based transcription if real-time fails
- **Error handling**: Clear error messages for troubleshooting

## Setup Instructions

### 1. Get AssemblyAI API Key
1. Go to [AssemblyAI Platform](https://www.assemblyai.com/)
2. Sign up or log in to your account
3. Navigate to your API Keys section
4. Copy your API key (starts with a long string of characters)

### 2. Configure API Key

Choose one of these methods:

#### Method A: Build-time configuration (Recommended)
```bash
flutter run --dart-define=ASSEMBLYAI_API_KEY=your_assemblyai_api_key_here
```

#### Method B: Environment file
1. Create a `.env` file in `lib/utils/constants/.env`
2. Add: `ASSEMBLYAI_API_KEY=your_assemblyai_api_key_here`
3. The app will automatically load this file

### 3. Test Live Transcription
1. Run the app with your API key configured
2. Navigate to the Speech to Text screen
3. Tap the play button to start recording
4. Speak clearly and watch your words appear in real-time
5. Tap pause to stop recording
6. Use the Generate button to create responses based on your transcript

## How It Works

### Real-time Streaming
- Uses WebSocket connection to AssemblyAI's real-time API
- Audio is streamed in real-time as you speak
- Partial transcripts appear immediately
- Final transcripts are confirmed when you pause

### Visual Indicators
- **Live Transcription Active**: Shows when recording is active
- **Listening...**: Indicates microphone is active
- **Transcribing...**: Shows when processing speech
- **Error messages**: Clear feedback if something goes wrong

### Fallback System
If real-time streaming fails, the app automatically falls back to:
1. File-based audio recording
2. Upload to AssemblyAI
3. Polling for results
4. Display final transcript

## Troubleshooting

### Common Issues

#### "Speech-to-text unavailable"
- **Cause**: Missing or invalid API key
- **Solution**: Check your API key configuration

#### "No audio captured"
- **Cause**: Microphone permission denied or no speech detected
- **Solution**: Grant microphone permission and speak clearly

#### "Transcription stream error"
- **Cause**: Network issues or API problems
- **Solution**: Check internet connection and try again

#### "Transcription timed out"
- **Cause**: Audio processing took too long
- **Solution**: Try shorter speech segments

### Permission Issues
- Ensure microphone permission is granted
- On iOS: Check Settings > Privacy & Security > Microphone
- On Android: Check app permissions in device settings

### Network Issues
- Ensure stable internet connection
- AssemblyAI requires HTTPS connection
- Check firewall settings if using corporate network

## API Usage
- AssemblyAI offers free tier with 5 hours of audio per month
- Real-time transcription uses streaming API
- File-based transcription uses upload + polling API
- Both methods count toward your monthly usage

## Performance Tips
- Speak clearly and at normal pace
- Minimize background noise
- Use headphones with microphone for better quality
- Ensure stable internet connection
- Close other apps using microphone

## File Structure
```
lib/
├── data/
│   └── services/
│       └── ai/
│           └── assemblyai_service.dart  # Main transcription service
├── Features/
│   └── conversation/
│       ├── controllers/
│       │   └── conversation_controller.dart  # Manages transcription state
│       └── screens/
│           └── speech_input_screen.dart  # UI with live transcript display
└── utils/
    └── constants/
        ├── api.dart  # Environment configuration
        └── .env  # API keys (create this file)
```

## Future Enhancements
- Support for multiple languages
- Speaker identification
- Sentiment analysis
- Custom vocabulary
- Offline transcription
- Audio quality optimization
