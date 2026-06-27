import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/domain/entities/deck.dart';
import 'package:memox_v4/domain/models/deck_node.dart';
import 'package:memox_v4/domain/models/deck_stats.dart';
import 'package:memox_v4/domain/types/sort.dart';
import 'package:memox_v4/domain/usecases/deck/sort_deck_nodes.dart';

DeckNode _node(int id, String name, {int? lastStudied}) => DeckNode(
  deck: Deck(id: id, pairId: 1, name: name, orderIndex: 0),
  stats: DeckStats(lastStudiedAt: lastStudied),
);

void main() {
  const sort = SortDeckNodesUseCase();
  final nodes = <DeckNode>[
    _node(2, 'Banana', lastStudied: 300),
    _node(1, 'apple'),
    _node(3, 'cherry', lastStudied: 100),
  ];

  List<int> ids(List<DeckNode> result) =>
      result.map((n) => n.deck.id).toList(growable: false);

  test('D-023: alphabetical ascending is case-insensitive', () {
    final result = sort.call(
      nodes,
      by: SortBy.alphabet,
      direction: SortDirection.asc,
    );
    expect(result.map((n) => n.deck.name).toList(), <String>[
      'apple',
      'Banana',
      'cherry',
    ]);
  });

  test('D-023: alphabetical descending', () {
    final result = sort.call(
      nodes,
      by: SortBy.alphabet,
      direction: SortDirection.desc,
    );
    expect(result.map((n) => n.deck.name).toList(), <String>[
      'cherry',
      'Banana',
      'apple',
    ]);
  });

  test('D-023: createdAt uses the id proxy', () {
    expect(
      ids(sort.call(nodes, by: SortBy.createdAt, direction: SortDirection.asc)),
      <int>[1, 2, 3],
    );
    expect(
      ids(
        sort.call(nodes, by: SortBy.createdAt, direction: SortDirection.desc),
      ),
      <int>[3, 2, 1],
    );
  });

  test('D-023: lastStudied ascending puts never-studied first', () {
    expect(
      ids(
        sort.call(nodes, by: SortBy.lastStudied, direction: SortDirection.asc),
      ),
      <int>[1, 3, 2],
    );
  });

  test('children are sorted recursively', () {
    final tree = <DeckNode>[
      DeckNode(
        deck: const Deck(id: 1, pairId: 1, name: 'Root', orderIndex: 0),
        stats: const DeckStats(),
        children: <DeckNode>[_node(3, 'zeta'), _node(2, 'alpha')],
      ),
    ];
    final sorted = sort.call(
      tree,
      by: SortBy.alphabet,
      direction: SortDirection.asc,
    );
    expect(sorted.first.children.map((n) => n.deck.name).toList(), <String>[
      'alpha',
      'zeta',
    ]);
  });
}
