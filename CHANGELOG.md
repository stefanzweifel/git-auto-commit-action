# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased](https://github.com/stefanzweifel/git-auto-commit-action/compare/v2.2.0...HEAD)

## [v2.2.0](https://github.com/stefanzweifel/git-auto-commit-action/compare/v2.1.0...v2.2.0) - 2019-10-26

### Added
- Add new `file_pattern`-argument. Allows users to define which files should be added in the commit. [#13](https://github.com/stefanzweifel/git-auto-commit-action/pull/13)

## [v2.1.0](https://github.com/stefanzweifel/git-auto-commit-action/compare/v2.0.0...v2.1.0) - 2019-09-20

### Added
- Add `branch`-argument to determine, to which branch changes should be pushed. See README for usage details.

### Fixed
- Fixes Issue where changes couldn't be pushed to GitHub due to wrong ref-name.

### Removed
- Remove `commit_author_email` and `commit_author_name` arguments. The `$GITHUB_ACTOR` is now used as the Git Author


## [v2.0.0](https://github.com/stefanzweifel/git-auto-commit-action/compare/v1.0.0...v2.0.0) - 2019-08-31

### Changed
- Make Action Compatible with latest beta of GitHub Actions [#3](https://github.com/stefanzweifel/git-auto-commit-action/pull/3)


## v1.0.0 - 2019-06-10

### Added

- Add Core Logic for Action

