// ignore_for_file: non_constant_identifier_names

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:yildiz_obs_mobile/services/user_preferences.dart';
import "package:yildiz_obs_mobile/main.dart";
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class FastLoginOBSPage extends StatefulWidget {
  const FastLoginOBSPage({super.key});
  @override
  State<FastLoginOBSPage> createState() => _FastLoginOBSPageState();
}

class _FastLoginOBSPageState extends State<FastLoginOBSPage> {
  late InAppWebViewController webViewController;
  late String usertckn = "";
  late String usereDevletPassword = "";
  late String userOBSUsername = "";
  late String userOBSPassword = "";
  ConnectivityResult? connection;
  DateTime timeBackPressed = DateTime.now();
  String OBSLoginLink = "https://obs.yildiz.edu.tr/oibs/std/login.aspx";
  bool webViewVisibility = false;
  bool isLoggedIn = false;
  bool showGoBack = false;
  int loginSteps = 0;
  int navBarSelectedIndex = 2;
  bool userPrefersFastLogin = true;
  PullToRefreshController? refreshController;

  Future<void> init() async {
    final String tckn = await UserPreferences.getTCKN();
    final String eDevletPassword = await UserPreferences.getEDevletPassword();
    final connectivityResult = await (Connectivity().checkConnectivity());
    final prefersFastLogin = await UserPreferences.getPrefersFastLogin();

    setState(() {
      connection = connectivityResult;
      usertckn = tckn;
      usereDevletPassword = eDevletPassword;
      userPrefersFastLogin = prefersFastLogin;
    });
  }

  @override
  void initState() {
    Future.delayed(const Duration(seconds: 10), () {
      setState(() {
        showGoBack = true;
      });
    });
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

  void OBSLogout() {
    webViewController.evaluateJavascript(
        source: "__doPostBack('btnLogout','');");
    appNavigator.currentState?.pushReplacementNamed("/login-justLoggedOut");
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          if (await webViewController.canGoBack()) {
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
        },
        child: Scaffold(
          appBar: connection == ConnectivityResult.none
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
          body: Center(
              child: SafeArea(
            bottom: false,
            child: Stack(
              children: [
                Builder(builder: (BuildContext context) {
                  if (connection == ConnectivityResult.none) {
                    return Center(
                        child: Column(
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
                                  ?.pushReplacementNamed("/obs-fast");
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text("Tekrar dene"))
                      ],
                    ));
                  } else {
                    return Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            showGoBack
                                ? const Text(
                                    "Tahmin edilenden uzun sürmeye başladı...")
                                : const Text(
                                    "E-Devlet bilgileri ile giriş yapılıyor..."),
                            const SizedBox(
                              width: 10,
                            ),
                            const CircularProgressIndicator(),
                          ],
                        ),
                        Visibility(
                          visible: showGoBack,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                FilledButton.icon(
                                  onPressed: () {
                                    appNavigator.currentState
                                        ?.popAndPushNamed("/obs-fast");
                                  },
                                  label: const Text("Tekrar dene"),
                                  icon: const Icon(Icons.refresh),
                                ),
                                OutlinedButton.icon(
                                  onPressed: () {
                                    appNavigator.currentState?.popAndPushNamed(
                                        "/login-justLoggedOut");
                                  },
                                  label: const Text("Geri dön"),
                                  icon: const Icon(Icons.arrow_back_rounded),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    );
                  }
                }),
                Offstage(
                  offstage: !webViewVisibility,
                  child: SizedBox(
                      height: double.infinity,
                      width: MediaQuery.of(context).size.width,
                      child: InAppWebView(
                        pullToRefreshController: refreshController,
                        initialUrlRequest:
                            URLRequest(url: WebUri(OBSLoginLink)),
                        onWebViewCreated: (InAppWebViewController controller) {
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
                          if (consoleMessage
                              .contains("User just logged out.")) {
                            // OBSLogout();
                          }
                          if (consoleMessage.contains("Oturum Sonlandı")) {
                            appNavigator.currentState
                                ?.pushReplacementNamed("/login-justLoggedOut");
                            setState(() {
                              isLoggedIn = false;
                              webViewVisibility = false;
                            });
                          }
                        },
                        onLoadStop: (controller, url) {
                          refreshController!.endRefreshing();
                          String currentUrl = url.toString();
                          if (kDebugMode) {
                            print(currentUrl);
                          }

                          webViewController.evaluateJavascript(
                              source: "console.log(document.body.innerText);");
                          if (mounted) {
                            if (kDebugMode) {
                              print(url);
                            }
                            if (loginSteps == 0 && currentUrl == OBSLoginLink) {
                              webViewController.evaluateJavascript(
                                  source:
                                      "__doPostBack('btnEdevletLogin','');");
                              if (kDebugMode) {
                                print("LOGINSTEPS: $loginSteps");
                              }
                              setState(() {
                                loginSteps++;
                              });
                            } else if (loginSteps <= 2 &&
                                currentUrl
                                    .contains("https://giris.turkiye.gov.tr")) {
                              webViewController.evaluateJavascript(
                                  source:
                                      "document.getElementById('tridField').value = '$usertckn';");
                              webViewController.evaluateJavascript(
                                  source:
                                      "document.getElementById('egpField').value = '$usereDevletPassword';");
                              webViewController.evaluateJavascript(
                                  source:
                                      "document.getElementsByClassName('btn btn-send')[0].click();");
                              webViewController.evaluateJavascript(
                                  source:
                                      "if(document.getElementsByClassName('alert error').length > 0){console.log('cannot be parsed, or is out of range')};");
                              if (kDebugMode) {
                                print("LOGINSTEPS: $loginSteps");
                              }
                              setState(() {
                                loginSteps++;
                              });
                            } else {
                              if (currentUrl
                                  .contains("https://obs.yildiz.edu.tr/")) {
                                setState(() {
                                  webViewVisibility = true;
                                  showGoBack = false;
                                  isLoggedIn = true;
                                });
                                webViewController.evaluateJavascript(
                                    source:
                                        "setTimeout(function(){__doPostBack('btnExtend','');}, 1200000);");
                              } else {
                                webViewController.evaluateJavascript(
                                    source:
                                        "document.getElementById('tridField').value = '$usertckn';");
                                webViewController.evaluateJavascript(
                                    source:
                                        "document.getElementById('egpField').value = '$usereDevletPassword';");
                                setState(() {
                                  webViewVisibility = true;
                                });
                              }
                              if (currentUrl == OBSLoginLink) {
                                appNavigator.currentState?.pushReplacementNamed(
                                    "/login-justLoggedOut");
                              }
                            }
                          } else {
                            return;
                          }
                        },
                        onLoadStart: (controller, url) {},
                      )),
                ),
              ],
            ),
          )),
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
