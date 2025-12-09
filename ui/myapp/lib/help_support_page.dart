import 'package:flutter/material.dart';

/// Help & Support Page - FAQs and support contact options
class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        title: const Text(
          'Help & Support',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Contact Support Card
          _buildContactSupportCard(context),

          const SizedBox(height: 24),

          // FAQ Section Header
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Text(
              'Frequently Asked Questions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // FAQ Items
          _buildFAQItem(
            question: 'How do I mark attendance?',
            answer:
                'Navigate to the Attendance tab and tap on the class you want to mark. Select present or absent for each student and save the attendance.',
          ),
          const SizedBox(height: 12),
          _buildFAQItem(
            question: 'How can I view my timetable?',
            answer:
                'Go to the Timetable tab to view your complete schedule. You can see all your classes organized by day and time.',
          ),
          const SizedBox(height: 12),
          _buildFAQItem(
            question: 'How do I update my profile information?',
            answer:
                'Go to the Profile tab and tap the edit icon in the top right corner. Update your information and tap Save Changes.',
          ),
          const SizedBox(height: 12),
          _buildFAQItem(
            question: 'What if I forgot my password?',
            answer:
                'On the login screen, tap "Forgot Password" and follow the instructions to reset your password via email.',
          ),
          const SizedBox(height: 12),
          _buildFAQItem(
            question: 'How do I enable notifications?',
            answer:
                'Go to Profile > Notifications and toggle the switches for the types of notifications you want to receive.',
          ),
          const SizedBox(height: 12),
          _buildFAQItem(
            question: 'Can I change my password?',
            answer:
                'Yes, go to Profile > Privacy & Security and use the Change Password section to update your password.',
          ),
          const SizedBox(height: 12),
          _buildFAQItem(
            question: 'How do I report a bug?',
            answer:
                'Use the Contact Support button above to email our support team with details about the issue you\'re experiencing.',
          ),
          const SizedBox(height: 12),
          _buildFAQItem(
            question: 'Is my data secure?',
            answer:
                'Yes, we use industry-standard encryption and security measures to protect your personal information and data.',
          ),

          const SizedBox(height: 32),

          // Additional Help Section
          _buildAdditionalHelpCard(),
        ],
      ),
    );
  }

  Widget _buildContactSupportCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.headset_mic_outlined,
            size: 48,
            color: Color(0xFF00ADB5),
          ),
          const SizedBox(height: 16),
          const Text(
            'Need Help?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Our support team is here to help you',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.white70),
          ),
          const SizedBox(height: 24),

          // Email Support
          _buildContactOption(
            icon: Icons.email_outlined,
            title: 'Email Support',
            value: 'support@university.edu',
            onTap: () {
              // Dummy action - would normally open email app
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Opening email app...'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
          const SizedBox(height: 12),

          // Phone Support
          _buildContactOption(
            icon: Icons.phone_outlined,
            title: 'Phone Support',
            value: '+1 (800) 123-4567',
            onTap: () {
              // Dummy action - would normally open phone app
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Opening phone app...'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // Contact Support Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Opening support form...'),
                    backgroundColor: Colors.black,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00ADB5),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Contact Support',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactOption({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            Icon(icon, color: Color(0xFF00ADB5), size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 13, color: Colors.white54),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white30),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem({required String question, required String answer}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: ThemeData(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          title: Text(
            question,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          iconColor: Color(0xFF00ADB5),
          collapsedIconColor: Colors.white54,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          children: [
            Text(
              answer,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalHelpCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          const Icon(Icons.info_outline, size: 32, color: Color(0xFF00ADB5)),
          const SizedBox(height: 12),
          const Text(
            'Still Need Help?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'If you couldn\'t find the answer to your question, please don\'t hesitate to contact our support team. We\'re here to help!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.white70, height: 1.5),
          ),
        ],
      ),
    );
  }
}