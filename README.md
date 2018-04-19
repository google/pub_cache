# pub_cache

A library to reflect on the local pub cache.

[![pub package](http://img.shields.io/pub/v/pub_cache.svg)](https://pub.dartlang.org/packages/pub_cache)
[![Build Status](https://travis-ci.org/dart-lang/pub_cache.svg)](https://travis-ci.org/dart-lang/pub_cache)
[![Build status](https://ci.appveyor.com/api/projects/status/w75vsabfhgmo93hq/branch/master?svg=true)](https://ci.appveyor.com/project/devoncarew/pub-cache/branch/master)

## How do I use it?

`pub_cache` lets you reflect on the information in your Pub cache. For example,
to find all the applications that have been activated:

```dart
PubCache cache = new PubCache();

for (Application app in cache.getGlobalApplications()) {
  print('activated app: ${app.name}, version: ${app.version}');
}
```

Some other interesting use cases:

- finding all the activated applications whose defining package has a specific
  meta-data file
- given a package name, locate the directory on disk for that package, and
  using that location to read resources contained in the package
- finding the latest non-dev version of all the packages in the cache

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/dart-lang/pub_cache/issues
