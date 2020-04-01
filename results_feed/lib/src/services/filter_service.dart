// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:html';

class Filter {
  final List<String> configurations;
  final List<String> configurationGroups;
  final bool showLatestFailures;
  final bool showUnapprovedOnly;

  const Filter._(this.configurations, this.configurationGroups,
      this.showLatestFailures, this.showUnapprovedOnly);
  Filter(this.configurations, this.configurationGroups, this.showLatestFailures,
      this.showUnapprovedOnly);

  static const defaultFilter =
      Filter._([], [], defaultShowLatestFailures, defaultShowUnapprovedOnly);

  Filter copy(
          {List<String> configurations,
          List<String> configurationGroups,
          bool showLatestFailures,
          bool showUnapprovedOnly}) =>
      Filter(
          configurations ?? this.configurations,
          configurationGroups ?? this.configurationGroups,
          showLatestFailures ?? this.showLatestFailures,
          showUnapprovedOnly ?? this.showUnapprovedOnly);

  String fragment() => [
        if (showLatestFailures != defaultShowLatestFailures)
          'showLatestFailures=$showLatestFailures',
        if (showUnapprovedOnly != defaultShowUnapprovedOnly)
          'showUnapprovedOnly=$showUnapprovedOnly',
        if (configurations.isNotEmpty)
          'configurations=${configurations.join(',')}',
        if (configurationGroups.isNotEmpty)
          'configurationGroups=${configurationGroups.join(',')}'
      ].join('&');

  void updateUrl() {
    window.location.hash = fragment();
  }

  factory Filter.fromUrl() {
    final fragment = Uri.parse(window.location.href).fragment;
    var result = defaultFilter;
    if (fragment.isEmpty) return result;
    for (final setting in fragment.split('&')) {
      final key = setting.split('=').first;
      final value = setting.split('=').last;
      if (key == 'showLatestFailures') {
        result = result.copy(showLatestFailures: value == 'true');
      } else if (key == 'showUnapprovedOnly') {
        result = result.copy(showUnapprovedOnly: value == 'true');
      } else if (key == 'configurations') {
        final configurations = value.split(',');
        result = result.copy(configurations: configurations);
      } else if (key == 'configurationGroups') {
        final configurationGroups = value.split(',');
        result = result.copy(configurationGroups: configurationGroups);
      }
    }
    return result;
  }

  static const defaultShowLatestFailures = false;
  static const defaultShowUnapprovedOnly = false;
  static const allConfigurationGroups = <String>[
    'analyzer',
    'app_jitk',
    'cfe',
    'dart2js',
    'dartdevc',
    'dartdevk',
    'dartk',
    'dartkb',
    'dartkp',
    'fasta',
    'unittest',
    'vm'
  ];
}

class FilterService {
  FilterService();

  Filter filter = Filter.fromUrl();
}
