import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProjectDetailsPage extends StatefulWidget {
  final Map<String, dynamic> project;
  final String currentUsername;

  const ProjectDetailsPage({
    super.key,
    required this.project,
    required this.currentUsername,
  });

  @override
  State<ProjectDetailsPage> createState() => _ProjectDetailsPageState();
}

class _ProjectDetailsPageState extends State<ProjectDetailsPage> {
  final TextEditingController _bidAmountController = TextEditingController();
  final TextEditingController _bidDetailsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final project = widget.project;
    final Color primaryColor = const Color(0xFF5D4DA8);

    // Get the project deadline and format it
    final projectDeadline = project['projectDeadline'];
    String formattedDeadline = 'N/A';
    if (projectDeadline is Timestamp) {
      final DateTime deadlineDate = projectDeadline.toDate();
      formattedDeadline = DateFormat.yMMMd().add_jm().format(deadlineDate);
    }

    // Skills associated with the project
    final List<String> projectSkills =
        List<String>.from(project['skills'] ?? []);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          project['title'] ?? 'Project Details',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        elevation: 8,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          color: Colors.white,
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _infoText('Details', project['details']),
                _infoText('Budget', '\$${project['budget']}'),
                _infoText('Deadline', formattedDeadline),
                _infoText('Posted by', project['createdby']),
                _infoText('Organization', project['orgusername']),
                _infoText('Skills Required', projectSkills.join(', ')),
                _infoText('Allow Multiple Workers',
                    project['allowmultipleworkers'] == 'yes' ? 'Yes' : 'No'),
                const SizedBox(height: 20),
                Divider(color: primaryColor, thickness: 2),
                const SizedBox(height: 20),
                const Text(
                  'Place Your Bid',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _bidAmountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Bid Amount',
                    prefixText: '\$ ',
                    border: const OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: primaryColor),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _bidDetailsController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'How you will do this project',
                    border: const OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: primaryColor),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  onPressed: _submitBid,
                  child: const Text(
                    'Submit Bid',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoText(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: RichText(
        text: TextSpan(
          text: '$label: ',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF333333),
          ),
          children: [
            TextSpan(
              text: value ?? 'N/A',
              style: const TextStyle(
                fontWeight: FontWeight.normal,
                color: Color(0xFF444444),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitBid() async {
    final bidAmount = _bidAmountController.text.trim();
    final bidDetails = _bidDetailsController.text.trim();

    if (bidAmount.isEmpty || bidDetails.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all bid fields.")),
      );
      return;
    }

    final firestore = FirebaseFirestore.instance;
    final now = DateTime.now();
    final formattedNow = DateFormat.yMMMMd().add_jm().format(now);

    final newBid = {
      'bidderUsername': widget.currentUsername,
      'projectId': widget.project['id'],
      'amount': bidAmount,
      'details': bidDetails,
      'timestamp': now.toIso8601String(),
      'updated_at': formattedNow,
      'bid_status': 'pending',
      'allocated': false,
      'project_status': 'open',
    };

    try {
      await firestore.collection('bids').add(newBid);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bid submitted successfully!")),
      );

      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error submitting bid: $e")),
      );
    }
  }
}
