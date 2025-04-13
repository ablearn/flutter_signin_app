import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChapterListScreen extends StatefulWidget {
  final String unitId;
  final String unitName;

  const ChapterListScreen({
    Key? key,
    required this.unitId,
    required this.unitName,
  }) : super(key: key);

  @override
  _ChapterListScreenState createState() => _ChapterListScreenState();
}

class _ChapterListScreenState extends State<ChapterListScreen> {
  late Future<QuerySnapshot> _chaptersFuture;

  @override
  void initState() {
    super.initState();
    _chaptersFuture = _fetchChapters();
  }

  Future<QuerySnapshot> _fetchChapters() {
    // Query the 'chapters' collection for documents matching the passed unitId
    return FirebaseFirestore.instance
        .collection('chapters')
        .where('unit', isEqualTo: widget.unitId)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chapters for ${widget.unitName}',
        ), // Display unit name in AppBar
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: _chaptersFuture,
        builder: (context, snapshot) {
          // Check for errors
          if (snapshot.hasError) {
            print('Error fetching chapters: ${snapshot.error}'); // Log error
            return const Center(
              child: Text('Error loading chapters. Please try again.'),
            );
          }

          // Once complete, show results or loading indicator
          if (snapshot.connectionState == ConnectionState.done) {
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text('No chapters found for this unit.'),
              );
            }

            // Data is available, build the list
            final chapters = snapshot.data!.docs;

            return ListView.builder(
              itemCount: chapters.length,
              itemBuilder: (context, index) {
                // Extract chapter name - assuming the field is named 'chapter'
                final chapterData =
                    chapters[index].data() as Map<String, dynamic>;
                final chapterName =
                    chapterData['chapter'] as String? ?? 'Unnamed Chapter';

                return ListTile(
                  title: Text(chapterName),
                  // Optional: Add onTap to navigate further (e.g., to content)
                  // onTap: () {
                  //   // Navigate to content screen, passing chapter details
                  // },
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
