#!/bin/bash

set -e

while read plugin; do
  /usr/bin/jenkins-plugin-cli --plugins "$plugin"
done
