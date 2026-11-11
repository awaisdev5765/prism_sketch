/// The parsed form of a sketch spec.
library;

/// The kind of screen to scaffold.
enum ScreenKind {
  /// A bare page with the listed components.
  page,
  /// Login/signup-style auth screen: centred card with fields.
  auth,
  /// Grouped settings page.
  settings,
  /// List screen.
  list,
  /// Analytics screen with charts.
  dashboard,
  /// Streaming chat screen.
  chat,
  /// A detail/content page with an app bar and rich body.
  detail,
}

/// One component the user asked for.
class SpecComponent {
  /// Creates a component occurrence.
  const SpecComponent(this.kind, {this.label});
  /// Canonical component key, e.g. `email_field`.
  final String kind;
  /// Optional label derived from the spec text, e.g. `dark mode`.
  final String? label;
  @override
  String toString() => label == null ? kind : '$kind($label)';
}

/// A parsed sketch.
class SketchSpec {
  /// Creates a parsed sketch.
  const SketchSpec({
    required this.kind,
    required this.className,
    required this.components,
    required this.title,
  });
  /// The screen type.
  final ScreenKind kind;
  /// Generated class name, e.g. `LoginPageView`.
  final String className;
  /// Components in the order mentioned.
  final List<SpecComponent> components;
  /// Human title for the app bar, e.g. `Login`.
  final String title;
}
