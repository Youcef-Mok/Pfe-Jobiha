import 'package:flutter/material.dart';
import '../widgets/settings_item.dart';



class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          'Settings & Activity',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          _buildSection('ACTIVITY', _activityTiles()),
          _buildSection('ACCOUNT', _accountTiles()),
          _buildSection('PREFERENCES', _preferencesTiles()),
          _buildSection('SUPPORT', _supportTiles()),
          _buildBottomButtons(),
        ],
      ),
    );
  }

  // ─── Section wrapper ───────────────────────────────────────────────────────

  Widget _buildSection(String title, List<Widget> tiles) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.grey[500],
              letterSpacing: 1.0,
            ),
          ),
        ),
        ...tiles,
      ],
    );
  }

  // ─── ACTIVITY tiles ────────────────────────────────────────────────────────

  List<Widget> _activityTiles() => [
        SettingsItem(
          assetPath: 'assets/ic_saved.png',
          label: 'Enregistrés',
          onTap: () {Navigator.pushNamed(context, '/saved');}
        ),
        SettingsItem(
          assetPath: 'assets/ic_notifications.png',
          label: 'Notifications',
          onTap: () {Navigator.pushNamed(context, '/notifications');}
        ),
        SettingsItem(
          assetPath: 'assets/ic_jobs.png',
          label: 'Candidatures envoyées',
          onTap: () {Navigator.pushNamed(context, '/applications-sent');}
        ),
      ];

  // ─── ACCOUNT tiles ─────────────────────────────────────────────────────────

  List<Widget> _accountTiles() => [
        SettingsItem(
          assetPath: 'assets/ic_personal_info.png',
          label: 'Informations personnelles',
          onTap: () {Navigator.pushNamed(context, '/personal-info');}

        ),
        SettingsItem(
          assetPath: 'assets/ic_password.png',
          label: 'Mot de passe et sécurité',
          onTap: () {Navigator.pushNamed(context, '/security');}

        ),
        SettingsItem(
          assetPath: 'assets/ic_deactivate.png',
          label: 'Désactiver le compte',
          onTap: () {Navigator.pushNamed(context, '/deactivate-account');}

        ),
      ];

  // ─── PREFERENCES tiles ─────────────────────────────────────────────────────

  List<Widget> _preferencesTiles() => [
        SwitchListTile(
          secondary: Image.asset(
            'assets/ic_push_notifications.png',
            width: 40,
            height: 40,
            color: Colors.deepPurple,
          ),
          title: const Text(
            'Push Notifications',
            style: TextStyle(fontSize: 15),
          ),
          value: _pushNotificationsEnabled,
          activeThumbColor: Colors.deepPurple,
          onChanged: (val) => setState(() => _pushNotificationsEnabled = val),
        ),
        SettingsItem(
          assetPath: 'assets/ic_accessibility.png',
          label: 'Accessibilité',
          onTap: () {Navigator.pushNamed(context, '/accessibility');}


        ),
        SettingsItem(
          assetPath: 'assets/ic_languages.png',
          label: 'Langues et traductions',
          onTap: () {Navigator.pushNamed(context, '/language');}

        ),
        SettingsItem(
          assetPath: 'assets/ic_blocked.png',
          label: 'Comptes bloqués',
          onTap: () {Navigator.pushNamed(context, '/blocked-users');}

        ),
      ];

  // ─── SUPPORT tiles ─────────────────────────────────────────────────────────

  List<Widget> _supportTiles() => [
        SettingsItem(
          assetPath: 'assets/ic_help.png',
          label: 'Centre d\'aide',
          onTap: () {Navigator.pushNamed(context, '/help-center');}


        ),
        SettingsItem(
          assetPath: 'assets/ic_privacy.png',
          label: 'Politique de confidentialité',
          onTap: () {Navigator.pushNamed(context, '/privacy-policy');}


        ),
        SettingsItem(
          assetPath: 'assets/ic_terms.png',
          label: 'Conditions d\'utilisation',
          onTap: () {Navigator.pushNamed(context, '/terms-conditions');}


        ),
      ];

  // ─── Bottom buttons ────────────────────────────────────────────────────────

  Widget _buildBottomButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        children: [
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              side: const BorderSide(color: Colors.deepPurple),
            ),
            onPressed: () {
              // TODO: handle add account
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/ic_add_account.png',
                  width: 22,
                  height: 16,
                  color: Colors.deepPurple,
                ),
                const SizedBox(width: 8),
                const Text(
                  'ajouter un compte',
                  style: TextStyle(color: Colors.deepPurple),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              // TODO: handle logout
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/ic_logout.png',
                  width: 18,
                  height: 18,
                  color: Colors.red,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Log Out (se déconnecter)',
                  style: TextStyle(color: Colors.red),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}