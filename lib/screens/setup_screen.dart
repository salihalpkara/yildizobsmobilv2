// ignore_for_file: non_constant_identifier_names

import "package:flutter/foundation.dart";
import "package:flutter/gestures.dart";
import "package:flutter/material.dart";
import "package:local_auth/local_auth.dart";
import "package:yildiz_obs_mobile/main.dart";
import 'package:yildiz_obs_mobile/services/user_preferences.dart';

class SetupPage extends StatefulWidget {
  final bool loggedIn;
  const SetupPage({super.key, required this.loggedIn});

  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  final setupScreenPageController = PageController();
  final tcknController = TextEditingController();
  final eDevletPasswordController = TextEditingController();
  final eDevletFormKey = GlobalKey<FormState>();
  final OBSUsernameController = TextEditingController();
  final OBSPasswordController = TextEditingController();
  final OBSFormKey = GlobalKey<FormState>();
  LocalAuthentication auth = LocalAuthentication();
  FocusNode tcknFocusNode = FocusNode();
  FocusNode eDevletPasswordFocusNode = FocusNode();
  FocusNode OBSUsernameFocusNode = FocusNode();
  FocusNode OBSPasswordFocusNode = FocusNode();
  bool _obscureTCKN = false;
  bool _obscureEDevletPassword = true;
  bool _obscureOBSPassword = true;
  bool useLocalAuth = false;
  int currentStep = 0;
  bool skipSetup = false;
  bool localAuthSupportState = false;
  bool prefersFastLogin = true;

  Future<void> _fetchSkipSetup() async {
    skipSetup = await UserPreferences.getSkipSetup();
  }

  Future init() async {
    _fetchSkipSetup();
    final bool fastLoginPreference = await UserPreferences.getPrefersFastLogin();
    final bool useLocalAuthPreference = await UserPreferences.getEnableAuth();
    final String tckn = await UserPreferences.getTCKN();
    final String eDevletPassword = await UserPreferences.getEDevletPassword();
    final String OBSUsername = await UserPreferences.getOBSUsername();
    final String OBSPassword = await UserPreferences.getOBSPassword();
    setState(() {
      tcknController.text = tckn;
      eDevletPasswordController.text = eDevletPassword;
      OBSUsernameController.text = OBSUsername;
      OBSPasswordController.text = OBSPassword;
      useLocalAuth = useLocalAuthPreference;
      prefersFastLogin = fastLoginPreference;
    });
    if (kDebugMode) {
      print("initial fast login preference = $prefersFastLogin");
    }
  }

  void setLocalAuthSupportState() {
    // Cihaz desekleniyorsa
    auth.isDeviceSupported().then((bool isSupported) => setState(() {
          localAuthSupportState = isSupported;
        }));
    if (!localAuthSupportState) {
      useLocalAuth = false;
    }
  }

  @override
  void initState() {
    init();
    setLocalAuthSupportState();
    super.initState();
  }

  void onStepContinue() {
    if (currentStep != 2) {
      setState(() {
        currentStep++;
      });
      if (kDebugMode) {
        print(currentStep);
      }
    } else {}
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121e2d),
      appBar: skipSetup
          ? AppBar(
        backgroundColor: Color(0XFF121e2d),
              title: const Text("Ayarlar"),
        automaticallyImplyLeading: false,
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: (){TercihiKaydetveDevamEt();BilgileriKaydetveDevamEt();KurulumuTamamla();},),
            )
          : null,
      body: Center(
        child: Stepper(
            onStepTapped: (int newindex) {
              if (newindex < currentStep) {
                setState(() {
                  currentStep = newindex;
                });
              }
              // else if (skipSetup) {
              //   setState(() {
              //     currentStep = newindex;
              //   });
              // }
            },
            currentStep: currentStep,
            controlsBuilder: (context, controller) {
              if (currentStep == 0) {
                return Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    FilledButton(
                        onPressed: TercihiKaydetveDevamEt,
                        child: const Row(
                          children: [
                            Text("Kaydet ve Devam et"),
                            Icon(Icons.arrow_forward)
                          ],
                        )),
                  ],
                );
              } else if (currentStep == 1) {
                return Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(side: BorderSide(width: 2, color: Color(0xFFBAC3FF))),
                        onPressed: (){setState(() {
                            currentStep--;
                          });},
                        child: Text("Geri")),
                    FilledButton(
                        onPressed: BilgileriKaydetveDevamEt,
                        child: const Row(
                          children: [
                            Text("Kaydet ve Devam et"),
                            Icon(Icons.arrow_forward)
                          ],
                        )),
                  ],
                );
              } else {
                return Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    OutlinedButton(
                        style: OutlinedButton.styleFrom(side: BorderSide(width: 2, color: Color(0xFFBAC3FF))),
                        onPressed: (){setState(() {
                          currentStep--;
                        });},
                        child: Text("Geri")),
                    FilledButton(
                        onPressed: KurulumuTamamla,
                        child: const Row(
                          children: [
                            Text("Kurulumu Tamamla"),
                            Icon(Icons.check)
                          ],
                        )),
                  ],
                );
              }
            },
            steps: [
              Step(
                isActive: currentStep == 0,
                  title: const Text("Giriş Yöntemi Tercihi"),
                  content: Column(
                    children: [
                      ListTile(leading: const Icon(Icons.check_circle_rounded, color: Colors.green,), subtitle: RichText(text: TextSpan(style: const TextStyle(height: 1.2,letterSpacing: 0.2),children: [const TextSpan(text:'e-Devlet ile giriş yaparken iki aşamalı kimlik doğrulama kullanmıyorsan\n'),TextSpan(text: "e-Devlet bilgileriyle giriş", style: const TextStyle(color: Colors.lightBlue, decoration: TextDecoration.underline),recognizer: TapGestureRecognizer()..onTap = (){if (kDebugMode) {
                        print("a");
                      }setState(() {
                        prefersFastLogin = true;
                        UserPreferences.setPrefersFastLogin(true);
                      });}) ,const TextSpan(text:'\nseçeneği sana en uygun seçenektir.')])),),
                      Center(
                        child: AnimatedContainer(
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: prefersFastLogin?Colors.redAccent: Theme.of(context).colorScheme.primary, width: 2)),
                          margin: const EdgeInsets.all(20),
                          padding: const EdgeInsets.all(20),
                          duration: const Duration(milliseconds: 350),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text("e-Devlet bilgileriyle giriş", style: TextStyle(color: prefersFastLogin ? Colors.white: Colors.grey),),
                              const SizedBox(height: 20,),
                              RotatedBox(
                                quarterTurns: 3,
                                child: Switch(
                                  activeColor: Colors.redAccent,
                                    inactiveThumbImage:const AssetImage("assets/images/logo_rotated.png"),
                                    activeThumbImage:const AssetImage("assets/images/edevletk_logo_rotated.png"),
                                    inactiveThumbColor: Theme.of(context).colorScheme.inversePrimary,
                                    inactiveTrackColor: Theme.of(context).colorScheme.primary,
                                    value: prefersFastLogin,
                                    onChanged: (bool newPreference) {
                                      setState((){
                                        prefersFastLogin = newPreference;
                                      });
                                      UserPreferences.setPrefersFastLogin(
                                          newPreference);
                                      if (kDebugMode) {
                                        print(prefersFastLogin);
                                      }
                                    }),
                              ),
                              const SizedBox(height: 20,),
                              Text("OBS bilgileriyle giriş", style: TextStyle(color: prefersFastLogin ? Colors.grey: Colors.white),),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )),
              Step(
                isActive: currentStep == 1,
                title: Text(prefersFastLogin ? "e-Devlet Giriş Bilgilerin": "OBS Giriş Bilgilerin"),
                content: prefersFastLogin ? Form(
                  key: eDevletFormKey,
                  child: Column(
                    children: [
                      //const SizedBox(
                      //  height: 20,
                      //),
                      //SizedBox(
                      //    width: MediaQuery.of(context).size.width * 2 / 7,
                      //    child: Image.asset("assets/images/edevletk_logo.png")),
                      //const SizedBox(
                      //  height: 20,
                      //),
                      ListTile(
                          dense: true,
                          leading: SizedBox(
                              width: 60,
                              child: Image.asset(
                                  "assets/images/edevletk_logo.png")),
                          title: const Text(
                              "Bu bilgiler OBS'ye e-Devlet ile giriş metodunu kullanırken otomatik doldurma bilgisi olarak kullanılacak.")),
                      const SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: TextFormField(
                          controller: tcknController,
                          focusNode: tcknFocusNode,
                          obscureText: _obscureTCKN,
                          onTapOutside: (_) {
                            FocusScope.of(context).unfocus();
                          },
                          onFieldSubmitted: (tckn) {
                            setState(() {
                              UserPreferences.setTCKN(tckn);
                            });
                            FocusScope.of(context)
                                .requestFocus(eDevletPasswordFocusNode);
                          },
                          validator: (tckn) {
                            if (tckn?.length != 11 || tckn!.isEmpty) {
                              return "Lütfen geçerli bir T.C. Kimlik Numarası giriniz.";
                            }
                            return null;
                          },
                          scrollPadding: EdgeInsets.only(
                              bottom:
                                  MediaQuery.of(context).viewInsets.bottom),
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                              suffixIcon: IconButton(
                                icon: AnimatedCrossFade(
                                  firstChild:
                                      const Icon(Icons.visibility_off),
                                  secondChild: const Icon(Icons.visibility),
                                  crossFadeState: _obscureTCKN
                                      ? CrossFadeState.showFirst
                                      : CrossFadeState.showSecond,
                                  duration: const Duration(milliseconds: 250),
                                ),
                                color: Colors.grey,
                                onPressed: () {
                                  setState(() {
                                    _obscureTCKN = !_obscureTCKN;
                                  });
                                },
                              ),
                              prefixIcon: const Icon(Icons.badge),
                              labelText: "T.C. Kimlik Numarası",
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15))),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: TextFormField(
                          focusNode: eDevletPasswordFocusNode,
                          onChanged: (pwd) {
                            UserPreferences.setEDevletPassword(pwd);
                          },
                          onFieldSubmitted: (pwd) {
                            UserPreferences.setEDevletPassword(pwd);
                          },
                          validator: (pwd) {
                            if (pwd!.isEmpty) {
                              return "Bu alan boş bırakılamaz";
                            }
                            return null;
                          },
                          obscureText: _obscureEDevletPassword,
                          scrollPadding: EdgeInsets.only(
                              bottom:
                                  MediaQuery.of(context).viewInsets.bottom),
                          controller: eDevletPasswordController,
                          keyboardType: TextInputType.visiblePassword,
                          decoration: InputDecoration(
                              suffixIcon: IconButton(
                                icon: AnimatedCrossFade(
                                  firstChild:
                                      const Icon(Icons.visibility_off),
                                  secondChild: const Icon(Icons.visibility),
                                  crossFadeState: _obscureEDevletPassword
                                      ? CrossFadeState.showFirst
                                      : CrossFadeState.showSecond,
                                  duration: const Duration(milliseconds: 250),
                                ),
                                color: Colors.grey,
                                onPressed: () {
                                  setState(() {
                                    _obscureEDevletPassword =
                                        !_obscureEDevletPassword;
                                  });
                                },
                              ),
                              prefixIcon: const Icon(Icons.password),
                              labelText: "e-Devlet Şifresi",
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15))),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const ListTile(
                          dense: true,
                          leading: Icon(
                            Icons.verified_user,
                            color: Colors.green,
                          ),
                          title: Text(
                              "Girdiğin bütün bilgiler cihazının yerel depolamasında şifrelenmiş bir şekilde saklanır, hiçbir zaman üçüncü bir taraf ile paylaşılmaz.")),
                    ],
                  ),
                ) : Form(
                  key: OBSFormKey,
                  child: Column(
                    children: [
                      //const SizedBox(
                      //  height: 20,
                      //),
                      //SizedBox(
                      //    width: MediaQuery.of(context).size.width * 2 / 7,
                      //    child: Image.asset("assets/images/edevletk_logo.png")),
                      //const SizedBox(
                      //  height: 20,
                      //),
                      ListTile(
                          dense: true,
                          leading: SizedBox(
                              width: 60,
                              child: Image.asset(
                                  "assets/images/logo.png")),
                          title: const Text(
                              "Bu bilgiler OBS'ye öğrenci bilgileri ile giriş metodunu kullanırken otomatik doldurma bilgisi olarak kullanılacak.")),
                      const SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: TextFormField(
                          controller: OBSUsernameController,
                          focusNode: OBSUsernameFocusNode,
                          onTapOutside: (_) {
                            FocusScope.of(context).unfocus();
                          },
                          onFieldSubmitted: (OBSUsername) {
                            setState(() {
                              UserPreferences.setOBSUsername(OBSUsername);
                            });
                            FocusScope.of(context)
                                .requestFocus(OBSPasswordFocusNode);
                          },
                          scrollPadding: EdgeInsets.only(
                              bottom:
                              MediaQuery.of(context).viewInsets.bottom),
                          keyboardType: TextInputType.text,
                          validator: (username) {
                            if (username!.isEmpty) {
                              return "Bu alan boş bırakılamaz";
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.person_rounded),
                              labelText: "Kullanıcı Adı",
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15))),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: TextFormField(
                          focusNode: OBSPasswordFocusNode,
                          onChanged: (pwd) {
                            UserPreferences.setOBSPassword(pwd);
                          },
                          onFieldSubmitted: (pwd) {
                            UserPreferences.setOBSPassword(pwd);
                          },
                          validator: (pwd) {
                            if (pwd!.isEmpty) {
                              return "Bu alan boş bırakılamaz";
                            }
                            return null;
                          },
                          obscureText: _obscureOBSPassword,
                          scrollPadding: EdgeInsets.only(
                              bottom:
                              MediaQuery.of(context).viewInsets.bottom),
                          controller: OBSPasswordController,
                          keyboardType: TextInputType.visiblePassword,
                          decoration: InputDecoration(
                              suffixIcon: IconButton(
                                icon: AnimatedCrossFade(
                                  firstChild:
                                  const Icon(Icons.visibility_off),
                                  secondChild: const Icon(Icons.visibility),
                                  crossFadeState: _obscureOBSPassword
                                      ? CrossFadeState.showFirst
                                      : CrossFadeState.showSecond,
                                  duration: const Duration(milliseconds: 250),
                                ),
                                color: Colors.grey,
                                onPressed: () {
                                  setState(() {
                                    _obscureOBSPassword =
                                    !_obscureOBSPassword;
                                  });
                                },
                              ),
                              prefixIcon: const Icon(Icons.password),
                              labelText: "Şifre",
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15))),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const ListTile(
                          dense: true,
                          leading: Icon(
                            Icons.verified_user,
                            color: Colors.green,
                          ),
                          title: Text(
                              "Girdiğin bütün bilgiler cihazının yerel depolamasında şifrelenmiş bir şekilde saklanır, hiçbir zaman üçüncü bir taraf ile paylaşılmaz.")),
                    ],
                  ),
                ),
              ),
              Step(
                isActive: currentStep == 2,
                title: const Text("Gizlilik ve Güvenlik"),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Kimlik Doğrulama',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    ListTile(
                      dense: true,
                      title: localAuthSupportState
                          ? const Text(
                              'Yerel Kimlik Doğrulamasını Etkinleştir',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )
                          : const Text(
                              'Yerel Kimlik Doğrulamasını Etkinleştir',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey),
                            ),
                      subtitle: localAuthSupportState
                          ? const Text(
                              "OBS'ye giriş yaparken yerel kimlik doğrulamasını (parmak izi, yüz tanıma, pin vs.) kullan.")
                          : const Column(
                              children: [
                                Text(
                                  "OBS'ye giriş yaparken yerel kimlik doğrulamasını (parmak izi, yüz tanıma, pin vs.) kullan.",
                                  style: TextStyle(color: Colors.grey),
                                ),
                                Text(
                                  "Bu özelliği etkinleştirmek için cihazının en azından bir PIN ile korunuyor olması gerekir.",
                                  style: TextStyle(
                                      color: Colors.red, fontSize: 10),
                                )
                              ],
                            ),
                      trailing: Switch(
                        value: localAuthSupportState ? useLocalAuth : false,
                        onChanged: localAuthSupportState
                            ? (value) {
                                setState(() {
                                  useLocalAuth = value;
                                });
                                UserPreferences.setEnableAuth(useLocalAuth);
                              }
                            : null,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    )
                  ],
                ),
              )
            ]),
      ),
    );
  }

  void TercihiKaydetveDevamEt() async {
    UserPreferences.setPrefersFastLogin(prefersFastLogin);
    String doThey = "eDevlet'le giriş: ${await UserPreferences.getPrefersFastLogin()}";

    if (kDebugMode) {
      print(doThey);
    }

    onStepContinue();
  }

  void BilgileriKaydetveDevamEt() async {
    if(prefersFastLogin){
      if (!eDevletFormKey.currentState!.validate()) {
        return;
      }
      UserPreferences.setTCKN(tcknController.text);
      UserPreferences.setEDevletPassword(eDevletPasswordController.text);

      String tckn = "Kaydedilen veri: ${await UserPreferences.getTCKN()}";
      String pwd =
          "Kaydedilen veri: ${await UserPreferences.getEDevletPassword()}";

      if (kDebugMode) {
        print("$tckn\n$pwd");
      }
    }else{
      if (!OBSFormKey.currentState!.validate()) {
        return;
      }
      UserPreferences.setOBSUsername(OBSUsernameController.text);
      UserPreferences.setOBSPassword(OBSPasswordController.text);

      String OBSUsername = "Kaydedilen veri: ${await UserPreferences.getOBSUsername()}";
      String OBSPassword =
          "Kaydedilen veri: ${await UserPreferences.getOBSPassword()}";

      if (kDebugMode) {
        print("$OBSUsername\n$OBSPassword");
      }
    }
    onStepContinue();
  }

  void KurulumuTamamla() async {
    UserPreferences.setPrefersFastLogin(prefersFastLogin);
    UserPreferences.setEnableAuth(useLocalAuth);
    UserPreferences.setSkipSetup(true);

    String authCondition =
        "Yerel doğrulama kullanılma durumu: ${await UserPreferences.getEnableAuth()}";
    String skipSetupCondition =
        "Kurulum ekranı atlanma durumu: ${await UserPreferences.getSkipSetup()}";

    if (widget.loggedIn) {
      appNavigator.currentState?.pop();
    } else {
      appNavigator.currentState?.pushReplacementNamed("/login-justLoggedOut");
    }
    if (kDebugMode) {
      print("$authCondition\n$skipSetupCondition");
    }
  }
}
