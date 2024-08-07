import 'dart:developer';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

import '../../../core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../data/enums/action.dart' as Action;
import 'package:path_provider/path_provider.dart';
import '../../../../data/enums/status.dart';
import '../../../../data/models/model.dart';
import '../../../../data/services/services.dart';
import '../../../routes/routes.dart';
import '../../features.dart';

class BuyerOrderController extends GetxController {
  RxList<Order> orders = <Order>[].obs;
  Rx<Order> order = Order().obs;
  RxList<String> images = RxList();
  Status selectedStatus = Status.PendingPayment;
  RxString fileName = "Please select a zip file".tr.obs;
  RxString fileSizeName = "".obs;
  File? file;

  // buyer order detail
  Status? orderStatus;
  bool isFirstDoing = true;
  RxList<Widget> timeline = <Widget>[].obs;
  final f = DateFormat('dd MMM HH:mm');
  String reviewContent = "";
  late Review review;
  int rating = 1;
  String? url;

  Future<void> getBuyerOrderByStatus({required String? orderStatus}) async {
    try {
      EasyLoading.show();
      Response? res;
      if (orderStatus == null) {
        res = await OrderService.ins.getBuyerOrders();
      } else {
        res =
            await OrderService.ins.getBuyerOrdersByStatus(status: orderStatus);
      }
      EasyLoading.dismiss();
      if (res!.isOk) {
        List<Order> listOrder = res.body["data"]
            .map<Order>((json) => Order.fromJson(json))
            .toList();
        if (orderStatus == null) {
          listOrder
              .sort((a, b) => b.updatedAt!.compareTo(a.updatedAt as DateTime));
          orders.value = List.from(listOrder);
        } else {
          orders.value = List.from(listOrder);
        }
        log("${res.body['message']}");
      } else {
        Get.defaultDialog(
          title: "Error".tr,
          content: Text(res.error),
        );
      }
    } catch (e) {
      log("BuyerOrderController get orders by status error: $e");
      EasyLoading.dismiss();
    }
  }

  void initBuyerOrderDetailData() {
    orderStatus = Status.values.firstWhere((e) => e == order.value.status);
  }

  Future<void> reloadData() async {
    order.value = await getOrder(orderId: order.value.id as int) as Order;
    orderStatus = order.value.status;
  }

  Future<void> downloadZip(String fileName) async {
    if (url != null) {
      try {
        EasyLoading.show();
        final appStorage = await getApplicationDocumentsDirectory();
        log(url!);
        await FlutterDownloader.enqueue(
          url: url!,
          savedDir: appStorage.path,
          showNotification: true,
          openFileFromNotification: true,
          saveInPublicStorage: true,
        );
        EasyLoading.dismiss();
        await Get.defaultDialog(
          title: "Notification".tr,
          content: Text("Download successfully".tr),
        );
        log("download path: ${appStorage.path}/$fileName");
      } catch (e) {
        EasyLoading.dismiss();
        log("download zip error: $e");
      }
    }
  }

  // delivered order method
  Future<void> acceptDeliveredOrder() async {
    EasyLoading.show();
    try {
      OrderAction orderAction = OrderAction(action: Action.Action.Receive);
      var res = await OrderService.ins.sendBuyerAction(
        orderId: order.value.id as int,
        orderAction: orderAction,
      );
      await reloadData();
      EasyLoading.dismiss();
      if (res.isOk) {
        Get.defaultDialog(
          title: "Success".tr,
          content: Text("Accept delivered order success".tr),
        );
      } else {
        Get.defaultDialog(
          title: "Error".tr,
          content: Text(res.error),
        );
      }
    } catch (e) {
      log("accept delivered order error: $e");
      EasyLoading.dismiss();
    }
  }

  Future<void> denyDeliveredOrder() async {
    EasyLoading.show();
    try {
      OrderAction orderAction = OrderAction(action: Action.Action.Revision);
      var res = await OrderService.ins.sendBuyerAction(
        orderId: order.value.id as int,
        orderAction: orderAction,
      );
      await reloadData();
      await EasyLoading.dismiss();
      if (res.isOk) {
        Get.defaultDialog(
          title: "Success".tr,
          content: Text("Deny delivered order success".tr),
        );
      } else {
        Get.defaultDialog(
          title: "Error".tr,
          content: Text(res.error),
        );
      }
    } catch (e) {
      log("deny delivered order error: $e");
      EasyLoading.dismiss();
    }
  }

  Future<void> reviewOrder() async {
    if (reviewContent.length < 10) {
      Get.defaultDialog(
        title: "Warning".tr,
        content: Text("Please leave your comment at least 10 characters".tr),
      );
      return;
    }
    EasyLoading.show();
    try {
      var res = await OrderService.ins.buyerReview(
        orderId: order.value.id as int,
        createReview: CreateReview(
          orderId: order.value.id,
          rating: rating,
          comment: reviewContent,
          label: 0
        ),
      );
      if (res.isOk) {
        var temp = Map<String, dynamic>.from(res.body["data"]);
        log(temp.runtimeType.toString());
        review = Review.fromJson(temp);
        await reloadData();
        EasyLoading.dismiss();
        log(res.body["message"]);
      } else {
        EasyLoading.dismiss();
        Get.defaultDialog(
          title: "Error".tr,
          content: Text(res.error),
        );
      }
    } catch (e) {
      log("buyer review error $e");
      EasyLoading.dismiss();
    }
  }

  // canceled order
  Future<void> cancelOrder() async {
    EasyLoading.show();
    try {
      OrderAction orderAction = OrderAction(action: Action.Action.Cancel);
      var res = await OrderService.ins.sendBuyerAction(
        orderId: order.value.id as int,
        orderAction: orderAction,
      );
      await reloadData();
      await EasyLoading.dismiss();
      if (res.isOk) {
        Get.defaultDialog(
          title: "Success".tr,
          content: Text("Cancel order successfully".tr),
        );
      } else {
        Get.defaultDialog(
          title: "Error".tr,
          content: Text(res.error),
        );
      }
    } catch (e) {
      EasyLoading.dismiss();
    }
  }

  // base order method

  Future<RxList<Order>> getAllOrders() async {
    orders.clear();
    EasyLoading.show();
    try {
      var res = await OrderService.ins.getBuyerOrders();
      EasyLoading.dismiss();
      if (res!.isOk) {
        print(res.body["data"]);
        List<Order> listOrder = res.body["data"]
            .map<Order>((json) => Order.fromJson(json))
            .toList() as List<Order>;
        listOrder
            .sort((a, b) => b.updatedAt!.compareTo(a.updatedAt as DateTime));

        orders.value = List.from(listOrder);
        log("${res.body['message']}");
        return orders;
      } else {
        Get.defaultDialog(
          title: "Error".tr,
          content: Text(res.error),
        );
      }
    } catch (e) {
      log("BuyerOrderController getAllOrders error: $e");
      EasyLoading.dismiss();
    }
    return <Order>[].obs;
  }

  Future<String?> getOrderImage({required int postId}) async {
    try {
      var res = await PostService.ins.getPostById(id: postId);
      if (res.isOk) {
        return res.body["data"]["images"][0];
      }
      Get.defaultDialog(
        title: "Error".tr,
        content: Text(res.error),
      );
    } catch (e) {
      log("get order image error: $e");
    }
    return null;
  }

  Future<Order?> getOrder({required int orderId}) async {
    timeline.clear();
    order.value.histories?.clear();
    try {
      var res = await OrderService.ins.getBuyerOrder(orderId: orderId);
      if (res!.isOk) {
        log("${res.body['message']}");
        order.value = Order.fromJson(res.body["data"]);
        orderStatus = order.value.status;
        return order.value;
      }
      Get.defaultDialog(
        title: "Error".tr,
        content: Text(res.error),
      );
    } catch (e) {
      log("BuyerOrderController getAllOrders error: $e");
    }
    return null;
  }

  openVnPayWeb() async {
    try {
      EasyLoading.show();
      var res = await OrderService.ins
          .buyerContinuePaymentWithBudget(orderId: order.value.id as int);
      EasyLoading.dismiss();

      if (res.isOk) {
        var vnpayUrl = res.body;
        if (vnpayUrl != null) {
          var webResult = await Get.to(() => WebviewScreen(initUrl: vnpayUrl));

          //nếu thanh toán thành công thì pop ra
          if (webResult == true) {
            await Get.defaultDialog(
              title: "Payment success".tr,
              middleText: "You have paid for the service".tr,
            );
          }
          popAllToBottomBar();
        } else {
          log("vnpayUrl null");
        }
      }
    } catch (e) {
      log("getPaymentUrl error: $e");
      EasyLoading.dismiss();
    }
    EasyLoading.dismiss();
  }

  void clearZipFile() {
    file = null;
    fileName.value = "Please select a zip file".tr;
    fileSizeName.value = "";
  }

  Future<void> deliveryOrder() async {
    EasyLoading.show();
    try {
      CreateResource? createResource;
      String? zipUrl;
      if (file != null) {
        zipUrl = await StorageService.ins
            .uploadZip(file!, order.value.package?.postId as int);
        createResource = CreateResource(
          name: fileName.value,
          size: file?.lengthSync(),
          url: zipUrl,
        );
        String temp =
        fileSizeName.value.substring(0, fileSizeName.value.length - 4);
        double fileSize = double.parse(temp.substring(1));
        if (fileSize > 500) {
          await Get.defaultDialog(
              title: "The selected zip file must not exceed 500 MB");
          return;
        }
      } else {
        Get.defaultDialog(
          title: "Error".tr,
          content: Text("Please select a zip file".tr),
        );
        EasyLoading.dismiss();
        return;
      }
      OrderAction orderAction = OrderAction(
        action: Action.Action.Delivery,
        resource: createResource,
      );
      var res = await OrderService.ins.sendSellerAction(
        orderId: order.value.id as int,
        orderAction: orderAction,
      );
      await reloadData();
      EasyLoading.dismiss();
      if (res.isOk) {
        Get.defaultDialog(
          title: "Success",
          content: const Text("Delivery order successfully"),
        );
      } else {
        Get.defaultDialog(
          title: "Error".tr,
          content: Text(res.error),
        );
      }
    } catch (e) {
      log("delivery order error $e");
      EasyLoading.dismiss();
    }
  }

  Future<void> pickZipFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
    );
    if (result != null) {
      log(result.toString());
      File pickedFile = File(result.files.single.path as String);
      if (pickedFile.path.substring(pickedFile.path.length - 3) != 'zip') {
        await Get.defaultDialog(
          title: "Unsupported file type".tr,
          content: Text("Please pick a zip file".tr),
        );
        return;
      }
      file = pickedFile;
      fileName.value = getFileName();
      String temp = await getFileSize(pickedFile.path, 1);
      fileSizeName.value = "($temp)";
    }
  }

  String getFileName() {
    int nameLength = 0;
    for (var i = file!.path.length - 1; i >= 0; i--) {
      if (file?.path[i] != '/') {
        nameLength++;
      } else {
        break;
      }
    }
    return file!.path.substring(file!.path.length - nameLength);
  }

  void popAllToBottomBar() {
    var bottomBarController = Get.find<BottomBarController>();
    bottomBarController.currentIndex.value = 2;
    Get.offAllNamed(myBottomBarRoute);
  }
}
