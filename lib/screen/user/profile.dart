import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:pophub/assets/constants.dart';
import 'package:pophub/model/popup_model.dart';
import 'package:pophub/model/review_model.dart';
import 'package:pophub/model/user.dart';
import 'package:pophub/model/visit_model.dart';
import 'package:pophub/notifier/StoreNotifier.dart';
import 'package:pophub/screen/adversiment/ad_list.dart';
import 'package:pophub/screen/alarm/alarm_add.dart';
import 'package:pophub/screen/alarm/notice_add.dart';
import 'package:pophub/screen/delivery/delivery_list.dart';
import 'package:pophub/screen/funding/funding.dart';
import 'package:pophub/screen/funding/funding_add.dart';
import 'package:pophub/screen/funding/funding_list.dart';
import 'package:pophub/screen/reservation/waiting_list_store.dart';
import 'package:pophub/screen/setting/address_write.dart';
import 'package:pophub/screen/setting/app_setting.dart';
import 'package:pophub/screen/setting/inquiry.dart';
import 'package:pophub/screen/setting/notice.dart';
import 'package:pophub/screen/store/alarm_list.dart';
import 'package:pophub/screen/store/popup_view.dart';
import 'package:pophub/screen/store/store_add.dart';
import 'package:pophub/screen/store/store_list.dart';
import 'package:pophub/screen/user/achieve.dart';
import 'package:pophub/screen/user/acount_info.dart';
import 'package:pophub/screen/user/calender.dart';
import 'package:pophub/screen/user/login.dart';
import 'package:pophub/screen/user/my_review.dart';
import 'package:pophub/screen/user/my_waiting.dart';
import 'package:pophub/screen/user/point_list.dart';
import 'package:pophub/screen/user/profile_add.dart';
import 'package:pophub/utils/api/funding_api.dart';
import 'package:pophub/utils/api/review_api.dart';
import 'package:pophub/utils/api/store_api.dart';
import 'package:pophub/utils/api/user_api.dart';
import 'package:pophub/utils/api/visit_api.dart';
import 'package:pophub/utils/log.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? profile; // profile 변수를 nullable로 선언
  bool isLoading = true; // 로딩 상태 변수 추가
  List<ReviewModel>? reviewList;
  String? storeId;
  String visitCount = "";
  List<PopupModel> reviewPopupList = [];

  Future<void> profileApi() async {
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> data = await UserApi.getProfile(User().userId);

    if (!data.toString().contains("fail")) {
      profile = data;
      User().userName = data['userName'];
      User().phoneNumber = data['phoneNumber'];
      User().age = data['age'];
      User().gender = data['gender'];
      User().file = data['userImage'] ?? '';
      User().role = data['userRole'] ?? '';
    } else {
      // 에러 처리
      if (mounted) {
        if (User().userId != "") {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ProfileAdd(
                        refreshProfile: profileApi,
                        useCallback: true,
                        isUser: true,
                      )));
        } else {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => const Login()));
        }
      }
    }

    setState(() {
      isLoading = false; // 로딩 상태 변경
    });
  }

  Future<void> checkStoreApi() async {
    setState(() {
      isLoading = true;
    });
    List<dynamic> data = await StoreApi.getMyPopup(User().userName);

    if (!data.toString().contains("fail") &&
        !data.toString().contains("없습니다")) {
      //TODO : 황지민 팝업 가져오는경우 처리
      PopupModel popup;
      popup = PopupModel.fromJson(data[0]);
      storeId = popup.id;
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PopupDetail(
              storeId: popup.id!,
              mode: "modify",
            ),
          ),
        );
      }
    } else {
      if (mounted) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => MultiProvider(providers: [
                      ChangeNotifierProvider(create: (_) => StoreModel())
                    ], child: const StoreCreatePage(mode: "add"))));
      }
    }

    setState(() {
      isLoading = false; // 로딩 상태 변경
    });
  }

  Future<void> fetchVisitData() async {
    try {
      List<VisitModel>? dataList = await VisitApi.getCalendar();

      if (dataList.isNotEmpty) {
        setState(() {
          visitCount = dataList.length.toString();
        });
      }
    } catch (error) {
      Logger.debug('Error fetching calendar data: $error');
    }
  }

  Future<void> getStoreId() async {
    setState(() {
      isLoading = true;
    });
    List<dynamic> data = await StoreApi.getMyPopup(User().userName);

    if (!data.toString().contains("fail") &&
        !data.toString().contains("없습니다")) {
      //TODO : 황지민 팝업 가져오는경우 처리
      PopupModel popup;
      popup = PopupModel.fromJson(data[0]);
      storeId = popup.id;
    } else {}
  }

  Future<void> checkFundingApi() async {
    setState(() {
      isLoading = true;
    });
    List<dynamic> data = await FundingApi.getMyFunding();
    print(data);

    if (data.toString().contains("Not")) {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const FundingAddPage(
                    mode: "add",
                  )),
        );
      }
    } else {
      if (mounted) {
        if (User().role == "President") {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const Funding(mode: 'select')),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FundingList()),
          );
        }
      }
    }

    setState(() {
      isLoading = false; // 로딩 상태 변경
    });
  }

  Future<void> fetchReviewData() async {
    try {
      List<ReviewModel>? dataList =
          await ReviewApi.getReviewListByUser(User().userName);
      if (dataList.isNotEmpty) {
        setState(() {
          reviewList = dataList;
        });

        for (ReviewModel review in dataList) {
          PopupModel? data =
              await StoreApi.getPopup(review.store.toString(), false, "");
          reviewPopupList.add(data);
        }
      }
    } catch (error) {
      Logger.debug('Error fetching review data: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    profileApi(); // API 호출
    fetchReviewData();
    getStoreId();
    fetchVisitData();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double screenWidth = screenSize.width;
    double screenHeight = screenSize.height;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const AppSetting()));
            },
          ),
          SizedBox(
            width: screenWidth * 0.05,
          )
        ],
        backgroundColor: Constants.DEFAULT_COLOR,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Stack(
              children: [
                Column(
                  children: [
                    Container(
                      width: screenWidth,
                      height: screenHeight * 0.2,
                      decoration: const BoxDecoration(
                        color: Constants.DEFAULT_COLOR,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                Transform.translate(
                  offset: Offset(0, screenHeight * 0.025),
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      SizedBox(
                          width: screenWidth,
                          height: screenHeight * 1,
                          child: Center(
                            child: Container(
                                width: screenWidth * 0.9,
                                height: screenHeight * 0.65,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 0.5,
                                    color: Colors.grey,
                                  ),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(15)),
                                  color: Colors.white,
                                ),
                                child: Padding(
                                  padding:
                                      EdgeInsets.only(top: screenWidth * 0.1),
                                  child: SingleChildScrollView(
                                    child: Column(
                                      //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      AcountInfo(
                                                        refreshProfile:
                                                            profileApi,
                                                      )),
                                            );
                                          },
                                          child: SizedBox(
                                            // width: screenWidth * 0.4,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const SizedBox(width: 20),
                                                Text(
                                                  // 닉네임으로 수정
                                                  profile?['userName'] ?? '',
                                                  style: const TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                const Icon(
                                                  Icons.arrow_forward_ios,
                                                  size: 20,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Visibility(
                                          visible:
                                              User().role == "General Member",
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                                top: screenHeight * 0.03),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                GestureDetector(
                                                  onTap: () {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                const PointListPage()));
                                                  },
                                                  child: SizedBox(
                                                    width:
                                                        (screenWidth * 0.3) - 2,
                                                    child: Column(
                                                      children: [
                                                        Text(
                                                          profile?['pointScore']
                                                                  .toString() ??
                                                              '',
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 10,
                                                        ),
                                                        Text(
                                                          'point'.tr(),
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 16,
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  height: screenWidth * 0.15,
                                                  width: 1,
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                const Calender()));
                                                  },
                                                  child: SizedBox(
                                                    width:
                                                        (screenWidth * 0.3) - 2,
                                                    child: Column(
                                                      children: [
                                                        Text(
                                                          visitCount,
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 10,
                                                        ),
                                                        Text(
                                                          'visit'.tr(),
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 16,
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  height: screenWidth * 0.15,
                                                  width: 1,
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                                SizedBox(
                                                  width:
                                                      (screenWidth * 0.3) - 2,
                                                  child: Column(
                                                    children: [
                                                      Text(
                                                        reviewList?.length
                                                                .toString() ??
                                                            '0',
                                                        style: const TextStyle(
                                                          fontSize: 20,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 10,
                                                      ),
                                                      GestureDetector(
                                                        onTap: () {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder:
                                                                  (context) =>
                                                                      MyReview(
                                                                reviews:
                                                                    reviewList ??
                                                                        [],
                                                                popupModels:
                                                                    reviewPopupList,
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                        child: Text(
                                                          'text_1'.tr(),
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 16,
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        MenuList(
                                          icon: Icons.star,
                                          text: 'text'.tr(),
                                          onClick: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const AchievementsPage(),
                                              ),
                                            );
                                          },
                                        ),

                                        MenuList(
                                          icon: Icons.comment,
                                          text: 'text_1'.tr(),
                                          onClick: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        MyReview(
                                                            reviews:
                                                                reviewList ??
                                                                    [],
                                                            popupModels:
                                                                reviewPopupList ??
                                                                    [])));
                                          },
                                        ),
                                        MenuList(
                                          icon: Icons.info_outline,
                                          text: 'text_2'.tr(),
                                          onClick: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        const NoticePage()));
                                          },
                                        ),
                                        MenuList(
                                          icon: Icons.help_outline,
                                          text: 'text_3'.tr(),
                                          onClick: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        const InquiryPage()));
                                          },
                                        ),
                                        Visibility(
                                          visible: User().role == "Manager",
                                          child: Column(
                                            children: [
                                              MenuList(
                                                icon: Icons.add_alert,
                                                text: 'text_4'.tr(),
                                                onClick: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              const AlarmAdd()));
                                                },
                                              ),
                                              MenuList(
                                                icon: Icons.add_circle_outline,
                                                text: 'text_5'.tr(),
                                                onClick: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              const NoticeAdd()));
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                        Visibility(
                                          visible: User().role == "President",
                                          child: MenuList(
                                            icon: Icons.message_outlined,
                                            text: 'text_6'.tr(),
                                            onClick: () {
                                              checkStoreApi();
                                            },
                                          ),
                                        ),
                                        Visibility(
                                          visible: User().role == "Manager",
                                          child: MenuList(
                                            icon: Icons
                                                .assignment_turned_in_outlined,
                                            text: 'text_7'.tr(),
                                            onClick: () async {
                                              final data = await StoreApi
                                                  .getPendingList();
                                              if (context.mounted) {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            MultiProvider(
                                                                providers: [
                                                                  ChangeNotifierProvider(
                                                                      create: (_) =>
                                                                          StoreModel())
                                                                ],
                                                                child:
                                                                    StoreListPage(
                                                                  popups: data,
                                                                  titleName:
                                                                      "titleName_1"
                                                                          .tr(),
                                                                  mode:
                                                                      "pending",
                                                                ))));
                                              }
                                            },
                                          ),
                                        ),
                                        Visibility(
                                          visible:
                                              User().role == "General Member",
                                          child: MenuList(
                                            icon: Icons.event_note,
                                            text: 'text_8'.tr(),
                                            onClick: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          AlarmListPage(
                                                            mode: "name",
                                                            titleName:
                                                                "text_8".tr(),
                                                          )));
                                            },
                                          ),
                                        ),
                                        Visibility(
                                          visible:
                                              User().role == "General Member",
                                          child: MenuList(
                                            icon: Icons.event_note,
                                            text: '현장대기 내역',
                                            onClick: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          const MyWaiting()));
                                            },
                                          ),
                                        ),
                                        MenuList(
                                          icon: Icons.payment,
                                          text: 'text_9'.tr(),
                                          onClick: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    DeliveryListPage(
                                                  storeId: storeId,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                        Visibility(
                                          visible: User().role == "President",
                                          child: MenuList(
                                            icon: Icons.event_note,
                                            text: 'text_10'.tr(),
                                            onClick: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          AlarmListPage(
                                                            mode: "store",
                                                            titleName:
                                                                "text_10".tr(),
                                                          )));
                                            },
                                          ),
                                        ),

                                        Visibility(
                                          visible: User().role == "President",
                                          child: MenuList(
                                            icon: Icons.event_note,
                                            text: 'make_a_waiting'.tr(),
                                            onClick: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          const WaitingListStorePage()));
                                            },
                                          ),
                                        ),
                                        // Visibility(
                                        //   visible: User().role == "President",
                                        //   child: MenuList(
                                        //     icon: Icons.shopping_bag_outlined,
                                        //     text: '펀딩',
                                        //     onClick: () {
                                        //       checkFundingApi();
                                        //     },
                                        //   ),
                                        // ),
                                        Visibility(
                                          visible: User().role == "Manager",
                                          child: MenuList(
                                            icon: Icons.ad_units,
                                            text: 'text_11'.tr(),
                                            onClick: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      const AdListPage(),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        Visibility(
                                          visible:
                                              User().role == "General Member" ||
                                                  User().role == "President",
                                          child: MenuList(
                                            icon: Icons.shopping_bag_outlined,
                                            text: 'text_12'.tr(),
                                            onClick: () {
                                              checkFundingApi();
                                            },
                                          ),
                                        ),
                                        MenuList(
                                          icon: Icons.mobile_friendly_rounded,
                                          text: 'address_add'.tr(),
                                          onClick: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const AddressWritePage(),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                )),
                          ))
                    ],
                  ),
                ),
                Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    // SizedBox(
                    //   width: screenWidth,
                    //   child: CircleAvatar(
                    //     backgroundImage: NetworkImage(profile['userImage'] ?? ''),
                    //     radius: 50,
                    //   ),
                    // ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: screenWidth * 0.26,
                          height: screenWidth * 0.26,
                          child: ClipRRect(
                              borderRadius: const BorderRadius.all(
                                Radius.circular(1000),
                              ),
                              child: profile?['userImage'] != null
                                  ? Image.network(
                                      profile?['userImage'] ?? '',
                                      fit: BoxFit.cover,
                                    )
                                  : Image.asset('assets/images/goods.png')),
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ),
    );
  }
}

class MenuList extends StatelessWidget {
  final IconData icon;
  final String text;
  final void Function() onClick;
  const MenuList({
    super.key,
    required this.icon,
    required this.text,
    required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double screenWidth = screenSize.width;
    double screenHeight = screenSize.height;
    return Padding(
      padding: EdgeInsets.only(
          left: screenWidth * 0.05,
          right: screenWidth * 0.05,
          top: screenHeight * 0.022,
          bottom: screenHeight * 0.022),
      child: GestureDetector(
        onTap: onClick,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 24,
                ),
                const SizedBox(
                  width: 10,
                ),
                SizedBox(
                  width: screenWidth * 0.6,
                  child: Text(
                    text,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
              ],
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
