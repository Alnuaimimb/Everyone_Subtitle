import 'package:flutter/material.dart';
import 'package:get/get.dart';

//local widgets
import 'package:everyone_subtitle/Features/authentication/controllers/onboarding_controller.dart';
import 'package:everyone_subtitle/Features/authentication/screens/onboarding/widgets/dot_navigator.dart';
import 'package:everyone_subtitle/Features/authentication/screens/onboarding/widgets/onBoarding_cicularButton.dart';
import 'package:everyone_subtitle/Features/authentication/screens/onboarding/widgets/onboarding_page.dart';

//utils
import 'package:everyone_subtitle/utils/constants/image_strings.dart';
import 'package:everyone_subtitle/utils/constants/sizes.dart';
import 'package:everyone_subtitle/utils/constants/text_strings.dart';
import 'package:everyone_subtitle/utils/device/device_utility.dart';

class onBoardingScreen extends StatelessWidget {
  const onBoardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(onBoardingController());

    return Scaffold(
      body: Stack(children: [
        /// Horizontal Scrollable Pages
        PageView(
          controller: controller.pageController,
          onPageChanged: controller.updatePageIndicator,
          children: const [
            onBoardingPage(
              title: TTexts.onBoardingTitle1,
              subtitle: TTexts.onBoardingSubTitle1,
              image: TImages.onBoardingImage1,
            ),
            onBoardingPage(
              title: TTexts.onBoardingTitle2,
              subtitle: TTexts.onBoardingSubTitle2,
              image: TImages.onBoardingImage2,
            ),
            onBoardingPage(
              title: TTexts.onBoardingTitle3,
              subtitle: TTexts.onBoardingSubTitle3,
              image: TImages.onBoardingImage3,
            ),
          ],
        ),

        /// Skip button
        Positioned(
          top: TDeviceUtils.getAppBarHeight(),
          right: TSizes.defaultSpace,
          child: TextButton(
            onPressed: () {
              controller.skipPage();
            },
            child: const Text("Skip"),
          ),
        ),

        /// Dot Navigation SmoothPage indicator
        const DotNavigator(),

        /// cicular button
        const onBoardingCircularButton()
      ]),
    );
  }
}
