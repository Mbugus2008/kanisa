import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kanisa/models/event_category.dart';
import 'package:kanisa/models/event.dart';
import 'package:google_fonts/google_fonts.dart';

class EventsDetailScreen extends StatefulWidget {
  const EventsDetailScreen({super.key});

  @override
  _EventsDetailScreenState createState() => _EventsDetailScreenState();
}

class _EventsDetailScreenState extends State<EventsDetailScreen> {
  EventCategory _selectedCategory = EventCategory.Church;

  // Sample data - replace with your actual data source
  final List<Event> _allEvents = [
    Event(
      title: 'Sunday Service',
      date: DateTime.now().add(Duration(days: 1)),
      time: TimeOfDay(hour: 9, minute: 0),
      location: 'Main Sanctuary',
      category: EventCategory.Church,
      imageUrl: 'https://source.unsplash.com/random/800x600/?church,service',
      description:
          'Join us for our weekly Sunday service with worship and the word.',
    ),
    Event(
      title: 'Bible Study Group',
      date: DateTime.now().add(Duration(days: 2)),
      time: TimeOfDay(hour: 18, minute: 30),
      location: 'Room 101',
      category: EventCategory.MyGroups,
      imageUrl: 'https://source.unsplash.com/random/800x600/?bible,study',
      description: 'In-depth Bible study and discussion for all age groups.',
    ),
    Event(
      title: 'District Meeting',
      date: DateTime.now().add(Duration(days: 3)),
      time: TimeOfDay(hour: 19, minute: 0),
      location: 'Conference Hall',
      category: EventCategory.MyDistricts,
      imageUrl:
          'https://source.unsplash.com/random/800x600/?meeting,conference',
      description: 'Quarterly district meeting for all church leaders.',
    ),
    Event(
      title: 'Youth Fellowship',
      date: DateTime.now().add(Duration(days: 5)),
      time: TimeOfDay(hour: 17, minute: 0),
      location: 'Youth Center',
      category: EventCategory.MyGroups,
      imageUrl: 'https://source.unsplash.com/random/800x600/?youth,group',
      description: 'Fun and fellowship for our youth members.',
    ),
    Event(
      title: 'Prayer Meeting',
      date: DateTime.now().add(Duration(days: 7)),
      time: TimeOfDay(hour: 6, minute: 0),
      location: 'Prayer Room',
      category: EventCategory.Church,
      imageUrl: 'https://source.unsplash.com/random/800x600/?prayer',
      description: 'Join us for a time of prayer and intercession.',
    ),
  ];

  List<Event> get _filteredEvents =>
      _allEvents.where((event) => event.category == _selectedCategory).toList();

  Widget _buildCategoryTab(EventCategory category) {
    final isSelected = _selectedCategory == category;
    final icon = _getCategoryIcon(category);

    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      margin: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? Theme.of(context).primaryColor.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected
              ? Theme.of(context).primaryColor
              : Colors.grey.shade300,
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            setState(() {
              _selectedCategory = category;
            });
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.grey.shade600,
                ),
                SizedBox(width: 8),
                Text(
                  category.displayName,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(EventCategory category) {
    switch (category) {
      case EventCategory.Church:
        return Icons.church_rounded;
      case EventCategory.MyGroups:
        return Icons.groups_rounded;
      case EventCategory.MyDistricts:
        return Icons.location_city_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 120.0,
              floating: false,
              pinned: true,
              elevation: 2,
              backgroundColor: Theme.of(context).primaryColor,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(bottom: 16.0),
                centerTitle: true,
                title: Text(
                  'Upcoming Events',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 22,
                  ),
                ),
                background: Container(
                  color: Theme.of(context).primaryColor,
                ),
              ),
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(80.0),
                child: Transform.translate(
                  offset: Offset(0, 20),
                  child: Container(
                    height: 60,
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: EventCategory.values.map((category) {
                        return _buildCategoryTab(category);
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ];
        },
        body: Container(
          margin: EdgeInsets.only(top: 40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            child: _filteredEvents.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_busy_rounded,
                          size: 64,
                          color: Colors.grey.shade300,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No events found',
                          style: GoogleFonts.poppins(
                            color: Colors.grey.shade500,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      return ListView.builder(
                        padding: const EdgeInsets.only(top: 20, bottom: 100),
                        itemCount: _filteredEvents.length,
                        itemBuilder: (context, index) {
                          final event = _filteredEvents[index];
                          return Padding(
                            key: ValueKey('event_${event.key}'),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: EventCard(
                              key: ValueKey('event_card_${event.key}'),
                              event: event,
                            ),
                          );
                        },
                        addAutomaticKeepAlives: true,
                        addRepaintBoundaries: true,
                        addSemanticIndexes: true,
                        cacheExtent: 500,
                        itemExtent: 400, // Adjust based on your item height
                      );
                    },
                  ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Get.snackbar(
            'New Event',
            'Feature coming soon!',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Theme.of(context).primaryColor,
            colorText: Colors.white,
          );
        },
        icon: Icon(Icons.add, size: 24),
        label: Text(
          'New Event',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
          ),
        ),
        elevation: 2,
        backgroundColor: Theme.of(context).primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

class _ImageLoader extends StatelessWidget {
  final String? imageUrl;
  final Widget placeholder;
  final double height;

  const _ImageLoader({
    super.key,
    required this.imageUrl,
    required this.placeholder,
    this.height = 180,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return SizedBox(
        height: height,
        width: double.infinity,
        child: placeholder,
      );
    }

    return SizedBox(
      height: height,
      width: double.infinity,
      child: CachedNetworkImage(
        imageUrl: imageUrl!,
        fit: BoxFit.cover,
        errorWidget: (context, url, error) {
          debugPrint('Error loading image: $error');
          return placeholder;
        },
        memCacheHeight:
            (height * MediaQuery.of(context).devicePixelRatio).round(),
        maxHeightDiskCache: (height * 2).round(),
        progressIndicatorBuilder: (context, url, progress) {
          // Show a simple loading indicator without percentage
          return Container(
            color: Colors.grey[200],
            child: const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        },
      ),
    );
  }
}

class EventCard extends StatelessWidget {
  const EventCard({
    super.key,
    required this.event,
  });

  final Event event;

  Color _getCategoryColor(EventCategory category) {
    switch (category) {
      case EventCategory.Church:
        return Colors.blue;
      case EventCategory.MyGroups:
        return Colors.green;
      case EventCategory.MyDistricts:
        return Colors.orange;
    }
  }

  Widget _buildPlaceholderState() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Icon(
          Icons.event_available_rounded,
          size: 50,
          color: Colors.grey,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Get.toNamed('/event-details', arguments: event);
        },
        borderRadius: BorderRadius.circular(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 500,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Event Image with gradient overlay
              Stack(
                children: [
                  // Image with loading state
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: SizedBox(
                      height: 160,
                      width: double.infinity,
                      child: _ImageLoader(
                        key: ValueKey('image_${event.key}'),
                        imageUrl: event.imageUrl,
                        placeholder: _buildPlaceholderState(),
                        height: 160,
                      ),
                    ),
                  ),
                  // Gradient overlay for better text readability
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.7),
                            Colors.transparent,
                            Colors.transparent,
                            Colors.black.withOpacity(0.3),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Category Chip
                  Positioned(
                    top: 8,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color:
                            _getCategoryColor(event.category).withOpacity(0.9),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        event.category.toString().split('.').last,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // Event details
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Event Title
                    Text(
                      event.title ?? 'No Title',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                        height: 1.25,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    // Date and Time
                    Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            size: 14, color: Colors.grey),
                        const SizedBox(width: 6),
                        Text(
                          event.formattedDate,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.access_time,
                            size: 14, color: Colors.grey),
                        const SizedBox(width: 6),
                        Text(
                          event.formattedTime,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),

                    if (event.location != null &&
                        event.location!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              size: 14, color: Colors.grey),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              event.location!,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],

                    if (event.description != null &&
                        event.description!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        event.description!,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              // Action Buttons
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 38,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // Handle reminder
                          },
                          icon: const Icon(Icons.notifications_none_rounded,
                              size: 16),
                          label: const Text(
                            'Remind Me',
                            style: TextStyle(fontSize: 13),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            side: BorderSide(
                                color: Theme.of(context).primaryColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SizedBox(
                        height: 38,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Handle register
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(Icons.login_rounded, size: 16),
                          label: const Text(
                            'Register',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
