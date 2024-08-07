import 'dart:convert';
import '../../../../data/services/RecommendService.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import '../../../../data/models/model.dart';
import '../../../../data/services/services.dart';
import '../../../common_widgets/common_widgets.dart';
import '../../../controller/controller.dart';
import '../../../core/core.dart';
import '../../../routes/routes.dart';
import '../../features.dart';

class BuyerHomeScreen extends StatefulWidget {
  const BuyerHomeScreen({super.key});

  @override
  State<BuyerHomeScreen> createState() => _BuyerHomeScreenState();
}

class _BuyerHomeScreenState extends State<BuyerHomeScreen> {
  late List<Post> posts = [];
  late List<Post> postsSave = [];
  late List<Post> postsRecommend = [];
  late List<Category> categoryList = [];
  late List<Post> postsRecent = [];
  late List<SaveService> saveList;
  late bool isGetDataAllCategory;
  late bool isGetDataPostsRecent;
  late bool isGetDataPosts;
  late bool isGetDataPostsSave;
  late bool isGetDataPostsRecommend;
  late final UserController userController;

  @override
  void initState() {
    userController = Get.find();
    getPopularCategory();
    getPostsRecent();
    getPosts();
    getPostsSave();
    getPostsRecommend();
    super.initState();
  }

  void getPopularCategory() async {
    setState(() {
      isGetDataAllCategory = false;
    });
    EasyLoading.show();
    var res = await CategoriesService.ins.getPopularCategory();
    EasyLoading.dismiss();
    if (res.isOk) {
      if (res.body["data"] is Iterable<dynamic> && res.body["data"].isNotEmpty) {
        res.body["data"].forEach((v) {
          if (v != null) {
            categoryList.add(Category.fromJson(v));
          }
        });
      }
    }
    setState(() {
      isGetDataAllCategory = true;
    });
  }

  void getPostsRecent() async {
    setState(() {
      isGetDataPostsRecent = false;
    });
    EasyLoading.show();
    var res = await PostService.ins.getPostsRecently();
    EasyLoading.dismiss();
    if (res.isOk) {
      if (res.body["data"] is Iterable<dynamic> && res.body["data"].isNotEmpty) {
        postsRecent = <Post>[];
        res.body["data"].forEach((v) {
          if (v != null) {
            postsRecent.add(Post.fromJson(v));
          }
        });
      }
    }
    setState(() {
      isGetDataPostsRecent = true;
    });
  }

  void getPosts() async {
    setState(() {
      isGetDataPosts = false;
    });
    EasyLoading.show();
    var res = await PostService.ins.getPosts();
    EasyLoading.dismiss();
    if (res.isOk) {
      if (res.body["data"] is Iterable<dynamic> && res.body["data"].isNotEmpty) {
        posts = <Post>[];
        res.body["data"].forEach((v) {
          if (v != null) {
            posts.add(Post.fromJson(v));
          }
        });
      }
    }
    setState(() {
      isGetDataPosts = true;
    });
  }

  void getPostsSave() async {
    setState(() {
      isGetDataPostsSave = false;
    });
    EasyLoading.show();
    var res = await SaveServiceAPI.ins.getServicesSave();
    EasyLoading.dismiss();
    if (res.isOk) {
      if (res.body["data"] is Iterable<dynamic> && res.body["data"].isNotEmpty) {
        postsSave = <Post>[];
        res.body["data"].forEach((v) {
          if (v != null) {
            postsSave.add(Post.fromJson(v));
          }
        });
      }
    }
    setState(() {
      isGetDataPostsSave = true;
    });
  }

  String replaceNaN(String json) {
    return json.replaceAll('NaN', 'null');
  }

  void getPostsRecommend() async {
    setState(() {
      isGetDataPostsRecommend = false;
    });
    EasyLoading.show();
    var res = await RecommendService.ins.getPostRecommend(
        skill: userController.currentUser.value.skills,
        experiences: userController.currentUser.value.description);
    EasyLoading.dismiss();
    var responseData = json.decode(replaceNaN(res.body));
    if (res.isOk) {
      if (res.body.isNotEmpty) {
        postsRecommend = <Post>[];
        responseData.forEach((v) {
          if (v != null) {
            postsRecommend.add(Post.fromJson(v));
          }
        });
      }
    }
    setState(() {
      isGetDataPostsRecommend = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    CustomSize().init(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryWhite,
        leadingWidth: getWidth(120),
        leading: Padding(
          padding: EdgeInsets.symmetric(horizontal: getWidth(20), vertical: getHeight(12)),
          child: Row(
            children: [
              Text(
                'Cliver',
                style: TextStyle(fontSize: getFont(26), fontWeight: FontWeight.w700),
              ),
              Container(
                width: getWidth(8),
                height: getHeight(8),
                margin: EdgeInsets.only(top: getHeight(15)),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: AppColors.greenCrayola,
                ),
              )
            ],
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: getWidth(20),
            ),
            child: Icon(
              Icons.notifications,
              size: getWidth(27),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWellWrapper(
              onTap: () => Get.toNamed(searchRoute, arguments: categoryList),
              margin: EdgeInsets.symmetric(horizontal: getWidth(20), vertical: getHeight(20)),
              color: AppColors.primaryWhite,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 2,
                  spreadRadius: 1,
                  offset: const Offset(0, 1),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 1,
                  spreadRadius: 0,
                  offset: const Offset(0, 1),
                )
              ],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: getWidth(20)),
                    child: Text('Search your services'.tr,
                        style: TextStyle(
                            fontSize: getFont(16), color: AppColors.primaryBlack.withOpacity(0.7))),
                  ),
                  Padding(
                    padding: EdgeInsets.all(getWidth(7)),
                    child: CircleAvatar(
                      radius: getHeight(40 / 2),
                      backgroundColor: Colors.transparent,
                      child: Icon(
                        Icons.search,
                        color: AppColors.primaryBlack.withOpacity(0.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const PageImageAnimation(),
            SizedBox(height: getHeight(20)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: getWidth(20)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('PopularCategories'.tr,
                      style: TextStyle(
                          color: AppColors.primaryBlack,
                          fontWeight: FontWeight.bold,
                          fontSize: getFont(20))),
                ],
              ),
            ),
            if (isGetDataAllCategory)
              SizedBox(
                height: getHeight(230),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  padding: EdgeInsets.symmetric(horizontal: getWidth(20), vertical: getHeight(10)),
                  itemBuilder: (BuildContext context, int index) {
                    return CategoryPopular(
                      category: categoryList[index],
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    SearchResultCategory(result: categoryList[index])));
                      },
                    );
                  },
                  itemCount: categoryList.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 5),
                ),
              ),
            Padding(
              padding: EdgeInsets.only(left: getWidth(20), top: getHeight(20)),
              child: Text('inspired'.tr,
                  style: TextStyle(
                      color: AppColors.primaryBlack,
                      fontWeight: FontWeight.bold,
                      fontSize: getFont(20))),
            ),
            if (isGetDataPosts)
              SizedBox(
                height: getHeight(300),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  padding: EdgeInsets.symmetric(horizontal: getWidth(20), vertical: getHeight(10)),
                  itemBuilder: (BuildContext context, int index) {
                    return CategoryHistoryItem(
                      postHistory: posts[index],
                      getPostsRecent: getPosts,
                      onTap: () => Get.toNamed(postDetailScreenRoute, arguments: posts[index].id),
                      onChangedStatus: (value) async {
                        EasyLoading.show();
                        await SaveServiceAPI.ins.changeStatusServicesSaveListById(
                            listId: value, serviceId: posts[index].id!);
                      },
                    );
                  },
                  itemCount: posts.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 5),
                ),
              ),
            Visibility(
              visible: postsRecommend.isNotEmpty,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                        left: getWidth(20), right: getWidth(20), top: getHeight(20)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Jobs recommendation'.tr,
                            style: TextStyle(
                                color: AppColors.primaryBlack,
                                fontWeight: FontWeight.bold,
                                fontSize: getFont(20))),
                        InkWellWrapper(
                          onTap: () => Get.toNamed(getAllJobRecommendRoute,
                            arguments: [userController.currentUser.value.skills, userController.currentUser.value.description]),
                          child: Text(
                            'See All'.tr,
                            style: TextStyle(
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                              decorationColor: AppColors.primaryColor,
                              fontSize: getFont(14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isGetDataPostsRecommend)
                    SizedBox(
                      height: getHeight(365),
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        padding:
                            EdgeInsets.symmetric(horizontal: getWidth(20), vertical: getHeight(10)),
                        itemBuilder: (BuildContext context, int index) {
                          return CategorySave(
                            onTap: () => Get.toNamed(postDetailScreenRoute,
                                arguments: postsRecommend[index].id),
                            postSave: postsRecommend[index],
                            getPostsRecent: getPostsRecommend,
                            onChangedStatus: (value) async {
                              EasyLoading.show();
                              await SaveServiceAPI.ins.changeStatusServicesSaveListById(
                                  listId: value, serviceId: postsRecommend[index].id!);
                              EasyLoading.dismiss();
                            },
                          );
                        },
                        itemCount: postsRecommend.length,
                        separatorBuilder: (context, index) => const SizedBox(width: 5),
                      ),
                    ),
                ],
              ),
            ),
            Visibility(
              visible: postsRecent.isNotEmpty,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                        left: getWidth(20), right: getWidth(20), top: getHeight(20)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('recently view'.tr,
                            style: TextStyle(
                                color: AppColors.primaryBlack,
                                fontWeight: FontWeight.bold,
                                fontSize: getFont(20))),
                      ],
                    ),
                  ),
                  if (isGetDataPostsRecent)
                    SizedBox(
                      height: getHeight(365),
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        padding:
                            EdgeInsets.symmetric(horizontal: getWidth(20), vertical: getHeight(10)),
                        itemBuilder: (BuildContext context, int index) {
                          return PostRecentlyView(
                            onTap: () => Get.toNamed(postDetailScreenRoute,
                                arguments: postsRecent[index].id),
                            postRecent: postsRecent[index],
                            getPostsRecent: getPostsRecent,
                            onChangedStatus: (value) async {
                              EasyLoading.show();
                              await SaveServiceAPI.ins.changeStatusServicesSaveListById(
                                  listId: value, serviceId: postsRecent[index].id!);
                              EasyLoading.dismiss();
                            },
                          );
                        },
                        itemCount: postsRecent.length,
                        separatorBuilder: (context, index) => const SizedBox(width: 5),
                      ),
                    ),
                ],
              ),
            ),
            Visibility(
              visible: postsSave.isNotEmpty,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                        left: getWidth(20), right: getWidth(20), top: getHeight(20)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('recently save'.tr,
                            style: TextStyle(
                                color: AppColors.primaryBlack,
                                fontWeight: FontWeight.bold,
                                fontSize: getFont(20))),
                      ],
                    ),
                  ),
                  if (isGetDataPostsSave)
                    SizedBox(
                      height: getHeight(365),
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        padding:
                            EdgeInsets.symmetric(horizontal: getWidth(20), vertical: getHeight(10)),
                        itemBuilder: (BuildContext context, int index) {
                          return CategorySave(
                            onTap: () =>
                                Get.toNamed(postDetailScreenRoute, arguments: postsSave[index].id),
                            postSave: postsSave[index],
                            getPostsRecent: getPostsSave,
                            onChangedStatus: (value) async {
                              EasyLoading.show();
                              await SaveServiceAPI.ins.changeStatusServicesSaveListById(
                                  listId: value, serviceId: postsSave[index].id!);
                              EasyLoading.dismiss();
                            },
                          );
                        },
                        itemCount: postsSave.length,
                        separatorBuilder: (context, index) => const SizedBox(width: 5),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
