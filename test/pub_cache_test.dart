// Copyright (c) 2014, Google Inc. Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

library pub_cache_test;

import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:pub_cache/pub_cache.dart';
import 'package:test/test.dart';

void main() => defineTests();

void defineTests() {
  final String cacheDirName = Platform.isWindows ? 'Cache' : 'pub-cache';

  group('PubCache', () {
    tearDown(() {
      Directory cacheDir = PubCache.getSystemCacheLocation();
      var globalDir =
          new Directory(path.join(cacheDir.path, "global_packages"));
      var file = new File(path.join(globalDir.path, "nonsense"));
      if (file.existsSync()) {
        file.deleteSync();
      }
    });

    test('getSystemCacheLocation', () {
      Directory cacheDir = PubCache.getSystemCacheLocation();
      expect(cacheDir, isNotNull);
      expect(path.basename(cacheDir.path), contains(cacheDirName));
    });

    test('Create PubCache when non-directories are in global_packages', () {
      // Get cache in its current state
      var cache = new PubCache();
      var currentGlobalApps = cache.getGlobalApplications();

      // Put a file in global_packages
      Directory cacheDir = PubCache.getSystemCacheLocation();
      var globalDir =
          new Directory(path.join(cacheDir.path, "global_packages"));
      var file = new File(path.join(globalDir.path, "nonsense"));
      file.writeAsStringSync("pub_cache test suite");

      // Ensure that this file is not reflected in cache
      cache = new PubCache();
      var newGlobalApps = cache.getGlobalApplications();

      expect(currentGlobalApps.length, newGlobalApps.length);
    });

    test('PubCache', () {
      PubCache cache = new PubCache();
      expect(cache, isNotNull);
      expect(cache.location, isNotNull);
      expect(path.basename(cache.location.path), contains(cacheDirName));
    });

    test('getBinaries', () {
      PubCache cache = new PubCache();
      expect(cache.getBinScripts(), isNotNull);
    });

    test('getGlobalApplications', () {
      PubCache cache = new PubCache();
      expect(cache.getGlobalApplications(), isNotEmpty);
    });

    test('getPackageRefs', () {
      PubCache cache = new PubCache();
      expect(cache.getPackageRefs(), isNotEmpty);
    });

    test('getCachedPackages', () {
      PubCache cache = new PubCache();
      expect(cache.getCachedPackages(), isNotEmpty);
    });

    test('getAllPackageVersions', () {
      PubCache cache = new PubCache();
      expect(cache.getAllPackageVersions('path'), isNotEmpty);
    });

    test('getLatestVersion', () {
      PubCache cache = new PubCache();
      expect(cache.getLatestVersion('path'), isNotNull);
    });

    test('getLatestVersion.dev', () {
      PubCache cache = new PubCache();
      expect(
          cache.getLatestVersion('path', includePreRelease: true), isNotNull);
    });
  });

  group('Application', () {
    PubCache cache;
    Application app;

    setUp(() {
      cache = new PubCache();
      app = cache.getGlobalApplications().first;
    });

    test('name', () {
      expect(app.name, isNotEmpty);
    });

    test('version', () {
      expect(app.version, isNotNull);
    });

    test('getDefiningPackageRef', () {
      expect(app.getDefiningPackageRef().name, app.name);
    });

    test('getPackageRefs', () {
      expect(app.getPackageRefs(), isNotEmpty);
    });

    test('toString', () {
      expect(app.toString(), isNotEmpty);
    });
  });

  group('PackageRef', () {
    PubCache cache;
    Application app;
    PackageRef ref;

    setUp(() {
      cache = new PubCache();
      app = cache.getGlobalApplications().first;
      ref = app.getPackageRefs().first;
    });

    test('name', () {
      expect(ref.name, isNotEmpty);
    });

    test('==', () {
      PackageRef ref0 = app.getPackageRefs()[0];
      PackageRef ref1 = app.getPackageRefs()[1];

      expect(ref0, equals(ref0));
      expect(ref0, isNot(equals(ref1)));
    });

    test('resolve', () {
      expect(ref.resolve(), isNotNull);
    });

    test('toString', () {
      expect(ref.toString(), isNotEmpty);
    });
  });

  group('Package', () {
    test('toString', () {
      PubCache cache = new PubCache();
      Package p = cache.getPackageRefs().first.resolve();
      expect(p, isNotNull);
      expect(p.toString(), isNotEmpty);
    });
  });

  group('integration', () {
    test('list apps', () {
      StringBuffer buf = new StringBuffer();
      PubCache cache = new PubCache();
      var apps = cache.getGlobalApplications();
      apps.forEach((app) => buf.writeln('  ${app}'));
      expect(buf.toString(), isNotEmpty);
    });

    test('everything parses', () {
      StringBuffer buf = new StringBuffer();
      PubCache cache = new PubCache();
      var packageRefs = cache.getPackageRefs();
      packageRefs.forEach((ref) {
        expect(ref.version, isNotNull);
        buf.writeln('${ref}');
      });
      expect(buf.toString(), isNotEmpty);
    });

    test('list packages', () {
      StringBuffer buf = new StringBuffer();
      PubCache cache = new PubCache();
      var packages = cache.getCachedPackages();
      packages.forEach((pkg) {
        List<PackageRef> versions = cache.getAllPackageVersions(pkg);
        buf.writeln(
            '${pkg} [${versions.map((p) => p.version.toString()).join(', ')}]');
      });
      expect(buf.toString(), isNotEmpty);
    });

    test('everything resolves', () {
      PubCache cache = new PubCache();

      for (Application app in cache.getGlobalApplications()) {
        for (PackageRef ref in app.getPackageRefs()) {
          expect(ref.resolve(), isNotNull);
        }
      }

      for (PackageRef ref in cache.getPackageRefs()) {
        expect(ref.resolve(), isNotNull);
      }
    });
  });
}
