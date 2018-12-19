#!/bin/bash

# Copyright (c) 2014, Google Inc. Please see the AUTHORS file for details.
# All rights reserved. Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

set -e

# Verify that the libraries are error free.
dartanalyzer --fatal-warnings .

# Ensure the example works.
dart example/list.dart

# Run the tests.
dart test/all.dart
