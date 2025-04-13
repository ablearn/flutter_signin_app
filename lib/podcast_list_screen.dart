import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:audioplayers/audioplayers.dart'; // Import audioplayers

class PodcastListScreen extends StatefulWidget {
  final String chapterId;
  final String chapterName;

  const PodcastListScreen({
    Key? key,
    required this.chapterId,
    required this.chapterName,
  }) : super(key: key);

  @override
  _PodcastListScreenState createState() => _PodcastListScreenState();
}

class _PodcastListScreenState extends State<PodcastListScreen> {
  late Future<QuerySnapshot> _podcastsFuture;
  final AudioPlayer audioPlayer = AudioPlayer(); // Create an instance

  @override
  void initState() {
    super.initState();
    _podcastsFuture = _fetchPodcasts();
  }

  Future<QuerySnapshot> _fetchPodcasts() {
    // Query the 'podcasts' collection for documents matching the passed chapterId
    return FirebaseFirestore.instance
        .collection('podcasts')
        .where('chapter', isEqualTo: widget.chapterId)
        .get();
  }

  @override
  void dispose() {
    audioPlayer.dispose(); // Dispose the player when the widget is removed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Podcasts for ${widget.chapterName}',
        ), // Display chapter name in AppBar
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: _podcastsFuture,
        builder: (context, snapshot) {
          // Check for errors
          if (snapshot.hasError) {
            print('Error fetching podcasts: ${snapshot.error}'); // Log error
            return const Center(
              child: Text('Error loading podcasts. Please try again.'),
            );
          }

          // Once complete, show results or loading indicator
          if (snapshot.connectionState == ConnectionState.done) {
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text('No podcasts found for this chapter.'),
              );
            }

            // Data is available, build the list
            final podcasts = snapshot.data!.docs;

            return ListView.builder(
              itemCount: podcasts.length,
              itemBuilder: (context, index) {
                // Extract podcast data
                final podcastData =
                    podcasts[index].data() as Map<String, dynamic>;
                final podcastTitle =
                    podcastData['title'] as String? ?? 'Unnamed Podcast';
                final audioUrl = podcastData['audioUrl'] as String?;

                return ListTile(
                  title: Text(podcastTitle),
                  leading: const Icon(Icons.audiotrack), // Add an icon
                  onTap: () async {
                    // Play the podcast
                    if (audioUrl != null) {
                      try {
                        await audioPlayer.play(UrlSource(audioUrl));
                      } catch (e) {
                        print('Error playing podcast: $e');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error playing: ${e.toString()}'),
                          ),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Audio URL not found.')),
                      );
                    }
                  },
                );
              },
            );
          }

          // While fetching data, show a loading spinner.
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
