import 'package:farm_vest/core/services/biometric_service.dart';
import 'package:farm_vest/core/services/secure_storage_service.dart';
import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:farm_vest/core/theme/theme_provider.dart';
import 'package:farm_vest/core/utils/app_enums.dart';
import 'package:farm_vest/features/auth/presentation/providers/auth_provider.dart';
import 'package:farm_vest/core/theme/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:farm_vest/core/localization/translation_helpers.dart';
import 'package:farm_vest/core/providers/locale_provider.dart';

class ProfileActionList extends ConsumerStatefulWidget {
  ProfileActionList({super.key});

  @override
  ConsumerState<ProfileActionList> createState() => _ProfileActionListState();
}

class _ProfileActionListState extends ConsumerState<ProfileActionList> {
  bool _isBiometricEnabled = false;
  bool _isBiometricSupported = false;
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _loadBiometricPreference();
    _loadAppVersion();
  }

  Future<void> _loadBiometricPreference() async {
    final enabled = await SecureStorageService.isBiometricEnabled();
    final supported = await BiometricService.isBiometricAvailable();
    if (!mounted) return;
    setState(() {
      _isBiometricEnabled = enabled;
      _isBiometricSupported = supported;
    });
  }

  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() {
      _appVersion = '${packageInfo.version}+${packageInfo.buildNumber}';
    });
  }

  Future<void> _toggleBiometric(bool newValue) async {
    if (newValue) {
      final success = await BiometricService.authenticate();
      if (!mounted) return;

      if (success) {
        await SecureStorageService.enableBiometric(true);
        setState(() => _isBiometricEnabled = true);
      } else {
        final reason = BiometricService.lastError;
        Fluttertoast.showToast(
          msg: reason == null || reason.isEmpty
              ? 'Authentication failed'
              : 'Authentication failed: $reason',
        );
      }
    } else {
      final shouldDisable = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text('Disable App Lock'.tr(ref)),
          content: Text(
            'Are you sure you want to disable fingerprint lock?'.tr(ref),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text('Cancel'.tr(ref)),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text('Disable'.tr(ref)),
            ),
          ],
        ),
      );

      if (!mounted) return;
      if (shouldDisable == true) {
        await SecureStorageService.enableBiometric(false);
        BiometricService.lock();
        setState(() => _isBiometricEnabled = false);
      }
    }
  }

  void _showLogoutDialog() {
    // 0. Safety check at entry
    if (!mounted) return;

    // 1. Capture notifier
    final authNotifier = ref.read(authProvider.notifier);

    showDialog(
      context: context,
      useRootNavigator: true, // Ensure we are using root navigator for dialog
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // 1. Close dialog immediately
              Navigator.of(dialogContext).pop();

              // 2. Perform logout (Fire and forget style to avoid blocking)
              // We handle the async operation without awaiting it in the UI thread
              // to prevent keeping the widget 'alive' longer than needed if it's unmounting.
              authNotifier
                  .logout()
                  .then((_) {
                    if (mounted) {
                      context.go('/login');
                    }
                  })
                  .catchError((e) {
                    debugPrint("Logout error: $e");
                  });
            },
            child: Text(
              'Logout'.tr(ref),
              style: TextStyle(color: AppTheme.errorRed),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Fluttertoast.showToast(msg: 'Could not launch $url');
    }
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      useRootNavigator: true,
      builder: (context) => AlertDialog(
        title: Text('Delete Account'.tr(ref)),
        content: Text(
          'Are you sure you want to delete your account? This action is permanent and will remove all your data. You will be redirected to our website to complete the process.'
              .tr(ref),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'.tr(ref)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _launchURL(AppConstants.deleteAccountUrl);
            },
            child: Text(
              'Delete'.tr(ref),
              style: TextStyle(color: AppTheme.errorRed),
            ),
          ),
        ],
      ),
    );
  }

  void _showSwitchRoleBottomSheet() {
    if (!mounted) return;

    final availableRoles = ref.read(authProvider).availableRoles;
    final currentRole = ref.read(authProvider).role;
    // Capture notifier early for safety
    final authNotifier = ref.read(authProvider.notifier);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Switch Active Role'.tr(ref),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Choose which portal you want to access'.tr(ref),
                style: TextStyle(color: AppTheme.mediumGrey),
              ),
              SizedBox(height: 24),
              ...availableRoles.map((role) {
                final isSelected = role == currentRole;

                return Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    onTap: isSelected
                        ? null
                        : () {
                            Navigator.of(context).pop();

                            authNotifier.selectRole(role).then((_) {
                              if (!mounted) return;
                              switch (role) {
                                case UserType.farmManager:
                                  context.go('/farm-manager-dashboard');
                                  break;
                                case UserType.supervisor:
                                  context.go('/supervisor-dashboard');
                                  break;
                                case UserType.doctor:
                                  context.go('/doctor-dashboard');
                                  break;
                                case UserType.assistant:
                                  context.go('/assistant-dashboard');
                                  break;
                                case UserType.customer:
                                  context.go('/customer-dashboard');
                                  break;
                              }
                            });
                          },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected ? role.color : Colors.grey.shade200,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    tileColor: isSelected ? role.color.withOpacity(0.05) : null,
                    leading: CircleAvatar(
                      backgroundColor: role.color.withOpacity(0.1),
                      child: Icon(role.icon, color: role.color),
                    ),
                    title: Text(
                      role.label,
                      style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check_circle, color: role.color)
                        : Icon(Icons.arrow_forward_ios, size: 14),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);

    return Column(
      children: [
        if (authState.availableRoles.length > 1) ...[
          ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            tileColor: theme.colorScheme.surface,
            leading: Icon(Icons.swap_horiz, color: AppTheme.primary),
            title: Text('Switch Role'.tr(ref)),
            subtitle: Text(
              'Currently as ${(authState.role ?? UserType.customer).label}',
            ),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: _showSwitchRoleBottomSheet,
          ),
          SizedBox(height: 8),
        ],
        if (_isBiometricSupported)
          ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            tileColor: theme.colorScheme.surface,
            leading: Icon(Icons.fingerprint, color: AppTheme.primary),
            title: Text('App Lock'.tr(ref)),
            subtitle: Text('Use biometric to unlock the app'.tr(ref)),
            trailing: Switch(
              value: _isBiometricEnabled,
              onChanged: _toggleBiometric,
            ),
          ),
        SizedBox(height: 8),
        ListTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          tileColor: theme.colorScheme.surface,
          leading: Icon(
            theme.brightness == Brightness.dark
                ? Icons.light_mode
                : Icons.dark_mode,
            color: AppTheme.primary,
          ),
          title: Text('Dark Mode'.tr(ref)),
          subtitle: Text(
            theme.brightness == Brightness.dark ? 'Enabled' : 'Disabled',
          ),
          trailing: Switch(
            value: theme.brightness == Brightness.dark,
            onChanged: (value) {
              ref.read(themeProvider.notifier).toggleTheme();
            },
          ),
        ),
        SizedBox(height: 8),
        ListTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          tileColor: theme.colorScheme.surface,
          leading: Icon(Icons.language, color: AppTheme.primary),
          title: Text('Language'.tr(ref)),
          subtitle: Text(
            _getLanguageName(ref.watch(localeProvider).languageCode),
          ),
          trailing: Icon(Icons.arrow_forward_ios, size: 16),
          onTap: _showLanguageBottomSheet,
        ),
        SizedBox(height: 8),
        ListTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          tileColor: theme.colorScheme.surface,
          leading: Icon(Icons.help_outline, color: AppTheme.primary),
          title: Text('Help & Support'.tr(ref)),
          trailing: Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => context.go('/support'),
        ),
        SizedBox(height: 8),
        ListTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          tileColor: theme.colorScheme.surface,
          leading: Icon(Icons.logout, color: AppTheme.errorRed),
          title: Text(
            'Logout'.tr(ref),
            style: TextStyle(color: AppTheme.errorRed),
          ),
          onTap: _showLogoutDialog,
        ),
        SizedBox(height: 8),
        ListTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          tileColor: theme.colorScheme.surface,
          leading: Icon(Icons.delete, color: AppTheme.errorRed),
          title: Text(
            'Delete Account'.tr(ref),
            style: TextStyle(color: AppTheme.errorRed),
          ),

          // trailing: Icon(Icons.arrow_forward_ios, size: 16),
          onTap: _showDeleteAccountDialog,
        ),
        if (_appVersion.isNotEmpty) ...[
          SizedBox(height: 24),
          Text(
            'Version $_appVersion',
            style: TextStyle(
              color: AppTheme.mediumGrey,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            AppConstants.poweredBy,
            style: TextStyle(
              color: AppTheme.mediumGrey.withOpacity(0.7),
              fontSize: 10,
            ),
          ),
          SizedBox(height: 16),
        ],
      ],
    );
  }

  String _getLanguageName(String? code) {
    switch (code) {
      case 'hi':
        return 'Hindi';
      case 'te':
        return 'Telugu';
      default:
        return 'English';
    }
  }

  void _showLanguageBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Language'.tr(ref),
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            _buildLanguageOption('English', 'en'),
            _buildLanguageOption('Hindi (हिंदी)', 'hi'),
            _buildLanguageOption('Telugu (తెలుగు)', 'te'),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String label, String code) {
    final isSelected = ref.watch(localeProvider).languageCode == code;
    return ListTile(
      title: Text(label),
      trailing: isSelected ? Icon(Icons.check, color: AppTheme.primary) : null,
      onTap: () async {
        await ref.read(localeProvider.notifier).setLocale(code);
        if (!mounted) return;
        Navigator.pop(context);
        setState(() {}); // Refresh UI
      },
    );
  }
}
