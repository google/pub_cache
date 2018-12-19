// Copyright (c) 2014, Google Inc. Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

library pub_cache.impl;

import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:pub_semver/pub_semver.dart';
import 'package:yaml/yaml.dart' as yaml;

import '../pub_cache.dart';

class PackageRefImpl extends PackageRef {
  final String sourceType;
  final String name;
  final Version version;

  Function _resolver;

  PackageRefImpl(this.sourceType, this.name, String ver)
      : version = new Version.parse(ver);

  PackageRefImpl.hosted(this.name, String ver, this._resolver)
      : sourceType = 'hosted',
        version = new Version.parse(ver);

  factory PackageRefImpl.git(
      String name, String ver, Map description, Function resolver) {
    return new GitPackageRefImpl(name, ver, description, resolver);
  }

  factory PackageRefImpl.path(String name, String ver, Map description) {
    return new PathPackageRefImpl(name, ver, description);
  }

  Package resolve() => _resolver == null ? null : _resolver(this);
}

class GitPackageRefImpl extends PackageRefImpl {
  final Map _description;

  GitPackageRefImpl(
      String name, String ver, this._description, Function resolver)
      : super('git', name, ver) {
    _resolver = resolver;
  }

  /// The git url.
  String get url => _description['url'];

  /// The git commit.
  String get resolvedRef => _description['resolved-ref'];

  String toString() => '${name} ${version} (${url}, ${resolvedRef})';
}

class PathPackageRefImpl extends PackageRefImpl {
  final Map _description;

  PathPackageRefImpl(String name, String ver, this._description)
      : super('path', name, ver);

  /// The path to the local package.
  String get path => _description['path'];

  bool get relative => _description['relative'] == true;

  Package resolve() {
    Directory dir = new Directory(path);
    return dir.existsSync() ? new Package(dir, name, version) : null;
  }

  String toString() => '${name} ${version} (${path}, relative=${relative})';
}

/// A reference to a package in the pub cache (for instance, something in
/// `~/.pub-cache/hosted/pub.dartlang.org/`).
class DirectoryPackageRef extends PackageRef {
  final String sourceType;
  final Directory directory;

  String _name;
  Version _version;

  DirectoryPackageRef(this.sourceType, this.directory) {
    _name = path.basename(this.directory.path);

    int index = _name.indexOf('-');
    if (index != -1) {
      _version = new Version.parse(_name.substring(index + 1));
      _name = _name.substring(0, index);
    } else {
      _version = Version.none;
    }
  }

  String get name => _name;
  Version get version => _version;

  Package resolve() => new Package(directory, name, version);
}

/// A reference to a package in the pub cache; something in `~/.pub-cache/git/`.
class GitDirectoryPackageRef extends PackageRef {
  final String sourceType;
  final Directory directory;

  String _name;
  Version _version;
  String _resolvedRef;

  GitDirectoryPackageRef(this.directory) : sourceType = 'git' {
    _name = path.basename(this.directory.path);

    int index = _name.indexOf('-');
    if (index != -1) {
      _resolvedRef = _name.substring(index + 1);
      _name = _name.substring(0, index);
    }

    // Parse the version.
    _version = Version.none;
    File f = new File(path.join(directory.path, 'pubspec.yaml'));
    if (f.existsSync()) {
      Map pubspec = yaml.loadYaml(f.readAsStringSync());
      if (pubspec.containsKey('version')) {
        _version = new Version.parse(pubspec['version']);
      }
    }
  }

  String get name => _name;
  Version get version => _version;

  /// The git commit.
  String get resolvedRef => _resolvedRef;

  Package resolve() => new Package(directory, name, version);

  String toString() => '${name} ${version} (${resolvedRef})';
}
