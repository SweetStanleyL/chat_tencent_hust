// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:ui';

import 'package:flutter/material.dart';

import 'demo_localization/demo_kit_client_localizations.dart';
import 'demo_localization/demo_kit_client_localizations_zh.dart';

// 获取本地化资源
class S {
  static const LocalizationsDelegate<DemoKitClientLocalizations> delegate =
      DemoKitClientLocalizations.delegate;

  static DemoKitClientLocalizations of([BuildContext? context]) {
    DemoKitClientLocalizations? localizations;
    if (context != null) {
      localizations = DemoKitClientLocalizations.of(context);
    }
    if (localizations == null) {
      var local = PlatformDispatcher.instance.locale;
      try {
        localizations = lookupDemoKitClientLocalizations(local);
      } catch (e) {
        localizations = DemoKitClientLocalizationsZh();
      }
    }
    return localizations;
  }
}
