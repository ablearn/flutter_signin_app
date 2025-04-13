import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'unit_list_screen.dart'; // Import the new screen

class SubjectListScreen extends StatefulWidget {
  final String gradeDocId; // Changed from grade to gradeDocId

  const SubjectListScreen({Key? key, required this.gradeDocId})
    : super(key: key); // Updated constructor

  @override
  _SubjectListScreenState createState() => _SubjectListScreenState();
}

class _SubjectListScreenState extends State<SubjectListScreen> {
  late Future<QuerySnapshot> _subjectsFuture;

  @override
  void initState() {
    super.initState();
    _subjectsFuture = _fetchSubjects();
  }

  Future<QuerySnapshot> _fetchSubjects() {
    // Query the 'subjects' collection using the grade document ID
    return FirebaseFirestore.instance
        .collection('subjects')
        .where('grade', isEqualTo: widget.gradeDocId) // Query using gradeDocId
        .get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Updated AppBar title to be more generic or fetch grade name if needed
      appBar: AppBar(title: const Text('Subjects')),
      body: FutureBuilder<QuerySnapshot>(
        future: _subjectsFuture,
        builder: (context, snapshot) {
          // Check for errors
          if (snapshot.hasError) {
            print('Error fetching subjects: ${snapshot.error}'); // Log error
            return const Center(
              child: Text('Error loading subjects. Please try again.'),
            );
          }

          // Once complete, show results or loading indicator
          if (snapshot.connectionState == ConnectionState.done) {
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              // Updated message as we don't have the grade string directly here anymore
              return const Center(
                child: Text('No subjects found for this grade.'),
              );
            }

            // Data is available, build the grid
            final subjects = snapshot.data!.docs;

            return GridView.builder(
              padding: const EdgeInsets.all(16.0), // Keep padding
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 180.0, // Max width for each item
                crossAxisSpacing: 16.0, // Spacing between columns
                mainAxisSpacing: 16.0, // Spacing between rows
                childAspectRatio: 1.0, // Keep aspect ratio (square items)
              ),
              itemCount: subjects.length,
              itemBuilder: (context, index) {
                final subjectData =
                    subjects[index].data() as Map<String, dynamic>;
                final subjectName =
                    subjectData['subject'] as String? ?? 'Unnamed Subject';
                final subjectId = subjects[index].id; // Get the document ID

                // Create the icon with text overlay
                return GestureDetector(
                  onTap: () {
                    // Navigate to UnitListScreen, passing subject ID and name
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => UnitListScreen(
                              subjectId: subjectId,
                              subjectName: subjectName,
                            ),
                      ),
                    );
                  },
                  child: Card(
                    // Use Card for elevation/border
                    elevation: 4.0,
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        // Book Icon
                        Icon(
                          Icons.menu_book, // Book icon
                          size: 80.0, // Adjust size as needed
                          color: Colors.teal, // Adjust color
                        ),
                        // Subject Name Text
                        Container(
                          // Background for text readability
                          color: Colors.black.withOpacity(0.5),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: Text(
                            subjectName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16, // Adjust font size
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2, // Allow wrapping
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
