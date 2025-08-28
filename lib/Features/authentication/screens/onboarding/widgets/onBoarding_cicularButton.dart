import 'package:flutter/material.dart';
import 'package:everyone_subtitle/Features/authentication/controllers/onboarding_controller.dart';
import 'package:everyone_subtitle/utils/constants/colors.dart';
import 'package:everyone_subtitle/utils/constants/sizes.dart';
import 'package:everyone_subtitle/utils/device/device_utility.dart';
import 'package:everyone_subtitle/utils/helpers/helper_functions.dart';

class onBoardingCircularButton extends StatelessWidget {
  const onBoardingCircularButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = onBoardingController.instance;
    return Positioned(
      right: TSizes.defaultSpace,
      bottom: TDeviceUtils.getBottomNavigationBarHeight(),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          backgroundColor: THelperFunctions.isDarkMode(context)
              ? TColors.buttonPrimary
              : TColors.dark,
        ),
        onPressed: controller.nextPage,
        child: const Icon(
          Icons.arrow_forward_ios_outlined,
          color: TColors.light,
        ),
      ),
    );
  }
}
