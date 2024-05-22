import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pophub/screen/reservation/reserve_count.dart';

class ReserveDate extends StatefulWidget {
  final String popup;
  const ReserveDate({super.key, required this.popup});

  @override
  State<ReserveDate> createState() => _ReserveDateState();
}

class _ReserveDateState extends State<ReserveDate> {
  DateTime date = DateTime.now();

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
        title: const Text('예약하기'),
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
                top: screenHeight * 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '예약 날짜 및 시간을  ',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Text(
                  '설정해 주세요.',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(
                  height: screenHeight * 0.05,
                ),
                GestureDetector(
                  onTap: () async {
                    final DateTime? dateTime = await showDatePicker(
                        context: context,
                        initialDate: date,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(3000));
                    if (dateTime != null) {
                      setState(() {
                        date = dateTime;
                      });
                    }
                  },
                  child: Container(
                    width: screenWidth * 0.9,
                    height: screenHeight * 0.05,
                    decoration: BoxDecoration(
                      border: Border.all(width: 1, color: Colors.grey),
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(DateFormat("yyyy.MM.dd hh:mm").format(date)),
                          const Icon(
                            Icons.keyboard_arrow_down_outlined,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: screenWidth * 0.8,
            height: screenHeight * 0.08,
            child: OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ReserveCount(
                            date: date,
                            popup: widget.popup,
                          )),
                );
              },
              child: const Text('다음'),
            ),
          ),
        ],
      ),
    );
  }
}