# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).
Release dates are based on the [Hex.pm release history](https://hex.pm/packages/similarity).

## [Unreleased]

### Changed

- Expanded the documentation and test coverage.
- Added a GitHub Actions test workflow.
- Updated the ExDoc development dependency to 0.34.
- Improved Simhash performance by accumulating hash votes in one pass and replacing
  expanded fixed-size bit conversions with shared conversion functions.
- Improved cosine pair comparisons by indexing attributes before matching them.

### Fixed

- Corrected a typo in the `Similarity.Cosine` module documentation.

## [0.4.0] - 2022-12-29

### Added

- Added configurable `:siphash`, `:md5`, and `:sha256` hash functions for Simhash.
- Added the `:binary` return type to `Similarity.Simhash.hash/2`.

### Changed

- Changed `Similarity.Simhash.hash` to accept `:ngram_size`, `:hash_function`, and
  `:return_type` as keyword options.

## [0.3.0] - 2022-12-28

### Changed

- Replaced the `:integer` Simhash return type with explicit `:int64_unsigned` and
  `:int64_signed` return types.

## [0.2.4] - 2022-12-27

### Fixed

- Added an `ArgumentError` when either string passed to the Sorensen-Dice
  implementation is shorter than the configured n-gram size.

## [0.2.3] - 2022-12-27

### Added

- Added Sorensen-Dice similarity for strings, lists, and `MapSet` values through
  `Similarity.SorensenDice` and `Similarity.sorensen_dice/3`.

## [0.2.2] - 2022-12-27

### Added

- Added an integer return type to `Similarity.Simhash.hash` while retaining the
  list-of-bits return type.
- Added an `ArgumentError` when a string passed to Simhash is shorter than the
  configured n-gram size.

### Changed

- Updated project dependencies and added Benchee as a development dependency.

## [0.2.1] - 2020-05-22

### Fixed

- Fixed Simhash binary-to-integer conversion so the result is always 64 bits.

## [0.2.0] - 2019-10-15

### Added

- Added Simhash string similarity and hash generation using character n-grams and
  SipHash.
- Added Simhash tests, documentation, and benchmark results.

## [0.1.0] - 2019-06-18

### Added

- Initial release.
- Added cosine similarity, cosine similarity scaled by the square root of vector
  length, Euclidean dot product, and Euclidean magnitude calculations.
- Added `Similarity.Cosine` for accumulating IDs and their attributes, comparing
  entries, and streaming all unique similarity pairs.

[Unreleased]: https://github.com/preciz/similarity/compare/v0.4.0...HEAD
[0.4.0]: https://github.com/preciz/similarity/compare/v0.3.0...v0.4.0
[0.3.0]: https://github.com/preciz/similarity/compare/v0.2.4...v0.3.0
[0.2.4]: https://github.com/preciz/similarity/compare/v0.2.3...v0.2.4
[0.2.3]: https://github.com/preciz/similarity/compare/v0.2.2...v0.2.3
[0.2.2]: https://github.com/preciz/similarity/compare/v0.2.1...v0.2.2
[0.2.1]: https://github.com/preciz/similarity/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/preciz/similarity/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/preciz/similarity/releases/tag/v0.1.0
