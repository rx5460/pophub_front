import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pophub/model/user.dart';
import 'package:pophub/screen/alarm/alarm_page.dart';
import 'package:pophub/screen/custom/custom_title_bar.dart';
import 'package:pophub/screen/store/store_list_page.dart';
import 'package:pophub/utils/api.dart';
import 'package:pophub/utils/log.dart';
import 'package:http/http.dart' as http;

class PendingRejectPage extends StatefulWidget {
  String id = "";
  PendingRejectPage({super.key, required this.id});

  @override
  State<PendingRejectPage> createState() => _PendingRejectPageState();
}

class _PendingRejectPageState extends State<PendingRejectPage> {
  TextEditingController denyController = TextEditingController();

  Future<void> popupStoreDeny() async {
    try {
      final response = await Api.popupDeny(widget.id, denyController.text);
      final applicantUsername = response.toString();

      if (applicantUsername.isNotEmpty && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('거절 완료되었습니다.'),
          ),
        );

        final alarmDetails = {
          'title': '팝업 거절 완료',
          'label': '당사의 팝업 등록이 거절되었습니다.',
          'time': DateFormat('MM월 dd일 HH시 mm분').format(DateTime.now()),
          'active': true,
          'storeId': widget.id,
        };

        // 서버에 알람 추가
        await http.post(
          Uri.parse('https://pophub-fa05bf3eabc0.herokuapp.com/alarm_add'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'userId': applicantUsername,
            'type': 'alarms',
            'alarmDetails': alarmDetails,
          }),
        );

        // Firestore에 알람 추가
        await FirebaseFirestore.instance
            .collection('users')
            .doc(applicantUsername)
            .collection('alarms')
            .add(alarmDetails);

        // 로컬 알림 발송
        await AlarmPage().showNotification(
            alarmDetails['title'], alarmDetails['label'], alarmDetails['time']);

        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('거절 완료되었습니다.'),
          ),
        );
        Navigator.of(context).pop();
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const StoreListPage()));
      } else {
        Logger.debug("거절에 실패했습니다.");
      }
    } catch (error) {
      // 오류 처리
      Logger.debug('Error fetching popup data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomTitleBar(titleName: "승인 거절"),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '거절 사유',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              maxLines: 5,
              controller: denyController,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  popupStoreDeny();
                },
                child: const Text(
                  '완료',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
