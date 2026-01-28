import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kanisa/Network/Apis.dart';
import 'package:kanisa/models/account_model.dart';
import 'package:kanisa/models/payment.dart';
import 'package:kanisa/models/vote_head.dart';
import 'package:kanisa/services/logger.dart';

class VoteHeadSelection {
  final VoteHead voteHead;
  final double amount;
  final bool isSelected;

  VoteHeadSelection({
    required this.voteHead,
    required this.amount,
    this.isSelected = false,
  });

  VoteHeadSelection copyWith({
    VoteHead? voteHead,
    double? amount,
    bool? isSelected,
  }) {
    return VoteHeadSelection(
      voteHead: voteHead ?? this.voteHead,
      amount: amount ?? this.amount,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}

class PaymentController extends GetxController {
  final LoggerService logger = Get.find();
  final ApiClient apiClient = ApiClient();

  // Observable properties
  var isLoading = false.obs;
  var voteHeads = <VoteHead>[].obs;
  var paymentHistory = <Payment>[].obs;
  var selectedVoteHeads = <VoteHeadSelection>[].obs;
  var totalPaymentAmount = 0.0.obs;
  var currentPayment = Rx<Payment?>(null);
  var stkPushInProgress = false.obs;
  var stkResponse = Rx<MpesaStkResponse?>(null);
  var currentCustomer = Rx<Customer?>(null);

  // Timer for checking payment status
  Timer? _statusCheckTimer;

  @override
  void onInit() {
    super.onInit();
    fetchVoteHeads();
  }

  @override
  void onClose() {
    _statusCheckTimer?.cancel();
    super.onClose();
  }

  /// Fetch available vote heads
  void fetchVoteHeads() async {
    try {
      isLoading(true);
      var fetchedVoteHeads = await apiClient.fetchVoteHeads();
      logger.info('Received ${fetchedVoteHeads.length} vote heads from API');

      // Debug: print all codes
      logger.info(
          'Vote head codes: ${fetchedVoteHeads.map((vh) => vh.code).toList()}');

      // If we got exactly 4 vote heads, check if it's the predefined list
      // by checking if first item has code 'DISTRICT REGISTRATIO'
      bool isPredefinedList = fetchedVoteHeads.length == 4 &&
          fetchedVoteHeads.any((vh) => vh.code == 'DISTRICT REGISTRATIO');

      logger.info('Is predefined list: $isPredefinedList');

      List<VoteHead> finalVoteHeads;
      if (isPredefinedList) {
        // Don't filter predefined list, show all
        logger.info(
            'Using predefined list - showing all vote heads without filter');
        finalVoteHeads = fetchedVoteHeads;
      } else {
        // Filter API results to only active ones
        finalVoteHeads =
            fetchedVoteHeads.where((vh) => vh.isActive == true).toList();
        logger.info(
            'Filtered to ${finalVoteHeads.length} active vote heads from API');
      }

      voteHeads.assignAll(finalVoteHeads);
      logger.info('Assigned ${voteHeads.length} vote heads to observable list');
    } catch (e) {
      logger.error('Error fetching vote heads: $e');
      Get.snackbar(
        'Error',
        'Failed to load payment options. Using default options.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    } finally {
      isLoading(false);
    }
  }

  /// Toggle vote head selection
  void toggleVoteHeadSelection(VoteHead voteHead) {
    final existingIndex = selectedVoteHeads
        .indexWhere((selection) => selection.voteHead.code == voteHead.code);

    if (existingIndex >= 0) {
      // Remove if already selected
      selectedVoteHeads.removeAt(existingIndex);
    } else {
      // Add new selection with default amount
      final defaultAmount = voteHead.defaultAmount ?? 0.0;
      selectedVoteHeads.add(VoteHeadSelection(
        voteHead: voteHead,
        amount: defaultAmount,
        isSelected: true,
      ));
    }

    _updateTotalAmount();
  }

  /// Update amount for a specific vote head
  void updateVoteHeadAmount(String voteHeadCode, double amount) {
    final index = selectedVoteHeads
        .indexWhere((selection) => selection.voteHead.code == voteHeadCode);

    if (index >= 0) {
      selectedVoteHeads[index] =
          selectedVoteHeads[index].copyWith(amount: amount);
      _updateTotalAmount();
    }
  }

  /// Calculate and update total payment amount
  void _updateTotalAmount() {
    final total = selectedVoteHeads.fold<double>(
        0, (sum, selection) => sum + selection.amount);
    totalPaymentAmount.value = total;
  }

  /// Check if a vote head is selected
  bool isVoteHeadSelected(VoteHead voteHead) {
    return selectedVoteHeads
        .any((selection) => selection.voteHead.code == voteHead.code);
  }

  /// Get amount for a specific vote head
  double getVoteHeadAmount(String voteHeadCode) {
    final selection = selectedVoteHeads.firstWhereOrNull(
        (selection) => selection.voteHead.code == voteHeadCode);
    return selection?.amount ?? 0.0;
  }

  /// Validate payment details
  String? validatePayment(Customer customer) {
    if (selectedVoteHeads.isEmpty) {
      return 'Please select at least one payment type';
    }
    if (totalPaymentAmount.value <= 0) {
      return 'Please enter valid amounts for selected payments';
    }
    if (customer.Phone_No == null || customer.Phone_No!.isEmpty) {
      return 'Phone number is required for M-Pesa payments';
    }
    return null;
  }

  /// Initiate M-Pesa STK Push payment
  Future<bool> initiatePayment(Customer customer) async {
    final validationError = validatePayment(customer);
    if (validationError != null) {
      Get.snackbar(
        'Validation Error',
        validationError,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    try {
      // Store customer for later use
      currentCustomer.value = customer;
      stkPushInProgress(true);

      // Generate document number/reference
      final documentNo = _generateReference();

      // Create payment description with vote heads
      final itemNames =
          selectedVoteHeads.map((s) => s.voteHead.name).join(', ');
      final description =
          'Payment for: $itemNames | Member: ${customer.Name ?? customer.No}';

      final multiplePaymentRequest = MultiplePaymentRequest(
        customerNo: customer.No,
        phoneNumber: _formatPhoneNumber(customer.Phone_No!),
        paymentItems: selectedVoteHeads
            .map((selection) => PaymentItem(
                  voteHeadCode: selection.voteHead.code,
                  voteHeadName: selection.voteHead.name,
                  amount: selection.amount,
                ))
            .toList(),
        totalAmount: totalPaymentAmount.value,
        description: description,
        reference: documentNo,
      );

      logger.info(
          'Initiating multiple M-Pesa payment: ${multiplePaymentRequest.toJson()}');

      final response =
          await apiClient.initiateMultipleMpesaPayment(multiplePaymentRequest);

      if (response != null && response.isSuccess) {
        stkResponse.value = response;

        Get.snackbar(
          'Payment Initiated',
          response.customerMessage ??
              'Please check your phone for M-Pesa prompt',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );

        // Start checking payment status using CheckoutRequestID
        if (response.checkoutRequestID != null) {
          _startStatusCheck(response.checkoutRequestID!);
        }
        return true;
      } else {
        Get.snackbar(
          'Payment Failed',
          response?.responseDescription ?? 'Failed to initiate payment',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      logger.error('Payment initiation error: $e');
      Get.snackbar(
        'Error',
        'Failed to initiate payment. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      stkPushInProgress(false);
    }
  }

  /// Start periodic status checking
  void _startStatusCheck(String checkoutRequestId) {
    _statusCheckTimer?.cancel();
    int attempts = 0;
    const maxAttempts = 30; // Check for 5 minutes (30 * 10 seconds)

    _statusCheckTimer =
        Timer.periodic(const Duration(seconds: 10), (timer) async {
      attempts++;

      try {
        final payment = await apiClient.checkPaymentStatus(checkoutRequestId);

        if (payment != null) {
          currentPayment.value = payment;

          if (payment.status == PaymentStatus.completed) {
            timer.cancel();
            _onPaymentSuccess(payment);
          } else if (payment.status == PaymentStatus.failed ||
              payment.status == PaymentStatus.cancelled) {
            timer.cancel();
            _onPaymentFailed(payment);
          }
        }

        if (attempts >= maxAttempts) {
          timer.cancel();
          _onPaymentTimeout();
        }
      } catch (e) {
        logger.warning('Status check error: $e');
        if (attempts >= maxAttempts) {
          timer.cancel();
          _onPaymentTimeout();
        }
      }
    });
  }

  /// Handle successful payment
  void _onPaymentSuccess(Payment payment) async {
    // Submit payment document to /addpayment
    await _submitPaymentDocument(payment);

    // Refresh payment history
    // TODO: Uncomment when payment history endpoint is ready
    // fetchPaymentHistory(payment.customerNo!);

    // Reset form
    _resetPaymentForm();

    // Show success message
    Get.snackbar(
      'Payment Successful',
      'Your payment of ${payment.formattedAmount} has been received. Receipt: ${payment.mpesaReceiptNumber}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 5),
    );

    // Close payment screen after a short delay
    await Future.delayed(const Duration(milliseconds: 1500));
    Get.back();
  }

  /// Submit payment document to /addpayment after successful M-Pesa payment
  Future<void> _submitPaymentDocument(Payment payment) async {
    try {
      // Use stored customer number, fallback to payment customer number
      final memberNo = currentCustomer.value?.No ?? payment.customerNo ?? '';

      // Create payment details list from selected vote heads
      final paymentDetailsList = selectedVoteHeads.map((selection) {
        return PaymentDetail(
          key: '',
          documentNo: payment.mpesaReceiptNumber ?? payment.reference ?? '',
          voteHead: selection.voteHead.code ?? '',
          amount: selection.amount,
          amountSpecified: true,
        );
      }).toList();

      // Create payment document with logged-in customer number
      final paymentDocument = PaymentDocument(
        paymentDetailsList: paymentDetailsList,
        key: '',
        documentNo: payment.reference ?? '',
        memberNo: memberNo,
        date: DateTime.now(),
        dateSpecified: true,
        time: DateTime.now(),
        timeSpecified: true,
        amount: totalPaymentAmount.value,
        amountSpecified: true,
      );

      logger.info(
          'Submitting payment document with ${paymentDetailsList.length} items');

      // Submit to /addpayment
      final success = await apiClient.addPayment(paymentDocument);

      if (success) {
        logger.info('Payment document submitted successfully');
      } else {
        logger.error('Failed to submit payment document');
        Get.snackbar(
          'Warning',
          'Payment successful but failed to record details. Please contact support.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
      }
    } catch (e) {
      logger.error('Error submitting payment document: $e');
    }
  }

  /// Handle failed payment
  void _onPaymentFailed(Payment payment) {
    Get.snackbar(
      'Payment Failed',
      'Your payment could not be processed. Please try again.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 5),
    );
  }

  /// Handle payment timeout
  void _onPaymentTimeout() {
    Get.snackbar(
      'Payment Status Unknown',
      'We could not verify your payment status. Please check your M-Pesa messages or contact support.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      duration: const Duration(seconds: 8),
    );
  }

  /// Fetch payment history for customer
  void fetchPaymentHistory(String customerNo) async {
    try {
      isLoading(true);
      var history = await apiClient.fetchPaymentHistory(customerNo, limit: 50);
      paymentHistory.assignAll(history);
      logger.info('Fetched ${history.length} payment records');
    } catch (e) {
      logger.error('Error fetching payment history: $e');
      Get.snackbar(
        'Error',
        'Failed to load payment history',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading(false);
    }
  }

  /// Reset payment form
  void _resetPaymentForm() {
    selectedVoteHeads.clear();
    totalPaymentAmount.value = 0.0;
    currentPayment.value = null;
    stkResponse.value = null;
  }

  /// Format phone number for M-Pesa (ensure it starts with 254)
  String _formatPhoneNumber(String phoneNumber) {
    String cleaned = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

    if (cleaned.startsWith('0')) {
      cleaned = '254${cleaned.substring(1)}';
    } else if (cleaned.startsWith('254')) {
      // Already formatted
    } else if (cleaned.startsWith('7') || cleaned.startsWith('1')) {
      cleaned = '254$cleaned';
    }

    return cleaned;
  }

  /// Generate payment reference
  String _generateReference() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'KNS$timestamp';
  }

  /// Get vote heads by category
  List<VoteHead> getVoteHeadsByCategory(String category) {
    return voteHeads.where((vh) => vh.category == category).toList();
  }

  /// Get all categories
  List<String> getCategories() {
    return voteHeads.map((vh) => vh.category ?? 'Other').toSet().toList()
      ..sort();
  }
}
