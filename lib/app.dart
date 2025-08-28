import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:event_app/Features/authentication/screens/onboarding/onboarding.dart';
import 'package:event_app/bindings/general_bindings.dart';
import 'package:event_app/utils/theme/theme.dart';

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
