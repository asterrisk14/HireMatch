import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'theme.dart';
import 'providers/auth_provider.dart';
import 'providers/favoruites_provider.dart';
import 'screens/login_screen.dart';
import 'screens/main_navigation.dart';


const String stripePublishableKey = String.fromEnvironment('STRIPE_PUBLISHABLE_KEY', defaultValue: 'pk_test_51Tit6mFNY5ev6BaeGC5lDBEBspWWLYvsahtBOnENeQ9xTKWOncOk9fwoypE4xXkF8rsg7x2FhnxcczbS2ux3RWtG00HsYtisaI');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    Stripe.publishableKey = stripePublishableKey;
    await Stripe.instance.applySettings();
  } catch (e) {
    print('Stripe init error: $e');
  }
  runApp(const HireMatchApp());
}

class HireMatchApp extends StatelessWidget {
  const HireMatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => FavouritesProvider()),
      ],
      child: MaterialApp(
        title: 'HireMatch',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        home: const SplashScreen(),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final auth = context.read<AuthProvider>();
    await auth.init();

    if (!mounted) return;

    if (auth.isLoggedIn) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainNavigation()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.tealMain,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _logoSquare(0.9),
                const SizedBox(width: 4),
                _logoSquare(0.6),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _logoSquare(0.6),
                const SizedBox(width: 4),
                _logoSquare(0.9),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'HireMatch',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _logoSquare(double opacity) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(opacity),
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}