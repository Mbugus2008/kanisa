import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kanisa/Network/Apis.dart';
import 'package:kanisa/models/account_model.dart';
import 'package:kanisa/screens/registration_screen.dart';
import 'package:kanisa/screens/sermons_detail_screen.dart';
import 'package:kanisa/screens/events_detail_screen.dart';
import 'package:kanisa/screens/live_feed_screen.dart';
import 'package:kanisa/screens/bible_screen.dart';
import 'package:kanisa/screens/my_account_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Welcome extends StatelessWidget {
  Welcome({super.key});

  final List<String> imgList = [
    'assets/Image1.jpg',
    'assets/Image2.jpg',
    'assets/Image3.jpg',
  ];

  final controller = Get.put(CarouselController());

  @override
  Widget build(BuildContext context) {
    // clearPreferences();
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.lightBlue.shade200,
              Colors.lightGreen.shade200,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  padding: EdgeInsets.all(16),
                  child: PictureSlider(imgList: imgList),
                ),
              ),
              Expanded(
                flex: 5,
                child: GridView.count(
                  crossAxisCount: 2,
                  padding: EdgeInsets.all(16),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.5,
                  children: [
                    MenuCard(
                        name: 'Sermons',
                        icon: Icons.church_outlined,
                        onTap: () => _handleMenuItemTap('Sermons', context)),
                    MenuCard(
                        name: 'Events',
                        icon: Icons.event_available_outlined,
                        onTap: () => _handleMenuItemTap('Events', context)),
                    MenuCard(
                        name: 'Live Feed',
                        icon: Icons.live_tv,
                        onTap: () => _handleMenuItemTap('Live Feed', context)),
                    MenuCard(
                        name: 'Bible',
                        icon: Icons.bookmark_add_outlined,
                        onTap: () => _handleMenuItemTap('Bible', context)),
                    MenuCard(
                        name: 'My Account',
                        icon: Icons.account_circle_outlined,
                        onTap: () => _handleMenuItemTap('My Account', context)),
                  ],
                ),
              ),
              Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Get.to(() => RegistrationScreen());
                      },
                      child: Text("Join Us"),
                    ),
                    // Other UI elements or buttons
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String?> checkPhoneNumber(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? phoneNumber = prefs.getString('phone_number');
    phoneNumber ??= await promptForPhoneNumber(context);
    return phoneNumber;
    //   else {
    //  ApiClient().checkCustomerExists(phoneNumber);
    //       Get.to(() => MyAccountScreen(customer: Customer()));
    //   }
  }

  final TextEditingController phoneController = TextEditingController();

  Future<String?> promptForPhoneNumber(BuildContext context) async {
    String? enteredPhoneNumber;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Enter Phone Number"),
          content: TextFormField(
            controller: phoneController,
            decoration: InputDecoration(
              hintText: "Phone Number",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: Icon(Icons.phone),
            ),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a phone number';
              }
              return null; // Return null to indicate the input is correct
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel", style: TextStyle(color: Colors.redAccent)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Submit"),
              onPressed: () {
                enteredPhoneNumber = phoneController.text;
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
    return enteredPhoneNumber;
  }

  Future<void> savePhoneNumber(String phoneNumber) async {
    if (phoneNumber.isNotEmpty) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('phone_number', phoneNumber);
      // Optionally navigate or refresh UI
    }
  }

  Future<void> clearPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Get.snackbar("Preferences Cleared", "All saved data has been removed.");
  }

  void _handleMenuItemTap(String item, BuildContext context) async {
    switch (item) {
      case 'Sermons':
        Get.to(() => SermonsDetailScreen(), transition: Transition.fadeIn);
        break;
      case 'Events':
        Get.to(() => EventsDetailScreen(), transition: Transition.fadeIn);
        break;
      case 'Live Feed':
        Get.to(() => LiveFeedScreen(), transition: Transition.fadeIn);
        break;
      case 'Bible':
        Get.to(() => BibleScreen(), transition: Transition.fadeIn);
        break;
      case 'My Account':
        // For operations that need async work, show loading
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Center(
              child: CircularProgressIndicator(),
            );
          },
        );

        try {
          String? pn = await checkPhoneNumber(context);
          if (pn != null) {
            Customer? customer = await ApiClient().checkCustomerExists(pn);
            // Close loading dialog
            Navigator.of(context, rootNavigator: true).pop();

            if (customer != null) {
              Get.to(() => MyAccountScreen(cust: customer),
                  transition: Transition.fadeIn);
              if (customer.Phone_No != null) {
                savePhoneNumber(customer.Phone_No ?? "");
              }
            } else {
              Get.to(() => RegistrationScreen(), transition: Transition.fadeIn);
            }
          } else {
            // Close loading dialog if phone number is null
            Navigator.of(context, rootNavigator: true).pop();
          }
        } catch (e) {
          // Close loading dialog on error
          Navigator.of(context, rootNavigator: true).pop();
          Get.snackbar('Error', 'Something went wrong: ${e.toString()}');
        }
        break;
      default:
        Get.snackbar('Coming Soon', 'This feature is not yet implemented');
    }
  }
}

class MenuCard extends StatelessWidget {
  final String name;
  final IconData icon;
  final VoidCallback onTap;

  const MenuCard({
    super.key,
    required this.name,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: _getIconColor(name), size: 28),
              const SizedBox(height: 6),
              Flexible(
                child: Text(
                  name,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 3),
              Flexible(
                child: Text(
                  _getPreviewText(name),
                  style: TextStyle(fontSize: 9, color: Colors.grey[600]),
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getIconColor(String name) {
    switch (name) {
      case 'Sermons':
        return Colors.purple;
      case 'Events':
        return Colors.orange;
      case 'Live Feed':
        return Colors.red;
      case 'Bible':
        return Colors.green;
      case 'My Account':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getPreviewText(String name) {
    switch (name) {
      case 'Sermons':
        return 'Listen to recent sermons';
      case 'Events':
        return 'View upcoming events';
      case 'Live Feed':
        return 'Watch live streams';
      case 'Bible':
        return 'Read the Holy Bible';
      case 'My Account':
        return 'Manage your profile';
      default:
        return '';
    }
  }
}

class PictureSlider extends StatelessWidget {
  final List<String> imgList;

  const PictureSlider({super.key, required this.imgList});

  @override
  Widget build(BuildContext context) {
    final ImageSliderController controller = Get.find();

    return Column(
      children: [
        Expanded(
          child: CarouselSlider(
            options: CarouselOptions(
              aspectRatio: 16 / 9,
              viewportFraction: 1,
              initialPage: 0,
              enableInfiniteScroll: true,
              reverse: false,
              autoPlay: true,
              autoPlayInterval: Duration(seconds: 5),
              autoPlayAnimationDuration: Duration(milliseconds: 800),
              autoPlayCurve: Curves.fastOutSlowIn,
              enlargeCenterPage: true,
              onPageChanged: (index, reason) {
                controller.changeImage(index);
              },
              scrollDirection: Axis.horizontal,
            ),
            items: imgList
                .map((item) => ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.asset(item, fit: BoxFit.cover, width: 1000),
                    ))
                .toList(),
          ),
        ),
        SizedBox(height: 8),
        Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: imgList.asMap().entries.map((entry) {
                return Container(
                  width: 8.0,
                  height: 8.0,
                  margin: EdgeInsets.symmetric(horizontal: 4.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue.shade700.withOpacity(
                        controller.currentImageIndex.value == entry.key
                            ? 0.9
                            : 0.4),
                  ),
                );
              }).toList(),
            )),
      ],
    );
  }
}

class ImageSliderController extends GetxController {
  var currentImageIndex = 0.obs;

  void changeImage(int index) {
    currentImageIndex.value = index;
  }
}
