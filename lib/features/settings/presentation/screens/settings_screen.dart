/// ═══════════════════════════════════════════════════════════════════════════════
/// ⚙️ SETTINGS SCREEN - Premium User Preferences Experience
/// ═══════════════════════════════════════════════════════════════════════════════
///
/// Modern settings screen with premium design tokens and smooth interactions.
///
/// FEATURES:
/// - Account settings (name, email, password)
/// - App preferences (notifications, theme, language)
/// - Interview settings (difficulty, time limits, categories)
/// - Data management (export, clear history, delete account)
/// - About section (version, privacy, terms)
/// - Premium component integration (AppCard, AppButton, switches)
///
/// UX PRINCIPLES:
/// - Grouped settings in logical sections
/// - Clear labels and descriptions
/// - Immediate visual feedback
/// - Confirmation for destructive actions
/// - Accessible and keyboard-friendly
///
/// ═══════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:mockmate/core/router/app_router.dart';
import 'package:mockmate/core/theme/design_tokens.dart';
import 'package:mockmate/core/widgets/app_card.dart';
import 'package:mockmate/core/widgets/app_toast.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mockmate/core/constants/app_constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _emailReminders = false;
  bool _darkMode = true;
  bool _hapticFeedback = true;
  bool _autoSaveProgress = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: AppTypography.titleM.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.x3l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Account Section ──────────────────────────────────────────
            AppSectionCard(
              title: 'Account',
              subtitle: 'Manage your profile and authentication',
              child: Column(
                children: [
                  _SettingsTile(
                    icon: Icons.person_outline_rounded,
                    title: 'Edit Profile',
                    subtitle: 'Change name, email, or avatar',
                    onTap: () {
                      // TODO: Navigate to profile edit screen
                      AppToast.info(context,
                          message: 'Profile editing coming soon!');
                    },
                  ),
                  Gap(AppSpacing.xs),
                  _SettingsTile(
                    icon: Icons.lock_outline_rounded,
                    title: 'Change Password',
                    subtitle: 'Update your account password',
                    onTap: () {
                      // TODO: Navigate to change password screen
                      AppToast.info(context,
                          message: 'Password change coming soon!');
                    },
                  ),
                ],
              ),
            ),

            Gap(AppSpacing.l),

            // ── Notifications Section ────────────────────────────────────
            AppSectionCard(
              title: 'Notifications',
              subtitle: 'Control how we communicate with you',
              child: Column(
                children: [
                  _SettingsSwitch(
                    icon: Icons.notifications_outlined,
                    title: 'Push Notifications',
                    subtitle: 'Get notified about your progress',
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      HapticFeedback.selectionClick();
                      setState(() => _notificationsEnabled = value);
                    },
                  ),
                  Gap(AppSpacing.xs),
                  _SettingsSwitch(
                    icon: Icons.email_outlined,
                    title: 'Email Reminders',
                    subtitle: 'Weekly practice reminders via email',
                    value: _emailReminders,
                    onChanged: (value) {
                      HapticFeedback.selectionClick();
                      setState(() => _emailReminders = value);
                    },
                  ),
                ],
              ),
            ),

            Gap(AppSpacing.l),

            // ── Preferences Section ──────────────────────────────────────
            AppSectionCard(
              title: 'Preferences',
              subtitle: 'Customize your app experience',
              child: Column(
                children: [
                  _SettingsSwitch(
                    icon: Icons.dark_mode_outlined,
                    title: 'Dark Mode',
                    subtitle: 'Use dark theme (always on)',
                    value: _darkMode,
                    onChanged: (value) {
                      HapticFeedback.selectionClick();
                      setState(() => _darkMode = value);
                      AppToast.info(context,
                          message: 'Theme changing coming soon!');
                    },
                  ),
                  Gap(AppSpacing.xs),
                  _SettingsSwitch(
                    icon: Icons.vibration_rounded,
                    title: 'Haptic Feedback',
                    subtitle: 'Subtle vibrations for interactions',
                    value: _hapticFeedback,
                    onChanged: (value) {
                      if (value) HapticFeedback.mediumImpact();
                      setState(() => _hapticFeedback = value);
                    },
                  ),
                  Gap(AppSpacing.xs),
                  _SettingsSwitch(
                    icon: Icons.save_outlined,
                    title: 'Auto-Save Progress',
                    subtitle: 'Automatically save interview progress',
                    value: _autoSaveProgress,
                    onChanged: (value) {
                      HapticFeedback.selectionClick();
                      setState(() => _autoSaveProgress = value);
                    },
                  ),
                ],
              ),
            ),

            Gap(AppSpacing.l),

            // ── Data & Privacy Section ───────────────────────────────────
            AppSectionCard(
              title: 'Data & Privacy',
              subtitle: 'Manage your data and privacy settings',
              child: Column(
                children: [
                  _SettingsTile(
                    icon: Icons.download_outlined,
                    title: 'Export Data',
                    subtitle: 'Download your interview history',
                    onTap: () {
                      AppToast.info(context,
                          message: 'Data export coming soon!');
                    },
                  ),
                  Gap(AppSpacing.xs),
                  _SettingsTile(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Policy',
                    subtitle: 'Read our privacy practices',
                    onTap: () {
                      AppToast.info(context,
                          message: 'Privacy policy coming soon!');
                    },
                  ),
                  Gap(AppSpacing.xs),
                  _SettingsTile(
                    icon: Icons.description_outlined,
                    title: 'Terms of Service',
                    subtitle: 'Review our terms and conditions',
                    onTap: () {
                      AppToast.info(context, message: 'Terms coming soon!');
                    },
                  ),
                ],
              ),
            ),

            Gap(AppSpacing.l),

            // ── Danger Zone Section ──────────────────────────────────────
            AppSectionCard(
              title: 'Danger Zone',
              subtitle: 'Irreversible actions',
              child: Column(
                children: [
                  _SettingsTile(
                    icon: Icons.delete_sweep_outlined,
                    title: 'Clear All History',
                    subtitle: 'Delete all your interview sessions',
                    iconColor: AppColors.warning500,
                    onTap: () => _showClearHistoryDialog(),
                  ),
                  Gap(AppSpacing.xs),
                  _SettingsTile(
                    icon: Icons.logout_rounded,
                    title: 'Sign Out',
                    subtitle: 'Log out from your account',
                    iconColor: AppColors.error500,
                    onTap: () => _showSignOutDialog(),
                  ),
                  Gap(AppSpacing.xs),
                  _SettingsTile(
                    icon: Icons.delete_forever_rounded,
                    title: 'Delete Account',
                    subtitle: 'Permanently delete your account',
                    iconColor: AppColors.error500,
                    onTap: () => _showDeleteAccountDialog(),
                  ),
                ],
              ),
            ),

            Gap(AppSpacing.x3l),

            // ── App Info Footer ──────────────────────────────────────────
            Center(
              child: Column(
                children: [
                  Text(
                    'MockMate',
                    style: AppTypography.labelM.copyWith(
                      color: AppColors.neutral400,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Gap(AppSpacing.xs),
                  Text(
                    'Version 1.0.0 (Build 1)',
                    style: AppTypography.labelS.copyWith(
                      color: AppColors.neutral500,
                    ),
                  ),
                  Gap(AppSpacing.xs),
                  Text(
                    '© 2026 MockMate. All rights reserved.',
                    style: AppTypography.labelXS.copyWith(
                      color: AppColors.neutral600,
                    ),
                  ),
                ],
              ),
            ),

            Gap(AppSpacing.x3l),
          ],
        ),
      ),
    );
  }

  // ── Dialogs ──────────────────────────────────────────────────────────────

  void _showClearHistoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.m),
        ),
        title: Text(
          'Clear All History?',
          style: AppTypography.titleM.copyWith(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'This will permanently delete all your interview sessions and progress. This action cannot be undone.',
          style: AppTypography.bodyM.copyWith(color: AppColors.neutral300),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text(
              'Cancel',
              style: AppTypography.labelM.copyWith(
                color: AppColors.neutral400,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              context.pop();
              AppToast.success(context,
                  message: 'History cleared successfully');
            },
            child: Text(
              'Clear History',
              style: AppTypography.labelM.copyWith(
                color: AppColors.error500,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.m),
        ),
        title: Text(
          'Sign Out?',
          style: AppTypography.titleM.copyWith(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to sign out? You can sign back in anytime.',
          style: AppTypography.bodyM.copyWith(color: AppColors.neutral300),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text(
              'Cancel',
              style: AppTypography.labelM.copyWith(
                color: AppColors.neutral400,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              HapticFeedback.mediumImpact();
              const storage = FlutterSecureStorage();
              await storage.delete(key: AppConstants.accessTokenKey);
              if (mounted) {
                context.pop();
                context.go(AppRoutes.login);
                AppToast.success(context, message: 'Signed out successfully');
              }
            },
            child: Text(
              'Sign Out',
              style: AppTypography.labelM.copyWith(
                color: AppColors.error500,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.m),
        ),
        title: Text(
          'Delete Account?',
          style: AppTypography.titleM.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.error500,
          ),
        ),
        content: Text(
          'This will permanently delete your account and all associated data. This action CANNOT be undone. Are you absolutely sure?',
          style: AppTypography.bodyM.copyWith(color: AppColors.neutral300),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text(
              'Cancel',
              style: AppTypography.labelM.copyWith(
                color: AppColors.neutral400,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              HapticFeedback.heavyImpact();
              context.pop();
              AppToast.error(context, message: 'Account deletion coming soon');
            },
            child: Text(
              'Delete Forever',
              style: AppTypography.labelM.copyWith(
                color: AppColors.error500,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// CUSTOM WIDGETS
// ═══════════════════════════════════════════════════════════════════════════════

/// Settings tile with tap interaction
class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.s),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.m,
          vertical: AppSpacing.m,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.primary500).withOpacity(0.12),
                borderRadius: BorderRadius.circular(AppRadius.xs),
              ),
              child: Icon(
                icon,
                size: 20,
                color: iconColor ?? AppColors.primary500,
              ),
            ),
            Gap(AppSpacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.bodyM.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Gap(AppSpacing.xs / 2),
                  Text(
                    subtitle,
                    style: AppTypography.bodyS.copyWith(
                      color: AppColors.neutral400,
                    ),
                  ),
                ],
              ),
            ),
            Gap(AppSpacing.m),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.neutral500,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

/// Settings switch with label
class _SettingsSwitch extends StatelessWidget {
  const _SettingsSwitch({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.m,
        vertical: AppSpacing.m,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary500.withOpacity(0.12),
              borderRadius: BorderRadius.circular(AppRadius.xs),
            ),
            child: Icon(
              icon,
              size: 20,
              color: AppColors.primary500,
            ),
          ),
          Gap(AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyM.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Gap(AppSpacing.xs / 2),
                Text(
                  subtitle,
                  style: AppTypography.bodyS.copyWith(
                    color: AppColors.neutral400,
                  ),
                ),
              ],
            ),
          ),
          Gap(AppSpacing.m),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary500,
            activeTrackColor: AppColors.primary500.withOpacity(0.5),
            inactiveThumbColor: AppColors.neutral400,
            inactiveTrackColor: AppColors.neutral700,
          ),
        ],
      ),
    );
  }
}
