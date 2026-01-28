/// Categories for organizing events in the application
enum EventCategory {
  Church,
  MyGroups,
  MyDistricts,
}

extension EventCategoryExtension on EventCategory {
  /// Returns the display name for the event category
  String get displayName {
    switch (this) {
      case EventCategory.Church:
        return 'Church';
      case EventCategory.MyGroups:
        return 'My Groups';
      case EventCategory.MyDistricts:
        return 'My Districts';
    }
  }
}
