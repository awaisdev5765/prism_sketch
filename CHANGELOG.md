# Changelog

## 0.1.0

Initial release.

- SpecParser: English spec -> SketchSpec (screen kinds, components, labels)
- CodeGenerator: SketchSpec -> complete, compilable prism_kit Dart files with
  state fields, component wiring, TODO markers and deterministic output
- CLI: `prism_sketch "<spec>" [--out file.dart]`, `--list`, `--help`
- 30+ supported components, 7 screen types, verified to compile against
  prism_kit 2.0.0
- 13 tests
