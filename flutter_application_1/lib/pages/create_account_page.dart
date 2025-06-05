import 'package:flutter/material.dart';
import '../widgets/simple_button.dart';

class CreateAccountPage extends StatelessWidget {
  const CreateAccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:  Stack(
          children: [
            // Background Image:
            Image.asset(
                  'assets/images/bg_create_account.png', 
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
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

            //Title:
            Center(
              child: Text(
                'Criar Conta',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w900)
              ),
            ),

            //EMAIL TEXTBOX:
            const TextField(
              decoration: InputDecoration(
                labelText: 'Email or username:',
                suffixIcon: Icon(Icons.person_outline),
                border: UnderlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),

            //PASSWORD TEXTBOX:
            const TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password:',
                suffixIcon: Icon(Icons.visibility_outlined),
                border: UnderlineInputBorder(),
              ),
            ),

            //PASSWORD CONFIRM TEXTBOX:
            const TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Confirm password:',
                suffixIcon: Icon(Icons.visibility_outlined),
                border: UnderlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            SimpleButton(
              child: const Text("Criar"), 
              onPressed: (){
                Navigator.pushReplacementNamed(context, '/');
              }
            ),
          ]),
        ),
      ]),
    ); 
  }
}