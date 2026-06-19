import 'dart:convert';

import 'package:flutter/services.dart';

class OpeningMatch {
  const OpeningMatch({required this.eco, required this.name});

  final String eco;
  final String name;
}

class OpeningTrie {
  final _OpeningTrieNode _root = _OpeningTrieNode();
  bool _loaded = false;

  Future<OpeningTrie> load() async {
    if (_loaded) return this;
    final jsonText = await rootBundle.loadString('assets/openings.json');
    final entries = jsonDecode(jsonText) as List<dynamic>;
    for (final entry in entries.cast<Map<String, dynamic>>()) {
      insert(
        (entry['moves'] as List<dynamic>).cast<String>(),
        OpeningMatch(eco: entry['eco'] as String, name: entry['name'] as String),
      );
    }
    _loaded = true;
    return this;
  }

  void insert(List<String> moves, OpeningMatch match) {
    var node = _root;
    for (final move in moves) {
      node = node.children.putIfAbsent(move, _OpeningTrieNode.new);
    }
    node.match = match;
  }

  OpeningMatch? lookup(List<String> moves) {
    var node = _root;
    OpeningMatch? best;
    for (final move in moves) {
      final next = node.children[move];
      if (next == null) break;
      node = next;
      best = node.match ?? best;
    }
    return best;
  }
}

class _OpeningTrieNode {
  final Map<String, _OpeningTrieNode> children = <String, _OpeningTrieNode>{};
  OpeningMatch? match;
}
