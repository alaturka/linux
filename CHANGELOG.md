Changelog
=========

All notable changes to this project will be documented in this file.

[Unreleased]
--------------------

### Added

- grading: Fallback to `.local/etc/autograding.json` for grading.
- development/c: Add Tiny C Compiler.
- bootstrap: Allow Pop!_OS.
- bootstrap: Refactor the whole process to continue with full classroom installation.

### Changed

- style/c: Increase Increase column limit to 120.
- bootstrap: Add `--anyos` switch to bypass OS assertion.
- bootstrap: Add notice after a failure.
- provision: Prevent provisioning failure for non critical package installations.
- provision: Report failure message after a failed provisioning step.

[0.1.0] - 2022-02-27
--------------------

Initial release.
