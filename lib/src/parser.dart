import 'spec.dart';

/// Parses an English sketch spec into a [SketchSpec].
///
/// Deliberately simple keyword matching over a normalised string: this is a
/// *sketch* tool that proposes code a developer then edits, not a
/// natural-language compiler. Deterministic and testable.
class SpecParser {
  /// Parses [spec]. Never throws; unknown words are ignored.
  SketchSpec parse(String spec) {
    final normalised = _normalise(spec);
    final kind = _screenKind(normalised);
    final title = _title(normalised, kind);
    final className = _className(title, kind);
    final components = _components(normalised, kind);
    return SketchSpec(
      kind: kind,
      className: className,
      components: components,
      title: title,
    );
  }

  String _normalise(String spec) {
    var s = spec.toLowerCase().trim();
    s = s.replaceAll(RegExp(r'[^\w\s,:]'), ' ');
    s = s.replaceAll(RegExp(r'\s+'), ' ');
    return s;
  }

  ScreenKind _screenKind(String s) {
    if (s.contains('login') || s.contains('sign in') || s.contains('signup') ||
        s.contains('sign up') || s.contains('register')) {
      return ScreenKind.auth;
    }
    if (s.contains('setting')) return ScreenKind.settings;
    if (s.contains('dashboard') || s.contains('analytics') ||
        s.contains('stats')) {
      return ScreenKind.dashboard;
    }
    if (s.contains('chat') || s.contains('assistant')) {
      return ScreenKind.chat;
    }
    if (s.contains('list') || s.contains('feed') || s.contains('inbox')) {
      return ScreenKind.list;
    }
    if (s.contains('detail') || s.contains('article') || s.contains('post')) {
      return ScreenKind.detail;
    }
    return ScreenKind.page;
  }

  String _title(String s, ScreenKind kind) {
    const known = {
      'login': 'Login',
      'sign in': 'Sign in',
      'signup': 'Sign up',
      'sign up': 'Sign up',
      'register': 'Register',
      'settings': 'Settings',
      'dashboard': 'Dashboard',
      'chat': 'Chat',
      'assistant': 'Assistant',
      'profile': 'Profile',
      'feed': 'Feed',
      'inbox': 'Inbox',
    };
    for (final entry in known.entries) {
      if (s.contains(entry.key)) return entry.value;
    }
    return switch (kind) {
      ScreenKind.auth => 'Sign in',
      ScreenKind.settings => 'Settings',
      ScreenKind.dashboard => 'Dashboard',
      ScreenKind.chat => 'Chat',
      ScreenKind.list => 'List',
      ScreenKind.detail => 'Details',
      ScreenKind.page => 'Home',
    };
  }

  String _className(String title, ScreenKind kind) {
    final words = title
        .split(RegExp(r'\s+'))
        .map((w) => w[0].toUpperCase() + w.substring(1))
        .join();
    return switch (kind) {
      ScreenKind.page => '${words}Page',
      _ => '${words}View',
    };
  }

  List<SpecComponent> _components(String s, ScreenKind kind) {
    // The part after the colon (or the whole string) is the component list.
    final afterColon = s.contains(':') ? s.substring(s.indexOf(':') + 1) : s;
    final body = afterColon
        .replaceAll(RegExp(r'\bwith\b'), ',')
        .replaceAll(' and ', ', ')
        .replaceAll(RegExp(r'\s+'), ' ');
    final parts = body
        .split(',')
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();

    final found = <SpecComponent>[];
    void add(String kind, [String? label]) =>
        found.add(SpecComponent(kind, label: label));

    for (final part in parts) {
      if (part.contains('email')) {
        add('email_field');
      } else if (part.contains('password')) {
        add('password_field');
      } else if (part.contains('phone') || part.contains('mobile')) {
        add('phone_field');
      } else if (part.contains('otp') || part.contains('pin')) {
        add('otp_field');
      } else if (part.contains('search')) {
        add('search_field');
      } else if ((part.contains('text') && part.contains('field')) ||
          part.contains('input')) {
        add('text_field', _labelOf(part, 'field'));
      } else if (part.contains('dropdown') || part.contains('select')) {
        add('dropdown', _labelOf(part, 'dropdown'));
      } else if (part.contains('slider')) {
        add('slider', _labelOf(part, 'slider'));
      } else if (part.contains('switch') || part.contains('toggle')) {
        add('switch', _labelOf(part, 'switch'));
      } else if (part.contains('checkbox')) {
        add('checkbox', _labelOf(part, 'checkbox'));
      } else if (part.contains('rating')) {
        add('rating');
      } else if (part.contains('calendar') || part.contains('date')) {
        add('calendar');
      } else if (part.contains('bar chart') || part.contains('bar graph')) {
        add('bar_chart');
      } else if (part.contains('line chart') || part.contains('sparkline') ||
          part.contains('trend')) {
        add('line_chart');
      } else if (part.contains('donut') || part.contains('pie')) {
        add('donut_chart');
      } else if (part.contains('stat') || part.contains('kpi')) {
        add('stat_tile');
      } else if (part.contains('chart')) {
        add('bar_chart');
      } else if (part.contains('button') || part.contains('cta')) {
        add('button', _labelOf(part, 'button'));
      } else if (part.contains('fab')) {
        add('fab');
      } else if (part.contains('card')) {
        add('card');
      } else if (part.contains('tile') || part.contains('item')) {
        add('tile');
      } else if (part.contains('banner')) {
        add('banner');
      } else if (part.contains('timeline')) {
        add('timeline');
      } else if (part.contains('avatar')) {
        add('avatar');
      } else if (part.contains('progress')) {
        add('progress');
      } else if (part.contains('empty')) {
        add('empty_state');
      } else if (part.contains('image')) {
        add('image');
      } else if (part.contains('file')) {
        add('file_picker');
      } else if (part.contains('photo')) {
        add('image_picker');
      }
    }

    if (found.isEmpty) {
      switch (kind) {
        case ScreenKind.auth:
          add('email_field');
          add('password_field');
          add('button', 'Sign in');
        case ScreenKind.settings:
          add('switch', 'dark mode');
          add('switch', 'notifications');
          add('tile', 'language');
        case ScreenKind.dashboard:
          add('stat_tile');
          add('bar_chart');
          add('donut_chart');
        case ScreenKind.list:
          add('search_field');
          add('tile');
        case ScreenKind.chat:
          add('chat_view');
        case ScreenKind.detail:
          add('card');
          add('tile');
        case ScreenKind.page:
          add('card');
      }
    }
    return found;
  }

  /// Strips the generic word from a phrase so "dark mode switch" labels the
  /// switch "dark mode".
  String? _labelOf(String part, String generic) {
    final label = part
        .replaceAll(RegExp('\\b$generic\\b'), '')
        .replaceAll(RegExp(r'\bfield\b|\badd\b|\ba\b|\ban\b|\bthe\b'), '')
        .trim();
    if (label.isEmpty) return null;
    return label
        .split(' ')
        .map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }
}
