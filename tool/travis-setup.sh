#!/bin/bash

# Fast fail the script on failures.
set -e

# Activate some packages for use while running tests.
pub global activate tuneup
pub global activate path 1.6.2
pub global activate path
pub global activate --source git https://github.com/dart-lang/yaml.git
pub global activate --source path .
