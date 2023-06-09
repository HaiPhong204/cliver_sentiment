import '../../../core/core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/routes.dart';
import '../../features.dart';

class ImageAttachPopup extends StatelessWidget {
  const ImageAttachPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: context.screenSize.width * 0.05,
      bottom: context.screenSize.height * 0.1,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.lightGreenColor.withOpacity(0.6),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            ButtonIcon(
              onPressed: () {},
              icon: Icons.image_outlined,
            ),
            SizedBox(
              width: context.screenSize.width * 0.03,
            ),
            ButtonIcon(
              onPressed: () {},
              icon: Icons.attachment_outlined,
            ),
            SizedBox(
              width: context.screenSize.width * 0.03,
            ),
            if (Get.find<BottomBarController>().isSeller.value)
              ElevatedButton(
                onPressed: () => Get.toNamed(customOrderScreenRoute),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    "Custom Order",
                    style: TextStyle(color: AppColors.primaryColor),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
