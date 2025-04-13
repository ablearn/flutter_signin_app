import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

            // Data is available, build the list
            final subjects = snapshot.data!.docs;

            return ListView.builder(
              itemCount: subjects.length,
              itemBuilder: (context, index) {
                // Extract subject name - assuming the field is named 'subject'
                final subjectData =
                    subjects[index].data() as Map<String, dynamic>;
                final subjectName =
                    subjectData['subject'] as String? ?? 'Unnamed Subject';

                return ListTile(
                  title: Text(subjectName),
                  // Optional: Add onTap to navigate further (e.g., to units/chapters)
                  // onTap: () {
                  //   // Navigate to units screen, passing subject details
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
