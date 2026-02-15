// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CardStatesTable extends CardStates
    with TableInfo<$CardStatesTable, CardState> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CardStatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _cardIdMeta = const VerificationMeta('cardId');
  @override
  late final GeneratedColumn<String> cardId = GeneratedColumn<String>(
    'card_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stabilityMeta = const VerificationMeta(
    'stability',
  );
  @override
  late final GeneratedColumn<double> stability = GeneratedColumn<double>(
    'stability',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _difficultyMeta = const VerificationMeta(
    'difficulty',
  );
  @override
  late final GeneratedColumn<double> difficulty = GeneratedColumn<double>(
    'difficulty',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(5.0),
  );
  static const VerificationMeta _lastReviewMeta = const VerificationMeta(
    'lastReview',
  );
  @override
  late final GeneratedColumn<DateTime> lastReview = GeneratedColumn<DateTime>(
    'last_review',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nextReviewMeta = const VerificationMeta(
    'nextReview',
  );
  @override
  late final GeneratedColumn<DateTime> nextReview = GeneratedColumn<DateTime>(
    'next_review',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _repsMeta = const VerificationMeta('reps');
  @override
  late final GeneratedColumn<int> reps = GeneratedColumn<int>(
    'reps',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lapsesMeta = const VerificationMeta('lapses');
  @override
  late final GeneratedColumn<int> lapses = GeneratedColumn<int>(
    'lapses',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('new'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    cardId,
    stability,
    difficulty,
    lastReview,
    nextReview,
    reps,
    lapses,
    state,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'card_states';
  @override
  VerificationContext validateIntegrity(
    Insertable<CardState> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('card_id')) {
      context.handle(
        _cardIdMeta,
        cardId.isAcceptableOrUnknown(data['card_id']!, _cardIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cardIdMeta);
    }
    if (data.containsKey('stability')) {
      context.handle(
        _stabilityMeta,
        stability.isAcceptableOrUnknown(data['stability']!, _stabilityMeta),
      );
    }
    if (data.containsKey('difficulty')) {
      context.handle(
        _difficultyMeta,
        difficulty.isAcceptableOrUnknown(data['difficulty']!, _difficultyMeta),
      );
    }
    if (data.containsKey('last_review')) {
      context.handle(
        _lastReviewMeta,
        lastReview.isAcceptableOrUnknown(data['last_review']!, _lastReviewMeta),
      );
    }
    if (data.containsKey('next_review')) {
      context.handle(
        _nextReviewMeta,
        nextReview.isAcceptableOrUnknown(data['next_review']!, _nextReviewMeta),
      );
    }
    if (data.containsKey('reps')) {
      context.handle(
        _repsMeta,
        reps.isAcceptableOrUnknown(data['reps']!, _repsMeta),
      );
    }
    if (data.containsKey('lapses')) {
      context.handle(
        _lapsesMeta,
        lapses.isAcceptableOrUnknown(data['lapses']!, _lapsesMeta),
      );
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {cardId};
  @override
  CardState map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CardState(
      cardId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}card_id'],
      )!,
      stability: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}stability'],
      )!,
      difficulty: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}difficulty'],
      )!,
      lastReview: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_review'],
      ),
      nextReview: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_review'],
      ),
      reps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reps'],
      )!,
      lapses: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lapses'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
    );
  }

  @override
  $CardStatesTable createAlias(String alias) {
    return $CardStatesTable(attachedDatabase, alias);
  }
}

class CardState extends DataClass implements Insertable<CardState> {
  final String cardId;
  final double stability;
  final double difficulty;
  final DateTime? lastReview;
  final DateTime? nextReview;
  final int reps;
  final int lapses;
  final String state;
  const CardState({
    required this.cardId,
    required this.stability,
    required this.difficulty,
    this.lastReview,
    this.nextReview,
    required this.reps,
    required this.lapses,
    required this.state,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['card_id'] = Variable<String>(cardId);
    map['stability'] = Variable<double>(stability);
    map['difficulty'] = Variable<double>(difficulty);
    if (!nullToAbsent || lastReview != null) {
      map['last_review'] = Variable<DateTime>(lastReview);
    }
    if (!nullToAbsent || nextReview != null) {
      map['next_review'] = Variable<DateTime>(nextReview);
    }
    map['reps'] = Variable<int>(reps);
    map['lapses'] = Variable<int>(lapses);
    map['state'] = Variable<String>(state);
    return map;
  }

  CardStatesCompanion toCompanion(bool nullToAbsent) {
    return CardStatesCompanion(
      cardId: Value(cardId),
      stability: Value(stability),
      difficulty: Value(difficulty),
      lastReview: lastReview == null && nullToAbsent
          ? const Value.absent()
          : Value(lastReview),
      nextReview: nextReview == null && nullToAbsent
          ? const Value.absent()
          : Value(nextReview),
      reps: Value(reps),
      lapses: Value(lapses),
      state: Value(state),
    );
  }

  factory CardState.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CardState(
      cardId: serializer.fromJson<String>(json['cardId']),
      stability: serializer.fromJson<double>(json['stability']),
      difficulty: serializer.fromJson<double>(json['difficulty']),
      lastReview: serializer.fromJson<DateTime?>(json['lastReview']),
      nextReview: serializer.fromJson<DateTime?>(json['nextReview']),
      reps: serializer.fromJson<int>(json['reps']),
      lapses: serializer.fromJson<int>(json['lapses']),
      state: serializer.fromJson<String>(json['state']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'cardId': serializer.toJson<String>(cardId),
      'stability': serializer.toJson<double>(stability),
      'difficulty': serializer.toJson<double>(difficulty),
      'lastReview': serializer.toJson<DateTime?>(lastReview),
      'nextReview': serializer.toJson<DateTime?>(nextReview),
      'reps': serializer.toJson<int>(reps),
      'lapses': serializer.toJson<int>(lapses),
      'state': serializer.toJson<String>(state),
    };
  }

  CardState copyWith({
    String? cardId,
    double? stability,
    double? difficulty,
    Value<DateTime?> lastReview = const Value.absent(),
    Value<DateTime?> nextReview = const Value.absent(),
    int? reps,
    int? lapses,
    String? state,
  }) => CardState(
    cardId: cardId ?? this.cardId,
    stability: stability ?? this.stability,
    difficulty: difficulty ?? this.difficulty,
    lastReview: lastReview.present ? lastReview.value : this.lastReview,
    nextReview: nextReview.present ? nextReview.value : this.nextReview,
    reps: reps ?? this.reps,
    lapses: lapses ?? this.lapses,
    state: state ?? this.state,
  );
  CardState copyWithCompanion(CardStatesCompanion data) {
    return CardState(
      cardId: data.cardId.present ? data.cardId.value : this.cardId,
      stability: data.stability.present ? data.stability.value : this.stability,
      difficulty: data.difficulty.present
          ? data.difficulty.value
          : this.difficulty,
      lastReview: data.lastReview.present
          ? data.lastReview.value
          : this.lastReview,
      nextReview: data.nextReview.present
          ? data.nextReview.value
          : this.nextReview,
      reps: data.reps.present ? data.reps.value : this.reps,
      lapses: data.lapses.present ? data.lapses.value : this.lapses,
      state: data.state.present ? data.state.value : this.state,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CardState(')
          ..write('cardId: $cardId, ')
          ..write('stability: $stability, ')
          ..write('difficulty: $difficulty, ')
          ..write('lastReview: $lastReview, ')
          ..write('nextReview: $nextReview, ')
          ..write('reps: $reps, ')
          ..write('lapses: $lapses, ')
          ..write('state: $state')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    cardId,
    stability,
    difficulty,
    lastReview,
    nextReview,
    reps,
    lapses,
    state,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CardState &&
          other.cardId == this.cardId &&
          other.stability == this.stability &&
          other.difficulty == this.difficulty &&
          other.lastReview == this.lastReview &&
          other.nextReview == this.nextReview &&
          other.reps == this.reps &&
          other.lapses == this.lapses &&
          other.state == this.state);
}

class CardStatesCompanion extends UpdateCompanion<CardState> {
  final Value<String> cardId;
  final Value<double> stability;
  final Value<double> difficulty;
  final Value<DateTime?> lastReview;
  final Value<DateTime?> nextReview;
  final Value<int> reps;
  final Value<int> lapses;
  final Value<String> state;
  final Value<int> rowid;
  const CardStatesCompanion({
    this.cardId = const Value.absent(),
    this.stability = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.lastReview = const Value.absent(),
    this.nextReview = const Value.absent(),
    this.reps = const Value.absent(),
    this.lapses = const Value.absent(),
    this.state = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CardStatesCompanion.insert({
    required String cardId,
    this.stability = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.lastReview = const Value.absent(),
    this.nextReview = const Value.absent(),
    this.reps = const Value.absent(),
    this.lapses = const Value.absent(),
    this.state = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : cardId = Value(cardId);
  static Insertable<CardState> custom({
    Expression<String>? cardId,
    Expression<double>? stability,
    Expression<double>? difficulty,
    Expression<DateTime>? lastReview,
    Expression<DateTime>? nextReview,
    Expression<int>? reps,
    Expression<int>? lapses,
    Expression<String>? state,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (cardId != null) 'card_id': cardId,
      if (stability != null) 'stability': stability,
      if (difficulty != null) 'difficulty': difficulty,
      if (lastReview != null) 'last_review': lastReview,
      if (nextReview != null) 'next_review': nextReview,
      if (reps != null) 'reps': reps,
      if (lapses != null) 'lapses': lapses,
      if (state != null) 'state': state,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CardStatesCompanion copyWith({
    Value<String>? cardId,
    Value<double>? stability,
    Value<double>? difficulty,
    Value<DateTime?>? lastReview,
    Value<DateTime?>? nextReview,
    Value<int>? reps,
    Value<int>? lapses,
    Value<String>? state,
    Value<int>? rowid,
  }) {
    return CardStatesCompanion(
      cardId: cardId ?? this.cardId,
      stability: stability ?? this.stability,
      difficulty: difficulty ?? this.difficulty,
      lastReview: lastReview ?? this.lastReview,
      nextReview: nextReview ?? this.nextReview,
      reps: reps ?? this.reps,
      lapses: lapses ?? this.lapses,
      state: state ?? this.state,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (cardId.present) {
      map['card_id'] = Variable<String>(cardId.value);
    }
    if (stability.present) {
      map['stability'] = Variable<double>(stability.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<double>(difficulty.value);
    }
    if (lastReview.present) {
      map['last_review'] = Variable<DateTime>(lastReview.value);
    }
    if (nextReview.present) {
      map['next_review'] = Variable<DateTime>(nextReview.value);
    }
    if (reps.present) {
      map['reps'] = Variable<int>(reps.value);
    }
    if (lapses.present) {
      map['lapses'] = Variable<int>(lapses.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CardStatesCompanion(')
          ..write('cardId: $cardId, ')
          ..write('stability: $stability, ')
          ..write('difficulty: $difficulty, ')
          ..write('lastReview: $lastReview, ')
          ..write('nextReview: $nextReview, ')
          ..write('reps: $reps, ')
          ..write('lapses: $lapses, ')
          ..write('state: $state, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReviewLogsTable extends ReviewLogs
    with TableInfo<$ReviewLogsTable, ReviewLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReviewLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _cardIdMeta = const VerificationMeta('cardId');
  @override
  late final GeneratedColumn<String> cardId = GeneratedColumn<String>(
    'card_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES card_states (card_id)',
    ),
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<int> rating = GeneratedColumn<int>(
    'rating',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _elapsedDaysMeta = const VerificationMeta(
    'elapsedDays',
  );
  @override
  late final GeneratedColumn<double> elapsedDays = GeneratedColumn<double>(
    'elapsed_days',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _responseTimeMsMeta = const VerificationMeta(
    'responseTimeMs',
  );
  @override
  late final GeneratedColumn<int> responseTimeMs = GeneratedColumn<int>(
    'response_time_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stabilityMeta = const VerificationMeta(
    'stability',
  );
  @override
  late final GeneratedColumn<double> stability = GeneratedColumn<double>(
    'stability',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _difficultyMeta = const VerificationMeta(
    'difficulty',
  );
  @override
  late final GeneratedColumn<double> difficulty = GeneratedColumn<double>(
    'difficulty',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cardId,
    timestamp,
    rating,
    elapsedDays,
    responseTimeMs,
    stability,
    difficulty,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'review_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReviewLog> instance, {
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
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('rating')) {
      context.handle(
        _ratingMeta,
        rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta),
      );
    } else if (isInserting) {
      context.missing(_ratingMeta);
    }
    if (data.containsKey('elapsed_days')) {
      context.handle(
        _elapsedDaysMeta,
        elapsedDays.isAcceptableOrUnknown(
          data['elapsed_days']!,
          _elapsedDaysMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_elapsedDaysMeta);
    }
    if (data.containsKey('response_time_ms')) {
      context.handle(
        _responseTimeMsMeta,
        responseTimeMs.isAcceptableOrUnknown(
          data['response_time_ms']!,
          _responseTimeMsMeta,
        ),
      );
    }
    if (data.containsKey('stability')) {
      context.handle(
        _stabilityMeta,
        stability.isAcceptableOrUnknown(data['stability']!, _stabilityMeta),
      );
    } else if (isInserting) {
      context.missing(_stabilityMeta);
    }
    if (data.containsKey('difficulty')) {
      context.handle(
        _difficultyMeta,
        difficulty.isAcceptableOrUnknown(data['difficulty']!, _difficultyMeta),
      );
    } else if (isInserting) {
      context.missing(_difficultyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReviewLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReviewLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      cardId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}card_id'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
      rating: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rating'],
      )!,
      elapsedDays: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}elapsed_days'],
      )!,
      responseTimeMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}response_time_ms'],
      ),
      stability: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}stability'],
      )!,
      difficulty: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}difficulty'],
      )!,
    );
  }

  @override
  $ReviewLogsTable createAlias(String alias) {
    return $ReviewLogsTable(attachedDatabase, alias);
  }
}

class ReviewLog extends DataClass implements Insertable<ReviewLog> {
  final int id;
  final String cardId;
  final DateTime timestamp;
  final int rating;
  final double elapsedDays;
  final int? responseTimeMs;
  final double stability;
  final double difficulty;
  const ReviewLog({
    required this.id,
    required this.cardId,
    required this.timestamp,
    required this.rating,
    required this.elapsedDays,
    this.responseTimeMs,
    required this.stability,
    required this.difficulty,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['card_id'] = Variable<String>(cardId);
    map['timestamp'] = Variable<DateTime>(timestamp);
    map['rating'] = Variable<int>(rating);
    map['elapsed_days'] = Variable<double>(elapsedDays);
    if (!nullToAbsent || responseTimeMs != null) {
      map['response_time_ms'] = Variable<int>(responseTimeMs);
    }
    map['stability'] = Variable<double>(stability);
    map['difficulty'] = Variable<double>(difficulty);
    return map;
  }

  ReviewLogsCompanion toCompanion(bool nullToAbsent) {
    return ReviewLogsCompanion(
      id: Value(id),
      cardId: Value(cardId),
      timestamp: Value(timestamp),
      rating: Value(rating),
      elapsedDays: Value(elapsedDays),
      responseTimeMs: responseTimeMs == null && nullToAbsent
          ? const Value.absent()
          : Value(responseTimeMs),
      stability: Value(stability),
      difficulty: Value(difficulty),
    );
  }

  factory ReviewLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReviewLog(
      id: serializer.fromJson<int>(json['id']),
      cardId: serializer.fromJson<String>(json['cardId']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      rating: serializer.fromJson<int>(json['rating']),
      elapsedDays: serializer.fromJson<double>(json['elapsedDays']),
      responseTimeMs: serializer.fromJson<int?>(json['responseTimeMs']),
      stability: serializer.fromJson<double>(json['stability']),
      difficulty: serializer.fromJson<double>(json['difficulty']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'cardId': serializer.toJson<String>(cardId),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'rating': serializer.toJson<int>(rating),
      'elapsedDays': serializer.toJson<double>(elapsedDays),
      'responseTimeMs': serializer.toJson<int?>(responseTimeMs),
      'stability': serializer.toJson<double>(stability),
      'difficulty': serializer.toJson<double>(difficulty),
    };
  }

  ReviewLog copyWith({
    int? id,
    String? cardId,
    DateTime? timestamp,
    int? rating,
    double? elapsedDays,
    Value<int?> responseTimeMs = const Value.absent(),
    double? stability,
    double? difficulty,
  }) => ReviewLog(
    id: id ?? this.id,
    cardId: cardId ?? this.cardId,
    timestamp: timestamp ?? this.timestamp,
    rating: rating ?? this.rating,
    elapsedDays: elapsedDays ?? this.elapsedDays,
    responseTimeMs: responseTimeMs.present
        ? responseTimeMs.value
        : this.responseTimeMs,
    stability: stability ?? this.stability,
    difficulty: difficulty ?? this.difficulty,
  );
  ReviewLog copyWithCompanion(ReviewLogsCompanion data) {
    return ReviewLog(
      id: data.id.present ? data.id.value : this.id,
      cardId: data.cardId.present ? data.cardId.value : this.cardId,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      rating: data.rating.present ? data.rating.value : this.rating,
      elapsedDays: data.elapsedDays.present
          ? data.elapsedDays.value
          : this.elapsedDays,
      responseTimeMs: data.responseTimeMs.present
          ? data.responseTimeMs.value
          : this.responseTimeMs,
      stability: data.stability.present ? data.stability.value : this.stability,
      difficulty: data.difficulty.present
          ? data.difficulty.value
          : this.difficulty,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReviewLog(')
          ..write('id: $id, ')
          ..write('cardId: $cardId, ')
          ..write('timestamp: $timestamp, ')
          ..write('rating: $rating, ')
          ..write('elapsedDays: $elapsedDays, ')
          ..write('responseTimeMs: $responseTimeMs, ')
          ..write('stability: $stability, ')
          ..write('difficulty: $difficulty')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    cardId,
    timestamp,
    rating,
    elapsedDays,
    responseTimeMs,
    stability,
    difficulty,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReviewLog &&
          other.id == this.id &&
          other.cardId == this.cardId &&
          other.timestamp == this.timestamp &&
          other.rating == this.rating &&
          other.elapsedDays == this.elapsedDays &&
          other.responseTimeMs == this.responseTimeMs &&
          other.stability == this.stability &&
          other.difficulty == this.difficulty);
}

class ReviewLogsCompanion extends UpdateCompanion<ReviewLog> {
  final Value<int> id;
  final Value<String> cardId;
  final Value<DateTime> timestamp;
  final Value<int> rating;
  final Value<double> elapsedDays;
  final Value<int?> responseTimeMs;
  final Value<double> stability;
  final Value<double> difficulty;
  const ReviewLogsCompanion({
    this.id = const Value.absent(),
    this.cardId = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.rating = const Value.absent(),
    this.elapsedDays = const Value.absent(),
    this.responseTimeMs = const Value.absent(),
    this.stability = const Value.absent(),
    this.difficulty = const Value.absent(),
  });
  ReviewLogsCompanion.insert({
    this.id = const Value.absent(),
    required String cardId,
    required DateTime timestamp,
    required int rating,
    required double elapsedDays,
    this.responseTimeMs = const Value.absent(),
    required double stability,
    required double difficulty,
  }) : cardId = Value(cardId),
       timestamp = Value(timestamp),
       rating = Value(rating),
       elapsedDays = Value(elapsedDays),
       stability = Value(stability),
       difficulty = Value(difficulty);
  static Insertable<ReviewLog> custom({
    Expression<int>? id,
    Expression<String>? cardId,
    Expression<DateTime>? timestamp,
    Expression<int>? rating,
    Expression<double>? elapsedDays,
    Expression<int>? responseTimeMs,
    Expression<double>? stability,
    Expression<double>? difficulty,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cardId != null) 'card_id': cardId,
      if (timestamp != null) 'timestamp': timestamp,
      if (rating != null) 'rating': rating,
      if (elapsedDays != null) 'elapsed_days': elapsedDays,
      if (responseTimeMs != null) 'response_time_ms': responseTimeMs,
      if (stability != null) 'stability': stability,
      if (difficulty != null) 'difficulty': difficulty,
    });
  }

  ReviewLogsCompanion copyWith({
    Value<int>? id,
    Value<String>? cardId,
    Value<DateTime>? timestamp,
    Value<int>? rating,
    Value<double>? elapsedDays,
    Value<int?>? responseTimeMs,
    Value<double>? stability,
    Value<double>? difficulty,
  }) {
    return ReviewLogsCompanion(
      id: id ?? this.id,
      cardId: cardId ?? this.cardId,
      timestamp: timestamp ?? this.timestamp,
      rating: rating ?? this.rating,
      elapsedDays: elapsedDays ?? this.elapsedDays,
      responseTimeMs: responseTimeMs ?? this.responseTimeMs,
      stability: stability ?? this.stability,
      difficulty: difficulty ?? this.difficulty,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (cardId.present) {
      map['card_id'] = Variable<String>(cardId.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (rating.present) {
      map['rating'] = Variable<int>(rating.value);
    }
    if (elapsedDays.present) {
      map['elapsed_days'] = Variable<double>(elapsedDays.value);
    }
    if (responseTimeMs.present) {
      map['response_time_ms'] = Variable<int>(responseTimeMs.value);
    }
    if (stability.present) {
      map['stability'] = Variable<double>(stability.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<double>(difficulty.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReviewLogsCompanion(')
          ..write('id: $id, ')
          ..write('cardId: $cardId, ')
          ..write('timestamp: $timestamp, ')
          ..write('rating: $rating, ')
          ..write('elapsedDays: $elapsedDays, ')
          ..write('responseTimeMs: $responseTimeMs, ')
          ..write('stability: $stability, ')
          ..write('difficulty: $difficulty')
          ..write(')'))
        .toString();
  }
}

class $ChapterProgressesTable extends ChapterProgresses
    with TableInfo<$ChapterProgressesTable, ChapterProgressesData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChapterProgressesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _chapterIdMeta = const VerificationMeta(
    'chapterId',
  );
  @override
  late final GeneratedColumn<String> chapterId = GeneratedColumn<String>(
    'chapter_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sectionsCompletedMeta = const VerificationMeta(
    'sectionsCompleted',
  );
  @override
  late final GeneratedColumn<String> sectionsCompleted =
      GeneratedColumn<String>(
        'sections_completed',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      );
  static const VerificationMeta _masteryPercentMeta = const VerificationMeta(
    'masteryPercent',
  );
  @override
  late final GeneratedColumn<double> masteryPercent = GeneratedColumn<double>(
    'mastery_percent',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    chapterId,
    sectionsCompleted,
    masteryPercent,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chapter_progresses';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChapterProgressesData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('chapter_id')) {
      context.handle(
        _chapterIdMeta,
        chapterId.isAcceptableOrUnknown(data['chapter_id']!, _chapterIdMeta),
      );
    } else if (isInserting) {
      context.missing(_chapterIdMeta);
    }
    if (data.containsKey('sections_completed')) {
      context.handle(
        _sectionsCompletedMeta,
        sectionsCompleted.isAcceptableOrUnknown(
          data['sections_completed']!,
          _sectionsCompletedMeta,
        ),
      );
    }
    if (data.containsKey('mastery_percent')) {
      context.handle(
        _masteryPercentMeta,
        masteryPercent.isAcceptableOrUnknown(
          data['mastery_percent']!,
          _masteryPercentMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {chapterId};
  @override
  ChapterProgressesData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChapterProgressesData(
      chapterId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chapter_id'],
      )!,
      sectionsCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sections_completed'],
      )!,
      masteryPercent: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}mastery_percent'],
      )!,
    );
  }

  @override
  $ChapterProgressesTable createAlias(String alias) {
    return $ChapterProgressesTable(attachedDatabase, alias);
  }
}

class ChapterProgressesData extends DataClass
    implements Insertable<ChapterProgressesData> {
  final String chapterId;
  final String sectionsCompleted;
  final double masteryPercent;
  const ChapterProgressesData({
    required this.chapterId,
    required this.sectionsCompleted,
    required this.masteryPercent,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['chapter_id'] = Variable<String>(chapterId);
    map['sections_completed'] = Variable<String>(sectionsCompleted);
    map['mastery_percent'] = Variable<double>(masteryPercent);
    return map;
  }

  ChapterProgressesCompanion toCompanion(bool nullToAbsent) {
    return ChapterProgressesCompanion(
      chapterId: Value(chapterId),
      sectionsCompleted: Value(sectionsCompleted),
      masteryPercent: Value(masteryPercent),
    );
  }

  factory ChapterProgressesData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChapterProgressesData(
      chapterId: serializer.fromJson<String>(json['chapterId']),
      sectionsCompleted: serializer.fromJson<String>(json['sectionsCompleted']),
      masteryPercent: serializer.fromJson<double>(json['masteryPercent']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'chapterId': serializer.toJson<String>(chapterId),
      'sectionsCompleted': serializer.toJson<String>(sectionsCompleted),
      'masteryPercent': serializer.toJson<double>(masteryPercent),
    };
  }

  ChapterProgressesData copyWith({
    String? chapterId,
    String? sectionsCompleted,
    double? masteryPercent,
  }) => ChapterProgressesData(
    chapterId: chapterId ?? this.chapterId,
    sectionsCompleted: sectionsCompleted ?? this.sectionsCompleted,
    masteryPercent: masteryPercent ?? this.masteryPercent,
  );
  ChapterProgressesData copyWithCompanion(ChapterProgressesCompanion data) {
    return ChapterProgressesData(
      chapterId: data.chapterId.present ? data.chapterId.value : this.chapterId,
      sectionsCompleted: data.sectionsCompleted.present
          ? data.sectionsCompleted.value
          : this.sectionsCompleted,
      masteryPercent: data.masteryPercent.present
          ? data.masteryPercent.value
          : this.masteryPercent,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChapterProgressesData(')
          ..write('chapterId: $chapterId, ')
          ..write('sectionsCompleted: $sectionsCompleted, ')
          ..write('masteryPercent: $masteryPercent')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(chapterId, sectionsCompleted, masteryPercent);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChapterProgressesData &&
          other.chapterId == this.chapterId &&
          other.sectionsCompleted == this.sectionsCompleted &&
          other.masteryPercent == this.masteryPercent);
}

class ChapterProgressesCompanion
    extends UpdateCompanion<ChapterProgressesData> {
  final Value<String> chapterId;
  final Value<String> sectionsCompleted;
  final Value<double> masteryPercent;
  final Value<int> rowid;
  const ChapterProgressesCompanion({
    this.chapterId = const Value.absent(),
    this.sectionsCompleted = const Value.absent(),
    this.masteryPercent = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChapterProgressesCompanion.insert({
    required String chapterId,
    this.sectionsCompleted = const Value.absent(),
    this.masteryPercent = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : chapterId = Value(chapterId);
  static Insertable<ChapterProgressesData> custom({
    Expression<String>? chapterId,
    Expression<String>? sectionsCompleted,
    Expression<double>? masteryPercent,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (chapterId != null) 'chapter_id': chapterId,
      if (sectionsCompleted != null) 'sections_completed': sectionsCompleted,
      if (masteryPercent != null) 'mastery_percent': masteryPercent,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChapterProgressesCompanion copyWith({
    Value<String>? chapterId,
    Value<String>? sectionsCompleted,
    Value<double>? masteryPercent,
    Value<int>? rowid,
  }) {
    return ChapterProgressesCompanion(
      chapterId: chapterId ?? this.chapterId,
      sectionsCompleted: sectionsCompleted ?? this.sectionsCompleted,
      masteryPercent: masteryPercent ?? this.masteryPercent,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (chapterId.present) {
      map['chapter_id'] = Variable<String>(chapterId.value);
    }
    if (sectionsCompleted.present) {
      map['sections_completed'] = Variable<String>(sectionsCompleted.value);
    }
    if (masteryPercent.present) {
      map['mastery_percent'] = Variable<double>(masteryPercent.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChapterProgressesCompanion(')
          ..write('chapterId: $chapterId, ')
          ..write('sectionsCompleted: $sectionsCompleted, ')
          ..write('masteryPercent: $masteryPercent, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CardStatesTable cardStates = $CardStatesTable(this);
  late final $ReviewLogsTable reviewLogs = $ReviewLogsTable(this);
  late final $ChapterProgressesTable chapterProgresses =
      $ChapterProgressesTable(this);
  late final CardStateDao cardStateDao = CardStateDao(this as AppDatabase);
  late final ReviewLogDao reviewLogDao = ReviewLogDao(this as AppDatabase);
  late final ChapterProgressDao chapterProgressDao = ChapterProgressDao(
    this as AppDatabase,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    cardStates,
    reviewLogs,
    chapterProgresses,
  ];
}

typedef $$CardStatesTableCreateCompanionBuilder =
    CardStatesCompanion Function({
      required String cardId,
      Value<double> stability,
      Value<double> difficulty,
      Value<DateTime?> lastReview,
      Value<DateTime?> nextReview,
      Value<int> reps,
      Value<int> lapses,
      Value<String> state,
      Value<int> rowid,
    });
typedef $$CardStatesTableUpdateCompanionBuilder =
    CardStatesCompanion Function({
      Value<String> cardId,
      Value<double> stability,
      Value<double> difficulty,
      Value<DateTime?> lastReview,
      Value<DateTime?> nextReview,
      Value<int> reps,
      Value<int> lapses,
      Value<String> state,
      Value<int> rowid,
    });

final class $$CardStatesTableReferences
    extends BaseReferences<_$AppDatabase, $CardStatesTable, CardState> {
  $$CardStatesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ReviewLogsTable, List<ReviewLog>>
  _reviewLogsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.reviewLogs,
    aliasName: $_aliasNameGenerator(db.cardStates.cardId, db.reviewLogs.cardId),
  );

  $$ReviewLogsTableProcessedTableManager get reviewLogsRefs {
    final manager = $$ReviewLogsTableTableManager($_db, $_db.reviewLogs).filter(
      (f) => f.cardId.cardId.sqlEquals($_itemColumn<String>('card_id')!),
    );

    final cache = $_typedResult.readTableOrNull(_reviewLogsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CardStatesTableFilterComposer
    extends Composer<_$AppDatabase, $CardStatesTable> {
  $$CardStatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get cardId => $composableBuilder(
    column: $table.cardId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get stability => $composableBuilder(
    column: $table.stability,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastReview => $composableBuilder(
    column: $table.lastReview,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextReview => $composableBuilder(
    column: $table.nextReview,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lapses => $composableBuilder(
    column: $table.lapses,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> reviewLogsRefs(
    Expression<bool> Function($$ReviewLogsTableFilterComposer f) f,
  ) {
    final $$ReviewLogsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cardId,
      referencedTable: $db.reviewLogs,
      getReferencedColumn: (t) => t.cardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReviewLogsTableFilterComposer(
            $db: $db,
            $table: $db.reviewLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CardStatesTableOrderingComposer
    extends Composer<_$AppDatabase, $CardStatesTable> {
  $$CardStatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get cardId => $composableBuilder(
    column: $table.cardId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get stability => $composableBuilder(
    column: $table.stability,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastReview => $composableBuilder(
    column: $table.lastReview,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextReview => $composableBuilder(
    column: $table.nextReview,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lapses => $composableBuilder(
    column: $table.lapses,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CardStatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CardStatesTable> {
  $$CardStatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get cardId =>
      $composableBuilder(column: $table.cardId, builder: (column) => column);

  GeneratedColumn<double> get stability =>
      $composableBuilder(column: $table.stability, builder: (column) => column);

  GeneratedColumn<double> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastReview => $composableBuilder(
    column: $table.lastReview,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get nextReview => $composableBuilder(
    column: $table.nextReview,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reps =>
      $composableBuilder(column: $table.reps, builder: (column) => column);

  GeneratedColumn<int> get lapses =>
      $composableBuilder(column: $table.lapses, builder: (column) => column);

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  Expression<T> reviewLogsRefs<T extends Object>(
    Expression<T> Function($$ReviewLogsTableAnnotationComposer a) f,
  ) {
    final $$ReviewLogsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cardId,
      referencedTable: $db.reviewLogs,
      getReferencedColumn: (t) => t.cardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReviewLogsTableAnnotationComposer(
            $db: $db,
            $table: $db.reviewLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CardStatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CardStatesTable,
          CardState,
          $$CardStatesTableFilterComposer,
          $$CardStatesTableOrderingComposer,
          $$CardStatesTableAnnotationComposer,
          $$CardStatesTableCreateCompanionBuilder,
          $$CardStatesTableUpdateCompanionBuilder,
          (CardState, $$CardStatesTableReferences),
          CardState,
          PrefetchHooks Function({bool reviewLogsRefs})
        > {
  $$CardStatesTableTableManager(_$AppDatabase db, $CardStatesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CardStatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CardStatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CardStatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> cardId = const Value.absent(),
                Value<double> stability = const Value.absent(),
                Value<double> difficulty = const Value.absent(),
                Value<DateTime?> lastReview = const Value.absent(),
                Value<DateTime?> nextReview = const Value.absent(),
                Value<int> reps = const Value.absent(),
                Value<int> lapses = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CardStatesCompanion(
                cardId: cardId,
                stability: stability,
                difficulty: difficulty,
                lastReview: lastReview,
                nextReview: nextReview,
                reps: reps,
                lapses: lapses,
                state: state,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String cardId,
                Value<double> stability = const Value.absent(),
                Value<double> difficulty = const Value.absent(),
                Value<DateTime?> lastReview = const Value.absent(),
                Value<DateTime?> nextReview = const Value.absent(),
                Value<int> reps = const Value.absent(),
                Value<int> lapses = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CardStatesCompanion.insert(
                cardId: cardId,
                stability: stability,
                difficulty: difficulty,
                lastReview: lastReview,
                nextReview: nextReview,
                reps: reps,
                lapses: lapses,
                state: state,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CardStatesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({reviewLogsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (reviewLogsRefs) db.reviewLogs],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (reviewLogsRefs)
                    await $_getPrefetchedData<
                      CardState,
                      $CardStatesTable,
                      ReviewLog
                    >(
                      currentTable: table,
                      referencedTable: $$CardStatesTableReferences
                          ._reviewLogsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CardStatesTableReferences(
                            db,
                            table,
                            p0,
                          ).reviewLogsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.cardId == item.cardId),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CardStatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CardStatesTable,
      CardState,
      $$CardStatesTableFilterComposer,
      $$CardStatesTableOrderingComposer,
      $$CardStatesTableAnnotationComposer,
      $$CardStatesTableCreateCompanionBuilder,
      $$CardStatesTableUpdateCompanionBuilder,
      (CardState, $$CardStatesTableReferences),
      CardState,
      PrefetchHooks Function({bool reviewLogsRefs})
    >;
typedef $$ReviewLogsTableCreateCompanionBuilder =
    ReviewLogsCompanion Function({
      Value<int> id,
      required String cardId,
      required DateTime timestamp,
      required int rating,
      required double elapsedDays,
      Value<int?> responseTimeMs,
      required double stability,
      required double difficulty,
    });
typedef $$ReviewLogsTableUpdateCompanionBuilder =
    ReviewLogsCompanion Function({
      Value<int> id,
      Value<String> cardId,
      Value<DateTime> timestamp,
      Value<int> rating,
      Value<double> elapsedDays,
      Value<int?> responseTimeMs,
      Value<double> stability,
      Value<double> difficulty,
    });

final class $$ReviewLogsTableReferences
    extends BaseReferences<_$AppDatabase, $ReviewLogsTable, ReviewLog> {
  $$ReviewLogsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CardStatesTable _cardIdTable(_$AppDatabase db) =>
      db.cardStates.createAlias(
        $_aliasNameGenerator(db.reviewLogs.cardId, db.cardStates.cardId),
      );

  $$CardStatesTableProcessedTableManager get cardId {
    final $_column = $_itemColumn<String>('card_id')!;

    final manager = $$CardStatesTableTableManager(
      $_db,
      $_db.cardStates,
    ).filter((f) => f.cardId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_cardIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ReviewLogsTableFilterComposer
    extends Composer<_$AppDatabase, $ReviewLogsTable> {
  $$ReviewLogsTableFilterComposer({
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

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get elapsedDays => $composableBuilder(
    column: $table.elapsedDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get responseTimeMs => $composableBuilder(
    column: $table.responseTimeMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get stability => $composableBuilder(
    column: $table.stability,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnFilters(column),
  );

  $$CardStatesTableFilterComposer get cardId {
    final $$CardStatesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cardId,
      referencedTable: $db.cardStates,
      getReferencedColumn: (t) => t.cardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardStatesTableFilterComposer(
            $db: $db,
            $table: $db.cardStates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReviewLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReviewLogsTable> {
  $$ReviewLogsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get elapsedDays => $composableBuilder(
    column: $table.elapsedDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get responseTimeMs => $composableBuilder(
    column: $table.responseTimeMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get stability => $composableBuilder(
    column: $table.stability,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnOrderings(column),
  );

  $$CardStatesTableOrderingComposer get cardId {
    final $$CardStatesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cardId,
      referencedTable: $db.cardStates,
      getReferencedColumn: (t) => t.cardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardStatesTableOrderingComposer(
            $db: $db,
            $table: $db.cardStates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReviewLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReviewLogsTable> {
  $$ReviewLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<int> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumn<double> get elapsedDays => $composableBuilder(
    column: $table.elapsedDays,
    builder: (column) => column,
  );

  GeneratedColumn<int> get responseTimeMs => $composableBuilder(
    column: $table.responseTimeMs,
    builder: (column) => column,
  );

  GeneratedColumn<double> get stability =>
      $composableBuilder(column: $table.stability, builder: (column) => column);

  GeneratedColumn<double> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => column,
  );

  $$CardStatesTableAnnotationComposer get cardId {
    final $$CardStatesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cardId,
      referencedTable: $db.cardStates,
      getReferencedColumn: (t) => t.cardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardStatesTableAnnotationComposer(
            $db: $db,
            $table: $db.cardStates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReviewLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReviewLogsTable,
          ReviewLog,
          $$ReviewLogsTableFilterComposer,
          $$ReviewLogsTableOrderingComposer,
          $$ReviewLogsTableAnnotationComposer,
          $$ReviewLogsTableCreateCompanionBuilder,
          $$ReviewLogsTableUpdateCompanionBuilder,
          (ReviewLog, $$ReviewLogsTableReferences),
          ReviewLog,
          PrefetchHooks Function({bool cardId})
        > {
  $$ReviewLogsTableTableManager(_$AppDatabase db, $ReviewLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReviewLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReviewLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReviewLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> cardId = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<int> rating = const Value.absent(),
                Value<double> elapsedDays = const Value.absent(),
                Value<int?> responseTimeMs = const Value.absent(),
                Value<double> stability = const Value.absent(),
                Value<double> difficulty = const Value.absent(),
              }) => ReviewLogsCompanion(
                id: id,
                cardId: cardId,
                timestamp: timestamp,
                rating: rating,
                elapsedDays: elapsedDays,
                responseTimeMs: responseTimeMs,
                stability: stability,
                difficulty: difficulty,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String cardId,
                required DateTime timestamp,
                required int rating,
                required double elapsedDays,
                Value<int?> responseTimeMs = const Value.absent(),
                required double stability,
                required double difficulty,
              }) => ReviewLogsCompanion.insert(
                id: id,
                cardId: cardId,
                timestamp: timestamp,
                rating: rating,
                elapsedDays: elapsedDays,
                responseTimeMs: responseTimeMs,
                stability: stability,
                difficulty: difficulty,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ReviewLogsTableReferences(db, table, e),
                ),
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
                                referencedTable: $$ReviewLogsTableReferences
                                    ._cardIdTable(db),
                                referencedColumn: $$ReviewLogsTableReferences
                                    ._cardIdTable(db)
                                    .cardId,
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

typedef $$ReviewLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReviewLogsTable,
      ReviewLog,
      $$ReviewLogsTableFilterComposer,
      $$ReviewLogsTableOrderingComposer,
      $$ReviewLogsTableAnnotationComposer,
      $$ReviewLogsTableCreateCompanionBuilder,
      $$ReviewLogsTableUpdateCompanionBuilder,
      (ReviewLog, $$ReviewLogsTableReferences),
      ReviewLog,
      PrefetchHooks Function({bool cardId})
    >;
typedef $$ChapterProgressesTableCreateCompanionBuilder =
    ChapterProgressesCompanion Function({
      required String chapterId,
      Value<String> sectionsCompleted,
      Value<double> masteryPercent,
      Value<int> rowid,
    });
typedef $$ChapterProgressesTableUpdateCompanionBuilder =
    ChapterProgressesCompanion Function({
      Value<String> chapterId,
      Value<String> sectionsCompleted,
      Value<double> masteryPercent,
      Value<int> rowid,
    });

class $$ChapterProgressesTableFilterComposer
    extends Composer<_$AppDatabase, $ChapterProgressesTable> {
  $$ChapterProgressesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get chapterId => $composableBuilder(
    column: $table.chapterId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sectionsCompleted => $composableBuilder(
    column: $table.sectionsCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get masteryPercent => $composableBuilder(
    column: $table.masteryPercent,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ChapterProgressesTableOrderingComposer
    extends Composer<_$AppDatabase, $ChapterProgressesTable> {
  $$ChapterProgressesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get chapterId => $composableBuilder(
    column: $table.chapterId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sectionsCompleted => $composableBuilder(
    column: $table.sectionsCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get masteryPercent => $composableBuilder(
    column: $table.masteryPercent,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChapterProgressesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChapterProgressesTable> {
  $$ChapterProgressesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get chapterId =>
      $composableBuilder(column: $table.chapterId, builder: (column) => column);

  GeneratedColumn<String> get sectionsCompleted => $composableBuilder(
    column: $table.sectionsCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<double> get masteryPercent => $composableBuilder(
    column: $table.masteryPercent,
    builder: (column) => column,
  );
}

class $$ChapterProgressesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChapterProgressesTable,
          ChapterProgressesData,
          $$ChapterProgressesTableFilterComposer,
          $$ChapterProgressesTableOrderingComposer,
          $$ChapterProgressesTableAnnotationComposer,
          $$ChapterProgressesTableCreateCompanionBuilder,
          $$ChapterProgressesTableUpdateCompanionBuilder,
          (
            ChapterProgressesData,
            BaseReferences<
              _$AppDatabase,
              $ChapterProgressesTable,
              ChapterProgressesData
            >,
          ),
          ChapterProgressesData,
          PrefetchHooks Function()
        > {
  $$ChapterProgressesTableTableManager(
    _$AppDatabase db,
    $ChapterProgressesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChapterProgressesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChapterProgressesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChapterProgressesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> chapterId = const Value.absent(),
                Value<String> sectionsCompleted = const Value.absent(),
                Value<double> masteryPercent = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChapterProgressesCompanion(
                chapterId: chapterId,
                sectionsCompleted: sectionsCompleted,
                masteryPercent: masteryPercent,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String chapterId,
                Value<String> sectionsCompleted = const Value.absent(),
                Value<double> masteryPercent = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChapterProgressesCompanion.insert(
                chapterId: chapterId,
                sectionsCompleted: sectionsCompleted,
                masteryPercent: masteryPercent,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ChapterProgressesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChapterProgressesTable,
      ChapterProgressesData,
      $$ChapterProgressesTableFilterComposer,
      $$ChapterProgressesTableOrderingComposer,
      $$ChapterProgressesTableAnnotationComposer,
      $$ChapterProgressesTableCreateCompanionBuilder,
      $$ChapterProgressesTableUpdateCompanionBuilder,
      (
        ChapterProgressesData,
        BaseReferences<
          _$AppDatabase,
          $ChapterProgressesTable,
          ChapterProgressesData
        >,
      ),
      ChapterProgressesData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CardStatesTableTableManager get cardStates =>
      $$CardStatesTableTableManager(_db, _db.cardStates);
  $$ReviewLogsTableTableManager get reviewLogs =>
      $$ReviewLogsTableTableManager(_db, _db.reviewLogs);
  $$ChapterProgressesTableTableManager get chapterProgresses =>
      $$ChapterProgressesTableTableManager(_db, _db.chapterProgresses);
}
