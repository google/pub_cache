[![Dart](https://github.com/google/pub_cache/actions/workflows/build.yaml/badge.svg)](https://github.com/google/pub_cache/actions/workflows/build.yaml)
[![pub package](http://img.shields.io/pub/v/pub_cache.svg)](https://pub.dartlang.org/packages/pub_cache)

A library to reflect on the local pub cache.

# Update - discontinued

As per https://github.com/google/pub_cache/issues/48 we've discontinued this
package. It was no longer used by the Dart team and has limited ecosystem usage.
Possible recourse for people who are using it is listed in that issue.

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

[tracker]: https://github.com/google/pub_cache/issues
