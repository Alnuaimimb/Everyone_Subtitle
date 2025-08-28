import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:event_app/Features/authentication/controllers/login_controller.dart';
import 'package:event_app/Features/authentication/screens/password_reset/forget_password.dart';
import 'package:event_app/utils/constants/sizes.dart';
import 'package:event_app/utils/constants/text_strings.dart';
import 'package:event_app/utils/device/device_utility.dart';
import 'package:event_app/utils/validators/validation.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = LoginController.instance;
    return Form(
      key: controller.logInFormKey,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: TDeviceUtils.getScreenWidth(context) > 500
              ? TSizes.spaceBtwItems
              : 0,
          vertical: TSizes.spaceBtwSections,
        ),
        child: Column(
          children: [
            /// Email
            TextFormField(
              controller: controller.email,
              validator: (value) {
                return TValidator.validateEmail(value);
              },
              decoration: const InputDecoration(
                prefixIcon: Icon(Iconsax.direct_right),
                label: Text(TTexts.email),
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwInputFields),

            /// Password
            TextFormField(
              controller: controller.password,
              validator: (value) {
                return TValidator.validatePassword(value);
              },
              decoration: const InputDecoration(
                prefixIcon: Icon(Iconsax.password_check),
                label: Text(TTexts.password),
                suffixIcon: Icon(Iconsax.eye_slash),
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwInputFields / 2),

            /// Remember me + Forget password
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                /// Remeber me
                Row(
                  children: [
                    Checkbox(value: true, onChanged: (value) {}),
                    const Text(TTexts.rememberMe)
                  ],
                ),

                /// Forget Password
                TextButton(
                  onPressed: () {
                    Get.to(const ForgetPassword());
                  },
                  child: const Text(TTexts.forgetPassword),
                ),
              ],
            ),

            /// sign in button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  controller.login();
                },
                child: const Text(TTexts.signIn),
              ),
            ),

            const SizedBox(
              height: TSizes.spaceBtwItems,
            ),

            /// sign in button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: controller.signup,
                child: const Text(TTexts.createAccount),
              ),
            )
          ],
        ),
      ),
    );
  }
}
