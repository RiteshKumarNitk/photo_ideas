import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../home/screens/home_screen.dart';
import 'login_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // State
  int _currentStep = 0; // 0: Email, 1: OTP, 2: New Password
  bool _isLoading = false;

  @override
  void dispose() {
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
      // Send OTP to email (Log in via OTP)
      // We use signInWithOtp because we want to log them in to let them change password.
      await Supabase.instance.client.auth.signInWithOtp(
        email: email,
        shouldCreateUser: false, // Don't create new users here
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
        _showError('Error sending OTP. Please check the email.');
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
            _currentStep = 2; // Move to Set Password step
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

  Future<void> _processStep2_SetNewPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final userAttributes = UserAttributes(
        password: _passwordController.text.trim(),
      );

      await Supabase.instance.client.auth.updateUser(userAttributes);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password updated successfully!')),
        );
        // Navigate to home
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
        _showError('Error updating password.');
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
    return PopScope(
      canPop: _currentStep == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        setState(() {
          _currentStep--;
          // Clear sensitive fields when going back? Maybe not necessary for UX
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
            // Blur Effect
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
                              "Reset Password",
                              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _getStepDescription(),
                              style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.8)),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),

                            if (_currentStep == 0) _buildStep0(),
                            if (_currentStep == 1) _buildStep1(),
                            if (_currentStep == 2) _buildStep2(),
                            
                            const SizedBox(height: 24),

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
                            if (_currentStep == 0)
                              TextButton(
                                onPressed: () => Navigator.pushReplacement(
                                  context, 
                                  MaterialPageRoute(builder: (context) => const LoginScreen())
                                ),
                                child: Text(
                                  "Back to Login",
                                  style: TextStyle(color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w500),
                                ),
                              )
                            else 
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
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep0() {
    return Column(
      children: [
        TextFormField(
          controller: _emailController,
          style: const TextStyle(color: Colors.white),
          keyboardType: TextInputType.emailAddress,
          decoration: _inputDecoration("Email Address", Icons.email_outlined),
          validator: (v) => v == null || !v.contains('@') ? 'Enter a valid email' : null,
        ),
      ],
    );
  }

  Widget _buildStep1() {
    return Column(
      children: [
        Text(
          "Code sent to ${_emailController.text}",
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _otpController,
          style: const TextStyle(color: Colors.white, fontSize: 18, letterSpacing: 2),
          keyboardType: TextInputType.number,
          maxLength: 6,
          textAlign: TextAlign.center,
          decoration: _inputDecoration("Enter 6-digit OTP", Icons.lock_clock).copyWith(counterText: ""),
          validator: (v) => v == null || v.length != 6 ? 'Enter 6 digits' : null,
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
          decoration: _inputDecoration("New Password", Icons.lock_outline),
          validator: (v) => v == null || v.length < 6 ? 'Min 6 chars' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: true,
          style: const TextStyle(color: Colors.white),
          decoration: _inputDecoration("Confirm New Password", Icons.lock_outline),
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
      case 2: _processStep2_SetNewPassword(); break;
    }
  }

  String _getMainButtonText() {
    switch (_currentStep) {
      case 0: return "Send Reset Code";
      case 1: return "Verify Code";
      case 2: return "Update Password";
      default: return "";
    }
  }

  String _getStepDescription() {
    switch (_currentStep) {
      case 0: return "Step 1/3: Enter your account email";
      case 1: return "Step 2/3: Enter the code sent to your email";
      case 2: return "Step 3/3: Create a new password";
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
