import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:event_app/Features/authentication/controllers/signup/signup_controller.dart';
import 'package:event_app/utils/constants/colors.dart';
import 'package:event_app/utils/constants/sizes.dart';
import 'package:event_app/utils/constants/text_strings.dart';
import 'package:event_app/utils/helpers/helper_functions.dart';
import 'package:event_app/utils/validators/validation.dart';

class SignupForm extends StatelessWidget {
  const SignupForm({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = THelperFunctions.isDarkMode(context);
    final controller = Get.put(SignupController());
    return Form(
      key: controller.signUpFormKey,
      child: Column(
        children: [
          /// First & Last name
          Row(
            children: [
              /// First Name
              Expanded(
                child: TextFormField(
                  controller: controller.firstName,
                  validator: (value) {
                    return TValidator.validateEmptyText(value, 'First Name');
                  },
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Iconsax.user),
                    label: Text(TTexts.firstName),
                  ),
                ),
              ),
              const SizedBox(width: TSizes.spaceBtwInputFields),

              /// Last Name
              Expanded(
                child: TextFormField(
                  controller: controller.lastName,
                  validator: (value) {
                    return TValidator.validateEmptyText(value, 'First Name');
                  },
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Iconsax.user),
                    label: Text(TTexts.lastName),
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: TSizes.spaceBtwInputFields),

          /// User Name
          TextFormField(
            controller: controller.userName,
            validator: (value) {
              return TValidator.validateEmptyText(
                  value, 'User Name'); // This now returns a string or null
            },
            decoration: const InputDecoration(
              prefixIcon: Icon(Iconsax.user),
              label: Text(TTexts.username),
            ),
          ),

          const SizedBox(height: TSizes.spaceBtwInputFields),

          /// Email
          TextFormField(
            controller: controller.email,
            validator: (value) {
              return TValidator.validateEmail(value);
            },
            decoration: const InputDecoration(
              prefixIcon: Icon(Iconsax.direct),
              label: Text(TTexts.email),
            ),
          ),
          const SizedBox(height: TSizes.spaceBtwInputFields),

          /// Phone number
          TextFormField(
            controller: controller.phoneNumber,
            validator: (value) {
              return TValidator.validatePhoneNumber(value);
            },
            decoration: const InputDecoration(
              prefixIcon: Icon(Iconsax.call),
              label: Text(TTexts.phoneNo),
            ),
          ),
          const SizedBox(height: TSizes.spaceBtwInputFields),

          /// Password
          Obx(
            () => TextFormField(
              controller: controller.password,
              validator: (value) {
                return TValidator.validatePassword(value);
              },
              obscureText: controller.hidePassword.value,
              decoration: InputDecoration(
                prefixIcon: const Icon(Iconsax.password_check),
                label: const Text(TTexts.password),
                suffixIcon: IconButton(
                  onPressed: () => controller.hidePassword.value =
                      !controller.hidePassword.value,
                  icon: controller.hidePassword.value
                      ? const Icon(Iconsax.eye_slash)
                      : const Icon(Iconsax.eye),
                ),
              ),
            ),
          ),
          const SizedBox(height: TSizes.spaceBtwItems),

          /// term and conditions checkbox
          Row(
            children: [
              Obx(() => Checkbox(
                  value: controller.privacyPolicy.value,
                  onChanged: (value) {
                    controller.privacyPolicy.value = value!;
                  })),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                          text: '${TTexts.iAgreeTo} ',
                          style: Theme.of(context).textTheme.bodySmall),
                      TextSpan(
                        text: '${TTexts.privacyPolicy} ',
                        style: Theme.of(context).textTheme.bodyMedium!.apply(
                              color: isDark ? TColors.white : TColors.primary,
                              decorationColor:
                                  isDark ? TColors.white : TColors.primary,
                            ),
                      ),
                      TextSpan(
                          text: '${TTexts.and} ',
                          style: Theme.of(context).textTheme.bodySmall),
                      TextSpan(
                        text: '${TTexts.termsOfUse} ',
                        style: Theme.of(context).textTheme.bodyMedium!.apply(
                              color: isDark ? TColors.white : TColors.primary,
                              decorationColor:
                                  isDark ? TColors.white : TColors.primary,
                            ),
                      ),
                    ],
                  ),
                  softWrap: false,
                ),
              ),
            ],
          ),
          const SizedBox(height: TSizes.spaceBtwItems),

          /// Create an account button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                controller.signup();
              },
              child: const Text(TTexts.createAccount),
            ),
          ),
          const SizedBox(height: TSizes.spaceBtwSections),
        ],
      ),
    );
  }
}
