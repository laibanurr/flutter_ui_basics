# Flutter UI Basics

A progressive, exhaustively-documented Flutter engineering course — built from first principles through to production-grade architecture, testing, and deployment.

## Purpose

This repository tracks deliberate, sequential mastery of the Flutter framework — from rendering pipeline internals (Widget/Element/RenderObject trees) through state management, networking, testing, and CI/CD deployment.

## Engineering Standards

- **Linting:** Strict `very_good_analysis` ruleset — zero warnings tolerated on `main`
- **Formatting:** `dart format` enforced via format-on-save, 80-character line length
- **Testing:** Unit, widget, and integration test coverage added per feature
- **Git hygiene:** Conventional Commits, feature-branch-per-topic workflow

## Structure

lib/
main.dart
app.dart
features/
  widget_tree/
test/
  widget_tree/

## Running This Project

flutter pub get
flutter analyze
flutter test
flutter run