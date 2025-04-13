import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

            // Data is available, build the list
            final units = snapshot.data!.docs;

            return ListView.builder(
              itemCount: units.length,
              itemBuilder: (context, index) {
                // Extract unit name - assuming the field is named 'unit'
                final unitData = units[index].data() as Map<String, dynamic>;
                final unitName = unitData['unit'] as String? ?? 'Unnamed Unit';

                return ListTile(
                  title: Text(unitName),
                  // Optional: Add onTap to navigate further (e.g., to chapters)
                  // onTap: () {
                  //   // Navigate to chapters screen, passing unit details
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
