// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class LanguagePair extends Table
    with TableInfo<LanguagePair, LanguagePairData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  LanguagePair(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL PRIMARY KEY AUTOINCREMENT',
  );
  static const VerificationMeta _sourceLangMeta = const VerificationMeta(
    'sourceLang',
  );
  late final GeneratedColumn<String> sourceLang = GeneratedColumn<String>(
    'source_lang',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _targetLangMeta = const VerificationMeta(
    'targetLang',
  );
  late final GeneratedColumn<String> targetLang = GeneratedColumn<String>(
    'target_lang',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _orderIndexMeta = const VerificationMeta(
    'orderIndex',
  );
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
    'order_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sourceLang,
    targetLang,
    orderIndex,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'language_pair';
  @override
  VerificationContext validateIntegrity(
    Insertable<LanguagePairData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('source_lang')) {
      context.handle(
        _sourceLangMeta,
        sourceLang.isAcceptableOrUnknown(data['source_lang']!, _sourceLangMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceLangMeta);
    }
    if (data.containsKey('target_lang')) {
      context.handle(
        _targetLangMeta,
        targetLang.isAcceptableOrUnknown(data['target_lang']!, _targetLangMeta),
      );
    } else if (isInserting) {
      context.missing(_targetLangMeta);
    }
    if (data.containsKey('order_index')) {
      context.handle(
        _orderIndexMeta,
        orderIndex.isAcceptableOrUnknown(data['order_index']!, _orderIndexMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LanguagePairData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LanguagePairData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sourceLang: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_lang'],
      )!,
      targetLang: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_lang'],
      )!,
      orderIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order_index'],
      )!,
    );
  }

  @override
  LanguagePair createAlias(String alias) {
    return LanguagePair(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class LanguagePairData extends DataClass
    implements Insertable<LanguagePairData> {
  final int id;
  final String sourceLang;
  final String targetLang;
  final int orderIndex;
  const LanguagePairData({
    required this.id,
    required this.sourceLang,
    required this.targetLang,
    required this.orderIndex,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['source_lang'] = Variable<String>(sourceLang);
    map['target_lang'] = Variable<String>(targetLang);
    map['order_index'] = Variable<int>(orderIndex);
    return map;
  }

  LanguagePairCompanion toCompanion(bool nullToAbsent) {
    return LanguagePairCompanion(
      id: Value(id),
      sourceLang: Value(sourceLang),
      targetLang: Value(targetLang),
      orderIndex: Value(orderIndex),
    );
  }

  factory LanguagePairData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LanguagePairData(
      id: serializer.fromJson<int>(json['id']),
      sourceLang: serializer.fromJson<String>(json['source_lang']),
      targetLang: serializer.fromJson<String>(json['target_lang']),
      orderIndex: serializer.fromJson<int>(json['order_index']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'source_lang': serializer.toJson<String>(sourceLang),
      'target_lang': serializer.toJson<String>(targetLang),
      'order_index': serializer.toJson<int>(orderIndex),
    };
  }

  LanguagePairData copyWith({
    int? id,
    String? sourceLang,
    String? targetLang,
    int? orderIndex,
  }) => LanguagePairData(
    id: id ?? this.id,
    sourceLang: sourceLang ?? this.sourceLang,
    targetLang: targetLang ?? this.targetLang,
    orderIndex: orderIndex ?? this.orderIndex,
  );
  LanguagePairData copyWithCompanion(LanguagePairCompanion data) {
    return LanguagePairData(
      id: data.id.present ? data.id.value : this.id,
      sourceLang: data.sourceLang.present
          ? data.sourceLang.value
          : this.sourceLang,
      targetLang: data.targetLang.present
          ? data.targetLang.value
          : this.targetLang,
      orderIndex: data.orderIndex.present
          ? data.orderIndex.value
          : this.orderIndex,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LanguagePairData(')
          ..write('id: $id, ')
          ..write('sourceLang: $sourceLang, ')
          ..write('targetLang: $targetLang, ')
          ..write('orderIndex: $orderIndex')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, sourceLang, targetLang, orderIndex);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LanguagePairData &&
          other.id == this.id &&
          other.sourceLang == this.sourceLang &&
          other.targetLang == this.targetLang &&
          other.orderIndex == this.orderIndex);
}

class LanguagePairCompanion extends UpdateCompanion<LanguagePairData> {
  final Value<int> id;
  final Value<String> sourceLang;
  final Value<String> targetLang;
  final Value<int> orderIndex;
  const LanguagePairCompanion({
    this.id = const Value.absent(),
    this.sourceLang = const Value.absent(),
    this.targetLang = const Value.absent(),
    this.orderIndex = const Value.absent(),
  });
  LanguagePairCompanion.insert({
    this.id = const Value.absent(),
    required String sourceLang,
    required String targetLang,
    this.orderIndex = const Value.absent(),
  }) : sourceLang = Value(sourceLang),
       targetLang = Value(targetLang);
  static Insertable<LanguagePairData> custom({
    Expression<int>? id,
    Expression<String>? sourceLang,
    Expression<String>? targetLang,
    Expression<int>? orderIndex,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sourceLang != null) 'source_lang': sourceLang,
      if (targetLang != null) 'target_lang': targetLang,
      if (orderIndex != null) 'order_index': orderIndex,
    });
  }

  LanguagePairCompanion copyWith({
    Value<int>? id,
    Value<String>? sourceLang,
    Value<String>? targetLang,
    Value<int>? orderIndex,
  }) {
    return LanguagePairCompanion(
      id: id ?? this.id,
      sourceLang: sourceLang ?? this.sourceLang,
      targetLang: targetLang ?? this.targetLang,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sourceLang.present) {
      map['source_lang'] = Variable<String>(sourceLang.value);
    }
    if (targetLang.present) {
      map['target_lang'] = Variable<String>(targetLang.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LanguagePairCompanion(')
          ..write('id: $id, ')
          ..write('sourceLang: $sourceLang, ')
          ..write('targetLang: $targetLang, ')
          ..write('orderIndex: $orderIndex')
          ..write(')'))
        .toString();
  }
}

class Deck extends Table with TableInfo<Deck, DeckData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Deck(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL PRIMARY KEY AUTOINCREMENT',
  );
  static const VerificationMeta _pairIdMeta = const VerificationMeta('pairId');
  late final GeneratedColumn<int> pairId = GeneratedColumn<int>(
    'pair_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL REFERENCES language_pair(id)ON DELETE CASCADE',
  );
  static const VerificationMeta _parentDeckIdMeta = const VerificationMeta(
    'parentDeckId',
  );
  late final GeneratedColumn<int> parentDeckId = GeneratedColumn<int>(
    'parent_deck_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'REFERENCES deck(id)ON DELETE CASCADE',
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _orderIndexMeta = const VerificationMeta(
    'orderIndex',
  );
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
    'order_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    pairId,
    parentDeckId,
    name,
    orderIndex,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'deck';
  @override
  VerificationContext validateIntegrity(
    Insertable<DeckData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('pair_id')) {
      context.handle(
        _pairIdMeta,
        pairId.isAcceptableOrUnknown(data['pair_id']!, _pairIdMeta),
      );
    } else if (isInserting) {
      context.missing(_pairIdMeta);
    }
    if (data.containsKey('parent_deck_id')) {
      context.handle(
        _parentDeckIdMeta,
        parentDeckId.isAcceptableOrUnknown(
          data['parent_deck_id']!,
          _parentDeckIdMeta,
        ),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('order_index')) {
      context.handle(
        _orderIndexMeta,
        orderIndex.isAcceptableOrUnknown(data['order_index']!, _orderIndexMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DeckData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DeckData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      pairId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pair_id'],
      )!,
      parentDeckId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}parent_deck_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      orderIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order_index'],
      )!,
    );
  }

  @override
  Deck createAlias(String alias) {
    return Deck(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class DeckData extends DataClass implements Insertable<DeckData> {
  final int id;
  final int pairId;
  final int? parentDeckId;
  final String name;
  final int orderIndex;
  const DeckData({
    required this.id,
    required this.pairId,
    this.parentDeckId,
    required this.name,
    required this.orderIndex,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['pair_id'] = Variable<int>(pairId);
    if (!nullToAbsent || parentDeckId != null) {
      map['parent_deck_id'] = Variable<int>(parentDeckId);
    }
    map['name'] = Variable<String>(name);
    map['order_index'] = Variable<int>(orderIndex);
    return map;
  }

  DeckCompanion toCompanion(bool nullToAbsent) {
    return DeckCompanion(
      id: Value(id),
      pairId: Value(pairId),
      parentDeckId: parentDeckId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentDeckId),
      name: Value(name),
      orderIndex: Value(orderIndex),
    );
  }

  factory DeckData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DeckData(
      id: serializer.fromJson<int>(json['id']),
      pairId: serializer.fromJson<int>(json['pair_id']),
      parentDeckId: serializer.fromJson<int?>(json['parent_deck_id']),
      name: serializer.fromJson<String>(json['name']),
      orderIndex: serializer.fromJson<int>(json['order_index']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'pair_id': serializer.toJson<int>(pairId),
      'parent_deck_id': serializer.toJson<int?>(parentDeckId),
      'name': serializer.toJson<String>(name),
      'order_index': serializer.toJson<int>(orderIndex),
    };
  }

  DeckData copyWith({
    int? id,
    int? pairId,
    Value<int?> parentDeckId = const Value.absent(),
    String? name,
    int? orderIndex,
  }) => DeckData(
    id: id ?? this.id,
    pairId: pairId ?? this.pairId,
    parentDeckId: parentDeckId.present ? parentDeckId.value : this.parentDeckId,
    name: name ?? this.name,
    orderIndex: orderIndex ?? this.orderIndex,
  );
  DeckData copyWithCompanion(DeckCompanion data) {
    return DeckData(
      id: data.id.present ? data.id.value : this.id,
      pairId: data.pairId.present ? data.pairId.value : this.pairId,
      parentDeckId: data.parentDeckId.present
          ? data.parentDeckId.value
          : this.parentDeckId,
      name: data.name.present ? data.name.value : this.name,
      orderIndex: data.orderIndex.present
          ? data.orderIndex.value
          : this.orderIndex,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DeckData(')
          ..write('id: $id, ')
          ..write('pairId: $pairId, ')
          ..write('parentDeckId: $parentDeckId, ')
          ..write('name: $name, ')
          ..write('orderIndex: $orderIndex')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, pairId, parentDeckId, name, orderIndex);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeckData &&
          other.id == this.id &&
          other.pairId == this.pairId &&
          other.parentDeckId == this.parentDeckId &&
          other.name == this.name &&
          other.orderIndex == this.orderIndex);
}

class DeckCompanion extends UpdateCompanion<DeckData> {
  final Value<int> id;
  final Value<int> pairId;
  final Value<int?> parentDeckId;
  final Value<String> name;
  final Value<int> orderIndex;
  const DeckCompanion({
    this.id = const Value.absent(),
    this.pairId = const Value.absent(),
    this.parentDeckId = const Value.absent(),
    this.name = const Value.absent(),
    this.orderIndex = const Value.absent(),
  });
  DeckCompanion.insert({
    this.id = const Value.absent(),
    required int pairId,
    this.parentDeckId = const Value.absent(),
    required String name,
    this.orderIndex = const Value.absent(),
  }) : pairId = Value(pairId),
       name = Value(name);
  static Insertable<DeckData> custom({
    Expression<int>? id,
    Expression<int>? pairId,
    Expression<int>? parentDeckId,
    Expression<String>? name,
    Expression<int>? orderIndex,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (pairId != null) 'pair_id': pairId,
      if (parentDeckId != null) 'parent_deck_id': parentDeckId,
      if (name != null) 'name': name,
      if (orderIndex != null) 'order_index': orderIndex,
    });
  }

  DeckCompanion copyWith({
    Value<int>? id,
    Value<int>? pairId,
    Value<int?>? parentDeckId,
    Value<String>? name,
    Value<int>? orderIndex,
  }) {
    return DeckCompanion(
      id: id ?? this.id,
      pairId: pairId ?? this.pairId,
      parentDeckId: parentDeckId ?? this.parentDeckId,
      name: name ?? this.name,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (pairId.present) {
      map['pair_id'] = Variable<int>(pairId.value);
    }
    if (parentDeckId.present) {
      map['parent_deck_id'] = Variable<int>(parentDeckId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DeckCompanion(')
          ..write('id: $id, ')
          ..write('pairId: $pairId, ')
          ..write('parentDeckId: $parentDeckId, ')
          ..write('name: $name, ')
          ..write('orderIndex: $orderIndex')
          ..write(')'))
        .toString();
  }
}

class Card extends Table with TableInfo<Card, CardData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Card(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL PRIMARY KEY AUTOINCREMENT',
  );
  static const VerificationMeta _deckIdMeta = const VerificationMeta('deckId');
  late final GeneratedColumn<int> deckId = GeneratedColumn<int>(
    'deck_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES deck(id)ON DELETE CASCADE',
  );
  static const VerificationMeta _termMeta = const VerificationMeta('term');
  late final GeneratedColumn<String> term = GeneratedColumn<String>(
    'term',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _genderMeta = const VerificationMeta('gender');
  late final GeneratedColumn<String> gender = GeneratedColumn<String>(
    'gender',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _audioRefMeta = const VerificationMeta(
    'audioRef',
  );
  late final GeneratedColumn<String> audioRef = GeneratedColumn<String>(
    'audio_ref',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _hiddenMeta = const VerificationMeta('hidden');
  late final GeneratedColumn<bool> hidden = GeneratedColumn<bool>(
    'hidden',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT FALSE',
    defaultValue: const CustomExpression('FALSE'),
  );
  static const VerificationMeta _orderIndexMeta = const VerificationMeta(
    'orderIndex',
  );
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
    'order_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _lastStudiedAtMeta = const VerificationMeta(
    'lastStudiedAt',
  );
  late final GeneratedColumn<int> lastStudiedAt = GeneratedColumn<int>(
    'last_studied_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    deckId,
    term,
    gender,
    audioRef,
    hidden,
    orderIndex,
    createdAt,
    lastStudiedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'card';
  @override
  VerificationContext validateIntegrity(
    Insertable<CardData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('deck_id')) {
      context.handle(
        _deckIdMeta,
        deckId.isAcceptableOrUnknown(data['deck_id']!, _deckIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deckIdMeta);
    }
    if (data.containsKey('term')) {
      context.handle(
        _termMeta,
        term.isAcceptableOrUnknown(data['term']!, _termMeta),
      );
    } else if (isInserting) {
      context.missing(_termMeta);
    }
    if (data.containsKey('gender')) {
      context.handle(
        _genderMeta,
        gender.isAcceptableOrUnknown(data['gender']!, _genderMeta),
      );
    }
    if (data.containsKey('audio_ref')) {
      context.handle(
        _audioRefMeta,
        audioRef.isAcceptableOrUnknown(data['audio_ref']!, _audioRefMeta),
      );
    }
    if (data.containsKey('hidden')) {
      context.handle(
        _hiddenMeta,
        hidden.isAcceptableOrUnknown(data['hidden']!, _hiddenMeta),
      );
    }
    if (data.containsKey('order_index')) {
      context.handle(
        _orderIndexMeta,
        orderIndex.isAcceptableOrUnknown(data['order_index']!, _orderIndexMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('last_studied_at')) {
      context.handle(
        _lastStudiedAtMeta,
        lastStudiedAt.isAcceptableOrUnknown(
          data['last_studied_at']!,
          _lastStudiedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CardData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CardData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      deckId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deck_id'],
      )!,
      term: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}term'],
      )!,
      gender: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gender'],
      ),
      audioRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}audio_ref'],
      ),
      hidden: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}hidden'],
      )!,
      orderIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order_index'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      lastStudiedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_studied_at'],
      ),
    );
  }

  @override
  Card createAlias(String alias) {
    return Card(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class CardData extends DataClass implements Insertable<CardData> {
  final int id;
  final int deckId;
  final String term;
  final String? gender;
  final String? audioRef;
  final bool hidden;
  final int orderIndex;
  final int createdAt;

  /// epoch ms
  final int? lastStudiedAt;
  const CardData({
    required this.id,
    required this.deckId,
    required this.term,
    this.gender,
    this.audioRef,
    required this.hidden,
    required this.orderIndex,
    required this.createdAt,
    this.lastStudiedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['deck_id'] = Variable<int>(deckId);
    map['term'] = Variable<String>(term);
    if (!nullToAbsent || gender != null) {
      map['gender'] = Variable<String>(gender);
    }
    if (!nullToAbsent || audioRef != null) {
      map['audio_ref'] = Variable<String>(audioRef);
    }
    map['hidden'] = Variable<bool>(hidden);
    map['order_index'] = Variable<int>(orderIndex);
    map['created_at'] = Variable<int>(createdAt);
    if (!nullToAbsent || lastStudiedAt != null) {
      map['last_studied_at'] = Variable<int>(lastStudiedAt);
    }
    return map;
  }

  CardCompanion toCompanion(bool nullToAbsent) {
    return CardCompanion(
      id: Value(id),
      deckId: Value(deckId),
      term: Value(term),
      gender: gender == null && nullToAbsent
          ? const Value.absent()
          : Value(gender),
      audioRef: audioRef == null && nullToAbsent
          ? const Value.absent()
          : Value(audioRef),
      hidden: Value(hidden),
      orderIndex: Value(orderIndex),
      createdAt: Value(createdAt),
      lastStudiedAt: lastStudiedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastStudiedAt),
    );
  }

  factory CardData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CardData(
      id: serializer.fromJson<int>(json['id']),
      deckId: serializer.fromJson<int>(json['deck_id']),
      term: serializer.fromJson<String>(json['term']),
      gender: serializer.fromJson<String?>(json['gender']),
      audioRef: serializer.fromJson<String?>(json['audio_ref']),
      hidden: serializer.fromJson<bool>(json['hidden']),
      orderIndex: serializer.fromJson<int>(json['order_index']),
      createdAt: serializer.fromJson<int>(json['created_at']),
      lastStudiedAt: serializer.fromJson<int?>(json['last_studied_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'deck_id': serializer.toJson<int>(deckId),
      'term': serializer.toJson<String>(term),
      'gender': serializer.toJson<String?>(gender),
      'audio_ref': serializer.toJson<String?>(audioRef),
      'hidden': serializer.toJson<bool>(hidden),
      'order_index': serializer.toJson<int>(orderIndex),
      'created_at': serializer.toJson<int>(createdAt),
      'last_studied_at': serializer.toJson<int?>(lastStudiedAt),
    };
  }

  CardData copyWith({
    int? id,
    int? deckId,
    String? term,
    Value<String?> gender = const Value.absent(),
    Value<String?> audioRef = const Value.absent(),
    bool? hidden,
    int? orderIndex,
    int? createdAt,
    Value<int?> lastStudiedAt = const Value.absent(),
  }) => CardData(
    id: id ?? this.id,
    deckId: deckId ?? this.deckId,
    term: term ?? this.term,
    gender: gender.present ? gender.value : this.gender,
    audioRef: audioRef.present ? audioRef.value : this.audioRef,
    hidden: hidden ?? this.hidden,
    orderIndex: orderIndex ?? this.orderIndex,
    createdAt: createdAt ?? this.createdAt,
    lastStudiedAt: lastStudiedAt.present
        ? lastStudiedAt.value
        : this.lastStudiedAt,
  );
  CardData copyWithCompanion(CardCompanion data) {
    return CardData(
      id: data.id.present ? data.id.value : this.id,
      deckId: data.deckId.present ? data.deckId.value : this.deckId,
      term: data.term.present ? data.term.value : this.term,
      gender: data.gender.present ? data.gender.value : this.gender,
      audioRef: data.audioRef.present ? data.audioRef.value : this.audioRef,
      hidden: data.hidden.present ? data.hidden.value : this.hidden,
      orderIndex: data.orderIndex.present
          ? data.orderIndex.value
          : this.orderIndex,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastStudiedAt: data.lastStudiedAt.present
          ? data.lastStudiedAt.value
          : this.lastStudiedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CardData(')
          ..write('id: $id, ')
          ..write('deckId: $deckId, ')
          ..write('term: $term, ')
          ..write('gender: $gender, ')
          ..write('audioRef: $audioRef, ')
          ..write('hidden: $hidden, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastStudiedAt: $lastStudiedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    deckId,
    term,
    gender,
    audioRef,
    hidden,
    orderIndex,
    createdAt,
    lastStudiedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CardData &&
          other.id == this.id &&
          other.deckId == this.deckId &&
          other.term == this.term &&
          other.gender == this.gender &&
          other.audioRef == this.audioRef &&
          other.hidden == this.hidden &&
          other.orderIndex == this.orderIndex &&
          other.createdAt == this.createdAt &&
          other.lastStudiedAt == this.lastStudiedAt);
}

class CardCompanion extends UpdateCompanion<CardData> {
  final Value<int> id;
  final Value<int> deckId;
  final Value<String> term;
  final Value<String?> gender;
  final Value<String?> audioRef;
  final Value<bool> hidden;
  final Value<int> orderIndex;
  final Value<int> createdAt;
  final Value<int?> lastStudiedAt;
  const CardCompanion({
    this.id = const Value.absent(),
    this.deckId = const Value.absent(),
    this.term = const Value.absent(),
    this.gender = const Value.absent(),
    this.audioRef = const Value.absent(),
    this.hidden = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastStudiedAt = const Value.absent(),
  });
  CardCompanion.insert({
    this.id = const Value.absent(),
    required int deckId,
    required String term,
    this.gender = const Value.absent(),
    this.audioRef = const Value.absent(),
    this.hidden = const Value.absent(),
    this.orderIndex = const Value.absent(),
    required int createdAt,
    this.lastStudiedAt = const Value.absent(),
  }) : deckId = Value(deckId),
       term = Value(term),
       createdAt = Value(createdAt);
  static Insertable<CardData> custom({
    Expression<int>? id,
    Expression<int>? deckId,
    Expression<String>? term,
    Expression<String>? gender,
    Expression<String>? audioRef,
    Expression<bool>? hidden,
    Expression<int>? orderIndex,
    Expression<int>? createdAt,
    Expression<int>? lastStudiedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deckId != null) 'deck_id': deckId,
      if (term != null) 'term': term,
      if (gender != null) 'gender': gender,
      if (audioRef != null) 'audio_ref': audioRef,
      if (hidden != null) 'hidden': hidden,
      if (orderIndex != null) 'order_index': orderIndex,
      if (createdAt != null) 'created_at': createdAt,
      if (lastStudiedAt != null) 'last_studied_at': lastStudiedAt,
    });
  }

  CardCompanion copyWith({
    Value<int>? id,
    Value<int>? deckId,
    Value<String>? term,
    Value<String?>? gender,
    Value<String?>? audioRef,
    Value<bool>? hidden,
    Value<int>? orderIndex,
    Value<int>? createdAt,
    Value<int?>? lastStudiedAt,
  }) {
    return CardCompanion(
      id: id ?? this.id,
      deckId: deckId ?? this.deckId,
      term: term ?? this.term,
      gender: gender ?? this.gender,
      audioRef: audioRef ?? this.audioRef,
      hidden: hidden ?? this.hidden,
      orderIndex: orderIndex ?? this.orderIndex,
      createdAt: createdAt ?? this.createdAt,
      lastStudiedAt: lastStudiedAt ?? this.lastStudiedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (deckId.present) {
      map['deck_id'] = Variable<int>(deckId.value);
    }
    if (term.present) {
      map['term'] = Variable<String>(term.value);
    }
    if (gender.present) {
      map['gender'] = Variable<String>(gender.value);
    }
    if (audioRef.present) {
      map['audio_ref'] = Variable<String>(audioRef.value);
    }
    if (hidden.present) {
      map['hidden'] = Variable<bool>(hidden.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (lastStudiedAt.present) {
      map['last_studied_at'] = Variable<int>(lastStudiedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CardCompanion(')
          ..write('id: $id, ')
          ..write('deckId: $deckId, ')
          ..write('term: $term, ')
          ..write('gender: $gender, ')
          ..write('audioRef: $audioRef, ')
          ..write('hidden: $hidden, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastStudiedAt: $lastStudiedAt')
          ..write(')'))
        .toString();
  }
}

class CardMeaning extends Table with TableInfo<CardMeaning, CardMeaningData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  CardMeaning(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL PRIMARY KEY AUTOINCREMENT',
  );
  static const VerificationMeta _cardIdMeta = const VerificationMeta('cardId');
  late final GeneratedColumn<int> cardId = GeneratedColumn<int>(
    'card_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES card(id)ON DELETE CASCADE',
  );
  static const VerificationMeta _langMeta = const VerificationMeta('lang');
  late final GeneratedColumn<String> lang = GeneratedColumn<String>(
    'lang',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [id, cardId, lang, content];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'card_meaning';
  @override
  VerificationContext validateIntegrity(
    Insertable<CardMeaningData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('card_id')) {
      context.handle(
        _cardIdMeta,
        cardId.isAcceptableOrUnknown(data['card_id']!, _cardIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cardIdMeta);
    }
    if (data.containsKey('lang')) {
      context.handle(
        _langMeta,
        lang.isAcceptableOrUnknown(data['lang']!, _langMeta),
      );
    } else if (isInserting) {
      context.missing(_langMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CardMeaningData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CardMeaningData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      cardId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}card_id'],
      )!,
      lang: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lang'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
    );
  }

  @override
  CardMeaning createAlias(String alias) {
    return CardMeaning(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class CardMeaningData extends DataClass implements Insertable<CardMeaningData> {
  final int id;
  final int cardId;
  final String lang;
  final String content;
  const CardMeaningData({
    required this.id,
    required this.cardId,
    required this.lang,
    required this.content,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['card_id'] = Variable<int>(cardId);
    map['lang'] = Variable<String>(lang);
    map['content'] = Variable<String>(content);
    return map;
  }

  CardMeaningCompanion toCompanion(bool nullToAbsent) {
    return CardMeaningCompanion(
      id: Value(id),
      cardId: Value(cardId),
      lang: Value(lang),
      content: Value(content),
    );
  }

  factory CardMeaningData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CardMeaningData(
      id: serializer.fromJson<int>(json['id']),
      cardId: serializer.fromJson<int>(json['card_id']),
      lang: serializer.fromJson<String>(json['lang']),
      content: serializer.fromJson<String>(json['content']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'card_id': serializer.toJson<int>(cardId),
      'lang': serializer.toJson<String>(lang),
      'content': serializer.toJson<String>(content),
    };
  }

  CardMeaningData copyWith({
    int? id,
    int? cardId,
    String? lang,
    String? content,
  }) => CardMeaningData(
    id: id ?? this.id,
    cardId: cardId ?? this.cardId,
    lang: lang ?? this.lang,
    content: content ?? this.content,
  );
  CardMeaningData copyWithCompanion(CardMeaningCompanion data) {
    return CardMeaningData(
      id: data.id.present ? data.id.value : this.id,
      cardId: data.cardId.present ? data.cardId.value : this.cardId,
      lang: data.lang.present ? data.lang.value : this.lang,
      content: data.content.present ? data.content.value : this.content,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CardMeaningData(')
          ..write('id: $id, ')
          ..write('cardId: $cardId, ')
          ..write('lang: $lang, ')
          ..write('content: $content')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, cardId, lang, content);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CardMeaningData &&
          other.id == this.id &&
          other.cardId == this.cardId &&
          other.lang == this.lang &&
          other.content == this.content);
}

class CardMeaningCompanion extends UpdateCompanion<CardMeaningData> {
  final Value<int> id;
  final Value<int> cardId;
  final Value<String> lang;
  final Value<String> content;
  const CardMeaningCompanion({
    this.id = const Value.absent(),
    this.cardId = const Value.absent(),
    this.lang = const Value.absent(),
    this.content = const Value.absent(),
  });
  CardMeaningCompanion.insert({
    this.id = const Value.absent(),
    required int cardId,
    required String lang,
    required String content,
  }) : cardId = Value(cardId),
       lang = Value(lang),
       content = Value(content);
  static Insertable<CardMeaningData> custom({
    Expression<int>? id,
    Expression<int>? cardId,
    Expression<String>? lang,
    Expression<String>? content,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cardId != null) 'card_id': cardId,
      if (lang != null) 'lang': lang,
      if (content != null) 'content': content,
    });
  }

  CardMeaningCompanion copyWith({
    Value<int>? id,
    Value<int>? cardId,
    Value<String>? lang,
    Value<String>? content,
  }) {
    return CardMeaningCompanion(
      id: id ?? this.id,
      cardId: cardId ?? this.cardId,
      lang: lang ?? this.lang,
      content: content ?? this.content,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (cardId.present) {
      map['card_id'] = Variable<int>(cardId.value);
    }
    if (lang.present) {
      map['lang'] = Variable<String>(lang.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CardMeaningCompanion(')
          ..write('id: $id, ')
          ..write('cardId: $cardId, ')
          ..write('lang: $lang, ')
          ..write('content: $content')
          ..write(')'))
        .toString();
  }
}

class SrsState extends Table with TableInfo<SrsState, SrsStateData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  SrsState(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _cardIdMeta = const VerificationMeta('cardId');
  late final GeneratedColumn<int> cardId = GeneratedColumn<int>(
    'card_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints:
        'NOT NULL PRIMARY KEY REFERENCES card(id)ON DELETE CASCADE',
  );
  static const VerificationMeta _boxMeta = const VerificationMeta('box');
  late final GeneratedColumn<int> box = GeneratedColumn<int>(
    'box',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _dueAtMeta = const VerificationMeta('dueAt');
  late final GeneratedColumn<int> dueAt = GeneratedColumn<int>(
    'due_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _lastResultMeta = const VerificationMeta(
    'lastResult',
  );
  late final GeneratedColumn<String> lastResult = GeneratedColumn<String>(
    'last_result',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _reviewedAtMeta = const VerificationMeta(
    'reviewedAt',
  );
  late final GeneratedColumn<int> reviewedAt = GeneratedColumn<int>(
    'reviewed_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [
    cardId,
    box,
    dueAt,
    lastResult,
    reviewedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'srs_state';
  @override
  VerificationContext validateIntegrity(
    Insertable<SrsStateData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('card_id')) {
      context.handle(
        _cardIdMeta,
        cardId.isAcceptableOrUnknown(data['card_id']!, _cardIdMeta),
      );
    }
    if (data.containsKey('box')) {
      context.handle(
        _boxMeta,
        box.isAcceptableOrUnknown(data['box']!, _boxMeta),
      );
    }
    if (data.containsKey('due_at')) {
      context.handle(
        _dueAtMeta,
        dueAt.isAcceptableOrUnknown(data['due_at']!, _dueAtMeta),
      );
    }
    if (data.containsKey('last_result')) {
      context.handle(
        _lastResultMeta,
        lastResult.isAcceptableOrUnknown(data['last_result']!, _lastResultMeta),
      );
    }
    if (data.containsKey('reviewed_at')) {
      context.handle(
        _reviewedAtMeta,
        reviewedAt.isAcceptableOrUnknown(data['reviewed_at']!, _reviewedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {cardId};
  @override
  SrsStateData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SrsStateData(
      cardId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}card_id'],
      )!,
      box: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}box'],
      )!,
      dueAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}due_at'],
      ),
      lastResult: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_result'],
      ),
      reviewedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reviewed_at'],
      ),
    );
  }

  @override
  SrsState createAlias(String alias) {
    return SrsState(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class SrsStateData extends DataClass implements Insertable<SrsStateData> {
  final int cardId;
  final int box;
  final int? dueAt;

  /// epoch ms; null = new, unscheduled
  final String? lastResult;

  /// 'correct' / 'wrong'
  final int? reviewedAt;
  const SrsStateData({
    required this.cardId,
    required this.box,
    this.dueAt,
    this.lastResult,
    this.reviewedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['card_id'] = Variable<int>(cardId);
    map['box'] = Variable<int>(box);
    if (!nullToAbsent || dueAt != null) {
      map['due_at'] = Variable<int>(dueAt);
    }
    if (!nullToAbsent || lastResult != null) {
      map['last_result'] = Variable<String>(lastResult);
    }
    if (!nullToAbsent || reviewedAt != null) {
      map['reviewed_at'] = Variable<int>(reviewedAt);
    }
    return map;
  }

  SrsStateCompanion toCompanion(bool nullToAbsent) {
    return SrsStateCompanion(
      cardId: Value(cardId),
      box: Value(box),
      dueAt: dueAt == null && nullToAbsent
          ? const Value.absent()
          : Value(dueAt),
      lastResult: lastResult == null && nullToAbsent
          ? const Value.absent()
          : Value(lastResult),
      reviewedAt: reviewedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(reviewedAt),
    );
  }

  factory SrsStateData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SrsStateData(
      cardId: serializer.fromJson<int>(json['card_id']),
      box: serializer.fromJson<int>(json['box']),
      dueAt: serializer.fromJson<int?>(json['due_at']),
      lastResult: serializer.fromJson<String?>(json['last_result']),
      reviewedAt: serializer.fromJson<int?>(json['reviewed_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'card_id': serializer.toJson<int>(cardId),
      'box': serializer.toJson<int>(box),
      'due_at': serializer.toJson<int?>(dueAt),
      'last_result': serializer.toJson<String?>(lastResult),
      'reviewed_at': serializer.toJson<int?>(reviewedAt),
    };
  }

  SrsStateData copyWith({
    int? cardId,
    int? box,
    Value<int?> dueAt = const Value.absent(),
    Value<String?> lastResult = const Value.absent(),
    Value<int?> reviewedAt = const Value.absent(),
  }) => SrsStateData(
    cardId: cardId ?? this.cardId,
    box: box ?? this.box,
    dueAt: dueAt.present ? dueAt.value : this.dueAt,
    lastResult: lastResult.present ? lastResult.value : this.lastResult,
    reviewedAt: reviewedAt.present ? reviewedAt.value : this.reviewedAt,
  );
  SrsStateData copyWithCompanion(SrsStateCompanion data) {
    return SrsStateData(
      cardId: data.cardId.present ? data.cardId.value : this.cardId,
      box: data.box.present ? data.box.value : this.box,
      dueAt: data.dueAt.present ? data.dueAt.value : this.dueAt,
      lastResult: data.lastResult.present
          ? data.lastResult.value
          : this.lastResult,
      reviewedAt: data.reviewedAt.present
          ? data.reviewedAt.value
          : this.reviewedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SrsStateData(')
          ..write('cardId: $cardId, ')
          ..write('box: $box, ')
          ..write('dueAt: $dueAt, ')
          ..write('lastResult: $lastResult, ')
          ..write('reviewedAt: $reviewedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(cardId, box, dueAt, lastResult, reviewedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SrsStateData &&
          other.cardId == this.cardId &&
          other.box == this.box &&
          other.dueAt == this.dueAt &&
          other.lastResult == this.lastResult &&
          other.reviewedAt == this.reviewedAt);
}

class SrsStateCompanion extends UpdateCompanion<SrsStateData> {
  final Value<int> cardId;
  final Value<int> box;
  final Value<int?> dueAt;
  final Value<String?> lastResult;
  final Value<int?> reviewedAt;
  const SrsStateCompanion({
    this.cardId = const Value.absent(),
    this.box = const Value.absent(),
    this.dueAt = const Value.absent(),
    this.lastResult = const Value.absent(),
    this.reviewedAt = const Value.absent(),
  });
  SrsStateCompanion.insert({
    this.cardId = const Value.absent(),
    this.box = const Value.absent(),
    this.dueAt = const Value.absent(),
    this.lastResult = const Value.absent(),
    this.reviewedAt = const Value.absent(),
  });
  static Insertable<SrsStateData> custom({
    Expression<int>? cardId,
    Expression<int>? box,
    Expression<int>? dueAt,
    Expression<String>? lastResult,
    Expression<int>? reviewedAt,
  }) {
    return RawValuesInsertable({
      if (cardId != null) 'card_id': cardId,
      if (box != null) 'box': box,
      if (dueAt != null) 'due_at': dueAt,
      if (lastResult != null) 'last_result': lastResult,
      if (reviewedAt != null) 'reviewed_at': reviewedAt,
    });
  }

  SrsStateCompanion copyWith({
    Value<int>? cardId,
    Value<int>? box,
    Value<int?>? dueAt,
    Value<String?>? lastResult,
    Value<int?>? reviewedAt,
  }) {
    return SrsStateCompanion(
      cardId: cardId ?? this.cardId,
      box: box ?? this.box,
      dueAt: dueAt ?? this.dueAt,
      lastResult: lastResult ?? this.lastResult,
      reviewedAt: reviewedAt ?? this.reviewedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (cardId.present) {
      map['card_id'] = Variable<int>(cardId.value);
    }
    if (box.present) {
      map['box'] = Variable<int>(box.value);
    }
    if (dueAt.present) {
      map['due_at'] = Variable<int>(dueAt.value);
    }
    if (lastResult.present) {
      map['last_result'] = Variable<String>(lastResult.value);
    }
    if (reviewedAt.present) {
      map['reviewed_at'] = Variable<int>(reviewedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SrsStateCompanion(')
          ..write('cardId: $cardId, ')
          ..write('box: $box, ')
          ..write('dueAt: $dueAt, ')
          ..write('lastResult: $lastResult, ')
          ..write('reviewedAt: $reviewedAt')
          ..write(')'))
        .toString();
  }
}

class DailyActivity extends Table
    with TableInfo<DailyActivity, DailyActivityData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  DailyActivity(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  late final GeneratedColumn<String> day = GeneratedColumn<String>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _pairIdMeta = const VerificationMeta('pairId');
  late final GeneratedColumn<int> pairId = GeneratedColumn<int>(
    'pair_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL REFERENCES language_pair(id)ON DELETE CASCADE',
  );
  static const VerificationMeta _secondsMeta = const VerificationMeta(
    'seconds',
  );
  late final GeneratedColumn<int> seconds = GeneratedColumn<int>(
    'seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _wordsMeta = const VerificationMeta('words');
  late final GeneratedColumn<int> words = GeneratedColumn<int>(
    'words',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  @override
  List<GeneratedColumn> get $columns => [day, pairId, seconds, words];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_activity';
  @override
  VerificationContext validateIntegrity(
    Insertable<DailyActivityData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('pair_id')) {
      context.handle(
        _pairIdMeta,
        pairId.isAcceptableOrUnknown(data['pair_id']!, _pairIdMeta),
      );
    } else if (isInserting) {
      context.missing(_pairIdMeta);
    }
    if (data.containsKey('seconds')) {
      context.handle(
        _secondsMeta,
        seconds.isAcceptableOrUnknown(data['seconds']!, _secondsMeta),
      );
    }
    if (data.containsKey('words')) {
      context.handle(
        _wordsMeta,
        words.isAcceptableOrUnknown(data['words']!, _wordsMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {day, pairId};
  @override
  DailyActivityData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyActivityData(
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day'],
      )!,
      pairId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pair_id'],
      )!,
      seconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seconds'],
      )!,
      words: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}words'],
      )!,
    );
  }

  @override
  DailyActivity createAlias(String alias) {
    return DailyActivity(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const ['PRIMARY KEY(day, pair_id)'];
  @override
  bool get dontWriteConstraints => true;
}

class DailyActivityData extends DataClass
    implements Insertable<DailyActivityData> {
  final String day;

  /// YYYY-MM-DD (machine clock)
  final int pairId;
  final int seconds;
  final int words;
  const DailyActivityData({
    required this.day,
    required this.pairId,
    required this.seconds,
    required this.words,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['day'] = Variable<String>(day);
    map['pair_id'] = Variable<int>(pairId);
    map['seconds'] = Variable<int>(seconds);
    map['words'] = Variable<int>(words);
    return map;
  }

  DailyActivityCompanion toCompanion(bool nullToAbsent) {
    return DailyActivityCompanion(
      day: Value(day),
      pairId: Value(pairId),
      seconds: Value(seconds),
      words: Value(words),
    );
  }

  factory DailyActivityData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyActivityData(
      day: serializer.fromJson<String>(json['day']),
      pairId: serializer.fromJson<int>(json['pair_id']),
      seconds: serializer.fromJson<int>(json['seconds']),
      words: serializer.fromJson<int>(json['words']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'day': serializer.toJson<String>(day),
      'pair_id': serializer.toJson<int>(pairId),
      'seconds': serializer.toJson<int>(seconds),
      'words': serializer.toJson<int>(words),
    };
  }

  DailyActivityData copyWith({
    String? day,
    int? pairId,
    int? seconds,
    int? words,
  }) => DailyActivityData(
    day: day ?? this.day,
    pairId: pairId ?? this.pairId,
    seconds: seconds ?? this.seconds,
    words: words ?? this.words,
  );
  DailyActivityData copyWithCompanion(DailyActivityCompanion data) {
    return DailyActivityData(
      day: data.day.present ? data.day.value : this.day,
      pairId: data.pairId.present ? data.pairId.value : this.pairId,
      seconds: data.seconds.present ? data.seconds.value : this.seconds,
      words: data.words.present ? data.words.value : this.words,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyActivityData(')
          ..write('day: $day, ')
          ..write('pairId: $pairId, ')
          ..write('seconds: $seconds, ')
          ..write('words: $words')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(day, pairId, seconds, words);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyActivityData &&
          other.day == this.day &&
          other.pairId == this.pairId &&
          other.seconds == this.seconds &&
          other.words == this.words);
}

class DailyActivityCompanion extends UpdateCompanion<DailyActivityData> {
  final Value<String> day;
  final Value<int> pairId;
  final Value<int> seconds;
  final Value<int> words;
  final Value<int> rowid;
  const DailyActivityCompanion({
    this.day = const Value.absent(),
    this.pairId = const Value.absent(),
    this.seconds = const Value.absent(),
    this.words = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DailyActivityCompanion.insert({
    required String day,
    required int pairId,
    this.seconds = const Value.absent(),
    this.words = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : day = Value(day),
       pairId = Value(pairId);
  static Insertable<DailyActivityData> custom({
    Expression<String>? day,
    Expression<int>? pairId,
    Expression<int>? seconds,
    Expression<int>? words,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (day != null) 'day': day,
      if (pairId != null) 'pair_id': pairId,
      if (seconds != null) 'seconds': seconds,
      if (words != null) 'words': words,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DailyActivityCompanion copyWith({
    Value<String>? day,
    Value<int>? pairId,
    Value<int>? seconds,
    Value<int>? words,
    Value<int>? rowid,
  }) {
    return DailyActivityCompanion(
      day: day ?? this.day,
      pairId: pairId ?? this.pairId,
      seconds: seconds ?? this.seconds,
      words: words ?? this.words,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (day.present) {
      map['day'] = Variable<String>(day.value);
    }
    if (pairId.present) {
      map['pair_id'] = Variable<int>(pairId.value);
    }
    if (seconds.present) {
      map['seconds'] = Variable<int>(seconds.value);
    }
    if (words.present) {
      map['words'] = Variable<int>(words.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyActivityCompanion(')
          ..write('day: $day, ')
          ..write('pairId: $pairId, ')
          ..write('seconds: $seconds, ')
          ..write('words: $words, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class Settings extends Table with TableInfo<Settings, Setting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Settings(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<Setting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  Setting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Setting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      ),
    );
  }

  @override
  Settings createAlias(String alias) {
    return Settings(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class Setting extends DataClass implements Insertable<Setting> {
  final String key;

  /// quoted: KEY is a SQL keyword
  final String? value;
  const Setting({required this.key, this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    if (!nullToAbsent || value != null) {
      map['value'] = Variable<String>(value);
    }
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(
      key: Value(key),
      value: value == null && nullToAbsent
          ? const Value.absent()
          : Value(value),
    );
  }

  factory Setting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Setting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String?>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String?>(value),
    };
  }

  Setting copyWith({
    String? key,
    Value<String?> value = const Value.absent(),
  }) => Setting(
    key: key ?? this.key,
    value: value.present ? value.value : this.value,
  );
  Setting copyWithCompanion(SettingsCompanion data) {
    return Setting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Setting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Setting && other.key == this.key && other.value == this.value);
}

class SettingsCompanion extends UpdateCompanion<Setting> {
  final Value<String> key;
  final Value<String?> value;
  final Value<int> rowid;
  const SettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String key,
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : key = Value(key);
  static Insertable<Setting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith({
    Value<String>? key,
    Value<String?>? value,
    Value<int>? rowid,
  }) {
    return SettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final LanguagePair languagePair = LanguagePair(this);
  late final Deck deck = Deck(this);
  late final Index idxDeckTree = Index(
    'idx_deck_tree',
    'CREATE INDEX idx_deck_tree ON deck (pair_id, parent_deck_id, order_index)',
  );
  late final Card card = Card(this);
  late final Index idxCardDeckOrder = Index(
    'idx_card_deck_order',
    'CREATE INDEX idx_card_deck_order ON card (deck_id, order_index)',
  );
  late final CardMeaning cardMeaning = CardMeaning(this);
  late final Index idxMeaningCard = Index(
    'idx_meaning_card',
    'CREATE INDEX idx_meaning_card ON card_meaning (card_id)',
  );
  late final SrsState srsState = SrsState(this);
  late final Index idxSrsDue = Index(
    'idx_srs_due',
    'CREATE INDEX idx_srs_due ON srs_state (due_at)',
  );
  late final DailyActivity dailyActivity = DailyActivity(this);
  late final Settings settings = Settings(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    languagePair,
    deck,
    idxDeckTree,
    card,
    idxCardDeckOrder,
    cardMeaning,
    idxMeaningCard,
    srsState,
    idxSrsDue,
    dailyActivity,
    settings,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'language_pair',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('deck', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'deck',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('card', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'card',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('card_meaning', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'card',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('srs_state', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'language_pair',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('daily_activity', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $LanguagePairCreateCompanionBuilder =
    LanguagePairCompanion Function({
      Value<int> id,
      required String sourceLang,
      required String targetLang,
      Value<int> orderIndex,
    });
typedef $LanguagePairUpdateCompanionBuilder =
    LanguagePairCompanion Function({
      Value<int> id,
      Value<String> sourceLang,
      Value<String> targetLang,
      Value<int> orderIndex,
    });

final class $LanguagePairReferences
    extends BaseReferences<_$AppDatabase, LanguagePair, LanguagePairData> {
  $LanguagePairReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<Deck, List<DeckData>> _deckRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.deck,
    aliasName: $_aliasNameGenerator(db.languagePair.id, db.deck.pairId),
  );

  $DeckProcessedTableManager get deckRefs {
    final manager = $DeckTableManager(
      $_db,
      $_db.deck,
    ).filter((f) => f.pairId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_deckRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<DailyActivity, List<DailyActivityData>>
  _dailyActivityRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.dailyActivity,
    aliasName: $_aliasNameGenerator(
      db.languagePair.id,
      db.dailyActivity.pairId,
    ),
  );

  $DailyActivityProcessedTableManager get dailyActivityRefs {
    final manager = $DailyActivityTableManager(
      $_db,
      $_db.dailyActivity,
    ).filter((f) => f.pairId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_dailyActivityRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $LanguagePairFilterComposer
    extends Composer<_$AppDatabase, LanguagePair> {
  $LanguagePairFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceLang => $composableBuilder(
    column: $table.sourceLang,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetLang => $composableBuilder(
    column: $table.targetLang,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> deckRefs(
    Expression<bool> Function($DeckFilterComposer f) f,
  ) {
    final $DeckFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.deck,
      getReferencedColumn: (t) => t.pairId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $DeckFilterComposer(
            $db: $db,
            $table: $db.deck,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> dailyActivityRefs(
    Expression<bool> Function($DailyActivityFilterComposer f) f,
  ) {
    final $DailyActivityFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dailyActivity,
      getReferencedColumn: (t) => t.pairId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $DailyActivityFilterComposer(
            $db: $db,
            $table: $db.dailyActivity,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $LanguagePairOrderingComposer
    extends Composer<_$AppDatabase, LanguagePair> {
  $LanguagePairOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceLang => $composableBuilder(
    column: $table.sourceLang,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetLang => $composableBuilder(
    column: $table.targetLang,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnOrderings(column),
  );
}

class $LanguagePairAnnotationComposer
    extends Composer<_$AppDatabase, LanguagePair> {
  $LanguagePairAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sourceLang => $composableBuilder(
    column: $table.sourceLang,
    builder: (column) => column,
  );

  GeneratedColumn<String> get targetLang => $composableBuilder(
    column: $table.targetLang,
    builder: (column) => column,
  );

  GeneratedColumn<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => column,
  );

  Expression<T> deckRefs<T extends Object>(
    Expression<T> Function($DeckAnnotationComposer a) f,
  ) {
    final $DeckAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.deck,
      getReferencedColumn: (t) => t.pairId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $DeckAnnotationComposer(
            $db: $db,
            $table: $db.deck,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> dailyActivityRefs<T extends Object>(
    Expression<T> Function($DailyActivityAnnotationComposer a) f,
  ) {
    final $DailyActivityAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dailyActivity,
      getReferencedColumn: (t) => t.pairId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $DailyActivityAnnotationComposer(
            $db: $db,
            $table: $db.dailyActivity,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $LanguagePairTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          LanguagePair,
          LanguagePairData,
          $LanguagePairFilterComposer,
          $LanguagePairOrderingComposer,
          $LanguagePairAnnotationComposer,
          $LanguagePairCreateCompanionBuilder,
          $LanguagePairUpdateCompanionBuilder,
          (LanguagePairData, $LanguagePairReferences),
          LanguagePairData,
          PrefetchHooks Function({bool deckRefs, bool dailyActivityRefs})
        > {
  $LanguagePairTableManager(_$AppDatabase db, LanguagePair table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $LanguagePairFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $LanguagePairOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $LanguagePairAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> sourceLang = const Value.absent(),
                Value<String> targetLang = const Value.absent(),
                Value<int> orderIndex = const Value.absent(),
              }) => LanguagePairCompanion(
                id: id,
                sourceLang: sourceLang,
                targetLang: targetLang,
                orderIndex: orderIndex,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String sourceLang,
                required String targetLang,
                Value<int> orderIndex = const Value.absent(),
              }) => LanguagePairCompanion.insert(
                id: id,
                sourceLang: sourceLang,
                targetLang: targetLang,
                orderIndex: orderIndex,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $LanguagePairReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({deckRefs = false, dailyActivityRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (deckRefs) db.deck,
                    if (dailyActivityRefs) db.dailyActivity,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (deckRefs)
                        await $_getPrefetchedData<
                          LanguagePairData,
                          LanguagePair,
                          DeckData
                        >(
                          currentTable: table,
                          referencedTable: $LanguagePairReferences
                              ._deckRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $LanguagePairReferences(db, table, p0).deckRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.pairId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (dailyActivityRefs)
                        await $_getPrefetchedData<
                          LanguagePairData,
                          LanguagePair,
                          DailyActivityData
                        >(
                          currentTable: table,
                          referencedTable: $LanguagePairReferences
                              ._dailyActivityRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $LanguagePairReferences(
                                db,
                                table,
                                p0,
                              ).dailyActivityRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.pairId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $LanguagePairProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      LanguagePair,
      LanguagePairData,
      $LanguagePairFilterComposer,
      $LanguagePairOrderingComposer,
      $LanguagePairAnnotationComposer,
      $LanguagePairCreateCompanionBuilder,
      $LanguagePairUpdateCompanionBuilder,
      (LanguagePairData, $LanguagePairReferences),
      LanguagePairData,
      PrefetchHooks Function({bool deckRefs, bool dailyActivityRefs})
    >;
typedef $DeckCreateCompanionBuilder =
    DeckCompanion Function({
      Value<int> id,
      required int pairId,
      Value<int?> parentDeckId,
      required String name,
      Value<int> orderIndex,
    });
typedef $DeckUpdateCompanionBuilder =
    DeckCompanion Function({
      Value<int> id,
      Value<int> pairId,
      Value<int?> parentDeckId,
      Value<String> name,
      Value<int> orderIndex,
    });

final class $DeckReferences
    extends BaseReferences<_$AppDatabase, Deck, DeckData> {
  $DeckReferences(super.$_db, super.$_table, super.$_typedResult);

  static LanguagePair _pairIdTable(_$AppDatabase db) => db.languagePair
      .createAlias($_aliasNameGenerator(db.deck.pairId, db.languagePair.id));

  $LanguagePairProcessedTableManager get pairId {
    final $_column = $_itemColumn<int>('pair_id')!;

    final manager = $LanguagePairTableManager(
      $_db,
      $_db.languagePair,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_pairIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<Card, List<CardData>> _cardRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.card,
    aliasName: $_aliasNameGenerator(db.deck.id, db.card.deckId),
  );

  $CardProcessedTableManager get cardRefs {
    final manager = $CardTableManager(
      $_db,
      $_db.card,
    ).filter((f) => f.deckId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_cardRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $DeckFilterComposer extends Composer<_$AppDatabase, Deck> {
  $DeckFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get parentDeckId => $composableBuilder(
    column: $table.parentDeckId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnFilters(column),
  );

  $LanguagePairFilterComposer get pairId {
    final $LanguagePairFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pairId,
      referencedTable: $db.languagePair,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $LanguagePairFilterComposer(
            $db: $db,
            $table: $db.languagePair,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> cardRefs(
    Expression<bool> Function($CardFilterComposer f) f,
  ) {
    final $CardFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.card,
      getReferencedColumn: (t) => t.deckId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $CardFilterComposer(
            $db: $db,
            $table: $db.card,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $DeckOrderingComposer extends Composer<_$AppDatabase, Deck> {
  $DeckOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get parentDeckId => $composableBuilder(
    column: $table.parentDeckId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnOrderings(column),
  );

  $LanguagePairOrderingComposer get pairId {
    final $LanguagePairOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pairId,
      referencedTable: $db.languagePair,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $LanguagePairOrderingComposer(
            $db: $db,
            $table: $db.languagePair,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $DeckAnnotationComposer extends Composer<_$AppDatabase, Deck> {
  $DeckAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get parentDeckId => $composableBuilder(
    column: $table.parentDeckId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => column,
  );

  $LanguagePairAnnotationComposer get pairId {
    final $LanguagePairAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pairId,
      referencedTable: $db.languagePair,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $LanguagePairAnnotationComposer(
            $db: $db,
            $table: $db.languagePair,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> cardRefs<T extends Object>(
    Expression<T> Function($CardAnnotationComposer a) f,
  ) {
    final $CardAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.card,
      getReferencedColumn: (t) => t.deckId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $CardAnnotationComposer(
            $db: $db,
            $table: $db.card,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $DeckTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          Deck,
          DeckData,
          $DeckFilterComposer,
          $DeckOrderingComposer,
          $DeckAnnotationComposer,
          $DeckCreateCompanionBuilder,
          $DeckUpdateCompanionBuilder,
          (DeckData, $DeckReferences),
          DeckData,
          PrefetchHooks Function({bool pairId, bool cardRefs})
        > {
  $DeckTableManager(_$AppDatabase db, Deck table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $DeckFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $DeckOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $DeckAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> pairId = const Value.absent(),
                Value<int?> parentDeckId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> orderIndex = const Value.absent(),
              }) => DeckCompanion(
                id: id,
                pairId: pairId,
                parentDeckId: parentDeckId,
                name: name,
                orderIndex: orderIndex,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int pairId,
                Value<int?> parentDeckId = const Value.absent(),
                required String name,
                Value<int> orderIndex = const Value.absent(),
              }) => DeckCompanion.insert(
                id: id,
                pairId: pairId,
                parentDeckId: parentDeckId,
                name: name,
                orderIndex: orderIndex,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), $DeckReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({pairId = false, cardRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (cardRefs) db.card],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (pairId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.pairId,
                                referencedTable: $DeckReferences._pairIdTable(
                                  db,
                                ),
                                referencedColumn: $DeckReferences
                                    ._pairIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (cardRefs)
                    await $_getPrefetchedData<DeckData, Deck, CardData>(
                      currentTable: table,
                      referencedTable: $DeckReferences._cardRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $DeckReferences(db, table, p0).cardRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.deckId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $DeckProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      Deck,
      DeckData,
      $DeckFilterComposer,
      $DeckOrderingComposer,
      $DeckAnnotationComposer,
      $DeckCreateCompanionBuilder,
      $DeckUpdateCompanionBuilder,
      (DeckData, $DeckReferences),
      DeckData,
      PrefetchHooks Function({bool pairId, bool cardRefs})
    >;
typedef $CardCreateCompanionBuilder =
    CardCompanion Function({
      Value<int> id,
      required int deckId,
      required String term,
      Value<String?> gender,
      Value<String?> audioRef,
      Value<bool> hidden,
      Value<int> orderIndex,
      required int createdAt,
      Value<int?> lastStudiedAt,
    });
typedef $CardUpdateCompanionBuilder =
    CardCompanion Function({
      Value<int> id,
      Value<int> deckId,
      Value<String> term,
      Value<String?> gender,
      Value<String?> audioRef,
      Value<bool> hidden,
      Value<int> orderIndex,
      Value<int> createdAt,
      Value<int?> lastStudiedAt,
    });

final class $CardReferences
    extends BaseReferences<_$AppDatabase, Card, CardData> {
  $CardReferences(super.$_db, super.$_table, super.$_typedResult);

  static Deck _deckIdTable(_$AppDatabase db) =>
      db.deck.createAlias($_aliasNameGenerator(db.card.deckId, db.deck.id));

  $DeckProcessedTableManager get deckId {
    final $_column = $_itemColumn<int>('deck_id')!;

    final manager = $DeckTableManager(
      $_db,
      $_db.deck,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_deckIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<CardMeaning, List<CardMeaningData>>
  _cardMeaningRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.cardMeaning,
    aliasName: $_aliasNameGenerator(db.card.id, db.cardMeaning.cardId),
  );

  $CardMeaningProcessedTableManager get cardMeaningRefs {
    final manager = $CardMeaningTableManager(
      $_db,
      $_db.cardMeaning,
    ).filter((f) => f.cardId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_cardMeaningRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<SrsState, List<SrsStateData>> _srsStateRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.srsState,
    aliasName: $_aliasNameGenerator(db.card.id, db.srsState.cardId),
  );

  $SrsStateProcessedTableManager get srsStateRefs {
    final manager = $SrsStateTableManager(
      $_db,
      $_db.srsState,
    ).filter((f) => f.cardId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_srsStateRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $CardFilterComposer extends Composer<_$AppDatabase, Card> {
  $CardFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get term => $composableBuilder(
    column: $table.term,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gender => $composableBuilder(
    column: $table.gender,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get audioRef => $composableBuilder(
    column: $table.audioRef,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hidden => $composableBuilder(
    column: $table.hidden,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastStudiedAt => $composableBuilder(
    column: $table.lastStudiedAt,
    builder: (column) => ColumnFilters(column),
  );

  $DeckFilterComposer get deckId {
    final $DeckFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deckId,
      referencedTable: $db.deck,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $DeckFilterComposer(
            $db: $db,
            $table: $db.deck,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> cardMeaningRefs(
    Expression<bool> Function($CardMeaningFilterComposer f) f,
  ) {
    final $CardMeaningFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cardMeaning,
      getReferencedColumn: (t) => t.cardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $CardMeaningFilterComposer(
            $db: $db,
            $table: $db.cardMeaning,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> srsStateRefs(
    Expression<bool> Function($SrsStateFilterComposer f) f,
  ) {
    final $SrsStateFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.srsState,
      getReferencedColumn: (t) => t.cardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $SrsStateFilterComposer(
            $db: $db,
            $table: $db.srsState,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $CardOrderingComposer extends Composer<_$AppDatabase, Card> {
  $CardOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get term => $composableBuilder(
    column: $table.term,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gender => $composableBuilder(
    column: $table.gender,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get audioRef => $composableBuilder(
    column: $table.audioRef,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hidden => $composableBuilder(
    column: $table.hidden,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastStudiedAt => $composableBuilder(
    column: $table.lastStudiedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $DeckOrderingComposer get deckId {
    final $DeckOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deckId,
      referencedTable: $db.deck,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $DeckOrderingComposer(
            $db: $db,
            $table: $db.deck,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $CardAnnotationComposer extends Composer<_$AppDatabase, Card> {
  $CardAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get term =>
      $composableBuilder(column: $table.term, builder: (column) => column);

  GeneratedColumn<String> get gender =>
      $composableBuilder(column: $table.gender, builder: (column) => column);

  GeneratedColumn<String> get audioRef =>
      $composableBuilder(column: $table.audioRef, builder: (column) => column);

  GeneratedColumn<bool> get hidden =>
      $composableBuilder(column: $table.hidden, builder: (column) => column);

  GeneratedColumn<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get lastStudiedAt => $composableBuilder(
    column: $table.lastStudiedAt,
    builder: (column) => column,
  );

  $DeckAnnotationComposer get deckId {
    final $DeckAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deckId,
      referencedTable: $db.deck,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $DeckAnnotationComposer(
            $db: $db,
            $table: $db.deck,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> cardMeaningRefs<T extends Object>(
    Expression<T> Function($CardMeaningAnnotationComposer a) f,
  ) {
    final $CardMeaningAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cardMeaning,
      getReferencedColumn: (t) => t.cardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $CardMeaningAnnotationComposer(
            $db: $db,
            $table: $db.cardMeaning,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> srsStateRefs<T extends Object>(
    Expression<T> Function($SrsStateAnnotationComposer a) f,
  ) {
    final $SrsStateAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.srsState,
      getReferencedColumn: (t) => t.cardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $SrsStateAnnotationComposer(
            $db: $db,
            $table: $db.srsState,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $CardTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          Card,
          CardData,
          $CardFilterComposer,
          $CardOrderingComposer,
          $CardAnnotationComposer,
          $CardCreateCompanionBuilder,
          $CardUpdateCompanionBuilder,
          (CardData, $CardReferences),
          CardData,
          PrefetchHooks Function({
            bool deckId,
            bool cardMeaningRefs,
            bool srsStateRefs,
          })
        > {
  $CardTableManager(_$AppDatabase db, Card table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $CardFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $CardOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $CardAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> deckId = const Value.absent(),
                Value<String> term = const Value.absent(),
                Value<String?> gender = const Value.absent(),
                Value<String?> audioRef = const Value.absent(),
                Value<bool> hidden = const Value.absent(),
                Value<int> orderIndex = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int?> lastStudiedAt = const Value.absent(),
              }) => CardCompanion(
                id: id,
                deckId: deckId,
                term: term,
                gender: gender,
                audioRef: audioRef,
                hidden: hidden,
                orderIndex: orderIndex,
                createdAt: createdAt,
                lastStudiedAt: lastStudiedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int deckId,
                required String term,
                Value<String?> gender = const Value.absent(),
                Value<String?> audioRef = const Value.absent(),
                Value<bool> hidden = const Value.absent(),
                Value<int> orderIndex = const Value.absent(),
                required int createdAt,
                Value<int?> lastStudiedAt = const Value.absent(),
              }) => CardCompanion.insert(
                id: id,
                deckId: deckId,
                term: term,
                gender: gender,
                audioRef: audioRef,
                hidden: hidden,
                orderIndex: orderIndex,
                createdAt: createdAt,
                lastStudiedAt: lastStudiedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), $CardReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback:
              ({
                deckId = false,
                cardMeaningRefs = false,
                srsStateRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (cardMeaningRefs) db.cardMeaning,
                    if (srsStateRefs) db.srsState,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (deckId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.deckId,
                                    referencedTable: $CardReferences
                                        ._deckIdTable(db),
                                    referencedColumn: $CardReferences
                                        ._deckIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (cardMeaningRefs)
                        await $_getPrefetchedData<
                          CardData,
                          Card,
                          CardMeaningData
                        >(
                          currentTable: table,
                          referencedTable: $CardReferences
                              ._cardMeaningRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $CardReferences(db, table, p0).cardMeaningRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.cardId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (srsStateRefs)
                        await $_getPrefetchedData<CardData, Card, SrsStateData>(
                          currentTable: table,
                          referencedTable: $CardReferences._srsStateRefsTable(
                            db,
                          ),
                          managerFromTypedResult: (p0) =>
                              $CardReferences(db, table, p0).srsStateRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.cardId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $CardProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      Card,
      CardData,
      $CardFilterComposer,
      $CardOrderingComposer,
      $CardAnnotationComposer,
      $CardCreateCompanionBuilder,
      $CardUpdateCompanionBuilder,
      (CardData, $CardReferences),
      CardData,
      PrefetchHooks Function({
        bool deckId,
        bool cardMeaningRefs,
        bool srsStateRefs,
      })
    >;
typedef $CardMeaningCreateCompanionBuilder =
    CardMeaningCompanion Function({
      Value<int> id,
      required int cardId,
      required String lang,
      required String content,
    });
typedef $CardMeaningUpdateCompanionBuilder =
    CardMeaningCompanion Function({
      Value<int> id,
      Value<int> cardId,
      Value<String> lang,
      Value<String> content,
    });

final class $CardMeaningReferences
    extends BaseReferences<_$AppDatabase, CardMeaning, CardMeaningData> {
  $CardMeaningReferences(super.$_db, super.$_table, super.$_typedResult);

  static Card _cardIdTable(_$AppDatabase db) => db.card.createAlias(
    $_aliasNameGenerator(db.cardMeaning.cardId, db.card.id),
  );

  $CardProcessedTableManager get cardId {
    final $_column = $_itemColumn<int>('card_id')!;

    final manager = $CardTableManager(
      $_db,
      $_db.card,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_cardIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $CardMeaningFilterComposer extends Composer<_$AppDatabase, CardMeaning> {
  $CardMeaningFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lang => $composableBuilder(
    column: $table.lang,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  $CardFilterComposer get cardId {
    final $CardFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cardId,
      referencedTable: $db.card,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $CardFilterComposer(
            $db: $db,
            $table: $db.card,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $CardMeaningOrderingComposer
    extends Composer<_$AppDatabase, CardMeaning> {
  $CardMeaningOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lang => $composableBuilder(
    column: $table.lang,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  $CardOrderingComposer get cardId {
    final $CardOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cardId,
      referencedTable: $db.card,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $CardOrderingComposer(
            $db: $db,
            $table: $db.card,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $CardMeaningAnnotationComposer
    extends Composer<_$AppDatabase, CardMeaning> {
  $CardMeaningAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get lang =>
      $composableBuilder(column: $table.lang, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  $CardAnnotationComposer get cardId {
    final $CardAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cardId,
      referencedTable: $db.card,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $CardAnnotationComposer(
            $db: $db,
            $table: $db.card,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $CardMeaningTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          CardMeaning,
          CardMeaningData,
          $CardMeaningFilterComposer,
          $CardMeaningOrderingComposer,
          $CardMeaningAnnotationComposer,
          $CardMeaningCreateCompanionBuilder,
          $CardMeaningUpdateCompanionBuilder,
          (CardMeaningData, $CardMeaningReferences),
          CardMeaningData,
          PrefetchHooks Function({bool cardId})
        > {
  $CardMeaningTableManager(_$AppDatabase db, CardMeaning table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $CardMeaningFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $CardMeaningOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $CardMeaningAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> cardId = const Value.absent(),
                Value<String> lang = const Value.absent(),
                Value<String> content = const Value.absent(),
              }) => CardMeaningCompanion(
                id: id,
                cardId: cardId,
                lang: lang,
                content: content,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int cardId,
                required String lang,
                required String content,
              }) => CardMeaningCompanion.insert(
                id: id,
                cardId: cardId,
                lang: lang,
                content: content,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $CardMeaningReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({cardId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (cardId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.cardId,
                                referencedTable: $CardMeaningReferences
                                    ._cardIdTable(db),
                                referencedColumn: $CardMeaningReferences
                                    ._cardIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $CardMeaningProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      CardMeaning,
      CardMeaningData,
      $CardMeaningFilterComposer,
      $CardMeaningOrderingComposer,
      $CardMeaningAnnotationComposer,
      $CardMeaningCreateCompanionBuilder,
      $CardMeaningUpdateCompanionBuilder,
      (CardMeaningData, $CardMeaningReferences),
      CardMeaningData,
      PrefetchHooks Function({bool cardId})
    >;
typedef $SrsStateCreateCompanionBuilder =
    SrsStateCompanion Function({
      Value<int> cardId,
      Value<int> box,
      Value<int?> dueAt,
      Value<String?> lastResult,
      Value<int?> reviewedAt,
    });
typedef $SrsStateUpdateCompanionBuilder =
    SrsStateCompanion Function({
      Value<int> cardId,
      Value<int> box,
      Value<int?> dueAt,
      Value<String?> lastResult,
      Value<int?> reviewedAt,
    });

final class $SrsStateReferences
    extends BaseReferences<_$AppDatabase, SrsState, SrsStateData> {
  $SrsStateReferences(super.$_db, super.$_table, super.$_typedResult);

  static Card _cardIdTable(_$AppDatabase db) =>
      db.card.createAlias($_aliasNameGenerator(db.srsState.cardId, db.card.id));

  $CardProcessedTableManager get cardId {
    final $_column = $_itemColumn<int>('card_id')!;

    final manager = $CardTableManager(
      $_db,
      $_db.card,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_cardIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $SrsStateFilterComposer extends Composer<_$AppDatabase, SrsState> {
  $SrsStateFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get box => $composableBuilder(
    column: $table.box,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastResult => $composableBuilder(
    column: $table.lastResult,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reviewedAt => $composableBuilder(
    column: $table.reviewedAt,
    builder: (column) => ColumnFilters(column),
  );

  $CardFilterComposer get cardId {
    final $CardFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cardId,
      referencedTable: $db.card,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $CardFilterComposer(
            $db: $db,
            $table: $db.card,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $SrsStateOrderingComposer extends Composer<_$AppDatabase, SrsState> {
  $SrsStateOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get box => $composableBuilder(
    column: $table.box,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastResult => $composableBuilder(
    column: $table.lastResult,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reviewedAt => $composableBuilder(
    column: $table.reviewedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $CardOrderingComposer get cardId {
    final $CardOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cardId,
      referencedTable: $db.card,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $CardOrderingComposer(
            $db: $db,
            $table: $db.card,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $SrsStateAnnotationComposer extends Composer<_$AppDatabase, SrsState> {
  $SrsStateAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get box =>
      $composableBuilder(column: $table.box, builder: (column) => column);

  GeneratedColumn<int> get dueAt =>
      $composableBuilder(column: $table.dueAt, builder: (column) => column);

  GeneratedColumn<String> get lastResult => $composableBuilder(
    column: $table.lastResult,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reviewedAt => $composableBuilder(
    column: $table.reviewedAt,
    builder: (column) => column,
  );

  $CardAnnotationComposer get cardId {
    final $CardAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cardId,
      referencedTable: $db.card,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $CardAnnotationComposer(
            $db: $db,
            $table: $db.card,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $SrsStateTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          SrsState,
          SrsStateData,
          $SrsStateFilterComposer,
          $SrsStateOrderingComposer,
          $SrsStateAnnotationComposer,
          $SrsStateCreateCompanionBuilder,
          $SrsStateUpdateCompanionBuilder,
          (SrsStateData, $SrsStateReferences),
          SrsStateData,
          PrefetchHooks Function({bool cardId})
        > {
  $SrsStateTableManager(_$AppDatabase db, SrsState table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $SrsStateFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $SrsStateOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $SrsStateAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> cardId = const Value.absent(),
                Value<int> box = const Value.absent(),
                Value<int?> dueAt = const Value.absent(),
                Value<String?> lastResult = const Value.absent(),
                Value<int?> reviewedAt = const Value.absent(),
              }) => SrsStateCompanion(
                cardId: cardId,
                box: box,
                dueAt: dueAt,
                lastResult: lastResult,
                reviewedAt: reviewedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> cardId = const Value.absent(),
                Value<int> box = const Value.absent(),
                Value<int?> dueAt = const Value.absent(),
                Value<String?> lastResult = const Value.absent(),
                Value<int?> reviewedAt = const Value.absent(),
              }) => SrsStateCompanion.insert(
                cardId: cardId,
                box: box,
                dueAt: dueAt,
                lastResult: lastResult,
                reviewedAt: reviewedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (e.readTable(table), $SrsStateReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({cardId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (cardId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.cardId,
                                referencedTable: $SrsStateReferences
                                    ._cardIdTable(db),
                                referencedColumn: $SrsStateReferences
                                    ._cardIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $SrsStateProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      SrsState,
      SrsStateData,
      $SrsStateFilterComposer,
      $SrsStateOrderingComposer,
      $SrsStateAnnotationComposer,
      $SrsStateCreateCompanionBuilder,
      $SrsStateUpdateCompanionBuilder,
      (SrsStateData, $SrsStateReferences),
      SrsStateData,
      PrefetchHooks Function({bool cardId})
    >;
typedef $DailyActivityCreateCompanionBuilder =
    DailyActivityCompanion Function({
      required String day,
      required int pairId,
      Value<int> seconds,
      Value<int> words,
      Value<int> rowid,
    });
typedef $DailyActivityUpdateCompanionBuilder =
    DailyActivityCompanion Function({
      Value<String> day,
      Value<int> pairId,
      Value<int> seconds,
      Value<int> words,
      Value<int> rowid,
    });

final class $DailyActivityReferences
    extends BaseReferences<_$AppDatabase, DailyActivity, DailyActivityData> {
  $DailyActivityReferences(super.$_db, super.$_table, super.$_typedResult);

  static LanguagePair _pairIdTable(_$AppDatabase db) =>
      db.languagePair.createAlias(
        $_aliasNameGenerator(db.dailyActivity.pairId, db.languagePair.id),
      );

  $LanguagePairProcessedTableManager get pairId {
    final $_column = $_itemColumn<int>('pair_id')!;

    final manager = $LanguagePairTableManager(
      $_db,
      $_db.languagePair,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_pairIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $DailyActivityFilterComposer
    extends Composer<_$AppDatabase, DailyActivity> {
  $DailyActivityFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get seconds => $composableBuilder(
    column: $table.seconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get words => $composableBuilder(
    column: $table.words,
    builder: (column) => ColumnFilters(column),
  );

  $LanguagePairFilterComposer get pairId {
    final $LanguagePairFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pairId,
      referencedTable: $db.languagePair,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $LanguagePairFilterComposer(
            $db: $db,
            $table: $db.languagePair,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $DailyActivityOrderingComposer
    extends Composer<_$AppDatabase, DailyActivity> {
  $DailyActivityOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get seconds => $composableBuilder(
    column: $table.seconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get words => $composableBuilder(
    column: $table.words,
    builder: (column) => ColumnOrderings(column),
  );

  $LanguagePairOrderingComposer get pairId {
    final $LanguagePairOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pairId,
      referencedTable: $db.languagePair,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $LanguagePairOrderingComposer(
            $db: $db,
            $table: $db.languagePair,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $DailyActivityAnnotationComposer
    extends Composer<_$AppDatabase, DailyActivity> {
  $DailyActivityAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<int> get seconds =>
      $composableBuilder(column: $table.seconds, builder: (column) => column);

  GeneratedColumn<int> get words =>
      $composableBuilder(column: $table.words, builder: (column) => column);

  $LanguagePairAnnotationComposer get pairId {
    final $LanguagePairAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pairId,
      referencedTable: $db.languagePair,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $LanguagePairAnnotationComposer(
            $db: $db,
            $table: $db.languagePair,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $DailyActivityTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          DailyActivity,
          DailyActivityData,
          $DailyActivityFilterComposer,
          $DailyActivityOrderingComposer,
          $DailyActivityAnnotationComposer,
          $DailyActivityCreateCompanionBuilder,
          $DailyActivityUpdateCompanionBuilder,
          (DailyActivityData, $DailyActivityReferences),
          DailyActivityData,
          PrefetchHooks Function({bool pairId})
        > {
  $DailyActivityTableManager(_$AppDatabase db, DailyActivity table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $DailyActivityFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $DailyActivityOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $DailyActivityAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> day = const Value.absent(),
                Value<int> pairId = const Value.absent(),
                Value<int> seconds = const Value.absent(),
                Value<int> words = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DailyActivityCompanion(
                day: day,
                pairId: pairId,
                seconds: seconds,
                words: words,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String day,
                required int pairId,
                Value<int> seconds = const Value.absent(),
                Value<int> words = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DailyActivityCompanion.insert(
                day: day,
                pairId: pairId,
                seconds: seconds,
                words: words,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $DailyActivityReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({pairId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (pairId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.pairId,
                                referencedTable: $DailyActivityReferences
                                    ._pairIdTable(db),
                                referencedColumn: $DailyActivityReferences
                                    ._pairIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $DailyActivityProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      DailyActivity,
      DailyActivityData,
      $DailyActivityFilterComposer,
      $DailyActivityOrderingComposer,
      $DailyActivityAnnotationComposer,
      $DailyActivityCreateCompanionBuilder,
      $DailyActivityUpdateCompanionBuilder,
      (DailyActivityData, $DailyActivityReferences),
      DailyActivityData,
      PrefetchHooks Function({bool pairId})
    >;
typedef $SettingsCreateCompanionBuilder =
    SettingsCompanion Function({
      required String key,
      Value<String?> value,
      Value<int> rowid,
    });
typedef $SettingsUpdateCompanionBuilder =
    SettingsCompanion Function({
      Value<String> key,
      Value<String?> value,
      Value<int> rowid,
    });

class $SettingsFilterComposer extends Composer<_$AppDatabase, Settings> {
  $SettingsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $SettingsOrderingComposer extends Composer<_$AppDatabase, Settings> {
  $SettingsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $SettingsAnnotationComposer extends Composer<_$AppDatabase, Settings> {
  $SettingsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $SettingsTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          Settings,
          Setting,
          $SettingsFilterComposer,
          $SettingsOrderingComposer,
          $SettingsAnnotationComposer,
          $SettingsCreateCompanionBuilder,
          $SettingsUpdateCompanionBuilder,
          (Setting, BaseReferences<_$AppDatabase, Settings, Setting>),
          Setting,
          PrefetchHooks Function()
        > {
  $SettingsTableManager(_$AppDatabase db, Settings table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $SettingsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $SettingsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $SettingsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String?> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                Value<String?> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SettingsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $SettingsProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      Settings,
      Setting,
      $SettingsFilterComposer,
      $SettingsOrderingComposer,
      $SettingsAnnotationComposer,
      $SettingsCreateCompanionBuilder,
      $SettingsUpdateCompanionBuilder,
      (Setting, BaseReferences<_$AppDatabase, Settings, Setting>),
      Setting,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $LanguagePairTableManager get languagePair =>
      $LanguagePairTableManager(_db, _db.languagePair);
  $DeckTableManager get deck => $DeckTableManager(_db, _db.deck);
  $CardTableManager get card => $CardTableManager(_db, _db.card);
  $CardMeaningTableManager get cardMeaning =>
      $CardMeaningTableManager(_db, _db.cardMeaning);
  $SrsStateTableManager get srsState =>
      $SrsStateTableManager(_db, _db.srsState);
  $DailyActivityTableManager get dailyActivity =>
      $DailyActivityTableManager(_db, _db.dailyActivity);
  $SettingsTableManager get settings =>
      $SettingsTableManager(_db, _db.settings);
}
