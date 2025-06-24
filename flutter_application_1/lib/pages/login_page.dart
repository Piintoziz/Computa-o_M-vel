import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/forgot_password.dart';
import '../widgets/simple_button.dart';
import '../widgets/shake_detector_mixin.dart';

class LoginPage extends StatefulWidget {
  LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with ShakeDetectorMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
          children: [
            // Background Image:
            Image.asset(
                  'assets/images/bg_login.png', 
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
            ),

            //Welcome Page Controls:
            Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //Top Arrow to back:
              Row(
                children: [
                  const Spacer(), 
                  IconButton(icon: const Icon(Icons.arrow_back), onPressed: (){Navigator.pop(context);},)
                ],
              ),
          
              Center(
                child: Text(
                  'Login',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w900)
                ),
              ),
          
              TextFormField(
                controller: _emailController,
                validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                decoration: const InputDecoration(
                  labelText: 'Email or username:',
                  suffixIcon: Icon(Icons.person_outline),
                  border: UnderlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
          
              TextFormField(
                controller: _passwordController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password:',
                  suffixIcon: Icon(Icons.visibility_outlined),
                  border: const UnderlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  SimpleButton(
                    child: const Text("Login"),
                    onPressed: () async {
                      try 
                      {
                        if (_formKey.currentState!.validate()) {
                          var credential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: _emailController.text, password: _passwordController.text);
                          if (credential.user != null) {
                            Navigator.pushReplacementNamed(context, '/');
                          }
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Invalid email or password'))
                          );
                      }
                    }
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgotPasswordPage()));
                    },
                    child: const Text('forgot password?'),
                  ),
                ],
              )
            ]),
        ),
        ),
      ]),
    ); 
  }
}