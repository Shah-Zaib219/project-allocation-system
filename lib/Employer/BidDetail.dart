import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
    final reviewsRef = FirebaseFirestore.instance
        .collection('bids')
        .doc(bidId)
        .collection(
            'reviews'); // Assuming reviews are stored under 'reviews' sub-collection

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF5D4DA8),
        title: const Text("Bid Details"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
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

            // Display reviews if available
            StreamBuilder<QuerySnapshot>(
              stream: reviewsRef.snapshots(),
              builder: (context, reviewsSnapshot) {
                if (reviewsSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                if (!reviewsSnapshot.hasData ||
                    reviewsSnapshot.data!.docs.isEmpty) {
                  return const Text("No reviews yet.");
                }

                final reviews = reviewsSnapshot.data!.docs;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: reviews.map((reviewDoc) {
                    final review = reviewDoc.data() as Map<String, dynamic>;
                    final reviewer = review['reviewer'] ?? 'Anonymous';
                    final rating = review['rating'] ?? 0;
                    final reviewText = review['review'] ?? 'No review provided';

                    return Card(
                      color: Colors.grey[200],
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        title: Text("$reviewer (Rating: $rating/5)"),
                        subtitle: Text(reviewText),
                      ),
                    );
                  }).toList(),
                );
              },
            ),

            const SizedBox(height: 20),

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
        ),
      ),
    );
  }

  Future<void> _updateBidStatus(BuildContext context, String newStatus) async {
    final bidsRef = FirebaseFirestore.instance
        .collection('projects')
        .doc(projectId)
        .collection('bids')
        .doc(bidId);
    final projectRef =
        FirebaseFirestore.instance.collection('projects').doc(projectId);

    try {
      if (newStatus == 'accepted') {
        final acceptedBidDoc = await bidsRef.get();
        final acceptedBid = acceptedBidDoc.data();

        if (acceptedBid == null) throw Exception("Bid data not found.");

        final String bidderUsername = acceptedBid['bidby'] ?? 'Unknown';

        await bidsRef.update({
          'status': 'accepted',
          'updated_at': DateTime.now().toIso8601String(),
        });

        // Update project status
        await projectRef.update({
          'status': 'allocated',
          'assigned_to': bidderUsername,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Bid accepted and project allocated.")),
        );
      } else {
        await bidsRef.update({
          'status': 'rejected',
          'updated_at': DateTime.now().toIso8601String(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Bid $newStatus successfully.")),
        );
      }

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update bid: $e")),
      );
    }
  }
}
