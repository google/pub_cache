// Copyright (c) 2014, Google Inc. Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

import 'package:pub_cache/pub_cache.dart';

void main(List<String> args) {
  PubCache cache = new PubCache();

  var apps = cache.getGlobalApplications();
  print('${apps.length} activated applications:');
  apps.forEach((app) {
    print('  ${app}');
  });

  var packages = cache.getCachedPackages();
  print('\n${packages.length} packages in cache:');
  packages.forEach((pkg) {
    print('  ${pkg}');
  });
}
