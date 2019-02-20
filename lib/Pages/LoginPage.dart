/* 
    The MIT License

    Copyright September 1, 2018 Shawn Gilroy/Louisiana State University

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in
    all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
    THE SOFTWARE.

    ---------------------------------------------------------------------

    This code also incorporates work from "coding-with-flutter-login-demo" under
    the following license:

    Copyright (c) 2018 Andrea Bizzotto [bizz84@gmail.com](mailto:bizz84@gmail.com)

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in
    all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
    THE SOFTWARE.
*/

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:visual_discrimination_app/Auth/AuthProvider.dart';
import 'package:visual_discrimination_app/Dialogs/ErrorDialog.dart';

/*
 * Validate email address
 */
class EmailFieldValidator {
  static String validate(String value) {
    return value.isEmpty ? 'Email can\'t be empty' : null;
  }
}

/*
 * Validate password
 */
class PasswordFieldValidator {
  static String validate(String value) {
    return value.isEmpty ? 'Password can\'t be empty' : null;
  }
}

class LoginPage extends StatefulWidget {
  LoginPage({this.onSignedIn});
  final Function onSignedIn;

  @override
  State<StatefulWidget> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  String email;
  String password;
  bool submitting = false;

  final FocusNode userFocus = FocusNode();
  final FocusNode passFocus = FocusNode();

  /*
   * Toggle progress
   */
  void toggleSubmitState() {
    setState(() {
      submitting = !submitting;
    });
  }

  /*
   * Validate form
   */
  bool validateAndSave() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  /*
   * Submit for login
   */
  void validateAndSubmit() async {
    if (validateAndSave()) {
      try {
        setState(() {
          toggleSubmitState(); 
        });

        var auth = AuthProvider.of(context).auth;

        await Future.delayed(new Duration(milliseconds: 1000));

        String userId = await auth.signInWithEmailAndPassword(email, password);
        widget.onSignedIn(userId);

      } on PlatformException catch (e) {
        await showAlert(context, e.message);

      } finally {
        setState(() {
          toggleSubmitState(); 
        });
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Discriminability App Login'),
      ),
      body: ListView(
        shrinkWrap: true,
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(16.0),
            child: Form(
              key: formKey,
              child: submitting ? Center(child: const CircularProgressIndicator()) : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children:  buildInputs() + buildSubmitButtons(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /*
   * Build inputs for username, password
   */
  List<Widget> buildInputs() {
    return [
      TextFormField(
        key: Key('email'),
        decoration: InputDecoration(
          labelText: 'Email'
        ),
        keyboardType: TextInputType.emailAddress,
        validator: EmailFieldValidator.validate,
        textInputAction: TextInputAction.next,
        focusNode: userFocus,
        onSaved: (value) => email = value,
        onFieldSubmitted: (value) {
          userFocus.unfocus();
          FocusScope.of(context).requestFocus(passFocus);
        },
      ),
      TextFormField(
        key: Key('password'),
        decoration: InputDecoration(
          labelText: 'Password'
        ),
        obscureText: true,
        validator: PasswordFieldValidator.validate,
        textInputAction: TextInputAction.done,
        focusNode: passFocus,
        onSaved: (value) => password = value,
        onFieldSubmitted: (value) {
          passFocus.unfocus();

          validateAndSubmit();
        },
      ),
    ];
  }

  /*
   * Build button for signin
   */
  List<Widget> buildSubmitButtons() {
    return [
      RaisedButton(
        key: Key('signIn'),
        child: Text('Login', style: TextStyle(fontSize: 20.0)),
        onPressed: validateAndSubmit,
      ),
    ];
  }
}