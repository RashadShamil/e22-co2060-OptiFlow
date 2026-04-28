import 'package:flutter/material.dart';
// Ensure these paths match your folder structure
// import '../theme/mobile_theme.dart'; 
import 'mobile_dashboard_screen.dart';
import 'mobile_dashboard_screen.dart'; // If they are in the same folder

class MobileLoginScreen extends StatefulWidget {
  const MobileLoginScreen({super.key});

  @override
  State<MobileLoginScreen> createState() => _MobileLoginScreenState();
}

class _MobileLoginScreenState extends State<MobileLoginScreen> {
  bool _isLoading = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _handleLogin() async {
    setState(() => _isLoading = true);
    
    // Simulate Supabase Auth Latency
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      setState(() => _isLoading = false);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MobileDashboardScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Professional Slate Dark
      body: Stack(
        children: [
          // Subtle Tech Gradient Background instead of floating circles
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topRight,
                  radius: 1.5,
                  colors: [
                    const Color(0xFF1E293B),
                    const Color(0xFF0F172A),
                  ],
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Column(
                  children: [
                    // Branding
                    const Icon(Icons.layers_outlined, size: 60, color: Color(0xFF38BDF8)),
                    const SizedBox(height: 12),
                    const Text(
                      'OPTIFLOW',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 4.0,
                      ),
                    ),
                    const Text(
                      'OPERATOR PORTAL',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF38BDF8),
                        letterSpacing: 3.0,
                      ),
                    ),
                    const SizedBox(height: 50),

                    // Login Form Container
                    Container(
                      padding: const EdgeInsets.all(24.0),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Sign In", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 20),
                          
                          _buildTextField(
                            label: "Email Address",
                            icon: Icons.alternate_email,
                            controller: _emailController,
                          ),
                          const SizedBox(height: 20),
                          
                          _buildTextField(
                            label: "Password",
                            icon: Icons.lock_outline,
                            controller: _passwordController,
                            obscureText: true,
                          ),
                          const SizedBox(height: 30),

                          // Professional Action Button
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF38BDF8),
                                foregroundColor: const Color(0xFF0F172A),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                              child: _isLoading 
                                ? const SizedBox(
                                    height: 20, 
                                    width: 20, 
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0F172A))
                                  ) 
                                : const Text('ACCESS DASHBOARD', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.blueGrey, fontSize: 12)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.blueGrey, size: 20),
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF38BDF8)),
            ),
          ),
        ),
      ],
    );
  }
}
