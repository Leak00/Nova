import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/secure_storage_service.dart';

class AuthScreen extends StatefulWidget {
  final ValueChanged<String> onLogin;

  const AuthScreen({super.key, required this.onLogin});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  static const String demoEmail = 'alex@company.com';
  static const String demoPassword = '1234';
  static const String demoName = 'Alex';
  static const String demoToken = 'demo_token';

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isRegisterMode = false;
  bool isLoading = false;
  bool passwordVisible = false;
  String? errorMessage;

  Future<void> _submit() async {
    final fullName = fullNameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;

    setState(() {
      errorMessage = null;
    });

    if (email.isEmpty || !email.contains('@')) {
      setState(() {
        errorMessage = 'Enter a valid email address.';
      });
      return;
    }

    if (password.length < 8 && !_isDemoCredentials()) {
      setState(() {
        errorMessage = 'Password must be at least 8 characters long.';
      });
      return;
    }

    if (isRegisterMode && fullName.isEmpty) {
      setState(() {
        errorMessage = 'Please enter your full name.';
      });
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      if (!isRegisterMode && _isDemoCredentials()) {
        await _loginDemo();
        return;
      }

      final response = isRegisterMode
          ? await ApiService.register(fullName, email, password)
          : await ApiService.login(email, password);

      final token = response['token'] as String?;
      final user = response['user'] as Map<String, dynamic>?;
      final displayName = user?['name'] as String? ?? email;

      if (token == null || token.isEmpty) {
        throw Exception('Token not returned from server');
      }

      await SecureStorageService().saveLogin(displayName, token);
      widget.onLogin(displayName);
    } catch (error) {
      setState(() {
        errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  bool _isDemoCredentials() {
    return emailController.text.trim() == demoEmail &&
        passwordController.text == demoPassword;
  }

  Future<void> _loginDemo() async {
    await SecureStorageService().saveLogin(demoName, demoToken);
    widget.onLogin(demoName);
  }

  void _toggleMode() {
    setState(() {
      isRegisterMode = !isRegisterMode;
      errorMessage = null;
    });
  }

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final surfaceColor = colorScheme.surface;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Container(
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 28,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Text(
                          'NOVA Pro',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.primary,
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                    const SizedBox(height: 22),
                    Text(
                      isRegisterMode ? 'Create Account' : 'Login',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      isRegisterMode
                          ? 'Join the productivity ecosystem designed for high-velocity teams.'
                          : 'Access your professional workspace.',
                      style: TextStyle(
                        fontSize: 15,
                        color: colorScheme.onSurface.withValues(alpha: 0.72),
                      ),
                    ),
                    const SizedBox(height: 28),
                    if (isRegisterMode) ...[
                      _buildTextField(
                        controller: fullNameController,
                        label: 'Full Name',
                        hintText: 'John Doe',
                        prefixIcon: Icons.person,
                      ),
                      const SizedBox(height: 16),
                    ],
                    _buildTextField(
                      controller: emailController,
                      label: 'Email Address',
                      hintText: 'name@company.com',
                      prefixIcon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: passwordController,
                      label: 'Password',
                      hintText: '••••••••',
                      prefixIcon: Icons.lock,
                      obscureText: !passwordVisible,
                      suffixIcon: IconButton(
                        icon: Icon(
                          passwordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: colorScheme.onSurface.withValues(alpha: 0.65),
                        ),
                        onPressed: () {
                          setState(() {
                            passwordVisible = !passwordVisible;
                          });
                        },
                      ),
                    ),
                    if (errorMessage != null) ...[
                      const SizedBox(height: 18),
                      Text(
                        errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: isLoading ? null : _submit,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Text(
                              isRegisterMode
                                  ? 'Create Account'
                                  : 'Login to Workspace →',
                            ),
                    ),
                    const SizedBox(height: 14),
                    Center(
                      child: TextButton(
                        onPressed: _toggleMode,
                        child: RichText(
                          text: TextSpan(
                            text: isRegisterMode
                                ? 'Already have an account? '
                                : 'Don’t have an account? ',
                            style: TextStyle(
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.72,
                              ),
                              fontSize: 14,
                            ),
                            children: [
                              TextSpan(
                                text: isRegisterMode
                                    ? 'Log in'
                                    : 'Create an account',
                                style: TextStyle(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (!isRegisterMode) ...[
                      const SizedBox(height: 8),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            emailController.text = demoEmail;
                            passwordController.text = demoPassword;
                          },
                          child: const Text('Use demo credentials'),
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    if (!isRegisterMode)
                      Center(
                        child: TextButton(
                          onPressed: () async {
                            setState(() {
                              isLoading = true;
                              errorMessage = null;
                            });

                            await _loginDemo();

                            if (mounted) {
                              setState(() {
                                isLoading = false;
                              });
                            }
                          },
                          child: const Text('Login with demo account'),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hintText,
    IconData? prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
