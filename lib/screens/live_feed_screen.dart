import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LiveFeedScreen extends StatelessWidget {
  const LiveFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade200, Colors.green.shade200],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              AppBar(
                title: Text('Live Feed'),
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red.withOpacity(0.2),
                        ),
                        child: Icon(Icons.live_tv, size: 80, color: Colors.red),
                      ),
                      SizedBox(height: 30),
                      Text(
                        'Live Stream Coming Soon!',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Stay tuned for our upcoming live events',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 40),
                      ElevatedButton.icon(
                        onPressed: () {
                          Get.snackbar('Live Stream', 'Feature coming soon!');
                        },
                        icon: Icon(Icons.notifications_active),
                        label: Text('Get Notified'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          padding: EdgeInsets.symmetric(
                              horizontal: 30, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
