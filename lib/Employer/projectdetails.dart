import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProjectDetailScreen extends StatelessWidget {
  final Map<String, dynamic> projectData;
  final String projectId;
  final String username;

  const ProjectDetailScreen({
    super.key,
    required this.projectData,
    required this.projectId,
    required this.username,
  });

  Future<void> requestDelete(BuildContext context) async {
    try {
      await FirebaseFirestore.instance.collection('deleteproject').add({
        ...projectData,
        'requestedBy': username,
        'requestedAt': Timestamp.now(),
        'originalProjectId': projectId,
      });

      await FirebaseFirestore.instance
          .collection('projects')
          .doc(projectId)
          .update({'deletionRequested': true});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Delete request sent for approval')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final skills = (projectData['skills'] as List?)?.join(', ') ?? 'None';
    final status = projectData['status'] ?? 'pending';
    final budget = projectData['budget'] ?? '0';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Title: ${projectData['title']}",
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Details: ${projectData['details']}"),
            const SizedBox(height: 8),
            Text("Skills: $skills"),
            const SizedBox(height: 8),
            Text("Budget: \$${budget.toString()}"),
            const SizedBox(height: 8),
            Text("Status: ${status.toUpperCase()}"),
            const SizedBox(height: 24),
            const Text(
              "Bids for this Project",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('bids')
                    .where('projectId', isEqualTo: projectId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Text("No bids yet for this project.");
                  }

                  final bidDocs = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: bidDocs.length,
                    itemBuilder: (context, index) {
                      final bid = bidDocs[index].data() as Map<String, dynamic>;
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        elevation: 3,
                        child: ListTile(
                          title: Text("Bidder: ${bid['bidderUsername']}"),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Amount: \$${bid['amount']}"),
                              Text("Details: ${bid['details']}"),
                              Text("Status: ${bid['bid_status']}"),
                              Text("Date: ${bid['updated_at']}"),
                            ],
                          ),
                          isThreeLine: true,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            if (projectData['deletionRequested'] == true)
              const Text(
                "Delete already requested.",
                style: TextStyle(
                    color: Colors.orange, fontWeight: FontWeight.bold),
              )
            else
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => requestDelete(context),
                child: const Text("Request Delete"),
              ),
          ],
        ),
      ),
    );
  }
}
