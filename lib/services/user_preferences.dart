// ignore_for_file: constant_identifier_names

import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  static const _tcknKey = "tckn";
  static const _OBSUsernameKey = "OBSUsername";
  static const _OBSPasswordKey = "OBSPassword";
  static const _eDevletPasswordKey = "eDevletPassword";
  static const _enableAuthKey = "enableAuth";
  static const _skipSetupKey = "skipSetup";
  static const _prefersFastLoginKey = "prefersFastLogin";

  static Future<void> setTCKN(String tckn) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_tcknKey, tckn);
  }

  static Future<String> getTCKN() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_tcknKey) ?? "";
  }

  static Future<void> setOBSUsername(String OBSUsername) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_OBSUsernameKey, OBSUsername);
  }

  static Future<String> getOBSUsername() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_OBSUsernameKey) ?? "";
  }

  static Future<void> setOBSPassword(String OBSPassword) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_OBSPasswordKey, OBSPassword);
  }

  static Future<String> getOBSPassword() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_OBSPasswordKey) ?? "";
  }

  static Future<void> setEnableAuth(bool enableAuth) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_enableAuthKey, enableAuth);
  }

  static Future<bool> getEnableAuth() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(_enableAuthKey) ?? false;
  }

  static Future<void> setPrefersFastLogin(bool fastLoginPreference) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_prefersFastLoginKey, fastLoginPreference);
  }

  static Future<bool> getPrefersFastLogin() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(_prefersFastLoginKey) ?? true;
  }

  static Future<void> setSkipSetup(bool skipSetup) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_skipSetupKey, skipSetup);
  }

  static Future<bool> getSkipSetup() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(_skipSetupKey) ?? false;
  }

  static Future<void> setEDevletPassword(String eDevletPassword) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_eDevletPasswordKey, eDevletPassword);
  }

  static Future<String> getEDevletPassword() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_eDevletPasswordKey) ?? "";
  }
}