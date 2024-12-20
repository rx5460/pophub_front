// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:pophub/assets/constants.dart';
// import 'package:pophub/model/user.dart';

// class AlarmList extends StatefulWidget {
//   final String? payload;
//   const AlarmList({super.key, this.payload});

//   @override
//   State<AlarmList> createState() => AlarmListState();

//   Future<void> showNotification(String title, String body, String time) async {
//     var androidDetails = const AndroidNotificationDetails(
//       "channelId",
//       "Local Notification",
//       channelDescription: "Your description",
//       importance: Importance.high,
//     );
//     var generalDetails = NotificationDetails(android: androidDetails);
//     await FlutterLocalNotificationsPlugin().show(
//       0,
//       title,
//       body,
//       generalDetails,
//       payload: time,
//     );
//   }
// }

// class AlarmListState extends State<AlarmList>
//     with SingleTickerProviderStateMixin {
//   TabController? _tabController;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//     if (widget.payload != null) {}
//   }

//   Future<void> showNotification(String title, String body, String time) async {
//     var androidDetails = const AndroidNotificationDetails(
//       "channelId",
//       "Local Notification",
//       channelDescription: "Your description",
//       importance: Importance.high,
//     );
//     var generalDetails = NotificationDetails(android: androidDetails);
//     await FlutterLocalNotificationsPlugin()
//         .show(0, title, body, generalDetails);
//   }

//   @override
//   void dispose() {
//     _tabController?.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           ('alarm').tr(),
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         centerTitle: true,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios),
//           onPressed: () => Navigator.pop(context),
//         ),
//         bottom: TabBar(
//           controller: _tabController,
//           dividerColor: Constants.DEFAULT_COLOR,
//           indicatorColor: Constants.DEFAULT_COLOR,
//           indicatorWeight: 3.5,
//           indicatorSize: TabBarIndicatorSize.label,
//           labelColor: Colors.black,
//           labelStyle: const TextStyle(fontSize: 20),
//           tabs: [
//             Tab(
//                 child: SizedBox(
//               width: MediaQuery.of(context).size.width * 0.33,
//               child: const Center(child: Text(('_selectedCategory').tr())),
//             )),
//             Tab(
//                 child: SizedBox(
//               width: MediaQuery.of(context).size.width * 0.33,
//               child: const Center(child: Text(('value').tr())),
//             )),
//             Tab(
//                 child: SizedBox(
//               width: MediaQuery.of(context).size.width * 0.33,
//               child: const Center(child: Text(('value_1').tr())),
//             )),
//           ],
//         ),
//       ),
//       body: TabBarView(
//         controller: _tabController,
//         children: [
//           buildAlarmList('alarms'),
//           buildAlarmList('orderAlarms'),
//           buildAlarmList('waitAlarms'),
//         ],
//       ),
//     );
//   }

//   Widget buildAlarmList(String collection) {
//     return StreamBuilder<QuerySnapshot>(
//       stream: FirebaseFirestore.instance
//           .collection('users')
//           .doc(User().userName)
//           .collection(collection)
//           .snapshots(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }
//         if (snapshot.hasError) {
//           return Text('Error: ${snapshot.error}');
//         }
//         if (!snapshot.hasData) {
//           return Text('No data available');
//         }
//         return ListView(
//           children: snapshot.data!.docs.map((document) {
//             var data = document.data() as Map<String, dynamic>;
//             return Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   ClipRRect(
//                     borderRadius: BorderRadius.circular(10.0),
//                     child: SizedBox(
//                       width: 65,
//                       child: AspectRatio(
//                         aspectRatio: 1,
//                         child: data['imageUrl'] != null
//                             ? Image.network(
//                                 data['imageUrl'],
//                                 fit: BoxFit.cover,
//                               )
//                             : Image.asset(
//                                 'assets/images/logo.png',
//                                 fit: BoxFit.cover,
//                               ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 15),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: <Widget>[
//                         Text(
//                           data['title'] ?? 'No title',
//                           style: const TextStyle(fontWeight: FontWeight.bold),
//                         ),
//                         Text(data['label'] ?? 'No label'),
//                         Text(data['time'] ?? 'No time'),
//                       ],
//                     ),
//                   ),
//                   IconButton(
//                     icon: const Icon(Icons.close),
//                     onPressed: () {
//                       document.reference.delete();
//                     },
//                   ),
//                 ],
//               ),
//             );
//           }).toList(),
//         );
//       },
//     );
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pophub/model/user.dart';

class AlarmList extends StatefulWidget {
  final String? payload;
  const AlarmList({super.key, this.payload});

  @override
  State<AlarmList> createState() => AlarmListState();

  Future<void> showNotification(String title, String body, String time) async {
    var androidDetails = const AndroidNotificationDetails(
      "channelId",
      "Local Notification",
      channelDescription: "Your description",
      importance: Importance.high,
    );
    var generalDetails = NotificationDetails(android: androidDetails);
    await FlutterLocalNotificationsPlugin().show(
      0,
      title,
      body,
      generalDetails,
      payload: time,
    );
  }
}

class AlarmListState extends State<AlarmList> {
  @override
  void initState() {
    super.initState();
    if (widget.payload != null) {}
  }

  Future<void> showNotification(String title, String body, String time) async {
    var androidDetails = const AndroidNotificationDetails(
      "channelId",
      "Local Notification",
      channelDescription: "Your description",
      importance: Importance.high,
    );
    var generalDetails = NotificationDetails(android: androidDetails);
    await FlutterLocalNotificationsPlugin()
        .show(0, title, body, generalDetails);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          ('alarm').tr(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: buildAlarmList(),
    );
  }

  Widget buildAlarmList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(User().userName)
          .collection('alarms')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (!snapshot.hasData) {
          return Text('No data available');
        }
        return ListView(
          children: snapshot.data!.docs.map((document) {
            var data = document.data() as Map<String, dynamic>;
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: SizedBox(
                      width: 65,
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: data['imageUrl'] != null
                            ? Image.network(
                                data['imageUrl'],
                                fit: BoxFit.cover,
                              )
                            : Image.asset(
                                'assets/images/logo.png',
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          data['title'] ?? 'No title',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(data['label'] ?? 'No label'),
                        Text(data['time'] ?? 'No time'),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      document.reference.delete();
                    },
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
