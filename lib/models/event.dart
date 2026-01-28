import 'package:flutter/material.dart';
import 'package:kanisa/models/event_category.dart';

class Event {
  final String? key;
  final String? title;
  final DateTime? date;
  final TimeOfDay? time;
  final String? location;
  final String? imageUrl;
  final String? description;
  final EventCategory category;

  Event({
    this.key,
    this.title,
    this.date,
    this.time,
    this.location,
    this.imageUrl,
    this.description,
    this.category = EventCategory.Church, // Default to Church
  });
  
  String get formattedDate {
    if (date == null) return '';
    final month = _getMonthAbbreviation(date!.month);
    return '${date!.day} $month';
  }
  
  String get formattedTime {
    if (time == null) return '';
    final hour = time!.hour % 12 == 0 ? 12 : time!.hour % 12;
    final minute = time!.minute.toString().padLeft(2, '0');
    final period = time!.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
  
  String _getMonthAbbreviation(int month) {
    const months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 
                   'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    return months[month - 1];
  }

  // Add fromJson and toJson methods if needed for API integration
  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      key: json['key'],
      title: json['title'],
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      time: json['time'] != null 
          ? TimeOfDay(hour: int.parse(json['time'].split(':')[0]), minute: int.parse(json['time'].split(':')[1])) 
          : null,
      location: json['location'],
      imageUrl: json['imageUrl'],
      description: json['description'],
      category: EventCategory.values.firstWhere(
        (e) => e.toString() == 'EventCategory.${json['category']}',
        orElse: () => EventCategory.Church,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'title': title,
      'date': date?.toIso8601String(),
      'time': time != null 
          ? '${time!.hour.toString().padLeft(2, '0')}:${time!.minute.toString().padLeft(2, '0')}'
          : null,
      'location': location,
      'imageUrl': imageUrl,
      'description': description,
      'category': category.toString().split('.').last,
    };
  }
}
