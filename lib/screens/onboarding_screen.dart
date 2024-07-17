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
      backgroundColor: Color(0XFF121e2d),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/images/logo.png", height: MediaQuery.of(context).size.height/3,),
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
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white
              ),
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