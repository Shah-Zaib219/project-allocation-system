import 'package:flutter/material.dart';
import 'data.dart'; // Importing the data file

class ProjectDetailsPage extends StatefulWidget {
  final Projects project; // Receiving a project object of type Projects

  // Constructor to receive data
  const ProjectDetailsPage({required this.project, super.key});

  @override
  _ProjectDetailsPageState createState() => _ProjectDetailsPageState();
}

class _ProjectDetailsPageState extends State<ProjectDetailsPage> {
  // Controller for the budget input field and the message field
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  // Submit button action
  void _submitBid() {
    final newBudget = _budgetController.text;
    final message = _messageController.text;

    if (newBudget.isNotEmpty && message.isNotEmpty) {
      // Handle the bid and message submission (e.g., save to database, update UI, etc.)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Bid and message submitted successfully!')),
      );

      // Show confirmation message in a dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Bid Submitted'),
            content: const Text(
                'After reviewing your bid, you will be notified if the project is assigned to you.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                  Navigator.of(context)
                      .pop(); // Go back to the previous screen (dashboard or list page)
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid bid and message')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 117, 97, 204),
        title: Text(
          widget.project.name, // Accessing the project name from the object
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Project name, details, and budget display
              Card(
                elevation: 5,
                margin: const EdgeInsets.only(bottom: 16.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Project Name: ${widget.project.name}', // Accessing name
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Details: ${widget.project.details}', // Accessing details
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Deadline: ${widget.project.deadline.toLocal().toString().split(' ')[0]}', // Formatting deadline
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Budget: \$${widget.project.price}', // Accessing price as budget
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Technologies: ${widget.project.technology.join(', ')}', // Joining technology list
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
              ),

              // Download Document Icon
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.file_download),
                    onPressed: () {
                      // Handle document download
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Downloading documents...')),
                      );
                    },
                    color: Colors.blue,
                    iconSize: 30,
                  ),
                  const Text('Download Project Documents'),
                ],
              ),
              const SizedBox(height: 20),

              // Bid Input Field and Message Input Field
              const Text(
                'Enter Your Bid and Message:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _budgetController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter Your Bid:',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Write Your Message:',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitBid,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 117, 97, 204),
                  padding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 4),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text(
                  'Submit Bid and Message',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
