import 'package:flutter/material.dart';

class AdList extends StatefulWidget {
  const AdList({Key? key}) : super(key: key);

  @override
  AdListState createState() => AdListState();
}

class AdListState extends State<AdList> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Color pinkColor = const Color(0xFFE6A3B3);
  final Color lightPinkColor = const Color(0xFFF0B7C3);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '광고',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          indicatorColor: pinkColor,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
          tabs: const [
            Tab(text: '광고 요청'),
            Tab(text: '광고 리스트'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAdRequestTab(),
          _buildAdListTab(),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: pinkColor,
              minimumSize: const Size(double.infinity, 50),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
            ),
            child: const Text(
              '광고 등록 하기',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 광고 요청 static 구현
  Widget _buildAdRequestTab() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildAdRequestItem(
          title: '광고 문의 드려요.',
          name: '연정흠',
          date: '2024.09.06',
          status: '답변하기',
          isCompleted: false,
        ),
        const SizedBox(height: 16.0),
        _buildAdRequestItem(
          title: '광고는 어떻게 하나요?',
          name: '황지민',
          date: '2024.09.07',
          status: '완료',
          isCompleted: true,
        ),
      ],
    );
  }

  Widget _buildAdListTab() {
    return const Center(
      child: Text('광고 리스트 내용'),
    );
  }

  Widget _buildAdRequestItem({
    required String title,
    required String name,
    required String date,
    required String status,
    required bool isCompleted,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 14.0,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                date,
                style: const TextStyle(
                  fontSize: 12.0,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
            decoration: BoxDecoration(
              color: isCompleted ? Colors.transparent : pinkColor,
              borderRadius: BorderRadius.circular(12.0),
              border: isCompleted ? Border.all(color: lightPinkColor) : null,
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
                color: isCompleted ? lightPinkColor : Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
