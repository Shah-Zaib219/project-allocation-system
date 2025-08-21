import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'projectdetails.dart';

class MyProjectsPage extends StatefulWidget {
  final String username;
  const MyProjectsPage({super.key, required this.username});

  @override
  State<MyProjectsPage> createState() => _MyProjectsPageState();
}

class _MyProjectsPageState extends State<MyProjectsPage> {
  int total = 0;
  int completed = 0;
  int pending = 0;
  int canceled = 0;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('projects')
        .where('createdby', isEqualTo: widget.username)
        .get();

    int completedCount = 0;
    int pendingCount = 0;
    int canceledCount = 0;

    for (var doc in snapshot.docs) {
      final data = doc.data();
      switch (data['status']) {
        case 'completed':
          completedCount++;
          break;
        case 'pending':
          pendingCount++;
          break;
        case 'canceled':
          canceledCount++;
          break;
      }
    }

    setState(() {
      total = snapshot.size;
      completed = completedCount;
      pending = pendingCount;
      canceled = canceledCount;
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.deepPurple;
      case 'canceled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Progress indicators
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCircle("Total", total, total == 0 ? 0 : 1.0, Colors.blue),
                _buildCircle("Completed", completed,
                    total == 0 ? 0 : completed / total, Colors.green),
                _buildCircle("Pending", pending,
                    total == 0 ? 0 : pending / total, Colors.deepPurple),
                _buildCircle("Canceled", canceled,
                    total == 0 ? 0 : canceled / total, Colors.red),
              ],
            ),
          ),

          // Project list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('projects')
                  .where('createdby', isEqualTo: widget.username)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No projects found."));
                }

                final projects = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: projects.length,
                  itemBuilder: (context, index) {
                    final project =
                        projects[index].data() as Map<String, dynamic>;
                    final status = (project['status'] ?? 'pending')
                        .toString()
                        .toLowerCase();
                    final deletionRequested =
                        project['deletionRequested'] == true;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      color: _getStatusColor(status),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        title: Text(
                          project['title'] ?? 'Untitled',
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Text("Status: ${status.toUpperCase()}",
                                style: const TextStyle(color: Colors.white)),
                            if (deletionRequested)
                              const Padding(
                                padding: EdgeInsets.only(top: 6.0),
                                child: Text(
                                  "Delete Requested",
                                  style: TextStyle(
                                      color: Colors.orangeAccent,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProjectDetailScreen(
                                projectData: project,
                                projectId: projects[index].id,
                                username: widget.username,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircle(String label, int count, double percent, Color color) {
    return Column(
      children: [
        CircularPercentIndicator(
          radius: 40.0,
          lineWidth: 8.0,
          percent: percent.clamp(0.0, 1.0),
          center: Text("$count",
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          progressColor: color,
          backgroundColor: Colors.grey.shade300,
        ),
        const SizedBox(height: 6),
        Text(label,
            style: TextStyle(color: color, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
