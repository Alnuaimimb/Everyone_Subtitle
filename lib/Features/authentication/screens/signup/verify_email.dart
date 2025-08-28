import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:event_app/Features/authentication/controllers/signup/verify_email_controller.dart';
import 'package:event_app/common/widgets/rusable_screens/sucess_screen.dart';
import 'package:event_app/features/authentication/screens/login/login.dart';
import 'package:event_app/utils/constants/image_strings.dart';
import 'package:event_app/utils/constants/sizes.dart';
import 'package:event_app/utils/constants/text_strings.dart';
import 'package:event_app/utils/helpers/helper_functions.dart';

class VerifyEmail extends StatelessWidget {
  const VerifyEmail({
    super.key,
    required this.email,
  });

  final String email;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VerifyEmailController());
    final screenWidth = THelperFunctions.screenWidth();
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              Get.offAll(const LoginScreen());
            },
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            children: [
              /// Image
              Image(
                width:
                    (screenWidth > 500 ? screenWidth * 0.5 : screenWidth * 0.9),
                image: const AssetImage(
                  TImages.deliveredEmailIllustration,
                ),
              ),
              const SizedBox(height: TSizes.spaceBtwSections),

              /// Title & Subtitle
              Text(
                textAlign: TextAlign.center,
                TTexts.confirmEmail,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: TSizes.spaceBtwItems),
              Text(
                email,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: TSizes.spaceBtwItems),
              Text(
                TTexts.confirmEmailSubTitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(height: TSizes.spaceBtwSections),

              /// Buttons
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    controller.checkEmailVerificationStatus();
                  },
                  child: const Text(TTexts.tContinue),
                ),
              ),
              const SizedBox(height: TSizes.spaceBtwItems),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                    onPressed: () {
                      controller.sendEmailVerification();
                    },
                    child: const Text(TTexts.resendEmail)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
