import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeMode = prefs.getString('theme_mode') ?? 'system';
    setState(() {
      _themeMode = _getThemeModeFromString(themeMode);
    });
  }

  Future<void> _saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', _getStringFromThemeMode(mode));
  }

  ThemeMode _getThemeModeFromString(String theme) {
    switch (theme) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  String _getStringFromThemeMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      default:
        return 'system';
    }
  }

  void _onThemeChanged(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
      _saveThemeMode(mode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
      ),
      body: Column(
        children: [
          ListTile(
            title: const Text('Modo Claro'),
            leading: Radio<ThemeMode>(
              value: ThemeMode.light,
              groupValue: _themeMode,
              onChanged: (mode) => _onThemeChanged(mode!),
            ),
          ),
          ListTile(
            title: const Text('Modo Oscuro'),
            leading: Radio<ThemeMode>(
              value: ThemeMode.dark,
              groupValue: _themeMode,
              onChanged: (mode) => _onThemeChanged(mode!),
            ),
          ),
          ListTile(
            title: const Text('Seguir el sistema'),
            leading: Radio<ThemeMode>(
              value: ThemeMode.system,
              groupValue: _themeMode,
              onChanged: (mode) => _onThemeChanged(mode!),
            ),
          ),
        ],
      ),
    );
  }
}
