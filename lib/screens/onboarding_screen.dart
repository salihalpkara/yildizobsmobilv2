import 'package:animated_background/animated_background.dart';
import "package:flutter/material.dart";
import 'package:yildiz_obs_mobile/main.dart';



class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> with TickerProviderStateMixin{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBackground(
        vsync: this,
        behaviour: SpaceBehaviour(),
        child: Column(
          mainAxisSize: MainAxisSize.max,
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
            const Text("Birkaç ufak ayardan sonra hazır olacaksın."),
            const SizedBox(
              height: 20,
            ),
            OutlinedButton(
              onPressed: () {
                appNavigator.currentState?.pushNamed("/setup");
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Hadi başlayalım!"),
                  Icon(Icons.arrow_forward)
                ],
              ),)
          ],
        ),
      ),
    );
  }


}