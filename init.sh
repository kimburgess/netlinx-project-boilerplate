#!/bin/bash

echo "Initialising project repo..."

# Remove our original boilderplate repo origin
git remote rm origin

# Nuke the README
git rm README.md
git commit -m "remove readme"

# Nuke this script
git rm init.sh
git commit -m "remove init script"

# Set ourselves up with a fresh git history
git checkout --orphan temp
git add -A
git commit -m "initial commit"
git branch -D master
git branch -m master

# Pull down the latest from our external libs
git submodule update --init --recursive

echo "Done"
