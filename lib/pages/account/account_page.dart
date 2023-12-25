import 'package:bhfit/main.dart';
import 'package:bhfit/pages/widgets/avatar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final TextEditingController _nameController = TextEditingController();

  String? _avatarUrl;
  bool _loading = true;

  Future<void> _getProfile() async {
    setState(() {
      _loading = true;
    });

    try {
      final userId = supabase.auth.currentSession!.user.id;
      final data =
          await supabase.from('users').select().eq('id', userId).single();
      _nameController.text = (data['first_name'] ?? '') as String;
      _avatarUrl = (data['avatar_url'] ?? '') as String;
    } on PostgrestException catch (error) {
      // TODO exception catch
    } catch (error) {
      // TODO exception catch
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _onUpload(String imageUrl) async {
    try {
      if (_avatarUrl != null || _avatarUrl != '') {
        final avatarStartIndex =
            _avatarUrl!.indexOf("avatars/") + "avatars/".length;
        final avatarEndIndex = _avatarUrl!.indexOf("?token", avatarStartIndex);
        final avatarName =
            _avatarUrl!.substring(avatarStartIndex, avatarEndIndex);
        await supabase.storage.from('avatars').remove([avatarName]);
        debugPrint(_avatarUrl);
        debugPrint(avatarName);
      }
      final userId = supabase.auth.currentUser!.id;
      await supabase.from('users').update({
        'avatar_url': imageUrl,
      }).match({'id': userId});
      if (mounted) {
        const SnackBar(
          content: Text('Updated your profile image!'),
        );
      }
    } on PostgrestException catch (error) {
      // TODO exception catch
    } catch (error) {
      // TODO exception catch
    }
    if (!mounted) {
      return;
    }

    setState(() {
      _avatarUrl = imageUrl;
    });
  }

  @override
  void initState() {
    super.initState();
    _getProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text('Account'),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Avatar(
                  imageUrl: _avatarUrl,
                  onUpload: _onUpload,
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'User Name'),
                ),
                const SizedBox(height: 18),
                ElevatedButton(
                  onPressed: _loading ? null : null, //_updateProfile,
                  child: Text(_loading ? 'Saving...' : 'Update'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await supabase.auth.signOut();
                    if (context.mounted) {
                      context.go('/login');
                    }
                  },
                  child: const Text('Sign Out'),
                ),
              ],
            ),
    );
  }
}
