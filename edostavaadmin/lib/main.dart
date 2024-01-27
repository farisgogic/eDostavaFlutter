import 'package:edostavaadmin/constants/global_variables.dart';
import 'package:edostavaadmin/features/Auth/login_admin_screen.dart';
import 'package:edostavaadmin/providers/korisnik_provider.dart';
import 'package:edostavaadmin/router.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => KorisnikProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'eDostavaAdmin',
      debugShowCheckedModeBanner: false,
      onGenerateRoute: (settings) => onGeneretedRoute(settings),
      theme: ThemeData(
        scaffoldBackgroundColor: GlobalVariables.backgroundColor,
      ),
      home: const LoginAdminScreen(),
    );
  }
}
