#!/bin/bash

# Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
# for details. All rights reserved. Use of this source code is governed by a
# BSD-style license that can be found in the LICENSE file.

# Fast fail the script on failures.
set -e

# Activate some packages for use while running tests.
pub global activate tuneup
pub global activate path 1.6.2
pub global activate path
pub global activate --source git https://github.com/dart-lang/test.git
pub global activate --source path .

# Verify that the libraries are error free.
dartanalyzer --fatal-warnings .

# Ensure the example works.
dart example/list.dart

# Run the tests.
dart test/all.dart
