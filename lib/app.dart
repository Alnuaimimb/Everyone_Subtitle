import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:everyone_subtitle/bindings/general_bindings.dart';
import 'package:everyone_subtitle/utils/theme/theme.dart';
import 'package:everyone_subtitle/data/repositories/authentication/authentication_repository.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'everyone-subtitle',
      themeMode: ThemeMode.light,
      theme: TAppTheme.lightTheme,
      initialBinding: GeneralBindings(),
      home: const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      onReady: () {
        // Let the auth repository handle routing
        AuthenticationRepository.instance.screenRedirect();
      },
    );
  }
}
