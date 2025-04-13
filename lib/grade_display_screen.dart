import 'package:flutter/material.dart';
import 'subject_list_screen.dart'; // Import the screen we will navigate to

class GradeDisplayScreen extends StatelessWidget {
  final String grade; // Keep for display
  final String gradeDocId; // Add grade document ID

  const GradeDisplayScreen({
    Key? key,
    required this.grade,
    required this.gradeDocId, // Make it required
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Grade'),
        // Optionally add a button to proceed to the main app/podcast list
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.arrow_forward),
        //     onPressed: () {
        //       // Navigate to the main podcast screen (replace HomeScreen if needed)
        //       // Navigator.pushReplacement(
        //       //   context,
        //       //   MaterialPageRoute(builder: (context) => const HomeScreen()),
        //       // );
        //     },
        //   ),
        // ],
      ),
      body: Center(
        child: GestureDetector(
          // Wrap the Stack with GestureDetector
          onTap: () {
            // Navigate to SubjectListScreen when tapped
            Navigator.push(
              context,
              MaterialPageRoute(
                // Pass the gradeDocId to SubjectListScreen now
                builder: (context) => SubjectListScreen(gradeDocId: gradeDocId),
              ),
            );
          },
          child: Stack(
            alignment: Alignment.center, // Center the text within the Stack
            children: <Widget>[
              // Graduation Cap Icon
              Icon(
                Icons.school, // Using the built-in school icon
                size: 200.0, // Increased size
                color: Colors.blueAccent, // Adjusted color
              ),
              // Grade Text positioned over the icon
              Container(
                // Optional: Add a background to the text for better visibility
                // padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                // decoration: BoxDecoration(
                //   color: Colors.black.withOpacity(0.5),
                //   borderRadius: BorderRadius.circular(5),
                // ),
                child: Text(
                  grade, // Display the grade passed to the widget
                  style: const TextStyle(
                    fontSize: 48, // Increased font size
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // White text for contrast
                    // Add shadow for better readability if needed
                    // shadows: [
                    //   Shadow(
                    //     blurRadius: 10.0,
                    //     color: Colors.black,
                    //     offset: Offset(2.0, 2.0),
                    //   ),
                    // ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
