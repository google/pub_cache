// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:pub_cache/pub_cache.dart';

import 'pub_cache_test.dart' as pub_cache_test;

void main() {
  // We need at least one activated application for our test suite.
  if (new PubCache().getGlobalApplications().isEmpty) {
    Process.runSync('pub', ['global', 'activate', 'dart_coveralls']);
  }

  pub_cache_test.defineTests();
}
