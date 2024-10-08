import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pophub/assets/constants.dart';
import 'package:pophub/model/user.dart';
import 'package:pophub/screen/alarm/alarm.dart';
import 'package:pophub/utils/api/reservation_api.dart';
import 'package:pophub/utils/utils.dart';

class ReserveCount extends StatefulWidget {
  final String date;
  final String popup;
  final String time;
  const ReserveCount(
      {super.key, required this.date, required this.popup, required this.time});

  @override
  State<ReserveCount> createState() => _ReserveCountState();
}

class _ReserveCountState extends State<ReserveCount> {
  int count = 1;

  Future<void> reservationApi() async {
    try {
      String userName = User().userName;
      Map<String, dynamic> data =
          await ReservationApi.postPopupReservationWithDetails(
              userName, widget.popup, widget.date, widget.time, count);

      if (data.toString().contains("fail")) {
        if (mounted) {
          // 예약 실패 알림 표시 및 대기 목록 추가 확인
          showAlert(context, "경고", "사전 예약에 실패했습니다. 대기 목록에 추가하시겠습니까?", () async {
            Navigator.of(context).pop();
            await addToWaitlist();
          });
        }
      } else {
        await sendAlarmAndNotification();
        print('예약 성공');
        if (mounted) {
          print('예약 성공 마운트');
          showAlert(context, "안내", "사전 예약에 성공했습니다.", () async {
            Navigator.pop(context);
            Navigator.pop(context);
          });
        }
      }
    } catch (e) {
      print('Error during reservation: $e');
      if (mounted) {
        showAlert(context, "오류", "예약 중 오류가 발생했습니다. 다시 시도해주세요.", () {
          Navigator.of(context).pop();
        });
      }
    }
  }

  Future<void> addToWaitlist() async {
    try {
      String userName = User().userName;
      final response = await http.post(
        Uri.parse('http://3.233.20.5:3000/alarm/waitlist_add'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userName': userName,
          'storeId': widget.popup,
          'date': widget.date,
          'desiredTime': widget.time,
        }),
      );

      if (response.statusCode == 201) {
        showAlert(context, "알림", "대기 목록에 성공적으로 추가되었습니다.", () {
          Navigator.of(context).pop();
        });
      } else {
        showAlert(context, "오류", "대기 목록 추가에 실패했습니다.", () {
          Navigator.of(context).pop();
        });
      }
    } catch (e) {
      print('Error during adding to waitlist: $e');
      showAlert(context, "오류", "대기 목록 추가 중 오류가 발생했습니다. 다시 시도해주세요.", () {
        Navigator.of(context).pop();
      });
    }
  }

  Future<void> sendAlarmAndNotification() async {
    final Map<String, String> alarmDetails = {
      'title': '사전 예약 완료',
      'label': '사전 예약이 성공적으로 완료되었습니다.',
      'time': DateFormat('MM월 dd일 HH시 mm분').format(DateTime.now()),
      'active': 'true',
    };

    // 서버에 알람 추가
    await http.post(
      Uri.parse('http://3.233.20.5:3000/alarm_add'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userName': User().userName,
        'type': 'alarms',
        'alarmDetails': alarmDetails,
      }),
    );

    // Firestore에 알람 추가
    await FirebaseFirestore.instance
        .collection('users')
        .doc(User().userName)
        .collection('alarms')
        .add(alarmDetails);

    // 로컬 알림 발송
    await const AlarmList().showNotification(
        alarmDetails['title']!, alarmDetails['label']!, alarmDetails['time']!);
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double screenWidth = screenSize.width;
    double screenHeight = screenSize.height;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          '예약하기',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(
                left: screenWidth * 0.05,
                right: screenWidth * 0.05,
                top: screenHeight * 0.02),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '방문할 인원을 선택해주세요.',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(
                  height: screenHeight * 0.04,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "인원수",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              if (count != 1) count -= 1;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                border:
                                    Border.all(width: 1, color: Colors.grey),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(20))),
                            child: const Icon(
                              Icons.remove,
                              size: 24,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 12, right: 12),
                          child: Text(
                            count.toString(),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              count += 1;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                border:
                                    Border.all(width: 1, color: Colors.grey),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(20))),
                            child: const Icon(
                              Icons.add,
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: screenWidth,
            height: screenHeight * 0.18,
            decoration: const BoxDecoration(
                border: Border(
                    top: BorderSide(
              width: 1,
              color: Constants.DEFAULT_COLOR,
            ))),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                      top: 12,
                      bottom: 16,
                      left: screenWidth * 0.05,
                      right: screenWidth * 0.05),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '방문 인원',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '총 $count 명',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      left: screenWidth * 0.05, right: screenWidth * 0.05),
                  child: SizedBox(
                    width: screenWidth * 0.9,
                    height: screenHeight * 0.07,
                    child: OutlinedButton(
                        onPressed: () {
                          reservationApi();
                        },
                        child: const Text(
                          '다음',
                          style: TextStyle(fontSize: 18),
                        )),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
