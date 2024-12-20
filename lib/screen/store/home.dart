import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:pophub/assets/constants.dart';
import 'package:pophub/model/ad_model.dart';
import 'package:pophub/model/funding_model.dart';
import 'package:pophub/model/popup_model.dart';
import 'package:pophub/model/user.dart';
import 'package:pophub/notifier/GoodsNotifier.dart';
import 'package:pophub/notifier/StoreNotifier.dart';
import 'package:pophub/screen/adversiment/ad_edit.dart';
import 'package:pophub/screen/alarm/alarm.dart';
import 'package:pophub/screen/funding/funding.dart';
import 'package:pophub/screen/goods/goods_add.dart';
import 'package:pophub/screen/store/popup_view.dart';
import 'package:pophub/screen/store/store_add.dart';
import 'package:pophub/screen/store/store_list.dart';
import 'package:pophub/screen/user/login.dart';
import 'package:pophub/utils/api/funding_api.dart';
import 'package:pophub/utils/api/store_api.dart';
import 'package:pophub/utils/api/user_api.dart';
import 'package:pophub/utils/log.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int current = 0;
  final CarouselController controller = CarouselController();

  TextEditingController searchController = TextEditingController();
  String? searchInput;
  List<PopupModel> poppularList = [];
  List<FundingModel> fundingList = [];
  List<PopupModel> recommandList = [];
  List<PopupModel> willBeOpenList = [];
  List<PopupModel> willBeCloseList = [];
  bool _isExpanded = false;
  bool addGoodsVisible = false;
  List imageList = [];
  PopupModel? popup;
  List<AdModel> selectedAds = [];

  @override
  void initState() {
    super.initState();
    initializeData();
    _loadSelectedAds();
  }

  Future<void> initializeData() async {
    fetchPopupData();
    fetchFundingData();
    await profileApi();
    getRecommandPopup();
    await getWillBeOpenPopup();
    await getWillBeClosePopup();
  }

  Future<void> _loadSelectedAds() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? storedAds = prefs.getStringList('selected_ads');

    if (storedAds != null && storedAds.isNotEmpty) {
      setState(() {
        selectedAds = storedAds
            .where((adJson) => adJson.isNotEmpty)
            .map((adJson) {
              try {
                return AdModel.fromJson(jsonDecode(adJson));
              } catch (e) {
                print("Error parsing adJson: $adJson, Error: $e");
                return null;
              }
            })
            .where((ad) => ad != null)
            .cast<AdModel>()
            .toList();
      });
    }
  }

  Future<void> navigateToAdEdit(BuildContext context, AdModel ad) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdEditPage(ad: ad),
      ),
    );
    if (result == true) {
      await _loadSelectedAds(); // 광고 등록 후 selectedAds 리스트 갱신
    }
  }

  Future<void> profileApi() async {
    Map<String, dynamic> data = await UserApi.getProfile(User().userId);

    if (!data.toString().contains("fail")) {
      User().userName = data['userName'];
      User().phoneNumber = data['phoneNumber'];
      User().age = data['age'];
      User().gender = data['gender'];
      User().file = data['userImage'] ?? '';
      User().role = data['userRole'] ?? '';
      checkStoreApi();
    }
  }

  Future<void> fetchPopupData() async {
    try {
      List<PopupModel>? dataList = await StoreApi.getPopupList();

      if (dataList.isNotEmpty) {
        setState(() {
          poppularList = dataList;
        });
      }
    } catch (error) {
      Logger.debug('Error fetching popup data: $error');
    }
  }

  Future<void> fetchFundingData() async {
    try {
      List<FundingModel> dataList = await FundingApi.getFundingList();

      if (dataList.isNotEmpty) {
        setState(() {
          fundingList = dataList;
        });
      }
    } catch (error) {
      Logger.debug('Error fetching funding data: $error');
    }
  }

  Future<void> checkStoreApi() async {
    List<dynamic> data = await StoreApi.getMyPopup(User().userName);

    if (!data.toString().contains("fail") &&
        !data.toString().contains(('없습니다'))) {
      setState(() {
        addGoodsVisible = true;

        if (mounted) {
          popup = PopupModel.fromJson(data[0]);
        }
      });
    } else {
      setState(() {
        if (mounted) {
          addGoodsVisible = false;
        }
      });
    }
  }

  Future<void> getPopupByStoreName(String storeName) async {
    final data = await StoreApi.getPopupByName(storeName);
    if (!data.toString().contains("fail") && mounted) {
      if (context.mounted) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => MultiProvider(
                        providers: [
                          ChangeNotifierProvider(create: (_) => StoreModel())
                        ],
                        child: StoreListPage(
                          popups: data,
                          titleName: ('titleName_16').tr(),
                        ))));
      }
    } else {}
    setState(() {});
  }

  Future<void> getRecommandPopup() async {
    try {
      if (User().userName != "") {
        List<PopupModel>? dataList = await StoreApi.getRecommendedPopupList();
        if (dataList.isNotEmpty) {
          setState(() {
            recommandList = dataList;
          });
        }
      }
    } catch (error) {
      Logger.debug('Error getRecommandPopup popup data: $error');
    }
  }

  Future<void> getWillBeOpenPopup() async {
    try {
      List<PopupModel>? dataList = await StoreApi.getWillBeOpenPopupList();

      if (dataList.isNotEmpty) {
        willBeOpenList = dataList;
        if (willBeOpenList.isNotEmpty) {
          for (PopupModel popup in willBeOpenList) {
            if (popup.image != null) {
              setState(() {
                imageList.add(popup.image![0]);
              });
            }
          }
        }
      }
    } catch (error) {
      Logger.debug('Error getRecommandPopup popup data: $error');
    }
  }

  Future<void> getWillBeClosePopup() async {
    try {
      List<PopupModel>? dataList = await StoreApi.getWillBeOpenPopupList();

      if (dataList.isNotEmpty) {
        setState(() {
          willBeCloseList = dataList;
        });
      }
    } catch (error) {
      Logger.debug('Error getRecommandPopup popup data: $error');
    }
  }

  Widget _buildCollapsedFloatingButton() {
    return FloatingActionButton(
      onPressed: () {
        setState(() {
          _isExpanded = true;
        });
      },
      backgroundColor: Constants.DEFAULT_COLOR,
      shape: const CircleBorder(),
      child: const Icon(
        Icons.add,
        color: Colors.white,
      ),
    );
  }

  Widget _buildExpandedFloatingButtons() {
    return Transform.translate(
      offset: Offset(MediaQuery.of(context).size.width * 0.04,
          MediaQuery.of(context).size.height * 0.02),
      child: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = false;
              });
            },
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: Colors.white.withOpacity(0.85),
              child: Padding(
                padding: EdgeInsets.only(
                    right: MediaQuery.of(context).size.width * 0.04,
                    bottom: MediaQuery.of(context).size.height * 0.02),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    addGoodsVisible
                        ? _buildFloatingButtonWithText(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => MultiProvider(
                                              providers: [
                                                ChangeNotifierProvider(
                                                    create: (_) =>
                                                        GoodsNotifier())
                                              ],
                                              child: GoodsCreatePage(
                                                  mode: "add",
                                                  popup: popup!))));
                            },
                            icon: Icons.check_box_outlined,
                            text: ('titleName_7').tr(),
                          )
                        : const SizedBox(),
                    addGoodsVisible
                        ? const SizedBox(height: 16)
                        : const SizedBox(),
                    _buildFloatingButtonWithText(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MultiProvider(
                                        providers: [
                                          ChangeNotifierProvider(
                                              create: (_) => StoreModel())
                                        ],
                                        child: const StoreCreatePage(
                                            mode: "add"))));
                      },
                      icon: Icons.calendar_today,
                      text: ('popup_store').tr(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingButtonWithText({
    required Function onPressed,
    required IconData icon,
    required String text,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: Colors.black,
          ),
        ),
        const SizedBox(width: 8),
        FloatingActionButton(
          onPressed: onPressed as void Function()?,
          heroTag: null,
          backgroundColor: const Color(0xFF1C77E4),
          shape: const CircleBorder(),
          child: Icon(
            icon,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double screenWidth = screenSize.width;
    double screenHeight = screenSize.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: User().userId != ""
            ? const Text(
                "nice_to_meet_you_",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ).tr(args: [User().userName])
            : Image.asset(
                'assets/images/logo.png',
                width: screenWidth * 0.14,
              ),
        actions: [
          GestureDetector(
            onTap: () {
              if (User().userName != "") {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AlarmList()),
                );
              } else {
                if (context.mounted) {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const Login()));
                }
              }
            },
            child: const Icon(Icons.notifications_outlined,
                size: 32, color: Colors.black),
          ),
          const SizedBox(
            width: 10,
          ),
        ],
      ),
      floatingActionButton: User().role == 'President'
          ? (_isExpanded
              ? _buildExpandedFloatingButtons()
              : _buildCollapsedFloatingButton())
          : null,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: screenWidth * 0.9,
                height: screenHeight * 0.055,
                child: TextField(
                  controller: searchController,
                  onChanged: (value) {
                    setState(() {
                      searchInput = value;
                    });
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 1.0,
                        color: Constants.DEFAULT_COLOR,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 1.0,
                        color: Constants.DEFAULT_COLOR,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                    labelText: ('labelText_9').tr(),
                    labelStyle: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      fontFamily: 'recipe',
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    suffixIcon: IconButton(
                      onPressed: () {
                        getPopupByStoreName(searchController.text);
                      },
                      icon: const Icon(
                        Icons.search_sharp,
                        color: Colors.black,
                        size: 25,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: selectedAds.isNotEmpty
                    ? CarouselSlider(
                        items: selectedAds.map(
                          (ad) {
                            return Builder(
                              builder: (context) {
                                return SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  child: Image.network(
                                    ad.img, // AdModel의 img 필드를 사용하여 이미지를 로드
                                    fit: BoxFit.fill,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            ('the_image_cannot_be_loaded').tr(),
                                            style: const TextStyle(
                                                color: Colors.red),
                                          ),
                                          const SizedBox(height: 8),
                                          Text('Error: $error',
                                              style: const TextStyle(
                                                  color: Colors.red)),
                                        ],
                                      );
                                    },
                                  ),
                                );
                              },
                            );
                          },
                        ).toList(),
                        options: CarouselOptions(
                          height: 300,
                          viewportFraction: 1.0,
                          autoPlay: true,
                          autoPlayInterval: const Duration(seconds: 4),
                          onPageChanged: (index, reason) {
                            setState(() {
                              current = index;
                            });
                          },
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          ('_advertisement_inquiry_').tr(),
                          style:
                              const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Transform.translate(
                    offset: Offset(0, -screenWidth * 0.1),
                    child: Container(
                      width: screenWidth * 0.17,
                      height: screenWidth * 0.06,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(8),
                        ),
                        color: Colors.white.withOpacity(0.2),
                      ),
                      child: Center(
                        child: Text(
                          '${(current + 1).toString()}/${imageList.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // 인기 있는 팝업스토어
              SizedBox(
                width: screenWidth * 0.9,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      ('popular_popup_stores').tr(),
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (context.mounted) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MultiProvider(
                                          providers: [
                                            ChangeNotifierProvider(
                                                create: (_) => StoreModel())
                                          ],
                                          child: StoreListPage(
                                            popups: poppularList,
                                            titleName: ('titleName_17').tr(),
                                          ))));
                        }
                      },
                      child: const Row(
                        children: [
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: screenWidth,
                    height: screenWidth * 0.7,
                    child: ListView.builder(
                      itemCount: poppularList.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        final popup = poppularList[index];
                        return Padding(
                          padding: EdgeInsets.only(
                              left: screenWidth * 0.05,
                              right: poppularList.length == index + 1
                                  ? screenWidth * 0.05
                                  : 0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PopupDetail(
                                    storeId: popup.id!,
                                  ),
                                ),
                              );
                            },
                            child: SizedBox(
                              width: screenWidth * 0.5,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  popup.image != null && popup.image!.isNotEmpty
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Image.network(
                                            '${popup.image![0]}',
                                            width: screenWidth * 0.5,
                                            height: screenWidth * 0.5,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Image.asset(
                                            'assets/images/logo.png',
                                            width: screenWidth * 0.5,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      '${popup.name}',
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${DateFormat("yy.MM.dd").format(DateTime.parse(popup.start!))} ~ ${DateFormat("yy.MM.dd").format(DateTime.parse(popup.end!))}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              // 종료 예정 팝업스토어
              SizedBox(
                width: screenWidth * 0.9,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      ('titleName_18').tr(),
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (context.mounted) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MultiProvider(
                                          providers: [
                                            ChangeNotifierProvider(
                                                create: (_) => StoreModel())
                                          ],
                                          child: StoreListPage(
                                            popups: willBeCloseList,
                                            titleName: ('titleName_18').tr(),
                                          ))));
                        }
                      },
                      child: const Row(
                        children: [
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: screenWidth,
                    height: screenWidth * 0.7,
                    child: ListView.builder(
                      itemCount: willBeCloseList.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        final popup = willBeCloseList[index];

                        return Padding(
                          padding: EdgeInsets.only(
                              left: screenWidth * 0.05,
                              right: willBeCloseList.length == index + 1
                                  ? screenWidth * 0.05
                                  : 0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PopupDetail(
                                    storeId: popup.id!,
                                  ),
                                ),
                              );
                            },
                            child: SizedBox(
                              width: screenWidth * 0.5,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  popup.image != null && popup.image!.isNotEmpty
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Image.network(
                                            '${popup.image![0]}',
                                            width: screenWidth * 0.5,
                                            height: screenWidth * 0.5,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Image.asset(
                                            'assets/images/logo.png',
                                            width: screenWidth * 0.5,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      '${popup.name}',
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${DateFormat("yy.MM.dd").format(DateTime.parse(popup.start!))} ~ ${DateFormat("yy.MM.dd").format(DateTime.parse(popup.end!))}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              // 추천 팝업스토어
              Visibility(
                visible: recommandList.isNotEmpty && User().userName != "",
                child: SizedBox(
                  width: screenWidth * 0.9,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        ('titleName_19').tr(),
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      GestureDetector(
                        onTap: () {
                          if (context.mounted) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MultiProvider(
                                            providers: [
                                              ChangeNotifierProvider(
                                                  create: (_) => StoreModel())
                                            ],
                                            child: StoreListPage(
                                              popups: recommandList,
                                              titleName: ('titleName_19').tr(),
                                            ))));
                          }
                        },
                        child: const Row(
                          children: [
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 14,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Visibility(
                visible: recommandList.isNotEmpty && User().userName != "",
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: screenWidth,
                      height: screenWidth * 0.7,
                      child: ListView.builder(
                        itemCount: recommandList.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          final popup = recommandList[index];

                          return Padding(
                            padding: EdgeInsets.only(
                                left: screenWidth * 0.05,
                                right: recommandList.length == index + 1
                                    ? screenWidth * 0.05
                                    : 0),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PopupDetail(
                                      storeId: popup.id!,
                                    ),
                                  ),
                                );
                              },
                              child: SizedBox(
                                width: screenWidth * 0.5,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    popup.image != null &&
                                            popup.image!.isNotEmpty
                                        ? ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: Image.network(
                                              '${popup.image![0]}',
                                              width: screenWidth * 0.5,
                                              height: screenWidth * 0.5,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        : ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: Image.asset(
                                              'assets/images/logo.png',
                                              width: screenWidth * 0.5,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        '${popup.name}',
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '${DateFormat("yy.MM.dd").format(DateTime.parse(popup.start!))} ~ ${DateFormat("yy.MM.dd").format(DateTime.parse(popup.end!))}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              // 신규 펀딩
              SizedBox(
                width: screenWidth * 0.9,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      ('new_funding').tr(),
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (context.mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Funding()),
                          );
                        }
                      },
                      child: const Row(
                        children: [
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: screenWidth,
                    height: screenWidth * 0.7,
                    child: ListView.builder(
                      itemCount: fundingList.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        final funding = fundingList[index];
                        return Padding(
                          padding: EdgeInsets.only(
                              left: screenWidth * 0.05,
                              right: fundingList.length == index + 1
                                  ? screenWidth * 0.05
                                  : 0),
                          child: GestureDetector(
                            onTap: () {},
                            child: SizedBox(
                              width: screenWidth * 0.5,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  funding.images != null &&
                                          funding.images!.isNotEmpty
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Image.network(
                                            '${funding.images![0]}',
                                            width: screenWidth * 0.5,
                                            height: screenWidth * 0.5,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Image.asset(
                                            'assets/images/logo.png',
                                            width: screenWidth * 0.5,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      '${funding.title}',
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget sliderWidget() {
    return CarouselSlider(
      carouselController: controller,
      items: selectedAds.map(
        (img) {
          return Builder(
            builder: (context) {
              return SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Image.network(
                  img.toString(),
                  fit: BoxFit.fill,
                ),
                // Image.asset(
                //   img,
                //   fit: BoxFit.fill,
                // ),
              );
            },
          );
        },
      ).toList(),
      options: CarouselOptions(
        height: 300,
        viewportFraction: 1.0,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 4),
        onPageChanged: (index, reason) {
          setState(() {
            current = index;
          });
        },
      ),
    );
  }
}
