import 'dart:io';

import 'package:prism_sketch/prism_sketch.dart';

void main(List<String> args) {
  if (args.isEmpty || args.contains('-h') || args.contains('--help')) {
    _printUsage();
    exit(args.isEmpty ? 64 : 0);
  }

  if (args.contains('--list')) {
    _printSupported();
    exit(0);
  }

  final specArg = args.where((a) => !a.startsWith('-')).join(' ').trim();
  if (specArg.isEmpty) {
    stderr.writeln('Error: no spec given. Try:');
    stderr.writeln('  prism_sketch "login page: email field, password field"');
    exit(64);
  }

  final outIndex = args.indexOf('--out');
  final outPath =
      outIndex >= 0 && outIndex + 1 < args.length ? args[outIndex + 1] : null;

  final spec = SpecParser().parse(specArg);
  final code = CodeGenerator().generate(spec);

  if (outPath != null) {
    File(outPath).writeAsStringSync(code);
    stderr.writeln('Wrote ${spec.className} to $outPath');
    exit(0);
  }

  stdout.writeln(code);
}

void _printUsage() {
  stdout.writeln('''
prism_sketch — wireframe-to-code for the Prism ecosystem.

Usage:
  prism_sketch "<spec>" [--out file.dart]

Examples:
  prism_sketch "login page: email field, password field, sign in button"
  prism_sketch "settings screen with dark mode switch and language tile"
  prism_sketch "dashboard with stat tile, bar chart, donut chart"
  prism_sketch "profile page: avatar, timeline, empty state"

Options:
  --out <path>   Write the generated file instead of printing
  --list         Show everything prism_sketch understands
  -h, --help     This message
''');
}

void _printSupported() {
  stdout.writeln('''
Screen types (detected from keywords):
  login / signup / register   -> auth screen
  settings                    -> settings page
  dashboard / analytics       -> charts page
  chat / assistant            -> AI chat page
  list / feed / inbox         -> list page
  detail / article            -> detail page
  (anything else)             -> plain page

Components:
  email field, password field, phone field, OTP field
  text field, search field
  button, FAB
  switch / toggle, checkbox, slider, dropdown
  rating, calendar / date
  bar chart, line chart, sparkline / trend, donut chart
  stat tile / KPI, card, tile / item
  banner, timeline, avatar, progress, empty state
  image, file picker, photo picker
''');
}
