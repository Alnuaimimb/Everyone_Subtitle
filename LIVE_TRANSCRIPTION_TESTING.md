# Live Transcription Testing Guide

## Overview
This guide helps you test and verify that the live transcription feature is working correctly with word-by-word real-time updates.

## Prerequisites
1. AssemblyAI API key configured
2. Microphone permissions granted
3. Stable internet connection
4. Physical device (recommended over emulator for audio testing)

## Testing Steps

### 1. Basic Setup Test
```bash
# Run with AssemblyAI API key
flutter run --dart-define=ASSEMBLYAI_API_KEY=your_assemblyai_api_key_here
```

### 2. Visual Indicators Test
1. Navigate to Speech to Text screen
2. Look for:
   - "Ready to listen" status in transcript card
   - Microphone icon (inactive state)
   - No live indicator visible

### 3. Live Transcription Test
1. Tap the **play button** (▶️)
2. Verify immediate changes:
   - "Live Transcription Active" indicator appears
   - Status changes to "Listening..."
   - Microphone icon becomes active
   - Border of transcript card highlights

### 4. Word-by-Word Test
1. Start recording (play button)
2. Speak slowly and clearly: "Hello world this is a test"
3. Watch for:
   - Words appearing as you speak
   - Real-time updates in the transcript
   - Word count increasing
   - Status showing "Transcribing..."

### 5. Debug Test (Optional)
1. Use the **Debug Live** button (🧪)
2. This simulates live updates for testing
3. Should see: "Hello" → "Hello world" → "Hello world this" → etc.

## Expected Behavior

### ✅ Working Correctly
- Words appear within 1-2 seconds of speaking
- Partial transcripts show immediately
- Final transcripts confirm when you pause
- Word count updates in real-time
- Status indicators change appropriately

### ❌ Issues to Watch For
- No words appearing after 5+ seconds
- Only final transcript (no partials)
- "Error" messages in status
- Stuck on "Listening..." without updates

## Troubleshooting

### No Live Updates
1. **Check API Key**: Verify AssemblyAI key is correct
2. **Check Permissions**: Ensure microphone access granted
3. **Check Network**: Verify stable internet connection
4. **Check Console**: Look for error messages in debug output

### Only Final Transcript
1. **Check WebSocket**: Look for "WS error" in console
2. **Check Audio Quality**: Speak clearly and reduce background noise
3. **Check Device**: Try on physical device instead of emulator

### Error Messages
- **"Speech-to-text unavailable"**: Missing or invalid API key
- **"Microphone permission denied"**: Grant microphone access
- **"Transcription stream error"**: Network or API issue
- **"No audio captured"**: Speak louder or check microphone

## Debug Output

### Expected Console Messages
```
[AssemblyAI] Starting realtime transcription...
[AssemblyAI] Got token, connecting to WebSocket...
[AssemblyAI] Sent start message
[AssemblyAI] Started microphone stream
[AssemblyAI] Realtime transcription started successfully
[ConversationController] Live transcription started
[AssemblyAI] Received message: type=partial_transcript, text="Hello"
[AssemblyAI] Partial update: "Hello"
[ConversationController] Live transcript update: "Hello"
```

### Error Messages to Watch For
```
[AssemblyAI] Failed to fetch realtime token: 401
[AssemblyAI] WS error: Connection failed
[AssemblyAI] Realtime init failed: TimeoutException
```

## Performance Tips

### For Best Results
- Speak clearly and at normal pace
- Minimize background noise
- Use headphones with microphone
- Ensure stable internet connection
- Close other apps using microphone

### Testing Scenarios
1. **Short phrases**: "Hello world"
2. **Medium sentences**: "This is a test of the live transcription system"
3. **Longer content**: "I am testing the real-time speech-to-text functionality to ensure it works properly with word-by-word updates"

## API Usage Monitoring
- AssemblyAI provides 5 hours free per month
- Real-time streaming uses more resources than file-based
- Monitor usage in AssemblyAI dashboard

## Support
If issues persist:
1. Check AssemblyAI service status
2. Verify API key permissions
3. Test with different network
4. Try on different device
5. Review debug console output
