import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:notebook_projectf/Screens/home/home_screen.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _passwordVisible = false;

  bool isLoading = false;
  bool isLogin = true;

  String emailError = '';
  String passwordError = '';

  Future<void> handleAuth() async {
    setState(() {
      emailError = emailController.text.trim().isEmpty ? 'Email is required' : '';
      passwordError = passwordController.text.trim().isEmpty ? 'Password is required' : '';
    });

    if (emailError.isNotEmpty || passwordError.isNotEmpty) return;

    try {
      setState(() => isLoading = true);
      if (isLogin) {
        await _auth.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
      } else {
        await _auth.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
      }

      // Getting the logged-in user's UID
      User? currentUser = FirebaseAuth.instance.currentUser;
      String? uid = currentUser?.uid;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isLogin ? 'Login Successful' : 'Account Created')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );

    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'invalid-email') {
          emailError = 'The email address is badly formatted.';
        } else if (e.code == 'user-not-found'|| e.code == 'wrong-password') {
          emailError = 'No user found with this email.';
        } else if (e.code == 'wrong-password') {
          passwordError = 'The password is incorrect.';
        } else if (e.code == 'weak-password') {
          passwordError = 'The password is too weak.';
        } else if (e.message == 'The supplied auth credential is incorrect, malformed or has expired.') {
          emailError = 'No user is found with this email and password.';
          passwordError = '';
        } else {
          emailError = 'Error: ${e.message}';
        }
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Color(0xFFFBF2E3),
      resizeToAvoidBottomInset: true,
        body: Container(
        decoration: const BoxDecoration(
        gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
        Colors.white,
    Color(0xFFFBF2E3),
    ],
    ),
    ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/img.png',
                  height: 250,
                ),

                const SizedBox(height: 20),
                Text(
                  isLogin ? "Hello Again!" : "Create Account",
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isLogin
                      ? "Start capturing your thoughts and ideas!"
                      : "Sign up to get started!",
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 25),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: "Email",
                    hintText: "Enter your email",
                    prefixIcon: const Icon(Icons.email_outlined),
                    labelStyle: TextStyle(color: Colors.black54),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: emailError.isNotEmpty ? Colors.red : Colors.grey,
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: emailError.isNotEmpty ? Colors.red : Colors.grey,
                        width: 2.0,
                      ),
                    ),
                    errorText: emailError.isNotEmpty ? emailError : null,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: "Password",
                    hintText: "Enter your password",
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _passwordVisible ? Icons.visibility : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _passwordVisible = !_passwordVisible;
                        });
                      },
                    ),
                    labelStyle: TextStyle(color: Colors.black54),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: passwordError.isNotEmpty ? Colors.red : Colors.grey,
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: passwordError.isNotEmpty ? Colors.red : Colors.grey,
                        width: 2.0,
                      ),
                    ),
                    errorText: passwordError.isNotEmpty ? passwordError : null,
                  ),
                    obscureText: !_passwordVisible,
                ),

                const SizedBox(height: 20),
                isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Color(0xFFFFB778),
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 40,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: handleAuth,
                  child: Text(
                    isLogin ? "Login" : "Sign Up",
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                const SizedBox(height: 20),
                // Toggle Between Login and Sign-Up
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isLogin = !isLogin;
                      // Clear error messages when switching modes
                      emailError = '';
                      passwordError = '';
                    });
                  },
                  child: Text(
                    isLogin
                        ? "Don't have an account? Register now"
                        : "Already have an account? Login",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
        ),
    );
  }

}
