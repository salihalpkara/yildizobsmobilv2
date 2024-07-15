// ignore_for_file: non_constant_identifier_names

import 'dart:async';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:yildiz_obs_mobile/services/user_preferences.dart';
import "package:yildiz_obs_mobile/main.dart";
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class ClassicLoginOBSPage extends StatefulWidget {
  const ClassicLoginOBSPage({super.key});
  @override
  State<ClassicLoginOBSPage> createState() => _ClassicLoginOBSPageState();
}

class _ClassicLoginOBSPageState extends State<ClassicLoginOBSPage>
    with TickerProviderStateMixin {
  late InAppWebViewController webViewController;
  InAppWebViewSettings settings = InAppWebViewSettings();
  final secCodeController = TextEditingController();
  late String userOBSUsername = "";
  late String userOBSPassword = "";
  ConnectivityResult? connection;
  DateTime timeBackPressed = DateTime.now();
  String OBSLoginLink = "https://obs.yildiz.edu.tr/oibs/std/login.aspx";
  String scannedText = "";
  String secCode = "";
  int secCodeAnswer = 0;
  bool webViewVisibility = false;
  bool isLoggedIn = false;
  bool showGoBack = false;
  int loginSteps = 0;
  int navBarSelectedIndex = 2;
  double obsSecCodeHeight = 40;
  double obsSecCodeWidth = 177;
  double loginProgress = 0.0;
  bool userPrefersFastLogin = false;
  late Timer timer;
  late Uint8List screenshotBytes;
  PullToRefreshController? refreshController;

  Future<void> init() async {
    final String OBSUsername = await UserPreferences.getOBSUsername();
    final String OBSPassword = await UserPreferences.getOBSPassword();
    final connectivityResult = await (Connectivity().checkConnectivity());
    final prefersFastLogin = await UserPreferences.getPrefersFastLogin();

    setState(() {
      connection = connectivityResult;
      userOBSUsername = OBSUsername;
      userOBSPassword = OBSPassword;
      userPrefersFastLogin = prefersFastLogin;
    });
  }

  @override
  void initState() {
    init();
    super.initState();
    refreshController = PullToRefreshController(
        onRefresh: () {
          webViewController.evaluateJavascript(
              source: "window.location.reload();");
        },
        settings: PullToRefreshSettings(
          color: Colors.blue,
          backgroundColor: Colors.white,
        ));
  }

  Future<void> increaseContrastAndSave(String imagePath) async {
    // Read image file
    File imageFile = File(imagePath);
    if (!imageFile.existsSync()) {
      if (kDebugMode) {
        print('Image file not found');
      }
      return;
    }

    // Read image bytes
    Uint8List imageBytes = await imageFile.readAsBytes();
    // Decode image
    img.Image? image = img.decodeImage(imageBytes);
    if (image == null) {
      if (kDebugMode) {
        print('Error decoding image');
      }
      return;
    }

    // Increase contrast
    image = img.gaussianBlur(image, radius: 3);
    image = img.contrast(image,
        contrast: 250); // Example: Increasing contrast by 50%
    image = img.gaussianBlur(image, radius: 3);
    image = img.contrast(image, contrast: 800);

    // Save image
    File(imagePath).writeAsBytesSync(img.encodePng(image));

    if (kDebugMode) {
      print('Contrast increased and image saved successfully');
    }
  }

  void getRecognizedText(File image) async {
    setState(() {
      loginProgress += 0.1;
    });
    final dir = (await getTemporaryDirectory()).path;
    increaseContrastAndSave("$dir/a.png");
    if (kDebugMode) {
      print("DIR: $dir");
    }
    final inputImage = InputImage.fromFilePath(image.path);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    RecognizedText recognizedText =
        await textRecognizer.processImage(inputImage);
    await textRecognizer.close();
    scannedText = "";
    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        scannedText = "$scannedText${line.text}\n";
      }
    }

    scannedText.split("").forEach((char) {
      if (char.isNum || char == "A" || char == "T") {
        if (char == "A") {
          secCode = "${secCode}4";
        } else if (char == "T") {
          secCode = "${secCode}1";
        } else {
          secCode = secCode + char;
        }
      }
    });

    Future.delayed(const Duration(seconds: 5), () async {
      var currentUrl = await webViewController.getUrl();
      if (currentUrl.toString() == OBSLoginLink) {
        webViewController.evaluateJavascript(
            source: "window.location.reload();");
      }
    });

    if (secCode.length == 4) {
      secCode = secCode.substring(0, 2) + secCode.substring(3);
      if (kDebugMode) {
        print("attempting login");
      }
      secCodeAnswer =
          int.parse(secCode.substring(0, 2)) + int.parse(secCode.substring(2));
      webViewController.evaluateJavascript(
          source:
              "document.getElementById('txtSecCode').value = '$secCodeAnswer';");
      webViewController.evaluateJavascript(
          source: "document.getElementById('btnLogin').click();");
    } else if (secCode.length == 3) {
      if (kDebugMode) {
        print("attempting login");
      }
      secCodeAnswer =
          int.parse(secCode.substring(0, 2)) + int.parse(secCode.substring(2));
      webViewController.evaluateJavascript(
          source:
              "document.getElementById('txtSecCode').value = '$secCodeAnswer';");
      webViewController.evaluateJavascript(
          source: "document.getElementById('btnLogin').click();");
    } else {
      webViewController.evaluateJavascript(
          source: 'document.querySelector("#btnRefresh").click();');

      if (kDebugMode) {
        print("Retrying: $secCode");
      }
    }

    setState(() {});
    if (kDebugMode) {
      print(dir);
    }
    if (kDebugMode) {
      print(
          "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\naaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\n$scannedText");
    }
    if (kDebugMode) {
      print(secCodeAnswer);
    }
    secCodeAnswer = 0;
    secCode = "";
  }

  void OBSLogout() {
      webViewController.evaluateJavascript(
          source: "__doPostBack('btnLogout','');");
      appNavigator.currentState?.popAndPushNamed("/login-justLoggedOut");
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          if (!isLoggedIn) {
            appNavigator.currentState?.popAndPushNamed("/login-justLoggedOut");
            return false;
          } else {
            await webViewController.canGoBack().then((canGoBack) {
              if (canGoBack) {
                webViewController.goBack();
                return false;
              } else {
                final difference = DateTime.now().difference(timeBackPressed);
                final isExitWarning = difference >= const Duration(seconds: 3);
                timeBackPressed = DateTime.now();

                if (isExitWarning) {
                  Fluttertoast.showToast(
                      msg: "Çıkış yapmak için tekrar basın",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 3,
                      backgroundColor: Colors.grey[700]?.withAlpha(220),
                      textColor: Colors.white,
                      fontSize: 15.0);
                  return false;
                } else {
                  OBSLogout();
                  return false;
                }
              }
            });
            return false;
          }
          // if (await controller.canGoBack()) {
          //   controller.goBack();
          //   return false;
          // } else {
          //   final difference = DateTime.now().difference(timeBackPressed);
          //   final isExitWarning = difference >= const Duration(seconds: 3);
          //   timeBackPressed = DateTime.now();
          //
          //   if (isExitWarning) {
          //     Fluttertoast.showToast(
          //         msg: "Çıkış yapmak için tekrar basın",
          //         toastLength: Toast.LENGTH_SHORT,
          //         gravity: ToastGravity.BOTTOM,
          //         timeInSecForIosWeb: 3,
          //         backgroundColor: Colors.grey[700]?.withAlpha(220),
          //         textColor: Colors.white,
          //         fontSize: 15.0);
          //     return false;
          //   } else {
          //     OBSLogout();
          //     return false;
          //   }
          //
          // }
        },
        child: Scaffold(
          appBar: connection == ConnectivityResult.none || !isLoggedIn
              ? AppBar(
                  leading: IconButton(
                    onPressed: () {
                      appNavigator.currentState
                          ?.pushReplacementNamed("/login-justLoggedOut");
                    },
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                )
              : null,
          extendBody: false,
          bottomNavigationBar: Visibility(
            visible: isLoggedIn,
            child: NavigationBarTheme(
              data: NavigationBarThemeData(
                  backgroundColor: Color(0xFF121e2d),
                  labelTextStyle: WidgetStateProperty.all<TextStyle>(
                      Theme.of(context).textTheme.labelMedium!)),
              child: NavigationBar(
                elevation: 0,
                height: 80,
                onDestinationSelected: (int newIndex) {
                  setState(() {
                    navBarSelectedIndex = newIndex;
                  });
                  switch (newIndex) {
                    case 0:
                      webViewController.evaluateJavascript(
                          source:
                              "menu_close(this,'start.aspx?gkm=00233219833291388643775636606311143523032194333453444836720385043439638936355703756034388388243330337427341963524535260');");

                      break;
                    case 1:
                      webViewController.evaluateJavascript(
                          source:
                              "menu_close(this,'start.aspx?gkm=00233219833291388643775636606311143523032194333453444836720385043439638936355703756034388388243330337427341963524035280');");
                      break;
                    case 2:
                      webViewController.evaluateJavascript(
                          source: "__doPostBack('','');");
                      break;
                    case 3:
                      webViewController.evaluateJavascript(
                          source:
                              "menu_close(this,'start.aspx?gkm=00233219833291388643775636606311143523032194333453444836720385043439638936355703756034388388243330337427341963524035275');");
                      break;
                    case 4:
                      Navigator.pushNamed(context, "/setup-loggedIn");
                      break;
                  }
                },
                selectedIndex: navBarSelectedIndex,
                labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.mail),
                    label: "  Gelen\nMesajlar",
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.calendar_month),
                    label: "    Ders\nProgramı",
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.home_rounded),
                    label: "Ana Sayfa\n",
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.note_alt_outlined),
                    label: "  Not\nListesi",
                  ),
                  NavigationDestination(
                      icon: Icon(Icons.settings), label: "Ayarlar\n"),
                ],
              ),
            ),
          ),
          body: SafeArea(
            bottom: false,
            child: Center(
              child: connection == ConnectivityResult.none
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.wifi_off_rounded,
                          size: 60,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text(
                          "Ağ bağlantısı yok",
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        FilledButton.icon(
                            onPressed: () {
                              appNavigator.currentState
                                  ?.pushReplacementNamed("/obs-classic");
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text("Tekrar dene"))
                      ],
                    )
                  : Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          height:
                              isLoggedIn ? double.infinity : obsSecCodeHeight,
                          width: isLoggedIn
                              ? MediaQuery.of(context).size.width
                              : obsSecCodeWidth * 2 / 3,
                          child: InAppWebView(
                            pullToRefreshController: refreshController,
                            initialUrlRequest:
                                URLRequest(url: WebUri(OBSLoginLink)),
                            initialSettings: settings,
                            onWebViewCreated:
                                (InAppWebViewController controller) {
                              webViewController = controller;
                            },
                            onConsoleMessage: (controller, message) {
                              String consoleMessage = message.message;
                              if (kDebugMode) {
                                print("console: $consoleMessage");
                              }
                              if (consoleMessage.contains(
                                  "cannot be parsed, or is out of range")) {
                                setState(() {
                                  webViewVisibility = true;
                                });
                              }
                              if (consoleMessage.contains(
                                  "Kullanıcı adı veya şifresi geçersiz.")) {
                                appNavigator.currentState
                                    ?.popAndPushNamed("/login-justLoggedOut");
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                        backgroundColor: Color(0xFF93000A),
                                        content: Text(
                                          "Kullanıcı adı veya şifresi geçersiz.",
                                          style: TextStyle(color: Colors.white),
                                        )));
                              }
                              if (consoleMessage
                                  .contains("captchaImg height:")) {
                                setState(() {
                                  obsSecCodeHeight = double.parse(
                                      consoleMessage.split(":")[1]);
                                });
                              }
                              if (consoleMessage
                                  .contains("captchaImg width:")) {
                                setState(() {
                                  obsSecCodeWidth = double.parse(
                                      consoleMessage.split(":")[1]);
                                });
                              }
                              if (consoleMessage
                                  .contains("User just logged out.")) {
                                // OBSLogout();
                              }
                              if (consoleMessage.contains("Oturum Sonlandı")) {
                                setState(() {
                                  isLoggedIn = false;
                                  webViewVisibility = false;
                                });
                              }
                            },
                            onLoadStop: (controller, url) async {
                              refreshController!.endRefreshing();
                              webViewController.evaluateJavascript(
                                  source:
                                      "console.log(document.body.innerText);");
                              String currentUrl = url.toString();
                              if (currentUrl == OBSLoginLink) {
                                setState(() {
                                  isLoggedIn = false;
                                });
                                String sonuc = await controller.evaluateJavascript(
                                        source:
                                            "document.getElementById('lblSonuclar').innerHTML;")
                                    as String;
                                if (sonuc ==
                                    'UYARI!! Aynı tarayıcıdan birden fazla giriş yapılamaz. Lütfen tüm açık tarayıcıları kapatın ve tarayıcınızı yeniden başlatın.') {
                                  webViewController.evaluateJavascript(
                                      source:
                                          'document.querySelector("#btnRefresh").click();');
                                } else {
                                  if (kDebugMode) {
                                    print(sonuc);
                                  }
                                }

                                webViewController.evaluateJavascript(
                                    source:
                                        "var imgCaptchaImg = document.getElementById('imgCaptchaImg'); document.body.appendChild(imgCaptchaImg); imgCaptchaImg.style.width = 'auto';imgCaptchaImg.style.height = 'auto';document.getElementById('form1').style.display = 'none';document.getElementById('imgCaptchaImg').onclick = '';");
                                webViewController.evaluateJavascript(
                                    source:
                                        "document.getElementById('txtParamT01').value = '$userOBSUsername';");
                                webViewController.evaluateJavascript(
                                    source:
                                        "document.getElementById('txtParamT02').value = '$userOBSPassword';");
                                webViewController.evaluateJavascript(
                                    source:
                                        "console.log('capthaImg height: ' + document.getElementById('imgCaptchaImg').getBoundingClientRect().height);");
                                webViewController.evaluateJavascript(
                                    source:
                                        "console.log('capthaImg width: ' + document.getElementById('imgCaptchaImg').getBoundingClientRect().width);");

                                Future.delayed(
                                    const Duration(milliseconds: 500),
                                    () async {
                                  webViewController.scrollTo(x: 0, y: 0);
                                  screenshotBytes = (await webViewController
                                      .takeScreenshot())!;
                                  final dir =
                                      (await getTemporaryDirectory()).path;
                                  final imageFile = File('$dir/a.png')
                                    ..writeAsBytesSync(screenshotBytes);
                                  getRecognizedText(imageFile);
                                });
                              } else {
                                webViewController.zoomBy(zoomFactor: 0.05);
                                webViewController.evaluateJavascript(
                                    source:
                                        '''document.querySelector('#btnLogout').href = "javascript:__doPostBack('btnLogout','');console.log('User just logged out.');"''');

                                setState(() {
                                  isLoggedIn = true;
                                  loginSteps = 1;
                                });
                              }
                            },
                          ),
                        ),
                        Offstage(
                            offstage: isLoggedIn,
                            child: Container(
                              height: obsSecCodeHeight,
                              width: MediaQuery.of(context).size.width,
                              color: Theme.of(context).colorScheme.background,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                      "OBS bilgileri ile giriş yapılıyor..."),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  SizedBox(
                                      width: 100,
                                      height: 10,
                                      child: LinearProgressIndicator(
                                        value: 0.5 + loginProgress,
                                        borderRadius: BorderRadius.circular(20),
                                      ))
                                ],
                              ),
                            )),
                      ],
                    ),
            ),
          ),
          floatingActionButton: isLoggedIn
              ? FloatingActionButton(
                  backgroundColor: Colors.red,
                  onPressed: () {
                    OBSLogout();
                  },
                  child: const Icon(Icons.power_settings_new),
                )
              : FloatingActionButton(
                  onPressed: () {
                    appNavigator.currentState?.pushNamed("/setup");
                  },
                  child: const Icon(Icons.settings),
                ),
        ));
  }
}
