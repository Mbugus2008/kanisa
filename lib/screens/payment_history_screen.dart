import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kanisa/controllers/payment_controller.dart';
import 'package:kanisa/models/account_model.dart';
import 'package:kanisa/models/payment.dart';

class PaymentHistoryScreen extends StatelessWidget {
  final Customer customer;
  final PaymentController paymentController = Get.find<PaymentController>();

  PaymentHistoryScreen({super.key, required this.customer}) {
    // Fetch payment history when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (customer.No != null) {
        paymentController.fetchPaymentHistory(customer.No!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment History',
            style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade600, Colors.blue.shade50],
          ),
        ),
        child: Column(
          children: [
            _buildCustomerHeader(),
            Expanded(
              child: Obx(() {
                if (paymentController.isLoading.value) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Colors.white),
                        SizedBox(height: 16),
                        Text('Loading payment history...',
                            style:
                                TextStyle(color: Colors.white, fontSize: 16)),
                      ],
                    ),
                  );
                }

                final payments = paymentController.paymentHistory;
                if (payments.isEmpty) {
                  return _buildEmptyState();
                }

                return _buildPaymentList(payments);
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.back(),
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.payment),
        label: const Text('Make Payment'),
      ),
    );
  }

  Widget _buildCustomerHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.person, color: Colors.blue.shade600, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(customer.Name ?? 'Unknown Member',
                    style: GoogleFonts.lato(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Member No: ${customer.No ?? 'N/A'}',
                    style: GoogleFonts.lato(
                        fontSize: 14, color: Colors.grey.shade600)),
                Text('Phone: ${customer.Phone_No ?? 'N/A'}',
                    style: GoogleFonts.lato(
                        fontSize: 14, color: Colors.grey.shade600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(Icons.payment_outlined,
                    size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text('No Payment History',
                    style: GoogleFonts.lato(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    )),
                const SizedBox(height: 8),
                Text(
                    'You haven\'t made any payments yet.\nStart by making your first payment!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lato(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentList(List<Payment> payments) {
    // Group payments by month
    final groupedPayments = <String, List<Payment>>{};
    for (final payment in payments) {
      final monthKey = payment.paymentDate != null
          ? '${payment.paymentDate!.year}-${payment.paymentDate!.month.toString().padLeft(2, '0')}'
          : 'unknown';
      groupedPayments.putIfAbsent(monthKey, () => []).add(payment);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: groupedPayments.keys.length,
      itemBuilder: (context, index) {
        final monthKey = groupedPayments.keys.elementAt(index);
        final monthPayments = groupedPayments[monthKey]!;
        return _buildMonthSection(monthKey, monthPayments);
      },
    );
  }

  Widget _buildMonthSection(String monthKey, List<Payment> payments) {
    final monthName = _getMonthName(monthKey);
    final totalAmount =
        payments.fold<double>(0, (sum, payment) => sum + (payment.amount ?? 0));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 16, bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(monthName,
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  )),
              Text('Total: KES ${totalAmount.toStringAsFixed(2)}',
                  style: GoogleFonts.lato(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade600,
                  )),
            ],
          ),
        ),
        ...payments.map((payment) => _buildPaymentCard(payment)),
      ],
    );
  }

  Widget _buildPaymentCard(Payment payment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: () => _showPaymentDetails(payment),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(payment.voteHeadName ?? 'Unknown Payment',
                          style: GoogleFonts.lato(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          )),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(payment.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: _getStatusColor(payment.status), width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_getStatusIcon(payment.status),
                              size: 14, color: _getStatusColor(payment.status)),
                          const SizedBox(width: 4),
                          Text(payment.statusDisplayName,
                              style: GoogleFonts.lato(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _getStatusColor(payment.status),
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(payment.formattedAmount,
                        style: GoogleFonts.lato(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade600,
                        )),
                    Text(payment.formattedDate,
                        style: GoogleFonts.lato(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        )),
                  ],
                ),
                if (payment.mpesaReceiptNumber != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.receipt,
                          size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text('Receipt: ${payment.mpesaReceiptNumber}',
                          style: GoogleFonts.lato(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          )),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPaymentDetails(Payment payment) {
    Get.dialog(
      AlertDialog(
        title: Text('Payment Details',
            style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Payment Type', payment.voteHeadName ?? 'N/A'),
              _buildDetailRow('Amount', payment.formattedAmount),
              _buildDetailRow('Status', payment.statusDisplayName),
              _buildDetailRow('Date', payment.formattedDate),
              if (payment.mpesaReceiptNumber != null)
                _buildDetailRow('M-Pesa Receipt', payment.mpesaReceiptNumber!),
              if (payment.phoneNumber != null)
                _buildDetailRow('Phone Number', payment.phoneNumber!),
              if (payment.description != null)
                _buildDetailRow('Description', payment.description!),
              if (payment.reference != null)
                _buildDetailRow('Reference', payment.reference!),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text('$label:',
                style: GoogleFonts.lato(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                )),
          ),
          Expanded(
            child: Text(value, style: GoogleFonts.lato(fontSize: 14)),
          ),
        ],
      ),
    );
  }

  String _getMonthName(String monthKey) {
    if (monthKey == 'unknown') return 'Unknown Date';

    final parts = monthKey.split('-');
    if (parts.length != 2) return monthKey;

    final year = int.tryParse(parts[0]) ?? 0;
    final month = int.tryParse(parts[1]) ?? 0;

    const monthNames = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];

    if (month >= 1 && month <= 12) {
      return '${monthNames[month]} $year';
    }

    return monthKey;
  }

  Color _getStatusColor(PaymentStatus? status) {
    switch (status) {
      case PaymentStatus.completed:
        return Colors.green;
      case PaymentStatus.processing:
      case PaymentStatus.pending:
        return Colors.orange;
      case PaymentStatus.failed:
      case PaymentStatus.cancelled:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(PaymentStatus? status) {
    switch (status) {
      case PaymentStatus.completed:
        return Icons.check_circle;
      case PaymentStatus.processing:
      case PaymentStatus.pending:
        return Icons.access_time;
      case PaymentStatus.failed:
      case PaymentStatus.cancelled:
        return Icons.error;
      default:
        return Icons.help;
    }
  }
}
