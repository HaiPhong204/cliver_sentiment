import '../../../../../core/core.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import '../../../../../common_widgets/common_widgets.dart';
import '../../controller/post_controller.dart';

class PackageDetail extends StatefulWidget {
  PackageController packageController;

  PackageDetail({Key? key, required this.packageController}) : super(key: key);

  @override
  State<PackageDetail> createState() => _PackageDetailState();
}

class _PackageDetailState extends State<PackageDetail> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "(*)",
                  style: TextStyle(fontSize: 13, color: Colors.redAccent),
                ),
                Text(
                  "Package",
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
            const SizedBox(height: 10),
            CustomTextField(
              controller: widget.packageController.packageName,
              hintText: "Name your package",
              length: 40,
              maxLines: 2,
            ),
            const SizedBox(height: 10),
            const Text(
              "Description",
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            CustomTextField(
              controller: widget.packageController.packageDes,
              hintText: "Details of your offering",
              length: 80,
              maxLines: 2,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "(*)",
                      style: TextStyle(fontSize: 13, color: Colors.redAccent),
                    ),
                    Text(
                      "Delivery time",
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
                const Spacer(),
                const Text(
                  "Revisions",
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                SizedBox(
                  width: context.screenSize.width * 0.45,
                  child: DropdownSearch<String>(
                    selectedItem: widget.packageController.deliveryDays == 1
                        ? '1 day'
                        : widget.packageController.deliveryDays.toString(),
                    popupProps: const PopupProps.menu(
                      showSelectedItems: true,
                      fit: FlexFit.loose,
                    ),
                    items: const [
                      "1 week",
                      "2 weeks",
                      "3 weeks",
                      "1 month",
                      "2 months",
                      "3 months"
                    ],
                    onChanged: (val) {
                      switch (val) {
                        case "1 week":
                          {
                            widget.packageController.deliveryDays = 1;
                            break;
                          }
                        case "2 weeks":
                          {
                            widget.packageController.deliveryDays = 2;
                            break;
                          }
                        case "3 weeks":
                          {
                            widget.packageController.deliveryDays = 3;
                            break;
                          }
                        case "1 month":
                          {
                            widget.packageController.deliveryDays = 4;
                            break;
                          }
                        case "2 months":
                          {
                            widget.packageController.deliveryDays = 8;
                            break;
                          }
                        case "3 months":
                          {
                            widget.packageController.deliveryDays = 12;
                            break;
                          }
                      }
                    },
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: context.screenSize.width * 0.45,
                  child: DropdownSearch<String>(
                    selectedItem: widget.packageController.revisions == 0
                        ? 'No revision'
                        : widget.packageController.revisions.toString(),
                    popupProps: const PopupProps.menu(
                      showSelectedItems: true,
                      fit: FlexFit.loose,
                    ),
                    items: const [
                      "No revision",
                      "3 time",
                      "5 times",
                      "10 times",
                    ],
                    onChanged: (val) {
                      switch (val) {
                        case "No revision":
                          {
                            widget.packageController.revisions = 0;
                            break;
                          }
                        case "1 time":
                          {
                            widget.packageController.revisions = 1;
                            break;
                          }
                        case "2 times":
                          {
                            widget.packageController.revisions = 2;
                            break;
                          }
                        case "3 times":
                          {
                            widget.packageController.revisions = 3;
                            break;
                          }
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "(*)",
                  style: TextStyle(fontSize: 13, color: Colors.redAccent),
                ),
                Text(
                  "Price",
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
            const SizedBox(height: 10),
            CustomTextField(
              controller: widget.packageController.price,
              hintText: "Number",
              type: "number",
              length: 17,
            ),
          ],
        ),
      ),
    );
  }
}
