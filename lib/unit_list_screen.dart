import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chapter_list_screen.dart'; // Import the new screen

class UnitListScreen extends StatefulWidget {
  final String subjectId;
  final String subjectName;

  const UnitListScreen({
    Key? key,
    required this.subjectId,
    required this.subjectName,
  }) : super(key: key);

  @override
  _UnitListScreenState createState() => _UnitListScreenState();
}

class _UnitListScreenState extends State<UnitListScreen> {
  late Future<QuerySnapshot> _unitsFuture;

  @override
  void initState() {
    super.initState();
    _unitsFuture = _fetchUnits();
  }

  Future<QuerySnapshot> _fetchUnits() {
    // Query the 'units' collection for documents matching the passed subjectId
    return FirebaseFirestore.instance
        .collection('units')
        .where('subject', isEqualTo: widget.subjectId)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Units for ${widget.subjectName}',
        ), // Display subject name in AppBar
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: _unitsFuture,
        builder: (context, snapshot) {
          // Check for errors
          if (snapshot.hasError) {
            print('Error fetching units: ${snapshot.error}'); // Log error
            return const Center(
              child: Text('Error loading units. Please try again.'),
            );
          }

          // Once complete, show results or loading indicator
          if (snapshot.connectionState == ConnectionState.done) {
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text('No units found for this subject.'),
              );
            }

            // Data is available, build the grid
            final units = snapshot.data!.docs;

            return GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 180.0,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 1.0,
              ),
              itemCount: units.length,
              itemBuilder: (context, index) {
                final unitData = units[index].data() as Map<String, dynamic>;
                final unitName = unitData['unit'] as String? ?? 'Unnamed Unit';
                final unitId = units[index].id; // Get the unit document ID

                return GestureDetector(
                  onTap: () {
                    // Navigate to ChapterListScreen, passing unit ID and name
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => ChapterListScreen(
                              unitId: unitId,
                              unitName: unitName,
                            ),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 4.0,
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.description, // Or another suitable icon
                          size: 80.0,
                          color: Colors.orange,
                        ),
                        Container(
                          color: Colors.black.withOpacity(0.5),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: Text(
                            unitName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
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
