import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../theme.dart';
import '../services/payment_service.dart';
import '../services/auth_service.dart';
import '../providers/auth_provider.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  final PaymentService _paymentService = PaymentService();
  bool _processing = false;
  String? _message;
  bool _messageIsError = false;

  bool get _isPremium => context.read<AuthProvider>().user?.isPremium ?? false;

  Future<void> _upgrade() async {
    setState(() {
      _processing = true;
      _message = null;
    });

    try {
      // 1. Backend kreira PaymentIntent i vraća clientSecret
      final clientSecret = await _paymentService.createPaymentIntent();

      // 2. Inicijalizuj Stripe PaymentSheet (in-app)
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'HireMatch',
        ),
      );

      // 3. Prikaži PaymentSheet korisniku
      await Stripe.instance.presentPaymentSheet();

      // 4. Plaćanje uspješno na klijentu; backend webhook potvrđuje i postavlja IsPremium.
      //    Dajemo backendu sekundu pa osvježavamo korisnika.
      await Future.delayed(const Duration(seconds: 2));
      await _refreshUser();

      setState(() {
        _processing = false;
        _message = 'Payment successful! You are now a Premium member.';
        _messageIsError = false;
      });
    } on StripeException catch (e) {
      setState(() {
        _processing = false;
        _message = e.error.localizedMessage ?? 'Payment was cancelled.';
        _messageIsError = true;
      });
    } catch (e) {
      setState(() {
        _processing = false;
        _message = 'Something went wrong. Please try again.';
        _messageIsError = true;
      });
    }
  }

  Future<void> _refund() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Premium'),
        content: const Text('Are you sure you want to cancel Premium and get a refund?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('No')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Yes, refund')),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() {
      _processing = true;
      _message = null;
    });

    try {
      await _paymentService.refundPremium();
      await _refreshUser();
      setState(() {
        _processing = false;
        _message = 'Refund processed. Premium has been removed.';
        _messageIsError = false;
      });
    } catch (e) {
      setState(() {
        _processing = false;
        _message = e.toString().replaceFirst('Exception: ', '');
        _messageIsError = true;
      });
    }
  }

  // Ponovo učitaj korisnika da osvježimo isPremium status
  Future<void> _refreshUser() async {
    final auth = context.read<AuthProvider>();
    await auth.reloadUser();
  }

  @override
  Widget build(BuildContext context) {
    final isPremium = context.watch<AuthProvider>().user?.isPremium ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text('Premium')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.tealDark, AppColors.tealMain],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('⭐', style: TextStyle(fontSize: 36)),
                  const SizedBox(height: 12),
                  Text(
                    isPremium ? 'You are Premium!' : 'HireMatch Premium',
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isPremium
                        ? 'Your profile is highlighted to recruiters.'
                        : 'Stand out to recruiters and get noticed first.',
                    style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text('What you get', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            _benefit('Your profile appears at the top of the Talent Pool'),
            _benefit('A Premium badge on your profile'),
            _benefit('Higher visibility to recruiters'),

            const SizedBox(height: 24),
            Center(
              child: Text(
                isPremium ? '' : '\$15.00 one-time',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.tealDark),
              ),
            ),
            const SizedBox(height: 16),

            if (_message != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _messageIsError ? const Color(0xFFFDE8E8) : const Color(0xFFEAF6EC),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _message!,
                  style: TextStyle(
                    color: _messageIsError ? const Color(0xFFC0392B) : const Color(0xFF2E5E3A),
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
            ],

            if (!isPremium)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _processing ? null : _upgrade,
                  child: _processing
                      ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Upgrade to Premium'),
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _processing ? null : _refund,
                  child: _processing
                      ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Cancel & Refund'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _benefit(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: AppColors.tealMain, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}