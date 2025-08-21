import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EmployerPendingProjectsScreen extends StatelessWidget {
  final String username;

  const EmployerPendingProjectsScreen({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    final projectsRef = FirebaseFirestore.instance.collection('projects');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF5D4DA8),
        title: const Text("Your Pending Projects' Bids"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: projectsRef
            .where('createdby', isEqualTo: username)
            .where('status', isEqualTo: 'pending')
            .snapshots(),
        builder: (context, projectSnapshot) {
          if (projectSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!projectSnapshot.hasData || projectSnapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No pending projects found."));
          }

          final projects = projectSnapshot.data!.docs;

          return ListView.builder(
            itemCount: projects.length,
            itemBuilder: (context, index) {
              final project = projects[index];
              final projectId = project.id;
              final projectTitle = project['title'] ?? 'Untitled Project';

              return Card(
                margin: const EdgeInsets.all(10),
                color: Colors.white,
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ExpansionTile(
                  title: Text(
                    projectTitle,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5D4DA8),
                    ),
                  ),
                  subtitle: const Text("Tap to see bids"),
                  children: [
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('bids')
                          .where('projectId', isEqualTo: projectId)
                          .where('status', isEqualTo: 'pending')
                          .snapshots(),
                      builder: (context, bidsSnapshot) {
                        if (bidsSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (!bidsSnapshot.hasData ||
                            bidsSnapshot.data!.docs.isEmpty) {
                          return const ListTile(
                            title: Text("No pending bids."),
                          );
                        }

                        final bids = bidsSnapshot.data!.docs;

                        return Column(
                          children: bids.map((bidDoc) {
                            final bid = bidDoc.data() as Map<String, dynamic>;
                            final bidId = bidDoc.id;

                            // Ensure bidPrice is converted to double and default to 0.0 if null or invalid
                            final bidPrice =
                                double.tryParse(bid['bidPrice'].toString()) ??
                                    0.0;

                            final description = bid['description'] ?? '';
                            final status = bid['status'] ?? '';
                            final submittedAt = bid['submittedAt'];
                            final bidderUsername = bid['bidby'] ?? 'Unknown';

                            // Convert Timestamp to String
                            String formattedSubmittedAt = '';
                            if (submittedAt is Timestamp) {
                              formattedSubmittedAt = (submittedAt as Timestamp)
                                  .toDate()
                                  .toString();
                            } else {
                              formattedSubmittedAt = submittedAt.toString();
                            }

                            return ListTile(
                              title: Text(
                                "Bid: \$${bidPrice.toStringAsFixed(2)}", // Safe to call toStringAsFixed() now
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Description: $description"),
                                  Text("Status: $status"),
                                  Text("Submitted At: $formattedSubmittedAt"),
                                  Text("Bidder Username: $bidderUsername"),
                                ],
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BidDetailsScreen(
                                      projectId: projectId,
                                      bidId: bidId,
                                      bidPrice: bidPrice,
                                      description: description,
                                      status: status,
                                      submittedAt: formattedSubmittedAt,
                                      bidderUsername: bidderUsername,
                                    ),
                                  ),
                                );
                              },
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class BidDetailsScreen extends StatelessWidget {
  final String projectId;
  final String bidId;
  final double bidPrice;
  final String description;
  final String status;
  final String submittedAt;
  final String bidderUsername;

  const BidDetailsScreen({
    super.key,
    required this.projectId,
    required this.bidId,
    required this.bidPrice,
    required this.description,
    required this.status,
    required this.submittedAt,
    required this.bidderUsername,
  });

  @override
  Widget build(BuildContext context) {
    print(bidId);
    final orgRef = FirebaseFirestore.instance
        .collection('organizations')
        .doc(bidderUsername);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF5D4DA8),
        title: const Text("Bid Details"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<DocumentSnapshot>(
          future: orgRef.get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: Text('Organization not found.'));
            }

            final organization = snapshot.data!.data() as Map<String, dynamic>;
            final rating = organization['rating'] ?? 0;
            final reviews = List<String>.from(organization['reviews'] ?? []);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Amount: \$${bidPrice.toStringAsFixed(2)}",
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 10),
                Text("Description: $description"),
                const SizedBox(height: 10),
                Text("Status: $status"),
                const SizedBox(height: 10),
                Text("Submitted: $submittedAt"),
                const SizedBox(height: 10),
                Text("Bidder Username: $bidderUsername"),
                const SizedBox(height: 20),

                // Displaying the rating
                Row(
                  children: [
                    const Text("Rating: "),
                    Icon(
                      Icons.star,
                      color: Colors.yellow,
                      size: 20,
                    ),
                    const SizedBox(width: 5),
                    Text(rating.toString(),
                        style: const TextStyle(fontSize: 18)),
                  ],
                ),
                const SizedBox(height: 10),

                // Displaying the reviews
                const Text("Reviews:",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                reviews.isEmpty
                    ? const Text("No reviews yet.")
                    : Column(
                        children: reviews.map((review) {
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(review),
                            ),
                          );
                        }).toList(),
                      ),

                // Buttons to accept or reject the bid
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5D4DA8),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => _updateBidStatus(context, 'accepted'),
                      child: const Text("Accept"),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5D4DA8),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => _updateBidStatus(context, 'rejected'),
                      child: const Text("Reject"),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _updateBidStatus(BuildContext context, String newStatus) async {
    final bidsRef = FirebaseFirestore.instance
        .collection('bids'); // Reference to the 'bids' collection
    final projectRef = FirebaseFirestore.instance
        .collection('projects')
        .doc(projectId); // Reference to the specific project

    try {
      if (newStatus == 'accepted') {
        // Fetch the specific bid document for the given bidId
        final acceptedBidDoc = await bidsRef.doc(bidId).get();
        final acceptedBid = acceptedBidDoc.data();

        if (acceptedBid == null) {
          throw Exception("Bid data not found.");
        }

        // Update the selected bid to 'accepted'
        await bidsRef.doc(bidId).update({
          'status': 'accepted',
          'updated_at': DateTime.now().toIso8601String(),
        });

        // Reject all other bids for the same project
        final allBids =
            await bidsRef.where('projectId', isEqualTo: projectId).get();
        for (var bid in allBids.docs) {
          if (bid.id != bidId) {
            await bid.reference.update({
              'status': 'rejected',
              'updated_at': DateTime.now().toIso8601String(),
            });
          }
        }

        // Update project status to 'allocated' after accepting the bid
        await projectRef.update({
          'status': 'allocated',
          'assigned_to':
              acceptedBid['bidby'], // Assign the bidder who got accepted
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Bid accepted and all other bids rejected.")),
        );
      } else {
        // Update the selected bid status to 'rejected'
        await bidsRef.doc(bidId).update({
          'status': 'rejected',
          'updated_at': DateTime.now().toIso8601String(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Bid $newStatus successfully.")),
        );
      }

      // Pop the screen after the update
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update bid: $e")),
      );
    }
  }
}
