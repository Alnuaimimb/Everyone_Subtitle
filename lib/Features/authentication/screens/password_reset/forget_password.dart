import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:everyone_subtitle/Features/authentication/controllers/forget_password_controller.dart';
import 'package:everyone_subtitle/utils/constants/sizes.dart';
import 'package:everyone_subtitle/utils/constants/text_strings.dart';
import 'package:everyone_subtitle/utils/validators/validation.dart';

class ForgetPassword extends StatelessWidget {
  const ForgetPassword({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ForgetPasswordController());

    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Form(
            key: controller.forgetPasswordFormKey,
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

                /// Email form field
                TextFormField(
                  controller: controller.email,
                  validator: (value) => TValidator.validateEmail(value),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Iconsax.direct_right),
                    label: Text(TTexts.email),
                  ),
                ),
                const SizedBox(height: TSizes.spaceBtwSections),

                /// Submit button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => controller.sendPasswordResetEmail(),
                    child: const Text(TTexts.submit),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
