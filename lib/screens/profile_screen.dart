import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

/// Profile Screen — user account info and settings.
/// Includes the light/dark mode toggle.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          // ─── Avatar & Name ─────────────────────────────
          Center(
            child: Column(
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        colors.primary,
                        colors.secondary,
                      ],
                    ),
                  ),
                  child: const Center(
                    child: Icon(Icons.person, size: 44, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Alex Johnson',
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'alex.johnson@email.com',
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // ─── Settings Section ──────────────────────────
          _SectionTitle(title: 'Settings'),
          const SizedBox(height: 8),

          // Dark mode toggle
          _SettingsTile(
            icon: themeProvider.isDarkMode
                ? Icons.dark_mode
                : Icons.light_mode,
            iconColor: colors.primary,
            title: 'Dark Mode',
            trailing: Switch.adaptive(
              value: themeProvider.isDarkMode,
              onChanged: (_) => themeProvider.toggleTheme(),
              activeTrackColor: colors.primary,
            ),
          ),
          _SettingsTile(
            icon: Icons.notifications_outlined,
            iconColor: const Color(0xFFF59E0B),
            title: 'Notifications',
            trailing: Icon(Icons.chevron_right, color: colors.onSurfaceVariant),
          ),
          _SettingsTile(
            icon: Icons.language,
            iconColor: const Color(0xFF6366F1),
            title: 'Language',
            subtitle: 'English',
            trailing: Icon(Icons.chevron_right, color: colors.onSurfaceVariant),
          ),

          const SizedBox(height: 24),
          _SectionTitle(title: 'Account'),
          const SizedBox(height: 8),

          _SettingsTile(
            icon: Icons.location_on_outlined,
            iconColor: const Color(0xFF10B981),
            title: 'Shipping Address',
            trailing: Icon(Icons.chevron_right, color: colors.onSurfaceVariant),
          ),
          _SettingsTile(
            icon: Icons.payment_outlined,
            iconColor: const Color(0xFF0EA5E9),
            title: 'Payment Methods',
            trailing: Icon(Icons.chevron_right, color: colors.onSurfaceVariant),
          ),
          _SettingsTile(
            icon: Icons.receipt_long_outlined,
            iconColor: const Color(0xFFEC4899),
            title: 'Order History',
            trailing: Icon(Icons.chevron_right, color: colors.onSurfaceVariant),
          ),

          const SizedBox(height: 24),
          _SectionTitle(title: 'Support'),
          const SizedBox(height: 8),

          _SettingsTile(
            icon: Icons.help_outline,
            iconColor: const Color(0xFFA855F7),
            title: 'Help Center',
            trailing: Icon(Icons.chevron_right, color: colors.onSurfaceVariant),
          ),
          _SettingsTile(
            icon: Icons.info_outline,
            iconColor: const Color(0xFF64748B),
            title: 'About',
            subtitle: 'Version 1.0.0',
            trailing: Icon(Icons.chevron_right, color: colors.onSurfaceVariant),
          ),

          const SizedBox(height: 32),

          // Logout button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Logout tapped')),
                );
              },
              icon: const Icon(Icons.logout, size: 20),
              label: const Text('Log Out'),
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.error,
                side: BorderSide(color: colors.error.withValues(alpha: 0.4)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

/// Section title widget
class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }
}

/// A single settings row tile.
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget trailing;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colors.outline.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
