#!/bin/bash
flutter clean
flutter packages pub upgrade
flutter pub run build_runner build
code .
flutter pub run build_runner watch --delete-conflicting-outputs

