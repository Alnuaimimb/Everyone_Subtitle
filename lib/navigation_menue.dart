import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:everyone_subtitle/Features/authentication/controllers/login_controller.dart';

import 'package:everyone_subtitle/data/repositories/authentication/authentication_repository.dart';

class NavigationMenue extends StatelessWidget {
  const NavigationMenue({super.key});

  @override
  Widget build(BuildContext context) {
    final controler = Get.put(NavigationController());
    return Scaffold(
      bottomNavigationBar: Obx(
        () => NavigationBar(
          selectedIndex: controler.selectedIndex.value,
          onDestinationSelected: (index) {
            controler.selectedIndex.value = index;
          },
          destinations: const [
            NavigationDestination(icon: Icon(Iconsax.home), label: 'Home'),
            NavigationDestination(icon: Icon(Iconsax.shop), label: 'Main'),
            NavigationDestination(icon: Icon(Iconsax.user), label: 'Profile'),
          ],
        ),
      ),
      body: Obx(
        () => controler.screens[controler.selectedIndex.value],
      ),
    );
  }
}

/// To avoid using stafull widget we use this controller
class NavigationController extends GetxController {
  final Rx<int> selectedIndex = 0.obs;

  final screens = [];
}
