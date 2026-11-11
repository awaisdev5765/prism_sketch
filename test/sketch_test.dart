import 'package:prism_sketch/prism_sketch.dart';
import 'package:test/test.dart';

void main() {
  late SpecParser parser;
  late CodeGenerator generator;

  setUp(() {
    parser = SpecParser();
    generator = CodeGenerator();
  });

  group('SpecParser', () {
    test('detects auth screens', () {
      final spec = parser.parse('login page: email field, password field');
      expect(spec.kind, ScreenKind.auth);
      expect(spec.className, 'LoginView');
      expect(spec.title, 'Login');
    });

    test('detects settings screens', () {
      final spec = parser.parse('settings screen');
      expect(spec.kind, ScreenKind.settings);
      expect(spec.className, 'SettingsView');
    });

    test('detects dashboards', () {
      final spec = parser.parse('dashboard with stats and charts');
      expect(spec.kind, ScreenKind.dashboard);
    });

    test('extracts component kinds from the spec body', () {
      final spec = parser.parse(
        'login page: email field, password field, sign in button',
      );
      final kinds = spec.components.map((c) => c.kind).toList();
      expect(kinds, containsAll(['email_field', 'password_field', 'button']));
    });

    test('labels switches from their context', () {
      final spec = parser.parse(
        'settings screen with dark mode switch and language tile',
      );
      final switchComponent = spec.components
          .firstWhere((c) => c.kind == 'switch');
      expect(switchComponent.label, 'Dark Mode');
    });

    test('applies sensible defaults when no components are listed', () {
      final spec = parser.parse('login page');
      final kinds = spec.components.map((c) => c.kind).toList();
      expect(kinds, containsAll(['email_field', 'password_field']));
    });

    test('unknown spec still yields a valid page', () {
      final spec = parser.parse('banana rocket ship');
      expect(spec.kind, ScreenKind.page);
      expect(spec.components, isNotEmpty);
      expect(spec.className, 'HomePage');
    });
  });

  group('CodeGenerator', () {
    test('generates a complete Dart file with prism_kit import', () {
      final code = generator.generate(
        parser.parse('login page: email field, password field, submit button'),
      );
      expect(code, contains("import 'package:prism_kit/prism.dart';"));
      expect(code, contains('class LoginView extends StatefulWidget'));
      expect(code, contains('PrismTextField.email'));
      expect(code, contains('PrismPasswordField'));
    });

    test('generates state fields for interactive components', () {
      final code = generator.generate(
        parser.parse('settings screen with dark mode switch'),
      );
      expect(code, contains('bool _darkModeEnabled = false;'));
      expect(code, contains('_darkModeEnabled = v'));
    });

    test('stateless when nothing interactive is requested', () {
      final code = generator.generate(
        parser.parse('profile page: avatar, timeline'),
      );
      expect(code, contains('extends StatelessWidget'));
      expect(code, contains('PrismAvatar'));
      expect(code, contains('PrismTimeline'));
    });

    test('chart components are card-wrapped', () {
      final code = generator.generate(
        parser.parse('dashboard with bar chart, donut chart'),
      );
      expect(code, contains('PrismBarChart'));
      expect(code, contains('PrismDonutChart'));
      expect(code, contains('PrismCard('));
    });

    test('FAB request becomes a Scaffold FAB', () {
      final code = generator.generate(parser.parse('list page with FAB'));
      expect(code, contains('floatingActionButton:'));
    });

    test('output is deterministic', () {
      final spec = parser.parse('settings screen with dark mode switch');
      expect(generator.generate(spec), generator.generate(spec));
    });
  });
}
