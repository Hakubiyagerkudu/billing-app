import 'package:flutter/material.dart';
import 'package:kontor/screens/auth/forgot_password_screen.dart';
import 'package:kontor/screens/auth/register_screen.dart';
import 'package:kontor/screens/auth/verify_password_screen.dart';
import 'package:kontor/screens/invoice/invoice_detail_screen.dart';
import 'package:kontor/screens/invoice/payment_screen.dart';
import 'package:kontor/screens/main_home.dart';
import 'package:kontor/screens/settings/change_password_screen.dart';
import 'package:kontor/screens/settings/counter_screen.dart';
import 'package:kontor/screens/settings/user_profile_screen.dart';
import '../screens/auth/login_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String login = '/login';
  static const String counter = '/counter';
  static const String register = '/register';
  static const String userProfile = '/userProfile';
  static const String changePassword = '/changePassword';
  static const String forgotPassword = '/forgotPassword';
  static const String verifyPassword = '/verifyPassword';
  static const String invoiceDetail = '/invoiceDetail';
  static const String qpayInvoice = '/qpayInvoice';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const MainHome());
      case login:
        final userCode = settings.arguments as String?;
        return MaterialPageRoute(
            builder: (_) => LoginScreen(rememberedUserCode: userCode ?? ""));
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case counter:
        return MaterialPageRoute(builder: (_) => const CounterScreen());
      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      case userProfile:
        return MaterialPageRoute(builder: (_) => const UserProfileScreen());
      case changePassword:
        return MaterialPageRoute(builder: (_) => const ChangePasswordScreen());
      case verifyPassword:
        final email = settings.arguments as String;
        return MaterialPageRoute(
            builder: (_) => VerifyPasswordScreen(email: email));
      case invoiceDetail:
        final args = settings.arguments as Map<String, dynamic>;

        final paid = args['paid'] as bool;
        final invoiceId = args['invoiceId'] as String;

        return MaterialPageRoute(
            builder: (_) =>
                InvoiceDetailScreen(paid: paid, invoiceId: invoiceId));
      case qpayInvoice:
        final args = settings.arguments as Map<String, dynamic>;

        final invoiceIds = args['invoiceIds'] as List<dynamic>;
        final userType = args['userType'] as String;
        final userRegister = args['userRegister'] as String;

        return MaterialPageRoute(
          builder: (_) => PaymentScreen(
            invoiceIds: invoiceIds,
            userType: userType,
            userRegister: userRegister,
          ),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text("404 - Page not found")),
          ),
        );
    }
  }
}
