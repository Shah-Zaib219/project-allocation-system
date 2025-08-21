import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddProjectScreen extends StatefulWidget {
  final String username;

  const AddProjectScreen({super.key, required this.username});

  @override
  State<AddProjectScreen> createState() => _AddProjectScreenState();
}

class _AddProjectScreenState extends State<AddProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final detailsController = TextEditingController();
  final budgetController = TextEditingController();
  final skillsController = TextEditingController();

  DateTime? selectedBidDeadline;
  DateTime? selectedProjectDeadline;
  String? uploadedFileName;
  bool isLoading = false;

  @override
  void dispose() {
    titleController.dispose();
    detailsController.dispose();
    budgetController.dispose();
    skillsController.dispose();
    super.dispose();
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  void _clearForm() {
    titleController.clear();
    detailsController.clear();
    budgetController.clear();
    skillsController.clear();
    selectedBidDeadline = null;
    selectedProjectDeadline = null;
    uploadedFileName = null;
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedBidDeadline == null || selectedProjectDeadline == null) {
      _showSnack("Please select both bid and project deadlines", isError: true);
      return;
    }

    setState(() => isLoading = true);

    final projectId =
        "${widget.username}_${DateTime.now().millisecondsSinceEpoch}";

    // Split skills by commas
    final List<String> skills = skillsController.text
        .split(',')
        .map((e) => e.trim())
        .where((element) => element.isNotEmpty)
        .toList();

    final projectData = {
      'id': projectId,
      'title': titleController.text.trim(),
      'details': detailsController.text.trim(),
      'skills': skills,
      'budget': double.tryParse(budgetController.text.trim()) ?? 0.0,
      'bidDeadline': selectedBidDeadline,
      'projectDeadline': selectedProjectDeadline,
      'fileName': uploadedFileName,
      'createdby': widget.username,
      'status': 'pending',
      'assigned_to': '',
      'createdAt': FieldValue.serverTimestamp(),
    };

    try {
      await FirebaseFirestore.instance
          .collection('projects')
          .doc(projectId)
          .set(projectData);

      await FirebaseFirestore.instance
          .collection('employers')
          .doc(widget.username)
          .update({
        'projects.pending': FieldValue.arrayUnion([projectId]),
        'projects.total': FieldValue.arrayUnion([projectId]),
      });

      _showSnack("✅ Project added successfully!");
      _clearForm();
    } catch (e) {
      debugPrint("Error: $e");
      _showSnack("Failed to add project: $e", isError: true);
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle("Project Information"),
                _buildTextField(titleController, "Project Title"),
                _buildTextField(detailsController, "Project Details",
                    maxLines: 4),
                _buildTextField(budgetController, "Budget (\$)",
                    inputType: TextInputType.number),
                _buildTextField(skillsController, "Skills (comma separated)"),
                const SizedBox(height: 16),
                _buildDatePicker(
                  title: "Last Date to Submit Bid",
                  selectedDate: selectedBidDeadline,
                  onSelect: (picked) =>
                      setState(() => selectedBidDeadline = picked),
                ),
                const SizedBox(height: 16),
                _buildDatePicker(
                  title: "Final Project Deadline",
                  selectedDate: selectedProjectDeadline,
                  onSelect: (picked) =>
                      setState(() => selectedProjectDeadline = picked),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        uploadedFileName ?? "No file selected",
                        style: const TextStyle(color: Color(0xFF5D4DA8)),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() => uploadedFileName = "uploaded_file.pdf");
                      },
                      icon: const Icon(Icons.upload_file,
                          color: Color(0xFF5D4DA8)),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Center(
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5D4DA8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 14),
                          ),
                          child: const Text(
                            "Add Project",
                            style: TextStyle(color: Colors.white, fontSize: 16),
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

  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          title,
          style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5D4DA8)),
        ),
      );

  Widget _buildTextField(TextEditingController controller, String label,
      {int maxLines = 1, TextInputType inputType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF5D4DA8)),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        validator: (value) =>
            (value == null || value.trim().isEmpty) ? "Enter $label" : null,
      ),
    );
  }

  Widget _buildDatePicker({
    required String title,
    required DateTime? selectedDate,
    required Function(DateTime) onSelect,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            selectedDate == null
                ? "$title not selected"
                : "$title: ${selectedDate.toLocal().toString().split(' ')[0]}",
            style: const TextStyle(color: Color(0xFF5D4DA8)),
          ),
        ),
        TextButton(
          onPressed: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime(2100),
            );
            if (picked != null) onSelect(picked);
          },
          style: TextButton.styleFrom(
            backgroundColor: const Color(0xFF5D4DA8),
            foregroundColor: Colors.white,
          ),
          child: const Text("Select Date"),
        ),
      ],
    );
  }
}
