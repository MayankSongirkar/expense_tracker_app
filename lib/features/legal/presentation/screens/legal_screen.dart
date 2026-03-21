/// Legal Compliance Screen
/// 
/// Provides access to Privacy Policy and Terms of Use for legal compliance.
/// Required for app store publication and regulatory compliance.
/// 
/// Key Features:
/// - Privacy Policy display with proper formatting
/// - Terms of Use with clear sections
/// - Easy navigation and readability
/// - Compliance with app store requirements
/// - Professional presentation

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Legal compliance screen for Privacy Policy and Terms of Use
/// 
/// This screen provides users with easy access to legal documents
/// required for app store compliance and regulatory requirements.
class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Legal Information'),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: Theme.of(context).brightness == Brightness.dark
                ? [const Color(0xFF020617), const Color(0xFF0F172A)]
                : [const Color(0xFFFAFAFA), const Color(0xFFFFFFFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildHeader(context),
            const SizedBox(height: 24),
            _buildLegalCard(
              context,
              title: 'Privacy Policy',
              description: 'Learn how we collect, use, and protect your data',
              icon: Icons.privacy_tip_outlined,
              onTap: () => _showPrivacyPolicy(context),
            ),
            const SizedBox(height: 16),
            _buildLegalCard(
              context,
              title: 'Terms of Use',
              description: 'Understand the terms and conditions for using our app',
              icon: Icons.description_outlined,
              onTap: () => _showTermsOfUse(context),
            ),
            const SizedBox(height: 24),
            _buildComplianceInfo(context),
          ],
        ),
      ),
    );
  }

  /// Builds the header section with title and description
  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Legal Information',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Your privacy and rights are important to us. Please review our legal documents.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withOpacity(0.7)
                : const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  /// Builds a legal document card
  Widget _buildLegalCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white.withOpacity(0.7)
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withOpacity(0.5)
                    : const Color(0xFF94A3B8),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds compliance information section
  Widget _buildComplianceInfo(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.verified_user_outlined,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Compliance & Security',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildComplianceItem(context, 'GDPR Compliant', 'European data protection standards'),
            _buildComplianceItem(context, 'Local Storage', 'All data stored securely on your device'),
            _buildComplianceItem(context, 'No Data Sharing', 'We never share your personal information'),
            _buildComplianceItem(context, 'Regular Updates', 'Security patches and improvements'),
          ],
        ),
      ),
    );
  }

  /// Builds individual compliance item
  Widget _buildComplianceItem(BuildContext context, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withOpacity(0.7)
                        : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Shows Privacy Policy in a modal bottom sheet
  void _showPrivacyPolicy(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildLegalDocument(
        context,
        title: 'Privacy Policy',
        content: _getPrivacyPolicyContent(),
      ),
    );
  }

  /// Shows Terms of Use in a modal bottom sheet
  void _showTermsOfUse(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildLegalDocument(
        context,
        title: 'Terms of Use',
        content: _getTermsOfUseContent(),
      ),
    );
  }

  /// Builds legal document viewer
  Widget _buildLegalDocument(BuildContext context, {
    required String title,
    required String content,
  }) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              const Divider(),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: SelectableText(
                    content,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.6,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Returns Privacy Policy content (summary for display)
  String _getPrivacyPolicyContent() {
    return '''
PRIVACY POLICY

Last Updated: [Date]

1. INFORMATION WE COLLECT
• Expense data you enter (amounts, categories, dates, notes)
• Device information for app functionality
• Usage data to improve the app

2. HOW WE USE YOUR INFORMATION
• Store your expense data locally on your device
• Generate analytics and insights for your spending
• Create PDF receipts and export data
• Improve app performance and features

3. DATA STORAGE & SECURITY
• All your expense data is stored locally on your device
• We do not store your personal data on our servers
• Data is encrypted and secured on your device
• You maintain full control over your data

4. DATA SHARING
• We do not sell or share your personal expense data
• No third-party access to your financial information
• Data remains private and under your control

5. YOUR RIGHTS
• Access and modify your data anytime
• Delete individual expenses or all data
• Export your data in standard formats
• Full control over your information

6. CONTACT US
For privacy questions, contact us at: [email]

For the complete Privacy Policy, please visit our website or contact us directly.
''';
  }

  /// Returns Terms of Use content (summary for display)
  String _getTermsOfUseContent() {
    return '''
TERMS OF USE

Last Updated: [Date]

1. ACCEPTANCE OF TERMS
By using Smart Expense Tracker, you agree to these terms and conditions.

2. DESCRIPTION OF SERVICE
Smart Expense Tracker is a personal finance app for tracking expenses with:
• Local data storage on your device
• Expense categorization and analytics
• PDF receipt generation
• Data export capabilities

3. USER RESPONSIBILITIES
• Provide accurate expense information
• Maintain device security
• Use the app for personal expense tracking only
• Comply with applicable laws

4. INTELLECTUAL PROPERTY
• The app and its content are protected by copyright
• You retain ownership of your expense data
• Respect third-party intellectual property rights

5. DISCLAIMERS
• The app is for expense tracking only, not financial advice
• We strive for accuracy but cannot guarantee error-free operation
• You are responsible for verifying your expense data

6. LIMITATION OF LIABILITY
• Use the app at your own risk
• We are not liable for data loss or financial decisions
• Our liability is limited to the maximum extent permitted by law

7. TERMINATION
• You may stop using the app at any time
• We may terminate access for violations of these terms
• Your local data remains under your control

8. GOVERNING LAW
These terms are governed by applicable laws in your jurisdiction.

9. CONTACT US
For questions about these terms, contact us at: [email]

For the complete Terms of Use, please visit our website or contact us directly.
''';
  }
}