// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:html' show window;

import 'package:angular/angular.dart';
import 'package:angular_components/material_button/material_button.dart';
import 'package:angular_components/material_input/material_input.dart';
import 'package:angular_components/material_input/material_input_multiline.dart';
import 'package:angular_forms/angular_forms.dart' show formDirectives;

import 'blamelist_component.dart';
import 'blamelist_picker.dart';
import '../model/commit.dart';
import '../model/comment.dart';
import '../services/firestore_service.dart';
import '../services/filter_service.dart';
import 'results_panel.dart';
import 'results_selector_panel.dart';

@Component(
    selector: 'dart-commit',
    directives: [
      coreDirectives,
      formDirectives,
      materialInputDirectives,
      MaterialButtonComponent,
      MaterialMultilineInputComponent,
      BlamelistComponent,
      BlamelistPicker,
      ResultsPanel,
      ResultsSelectorPanel,
    ],
    templateUrl: 'commit_component.html',
    styleUrls: ([
      'commit_component.css',
      'package:angular_components/css/mdc_web/card/mdc-card.scss.css'
    ]))
class CommitComponent {
  CommitComponent(this.firestoreService);

  @Input()
  FirestoreService firestoreService;

  @Input()
  Filter filter;

  @Input()
  ChangeGroup changeGroup;

  bool collapsedBlamelist = true;
  int resultLimit = 10;

  bool chooseCommit = false;
  bool approving = false;

  bool get approveEnabled =>
      firestoreService.isLoggedIn &&
      changeGroup.latestChanges.flat
          .any((change) => change.result != change.expected);
  final selected = Set<Change>();
  Commit selectedCommit;
  String commentText;

  Future pinCommit() {
    return firestoreService.pinResults(selectedCommit.index, [
      for (Change result in selected) result.id
    ]).then((_) => window.location.reload());
  }

  Future<void> approve(bool approval) async {
    approving = false;
    for (Change result in selected) {
      result.approved = approval ?? result.approved;
    }

    await firestoreService.saveApprovals(
        approve: approval,
        resultIds: [for (Change result in selected) result.id]);
    final comment = Comment.fromDocument(await firestoreService.saveComment(
        approval,
        commentText,
        changeGroup.comments.isEmpty
            ? null
            : changeGroup.comments.last.baseComment ??
                changeGroup.comments.last.id,
        resultIds: [for (Change result in selected) result.id],
        blamelistStart: changeGroup.range.start,
        blamelistEnd: changeGroup.range.end));
    // The list changeGroup.comments is the actual list object stored in the
    // applications-level map of all comments, AppComponent.comments.
    // So changing it here changes it everywhere.
    changeGroup.comments
      ..add(comment)
      ..sort();
  }
}
