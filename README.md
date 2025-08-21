Projex – Worker–Employer Platform (Flutter & Firebase)

I named this project Projex because it represents a Project Exchange platform where Employers can post tasks, and Workers can bid, collaborate, and deliver results seamlessly. It is inspired by platforms like Upwork but customized for easier management with a strong focus on skills, deadlines, and transparency.

✨ Key Features

Employer Panel: Post projects with budget, skills, and deadlines. Review bids and hire based on worker profiles.

Worker Panel: View skill-matched projects (before deadline), place bids, track bid status & project progress. Update work status (0%, 25%, 50%, 75%, 100%).

Employer Actions: Accept one bid, track project updates, mark projects as completed, give ratings & reviews.

Worker Dashboard: View completed projects, accepted bids, average rating, total earnings, client reviews, and project history.

Admin Panel (Web): Manage users, activate/deactivate accounts, add skills, monitor projects & system activities.

Local Storage (Sqflite): Cache sessions to avoid repeated logins and ensure smooth offline support.

Notifications: Real-time updates from Admin and system alerts.

User Support: In-app Help Section with guidelines, FAQs, and support.

Report System: Workers and Employers can report issues or misconduct, flagged directly to the Admin.

Easy Logout: One-tap logout for quick and secure session handling.

📂 Project Structure

lib/ – Main Flutter application code (UI, logic, services).

android/ & ios/ – Native platform code for Flutter integration.

assets/ – Icons, images, and static files.

projex_admin_panel/ – Web-based Admin Panel.

local_db/ – Sqflite setup for offline storage.

🚀 Future Improvements

To make Projex more professional, I plan to add:

🔒 Secure Payments & Escrow System

📊 Advanced Analytics (project performance, earnings insights, etc.)

🤖 AI-based Skill Matching

🛠 Role-Based Dashboards (different UIs for employers, workers, and admins)

These upgrades will make it comparable to global freelancing platforms like Upwork and Fiverr.

🛠 Tech Stack

Frontend & App: Flutter

Backend & Database: Firebase (Auth, Firestore, Storage, Notifications)

Local Database: Sqflite (for offline caching & sessions)

Admin Panel: Web (Flutter Web/Firebase integrated)