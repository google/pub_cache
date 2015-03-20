// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library pub_cache;

import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:pub_semver/pub_semver.dart';
import 'package:yaml/yaml.dart' as yaml;

// TODO: do things like get all the versions for a package?

// TODO: get the latest version for a package?

// TODO: get the latest non-dev version for a package?

// TODO: get all the packages (id's only) in the pubcache

/**
 * TODO:
 */
class PubCache {

  static Directory getSystemCacheLocation() {
    if (Platform.environment.containsKey('PUB_CACHE')) {
      return new Directory(Platform.environment['PUB_CACHE']);
    } else if (Platform.operatingSystem == 'windows') {
      var appData = Platform.environment['APPDATA'];
      return new Directory(path.join(appData, 'Pub', 'Cache'));
    } else {
      return new Directory('${Platform.environment['HOME']}/.pub-cache');
    }
  }

  final Directory location;

  List<Application> _applications;
  List<PackageRef> _packageRefs;

  PubCache([Directory dir]) :
      location = dir == null ? getSystemCacheLocation() : dir {
    _parse();
  }

  /**
   * Return the contents of `bin/` - the scripts for the activated applications.
   */
  List<File> getBinaries() {
    Directory dir = _getSubDir(location, 'bin');
    return dir.existsSync() ? dir.listSync() : [];
  }

  List<Application> getGlobalApplications() => _applications;

  List<PackageRef> getPackageRefs() => _packageRefs;

  void _parse() {
    // Read the activated applications.
    _applications = [];

    Directory globalPackagesDir = _getSubDir(location, 'global_packages');
    if (globalPackagesDir.existsSync()) {
      _applications = globalPackagesDir.listSync().map(
          (dir) => new Application._(this, dir)).toList();
    }

    // TODO: Scan for git packages.

    // Scan hosted packages - just pub.dartlang.org for now.
    _packageRefs = [];

    Directory dartlangDir = new Directory(
        path.join(location.path, 'hosted', 'pub.dartlang.org'));
    if (dartlangDir.existsSync()) {
      _packageRefs = dartlangDir.listSync()
          .where((dir) => dir is Directory)
          .map((dir) => new _DirectoryPackageRef('hosted', dir))
          .toList();
    }
  }

  Directory _getSubDir(Directory dir, String name) =>
      new Directory(path.join(dir.path, name));
}

class Application {
  final PubCache _cache;
  final Directory _dir;

  List<PackageRef> _packageRefs;
  Version _version;

  Application._(this._cache, this._dir);

  String get name => path.basename(_dir.path);

  Version get version {
    if (_packageRefs == null) _parsePubspecLock();
    return _version;
  }

  List<PackageRef> getPackageRefs() {
    if (_packageRefs == null) _parsePubspecLock();
    return _packageRefs;
  }

  String toString() => '${name} ${version}';

  void _parsePubspecLock() {
    File pubspecLock = new File(path.join(_dir.path, 'pubspec.lock'));
    Map doc = yaml.loadYaml(pubspecLock.readAsStringSync());
    Map packages = doc['packages'];
    _packageRefs = packages.keys.map((key) {
      Map m = packages[key];
      return new _AppPackageRef(_cache, m['source'], key, m['version']);
    }).toList();

    String name = this.name;

    for (PackageRef ref in _packageRefs) {
      if (ref.name == name) {
        _version = ref.version;
        break;
      }
    }
  }
}

abstract class PackageRef {
  String get sourceType;
  String get name;
  Version get version;

  Package resolve();

  bool operator ==(other) {
    return this.sourceType == other.sourceType
        && this.name == other.name
        && this.version == other.version;
  }

  String toString() => '${name} ${version}';
}

class _AppPackageRef extends PackageRef {
  final PubCache cache;
  final String sourceType;
  final String name;
  final Version version;

  _AppPackageRef(this.cache, this.sourceType, this.name, String ver) :
      version = new Version.parse(ver);

  Package resolve() {
    for (PackageRef ref in cache.getPackageRefs()) {
      if (ref == this) return ref.resolve();
    }

    return null;
  }
}

class _DirectoryPackageRef extends PackageRef {
  final String sourceType;
  final Directory directory;

  String _name;
  Version _version;

  _DirectoryPackageRef(this.sourceType, this.directory) {
    _name = path.basename(this.directory.path);

    int index = _name.indexOf('-');
    if (index != -1) {
      _version = new Version.parse(_name.substring(index + 1));
      _name = _name.substring(0, index);
    }
  }

  String get name => _name;
  Version get version => _version;

  Package resolve() => new Package(directory, name, version);
}

class Package {
  final Directory location;
  final String name;
  final Version version;

  Package(this.location, this.name, this.version);

  String toString() => '${name} ${version}';
}