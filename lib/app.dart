import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:everyone_subtitle/Features/conversation/screens/speech_input_screen.dart';
import 'package:everyone_subtitle/bindings/general_bindings.dart';
import 'package:everyone_subtitle/utils/theme/theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'everyone-subtitle',
      themeMode: ThemeMode.light,
      theme: TAppTheme.lightTheme,
      initialBinding: GeneralBindings(),
      home: const SpeechInputScreen(),
    );
  }
}
