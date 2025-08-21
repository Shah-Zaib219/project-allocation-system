import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import intl package for date formatting
import 'ProjectDetailsPage.dart';

class PendingProjectsPage extends StatelessWidget {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final String orgusername;
  final String username;

  PendingProjectsPage({
    super.key,
    required this.orgusername,
    required this.username,
  });

  Future<List<Map<String, dynamic>>> _getFilteredProjects() async {
    print('Fetching projects for organization: $orgusername');

    final projectsSnapshot = await firestore
        .collection('projects')
        .where('orgusername', isEqualTo: orgusername)
        .get();

    print('Projects Retrieved: ${projectsSnapshot.docs.length}');

    final userSnapshot =
        await firestore.collection('workers').doc(username).get();
    final userData = userSnapshot.data();

    if (userData == null) {
      print('No user data found for $username');
      return [];
    }

    List<String> userSkills = List<String>.from(userData['skills'] ?? []);
    userSkills = userSkills.map((s) => s.toLowerCase()).toList();
    print('User Skills: $userSkills');

    final allProjects = projectsSnapshot.docs;
    List<Map<String, dynamic>> filteredProjects = [];

    for (var doc in allProjects) {
      final projectData = doc.data();
      final projectId = doc['id'];
      projectData['id'] = projectId;

      // Handle deadline fields
      final bidDeadlineTimestamp = projectData['bidDeadline'];
      final projectDeadlineTimestamp = projectData['projectDeadline'];

      DateTime? bidDeadline;
      DateTime? projectDeadline;

      if (bidDeadlineTimestamp is Timestamp) {
        bidDeadline = bidDeadlineTimestamp.toDate();
        print('Bid Deadline: $bidDeadline');
      } else {
        print(
            'Skipping project (no valid bid deadline): ${projectData['title']}');
        continue;
      }

      if (projectDeadlineTimestamp is Timestamp) {
        projectDeadline = projectDeadlineTimestamp.toDate();
        print('Project Deadline: $projectDeadline');
      } else {
        print(
            'Skipping project (no valid project deadline): ${projectData['title']}');
        continue;
      }

      // Check if the bid deadline has passed
      if (bidDeadline.isBefore(DateTime.now())) {
        print('Skipping expired bid deadline project: ${projectData['title']}');
        continue;
      }

      // Check for allow multiple workers
      final allowMultiple =
          projectData['allowmultipleworkers'] == 'yes'; // Convert to boolean
      List<String> projectSkills =
          List<String>.from(projectData['skills'] ?? []);
      projectSkills = projectSkills.map((s) => s.toLowerCase()).toList();

      print('Checking project: ${projectData['title']}');
      print('Project Skills: $projectSkills');
      print('Allow Multiple Workers: $allowMultiple');

      // Check if user already bid
      final bidsQuery = await firestore
          .collection('bids')
          .where('projectId', isEqualTo: projectId)
          .where('bidderUsername', isEqualTo: username)
          .limit(1)
          .get();

      final bool hasBid = bidsQuery.docs.isNotEmpty;
      if (hasBid) {
        print('User already bid on project: ${projectData['title']}');
        continue;
      }

      // Skill matching logic
      bool skillMatch = false;
      if (allowMultiple) {
        // At least one matching skill
        skillMatch = userSkills.any((skill) => projectSkills.contains(skill));
        print('Skill Match (multiple workers allowed): $skillMatch');
      } else {
        // Must have all required project skills
        skillMatch = projectSkills.every((skill) => userSkills.contains(skill));
        print('Skill Match (single worker required all skills): $skillMatch');
      }

      if (skillMatch) {
        filteredProjects.add(projectData);
        print('✅ Project Added: ${projectData['title']}');
      } else {
        print('❌ Skills not matching for project: ${projectData['title']}');
      }
    }

    print('Total Filtered Projects: ${filteredProjects.length}');
    return filteredProjects;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getFilteredProjects(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final filteredProjects = snapshot.data ?? [];

          if (filteredProjects.isEmpty) {
            return const Center(
                child: Text('No available projects to bid on.'));
          }

          return ListView.builder(
            itemCount: filteredProjects.length,
            itemBuilder: (context, index) {
              final project = filteredProjects[index];

              // Format project deadline
              final projectDeadline = project['projectDeadline'];
              String formattedDeadline = 'N/A';
              if (projectDeadline is Timestamp) {
                final DateTime deadlineDate = projectDeadline.toDate();
                formattedDeadline =
                    DateFormat.yMMMd().add_jm().format(deadlineDate);
              }

              return Card(
                margin: const EdgeInsets.all(10),
                color: const Color(0xFF5D4DA8),
                child: ListTile(
                  title: Text(
                    project['title'] ?? 'Untitled Project',
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    'Deadline: $formattedDeadline\n'
                    'Budget: \$${project['budget'] ?? 0}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white),
                  ),
                  trailing:
                      const Icon(Icons.arrow_forward, color: Colors.white),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProjectDetailsPage(
                          project: project,
                          currentUsername: username,
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
    );
  }
}
