import 'package:bhfit/main.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PasswordReset extends StatefulWidget {
  const PasswordReset({super.key});

  @override
  State<PasswordReset> createState() => _PasswordResetState();
}

class _PasswordResetState extends State<PasswordReset> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isloading = false;

  bool _obscureTextPassword = true;
  bool _obscureTextConfirmPassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 23.0),
      child: Column(
        children: <Widget>[
          Stack(
            alignment: Alignment.topCenter,
            children: <Widget>[
              Card(
                elevation: 2.0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: SizedBox(
                  width: 300.0,
                  height: 190.0,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 20.0,
                          bottom: 20.0,
                          left: 25.0,
                          right: 25.0,
                        ),
                        child: TextField(
                          controller: _passwordController,
                          obscureText: _obscureTextPassword,
                          style: const TextStyle(
                            fontSize: 16.0,
                            color: Colors.black,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'New Password',
                            hintStyle: const TextStyle(
                              fontSize: 17.0,
                            ),
                            suffixIcon: GestureDetector(
                              onTap: _togglePasswordObscurity,
                              child: Icon(
                                _obscureTextPassword
                                    ? Icons.home
                                    : Icons.home_filled,
                                size: 15.0,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 250.0,
                        height: 1.0,
                        color: Colors.grey[400],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 20.0, bottom: 20.0, left: 25.0, right: 25.0),
                        child: TextField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureTextConfirmPassword,
                          style: const TextStyle(
                            fontSize: 16.0,
                            color: Colors.black,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Confirm New Password',
                            hintStyle: const TextStyle(
                              fontSize: 17.0,
                            ),
                            suffixIcon: GestureDetector(
                              onTap: _toggleConfirmPasswordObscurity,
                              child: Icon(
                                _obscureTextConfirmPassword
                                    ? Icons.home
                                    : Icons.home_filled,
                                size: 15.0,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          onSubmitted: (_) {
                            _updatePassword();
                          },
                          textInputAction: TextInputAction.go,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 170.0),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Color.fromRGBO(255, 255, 255, 1),
                      offset: Offset(-1.0, 2.0),
                      blurRadius: 6.0,
                    ),
                  ],
                  gradient: LinearGradient(
                      colors: <Color>[
                        Color.fromRGBO(0, 0, 0, 1),
                        Color.fromRGBO(255, 255, 255, 1),
                      ],
                      begin: FractionalOffset(0.2, 0.2),
                      end: FractionalOffset(1.0, 1.0),
                      stops: <double>[0.0, 1.0],
                      tileMode: TileMode.clamp),
                ),
                child: MaterialButton(
                  child: const Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 42.0),
                    child: Text(
                      'RESET',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25.0,
                      ),
                    ),
                  ),
                  onPressed: () => {_updatePassword()},
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  void _updatePassword() async {
    final password = _passwordController.text.trim();
    final passwordConfirm = _confirmPasswordController.text.trim();

    if (password != passwordConfirm) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Passwords don\'t match'),
          backgroundColor: Theme.of(context).colorScheme.error));
      return;
    }

    if (_isloading) {
      return;
    }

    try {
      _isloading = true;
      await supabase.auth.updateUser(UserAttributes(
        password: password,
      ));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Password has been reset')));
      }
      await supabase.auth.signOut();
    } on AuthException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(error.message),
          backgroundColor: Theme.of(context).colorScheme.error,
        ));
      }
    } finally {
      _isloading = false;
    }
  }

  void _togglePasswordObscurity() {
    setState(() {
      _obscureTextPassword = !_obscureTextPassword;
    });
  }

  void _toggleConfirmPasswordObscurity() {
    setState(() {
      _obscureTextConfirmPassword = !_obscureTextConfirmPassword;
    });
  }
}
