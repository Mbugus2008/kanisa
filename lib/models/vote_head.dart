import 'package:kanisa/Network/results.dart';

class VoteHead implements Tomaps {
  String? code;
  String? name;
  String? description;
  double? defaultAmount;
  bool? allowCustomAmount;
  bool? isActive;
  String? category;

  VoteHead({
    this.code,
    this.name,
    this.description,
    this.defaultAmount,
    this.allowCustomAmount,
    this.isActive,
    this.category,
  });

  factory VoteHead.fromJson(Map<String, dynamic> json) {
    // Handle both camelCase and PascalCase from backend
    final code = json['code'] ?? json['Code'];
    final category =
        json['category'] ?? json['Category'] ?? _getCategoryFromCode(code);

    return VoteHead(
      code: code,
      name: json['name'] ?? json['Name'],
      description: json['description'] ?? json['Description'],
      defaultAmount:
          (json['defaultAmount'] ?? json['DefaultAmount'])?.toDouble(),
      allowCustomAmount:
          json['allowCustomAmount'] ?? json['AllowCustomAmount'] ?? true,
      isActive: json['isActive'] ?? json['IsActive'] ?? true,
      category: category,
    );
  }

  // Helper method to determine category from code
  static String _getCategoryFromCode(String? code) {
    if (code == null) return 'Other';
    final upperCode = code.toUpperCase();
    if (upperCode.contains('REGISTRAT')) return 'Registration';
    if (upperCode.contains('TITHE')) return 'Contribution';
    if (upperCode.contains('OFFERING')) return 'Contribution';
    if (upperCode.contains('FELLOWSHIP')) return 'Fellowship';
    if (upperCode.contains('BUILDING')) return 'Special';
    if (upperCode.contains('MISSION')) return 'Special';
    return 'Other';
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'name': name,
      'description': description,
      'defaultAmount': defaultAmount,
      'allowCustomAmount': allowCustomAmount,
      'isActive': isActive,
      'category': category,
    };
  }

  Map<String, dynamic> toJson() => toMap();

  @override
  String toString() {
    return 'VoteHead{code: $code, name: $name, description: $description, defaultAmount: $defaultAmount}';
  }
}

// Predefined vote heads for the church
class PredefinedVoteHeads {
  static List<VoteHead> getDefaultVoteHeads() {
    return [
      VoteHead(
        code: 'DISTRICT REGISTRATIO',
        name: 'District Registration',
        description: 'District Registration',
        defaultAmount: 0.0,
        allowCustomAmount: true,
        isActive: true,
        category: 'Registration',
      ),
      VoteHead(
        code: 'LCC REGISTRATION',
        name: 'Lcc Registration',
        description: 'Lcc Registration',
        defaultAmount: 0.0,
        allowCustomAmount: true,
        isActive: true,
        category: 'Registration',
      ),
      VoteHead(
        code: 'OFFERING',
        name: 'Offering',
        description: 'Offering',
        defaultAmount: 0.0,
        allowCustomAmount: true,
        isActive: true,
        category: 'Contribution',
      ),
      VoteHead(
        code: 'TITHE',
        name: 'Tithe',
        description: 'Tithe',
        defaultAmount: 0.0,
        allowCustomAmount: true,
        isActive: true,
        category: 'Contribution',
      ),
    ];
  }
}
