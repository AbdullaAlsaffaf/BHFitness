import 'package:bhfit/main.dart';
import 'package:bhfit/pages/widgets/avatar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneFieldController = TextEditingController();
  final TextEditingController _cprController = TextEditingController();

  String? _avatarUrl;
  bool _loading = true;
  bool _userInfoLoaded = false;

  @override
  void initState() {
    super.initState();
    _getProfile();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneFieldController.dispose();
    _cprController.dispose();
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
                Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: _userInfoLoaded
                      ? Text(
                          "${_firstNameController.text} ${_lastNameController.text}",
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      : IntrinsicWidth(
                          child: Row(
                            children: [
                              const Text('Loading..'),
                              Container(
                                margin: const EdgeInsets.only(left: 8.0),
                                child: const SizedBox(
                                  height: 10,
                                  width: 10,
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
                const SizedBox(height: 18),
                ElevatedButton(
                  onPressed: _loading ? null : _openDialog,
                  child: Text(_loading ? 'Saving...' : 'Update Info'),
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

  Future<void> _getProfile() async {
    setState(() {
      _loading = true;
    });

    try {
      // get the data from Supabase
      final userId = supabase.auth.currentSession!.user.id;
      final data =
          await supabase.from('users').select().eq('id', userId).single();
      // load the data into the widgets
      _firstNameController.text = data['first_name'] ?? '';
      _lastNameController.text = data['last_name'] ?? '';
      _cprController.text = data['cpr'] ?? '';

      _userInfoLoaded = true;

      _avatarUrl = (data['avatar_url'] ?? '') as String;
    } on PostgrestException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(error.message),
          backgroundColor: Theme.of(context).colorScheme.error,
        ));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Something went wrong'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ));
      }
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
      if (_avatarUrl != null && _avatarUrl != '') {
        final avatarStartIndex =
            _avatarUrl!.indexOf("avatars/") + "avatars/".length;
        final avatarEndIndex = _avatarUrl!.indexOf("?token", avatarStartIndex);
        final avatarName =
            _avatarUrl!.substring(avatarStartIndex, avatarEndIndex);
        await supabase.storage.from('avatars').remove([avatarName]);
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(error.message),
          backgroundColor: Theme.of(context).colorScheme.error,
        ));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text("Something went wrong"),
          backgroundColor: Theme.of(context).colorScheme.error,
        ));
      }
    }
    if (!mounted) {
      return;
    }

    setState(() {
      _avatarUrl = imageUrl;
    });
  }

  Future<void> _openDialog() => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Center(
            child: Text('Enter Your details'),
          ),
          content: Container(
            margin: const EdgeInsets.symmetric(horizontal: 6.0),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  TextField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(hintText: 'First Name'),
                  ),
                  TextField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(hintText: 'Last Name'),
                  ),
                  IntlPhoneField(
                    dropdownIconPosition: IconPosition.trailing,
                    decoration: const InputDecoration(
                      hintText: 'Phone number',
                    ),
                    textAlign: TextAlign.right,
                    initialCountryCode: 'BH',
                    onChanged: (phone) {
                      _phoneFieldController.text =
                          "${phone.countryCode} ${phone.number}";
                    },
                  ),
                  TextField(
                    controller: _cprController,
                    decoration: const InputDecoration(hintText: 'CPR Number'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                context.pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (_firstNameController.text.isEmpty ||
                    _firstNameController.text.trim() == "") {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: const Text('Please input your first name'),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ));
                  return;
                }
                if (_lastNameController.text.isEmpty ||
                    _lastNameController.text.trim() == "") {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: const Text('Please input your last name'),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ));
                  return;
                }
                if (_phoneFieldController.text.isEmpty ||
                    _phoneFieldController.text.trim() == "") {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: const Text('Please input your phone number'),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ));
                  return;
                }
                if (_cprController.text.isEmpty ||
                    _cprController.text.trim() == "") {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: const Text('Please input your cpr number'),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ));
                  return;
                }
                final userId = supabase.auth.currentUser!.id;

                await supabase.from('users').update({
                  'first_name': _firstNameController.text,
                  'last_name': _lastNameController.text,
                  'phone': _phoneFieldController.text,
                  'cpr': _cprController.text
                }).match({'id': userId});

                if (mounted) {
                  context.pop();
                }
              },
              child: const Text('Update'),
            ),
          ],
        ),
      );
}
