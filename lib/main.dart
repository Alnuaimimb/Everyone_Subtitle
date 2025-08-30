import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:everyone_subtitle/app.dart';
import 'package:everyone_subtitle/data/repositories/authentication/authentication_repository.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load environment variables before initializing services
  await dotenv.load(fileName: 'lib/utils/constants/.env');
  await GetStorage.init();
  await Firebase.initializeApp();

  // Initialize GetX with proper configuration
  Get.config(
    enableLog: true,
    defaultPopGesture: true,
    defaultTransition: Transition.fade,
  );

  // Make auth repo available and let it handle initial routing via onReady()
  Get.put(AuthenticationRepository(), permanent: true);

  runApp(const App());
}
