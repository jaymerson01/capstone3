import 'package:flutter/material.dart';
import '../theme/app_color.dart';

class MapsPage extends StatelessWidget {
  const MapsPage({super.key});

  Widget appLogo() {
    return Container(
      height: 40,
      width: 40,
      padding: const EdgeInsets.all(3),
      color: Colors.white,
      child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
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
            appLogo(),
            const SizedBox(width: 10),
            const Text("Safe Moonwalk Maps",
                style: TextStyle(color: Colors.white, fontSize: 15)),
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
            const Text("Maps", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 15),
            Container(
              height: 330,
              width: double.infinity,
              color: Colors.grey.shade300,
              child: const Center(
                child: Icon(Icons.map, size: 150, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 35),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Text("G",
                    style: TextStyle(
                        color: Colors.blue,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                label: const Text("Continue with Google Maps"),
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}