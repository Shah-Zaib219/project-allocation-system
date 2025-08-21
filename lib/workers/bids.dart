import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class MyProjectsPage extends StatefulWidget {
  final String username; // Worker ID
  const MyProjectsPage({super.key, required this.username});

  @override
  State<MyProjectsPage> createState() => _MyProjectsPageState();
}

class _MyProjectsPageState extends State<MyProjectsPage> {
  int totalBids = 0;
  int completedBids = 0;
  int pendingBids = 0;
  int canceledBids = 0;
  int allocatedBids = 0;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    final snapshot = await FirebaseFirestore.instance.collection('bids').get();

    int completedCount = 0;
    int pendingCount = 0;
    int canceledCount = 0;
    int allocatedCount = 0;
    int totalCount = 0;

    for (var doc in snapshot.docs) {
      final data = doc.data();

      if (data['bidderUsername'] == widget.username) {
        final status = data['bid_status']?.toString().toLowerCase() ?? '';

        switch (status) {
          case 'completed':
            completedCount++;
            break;
          case 'pending':
            pendingCount++;
            break;
          case 'canceled':
            canceledCount++;
            break;
          case 'allocated':
            allocatedCount++;
            break;
        }

        totalCount++;
      }
    }

    setState(() {
      totalBids = totalCount;
      completedBids = completedCount;
      pendingBids = pendingCount;
      canceledBids = canceledCount;
      allocatedBids = allocatedCount;
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
      case 'allocated':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Bids")),
      body: Column(
        children: [
          // Stats indicators
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildCircle("Total", totalBids, totalBids == 0 ? 0 : 1.0,
                      Colors.blue),
                  _buildCircle(
                      "Completed",
                      completedBids,
                      totalBids == 0 ? 0 : completedBids / totalBids,
                      Colors.green),
                  _buildCircle(
                      "Pending",
                      pendingBids,
                      totalBids == 0 ? 0 : pendingBids / totalBids,
                      Colors.deepPurple),
                  _buildCircle(
                      "Canceled",
                      canceledBids,
                      totalBids == 0 ? 0 : canceledBids / totalBids,
                      Colors.red),
                  _buildCircle(
                      "Allocated",
                      allocatedBids,
                      totalBids == 0 ? 0 : allocatedBids / totalBids,
                      Colors.blue),
                ],
              ),
            ),
          ),

          // Bid list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('bids').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No bids found."));
                }

                final userBids = <Map<String, dynamic>>[];

                for (var doc in snapshot.data!.docs) {
                  final data = doc.data() as Map<String, dynamic>;

                  if (data['bidderUsername'] == widget.username) {
                    String formattedDate = 'N/A';

                    if (data['timestamp'] is Timestamp) {
                      final timestamp = data['timestamp'] as Timestamp;
                      formattedDate =
                          timestamp.toDate().toString().split(' ').first;
                    } else if (data['updated_at'] != null) {
                      formattedDate = data['updated_at'].toString();
                    }

                    userBids.add({
                      'projectID': data['projectId'],
                      'amount': data['amount'] ?? 'N/A',
                      'details': data['details'] ?? 'N/A',
                      'status': data['bid_status'] ?? 'pending',
                      'submittedDate': formattedDate,
                    });
                  }
                }

                if (userBids.isEmpty) {
                  return const Center(child: Text("No bids found."));
                }

                return ListView.builder(
                  itemCount: userBids.length,
                  itemBuilder: (context, index) {
                    final bid = userBids[index];
                    final status =
                        (bid['status'] ?? 'pending').toString().toLowerCase();

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      color: _getStatusColor(status),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        title: Text(
                          "Bid for Project: ${bid['projectID']}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Text("Amount: \$${bid['amount']}",
                                style: const TextStyle(color: Colors.white)),
                            const SizedBox(height: 4),
                            Text("Details: ${bid['details']}",
                                style: const TextStyle(color: Colors.white)),
                            const SizedBox(height: 4),
                            Text("Status: ${status.toUpperCase()}",
                                style: const TextStyle(color: Colors.white)),
                            const SizedBox(height: 4),
                            Text("Submitted: ${bid['submittedDate']}",
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 12)),
                          ],
                        ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      child: Column(
        children: [
          CircularPercentIndicator(
            radius: 40.0,
            lineWidth: 8.0,
            percent: percent.clamp(0.0, 1.0),
            center: Text(
              "$count",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            progressColor: color,
            backgroundColor: Colors.grey.shade300,
          ),
          const SizedBox(height: 6),
          Text(label,
              style: TextStyle(color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
