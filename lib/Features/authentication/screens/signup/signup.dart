import 'package:flutter/material.dart';

import 'package:event_app/Features/authentication/screens/signup/widgets/signup_form.dart';
import 'package:event_app/common/widgets/login-SignUp/form_divider.dart';
import 'package:event_app/common/widgets/login-SignUp/login_social.dart';
import 'package:event_app/utils/constants/sizes.dart';
import 'package:event_app/utils/constants/text_strings.dart';
import 'package:event_app/utils/device/device_utility.dart';
import 'package:event_app/utils/helpers/helper_functions.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = THelperFunctions.isDarkMode(context);

    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(
            TDeviceUtils.getScreenWidth(context) > 500
                ? TSizes.defaultSpace
                : 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Signup header
              Text(
                TTexts.signupTitle,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: TSizes.spaceBtwSections),

              /// Signup form
              const SignupForm(),

              /// devider
              FormDivider(isDark: isDark, dividerText: TTexts.orSignUpWith),

              const SizedBox(height: TSizes.spaceBtwItems),
              const LoginSocial()
            ],
          ),
        ),
      ),
    );
  }
}
