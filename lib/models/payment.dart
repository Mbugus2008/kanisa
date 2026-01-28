import 'package:intl/intl.dart';
import 'package:kanisa/Network/results.dart';

enum PaymentStatus { pending, processing, completed, failed, cancelled }

enum PaymentMethod { mpesa, cash, bank }

class Payment implements Tomaps {
  String? id;
  String? customerNo;
  String? customerName;
  String? voteHeadCode;
  String? voteHeadName;
  double? amount;
  PaymentStatus? status;
  PaymentMethod? paymentMethod;
  String? mpesaReceiptNumber;
  String? mpesaTransactionId;
  String? phoneNumber;
  DateTime? paymentDate;
  DateTime? createdAt;
  String? description;
  String? reference;

  Payment({
    this.id,
    this.customerNo,
    this.customerName,
    this.voteHeadCode,
    this.voteHeadName,
    this.amount,
    this.status,
    this.paymentMethod,
    this.mpesaReceiptNumber,
    this.mpesaTransactionId,
    this.phoneNumber,
    this.paymentDate,
    this.createdAt,
    this.description,
    this.reference,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] ?? json['Id'],
      customerNo: json['customerNo'] ?? json['CustomerNo'],
      customerName: json['customerName'] ?? json['CustomerName'],
      voteHeadCode: json['voteHeadCode'] ?? json['VoteHeadCode'],
      voteHeadName: json['voteHeadName'] ?? json['VoteHeadName'],
      amount: (json['amount'] ?? json['Amount'])?.toDouble(),
      status: _parsePaymentStatus(json['status'] ?? json['Status']),
      paymentMethod:
          _parsePaymentMethod(json['paymentMethod'] ?? json['PaymentMethod']),
      mpesaReceiptNumber:
          json['mpesaReceiptNumber'] ?? json['MpesaReceiptNumber'],
      mpesaTransactionId:
          json['mpesaTransactionId'] ?? json['MpesaTransactionId'],
      phoneNumber: json['phoneNumber'] ?? json['PhoneNumber'],
      paymentDate: (json['paymentDate'] ?? json['PaymentDate']) != null
          ? DateTime.parse(json['paymentDate'] ?? json['PaymentDate'])
          : null,
      createdAt: (json['createdAt'] ?? json['CreatedAt']) != null
          ? DateTime.tryParse(json['createdAt'] ?? json['CreatedAt'])
          : null,
      description: json['description'] ?? json['Description'],
      reference: json['reference'] ?? json['Reference'],
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerNo': customerNo,
      'customerName': customerName,
      'voteHeadCode': voteHeadCode,
      'voteHeadName': voteHeadName,
      'amount': amount,
      'status': status?.name,
      'paymentMethod': paymentMethod?.name,
      'mpesaReceiptNumber': mpesaReceiptNumber,
      'mpesaTransactionId': mpesaTransactionId,
      'phoneNumber': phoneNumber,
      'paymentDate': paymentDate?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'description': description,
      'reference': reference,
    };
  }

  Map<String, dynamic> toJson() => toMap();

  static PaymentStatus? _parsePaymentStatus(String? status) {
    if (status == null) return null;

    // Handle backend variations
    final statusLower = status.toLowerCase();
    if (statusLower == 'success' || statusLower == 'successful') {
      return PaymentStatus.completed;
    }
    if (statusLower == 'failed' || statusLower == 'failure') {
      return PaymentStatus.failed;
    }

    return PaymentStatus.values.firstWhere(
      (e) => e.name == statusLower,
      orElse: () => PaymentStatus.pending,
    );
  }

  static PaymentMethod? _parsePaymentMethod(String? method) {
    if (method == null) return null;
    return PaymentMethod.values.firstWhere(
      (e) => e.name == method.toLowerCase(),
      orElse: () => PaymentMethod.mpesa,
    );
  }

  String get formattedAmount => 'KES ${amount?.toStringAsFixed(2) ?? '0.00'}';

  String get formattedDate {
    if (paymentDate == null) return 'N/A';
    return DateFormat('dd MMM yyyy, HH:mm').format(paymentDate!);
  }

  String get statusDisplayName {
    switch (status) {
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.processing:
        return 'Processing';
      case PaymentStatus.completed:
        return 'Completed';
      case PaymentStatus.failed:
        return 'Failed';
      case PaymentStatus.cancelled:
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  @override
  String toString() {
    return 'Payment{id: $id, voteHeadCode: $voteHeadCode, amount: $amount, status: $status}';
  }
}

class PaymentRequest implements Tomaps {
  String? mobile;
  String? documentNo;
  double? amount;
  String? description;

  PaymentRequest({
    this.mobile,
    this.documentNo,
    this.amount,
    this.description,
  });

  factory PaymentRequest.fromJson(Map<String, dynamic> json) {
    return PaymentRequest(
      mobile: json['Mobile'] ?? json['mobile'],
      documentNo: json['Document_No'] ?? json['documentNo'],
      amount: (json['Amount'] ?? json['amount'])?.toDouble(),
      description: json['Description'] ?? json['description'],
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'Mobile': mobile,
      'Document_No': documentNo,
      'Amount': amount,
      'Description': description,
    };
  }

  Map<String, dynamic> toJson() => toMap();
}

class PaymentItem implements Tomaps {
  String? voteHeadCode;
  String? voteHeadName;
  double? amount;

  PaymentItem({
    this.voteHeadCode,
    this.voteHeadName,
    this.amount,
  });

  factory PaymentItem.fromJson(Map<String, dynamic> json) {
    return PaymentItem(
      voteHeadCode: json['voteHeadCode'],
      voteHeadName: json['voteHeadName'],
      amount: json['amount']?.toDouble(),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'VoteHeadCode': voteHeadCode,
      'VoteHeadName': voteHeadName,
      'Amount': amount,
    };
  }

  Map<String, dynamic> toJson() => toMap();
}

class MultiplePaymentRequest implements Tomaps {
  String? customerNo;
  String? phoneNumber;
  List<PaymentItem>? paymentItems;
  double? totalAmount;
  String? description;
  String? reference;

  MultiplePaymentRequest({
    this.customerNo,
    this.phoneNumber,
    this.paymentItems,
    this.totalAmount,
    this.description,
    this.reference,
  });

  factory MultiplePaymentRequest.fromJson(Map<String, dynamic> json) {
    return MultiplePaymentRequest(
      customerNo: json['customerNo'],
      phoneNumber: json['phoneNumber'],
      paymentItems: json['paymentItems'] != null
          ? (json['paymentItems'] as List)
              .map((item) => PaymentItem.fromJson(item))
              .toList()
          : null,
      totalAmount: json['totalAmount']?.toDouble(),
      description: json['description'],
      reference: json['reference'],
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'Mobile': phoneNumber,
      'Member_No': customerNo ?? '',
      'Document_No': reference ?? '',
      'Amount': totalAmount,
      'Description': description,
    };
  }

  Map<String, dynamic> toJson() => toMap();
}

class MpesaStkResponse implements Tomaps {
  bool? success;
  String? merchantRequestID;
  String? checkoutRequestID;
  String? responseCode;
  String? responseDescription;
  String? customerMessage;

  MpesaStkResponse({
    this.success,
    this.merchantRequestID,
    this.checkoutRequestID,
    this.responseCode,
    this.responseDescription,
    this.customerMessage,
  });

  factory MpesaStkResponse.fromJson(Map<String, dynamic> json) {
    return MpesaStkResponse(
      success: json['success'] as bool?,
      merchantRequestID: json['MerchantRequestID'] as String?,
      checkoutRequestID: json['CheckoutRequestID'] as String?,
      responseCode: json['ResponseCode'] as String?,
      responseDescription: json['ResponseDescription'] as String?,
      customerMessage: json['CustomerMessage'] as String?,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'success': success,
      'MerchantRequestID': merchantRequestID,
      'CheckoutRequestID': checkoutRequestID,
      'ResponseCode': responseCode,
      'ResponseDescription': responseDescription,
      'CustomerMessage': customerMessage,
    };
  }

  Map<String, dynamic> toJson() => toMap();

  bool get isSuccess => success == true && responseCode == '0';
}

// Payment Detail for the payment document
class PaymentDetail implements Tomaps {
  String? key;
  String? documentNo;
  String? voteHead;
  double? amount;
  bool? amountSpecified;

  PaymentDetail({
    this.key,
    this.documentNo,
    this.voteHead,
    this.amount,
    this.amountSpecified,
  });

  factory PaymentDetail.fromJson(Map<String, dynamic> json) {
    return PaymentDetail(
      key: json['Key'],
      documentNo: json['Document_No'],
      voteHead: json['Vote_Head'],
      amount: json['Amount']?.toDouble(),
      amountSpecified: json['AmountSpecified'],
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'Key': key ?? '',
      'Document_No': documentNo ?? '',
      'Vote_Head': voteHead ?? '',
      'Amount': amount ?? 0.0,
      'AmountSpecified': amountSpecified ?? true,
    };
  }

  Map<String, dynamic> toJson() => toMap();
}

// Payment Document to be sent to /addpayment
class PaymentDocument implements Tomaps {
  List<PaymentDetail>? paymentDetailsList;
  String? key;
  String? documentNo;
  String? memberNo;
  DateTime? date;
  bool? dateSpecified;
  DateTime? time;
  bool? timeSpecified;
  double? amount;
  bool? amountSpecified;

  PaymentDocument({
    this.paymentDetailsList,
    this.key,
    this.documentNo,
    this.memberNo,
    this.date,
    this.dateSpecified,
    this.time,
    this.timeSpecified,
    this.amount,
    this.amountSpecified,
  });

  factory PaymentDocument.fromJson(Map<String, dynamic> json) {
    return PaymentDocument(
      paymentDetailsList: json['Payment_Details_List'] != null
          ? (json['Payment_Details_List'] as List)
              .map((item) => PaymentDetail.fromJson(item))
              .toList()
          : null,
      key: json['Key'],
      documentNo: json['Document_No'],
      memberNo: json['Member_No'],
      date: json['Date'] != null ? DateTime.parse(json['Date']) : null,
      dateSpecified: json['DateSpecified'],
      time: json['Time'] != null ? DateTime.parse(json['Time']) : null,
      timeSpecified: json['TimeSpecified'],
      amount: json['Amount']?.toDouble(),
      amountSpecified: json['AmountSpecified'],
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'Payment_Details_List':
          paymentDetailsList?.map((item) => item.toMap()).toList() ?? [],
      'Key': key ?? '',
      'Document_No': documentNo ?? '',
      'Member_No': memberNo ?? '',
      'Date': date?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'DateSpecified': dateSpecified ?? true,
      'Time': time?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'TimeSpecified': timeSpecified ?? true,
      'Amount': amount ?? 0.0,
      'AmountSpecified': amountSpecified ?? true,
    };
  }

  Map<String, dynamic> toJson() => toMap();
}
