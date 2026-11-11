# prism_sketch

Wireframe-to-code for the Prism ecosystem.

Describe a screen in plain English. Get idiomatic `prism_kit` Flutter code —
state fields, component wiring, tokens — as a complete, compilable file you
paste in and edit. Pure Dart, zero dependencies, one command.

```bash
$ prism_sketch "login page: email field, password field, sign in button"
```

```dart
class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          PrismTextField.email(name: 'email', label: 'Email'),
          PrismPasswordField(
            common: const PrismFieldCommon(
              name: 'password',
              label: 'Password',
            ),
          ),
          FilledButton(
            onPressed: () {}, // TODO: submit
            child: const Text('Sign In'),
          ),
        ],
      ),
    );
  }
}
```

## Install

```bash
dart pub global activate prism_sketch
```

## Usage

```bash
prism_sketch "settings screen with dark mode switch and language dropdown"
prism_sketch "dashboard with stat tile, bar chart, donut chart" --out dashboard.dart
prism_sketch --list          # everything it understands
```

## What it understands

**Screens** (detected from keywords): login/signup, settings, dashboard,
chat, list, detail, and plain pages.

**Components:** email/password/phone/OTP fields, search, buttons, FAB,
switch, checkbox, slider, dropdown, rating, calendar, bar/line/donut charts,
stat tiles, cards, tiles, banners, timelines, avatars, progress, empty
states, image/file pickers — 30+ in total, all rendered as prism_kit
components that read `PrismTokens` and `PrismColors`.

If you list no components, prism_sketch picks sensible ones for the screen
type. Generated code is deterministic, so it is snapshot-testable and safe
in CI.

## Philosophy

prism_sketch proposes, you dispose. It writes the repetitive 60% —
imports, state fields, component wiring, layout scaffolding — and leaves
TODO markers exactly where your business logic goes. Every generated file
was verified to compile against prism_kit.

## Library use

The two stages are separate APIs, so you can build editors, IDE plugins or
chat bots on top:

```dart
final spec = SpecParser().parse('dashboard with stat tile, bar chart');
final code = CodeGenerator().generate(spec);
```

## License

MIT — see [LICENSE](LICENSE).
