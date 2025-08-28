import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:event_app/features/authentication/screens/login/login.dart';
import 'package:event_app/utils/constants/sizes.dart';
import 'package:event_app/utils/constants/text_strings.dart';

class ForgetPassword extends StatelessWidget {
  const ForgetPassword({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// title & subtitle
              Text(
                textAlign: TextAlign.left,
                TTexts.forgetPasswordTitle,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: TSizes.spaceBtwItems),
              Text(
                textAlign: TextAlign.left,
                TTexts.forgetPasswordSubTitle,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: TSizes.spaceBtwSections * 2),

              /// formField
              const TextField(
                decoration: InputDecoration(
                  prefixIcon: Icon(Iconsax.direct_right),
                  label: Text(TTexts.email),
                ),
              ),
              const SizedBox(height: TSizes.spaceBtwSections),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  child: const Text(TTexts.submit),
                  onPressed: () {
                    Get.to(const LoginScreen());
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
