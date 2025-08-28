import 'package:flutter/material.dart';
import 'package:event_app/common/styles/spacing_style.dart';
import 'package:event_app/Features/authentication/screens/login/widgets/Login_header.dart';
import 'package:event_app/common/widgets/login-SignUp/form_divider.dart';
import 'package:event_app/Features/authentication/screens/login/widgets/login_form.dart';
import 'package:event_app/common/widgets/login-SignUp/login_social.dart';
import 'package:event_app/utils/constants/sizes.dart';
import 'package:event_app/utils/constants/text_strings.dart';
import 'package:event_app/utils/helpers/helper_functions.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = THelperFunctions.isDarkMode(context);
    return Scaffold(
      body: SingleChildScrollView(
        padding: TSpaceingStyle.paddingWithAppBarHeight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ///App logo
            LoginHeader(),

            ///FORM
            const LoginForm(),

            /// Divider
            FormDivider(
              isDark: isDark,
              dividerText: TTexts.orSignInWith,
            ),
            const SizedBox(height: TSizes.spaceBtwItems),

            /// socail icons
            const LoginSocial()
          ],
        ),
      ),
    );
  }
}
