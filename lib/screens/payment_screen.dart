import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kanisa/controllers/payment_controller.dart';
import 'package:kanisa/models/account_model.dart';
import 'package:kanisa/models/payment.dart';
import 'package:kanisa/models/vote_head.dart';

class PaymentScreen extends StatelessWidget {
  final Customer customer;
  final PaymentController paymentController = Get.find<PaymentController>();

  PaymentScreen({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Make Payment',
                style: GoogleFonts.lato(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(
              customer.Name ?? 'Unknown Member',
              style:
                  GoogleFonts.lato(fontSize: 13, fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade600, Colors.blue.shade50],
          ),
        ),
        child: Obx(() {
          if (paymentController.isLoading.value) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 16),
                  Text('Loading payment options...',
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Scrollable payment types list
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildPaymentTypeSelector(),
                      const SizedBox(height: 16),
                      _buildPaymentStatus(),
                    ],
                  ),
                ),
              ),
              // Fixed bottom section with summary and button
              _buildFixedBottomSection(),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildFixedBottomSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildAmountInput(),
              const SizedBox(height: 12),
              _buildPaymentButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentTypeSelector() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Payment Types',
                style: GoogleFonts.lato(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('You can select multiple items to pay at once',
                style: GoogleFonts.lato(
                    fontSize: 12, color: Colors.grey.shade600)),
            const SizedBox(height: 16),
            Obx(() {
              final categories = paymentController.getCategories();
              return Column(
                children: categories
                    .map((category) => _buildCategorySection(category))
                    .toList(),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection(String category) {
    final voteHeads = paymentController.getVoteHeadsByCategory(category);
    if (voteHeads.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(category,
              style: GoogleFonts.lato(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.blue.shade700,
              )),
        ),
        ...voteHeads.map((voteHead) => _buildVoteHeadTile(voteHead)),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildVoteHeadTile(VoteHead voteHead) {
    return Obx(() {
      final isSelected = paymentController.isVoteHeadSelected(voteHead);
      final currentAmount =
          paymentController.getVoteHeadAmount(voteHead.code ?? '');

      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.blue.shade600 : Colors.grey.shade300,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? Colors.blue.shade50 : Colors.white,
        ),
        child: Column(
          children: [
            ListTile(
              title: Text(voteHead.name ?? 'Unknown',
                  style: GoogleFonts.lato(fontWeight: FontWeight.w500)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (voteHead.description != null)
                    Text(voteHead.description!,
                        style: GoogleFonts.lato(
                            fontSize: 12, color: Colors.grey.shade600)),
                  if (voteHead.defaultAmount != null)
                    Text(
                        'Suggested: KES ${voteHead.defaultAmount!.toStringAsFixed(0)}',
                        style: GoogleFonts.lato(
                          fontSize: 12,
                          color: Colors.green.shade600,
                          fontWeight: FontWeight.w500,
                        )),
                ],
              ),
              trailing: Checkbox(
                value: isSelected,
                onChanged: (value) =>
                    paymentController.toggleVoteHeadSelection(voteHead),
                activeColor: Colors.blue.shade600,
              ),
              onTap: () => paymentController.toggleVoteHeadSelection(voteHead),
            ),
            if (isSelected)
              _buildAmountInputForVoteHead(voteHead, currentAmount),
          ],
        ),
      );
    });
  }

  Widget _buildAmountInputForVoteHead(VoteHead voteHead, double currentAmount) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(6),
          bottomRight: Radius.circular(6),
        ),
      ),
      child: Row(
        children: [
          Text('Amount: ',
              style: GoogleFonts.lato(fontWeight: FontWeight.w500)),
          const SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              initialValue: currentAmount.toStringAsFixed(0),
              decoration: InputDecoration(
                prefixText: 'KES ',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                enabled: voteHead.allowCustomAmount ?? true,
                suffixIcon: voteHead.allowCustomAmount == false
                    ? const Icon(Icons.lock, size: 16, color: Colors.grey)
                    : null,
              ),
              keyboardType: TextInputType.number,
              readOnly: voteHead.allowCustomAmount == false,
              onChanged: (value) {
                final amount = double.tryParse(value) ?? 0.0;
                paymentController.updateVoteHeadAmount(
                    voteHead.code ?? '', amount);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountInput() {
    return Obx(() {
      final hasSelection = paymentController.selectedVoteHeads.isNotEmpty;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: hasSelection ? Colors.blue.shade50 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasSelection ? Colors.blue.shade200 : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Payment Summary',
                    style: GoogleFonts.lato(
                        fontSize: 14, fontWeight: FontWeight.w600)),
                Text('${paymentController.selectedVoteHeads.length} item(s)',
                    style: GoogleFonts.lato(
                        fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
            const SizedBox(height: 8),

            // Show message when nothing selected, otherwise show items
            if (!hasSelection)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.info_outline,
                        size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 8),
                    Text(
                      'Select payment types above',
                      style: GoogleFonts.lato(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              )
            else ...[
              // Compact list of selected items (max 3 visible, then "and X more")
              ...paymentController.selectedVoteHeads
                  .take(3)
                  .map((selection) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(selection.voteHead.name ?? 'Unknown',
                                  style: GoogleFonts.lato(fontSize: 12)),
                            ),
                            Text('KES ${selection.amount.toStringAsFixed(0)}',
                                style: GoogleFonts.lato(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                )),
                          ],
                        ),
                      )),
              if (paymentController.selectedVoteHeads.length > 3)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                      '...and ${paymentController.selectedVoteHeads.length - 3} more',
                      style: GoogleFonts.lato(
                          fontSize: 11, color: Colors.grey.shade600)),
                ),
            ],

            const Divider(height: 16),
            // Total amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Amount:',
                    style: GoogleFonts.lato(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                Text(
                    'KES ${paymentController.totalPaymentAmount.value.toStringAsFixed(2)}',
                    style: GoogleFonts.lato(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: hasSelection
                          ? Colors.blue.shade700
                          : Colors.grey.shade600,
                    )),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildPaymentButton() {
    return Obx(() {
      final isProcessing = paymentController.stkPushInProgress.value;
      final hasSelection = paymentController.selectedVoteHeads.isNotEmpty;
      final hasAmount = paymentController.totalPaymentAmount.value > 0;
      final canPay = hasSelection && hasAmount && !isProcessing;

      return SizedBox(
        height: 56,
        child: ElevatedButton.icon(
          onPressed: canPay ? () => _initiatePayment() : null,
          icon: isProcessing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Icon(Icons.payment),
          label: Text(
            isProcessing ? 'Processing...' : 'Pay with M-Pesa',
            style: GoogleFonts.lato(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade600,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 4,
          ),
        ),
      );
    });
  }

  Widget _buildPaymentStatus() {
    return Obx(() {
      final stkResponse = paymentController.stkResponse.value;
      final currentPayment = paymentController.currentPayment.value;

      if (stkResponse == null && currentPayment == null) {
        return const SizedBox.shrink();
      }

      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Payment Status',
                  style: GoogleFonts.lato(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              if (stkResponse != null && currentPayment == null) ...[
                Row(
                  children: [
                    const CircularProgressIndicator(strokeWidth: 2),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Waiting for M-Pesa confirmation...\nPlease complete the payment on your phone.',
                        style: GoogleFonts.lato(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ],
              if (currentPayment != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:
                        _getStatusColor(currentPayment.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: _getStatusColor(currentPayment.status)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(_getStatusIcon(currentPayment.status),
                              color: _getStatusColor(currentPayment.status)),
                          const SizedBox(width: 8),
                          Text(currentPayment.statusDisplayName,
                              style: GoogleFonts.lato(
                                fontWeight: FontWeight.bold,
                                color: _getStatusColor(currentPayment.status),
                              )),
                        ],
                      ),
                      if (currentPayment.mpesaReceiptNumber != null) ...[
                        const SizedBox(height: 8),
                        Text('Receipt: ${currentPayment.mpesaReceiptNumber}',
                            style: GoogleFonts.lato(fontSize: 12)),
                      ],
                      const SizedBox(height: 4),
                      Text('Amount: ${currentPayment.formattedAmount}',
                          style: GoogleFonts.lato(fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    });
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

  void _initiatePayment() async {
    final success = await paymentController.initiatePayment(customer);
    if (!success) {
      // Error handling is done in the controller
    }
  }
}
