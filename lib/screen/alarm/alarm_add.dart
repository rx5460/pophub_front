import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AlarmAdd extends StatefulWidget {
  const AlarmAdd({Key? key}) : super(key: key);

  @override
  AlarmAddState createState() => AlarmAddState();
}

class AlarmAddState extends State<AlarmAdd> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  String _selectedCategory = '전체';

  Future<void> alarmNotification() async {
    String collection;
    switch (_selectedCategory) {
      case '주문':
        collection = 'orderAlarms';
        break;
      case '대기':
        collection = 'waitAlarms';
        break;
      default:
        collection = 'alarms';
    }

    try {
      String formattedTime =
          DateFormat('MM월 dd일 HH시 mm분').format(DateTime.now());

      // Firestore에 알림 저장
      await FirebaseFirestore.instance.collection(collection).add({
        'active': true,
        'label': _contentController.text,
        'time': formattedTime,
        'title': _titleController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('알림이 성공적으로 전송되었습니다.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('알림 전송에 실패했습니다. 다시 시도해주세요.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '알림',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '알림 제목',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '알림 제목을 입력하세요',
              ),
            ),
            const SizedBox(height: 16.0),
            const Text(
              '알림 카테고리',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              items: const [
                DropdownMenuItem<String>(
                  value: '전체',
                  child: Text('전체'),
                ),
                DropdownMenuItem<String>(
                  value: '주문',
                  child: Text('주문'),
                ),
                DropdownMenuItem<String>(
                  value: '대기',
                  child: Text('대기'),
                ),
              ],
              onChanged: (String? value) {
                setState(() {
                  _selectedCategory = value ?? '전체';
                });
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            const Text(
              '알림 내용',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            Expanded(
              child: TextField(
                controller: _contentController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: '알림 내용을 입력하세요',
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: alarmNotification,
                style: OutlinedButton.styleFrom(
                  backgroundColor: const Color(0xFFE6A3B3),
                  minimumSize: const Size(double.infinity, 50),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
                child: const Text(
                  '완료',
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}