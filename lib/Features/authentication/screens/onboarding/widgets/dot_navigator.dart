import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:everyone_subtitle/Features/authentication/controllers/onboarding_controller.dart';
import 'package:everyone_subtitle/utils/constants/colors.dart';
import 'package:everyone_subtitle/utils/constants/sizes.dart';
import 'package:everyone_subtitle/utils/device/device_utility.dart';
import 'package:everyone_subtitle/utils/helpers/helper_functions.dart';

class DotNavigator extends StatelessWidget {
  const DotNavigator({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = onBoardingController.instance;
    return Positioned(
      bottom: TDeviceUtils.getBottomNavigationBarHeight() + 30,
      left: TSizes.defaultSpace,
      child: SmoothPageIndicator(
        controller: controller.pageController,
        count: 3,
        onDotClicked: controller.dotNavigationClick,
        effect: ExpandingDotsEffect(
            activeDotColor: THelperFunctions.isDarkMode(context)
                ? TColors.light
                : TColors.dark,
            dotHeight: 6),
      ),
    );
  }
}
