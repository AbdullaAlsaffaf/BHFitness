import 'package:flutter/material.dart';
import 'package:bhfit/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isloading = false;

  bool _obscureTextPassword = true;
  bool _obscureTextConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
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
                  height: 275.0,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 20.0, bottom: 20.0, left: 25.0, right: 25.0),
                        child: TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(
                              fontFamily: 'WorkSansSemiBold',
                              fontSize: 16.0,
                              color: Colors.black),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            // icon: Icon(
                            //   FontAwesomeIcons.envelope,
                            //   color: Colors.black,
                            //   size: 22.0,
                            // ),
                            hintText: 'Email Address',
                            hintStyle: TextStyle(
                                fontFamily: 'WorkSansSemiBold', fontSize: 17.0),
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
                          controller: _passwordController,
                          obscureText: _obscureTextPassword,
                          style: const TextStyle(
                              fontFamily: 'WorkSansSemiBold',
                              fontSize: 16.0,
                              color: Colors.black),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            // icon: const Icon(
                            //   FontAwesomeIcons.lock,
                            //   size: 22.0,
                            //   color: Colors.black,
                            // ),
                            hintText: 'Password',
                            hintStyle: const TextStyle(
                                fontFamily: 'WorkSansSemiBold', fontSize: 17.0),
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
                              fontFamily: 'WorkSansSemiBold',
                              fontSize: 16.0,
                              color: Colors.black),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            // icon: const Icon(
                            //   FontAwesomeIcons.lock,
                            //   size: 22.0,
                            //   color: Colors.black,
                            // ),
                            hintText: 'Confirm Password',
                            hintStyle: const TextStyle(
                                fontFamily: 'WorkSansSemiBold', fontSize: 17.0),
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
                            _signUp();
                          },
                          textInputAction: TextInputAction.go,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 255.0),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Color.fromRGBO(
                          255, 255, 255, 1), //CustomTheme.loginGradientEnd,
                      offset: Offset(-1.0, 2.0),
                      blurRadius: 6.0,
                    ),
                  ],
                  gradient: LinearGradient(
                      colors: <Color>[
                        Color.fromRGBO(0, 0, 0, 1),
                        Color.fromRGBO(255, 255, 255, 1),
                        // CustomTheme.loginGradientEnd,
                        // CustomTheme.loginGradientStart
                      ],
                      begin: FractionalOffset(0.2, 0.2),
                      end: FractionalOffset(1.0, 1.0),
                      stops: <double>[0.0, 1.0],
                      tileMode: TileMode.clamp),
                ),
                child: MaterialButton(
                  //highlightColor: Colors.transparent,
                  // splashColor: CustomTheme.loginGradientEnd,
                  child: const Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 42.0),
                    child: Text(
                      'REGISTER',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25.0,
                      ),
                    ),
                  ),
                  onPressed: () => {_signUp()},
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  void _signUp() async {
    if (_isloading) {
      return;
    }

    try {
      _isloading = true;
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      final passwordConfirm = _confirmPasswordController.text.trim();

      if (password != passwordConfirm) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text('Passwords don\'t match'),
            backgroundColor: Theme.of(context).colorScheme.error));
        return;
      }

      await supabase.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: 'io.supabase.bhfitness://callback',
      );

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Check your inbox')));
      }
    } on AuthException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(error.message),
          backgroundColor: Theme.of(context).colorScheme.error,
        ));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Error occured'),
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
