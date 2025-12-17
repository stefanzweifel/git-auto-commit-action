# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased](https://github.com/stefanzweifel/git-auto-commit-action/compare/v7.1.0...HEAD)

> TBD

## [v7.1.0](https://github.com/stefanzweifel/git-auto-commit-action/compare/v7.0.0...v7.1.0) - 2025-12-17

### Added

- Add skip_push input option ([#401](https://github.com/stefanzweifel/git-auto-commit-action/pull/401)) [@kvanzuijlen](https://github.com/@kvanzuijlen)

### Changes

- docs: fix typo in README.md ([#400](https://github.com/stefanzweifel/git-auto-commit-action/pull/400)) [@GideonBear](https://github.com/@GideonBear)

### Dependency Updates

- Bump actions/checkout from 5 to 6 ([#399](https://github.com/stefanzweifel/git-auto-commit-action/pull/399)) [@[dependabot[bot]](https://github.com/apps/dependabot)](https://github.com/@[dependabot[bot]](https://github.com/apps/dependabot))
- Bump bats from 1.12.0 to 1.13.0 ([#398](https://github.com/stefanzweifel/git-auto-commit-action/pull/398)) [@[dependabot[bot]](https://github.com/apps/dependabot)](https://github.com/@[dependabot[bot]](https://github.com/apps/dependabot))

## [v7.0.0](https://github.com/stefanzweifel/git-auto-commit-action/compare/v6.0.1...v7.0.0) - 2025-10-12

### Added

- Restore skip_fetch, skip_checkout, create_branch ([#388](https://github.com/stefanzweifel/git-auto-commit-action/pull/388)) [@stefanzweifel](https://github.com/@stefanzweifel)
- Restore Detached State Detection ([#393](https://github.com/stefanzweifel/git-auto-commit-action/pull/393)) [@stefanzweifel](https://github.com/@stefanzweifel)
- Add Support for Tag Messages ([#391](https://github.com/stefanzweifel/git-auto-commit-action/pull/391)) [@EliasBoulharts](https://github.com/@EliasBoulharts)

### Changed

- Run Action on Node 24 ([#389](https://github.com/stefanzweifel/git-auto-commit-action/pull/389)) [@stefanzweifel](https://github.com/@stefanzweifel)

### Dependency Updates

- Bump actions/checkout from 4 to 5 ([#386](https://github.com/stefanzweifel/git-auto-commit-action/pull/386)) [@[dependabot[bot]](https://github.com/apps/dependabot)](https://github.com/@[dependabot[bot]](https://github.com/apps/dependabot))

## [v6.0.1](https://github.com/stefanzweifel/git-auto-commit-action/compare/v6.0.0...v6.0.1) - 2025-06-11

### Fixed

- Disable Check if Repo is in Detached State ([#379](https://github.com/stefanzweifel/git-auto-commit-action/pull/379)) [@stefanzweifel](https://github.com/@stefanzweifel)

## [v6.0.0](https://github.com/stefanzweifel/git-auto-commit-action/compare/v5.2.0...v6.0.0) - 2025-06-10

### Added

- Throw error early if repository is in a detached state ([#357](https://github.com/stefanzweifel/git-auto-commit-action/pull/357))

### Fixed

- Fix PAT instructions with Dependabot ([#376](https://github.com/stefanzweifel/git-auto-commit-action/pull/376)) [@Dreamsorcerer](https://github.com/@Dreamsorcerer)

### Removed

- Remove support for `create_branch`, `skip_checkout`, `skip_Fetch` ([#314](https://github.com/stefanzweifel/git-auto-commit-action/pull/314))

## [v5.2.0](https://github.com/stefanzweifel/git-auto-commit-action/compare/v5.1.0...v5.2.0) - 2025-04-19

### Added

- Add `create_git_tag_only` option to skip commiting and always create a git-tag. ([#364](https://github.com/stefanzweifel/git-auto-commit-action/pull/364)) [@zMynxx](https://github.com/@zMynxx)
- Add Test for `create_git_tag_only` feature ([#367](https://github.com/stefanzweifel/git-auto-commit-action/pull/367)) [@stefanzweifel](https://github.com/@stefanzweifel)

### Fixed

- docs: Update README.md per #354 ([#361](https://github.com/stefanzweifel/git-auto-commit-action/pull/361)) [@rasa](https://github.com/@rasa)

## [v5.1.0](https://github.com/stefanzweifel/git-auto-commit-action/compare/v5.0.1...v5.1.0) - 2025-01-11

### Changed

- Include `github.actor_id` in default `commit_author` ([#354](https://github.com/stefanzweifel/git-auto-commit-action/pull/354)) [@parkerbxyz](https://github.com/@parkerbxyz)

### Fixed

- docs(README): fix broken protected branch docs link ([#346](https://github.com/stefanzweifel/git-auto-commit-action/pull/346)) [@scarf005](https://github.com/@scarf005)
- Update README.md ([#343](https://github.com/stefanzweifel/git-auto-commit-action/pull/343)) [@Kludex](https://github.com/@Kludex)

### Dependency Updates

- Bump bats from 1.11.0 to 1.11.1 ([#353](https://github.com/stefanzweifel/git-auto-commit-action/pull/353)) [@dependabot](https://github.com/@dependabot)
- Bump github/super-linter from 6 to 7 ([#342](https://github.com/stefanzweifel/git-auto-commit-action/pull/342)) [@dependabot](https://github.com/@dependabot)
- Bump github/super-linter from 5 to 6 ([#335](https://github.com/stefanzweifel/git-auto-commit-action/pull/335)) [@dependabot](https://github.com/@dependabot)

## [v5.0.1](https://github.com/stefanzweifel/git-auto-commit-action/compare/v5.0.0...v5.0.1) - 2024-04-12

### Fixed

- Fail if attempting to execute git commands in a directory that is not a git-repo. ([#326](https://github.com/stefanzweifel/git-auto-commit-action/pull/326)) [@ccomendant](https://github.com/@ccomendant)

### Dependency Updates

- Bump bats from 1.10.0 to 1.11.0 ([#325](https://github.com/stefanzweifel/git-auto-commit-action/pull/325)) [@dependabot](https://github.com/@dependabot)
- Bump release-drafter/release-drafter from 5 to 6 ([#319](https://github.com/stefanzweifel/git-auto-commit-action/pull/319)) [@dependabot](https://github.com/@dependabot)

### Misc

- Clarify `commit_author` input option ([#315](https://github.com/stefanzweifel/git-auto-commit-action/pull/315)) [@npanuhin](https://github.com/@npanuhin)
- Add step id explanation for output in README.md ([#324](https://github.com/stefanzweifel/git-auto-commit-action/pull/324)) [@ChristianVermeulen](https://github.com/@ChristianVermeulen)
- Linux is not UNIX ([#321](https://github.com/stefanzweifel/git-auto-commit-action/pull/321)) [@couling](https://github.com/@couling)

## [v5.0.0](https://github.com/stefanzweifel/git-auto-commit-action/compare/v4.16.0...v5.0.0) - 2023-10-06

New major release that bumps the default runtime to Node 20. There are no other breaking changes.

### Changed

- Update node version to node20 ([#300](https://github.com/stefanzweifel/git-auto-commit-action/pull/300)) [@ryudaitakai](https://github.com/@ryudaitakai)
- Add _log and _set_github_output functions ([#273](https://github.com/stefanzweifel/git-auto-commit-action/pull/273)) [@stefanzweifel](https://github.com/@stefanzweifel)

### Fixed

- Seems like there is an extra space ([#288](https://github.com/stefanzweifel/git-auto-commit-action/pull/288)) [@pedroamador](https://github.com/@pedroamador)
- Fix git-auto-commit.yml ([#277](https://github.com/stefanzweifel/git-auto-commit-action/pull/277)) [@zcong1993](https://github.com/@zcong1993)

### Dependency Updates

- Bump actions/checkout from 3 to 4 ([#302](https://github.com/stefanzweifel/git-auto-commit-action/pull/302)) [@dependabot](https://github.com/@dependabot)
- Bump bats from 1.9.0 to 1.10.0 ([#293](https://github.com/stefanzweifel/git-auto-commit-action/pull/293)) [@dependabot](https://github.com/@dependabot)
- Bump github/super-linter from 4 to 5 ([#289](https://github.com/stefanzweifel/git-auto-commit-action/pull/289)) [@dependabot](https://github.com/@dependabot)
- Bump bats from 1.8.2 to 1.9.0 ([#282](https://github.com/stefanzweifel/git-auto-commit-action/pull/282)) [@dependabot](https://github.com/@dependabot)

## [v4.16.0](https://github.com/stefanzweifel/git-auto-commit-action/compare/v4.15.4...v4.16.0) - 2022-12-02

### Changed

- Don't commit files when only LF/CRLF changes ([#265](https://github.com/stefanzweifel/git-auto-commit-action/pull/265)) [@ZeroRin](https://github.com/@ZeroRin)
- Update default email address of github-actions[bot] ([#264](https://github.com/stefanzweifel/git-auto-commit-action/pull/264)) [@Teko012](https://github.com/@Teko012)

### Fixed

- Fix link and text for workflow limitation ([#263](https://github.com/stefanzweifel/git-auto-commit-action/pull/263)) [@Teko012](https://github.com/@Teko012)

## [v4.15.4](https://github.com/stefanzweifel/git-auto-commit-action/compare/v4.15.3...v4.15.4) - 2022-11-05

### Fixed

- Let Action fail if git binary can't be located ([#261](https://github.com/stefanzweifel/git-auto-commit-action/pull/261)) [@stefanzweifel](https://github.com/@stefanzweifel)

### Dependency Updates

- Bump github/super-linter from 3 to 4 ([#258](https://github.com/stefanzweifel/git-auto-commit-action/pull/258)) [@dependabot](https://github.com/@dependabot)
- Bump bats from 1.7.0 to 1.8.2 ([#259](https://github.com/stefanzweifel/git-auto-commit-action/pull/259)) [@dependabot](https://github.com/@dependabot)
- Bump actions/checkout from 2 to 3 ([#257](https://github.com/stefanzweifel/git-auto-commit-action/pull/257)) [@dependabot](https://github.com/@dependabot)

## [v4.15.3](https://github.com/stefanzweifel/git-auto-commit-action/compare/v4.15.2...v4.15.3) - 2022-10-26

### Changed

- Use deprecated set-output syntax if GITHUB_OUTPUT environment is not available ([#255](https://github.com/stefanzweifel/git-auto-commit-action/pull/255)) [@stefanzweifel](https://github.com/@stefanzweifel)

## [v4.15.2](https://github.com/stefanzweifel/git-auto-commit-action/compare/v4.15.1...v4.15.2) - 2022-10-22

### Changed

- Replace set-output usage with GITHUB_OUTPUT ([#252](https://github.com/stefanzweifel/git-auto-commit-action/pull/252)) [@amonshiz](https://github.com/amonshiz)

## [v4.15.1](https://github.com/stefanzweifel/git-auto-commit-action/compare/v4.15.0...v4.15.1) - 2022-10-10

### Fixed

- Run Action on Node16 ([#247](https://github.com/stefanzweifel/git-auto-commit-action/pull/247)) [@stefanzweifel](https://github.com/@stefanzweifel)

## [v4.15.0](https://github.com/stefanzweifel/git-auto-commit-action/compare/v4.14.1...v4.15.0) - 2022-09-24

### Changed

- Expand `file_pattern`-input to an array ([#205](https://github.com/stefanzweifel/git-auto-commit-action/pull/205)) [@stefanzweifel](https://github.com/@stefanzweifel)

### Fixed

- String values in README.md extended example are now correct ([#196](https://github.com/stefanzweifel/git-auto-commit-action/pull/196)) [@karolswdev](https://github.com/@karolswdev)
- Fix Typos and grammer Errors in README ([#235](https://github.com/stefanzweifel/git-auto-commit-action/pull/235)) [@derrickleemy](https://github.com/@derrickleemy)
- Fix Typo in README ([#230](https://github.com/stefanzweifel/git-auto-commit-action/pull/230)) [@fty4](https://github.com/@fty4)
- Add missing links in the CHANGELOG ([#223](https://github.com/stefanzweifel/git-auto-commit-action/pull/223)) [@ericcornelissen](https://github.com/@ericcornelissen)

## [v4.14.1](https://github.com/stefanzweifel/git-auto-commit-action/compare/v4.14.0...v4.14.1) - 2022-04-12

## Changed

- Change Commit User Name from "GitHub Actions" to "github-actions[bot]" ([#213](https://github.com/stefanzweifel/git-auto-commit-action/pull/213)) @jooola
- Change Commit User Email from "actions@github.com" to "github-actions[bot]@users.noreply.github.com" ([#213](https://github.com/stefanzweifel/git-auto-commit-action/pull/213)) @jooola

## Fixed

- Update doc link to GITHUB_TOKEN not triggering new workflow runs ([#206](https://github.com/stefanzweifel/git-auto-commit-action/pull/206)) @gapple

## [v4.14.0](https://github.com/stefanzweifel/git-auto-commit-action/compare/v4.13.1...v4.14.0) - 2022-03-18

## Added

- Add `create_branch` option to force create a new branch ([#203](https://github.com/stefanzweifel/git-auto-commit-action/pull/203)) @stefanzweifel

## Fixed

- README.md: Updates hyperlink to GH docs ([#200](https://github.com/stefanzweifel/git-auto-commit-action/pull/200)) @funkyfuture

## [v4.13.1](https://github.com/stefanzweifel/git-auto-commit-action/compare/v4.13.0...v4.13.1) - 2022-01-13

## Fixed

- Properly disambiguate between branch or file checkout ([#199](https://github.com/stefanzweifel/git-auto-commit-action/pull/199)) @kenodegard

## [v4.13.0](https://github.com/stefanzweifel/git-auto-commit-action/compare/v4.12.0...v4.13.0) - 2022-01-10

## Added

- Add `skip_checkout` option ([#197](https://github.com/stefanzweifel/git-auto-commit-action/pull/197)) @cmbuckley

## Changed

- Add note on minimum permissions to the docs ([#180](https://github.com/stefanzweifel/git-auto-commit-action/pull/180)) @ericcornelissen

## [v4.12.0](https://github.com/stefanzweifel/git-auto-commit-action/compare/v4.11.0...v4.12.0) - 2021-09-10

### Added

- Add `commit_hash` output [#172](https://github.com/stefanzweifel/git-auto-commit-action/pull/172)

## [v4.11.0](https://github.com/stefanzweifel/git-auto-commit-action/compare/v4.10.0...v4.11.0) - 2021-05-03

### Added

- Add `status_options` and `add_options` option [#156](https://github.com/stefanzweifel/git-auto-commit-action/pull/156)

## [v4.10.0](https://github.com/stefanzweifel/git-auto-commit-action/compare/v4.9.2...v4.10.0) - 2021-04-12

### Added

- Add `disable_globbing` option [#153](https://github.com/stefanzweifel/git-auto-commit-action/issues/153), [#154](https://github.com/stefanzweifel/git-auto-commit-action/pull/154)

## [v4.9.2](https://github.com/stefanzweifel/git-auto-commit-action/compare/v4.9.1...v4.9.2) - 2021-03-04

### Fixes

- Push created annotated tags to remote by using `--follow-tags` and `--atomic` instead of just `--tags` [#146](https://github.com/stefanzweifel/git-auto-commit-action/pull/146)

## [v4.9.1](https://github.com/stefanzweifel/git-auto-commit-action/compare/v4.9.0...v4.9.1) - 2021-02-23

### Changed

- Revert changes made in v4.9.0. A branch will no longer be automatically generated. [#144](https://github.com/stefanzweifel/git-auto-commit-action/pull/144)

## [v4.9.0](https://github.com/stefanzweifel/git-auto-commit-action/compare/v4.8.0...v4.9.0) - 2021-02-20

### Changed

- Automatically create branch if a branch with the given name does not exist [#140](https://github.com/stefanzweifel/git-auto-commit-action/pull/140)

## [v4.8.0](https://github.com/stefanzweifel/git-auto-commit-action/compare/v4.7.2...v4.8.0) - 2020-12-15

### Added

- Add `skip_fetch` option to skip the execution of `git-fetch` [#131](https://github.com/stefanzweifel/git-auto-commit-action/pull/131)

### Changed

- Update `git fetch` to only fetch the latest commit from remote [#131](https://github.com/stefanzweifel/git-auto-commit-action/pull/131)

## [v4.7.2](https://github.com/stefanzweifel/git-auto-commit-action/compare/v4.7.1...v4.7.2) - 2020-10-24

This release basically reverts the Action to the state of `v4.6.0`.

### Changed

- Revert change to fix git-checkout with special characters in branch names [#122](https://github.com/stefanzweifel/git-auto-commit-action/pull/122)

## [v4.7.1](https://github.com/stefanzweifel/git-auto-commit-action/compare/v4.7.0...v4.7.1) - 2020-10-22

### Removed

- Remove `checkout_options` as it broke everything [#120](https://github.com/stefanzweifel/git-auto-commit-action/pull/120/)

## [v4.7.0](https://github.com/stefanzweifel/git-auto-commit-action/compare/v4.6.0...v4.7.0) - 2020-10-21

### Added

- Add `checkout_options` [#115](https://github.com/stefanzweifel/git-auto-commit-action/pull/115)

## [v4.6.0](https://github.com/stefanzweifel/git-auto-commit-action/compare/v4.5.1...v4.6.0) - 2020-10-11

### Changed

- Make "commit_message" optional and set default commit message to "Apply automatic changes" [#103](https://github.com/stefanzweifel/git-auto-commit-action/issues/103), [#110](https://github.com/stefanzweifel/git-auto-commit-action/pull/110)

### Fixes

- Better support for branch names with special characters in them [#108](https://github.com/stefanzweifel/git-auto-commit-action/pull/108)

## [v4.5.1](https://github.com/stefanzweifel/git-auto-commit-action/compare/v4.5.0...v4.5.1) - 2020-09-11

### Removed

- Remove orphan branch feature added in #95 which broke stuff [#98](https://github.com/stefanzweifel/git-auto-commit-action/pull/98)

## [v4.5.0](https://github.com/stefanzweifel/git-auto-commit-action/compare/v4.4.1...v4.5.0) - 2020-09-10

### Added

- Create orphan branch if branch name does not exist [#95](https://github.com/stefanzweifel/git-auto-commit-action/pull/95)

## [v4.4.1](https://github.com/stefanzweifel/git-auto-commit-action/compare/v4.4.0...v4.4.1) - 2020-08-16

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
