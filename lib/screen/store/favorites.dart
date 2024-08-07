import 'package:flutter/material.dart';
import 'package:pophub/model/like_model.dart';
import 'package:pophub/model/popup_model.dart';
import 'package:pophub/model/user.dart';
import 'package:pophub/screen/store/store_list.dart';
import 'package:pophub/screen/user/login.dart';
import 'package:pophub/utils/api/like_api.dart';
import 'package:pophub/utils/api/store_api.dart';
import 'package:pophub/utils/log.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<PopupModel> likePopupList = [];
  bool isLoading = false;

  Future<void> getPopupData() async {
    likePopupList.clear();
    if (context.mounted) {
      if (User().userName != "") {
        final likeData = await LikeApi.getLikePopup();

        for (LikeModel like in likeData) {
          try {
            PopupModel? popup =
                await StoreApi.getPopup(like.storeId, true, like.userName);
            if (context.mounted) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  likePopupList.add(popup);
                });
                isLoading = true;
              });
            }
          } catch (error) {
            // 오류 처리
            Logger.debug('Error fetching popup data: $error');
          }
        }
      } else {
        if (context.mounted) {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => const Login()));
        }
      }
    }
  }

  Future<void> initializeData() async {
    await getPopupData();
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      initializeData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return !isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : StoreListPage(
            popups: likePopupList,
          );
  }
}
