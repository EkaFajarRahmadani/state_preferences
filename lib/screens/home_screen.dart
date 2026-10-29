import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';
import 'profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, provider, _) => Scaffold(
        appBar: AppBar(
          title: const Text('Home'),
          actions: [
            IconButton(
              icon: Icon(
                provider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              ),
              tooltip: provider.isDarkMode ? 'Mode terang' : 'Mode gelap',
              onPressed: provider.toggleDarkMode,
            ),
          ],
        ),
        body: provider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.home, size: 80),
                      const SizedBox(height: 24),
                      Text(
                        provider.user.isLoggedIn
                            ? 'Selamat datang, ${provider.user.name}!'
                            : 'Selamat datang, Tamu!',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text('Aplikasi telah dibuka ${provider.visitCount} kali'),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProfileScreen(),
                            ),
                          );
                        },
                        icon: Icon(
                          provider.user.isLoggedIn
                              ? Icons.person
                              : Icons.login,
                        ),
                        label: Text(
                          provider.user.isLoggedIn
                              ? 'Lihat Profil'
                              : 'Login / Daftar',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
