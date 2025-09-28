import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../services/user_service.dart';
import '../widgets/custom_input.dart';
import '../constants.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _ageController = TextEditingController();
  String? _selectedGender;
  final _contactController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _addressController = TextEditingController();
  final _userService = UserService();
  bool _isLoading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _ageController.dispose();
    _contactController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _handleMongoDBSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _userService.registerUser(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        age: int.parse(_ageController.text.trim()),
        gender: _selectedGender ?? '',
        contactNumber: _contactController.text.trim(),
        email: _emailController.text.trim(),
        username: _usernameController.text.trim(),
        password: _passwordController.text.trim(),
        address: _addressController.text.trim(),
      );

      // Save user data if token is returned
      if (response['token'] != null) {
        await _userService.saveUserData(response);
      }

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('MongoDB Registration successful!')),
      );

      // Navigate to home or login
      if (response['token'] != null) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      if (!mounted) return;

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('MongoDB Registration failed: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleFirebaseSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final userCredential = await _userService.createAccount(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
      );

      // Update display name with the username
      await _userService.updateUsername(username: _usernameController.text.trim());

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Firebase Registration successful!')),
      );

      // Navigate to home
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      if (!mounted) return;

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Firebase Registration failed: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppGradients.primaryGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: screenSize.width * 0.05,
              vertical: screenSize.height * 0.02,
            ),
            child: Column(
              children: [
                // Header Section
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: screenSize.height * 0.03),
                  child: Column(
                    children: [
                      // Back Button
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(UIConstants.radiusL),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back_ios_new,
                              color: AppColors.white,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ),
                      
                      SizedBox(height: screenSize.height * 0.02),
                      
                      // Title Section
                      Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: screenSize.width * 0.08,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                          letterSpacing: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      SizedBox(height: screenSize.height * 0.01),
                      
                      Text(
                        'Join us and start your journey',
                        style: TextStyle(
                          fontSize: screenSize.width * 0.04,
                          color: AppColors.white.withOpacity(0.8),
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                // Form Card
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(vertical: screenSize.height * 0.02),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(UIConstants.radiusXL),
                    boxShadow: const [AppShadows.medium],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(screenSize.width * 0.06),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                
                          // Personal Information Section
                          Container(
                            padding: EdgeInsets.symmetric(vertical: screenSize.height * 0.01),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Personal Information',
                                  style: TextStyle(
                                    fontSize: screenSize.width * 0.045,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                SizedBox(height: screenSize.height * 0.02),
                                
                                // First Name
                                Container(
                                  margin: EdgeInsets.only(bottom: screenSize.height * 0.015),
                                  child: TextFormField(
                                    controller: _firstNameController,
                                    style: TextStyle(fontSize: screenSize.width * 0.04),
                                    decoration: InputDecoration(
                                      labelText: 'First Name',
                                      prefixIcon: Icon(
                                        Icons.person_outline,
                                        color: AppColors.primary,
                                        size: screenSize.width * 0.05,
                                      ),
                                      filled: true,
                                      fillColor: AppColors.grey50,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(UIConstants.radiusL),
                                        borderSide: BorderSide.none,
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(UIConstants.radiusL),
                                        borderSide: BorderSide(color: AppColors.primary, width: 2),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'Please enter your first name';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                
                                // Last Name
                                Container(
                                  margin: EdgeInsets.only(bottom: screenSize.height * 0.015),
                                  child: TextFormField(
                                    controller: _lastNameController,
                                    style: TextStyle(fontSize: screenSize.width * 0.04),
                                    decoration: InputDecoration(
                                      labelText: 'Last Name',
                                      prefixIcon: Icon(
                                        Icons.person_outline,
                                        color: AppColors.primary,
                                        size: screenSize.width * 0.05,
                                      ),
                                      filled: true,
                                      fillColor: AppColors.grey50,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(UIConstants.radiusL),
                                        borderSide: BorderSide.none,
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(UIConstants.radiusL),
                                        borderSide: BorderSide(color: AppColors.primary, width: 2),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'Please enter your last name';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                
                                // Age and Gender Row
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        margin: EdgeInsets.only(bottom: screenSize.height * 0.015, right: 8),
                                        child: NumberInput(
                                          label: 'Age',
                                          hint: 'Enter your age',
                                          controller: _ageController,
                                          min: 18,
                                          max: 100,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        margin: EdgeInsets.only(bottom: screenSize.height * 0.015, left: 8),
                                        child: DropdownInput<String>(
                                          label: 'Gender',
                                          hint: 'Select your gender',
                                          value: _selectedGender,
                                          items: const [
                                            DropdownMenuItem(value: 'Male', child: Text('Male')),
                                            DropdownMenuItem(value: 'Female', child: Text('Female')),
                                            DropdownMenuItem(value: 'Other', child: Text('Other')),
                                            DropdownMenuItem(value: 'Prefer not to say', child: Text('Prefer not to say')),
                                          ],
                                          onChanged: (value) {
                                            setState(() {
                                              _selectedGender = value;
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          
                          // Contact Information Section
                          Container(
                            padding: EdgeInsets.symmetric(vertical: screenSize.height * 0.02),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Contact Information',
                                  style: TextStyle(
                                    fontSize: screenSize.width * 0.045,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                SizedBox(height: screenSize.height * 0.02),
                                
                                // Phone Number
                                Container(
                                  margin: EdgeInsets.only(bottom: screenSize.height * 0.015),
                                  child: PhoneInput(
                                    label: 'Contact Number',
                                    hint: 'Enter your phone number',
                                    controller: _contactController,
                                  ),
                                ),
                                
                                // Email
                                Container(
                                  margin: EdgeInsets.only(bottom: screenSize.height * 0.015),
                                  child: EmailInput(
                                    label: 'Email',
                                    hint: 'Enter your email address',
                                    controller: _emailController,
                                  ),
                                ),
                                
                                // Address
                                Container(
                                  margin: EdgeInsets.only(bottom: screenSize.height * 0.015),
                                  child: TextFormField(
                                    controller: _addressController,
                                    maxLines: 3,
                                    style: TextStyle(fontSize: screenSize.width * 0.04),
                                    decoration: InputDecoration(
                                      labelText: 'Address',
                                      prefixIcon: Icon(
                                        Icons.location_on_outlined,
                                        color: AppColors.primary,
                                        size: screenSize.width * 0.05,
                                      ),
                                      filled: true,
                                      fillColor: AppColors.grey50,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(UIConstants.radiusL),
                                        borderSide: BorderSide.none,
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(UIConstants.radiusL),
                                        borderSide: const BorderSide(color: AppColors.primary, width: 2),
                                      ),
                                      alignLabelWithHint: true,
                                    ),
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'Please enter your address';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Account Information Section
                          Container(
                            padding: EdgeInsets.symmetric(vertical: screenSize.height * 0.02),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Account Information',
                                  style: TextStyle(
                                    fontSize: screenSize.width * 0.045,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                SizedBox(height: screenSize.height * 0.02),
                                
                                // Username
                                Container(
                                  margin: EdgeInsets.only(bottom: screenSize.height * 0.015),
                                  child: TextFormField(
                                    controller: _usernameController,
                                    style: TextStyle(fontSize: screenSize.width * 0.04),
                                    decoration: InputDecoration(
                                      labelText: 'Username',
                                      prefixIcon: Icon(
                                        Icons.account_circle_outlined,
                                        color: AppColors.primary,
                                        size: screenSize.width * 0.05,
                                      ),
                                      filled: true,
                                      fillColor: AppColors.grey50,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(UIConstants.radiusL),
                                        borderSide: BorderSide.none,
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(UIConstants.radiusL),
                                        borderSide: const BorderSide(color: AppColors.primary, width: 2),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'Please enter a username';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                
                                // Password
                                Container(
                                  margin: EdgeInsets.only(bottom: screenSize.height * 0.03),
                                  child: EnhancedPasswordInput(
                                    label: 'Password',
                                    hint: 'Enter a strong password',
                                    controller: _passwordController,
                                    showStrengthIndicator: true,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // MongoDB Sign Up Button
                          Container(
                            width: double.infinity,
                            height: screenSize.height * 0.065,
                            margin: EdgeInsets.symmetric(vertical: screenSize.height * 0.01),
                            decoration: BoxDecoration(
                              gradient: AppGradients.primaryGradient,
                              borderRadius: BorderRadius.circular(UIConstants.radiusL),
                              boxShadow: const [AppShadows.soft],
                            ),
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleMongoDBSignUp,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(UIConstants.radiusL),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 3,
                                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                                      ),
                                    )
                                  : Text(
                                      'Create Account (MongoDB)',
                                      style: TextStyle(
                                        fontSize: screenSize.width * 0.04,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.white,
                                      ),
                                    ),
                            ),
                          ),

                          // Firebase Sign Up Button
                          Container(
                            width: double.infinity,
                            height: screenSize.height * 0.065,
                            margin: EdgeInsets.symmetric(vertical: screenSize.height * 0.01),
                            decoration: BoxDecoration(
                              color: AppColors.secondary,
                              borderRadius: BorderRadius.circular(UIConstants.radiusL),
                              boxShadow: const [AppShadows.soft],
                            ),
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleFirebaseSignUp,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(UIConstants.radiusL),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 3,
                                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                                      ),
                                    )
                                  : Text(
                                      'Create Account (Firebase)',
                                      style: TextStyle(
                                        fontSize: screenSize.width * 0.04,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.white,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: UIConstants.spacingS),

                          // Helpful note
                          Text(
                            'Choose your preferred authentication method above.',
                            style: TextStyle(
                              fontSize: screenSize.width * 0.03,
                              color: AppColors.textSecondary,
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          // Login Link
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: UIConstants.spacingS),
                            ),
                            child: RichText(
                              text: TextSpan(
                                text: "Already have an account? ",
                                style: TextStyle(
                                  fontSize: screenSize.width * 0.035,
                                  color: AppColors.textSecondary,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Login',
                                    style: TextStyle(
                                      fontSize: screenSize.width * 0.035,
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}