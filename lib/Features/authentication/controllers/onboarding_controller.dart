import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:everyone_subtitle/Features/authentication/screens/login/login.dart';

class onBoardingController extends GetxController {
  final deviceStorage = GetStorage();
  static onBoardingController get instance => Get.find();

  // variables
  final pageController = PageController();
  Rx<int> currentPageIndex = 0.obs;

  // update current index when page scroll
  void updatePageIndicator(index) {
    currentPageIndex.value = index;
  }

  // void jump to specific dot selected page.
  void dotNavigationClick(index) {
    currentPageIndex.value = index;
    pageController.jumpToPage(index);
  }

  // update current index and jump to the next page
  void nextPage() {
    if (currentPageIndex.value == 2) {
      debugPrint('Onboarding completed, setting IsFirstTime to false');
      deviceStorage.write('IsFirstTime', false);
      Get.offAll(const LoginScreen());
    } else {
      int page = currentPageIndex.value + 1;
      pageController.jumpToPage(page);
    }
  }

  // update current index and jump to the last page
  void skipPage() {
    currentPageIndex.value = 2;
    pageController.jumpToPage(2);
  }

  // Reset first time flag for testing (can be called from settings or debug)
  void resetFirstTimeFlag() {
    deviceStorage.write('IsFirstTime', true);
    debugPrint('IsFirstTime reset to true');
  }
}
