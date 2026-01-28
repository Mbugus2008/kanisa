// ignore_for_file: public_member_api_docs, sort_constructors_first, non_constant_identifier_names
import 'dart:convert';

abstract class Tomaps {
  Map<String, dynamic> toMap();
}

class Results<T> {
  int? Code;
  String? Desc;
  T? Contents;

  Results({this.Code, this.Desc, this.Contents});

  Map<String, dynamic> toMap() {
    return {
      'Code': Code,
      'Desc': Desc,
      'Contents': Contents is List<Tomaps>
          ? (Contents as List<Tomaps>).map((e) => e.toMap()).toList()
          : (Contents as Tomaps).toMap(),
    };
  }

  factory Results.fromMap(
      Map<String, dynamic> map, T Function(dynamic) fromJsonT) {
    var contents = map['Contents'];
    return Results(
      Code: map['Code'] as int?,
      Desc: map['Desc'] as String?,
      Contents: contents != null
          ? (contents is List
              ? (contents).map((item) => fromJsonT(item)).toList() as T
              : fromJsonT(contents))
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Results.fromJson(String source, T Function(dynamic) fromJsonT) =>
      Results.fromMap(json.decode(source), fromJsonT);
}

class ListResults<T extends Tomaps> {
  int? Code = 0;
  String? Desc = "Successful";
  List<T>? Contents;
  ListResults({
    int? code,
    String? desc,
    this.Code,
    this.Desc,
    this.Contents,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'Code': Code,
      'Desc': Desc,
      'Contents': Contents?.map((x) => x.toMap()).toList(),
    };
  }

  factory ListResults.fromMap(
      Map<String, dynamic> map, T Function(Map<String, dynamic>) createT) {
    return ListResults(
      Code: map['Code'] != null ? map['Code'] as int : null,
      Desc: map['Desc'] != null ? map['Desc'] as String : null,
      Contents: map['Contents'] != null
          ? (map['Contents'] as List<dynamic>)
              .map((x) => createT(x as Map<String, dynamic>))
              .toList()
          : null,
    );
  }
  String toJson() => json.encode(toMap());
  factory ListResults.fromJson(
          String source, T Function(Map<String, dynamic>) createT) =>
      ListResults.fromMap(json.decode(source) as Map<String, dynamic>, createT);
}
