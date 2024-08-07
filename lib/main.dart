import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yildiz_obs_mobile/screens/login_screen.dart';
import 'package:yildiz_obs_mobile/screens/obs_fast_login_screen.dart';
import 'package:yildiz_obs_mobile/screens/obs_classic_login_screen.dart';
import 'package:yildiz_obs_mobile/screens/onboarding_screen.dart';
import 'package:yildiz_obs_mobile/screens/setup_screen.dart';

final GlobalKey<NavigatorState> appNavigator = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);


  final prefs = await SharedPreferences.getInstance();
  final skipSetup = prefs.getBool("skipSetup") ?? false;
  runApp(YildizOBSMobil(skipSetup: skipSetup));
}

class YildizOBSMobil extends StatelessWidget {

  final bool skipSetup;


  const YildizOBSMobil({Key? key, required this.skipSetup}) : super(key: key);


  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      builder: FToastBuilder(),
      navigatorKey: appNavigator,
      routes: {
        "/login":(context) => const LoginPage(justLoggedOut: false),
        "/login-justLoggedOut":(context) => const LoginPage(justLoggedOut: true),
        "/onboarding":(context) => const OnboardingPage(),
        "/setup":(context) => const SetupPage(loggedIn: false),
        "/setup-loggedIn":(context) => const SetupPage(loggedIn: true),
        "/obs-fast":(context) => const FastLoginOBSPage(),
        "/obs-classic":(context) => const ClassicLoginOBSPage()
      },
      title: 'Yıldız OBS Mobil',
      debugShowCheckedModeBanner: false,
      home: skipSetup ? const LoginPage(justLoggedOut: false,) : const OnboardingPage(),
      theme: ThemeData(
        textTheme: GoogleFonts.lexendTextTheme(Theme.of(context).textTheme).apply(bodyColor: Colors.white, displayColor: Colors.white),
        colorScheme: const ColorScheme(
          brightness: Brightness.dark,
          primary: Color(0xFFBAC3FF),
          onPrimary: Color(0xFF172778),
          primaryContainer: Color(0xFF313F90),
          onPrimaryContainer: Color(0xFFDEE0FF),
          secondary: Color(0xFFF4BE48),
          onSecondary: Color(0xFF402D00),
          secondaryContainer: Color(0xFF5C4200),
          onSecondaryContainer: Color(0xFFFFDEA1),
          tertiary: Color(0xFFCFBCFF),
          onTertiary: Color(0xFF381E72),
          tertiaryContainer: Color(0xFF4F378A),
          onTertiaryContainer: Color(0xFFE9DDFF),
          error: Color(0xFFFFB4AB),
          errorContainer: Color(0xFF93000A),
          onError: Color(0xFF690005),
          onErrorContainer: Color(0xFFFFDAD6),
          surface: Color(0xFF1B1B1F),
          onSurface: Color(0xFFE4E1E6),
          surfaceContainerHighest: Color(0xFF46464F),
          onSurfaceVariant: Color(0xFFC7C5D0),
          outline: Color(0xFF90909A),
          onInverseSurface: Color(0xFF1B1B1F),
          inverseSurface: Color(0xFFE4E1E6),
          inversePrimary: Color(0xFF4A58A9),
          shadow: Color(0xFF000000),
          surfaceTint: Color(0xFFBAC3FF),
          outlineVariant: Color(0xFF46464F),
          scrim: Color(0xFF000000),
        ),
        useMaterial3: true,
      ),
    );
  }
}

