import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:everyone_subtitle/Features/authentication/screens/onboarding/onboarding.dart';
import 'package:everyone_subtitle/bindings/general_bindings.dart';
import 'package:everyone_subtitle/utils/theme/theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      themeMode: ThemeMode.light,
      theme: TAppTheme.lightTheme,
      initialBinding: GeneralBindings(),
      home: const Scaffold(
        body: onBoardingScreen(),
      ),
    );
  }
}
