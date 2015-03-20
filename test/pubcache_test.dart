// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library pubcache_test;

import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:pubcache/pubcache.dart';
import 'package:unittest/unittest.dart';

void main() => defineTests();

void defineTests() {
  group('PubCache', () {
    test('getSystemCacheLocation', () {
      Directory cacheDir = PubCache.getSystemCacheLocation();
      expect(cacheDir, isNotNull);
      expect(path.basename(cacheDir.path), contains('pub-cache'));
    });

    test('PubCache', () {
      PubCache cache = new PubCache();
      expect(cache, isNotNull);
      expect(cache.location, isNotNull);
      expect(path.basename(cache.location.path), contains('pub-cache'));
    });

    test('getBinaries', () {
      PubCache cache = new PubCache();
      expect(cache.getBinaries(), isNotNull);
    });
  });
}
