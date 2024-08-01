import "package:connectivity_plus/connectivity_plus.dart";
import "package:flutter/material.dart";
import "package:local_auth/local_auth.dart";
import "package:yildiz_obs_mobile/main.dart";
import "../services/user_preferences.dart";
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatefulWidget {
  final bool justLoggedOut;
  const LoginPage({super.key, required this.justLoggedOut});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  late final LocalAuthentication auth;
  bool isLocalAuthSupported = false;
  bool isAuthEnabled = false;
  ConnectivityResult? connection;
  bool userPrefersFastLogin = true;

  Future<void> _fetchEnabledAuth(bool setup) async {
    isAuthEnabled = await UserPreferences.getEnableAuth();

    auth.isDeviceSupported().then((bool isSupported) {
      setState(() {
        isLocalAuthSupported = isSupported;
        if (isLocalAuthSupported) {
          if (isAuthEnabled) {
            _authenticate(setup);
          } else {
            if (setup) {
              appNavigator.currentState?.pushReplacementNamed("/setup");
            } else {
              if (userPrefersFastLogin) {
                appNavigator.currentState?.pushReplacementNamed("/obs-fast");
              } else {
                appNavigator.currentState?.pushReplacementNamed("/obs-classic");
              }
            }
          }
        } else {
          UserPreferences.setEnableAuth(false);
          if (setup) {
            appNavigator.currentState?.pushReplacementNamed("/setup");
          } else {
            if (userPrefersFastLogin) {
              appNavigator.currentState?.pushReplacementNamed("/obs-fast");
            } else {
              appNavigator.currentState?.pushReplacementNamed("/obs-classic");
            }
          }
        }
      });
    });
  }

  Future<void> checkNetworkConnection() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    setState(() {
      connection = connectivityResult;
    });
  }

  Future<void> checkFastLoginEnabled() async {
    final bool prefersFastLogin = await UserPreferences.getPrefersFastLogin();
    setState(() {
      userPrefersFastLogin = prefersFastLogin;
    });
  }

  @override
  void initState() {
    checkNetworkConnection();
    checkFastLoginEnabled();
    auth = LocalAuthentication();

    if (!widget.justLoggedOut) {
      _fetchEnabledAuth(false);
    }
    super.initState();
  }

  Future<void> _authenticate(bool setup) async {
    if (isAuthEnabled) {
      bool authenticated = await auth.authenticate(
          localizedReason: "",
          options: const AuthenticationOptions(
              stickyAuth: true,
              biometricOnly: false,
              sensitiveTransaction: true));
      if (authenticated) {
        if (setup) {
          appNavigator.currentState?.pushReplacementNamed("/setup");
        } else {
          if (userPrefersFastLogin) {
            appNavigator.currentState?.pushReplacementNamed("/obs-fast");
          } else {
            appNavigator.currentState?.pushReplacementNamed("/obs-classic");
          }
        }
      }
    } else {
      if (setup) {
        appNavigator.currentState?.pushReplacementNamed("/setup");
      } else {
        if (userPrefersFastLogin) {
          appNavigator.currentState?.pushReplacementNamed("/obs-fast");
        } else {
          appNavigator.currentState?.pushReplacementNamed("/obs-classic");
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Scaffold(
        backgroundColor: const Color(0XFF121e2d),
        body: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height / 3,
              child: Image.asset("assets/images/logo.png"),
            ),
            Text(
              "Yıldız OBS Mobil'e\nHoş Geldin!",
              textAlign: TextAlign.center,
              style: GoogleFonts.lexend(fontSize: 40),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FilledButton.icon(
                        style: FilledButton.styleFrom(
                            backgroundColor:
                                const Color.fromRGBO(0, 74, 153, 1),
                            side: const BorderSide(
                                width: 2, color: Colors.white)),
                        onPressed: () {
                          _fetchEnabledAuth(false);
                        },
                        icon: const Icon(
                          Icons.login,
                          color: Colors.white,
                        ),
                        label: const Text(
                          "Giriş yap",
                          style: TextStyle(color: Colors.white),
                        )),
                    FilledButton.icon(
                        style: FilledButton.styleFrom(
                            backgroundColor: const Color(0XFFae946e),
                            side: const BorderSide(
                                width: 2, color: Colors.white)),
                        onPressed: () {
                          _fetchEnabledAuth(true);
                        },
                        icon: const Icon(Icons.settings, color: Colors.white),
                        label: const Text(
                          "Ayarlar",
                          style: TextStyle(color: Colors.white),
                        ))
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
