#!/bin/bash

# Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
# for details. All rights reserved. Use of this source code is governed by a
# BSD-style license that can be found in the LICENSE file.

# Fast fail the script on failures.
set -e

# Activate some packages for use while running tests.
pub global activate path 1.3.0
pub global activate path
pub global activate --source git https://github.com/dart-lang/test.git
pub global activate --source path .

# Verify that the libraries are error free.
dartanalyzer --fatal-warnings \
  example/ \
  lib/ \
  test/

# Ensure the example works in Dart 2.
dart --preview-dart-2 example/list.dart

# Run the tests.
dart --preview-dart-2 test/all.dart
