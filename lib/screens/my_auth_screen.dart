import 'package:flutter/material.dart';
import 'dart:math';

enum AuthMode {
  Login,
  SignUp,
}

class MyAuthScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.9),
                    Colors.pink.withOpacity(0.6)
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0, 1]),
            ),
          ),
          SingleChildScrollView(
            child: Container(
                height: deviceSize.height,
                width: deviceSize.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Container(
                        margin: EdgeInsets.only(bottom: 20.0),
                        padding: EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 94.0),
                        transform: Matrix4.rotationZ(-10 * pi / 180)
                          ..translate(-10.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.red,
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 8,
                              color: Colors.black26,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          'My Shop',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 50,
                            fontFamily: 'Anton',
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      child: MyAuthCard(),
                      flex: deviceSize.width > 600 ? 2 : 1,
                    )
                  ],
                )),
          )
        ],
      ),
    );
  }
}

class MyAuthCard extends StatefulWidget {
  const MyAuthCard({Key? key}) : super(key: key);

  @override
  State<MyAuthCard> createState() => _MyAuthCardState();
}

class _MyAuthCardState extends State<MyAuthCard> {
  AuthMode _authMode = AuthMode.Login;
  Map<String, String> authData = {
    'email': '',
    'password': '',
  };
  final _passwordEditingController = TextEditingController();
  var _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    if (_authMode == AuthMode.Login) {
      // Log user in
    } else {
      // Sign user up
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.SignUp;
      });
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          10.0,
        ),
      ),
      elevation: 8.0,
      child: Container(
        height: _authMode == AuthMode.SignUp ? 320 : 260,
        constraints:
            BoxConstraints(minHeight: _authMode == AuthMode.SignUp ? 320 : 260),
        width: deviceSize.width * 0.75,
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
              child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'E-mail'),
                keyboardType: TextInputType.emailAddress,
                onSaved: (value) {
                  authData['email'] = value as String;
                },
                validator: (value) {
                  if (value!.isEmpty || !value.contains('@')) {
                    return 'Invalid email!';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Passoword'),
                obscureText: true,
                controller: _passwordEditingController,
                onSaved: (value) {
                  authData['passoword'] = value as String;
                },
                validator: (value) {
                  if (value!.isEmpty || value.length < 5) {
                    return 'Password is too short';
                  }
                  return null;
                },
              ),
              if (_authMode == AuthMode.SignUp)
                TextFormField(
                  decoration: InputDecoration(labelText: 'Confirm password'),
                  enabled: _authMode == AuthMode.SignUp,
                  obscureText: true,
                  validator: _authMode == AuthMode.SignUp
                      ? (value) {
                          if (value != _passwordEditingController) {
                            return 'Passwords do not match!';
                          }
                        }
                      : null,
                ),
              SizedBox(
                height: 20,
              ),
              if (_isLoading)
                CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: _submit,
                  child:
                      Text(_authMode == AuthMode.Login ? 'Login' : 'Sign-Up'),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        30,
                      ),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 30.0,
                      vertical: 8.0,
                    ),
                  ),
                ),
              TextButton(
                onPressed: _switchAuthMode,
                child: Text(
                  '${_authMode == AuthMode.Login ? 'SignUp' : 'Login'} Instead',
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 4,
                  ),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          )),
        ),
      ),
    );
  }
}
