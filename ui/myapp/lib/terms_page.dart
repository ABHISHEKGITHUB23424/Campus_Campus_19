import 'package:flutter/material.dart';

/// Terms & Conditions Page - Display terms of service
class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        title: const Text(
          'Terms & Conditions',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Last Updated: November 17, 2025',
              style: TextStyle(
                fontSize: 13,
                color: Colors.white54,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 24),

            _buildSection(
              title: '1. Acceptance of Terms',
              content:
                  'By accessing and using the Faculty App, you accept and agree to be bound by the terms and provision of this agreement. If you do not agree to abide by the above, please do not use this application.',
            ),

            _buildSection(
              title: '2. Use of Service',
              content:
                  'This application is provided for the exclusive use of authorized faculty members and administrators of the University. You agree to use the app only for lawful purposes and in accordance with these Terms.',
            ),

            _buildSection(
              title: '3. User Accounts',
              content:
                  'You are responsible for maintaining the confidentiality of your account credentials. You agree to accept responsibility for all activities that occur under your account. You must notify us immediately of any unauthorized use of your account.',
            ),

            _buildSection(
              title: '4. Data Collection and Use',
              content:
                  'We collect and use information in accordance with our Privacy Policy. By using the Faculty App, you consent to the collection and use of information as described in our Privacy Policy.',
            ),

            _buildSection(
              title: '5. Attendance Management',
              content:
                  'Faculty members are responsible for accurately marking and maintaining student attendance records. The University reserves the right to audit attendance records for accuracy and compliance.',
            ),

            _buildSection(
              title: '6. Intellectual Property',
              content:
                  'The Faculty App and its original content, features, and functionality are owned by the University and are protected by international copyright, trademark, and other intellectual property laws.',
            ),

            _buildSection(
              title: '7. Prohibited Activities',
              content:
                  'You agree not to:\n• Share your account credentials with unauthorized users\n• Access data or systems you are not authorized to access\n• Modify, adapt, or hack the application\n• Use the app for any illegal or unauthorized purpose\n• Transmit any viruses or malicious code',
            ),

            _buildSection(
              title: '8. Termination',
              content:
                  'We may terminate or suspend your access to the Faculty App immediately, without prior notice or liability, for any reason whatsoever, including without limitation if you breach the Terms.',
            ),

            _buildSection(
              title: '9. Limitation of Liability',
              content:
                  'In no event shall the University, nor its directors, employees, partners, agents, suppliers, or affiliates, be liable for any indirect, incidental, special, consequential or punitive damages resulting from your use of the Faculty App.',
            ),

            _buildSection(
              title: '10. Changes to Terms',
              content:
                  'We reserve the right to modify or replace these Terms at any time. We will provide notice of any changes by posting the new Terms on this page. Your continued use of the Faculty App after any such changes constitutes your acceptance of the new Terms.',
            ),

            _buildSection(
              title: '11. Governing Law',
              content:
                  'These Terms shall be governed and construed in accordance with the laws of the jurisdiction in which the University operates, without regard to its conflict of law provisions.',
            ),

            _buildSection(
              title: '12. Contact Information',
              content:
                  'If you have any questions about these Terms, please contact us at:\n\nEmail: legal@university.edu\nPhone: +1 (800) 123-4567\nAddress: University Legal Department, Main Campus',
            ),

            const SizedBox(height: 32),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Color(0xFF00ADB5),
                    size: 24,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: const Text(
                      'By using the Faculty App, you acknowledge that you have read and understood these Terms & Conditions.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}