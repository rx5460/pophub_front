import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pophub/assets/constants.dart';
import 'package:pophub/model/user.dart';
import 'package:pophub/screen/custom/custom_title_bar.dart';
import 'package:pophub/utils/api/user_api.dart';

class StoreMain extends StatefulWidget {
  const StoreMain({super.key});

  @override
  State<StoreMain> createState() => _StoreMainState();
}

class _StoreMainState extends State<StoreMain> {
  bool loginCompelete = false;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  String token = "";
  String profileData = "";

  // Future<void> testApi() async {
  //   final data =
  //       await PaymentApi.postPay(User().userId, "zero22", 1, 33000, 3000, 0);
  //   // Map<String, dynamic> valueMap = json.decode(data);
  //   profileData = data.toString();
  //   setState(() {});
  // }

  Future<void> popupApi() async {
    final data = await UserApi.getProfile(User().userId);
    // Map<String, dynamic> valueMap = json.decode(data);
    profileData = data.toString();
    setState(() {});
  }

  Future<void> _showToken() async {
    token = (await _storage.read(key: 'token'))!;
    setState(() {});
  }

  @override
  void initState() {
    _showToken();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            body: Center(
              child: Padding(
                  // width: double.infinity,
                  padding: const EdgeInsets.all(Constants.DEFAULT_PADDING),
                  child: Column(
                    children: <Widget>[
                      CustomTitleBar(titleName: ('titleName_21').tr()),
                      Image.asset(
                        'assets/images/logo.png',
                        height: 150,
                        width: 150,
                      ),
                      Text(profileData),
                      Container(
                        width: double.infinity,
                        height: 48,
                        margin: const EdgeInsets.only(top: 10, bottom: 10),
                        child: OutlinedButton(
                            onPressed: () => {popupApi()},
                            child: Text(('get_account_information').tr())),
                      ),
                    ],
                  )),
            )));
  }
}
