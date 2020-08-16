# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased](https://github.com/stefanzweifel/git-auto-commit-action/compare/v4.4.1...HEAD)

> TBD


## [v4.4.1](https://github.com/stefanzweifel/git-auto-commit-action/compare/v4.4.0...v4.4.1) - 2020-08-016

### Changed
- Include given `file_pattern` in git dirty check [#91](https://github.com/stefanzweifel/git-auto-commit-action/pull/91)


## [v4.4.0](https://github.com/stefanzweifel/git-auto-commit-action/compare/v4.3.0...v4.4.0) - 2020-06-26

### Added
- Add option to skipt the dirty check and always try to create and push a commit [#82](https://github.com/stefanzweifel/git-auto-commit-action/issues/82), [#84](https://github.com/stefanzweifel/git-auto-commit-action/pull/84)


## [v4.3.0](https://github.com/stefanzweifel/git-auto-commit-action/compare/v4.2.0...v4.3.0) - 2020-05-16

Note: Since v4.3.0 we provide major version tags. You can now use `stefanzweifel/git-auto-commit-action@v4` to always use the latest release of a major version. See [#77](https://github.com/stefanzweifel/git-auto-commit-action/issues/77) for details.

### Added
- Add new `push_options`-input. This feature makes it easier for you to force-push commits to a repository. [#78](https://github.com/stefanzweifel/git-auto-commit-action/pull/78), [#72](https://github.com/stefanzweifel/git-auto-commit-action/issues/72)


## [v4.2.0](https://github.com/stefanzweifel/git-auto-commit-action/compare/v4.1.6...v4.2.0) - 2020-05-10

### Changed
- Use `${{ github.head_ref }}` as default branch value. Therefore, the branch name when listening for `pull_request`-events is optional. [#75](https://github.com/stefanzweifel/git-auto-commit-action/pull/75), [#73](https://github.com/stefanzweifel/git-auto-commit-action/pull/73)


## [v4.1.6](https://github.com/stefanzweifel/git-auto-commit-action/compare/v4.1.5...v4.1.6) - 2020-04-28

### Fixes
- Fix issue where tags could not be created correctly [#68](https://github.com/stefanzweifel/git-auto-commit-action/pull/68)

## [v4.1.5](https://github.com/stefanzweifel/git-auto-commit-action/compare/v4.1.4...v4.1.5) - 2020-04-23

### Added
- Update `file_pattern` to support multiple file paths [#65](https://github.com/stefanzweifel/git-auto-commit-action/pull/65)

### Changes
- Revert changes made in v4.1.4 [#63](https://github.com/stefanzweifel/git-auto-commit-action/pull/63)

### Fixes
- Fix issue with `commit_options` [#64](https://github.com/stefanzweifel/git-auto-commit-action/pull/64)

## [v4.1.4](https://github.com/stefanzweifel/git-auto-commit-action/compare/v4.1.3...v4.1.4) - 2020-04-22

### Fixed
- Fix bug introduced in previous version, where git user configuration has been placed inline [#62](https://github.com/stefanzweifel/git-auto-commit-action/pull/62)


## [v4.1.3](https://github.com/stefanzweifel/git-auto-commit-action/compare/v4.1.2...v4.1.3) - 2020-04-18

### Changed
- Place Git user configuration inline [#59](https://github.com/stefanzweifel/git-auto-commit-action/pull/59)

## [v4.1.2](https://github.com/stefanzweifel/git-auto-commit-action/compare/v4.1.1...v4.1.2) - 2020-04-03

### Fixes
- Fix Issue with `changes_detected`-output [#57](https://github.com/stefanzweifel/git-auto-commit-action/pull/57)

## [v4.1.1](https://github.com/stefanzweifel/git-auto-commit-action/compare/v4.1.0...v4.1.1) - 2020-03-14

### Fixes
- Fix issue where commit has not been pushed to remote repository, when no `branch`-option has been given [#54](https://github.com/stefanzweifel/git-auto-commit-action/pull/54)


## [v4.1.0](https://github.com/stefanzweifel/git-auto-commit-action/compare/v4.0.0...v4.1.0) - 2020-03-05

### Added
- Add `changes_detected` output [#49](https://github.com/stefanzweifel/git-auto-commit-action/pull/49), [#46](https://github.com/stefanzweifel/git-auto-commit-action/issues/46)
- Add `tagging_message` input option to create and push tags [#50](https://github.com/stefanzweifel/git-auto-commit-action/pull/50), [#47](https://github.com/stefanzweifel/git-auto-commit-action/issues/47)


## [v4.0.0](https://github.com/stefanzweifel/git-auto-commit-action/compare/v3.0.0...v4.0.0) - 2020-02-24

### Changed
- Switch Action to use `node12`-environment instead of `docker`. [#45](https://github.com/stefanzweifel/git-auto-commit-action/pull/45)

## [v3.0.0](https://github.com/stefanzweifel/git-auto-commit-action/compare/v2.5.0...v3.0.0) - 2020-02-06

### Added
- Add `commit_user_name`, `commit_user_email` and `commit_author` input options for full customzation on how the commit is being created [#39](https://github.com/stefanzweifel/git-auto-commit-action/pull/39)

### Changed
- Make the `branch` input option optional [#41](https://github.com/stefanzweifel/git-auto-commit-action/pull/41)

### Removed
- Remove the need of a GITHUB_TOKEN. Users now have to use `actions/checkout@v2` or higher [#36](https://github.com/stefanzweifel/git-auto-commit-action/pull/36)


## [v2.5.0](https://github.com/stefanzweifel/git-auto-commit-action/compare/v2.4.0...v2.5.0) - 2019-12-18

### Added
- Add new `repository`-argument [#22](https://github.com/stefanzweifel/git-auto-commit-action/pull/22)

### Changed
- Extract logic of the Action into methods and into a separate file [#24](https://github.com/stefanzweifel/git-auto-commit-action/pull/24)


## [v2.4.0](https://github.com/stefanzweifel/git-auto-commit-action/compare/v2.3.0...v2.4.0) - 2019-11-30

### Added
- Commit untracked files [#19](https://github.com/stefanzweifel/git-auto-commit-action/pull/19) (fixes [#16](https://github.com/stefanzweifel/git-auto-commit-action/issues/16))
- Add support for Git-LFS [#21](https://github.com/stefanzweifel/git-auto-commit-action/pull/21) (fixes [#20](https://github.com/stefanzweifel/git-auto-commit-action/issues/20))


## [v2.3.0](https://github.com/stefanzweifel/git-auto-commit-action/compare/v2.2.0...v2.3.0) - 2019-11-04

### Added
- Add a new `commit_option`-argument. Allows users to define additional commit options for the `git-commit` command. [#14](https://github.com/stefanzweifel/git-auto-commit-action/pull/15)


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

