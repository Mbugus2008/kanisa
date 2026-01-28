import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kanisa/Network/Apis.dart';
import 'package:kanisa/controllers/dimension_controller.dart';
import 'package:kanisa/controllers/payment_controller.dart';
import 'package:kanisa/models/account_model.dart';
import 'package:kanisa/screens/my_account_screen.dart';
import 'package:kanisa/screens/payment_history_screen.dart';
import 'package:kanisa/screens/payment_screen.dart';
import 'package:kanisa/screens/registration_screen.dart';
import 'package:kanisa/services/logger.dart';
import 'package:kanisa/splash.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Get.put(LoggerService(), permanent: true);
  Get.put(ImageSliderController());
  Get.put(DimensionController());
  Get.put(PaymentController());

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final ApiClient api = ApiClient();

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Kanisa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.blue,
          accentColor: Colors.green,
        ),
        useMaterial3: true,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Welcome(),
      getPages: [
        GetPage(
            name: '/myaccount', page: () => MyAccountScreen(cust: Customer())),
        GetPage(name: '/register', page: () => RegistrationScreen()),
        GetPage(
            name: '/payments', page: () => PaymentScreen(customer: Customer())),
        GetPage(
            name: '/payment-history',
            page: () => PaymentHistoryScreen(customer: Customer())),
      ],
    );
  }

  void navigateToAccount() async {
    String? phoneNumber = await getPhoneNumber();
    if (phoneNumber != null) {
      Customer? isRegistered = await api.checkCustomerExists(phoneNumber);
      if (isRegistered != null) {
        Get.to(() => MyAccountScreen(cust: isRegistered));
      } else {
        Get.to(() => RegistrationScreen());
      }
    } else {
      print("No phone number found in preferences.");
    }
  }

  Future<String?> getPhoneNumber() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('phone_number');
  }

  Future<Customer> fetchCustomerData(String phoneNumber) async {
    // Implement fetching customer data logic
    return Customer(); // Placeholder
  }
}
