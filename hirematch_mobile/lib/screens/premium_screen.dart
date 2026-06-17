import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../theme.dart';
import '../services/payment_service.dart';
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

  Future<void> _upgrade() async {
    setState(() {
      _processing = true;
      _message = null;
    });
    try {
      final clientSecret = await _paymentService.createPaymentIntent();
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'HireMatch',
        ),
      );
      await Stripe.instance.presentPaymentSheet();
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
        content: const Text('Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Yes'),
          ),
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
        _message = 'Refund processed.';
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

  Future<void> _refreshUser() async {
    await context.read<AuthProvider>().reloadUser();
  }

  @override
  Widget build(BuildContext context) {
    final isPremium = context.watch<AuthProvider>().user?.isPremium ?? false;
    return Scaffold(
      appBar: AppBar(leading: const BackButton(), title: const Text('Premium')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.tealDark, AppColors.tealMain],
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
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    isPremium
                        ? 'Your profile is highlighted.'
                        : 'Stand out to recruiters.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _benefit('Profile top of Talent Pool'),
            _benefit('Premium badge'),
            _benefit('Higher visibility'),
            const SizedBox(height: 24),
            if (_message != null)
              Container(
                padding: const EdgeInsets.all(12),
                color: _messageIsError
                    ? Colors.red.shade100
                    : Colors.green.shade100,
                child: Text(_message!, textAlign: TextAlign.center),
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: isPremium
                  ? OutlinedButton(
                      onPressed: _processing ? null : _refund,
                      child: const Text('Cancel & Refund'),
                    )
                  : ElevatedButton(
                      onPressed: _processing ? null : _upgrade,
                      child: const Text('Upgrade to Premium'),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _benefit(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      children: [
        const Icon(Icons.check_circle, color: AppColors.tealMain),
        const SizedBox(width: 10),
        Text(text),
      ],
    ),
  );
}
