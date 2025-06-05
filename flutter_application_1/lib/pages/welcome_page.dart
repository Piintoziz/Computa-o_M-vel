import 'package:flutter/material.dart';
import 'create_account_page.dart';
import 'login_page.dart';
import '../widgets/continue_with_button.dart';
import '../widgets/primary_button.dart';

class WelcomePage extends StatelessWidget {
  WelcomePage({super.key});
  BuildContext? context;

  void displayLoginPage() {
    Navigator.push(context!, MaterialPageRoute(builder:(context) => const LoginPage()));
  }

  void displayCreateAccountPage() {
    Navigator.push(context!, MaterialPageRoute(builder: (context) => const CreateAccountPage()));
  }

  void continueWithFacebook() {
    //TODO: Implementar autenticação com facebook
  }

  void continueWithGoogle() {
    //TODO: Implementar autenticação com google
  }

  void continueWithApple() {
    //TODO: Implementar autenticação com apple
  }

  @override
  Widget build(BuildContext context) {
    this.context = context;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body:  Stack(
          children: [
            // Background Image:
            Image.asset(
                  'assets/images/bg_welcome.png', 
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
            ),

            //Welcome Page Controls:
            Column(
              children: [
                SizedBox(height: screenHeight * 0.51),
                //Login and create account buttons:
                Row(children: [
                  Expanded(child: PrimaryButton(text: 'Login', onPressed: displayLoginPage)),
                  Expanded(child: PrimaryButton(text: 'Criar Conta', onPressed: displayCreateAccountPage))
                ],),

                //Continue with social media buttons:
                const SizedBox(height: 20,),
                SocialMediaLoginButton( //Facebook
                  icon: const Icon(Icons.facebook, color: Colors.blue, size: 35), 
                  text: "Continuar com o Facebook", 
                  onPressed: continueWithFacebook
                ),
                SocialMediaLoginButton( //Google
                  icon: Image.asset("assets/images/google_small_icon.png", scale: 48.0 / 35.0,), 
                  text: "Continuar com o Google", 
                  onPressed: continueWithGoogle
                ),
                SocialMediaLoginButton( //Apple
                  icon: const Icon(Icons.apple, color: Colors.black, size: 35), 
                  text: "Continuar com a Apple", 
                  onPressed: continueWithApple
                ),
              ],
            )
          ],
      ),
    ); 
  }
}
