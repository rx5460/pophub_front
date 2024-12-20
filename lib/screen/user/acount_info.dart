import 'dart:io' show File;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pophub/assets/constants.dart';
import 'package:pophub/model/user.dart';
import 'package:pophub/notifier/UserNotifier.dart';
import 'package:pophub/screen/custom/custom_title_bar.dart';
import 'package:pophub/screen/user/reset_passwd.dart';
import 'package:pophub/utils/api/user_api.dart';
import 'package:pophub/utils/log.dart';
import 'package:pophub/utils/utils.dart';
import 'package:provider/provider.dart';

class AcountInfo extends StatefulWidget {
  final VoidCallback refreshProfile;
  const AcountInfo({super.key, required this.refreshProfile});

  @override
  State<AcountInfo> createState() => _AcountInfoState();
}

class _AcountInfoState extends State<AcountInfo> {
  TextEditingController nicknameController = TextEditingController();
  String? nicknameInput;

  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  @override
  void initState() {
    super.initState();
    nicknameController.text = User().userName;
    nicknameInput = User().userName;
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedImage =
          await _picker.pickImage(source: ImageSource.gallery);
      if (pickedImage != null) {
        setState(() {
          _image = pickedImage;
        });
      }
    } catch (e) {
      Logger.debug('Error picking image: $e');
    }
  }

  String? fileName;
  bool checked = false;

  Future<void> nameCheckApi() async {
    Map<String, dynamic> data = await UserApi.getNameCheck(nicknameInput ?? '');

    if (mounted) {
      if (!data.toString().contains("Exists")) {
        showAlert(context, ('guide').tr(), ('nicknames_are_available').tr(),
            () {
          Navigator.of(context).pop();
        });
        setState(() {
          checked = true;
        });
      } else {
        showAlert(context, ('warning').tr(), ('nickname_is_duplicated').tr(),
            () {
          Navigator.of(context).pop();
        });
      }
    }
  }

  Future<void> profileModify() async {
    Map<String, dynamic> data =
        await UserApi.postProfileModify(User().userId, nicknameInput!);

    if (!data.toString().contains("fail")) {
      widget.refreshProfile;
      if (mounted) Navigator.of(context).pop();
    } else {}
  }

  Future<void> profileModifyImage() async {
    Map<String, dynamic> data = await UserApi.postProfileModifyImage(
        User().userId, nicknameInput!, File(_image!.path));

    if (!data.toString().contains("fail")) {
      widget.refreshProfile();
      closePage();
    } else {}
  }

  void closePage() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double screenWidth = screenSize.width;
    double screenHeight = screenSize.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomTitleBar(
        titleName: ('titleName_5').tr(),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: screenWidth * 0.4,
                          height: screenHeight * 0.2,
                          child: CircleAvatar(
                            backgroundImage: _image == null
                                ? User().file != ""
                                    ? FileImage(File(User().file))
                                    : const AssetImage('assets/images/logo.png')
                                        as ImageProvider
                                : FileImage(File(_image!.path))
                                    as ImageProvider,
                            radius: 1000,
                          ),
                        ),
                        Transform.translate(
                          offset: Offset(screenWidth * 0.2 - 18, -48),
                          child: GestureDetector(
                            onTap: () {
                              _pickImage();
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 1,
                                    color: Constants.DEFAULT_COLOR,
                                  ),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(50)),
                                  color: Colors.white),
                              child: const Padding(
                                padding: EdgeInsets.all(4.0),
                                child: Icon(
                                  Icons.settings_outlined,
                                  color: Colors.black,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: screenWidth * 0.9,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: nicknameController,
                          onChanged: (value) {
                            setState(() {
                              checked = false;
                              nicknameInput = value;
                            });
                          },
                          readOnly: checked,
                          decoration: InputDecoration(
                            labelText: User().userName,
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: screenWidth * 0.1,
                      ),
                      SizedBox(
                        width: screenWidth * 0.22,
                        height: screenHeight * 0.065,
                        child: OutlinedButton(
                          onPressed: () {
                            if (checked) {
                              setState(() {
                                checked = false;
                              });
                            } else if (nicknameInput != '') {
                              nameCheckApi();
                            }
                          },
                          child: Center(
                            child: Text(
                              checked
                                  ? ('correction').tr()
                                  : ('duplicate_check').tr(),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: screenHeight * 0.03,
                ),
                SizedBox(
                  width: screenWidth * 0.9,
                  height: screenHeight * 0.07,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MultiProvider(providers: [
                                    ChangeNotifierProvider(
                                        create: (_) => UserNotifier())
                                  ], child: const ResetPasswd())));
                    },
                    child: Center(
                      child: Text(
                        ('reset_password').tr(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: screenHeight * 0.03,
                ),
                Visibility(
                  visible: User().role == "General Member",
                  child: Container(
                    width: screenWidth * 0.9,
                    height: screenHeight * 0.07,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      border: Border.all(
                        width: 1,
                        color: Constants.BUTTON_GREY,
                      ),
                    ),
                    child: Center(
                      child: const Text(
                        'gender__',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ).tr(args: [User().gender]),
                    ),
                  ),
                ),
                SizedBox(
                  height: screenHeight * 0.03,
                ),
                Visibility(
                  visible: User().role == "General Member",
                  child: Container(
                    width: screenWidth * 0.9,
                    height: screenHeight * 0.07,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      border: Border.all(
                        width: 1,
                        color: Constants.BUTTON_GREY,
                      ),
                    ),
                    child: Center(
                      child: const Text(
                        'age__',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ).tr(args: [User().age.toString()]),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.1), // Added space for button
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: screenWidth * 0.9,
              height: screenHeight * 0.07,
              margin: const EdgeInsets.only(bottom: 15),
              child: OutlinedButton(
                onPressed: () {
                  if (checked) {
                    if (_image == null) {
                      profileModify();
                    } else {
                      profileModifyImage();
                    }
                  } else {
                    showAlert(context, ('warning').tr(),
                        ('please_check_for_duplicate_nicknames').tr(), () {
                      Navigator.of(context).pop();
                    });
                  }
                },
                child: Center(
                  child: Text(
                    ('edit').tr(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
