import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kanisa/models/sermon.dart';

class SermonsDetailScreen extends StatelessWidget {
  const SermonsDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text('Sermons'),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.blue.shade700,
                      Colors.green.shade500,
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Recent Sermons',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return SermonCard(
                  sermon: Sermon(
                    key: '${index + 1}',
                    title: 'The Power of Faith ${index + 1}',
                    preacher: 'Pastor John Doe',
                    date: DateTime.now().subtract(Duration(days: index)),
                    duration: '45 minutes',
                    thumbnailUrl:
                        'https://picsum.photos/seed/${index + 1}/300/200',
                  ),
                );
              },
              childCount: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class SermonCard extends StatelessWidget {
  final Sermon sermon;

  const SermonCard({
    super.key,
    required this.sermon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
            child: Image.network(
              sermon.thumbnailUrl ?? '',
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: Center(child: Icon(Icons.error)),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sermon.title ?? '',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.person, size: 16, color: Colors.grey),
                    SizedBox(width: 4),
                    Text(sermon.preacher ?? '',
                        style: TextStyle(color: Colors.grey)),
                    Spacer(),
                    Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                    SizedBox(width: 4),
                    Text(sermon.date?.toString() ?? '',
                        style: TextStyle(color: Colors.grey)),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: Colors.grey),
                    SizedBox(width: 4),
                    Text(sermon.duration ?? '',
                        style: TextStyle(color: Colors.grey)),
                  ],
                ),
                SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    // Handle sermon playback
                    Get.snackbar('Play Sermon', 'Playing: ${sermon.title}');
                  },
                  icon: Icon(Icons.play_arrow),
                  label: Text('Listen Now'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
