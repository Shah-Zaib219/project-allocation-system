class Projects {
  final String projectId;
  final String name;
  final String details;
  final double price;
  List<String> technology;
  final DateTime deadline;
  final String status; // Example: "open", "completed", "canceled"
  final String postedBy; // Employer username
  final Map<String, Map<String, dynamic>> bids;
  // Key: Worker username
  // Value: A map containing message, bid, and status (accept/reject)

  Projects({
    required this.projectId,
    required this.name,
    required this.details,
    required this.price,
    required this.technology,
    required this.deadline,
    required this.status,
    required this.postedBy,
    required this.bids,
  });
}

class Employers {
  String username;
  String name;
  String email;
  String contactNumber;
  String password;
  String gender;
  String organization;
  List<String> totalProjects;
  List<String> completedProjects;
  List<String> pendingProjects;

  Employers({
    required this.username,
    required this.name,
    required this.email,
    required this.contactNumber,
    required this.password,
    required this.gender,
    required this.organization,
    required this.totalProjects,
    required this.completedProjects,
    required this.pendingProjects,
  });
}

// worker.dart
class Workers {
  String username;
  String name;
  String email;
  String contactNumber;
  String password;
  String gender;
  String organization;
  List<String> skills;
  List<String> completedProjects;
  List<String> totalProjects;
  List<Map<String, String>> completedAndCanceledProjects;

  Workers({
    required this.username,
    required this.name,
    required this.email,
    required this.contactNumber,
    required this.password,
    required this.gender,
    required this.organization,
    required this.skills,
    required this.completedProjects,
    required this.totalProjects,
    required this.completedAndCanceledProjects,
  });
}

class CallData {
  // Generate dummy data for Workers
  List<Workers> wo = [
    Workers(
      username: "sadaqat",
      name: "Sadaqat Hussain",
      email: "sadaqat@gmail.com",
      contactNumber: "1234567890",
      password: "123",
      gender: "Male",
      organization: "Tech Corp",
      skills: ["Flutter", "Dart", "Firebase"],
      completedProjects: ["P001", "P002"],
      totalProjects: ["P001", "P002", "P003"],
      completedAndCanceledProjects: [
        {"status": "completed", "projectId": "P001"},
        {"status": "canceled", "projectId": "P003"},
      ],
    ),
    Workers(
      username: "worker02",
      name: "Jane Smith",
      email: "jane.smith@example.com",
      contactNumber: "9876543210",
      password: "securepass",
      gender: "Female",
      organization: "Design Hub",
      skills: ["UI/UX Design", "HTML", "CSS"],
      completedProjects: ["P004"],
      totalProjects: ["P004", "P005"],
      completedAndCanceledProjects: [
        {"status": "completed", "projectId": "P004"},
        {"status": "canceled", "projectId": "P005"},
      ],
    ),
  ];
  List<Workers> generateWorkers() {
    return wo;
  }

  // Generate dummy data for Employers
  List<Employers> generateEmployers() {
    return [
      Employers(
        username: "zammar",
        name: "Zammar Ahmed",
        email: "zammar@gmail.com",
        contactNumber: "1122334455",
        password: "123",
        gender: "Male",
        organization: "Innovative Solutions",
        totalProjects: ["P001", "P002"],
        completedProjects: ["P001"],
        pendingProjects: ["P002"],
      ),
      Employers(
        username: "employer02",
        name: "Bob White",
        email: "bob.white@example.com",
        contactNumber: "5566778899",
        password: "adminpass",
        gender: "Male",
        organization: "NextGen Tech",
        totalProjects: ["P003", "P004"],
        completedProjects: ["P003"],
        pendingProjects: ["P004"],
      ),
    ];
  }

  List<Projects> pro = [
    Projects(
      projectId: "P001",
      name: "E-Commerce App",
      details: "Build an e-commerce app with payment gateway integration.",
      price: 5000.0,
      technology: ['a'],
      deadline: DateTime.now().add(const Duration(days: 30)),
      status: "pending",
      postedBy: "zammar",
      bids: {
        "worker01": {
          "message": "I have prior experience with e-commerce apps.",
          "bid": 4800.0,
          "status": "pending",
        },
        "worker02": {
          "message": "I can deliver this within 3 weeks.",
          "bid": 4700.0,
          "status": "pending",
        },
      },
    ),
    Projects(
      projectId: "P002",
      name: "Portfolio Website",
      details: "Create a modern portfolio website with responsive design.",
      price: 2000.0,
      technology: ['a'],
      deadline: DateTime.now().add(const Duration(days: 15)),
      status: "completed",
      postedBy: "employer01",
      bids: {
        "worker01": {
          "message": "I specialize in portfolio websites.",
          "bid": 1900.0,
          "status": "accepted",
        },
      },
    ),
    Projects(
      projectId: "P003",
      name: "Ecommerce Website",
      details: "Create a modern portfolio website with responsive design.",
      price: 2000.0,
      technology: ['React'],
      deadline: DateTime.now().add(const Duration(days: 15)),
      status: "pending",
      postedBy: "zammar",
      bids: {
        "worker01": {
          "message": "I specialize in portfolio websites.",
          "bid": 1900.0,
          "status": "pending",
        },
      },
    ),
  ];
  // Generate dummy data for Projects
  List<Projects> generateProjects() {
    return pro;
  }
}
