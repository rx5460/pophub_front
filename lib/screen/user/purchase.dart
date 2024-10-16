import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pophub/model/goods_model.dart';
import 'package:pophub/model/user.dart';
import 'package:pophub/screen/alarm/alarm.dart';
import 'package:pophub/utils/api/delivery_api.dart';
import 'package:pophub/utils/log.dart';
import 'package:pophub/utils/utils.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PurchasePage extends StatefulWidget {
  final String api;
  final GoodsModel goods;
  final int? addressId;
  final int count;

  const PurchasePage(
      {super.key,
      required this.api,
      required this.goods,
      required this.addressId,
      required this.count});

  @override
  State<PurchasePage> createState() => _PurchasePageState();
}

class _PurchasePageState extends State<PurchasePage> {
  late final WebViewController _webViewController;
  String token = "";
  String profileData = "";

  Future<void> addDelivery() async {
    Map<String, dynamic> data = await DeliveryApi.postDelivery(
        User().userName,
        widget.addressId!,
        widget.goods.store,
        widget.goods.product,
        widget.goods.price,
        widget.count);

    if (!data.toString().contains("fail")) {
      if (mounted) {
        showAlert(context, ('payment').tr(), ('payment_was_successful').tr(),
            () async {
          // 결제 완료 알림
          String title = ('title_1').tr();
          String label = ('label').tr();
          final String time =
              DateFormat(('mm_month_dd_day_hh_hours_mm_minutes').tr())
                  .format(DateTime.now());

          final Map<String, String> alarmDetails = {
            'title': title,
            'label': label,
            'time': time,
            'active': 'true',
          };

          // 서버에 알람 추가
          await http.post(
            Uri.parse('http://3.233.20.5:3000/alarm/alarm_add'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'userName': User().userName,
              'type': 'orderAlarms',
              'alarmDetails': alarmDetails,
            }),
          );
          // 판매자 알람 추가
          final Map<String, String> sellerAlarmDetails = {
            'title': ('order_came_in').tr(),
            'label': ('orders_for_our_goods_have_arrived').tr(),
            'time': time,
            'active': 'true',
          };

          await http.post(
            Uri.parse('http://3.233.20.5:3000/alarm/seller_alarm_add'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'storeId': widget.goods.store,
              'type': 'orderAlarms',
              'alarmDetails': sellerAlarmDetails,
            }),
          );

          await const AlarmList().showNotification(alarmDetails['title']!,
              alarmDetails['label']!, alarmDetails['time']!);
          Navigator.of(context).pop();
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        });
      }
    } else {
      if (mounted) {
        showAlert(context, ('failure').tr(), ('payment_failed').tr(), () {
          Navigator.of(context).pop();
        });
      }
    }
  }

  @override
  void initState() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {},
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) async {
            /// 황지민 : 결제시 intent 버그를 막기위한 작업
            /// 2024/05/20 재 수정 ..
            ///
            Logger.debug("### ${request.url} efwaewaf");

            if (request.url.startsWith('intent')) {
              String parseUrl = request.url;
              if (parseUrl.contains("intent")) {
                parseUrl = parseUrl.replaceAll("intent", "kakaotalk");
              }
              launchUrlString(parseUrl);
              return NavigationDecision.prevent;
            } else if (request.url.contains("partner_user_id")) {
              addDelivery();

              return NavigationDecision.prevent;
            } else if (request.url.startsWith('http://localhost')) {
              showAlert(context, ('payment').tr(), ('payment_failed').tr(), () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              });
              return NavigationDecision.prevent;
            } else {
              return NavigationDecision.navigate;
            }
          },
        ),
      )
      ..loadRequest(
          Uri.parse(widget.api.toString().replaceAll("aInfo", "mInfo")));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      resizeToAvoidBottomInset: false,
      body: WebViewWidget(controller: _webViewController),
    ));
  }
}
