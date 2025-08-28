import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lottie/lottie.dart';
import 'package:event_app/common/styles/spacing_style.dart';
import 'package:event_app/utils/constants/image_strings.dart';
import 'package:event_app/utils/constants/sizes.dart';
import 'package:event_app/utils/constants/text_strings.dart';
import 'package:event_app/utils/helpers/helper_functions.dart';

class SucessScreen extends StatelessWidget {
  const SucessScreen({
    super.key,
    required this.image,
    required this.title,
    required this.subtitle,
    required this.onPressed,
  });
  final String image, title, subtitle;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final screenWidth = THelperFunctions.screenWidth();
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: TSpaceingStyle.paddingWithAppBarHeight * 2,
          child: Column(
            children: [
              /// Image
              Lottie.asset(
                image,
                width:
                    (screenWidth > 500 ? screenWidth * 0.5 : screenWidth * 0.9),
              ),

              const SizedBox(height: TSizes.spaceBtwSections),

              /// Title & Subtitle
              Text(
                textAlign: TextAlign.center,
                title,
                style: Theme.of(context).textTheme.headlineMedium,
              ),

              const SizedBox(height: TSizes.spaceBtwItems),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(height: TSizes.spaceBtwSections),

              /// Buttons
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: onPressed, child: const Text(TTexts.tContinue)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
