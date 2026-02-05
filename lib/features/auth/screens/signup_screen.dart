import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../home/screens/home_screen.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // State
  int _currentStep = 0; // 0: Email/Name, 1: OTP, 2: Password
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // --- Actions ---

  Future<void> _processStep0_SendOtp() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    final email = _emailController.text.trim();
    
    try {
      // Send OTP to email
      await Supabase.instance.client.auth.signInWithOtp(
        email: email,
        shouldCreateUser: true,
        // We can pass metadata here, but we'll also ensure it's set at the end
        data: {'full_name': _nameController.text.trim()},
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('OTP sent to $email')),
        );
        setState(() {
          _isLoading = false;
          _currentStep = 1;
        });
      }
    } on AuthException catch (e) {
       if (mounted) {
        _showError(e.message);
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        _showError('Error sending OTP. Please try again.');
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _processStep1_VerifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      _showError('Please enter a valid 6-digit OTP');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final res = await Supabase.instance.client.auth.verifyOTP(
        type: OtpType.email,
        token: otp,
        email: _emailController.text.trim(),
      );

      if (res.session != null) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _currentStep = 2; // Move to Password step
          });
        }
      } else {
        throw 'Verification failed';
      }
    } on AuthException catch (e) {
      if (mounted) {
        _showError(e.message);
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        _showError('Invalid OTP');
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _processStep2_SetPassword() async {
    if (!_formKey.currentState!.validate()) return; // Validates password fields

    setState(() => _isLoading = true);
    try {
      // User is already authenticated from Step 1 (OTP).
      // We now just update their user profile with the password and name.
      final userAttributes = UserAttributes(
        password: _passwordController.text.trim(),
        data: {'full_name': _nameController.text.trim()},
      );

      await Supabase.instance.client.auth.updateUser(userAttributes);

      if (mounted) {
        // Success! Go home.
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
      }
    } on AuthException catch (e) {
      if (mounted) {
        _showError(e.message);
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        _showError('Error setting password.');
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  // --- UI Builders ---

  @override
  Widget build(BuildContext context) {
    // Back handler to go back steps instead of closing app
    return PopScope(
      canPop: _currentStep == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        setState(() {
          _currentStep--;
          _otpController.clear();
        });
      },
      child: Scaffold(
        body: Stack(
          children: [
            // Background Image
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?auto=format&fit=crop&w=1000&q=80',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Overlay
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(color: Colors.black.withOpacity(0.4)),
            ),
            
            // Content
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "Create Account",
                              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _getStepDescription(),
                              style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.8)),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),

                            // Dynamic Step Content
                            if (_currentStep == 0) _buildStep0(),
                            if (_currentStep == 1) _buildStep1(),
                            if (_currentStep == 2) _buildStep2(),
                            
                            const SizedBox(height: 24),

                            // Main Action Button
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _handleMainAction,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: _isLoading
                                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                    : Text(
                                        _getMainButtonText(),
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                              ),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Bottom Nav/Back Button
                            if (_currentStep == 0) ...[
                              TextButton(
                                onPressed: () => Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                                ),
                                child: Text(
                                  "Already have an account? Login",
                                  style: TextStyle(color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w500),
                                ),
                              ),
                            ] else ...[
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _currentStep--;
                                  });
                                },
                                child: Text(
                                  "Back",
                                  style: TextStyle(color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            // Back/Exit Button
            Positioned(
              top: 40,
              left: 20,
              child: GestureDetector(
                onTap: () => Navigator.of(context).maybePop(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Step Content Builders ---

  Widget _buildStep0() {
    return Column(
      children: [
        TextFormField(
          controller: _nameController,
          style: const TextStyle(color: Colors.white),
          decoration: _inputDecoration("Full Name", Icons.person_outline),
          validator: (v) => v == null || v.isEmpty ? 'Please enter your name' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _emailController,
          style: const TextStyle(color: Colors.white),
          keyboardType: TextInputType.emailAddress,
          decoration: _inputDecoration("Email Address", Icons.email_outlined),
          validator: (v) => v == null || !v.contains('@') ? 'Please enter a valid email' : null,
        ),
      ],
    );
  }

  Widget _buildStep1() {
    return Column(
      children: [
        Text(
          _emailController.text,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _otpController,
          style: const TextStyle(color: Colors.white, fontSize: 18, letterSpacing: 2),
          keyboardType: TextInputType.number,
          maxLength: 6,
          textAlign: TextAlign.center,
          decoration: _inputDecoration("Enter 6-digit OTP", Icons.lock_clock).copyWith(
            counterText: "",
          ),
          validator: (v) => v == null || v.length != 6 ? 'Enter full 6-digit OTP' : null,
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      children: [
        TextFormField(
          controller: _passwordController,
          obscureText: true,
          style: const TextStyle(color: Colors.white),
          decoration: _inputDecoration("Create Password", Icons.lock_outline),
          validator: (v) => v == null || v.length < 6 ? 'Min 6 characters' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: true,
          style: const TextStyle(color: Colors.white),
          decoration: _inputDecoration("Confirm Password", Icons.lock_outline),
          validator: (v) {
             if (v != _passwordController.text) return 'Passwords do not match';
             return null;
          },
        ),
      ],
    );
  }

  // Helpers
  
  void _handleMainAction() {
    switch (_currentStep) {
      case 0: _processStep0_SendOtp(); break;
      case 1: _processStep1_VerifyOtp(); break;
      case 2: _processStep2_SetPassword(); break;
    }
  }

  String _getMainButtonText() {
    switch (_currentStep) {
      case 0: return "Verify Email";
      case 1: return "Verify OTP";
      case 2: return "Complete Registration";
      default: return "";
    }
  }

  String _getStepDescription() {
    switch (_currentStep) {
      case 0: return "Step 1/3: Enter your details";
      case 1: return "Step 2/3: Verify your email";
      case 2: return "Step 3/3: Set a password";
      default: return "";
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
      prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.8)),
      filled: true,
      fillColor: Colors.white.withOpacity(0.1),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white)),
    );
  }
}
