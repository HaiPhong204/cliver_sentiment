import 'dart:io';

import 'package:ezjob/app/core/utils/utils.dart';
import 'package:ezjob/app/core/values/app_colors.dart';
import 'package:ezjob/app/features/seller/post/controller/post_controller.dart';
import 'package:ezjob/app/routes/routes.dart';
import 'package:ezjob/data/services/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';


class EditStep4 extends StatefulWidget {
  const EditStep4({Key? key}) : super(key: key);

  @override
  State<EditStep4> createState() => _EditStep4State();
}

class _EditStep4State extends State<EditStep4> {
  final ImagePicker imgPicker = ImagePicker();

  List<String> imageFileList = [];

  final PostController _controller = Get.find();

  @override
  void initState() {
    super.initState();
  }

  void selectMultiImages() async {
    final List<XFile> selected = await imgPicker.pickMultiImage();

    imageFileList.addAll(selected.map((e) => e.path).toList());
    if (imageFileList.length > 6) {
      imageFileList.removeRange(6, imageFileList.length);
    }
    setState(() {});
  }

  void selectImages(int i) async {
    final XFile? selected =
        await imgPicker.pickImage(source: ImageSource.gallery);

    if (selected != null) {
      imageFileList[i] = selected.path;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Showcase your service in a Gallery",
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 10),
              const ListTile(
                horizontalTitleGap: 0,
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.info_outline),
                dense: true,
                title: Text(
                  "To comply with Cliver Terms of service, make sure to upload only content you either own or you have the permission or license to use.",
                  textAlign: TextAlign.justify,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "(*)",
                        style: TextStyle(
                            fontSize: 13,
                            color: Colors.redAccent
                        ),
                      ),
                      Text(
                        "Images (up to 6)",
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Visibility(
                    visible: imageFileList.isNotEmpty ? true : false,
                    child: GestureDetector(
                      onTap: () => selectMultiImages(),
                      child: Text(
                        "More",
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              imageFileList.isEmpty
                  ? GestureDetector(
                      onTap: () {
                        selectMultiImages();
                      },
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.secondaryColor),
                        ),
                        child: const Icon(
                          Icons.panorama_outlined,
                          color: Colors.grey,
                          size: 50,
                        ),
                      ),
                    )
                  : SizedBox(
                      height: 200,
                      child: ListView.builder(
                        itemCount: imageFileList.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, i) {
                          return GestureDetector(
                            onTap: () {
                              selectImages(i);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Stack(
                                children: [
                                  Image.file(
                                    width: context.screenSize.width * 0.75,
                                    File(imageFileList[i]),
                                    fit: BoxFit.cover,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        imageFileList.removeAt(i);
                                      });
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.all(5),
                                      child: Icon(Icons.close),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: ElevatedButton(
          onPressed: () async {
            if (imageFileList.isNotEmpty) {
              EasyLoading.show();
              var listLink = await StorageService.ins.uploadPostImages(
                  imageFileList.map((e) => File(e)).toList(),
                  _controller.currentPost.id!);
              EasyLoading.dismiss();
              _controller.currentPost.images = listLink;
              _controller.currentPost.isPublish = true;

              EasyLoading.show();
              var res = await PostService.ins.putPostStep(post: _controller.currentPost);
              EasyLoading.dismiss();
              if (res.isOk) {
                Get.delete<PostController>();
                Get.offAllNamed(sellerProfileScreenRoute);
              } else {
                EasyLoading.showToast(res.error, toastPosition: EasyLoadingToastPosition.bottom);
              }
            } else {
              EasyLoading.showToast('enterAllInformation'.tr, toastPosition: EasyLoadingToastPosition.bottom);
            }
          },
          child: const Text("Finish"),
        ),
      ),
    );
  }
}
