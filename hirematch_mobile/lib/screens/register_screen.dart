import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../providers/auth_provider.dart';
import '../services/location_service.dart';
import 'onboarding/onboarding_industry_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  DateTime? _dateOfBirth;

  final LocationService _locationService = LocationService();
  List<Country> _countries = [];
  List<City> _cities = [];
  int? _selectedCountryId;
  int? _selectedCityId;
  bool _loadingLocations = true;

  String? _phoneError;

  // BiH format: 06X XXX XXX (9 cifara) ili +387 6X XXX XXX
  static final RegExp _phoneRegex = RegExp(r'^(\+387|0)6[0-9]{7}$');

  @override
  void initState() {
    super.initState();
    _loadCountries();
  }

  Future<void> _loadCountries() async {
    try {
      final countries = await _locationService.getCountries();
      // ignore: avoid_print
      print('COUNTRIES: ${countries.map((c) => '${c.id}:${c.name}').toList()}');
      setState(() {
        _countries = countries;
        _loadingLocations = false;
      });
      if (countries.isNotEmpty) {
        _onCountryChanged(countries.first.id);
      }
    } catch (e) {
      // ignore: avoid_print
      print('COUNTRIES ERROR: $e');
      setState(() => _loadingLocations = false);
    }
  }

  Future<void> _onCountryChanged(int? countryId) async {
    setState(() {
      _selectedCountryId = countryId;
      _selectedCityId = null;
      _cities = [];
    });
    if (countryId == null) return;
    try {
      final cities = await _locationService.getCities(countryId);
      setState(() {
        _cities = cities;
        if (cities.isNotEmpty) _selectedCityId = cities.first.id;
      });
    } catch (_) {}
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 20, now.month, now.day),
      firstDate: DateTime(now.year - 100),
      lastDate: DateTime(now.year - 16, now.month, now.day),
      helpText: 'Select date of birth',
    );
    if (picked != null) {
      setState(() => _dateOfBirth = picked);
    }
  }

  bool _validatePhone() {
    final phone = _phoneController.text.trim();
    if (!_phoneRegex.hasMatch(phone)) {
      setState(() {
        _phoneError = 'Enter a valid phone number (e.g. 061234567 or +38761234567)';
      });
      return false;
    }
    setState(() => _phoneError = null);
    return true;
  }

  Future<void> _register() async {
    final auth = context.read<AuthProvider>();

    // Obavezna polja
    if (_firstNameController.text.trim().isEmpty) {
      auth.errorMessage = 'Please enter your first name.';
      setState(() {});
      return;
    }
    if (_lastNameController.text.trim().isEmpty) {
      auth.errorMessage = 'Please enter your last name.';
      setState(() {});
      return;
    }
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      auth.errorMessage = 'Please enter your email.';
      setState(() {});
      return;
    }
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      auth.errorMessage = 'Please enter a valid email address.';
      setState(() {});
      return;
    }
    if (_passwordController.text.length < 6) {
      auth.errorMessage = 'Password must be at least 6 characters long.';
      setState(() {});
      return;
    }

    if (!_validatePhone()) return;

    if (_dateOfBirth == null) {
      auth.errorMessage = 'Please select your date of birth.';
      setState(() {});
      return;
    }

    if (_selectedCountryId == null || _selectedCityId == null) {
      auth.errorMessage = 'Please select your country and city.';
      setState(() {});
      return;
    }

    final dob = '${_dateOfBirth!.year.toString().padLeft(4, '0')}-'
        '${_dateOfBirth!.month.toString().padLeft(2, '0')}-'
        '${_dateOfBirth!.day.toString().padLeft(2, '0')}';

    final success = await auth.register(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: email,
      password: _passwordController.text,
      dateOfBirth: dob,
      countryId: _selectedCountryId!,
      cityId: _selectedCityId!,
      phone: _phoneController.text.trim(),
    );

    if (success && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OnboardingIndustryScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Join HireMatch',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.tealDark),
              ),
              const SizedBox(height: 6),
              const Text(
                'Create an account to find your next opportunity',
                style: TextStyle(fontSize: 13, color: AppColors.textMuted),
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(labelText: 'First name'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(labelText: 'Last name'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 14),

              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                onChanged: (_) {
                  if (_phoneError != null) _validatePhone();
                },
                decoration: InputDecoration(
                  labelText: 'Phone',
                  hintText: 'e.g. 061234567',
                  errorText: _phoneError,
                ),
              ),
              const SizedBox(height: 14),

              GestureDetector(
                onTap: _pickDateOfBirth,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date of birth',
                    suffixIcon: Icon(Icons.calendar_today_outlined, size: 18),
                  ),
                  child: Text(
                    _dateOfBirth != null
                        ? '${_dateOfBirth!.day.toString().padLeft(2, '0')}.${_dateOfBirth!.month.toString().padLeft(2, '0')}.${_dateOfBirth!.year}'
                        : 'Select date',
                    style: TextStyle(
                      color: _dateOfBirth != null ? AppColors.textPrimary : AppColors.textMuted,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              if (_loadingLocations)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                )
              else ...[
                DropdownButtonFormField<int>(
                  value: _selectedCountryId,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Country'),
                  items: _countries
                      .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                      .toList(),
                  onChanged: _onCountryChanged,
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<int>(
                  value: _selectedCityId,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'City'),
                  items: _cities
                      .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                      .toList(),
                  onChanged: (value) => setState(() => _selectedCityId = value),
                ),
              ],

              const SizedBox(height: 14),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),

              if (auth.errorMessage != null) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDE8E8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    auth.errorMessage!,
                    style: const TextStyle(color: Color(0xFFC0392B), fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: auth.isLoading ? null : _register,
                  child: auth.isLoading
                      ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                      : const Text('Create account'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}