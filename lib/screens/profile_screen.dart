import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/user_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _favoriteController = TextEditingController();
  bool _controllersInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = context.read<UserProvider>();
    if (!_controllersInitialized && !provider.isLoading) {
      _nameController.text = provider.user.name;
      _emailController.text = provider.user.email;
      _controllersInitialized = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _favoriteController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState?.validate() != true) return;

    final provider = context.read<UserProvider>();
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('user_email')?.trim();
    final isCurrentUserEmail =
        provider.user.isLoggedIn &&
        savedEmail?.toLowerCase() == provider.user.email.toLowerCase();
    if (savedEmail != null &&
        savedEmail.isNotEmpty &&
        savedEmail.toLowerCase() == email.toLowerCase() &&
        !isCurrentUserEmail) {
      _showMessage('Email sudah digunakan', isError: true);
      return;
    }

    await provider.updateUser(
      provider.user.copyWith(name: name, email: email, isLoggedIn: true),
    );
    if (mounted) _showMessage('Profil berhasil disimpan');
  }

  Future<void> _addFavorite() async {
    final favorite = _favoriteController.text.trim();
    if (favorite.isEmpty) {
      _showMessage('Favorit tidak boleh kosong', isError: true);
      return;
    }
    final provider = context.read<UserProvider>();
    if (provider.favorites.any(
      (item) => item.toLowerCase() == favorite.toLowerCase(),
    )) {
      _showMessage('Favorit sudah ada', isError: true);
      return;
    }

    await provider.addFavorite(favorite);
    if (mounted) _favoriteController.clear();
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
      ),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Apakah Anda yakin ingin logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<UserProvider>().logout();
              Navigator.pop(context);
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          if (provider.user.isLoggedIn)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _logout,
              tooltip: 'Logout',
            ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 16),
                      const CircleAvatar(
                        radius: 50,
                        child: Icon(Icons.person, size: 60),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _nameController,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        decoration: const InputDecoration(
                          labelText: 'Nama',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nama tidak boleh kosong';
                          }
                          if (!RegExp(
                            r'^[\p{L}\p{M} ]+$',
                            unicode: true,
                          ).hasMatch(value.trim())) {
                            return 'Nama hanya boleh berisi huruf dan spasi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Email tidak boleh kosong';
                          }
                          final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                          if (!emailRegex.hasMatch(value.trim())) {
                            return 'Format email tidak valid';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _saveProfile,
                        icon: const Icon(Icons.save),
                        label: const Text('Simpan Profil'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Daftar Favorit',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        key: const ValueKey('favorite-input'),
                        controller: _favoriteController,
                        decoration: InputDecoration(
                          labelText: 'Hobi atau item favorit',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.add),
                            tooltip: 'Tambah favorit',
                            onPressed: _addFavorite,
                          ),
                        ),
                        onSubmitted: (_) => _addFavorite(),
                      ),
                      if (provider.favorites.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Text('Belum ada favorit.'),
                        )
                      else
                        ...provider.favorites.map(
                          (favorite) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(favorite),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline),
                              tooltip: 'Hapus $favorite',
                              onPressed: () =>
                                  provider.removeFavorite(favorite),
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      Card(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.info),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Catatan Keamanan',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Data disimpan di SharedPreferences (plaintext). '
                                'Jangan simpan password atau data sensitif di sini. '
                                'Gunakan secure storage untuk data sensitif.',
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
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
