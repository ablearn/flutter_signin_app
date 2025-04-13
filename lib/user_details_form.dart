import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main.dart'; // To navigate to HomeScreen

class UserDetailsForm extends StatefulWidget {
  const UserDetailsForm({Key? key}) : super(key: key);

  @override
  _UserDetailsFormState createState() => _UserDetailsFormState();
}

class _UserDetailsFormState extends State<UserDetailsForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _gradeController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _gradeController.dispose();
    super.dispose();
  }

  Future<void> _saveUserDetails() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        // Should not happen if navigated here after sign-in, but handle defensively
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: No user logged in.')),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final userData = {
        'name': _nameController.text.trim(),
        'grade': _gradeController.text.trim(),
        'email': user.email, // Get email from the authenticated user
        'subscriptionPlanCode': 'FREE', // Hardcoded as requested
        'userType': 'STUDENT', // Hardcoded as requested
      };

      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid) // Use user's UID as document ID
            .set(userData);

        // Navigate to HomeScreen after successful save
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } catch (e) {
        print("Error saving user details: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving details: ${e.toString()}')),
        );
      } finally {
        // Ensure loading state is turned off even if navigation fails
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enter Your Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Student Name'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _gradeController,
                decoration: const InputDecoration(labelText: 'Grade'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your grade';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                    onPressed: _saveUserDetails,
                    child: const Text('Save Details'),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
