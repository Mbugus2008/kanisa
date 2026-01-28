import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: Text(
              'Kanisa App',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            onTap: () => Get.offAllNamed('/'),
          ),
          ListTile(
            leading: Icon(Icons.church),
            title: Text('Sermons'),
            onTap: () => Get.toNamed('/sermons'),
          ),
          ListTile(
            leading: Icon(Icons.event),
            title: Text('Events'),
            onTap: () => Get.toNamed('/events'),
          ),
          ListTile(
            leading: Icon(Icons.live_tv),
            title: Text('Live Feed'),
            onTap: () => Get.toNamed('/live-feed'),
          ),
          ListTile(
            leading: Icon(Icons.book),
            title: Text('Bible'),
            onTap: () => Get.toNamed('/bible'),
          ),
          ListTile(
            leading: Icon(Icons.account_circle),
            title: Text('My Account'),
            onTap: () => Get.toNamed('/account'),
          ),
        ],
      ),
    );
  }
}
