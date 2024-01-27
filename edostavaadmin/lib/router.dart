import 'package:edostavaadmin/features/Account/home_admin_screen.dart';
import 'package:edostavaadmin/features/Auth/login_admin_screen.dart';
import 'package:edostavaadmin/features/Auth/registracija_korisnika_screen.dart';
import 'package:flutter/material.dart';

Route<dynamic> onGeneretedRoute(RouteSettings routeSettings) {
  switch (routeSettings.name) {
    case HomeAdminScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => HomeAdminScreen(userData: routeSettings.arguments),
      );
    case LoginAdminScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const LoginAdminScreen(),
      );

    case RegistracijaKorisnikaScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const RegistracijaKorisnikaScreen(),
      );
    default:
      return MaterialPageRoute(
        builder: (_) => const Scaffold(
          body: Center(
            child: Text('PAGE NOT FOUND'),
          ),
        ),
      );
  }
}
