/// Wireframe-to-code for the Prism ecosystem.
///
/// Describe a screen in plain English and get idiomatic `prism_kit` code.
///
/// The library exposes the two stages separately so you can build your own
/// front ends (editors, plugins, bots) on top:
///
/// - [SpecParser] turns an English spec into a [SketchSpec].
/// - [CodeGenerator] renders a [SketchSpec] as a complete Dart file.
library;

export 'src/generator.dart';
export 'src/parser.dart';
export 'src/spec.dart';
