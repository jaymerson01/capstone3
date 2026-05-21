import 'package:flutter/material.dart';
import '../theme/app_color.dart';

class MyReportsPage extends StatelessWidget {
  const MyReportsPage({super.key});

  Widget logoBox() {
    return Container(
      height: 40,
      width: 40,
      padding: const EdgeInsets.all(3),
      color: Colors.white,
      child: Image.asset(
        'assets/images/logo.png',
        fit: BoxFit.contain,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.darkGreen,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(
          children: [
            logoBox(),
            const SizedBox(width: 10),
            const Text(
              "Safe Moonwalk My Report",
              style: TextStyle(color: Colors.white, fontSize: 15),
            ),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 15),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.grey),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text("My Reports", style: TextStyle(fontSize: 16)),
                const Spacer(),
                Container(
                  width: 90,
                  height: 28,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      SizedBox(width: 8),
                      Icon(Icons.search, size: 18),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                color: Colors.grey.shade300,
                child: Column(
                  children: [
                    Row(
                      children: [
                        filterButton("ALL", Colors.blue, Colors.white),
                        const SizedBox(width: 8),
                        filterButton("Pending", Colors.grey, Colors.black),
                        const SizedBox(width: 8),
                        filterButton("In Progress", Colors.grey, Colors.black),
                        const SizedBox(width: 8),
                        filterButton("Resolve", Colors.grey, Colors.black),
                      ],
                    ),
                    const SizedBox(height: 20),
                    reportBox(
                      title: "House Fire on St. Francis Compound",
                      time: "5 mins ago",
                      status: "Pending",
                    ),
                    const SizedBox(height: 22),
                    emptyBox(),
                    const SizedBox(height: 22),
                    emptyBox(),
                    const SizedBox(height: 22),
                    emptyBox(),
                    const SizedBox(height: 22),
                    emptyBox(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget filterButton(String text, Color color, Color textColor) {
    return Expanded(
      child: Container(
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: 11, color: textColor),
        ),
      ),
    );
  }

  Widget reportBox({
    required String title,
    required String time,
    required String status,
  }) {
    return Container(
      height: 60,
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        border: Border.all(color: Colors.black54),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 2,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "$title\n$time",
              style: const TextStyle(fontSize: 11),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.yellow,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(status, style: const TextStyle(fontSize: 10)),
          ),
        ],
      ),
    );
  }

  Widget emptyBox() {
    return Container(
      height: 60,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        border: Border.all(color: Colors.black54),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 2,
            offset: Offset(2, 2),
          ),
        ],
      ),
    );
  }
}