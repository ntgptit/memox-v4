import 'package:equatable/equatable.dart';
import 'package:memox_v4/core/error/failure.dart';
import 'package:memox_v4/core/error/result.dart';
import 'package:memox_v4/domain/entities/ids.dart';

/// A library node (`Bộ thẻ`) in the self-nesting deck tree. A deck can hold cards
/// directly and/or child decks (a mixed node, BR-2). A root deck has no parent.
///
/// The tree shape is a single [parentId] link (schema `parent_deck_id`); the
/// recursive subtree aggregation (BR-5) and cycle-free moves (BR-3) are operations
/// that live in the deck use cases, not on this entity. Per the deck spec the row
/// carries no created/last-studied columns, so this entity has none.
class Deck extends Equatable {
  const Deck._({required this.id, required this.name, this.parentId});

  /// Validated construction — the name is required and non-empty (BR-1).
  static Result<Deck> create({
    required DeckId id,
    required String name,
    DeckId? parentId,
  }) {
    if (name.trim().isEmpty) {
      return const Err(ValidationFailure('A deck name is required'));
    }
    return Ok(Deck._(id: id, name: name, parentId: parentId));
  }

  final DeckId id;
  final String name;

  /// The parent deck, or null for a root deck.
  final DeckId? parentId;

  bool get isRoot => parentId == null;

  @override
  List<Object?> get props => [id.value, name, parentId?.value];
}
