import 'package:kanisa/Network/results.dart';

class Dimension implements Tomaps {
  final String Key;
  final String Code;
  final String Name;
  final String Dimension_Code;

  Dimension({
    required this.Key,
    required this.Code,
    required this.Name,
    required this.Dimension_Code,
  });

  factory Dimension.fromMap(Map<String, dynamic> map) {
    return Dimension(
      Key: map['Key'] as String,
      Code: map['Code'] as String,
      Name: map['Name'] as String,
      Dimension_Code: map['Dimension_Code'] as String,
    );
  }
  @override
  String toString() {
    return 'Dimension(Key: $Key, Code: $Code, Name: $Name, Dimension_Code: $Dimension_Code)';
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'Key': Key,
      'Code': Code,
      'Name': Name,
      'Dimension_Code': Dimension_Code,
    };
  }

  factory Dimension.fromJson(Map<String, dynamic> json) {
    return Dimension(
      Key: json['Key'] as String,
      Code: json['Code'] as String,
      Name: json['Name'] as String,
      Dimension_Code: json['Dimension_Code'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return toMap();
  }
}
