import "package:connectivity_plus/connectivity_plus.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:local_auth/local_auth.dart";
import "package:yildiz_obs_mobile/main.dart";
import "../services/user_preferences.dart";

class LoginPage extends StatefulWidget {
  final bool justLoggedOut;
  const LoginPage({super.key, required this.justLoggedOut});

  @override
  State<LoginPage> createState() => _LoginPageState();
}







class _LoginPageState extends State<LoginPage> {
  late final LocalAuthentication auth;
  bool isLocalAuthSupported = false;
  bool showLoginButton = true;
  bool isAuthEnabled = false;
  ConnectivityResult? connection;
  bool userPrefersFastLogin = true;



  Future<void> _fetchEnabledAuth() async {
    isAuthEnabled = await UserPreferences.getEnableAuth();

    auth.isDeviceSupported().then((bool isSupported) {
      setState(() {
          isLocalAuthSupported = isSupported;
          if (isLocalAuthSupported) {
            if (isAuthEnabled) {
              _authenticate();
            }else {
              if (userPrefersFastLogin) {
                appNavigator.currentState?.pushReplacementNamed("/obs-fast");
              } else {
                appNavigator.currentState?.pushReplacementNamed("/obs-classic");
              }
            }
          }else {
            UserPreferences.setEnableAuth(false);
            if (userPrefersFastLogin) {
              appNavigator.currentState?.pushReplacementNamed("/obs-fast");
            } else {
              appNavigator.currentState?.pushReplacementNamed("/obs-classic");
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

  Future<void> checkFastLoginEnabled () async {
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
      _fetchEnabledAuth();
    }
    super.initState();
  }

  Future<void> _authenticate() async {

    setState(() {
      showLoginButton = false;
    });

    if(isAuthEnabled) {
      try {
        bool authenticated = await auth.authenticate(
            localizedReason: "Giriş yapmak için kimliğinizi doğrulayın",
            options: const AuthenticationOptions(
                stickyAuth: true,
                biometricOnly: false,
                sensitiveTransaction: false));
        if (authenticated) {
          if (userPrefersFastLogin) {
            appNavigator.currentState?.pushReplacementNamed("/obs-fast");
          } else {
            appNavigator.currentState?.pushReplacementNamed("/obs-classic");
          }
        }else{
          setState(() {
            showLoginButton = true;
          });
        }
      } on PlatformException catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }} else {
      if (userPrefersFastLogin) {
        appNavigator.currentState?.pushReplacementNamed("/obs-fast");
      } else {
        appNavigator.currentState?.pushReplacementNamed("/obs-classic");
      }
    }
  }





  @override
  Widget build(BuildContext context) {

    return SafeArea(
      top: false,
      child: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/images/logo.png"),
            const Text(
              "Yıldız OBS Mobil'e Hoş Geldin!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 40),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                showLoginButton||widget.justLoggedOut ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FilledButton.icon(onPressed:(){
                      setState(() {
                        showLoginButton = false;
                      });
                      _fetchEnabledAuth();
                    }, icon:const Icon(Icons.login),
                    label:const Text("Giriş yap")),
                    OutlinedButton.icon(style: OutlinedButton.styleFrom(side:  BorderSide(width: 1.6, color: Theme.of(context).colorScheme.primary)),onPressed: (){appNavigator.currentState?.pushNamed("/setup");}, icon: const Icon(Icons.settings), label: const Text("Ayarlar"))
                  ],
                ):  const Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Doğrulama yapılıyor..."),
                    SizedBox(width: 10,),
                    CircularProgressIndicator(),
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
