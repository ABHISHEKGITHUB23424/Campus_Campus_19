import 'package:flutter/material.dart';

/// Privacy Policy Page - Display privacy policy information
class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        title: const Text(
          'Privacy Policy',
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
              'Effective Date: November 17, 2025',
              style: TextStyle(
                fontSize: 13,
                color: Colors.white54,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 24),

            _buildSection(
              title: 'Introduction',
              content:
                  'This Privacy Policy describes how the Faculty App ("we", "our", or "us") collects, uses, and shares information about you when you use our mobile application. We are committed to protecting your privacy and ensuring the security of your personal information.',
            ),

            _buildSection(
              title: '1. Information We Collect',
              content:
                  'We collect the following types of information:\n\n• Personal Information: Name, email address, phone number, employee ID, department, and qualification\n• Professional Information: Teaching schedule, attendance records, course information\n• Usage Data: App interactions, features used, and session duration\n• Device Information: Device type, operating system, and app version',
            ),

            _buildSection(
              title: '2. How We Use Your Information',
              content:
                  'We use the collected information for the following purposes:\n\n• To provide and maintain the Faculty App services\n• To manage your account and profile\n• To facilitate attendance tracking and timetable management\n• To send you notifications and updates\n• To improve our services and user experience\n• To ensure security and prevent fraud',
            ),

            _buildSection(
              title: '3. Information Sharing',
              content:
                  'We do not sell your personal information. We may share your information only in the following circumstances:\n\n• With university administrators for academic purposes\n• With IT support staff for technical assistance\n• When required by law or legal process\n• To protect the rights and safety of the University and its community',
            ),

            _buildSection(
              title: '4. Data Security',
              content:
                  'We implement appropriate technical and organizational measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction. This includes:\n\n• Encryption of data in transit and at rest\n• Secure authentication mechanisms\n• Regular security audits and updates\n• Access controls and monitoring',
            ),

            _buildSection(
              title: '5. Data Retention',
              content:
                  'We retain your personal information for as long as necessary to fulfill the purposes outlined in this Privacy Policy, unless a longer retention period is required or permitted by law. Attendance records and academic data may be retained according to university policy.',
            ),

            _buildSection(
              title: '6. Your Rights',
              content:
                  'You have the right to:\n\n• Access your personal information\n• Correct inaccurate data\n• Request deletion of your data (subject to legal requirements)\n• Opt-out of certain data collection\n• Withdraw consent where applicable\n• File a complaint with relevant authorities',
            ),

            _buildSection(
              title: '7. Cookies and Tracking',
              content:
                  'The Faculty App may use cookies and similar tracking technologies to enhance user experience and collect usage information. You can control cookie settings through your device preferences.',
            ),

            _buildSection(
              title: '8. Third-Party Services',
              content:
                  'The app may contain links to third-party services or integrate with external platforms. We are not responsible for the privacy practices of these third parties. We encourage you to review their privacy policies.',
            ),

            _buildSection(
              title: '9. Children\'s Privacy',
              content:
                  'The Faculty App is intended for use by faculty members and authorized staff only. We do not knowingly collect information from individuals under the age of 18.',
            ),

            _buildSection(
              title: '10. Changes to Privacy Policy',
              content:
                  'We may update this Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page and updating the effective date. Your continued use of the Faculty App after changes are posted constitutes acceptance of the updated policy.',
            ),

            _buildSection(
              title: '11. International Data Transfers',
              content:
                  'Your information may be transferred to and processed in countries other than your country of residence. We ensure appropriate safeguards are in place to protect your information in accordance with this Privacy Policy.',
            ),

            _buildSection(
              title: '12. Contact Us',
              content:
                  'If you have any questions, concerns, or requests regarding this Privacy Policy or our data practices, please contact us:\n\nPrivacy Officer\nEmail: privacy@university.edu\nPhone: +1 (800) 123-4567\nAddress: University Data Protection Office, Main Campus',
            ),

            const SizedBox(height: 32),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.shield_outlined,
                        color: Color(0xFF00ADB5),
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: const Text(
                          'Your Privacy Matters',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'We are committed to protecting your personal information and respecting your privacy. If you have any concerns about how we handle your data, please don\'t hesitate to contact our Privacy Officer.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white70,
                      height: 1.5,
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