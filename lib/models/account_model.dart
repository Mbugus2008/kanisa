import 'package:intl/intl.dart';
import 'package:kanisa/Network/results.dart';
import 'package:kanisa/Utils/util.dart';

class Customer implements Tomaps {
  String? Key;
  String? No;
  String? Name;
  String? Phone_No;
  String? Global_Dimension_1_Code;
  String? Global_Dimension_2_Code;
  String? E_Mail;
  double? Balance_LCY;
  String? Occupation;
  DateTime? Date_of_Birth;
  DateTime? Baptism_Date;
  String? Baptised_by;
  bool? Confirmed;
  String? Other_Information;
  gender? Gender;
  List<MemberGroups>? MembersGroups;
  DateTime? Confirmation_Date;
  customerRole? Relationship;
  String? Household_Primary_No;

  Customer({
    this.Key,
    this.No,
    this.Name,
    this.Phone_No,
    this.Global_Dimension_1_Code,
    this.Global_Dimension_2_Code,
    this.E_Mail,
    this.Balance_LCY,
    this.Occupation,
    this.Date_of_Birth,
    this.Baptism_Date,
    this.Baptised_by,
    this.Confirmed,
    this.Other_Information,
    this.Gender,
    this.MembersGroups,
    this.Confirmation_Date,
    this.Relationship,
    this.Household_Primary_No,
  });

  @override
  String toString() {
    return '$No $Name $Phone_No $Global_Dimension_1_Code $Global_Dimension_2_Code $Occupation $Confirmed $Confirmation_Date';
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      Key: map['Key'] as String?,
      Name: map['Name'] as String?,
      Phone_No: map['Phone_No'] as String?,
      Global_Dimension_1_Code: map['Global_Dimension_1_Code'] as String?,
      Global_Dimension_2_Code: map['Global_Dimension_2_Code'] as String?,
      E_Mail: map['E_Mail'] as String?,
      Balance_LCY: map['Balance_LCY']?.toDouble(),
      Occupation: map['Occupation'] as String?,
      Confirmed: map['Confirmed'] as bool?,
      Date_of_Birth: map['Date_of_Birth'] is String
          ? DateFormat('dd-MM-yyyy').parse(map['Date_of_Birth'])
          : map['Date_of_Birth'] as DateTime?,
      Baptism_Date: map['Baptism_Date'] is String
          ? DateFormat('dd-MM-yyyy').parse(map['Baptism_Date'])
          : map['Baptism_Date'] as DateTime?,
      Baptised_by: map['Baptised_by'] as String?,
      Other_Information: map['Other_Information'] as String?,
      Gender: map['Gender'] is String
          ? gender.values.firstWhere(
              (e) => e.toString() == 'gender.${map['Gender']}',
              orElse: () => gender._blank_,
            )
          : map['Gender'] as gender?,
      MembersGroups: map['MembersGroups'] != null
          ? List<MemberGroups>.from((map['MembersGroups'] as List).map((x) =>
              x is Map<String, dynamic>
                  ? MemberGroups.fromMap(x)
                  : x as MemberGroups))
          : null,
      Confirmation_Date: map['Confirmation_Date'] is String
          ? DateFormat('dd-MM-yyyy').parse(map['Confirmation_Date'])
          : map['Confirmation_Date'] as DateTime?,
      Relationship: map['Relationship'] is String
          ? customerRole.values.firstWhere(
              (e) => e.toString() == 'customerRole.${map['Relationship']}',
              orElse: () => customerRole.primary,
            )
          : map['Relationship'] is int
              ? _roleFromIndex(map['Relationship'])
              : null,
      Household_Primary_No: map['Household_Primary_No'] as String?,
    );
  }

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      Key: json['Key'],
      No: json['No'],
      Name: json['Name'],
      Occupation: json['Occupation'],
      Phone_No: json['Phone_No'],
      Global_Dimension_1_Code: json['Global_Dimension_1_Code'],
      Global_Dimension_2_Code: json['Global_Dimension_2_Code'],
      E_Mail: json['E_Mail'],
      Balance_LCY: json['Balance_LCY']?.toDouble(),
      Confirmed: json['Confirmed'],
      Date_of_Birth: json['Date_of_Birth'] != null
          ? parseDate(json['Date_of_Birth'])
          : null,
      Baptism_Date:
          json['Baptism_Date'] != null ? parseDate(json['Baptism_Date']) : null,
      Baptised_by: json['Baptised_by'],
      Other_Information: json['Other_Information'],
      Gender: json['Gender'] != null && json['Gender'] is int
          ? gender.values.elementAt(json['Gender'])
          : gender._blank_,
      MembersGroups: json['MembersGroups'] != null
          ? List<MemberGroups>.from(
              json['MembersGroups']?.map((x) => MemberGroups.fromJson(x)))
          : null,
      Confirmation_Date: json['Confirmation_Date'] != null
          ? parseDate(json['Confirmation_Date'])
          : null,
      Relationship: json['Relationship'] is String
          ? customerRole.values.firstWhere(
              (e) => e.toString() == 'customerRole.${json['Relationship']}',
              orElse: () => customerRole.primary,
            )
          : json['Relationship'] is int
              ? _roleFromIndex(json['Relationship'])
              : null,
      Household_Primary_No: json['Household_Primary_No'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Key': Key,
      'No': No,
      'Name': Name,
      'Phone_No': Phone_No,
      'Occupation': Occupation,
      'Global_Dimension_1_Code': Global_Dimension_1_Code,
      'Global_Dimension_2_Code': Global_Dimension_2_Code,
      'E_Mail': E_Mail,
      'Balance_LCY': Balance_LCY,
      'Confirmed': Confirmed,
      'Date_of_Birth':
          Date_of_Birth != null ? formattedMMDD.format(Date_of_Birth!) : null,
      'Baptism_Date':
          Baptism_Date != null ? formattedMMDD.format(Baptism_Date!) : null,
      'Baptised_by': Baptised_by,
      'Other_Information': Other_Information,
      'Gender': Gender?.index,
      'MembersGroups': MembersGroups?.map((e) => e.toJson()).toList(),
      'Confirmation_Date': Confirmation_Date != null
          ? formattedMMDD.format(Confirmation_Date!)
          : null,
      'Relationship': Relationship?.index,
      'Household_Primary_No': Household_Primary_No,
    };
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'Key': Key,
      'No': No,
      'Name': Name,
      'Occupation': Occupation,
      'Phone_No': Phone_No,
      'Global_Dimension_1_Code': Global_Dimension_1_Code,
      'Global_Dimension_2_Code': Global_Dimension_2_Code,
      'E_Mail': E_Mail,
      'Balance_LCY': Balance_LCY,
      'Confirmed': Confirmed,
      'Date_of_Birth':
          Date_of_Birth != null ? formattedDDMM.format(Date_of_Birth!) : null,
      'Baptism_Date':
          Baptism_Date != null ? formattedDDMM.format(Baptism_Date!) : null,
      'Baptised_by': Baptised_by,
      'Other_Information': Other_Information,
      'Gender': Gender?.index,
      'MembersGroups': MembersGroups?.map((e) => e.toMap()).toList(),
      'Confirmation_Date': Confirmation_Date != null
          ? formattedDDMM.format(Confirmation_Date!)
          : null,
      'Relationship': Relationship?.index,
      'Household_Primary_No': Household_Primary_No,
    };
  }

  static customerRole? _roleFromIndex(dynamic value) {
    final int index = value as int;
    if (index < 0 || index >= customerRole.values.length) {
      return null;
    }
    return customerRole.values.elementAt(index);
  }
}

class MemberGroups implements Tomaps {
  String? Customer;
  String? Global_Dimension_2_Code;
  List<String>? Group_Codes;

  MemberGroups({
    this.Customer,
    this.Global_Dimension_2_Code,
    this.Group_Codes,
  });

  factory MemberGroups.fromMap(Map<String, dynamic> map) {
    return MemberGroups(
      Customer: map['Customer'] as String?,
      Global_Dimension_2_Code: map['Global_Dimension_2_Code'] as String?,
      Group_Codes: map['Group_Codes'] != null
          ? List<String>.from(map['Group_Codes'])
          : null,
    );
  }

  factory MemberGroups.fromJson(Map<String, dynamic> json) {
    return MemberGroups(
      Customer: json['Customer'] as String?,
      Global_Dimension_2_Code: json['Global_Dimension_2_Code'] as String?,
      Group_Codes: json['Group_Codes'] != null
          ? List<String>.from(json['Group_Codes'])
          : null,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'Customer': Customer,
      'Global_Dimension_2_Code': Global_Dimension_2_Code,
      'Group_Codes': Group_Codes,
    };
  }

  Map<String, dynamic> toJson() {
    return toMap();
  }
}

enum customerRole {
  primary,
  spouse,
  child,
}

enum gender {
  _blank_,
  Male,
  Female,
}
