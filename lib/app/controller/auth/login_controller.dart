import '../../core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/models/model.dart';
import '../../../data/services/services.dart';
import '../../routes/routes.dart';
import '../controller.dart';

class LoginController extends GetxController {
  final TextEditingController email = TextEditingController();
  final TextEditingController pass = TextEditingController();

  loginFunc() async {
    if (email.text.isEmpty || pass.text.isEmpty) {
      EasyLoading.showToast("Please enter your email and password", toastPosition: EasyLoadingToastPosition.bottom);
      return;
    }

    EasyLoading.show();
    var res = await AuthService.instance
        .login(user: User(email: email.text, password: pass.text));
    EasyLoading.dismiss();

    if (res.isOk) {
      //save user data
      final UserController userController = Get.find();
      userController.currentUser.value = User.fromJson(res.data);
      userController.userToken = "Bearer ${res.body["token"]}";
      //save user token in local
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("user_token", "Bearer ${res.body["token"]}");

      //get user wallet
      res =
          await AuthService.instance.getWallet(token: userController.userToken);
      if (res.isOk) {
        Wallet wallet = Wallet.fromJson(res.body["data"]["wallet"]);
        userController.currentUser.value.wallet = wallet;
        userController.currentUser.value.isActive = true;

        Get.offAllNamed(myBottomBarRoute);
      } else {
        Get.defaultDialog(
          title: "Error".tr,
          content: Text(res.error),
        );
      }
    } else {
      Get.defaultDialog(
        title: "Error".tr,
        content: Text(res.error.tr),
      );
    }
  }

  void toForgetPassScreen() {
    Get.toNamed(forgetPassScreenRoute);
  }
}
