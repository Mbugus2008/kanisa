// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:kanisa/Network/results.dart';
import 'package:kanisa/models/account_model.dart';
import 'package:kanisa/models/dimensions.dart';
import 'package:kanisa/models/payment.dart';
import 'package:kanisa/models/vote_head.dart';
import 'package:kanisa/services/logger.dart';

class ApiClient extends ChangeNotifier {
  final LoggerService logger = Get.find();
  String baseUrl = "http://trimline.co.ke:4006/api";
  //String baseUrl = "http://192.168.100.47:898/api";
  //String baseUrl = "http://192.168.1.118:898/api";
  //String baseUrl = "http://192.168.100.54:898/api";

  Future<http.Response> postdata(String url,
      {String? data, bool isPost = true}) async {
    http.Response response;
    try {
      logger.debug(data);
      final headers = {
        'Content-Type': 'application/json',
        'X-Client-Identifier': "kirigiti", // Custom header
      };
      logger.info('$baseUrl$url');
      logger.info("out: $data");
      if (isPost) {
        response = await http.post(Uri.parse('$baseUrl$url'),
            body: data, headers: headers);
      } else {
        response = await http.get(Uri.parse('$baseUrl$url'), headers: headers);
      }
      logger.debug(response.statusCode.toString());
      logger.debug(response.body);
    } catch (e) {
      logger.debug("Network exception: ${e.toString()}");
      response = http.Response(e.toString(), 400);
    }
    return response;
  }

  // Updated method to check if customer exists using phone number
  Future<Customer?> checkCustomerExists(String phoneNumber) async {
    var response = await postdata('/customer?phoneNo=$phoneNumber',
        data: null, isPost: true);
    if (response.statusCode == 200 && response.body.isNotEmpty) {
      Results<Customer> data = Results.fromJson(response.body,
          (item) => Customer.fromJson(item as Map<String, dynamic>));
      return data.Contents;
    } else {
      return null;
    }
  }

  // Method to register a new customer
  Future<Customer?> registerCustomer(Customer customer) async {
    var response = await postdata('/register-customer',
        data: json.encode(customer.toJson()), isPost: true);
    if (response.statusCode != 200) {
      throw Exception('Failed to register customer');
    }
    Results<Customer> data = Results.fromJson(response.body,
        (item) => Customer.fromJson(item as Map<String, dynamic>));

    return data.Contents;
  }

  // Method to fetch household members (children/spouse) for a primary member
  Future<List<Customer>> getHouseholdMembers(String primaryNo) async {
    try {
      logger.info('Fetching household members for primary: $primaryNo');
      var response = await postdata('/household-members?primaryNo=$primaryNo',
          data: null, isPost: false);

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        ListResults<Customer> results = ListResults<Customer>.fromJson(
            response.body,
            (item) => Customer.fromJson(item as Map<String, dynamic>));
        logger.info('Found ${results.Contents?.length ?? 0} household members');
        return results.Contents ?? [];
      }
      return [];
    } catch (e) {
      logger.error('Error fetching household members: $e');
      return [];
    }
  }

  Future<List<Dimension>> fetchDimensions() async {
    try {
      logger.info('Fetching dimensions from /dimensions endpoint');
      final response = await postdata('/dimensions',
          isPost: true, data: json.encode({"key": "value"}));

      logger.debug('Dimensions response status: ${response.statusCode}');
      logger.debug('Dimensions response body: ${response.body}');

      if (response.statusCode == 200) {
        ListResults<Dimension> results =
            ListResults<Dimension>.fromJson(response.body, Dimension.fromMap);
        logger.info(
            'Successfully loaded ${results.Contents?.length ?? 0} dimensions');
        return results.Contents ?? [];
      } else {
        logger
            .error('Failed to load dimensions: Status ${response.statusCode}');
        return [];
      }
    } catch (e) {
      logger.error('Error loading dimensions: $e');
      return [];
    }
  }

  // Payment API Methods

  /// Fetch available vote heads for payments
  Future<List<VoteHead>> fetchVoteHeads() async {
    try {
      logger.info('Fetching vote heads from /voteheads endpoint');
      final response = await postdata('/voteheads', isPost: false);

      logger.debug('Vote heads response status: ${response.statusCode}');
      logger.debug('Vote heads response body: ${response.body}');

      if (response.statusCode == 200) {
        ListResults<VoteHead> results =
            ListResults<VoteHead>.fromJson(response.body, VoteHead.fromJson);

        logger.info('Contents is null: ${results.Contents == null}');
        logger.info('Contents length: ${results.Contents?.length ?? 0}');

        // Debug: Log each vote head details
        if (results.Contents != null) {
          for (var vh in results.Contents!) {
            logger.debug(
                'Parsed VoteHead: code=${vh.code}, name=${vh.name}, isActive=${vh.isActive}');
          }
        }

        if (results.Contents == null || results.Contents!.isEmpty) {
          logger.warning(
              'API returned empty/null vote heads, using predefined list');
          final predefined = PredefinedVoteHeads.getDefaultVoteHeads();
          logger.info('Predefined list size: ${predefined.length}');
          return predefined;
        } else {
          logger.info(
              'Successfully loaded ${results.Contents!.length} vote heads from API');
          return results.Contents!;
        }
      } else {
        logger
            .error('Failed to fetch vote heads: Status ${response.statusCode}');
        logger.info('Using predefined vote heads as fallback');
        final predefined = PredefinedVoteHeads.getDefaultVoteHeads();
        logger.info('Predefined list size: ${predefined.length}');
        return predefined;
      }
    } catch (e) {
      logger.error('Failed to fetch vote heads: $e');
      logger.info('Using predefined vote heads as fallback');
      final predefined = PredefinedVoteHeads.getDefaultVoteHeads();
      logger.info('Predefined list size: ${predefined.length}');
      return predefined;
    }
  }

  /// Initiate M-Pesa STK Push payment
  Future<MpesaStkResponse?> initiateMpesaPayment(
      PaymentRequest paymentRequest) async {
    try {
      logger.info(
          'Initiating M-Pesa payment for ${paymentRequest.mobile}: KES ${paymentRequest.amount}');

      final response = await postdata('/pushstk',
          data: json.encode(paymentRequest.toJson()), isPost: true);

      if (response.statusCode == 200) {
        Results<MpesaStkResponse> result = Results.fromJson(response.body,
            (item) => MpesaStkResponse.fromJson(item as Map<String, dynamic>));

        if (result.Code == 0 && result.Contents != null) {
          logger.info('M-Pesa STK push successful: ${result.Desc}');
          logger
              .info('CheckoutRequestID: ${result.Contents?.checkoutRequestID}');
          return result.Contents;
        } else {
          logger.error('M-Pesa payment failed: ${result.Desc}');
          return null;
        }
      } else {
        logger.error(
            'M-Pesa payment initiation failed: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      logger.error('M-Pesa payment initiation error: $e');
      return null;
    }
  }

  /// Initiate M-Pesa STK Push payment for multiple items
  Future<MpesaStkResponse?> initiateMultipleMpesaPayment(
      MultiplePaymentRequest multiplePaymentRequest) async {
    try {
      logger.info(
          'Initiating multiple M-Pesa payment for ${multiplePaymentRequest.phoneNumber}: KES ${multiplePaymentRequest.totalAmount}');
      logger.info(
          'Payment items count: ${multiplePaymentRequest.paymentItems?.length ?? 0}');

      final response = await postdata('/pushstk',
          data: json.encode(multiplePaymentRequest.toJson()), isPost: true);

      if (response.statusCode == 200) {
        Results<MpesaStkResponse> result = Results.fromJson(response.body,
            (item) => MpesaStkResponse.fromJson(item as Map<String, dynamic>));

        if (result.Code == 0 && result.Contents != null) {
          logger.info('Multiple M-Pesa STK push successful: ${result.Desc}');
          logger
              .info('CheckoutRequestID: ${result.Contents?.checkoutRequestID}');
          return result.Contents;
        } else {
          logger.error('Multiple M-Pesa payment failed: ${result.Desc}');
          return null;
        }
      } else {
        logger.error(
            'Multiple M-Pesa payment initiation failed: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      logger.error('Multiple M-Pesa payment initiation error: $e');
      return null;
    }
  }

  /// Check M-Pesa payment status
  Future<Payment?> checkPaymentStatus(String checkoutRequestId) async {
    try {
      final response = await postdata(
          '/stkstatus?checkoutRequestID=$checkoutRequestId',
          isPost: false);

      if (response.statusCode == 200) {
        Results<Payment> result = Results.fromJson(response.body,
            (item) => Payment.fromJson(item as Map<String, dynamic>));
        return result.Contents;
      } else {
        logger.warning('Payment status check failed: ${response.body}');
        return null;
      }
    } catch (e) {
      logger.error('Payment status check error: $e');
      return null;
    }
  }

  /// Fetch payment history for a customer
  Future<List<Payment>> fetchPaymentHistory(String customerNo,
      {int? limit, int? offset}) async {
    try {
      String endpoint = '/payments/history?customerNo=$customerNo';
      if (limit != null) endpoint += '&limit=$limit';
      if (offset != null) endpoint += '&offset=$offset';

      final response = await postdata(endpoint, isPost: false);

      if (response.statusCode == 200) {
        ListResults<Payment> results =
            ListResults<Payment>.fromJson(response.body, Payment.fromJson);
        return results.Contents ?? [];
      } else {
        logger.warning('Payment history fetch failed: ${response.body}');
        return [];
      }
    } catch (e) {
      logger.error('Payment history fetch error: $e');
      return [];
    }
  }

  /// Submit a payment record (for cash or bank payments)
  Future<Payment?> submitPayment(Payment payment) async {
    try {
      final response = await postdata('/payments/submit',
          data: json.encode(payment.toJson()), isPost: true);

      if (response.statusCode == 200) {
        Results<Payment> result = Results.fromJson(response.body,
            (item) => Payment.fromJson(item as Map<String, dynamic>));
        return result.Contents;
      } else {
        logger.error('Payment submission failed: ${response.body}');
        return null;
      }
    } catch (e) {
      logger.error('Payment submission error: $e');
      return null;
    }
  }

  /// Add payment document after successful M-Pesa payment
  Future<bool> addPayment(PaymentDocument paymentDocument) async {
    try {
      logger.info('Submitting payment document to /addpayment');
      logger.info('Document No: ${paymentDocument.documentNo}');
      logger.info('Member No: ${paymentDocument.memberNo}');
      logger.info('Total Amount: ${paymentDocument.amount}');
      logger.info(
          'Payment Details Count: ${paymentDocument.paymentDetailsList?.length ?? 0}');

      final response = await postdata('/addpayment',
          data: json.encode(paymentDocument.toJson()), isPost: true);

      if (response.statusCode == 200) {
        logger
            .info('Payment document submitted successfully: ${response.body}');
        return true;
      } else {
        logger.error(
            'Payment document submission failed: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      logger.error('Payment document submission error: $e');
      return false;
    }
  }
}

class ApiService extends GetxService {
  Future<ApiService> init() async {
    // Initialize your API service here
    print('ApiService initialized');
    return this;
  }

  // ... other API methods
}
