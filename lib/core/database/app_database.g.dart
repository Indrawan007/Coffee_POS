// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $UsersTableTable extends UsersTable
    with TableInfo<$UsersTableTable, UsersTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _usernameMeta =
      const VerificationMeta('username');
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
      'username', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 3, maxTextLength: 50),
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _passwordMeta =
      const VerificationMeta('password');
  @override
  late final GeneratedColumn<String> password = GeneratedColumn<String>(
      'password', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
      'role', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('cashier'));
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, username, password, role, isActive, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(Insertable<UsersTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('username')) {
      context.handle(_usernameMeta,
          username.isAcceptableOrUnknown(data['username']!, _usernameMeta));
    } else if (isInserting) {
      context.missing(_usernameMeta);
    }
    if (data.containsKey('password')) {
      context.handle(_passwordMeta,
          password.isAcceptableOrUnknown(data['password']!, _passwordMeta));
    } else if (isInserting) {
      context.missing(_passwordMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
          _roleMeta, role.isAcceptableOrUnknown(data['role']!, _roleMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UsersTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UsersTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      username: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}username'])!,
      password: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}password'])!,
      role: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}role'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $UsersTableTable createAlias(String alias) {
    return $UsersTableTable(attachedDatabase, alias);
  }
}

class UsersTableData extends DataClass implements Insertable<UsersTableData> {
  final int id;
  final String name;
  final String username;
  final String password;
  final String role;
  final bool isActive;
  final String createdAt;
  final String updatedAt;
  const UsersTableData(
      {required this.id,
      required this.name,
      required this.username,
      required this.password,
      required this.role,
      required this.isActive,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['username'] = Variable<String>(username);
    map['password'] = Variable<String>(password);
    map['role'] = Variable<String>(role);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    return map;
  }

  UsersTableCompanion toCompanion(bool nullToAbsent) {
    return UsersTableCompanion(
      id: Value(id),
      name: Value(name),
      username: Value(username),
      password: Value(password),
      role: Value(role),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory UsersTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UsersTableData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      username: serializer.fromJson<String>(json['username']),
      password: serializer.fromJson<String>(json['password']),
      role: serializer.fromJson<String>(json['role']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'username': serializer.toJson<String>(username),
      'password': serializer.toJson<String>(password),
      'role': serializer.toJson<String>(role),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
    };
  }

  UsersTableData copyWith(
          {int? id,
          String? name,
          String? username,
          String? password,
          String? role,
          bool? isActive,
          String? createdAt,
          String? updatedAt}) =>
      UsersTableData(
        id: id ?? this.id,
        name: name ?? this.name,
        username: username ?? this.username,
        password: password ?? this.password,
        role: role ?? this.role,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  UsersTableData copyWithCompanion(UsersTableCompanion data) {
    return UsersTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      username: data.username.present ? data.username.value : this.username,
      password: data.password.present ? data.password.value : this.password,
      role: data.role.present ? data.role.value : this.role,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UsersTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('username: $username, ')
          ..write('password: $password, ')
          ..write('role: $role, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, name, username, password, role, isActive, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UsersTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.username == this.username &&
          other.password == this.password &&
          other.role == this.role &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class UsersTableCompanion extends UpdateCompanion<UsersTableData> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> username;
  final Value<String> password;
  final Value<String> role;
  final Value<bool> isActive;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  const UsersTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.username = const Value.absent(),
    this.password = const Value.absent(),
    this.role = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  UsersTableCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String username,
    required String password,
    this.role = const Value.absent(),
    this.isActive = const Value.absent(),
    required String createdAt,
    required String updatedAt,
  })  : name = Value(name),
        username = Value(username),
        password = Value(password),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<UsersTableData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? username,
    Expression<String>? password,
    Expression<String>? role,
    Expression<bool>? isActive,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (username != null) 'username': username,
      if (password != null) 'password': password,
      if (role != null) 'role': role,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  UsersTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String>? username,
      Value<String>? password,
      Value<String>? role,
      Value<bool>? isActive,
      Value<String>? createdAt,
      Value<String>? updatedAt}) {
    return UsersTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      password: password ?? this.password,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (password.present) {
      map['password'] = Variable<String>(password.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('username: $username, ')
          ..write('password: $password, ')
          ..write('role: $role, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTableTable extends CategoriesTable
    with TableInfo<$CategoriesTableTable, CategoriesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, sortOrder, isActive, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
      Insertable<CategoriesTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CategoriesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoriesTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $CategoriesTableTable createAlias(String alias) {
    return $CategoriesTableTable(attachedDatabase, alias);
  }
}

class CategoriesTableData extends DataClass
    implements Insertable<CategoriesTableData> {
  final int id;
  final String name;
  final int sortOrder;
  final bool isActive;
  final String createdAt;
  final String updatedAt;
  const CategoriesTableData(
      {required this.id,
      required this.name,
      required this.sortOrder,
      required this.isActive,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['sort_order'] = Variable<int>(sortOrder);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    return map;
  }

  CategoriesTableCompanion toCompanion(bool nullToAbsent) {
    return CategoriesTableCompanion(
      id: Value(id),
      name: Value(name),
      sortOrder: Value(sortOrder),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory CategoriesTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoriesTableData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
    };
  }

  CategoriesTableData copyWith(
          {int? id,
          String? name,
          int? sortOrder,
          bool? isActive,
          String? createdAt,
          String? updatedAt}) =>
      CategoriesTableData(
        id: id ?? this.id,
        name: name ?? this.name,
        sortOrder: sortOrder ?? this.sortOrder,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  CategoriesTableData copyWithCompanion(CategoriesTableCompanion data) {
    return CategoriesTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, sortOrder, isActive, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoriesTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.sortOrder == this.sortOrder &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CategoriesTableCompanion extends UpdateCompanion<CategoriesTableData> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> sortOrder;
  final Value<bool> isActive;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  const CategoriesTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  CategoriesTableCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.sortOrder = const Value.absent(),
    this.isActive = const Value.absent(),
    required String createdAt,
    required String updatedAt,
  })  : name = Value(name),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<CategoriesTableData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? sortOrder,
    Expression<bool>? isActive,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  CategoriesTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<int>? sortOrder,
      Value<bool>? isActive,
      Value<String>? createdAt,
      Value<String>? updatedAt}) {
    return CategoriesTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $ProductsTableTable extends ProductsTable
    with TableInfo<$ProductsTableTable, ProductsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
      'category_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES categories (id)'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _basePriceMeta =
      const VerificationMeta('basePrice');
  @override
  late final GeneratedColumn<double> basePrice = GeneratedColumn<double>(
      'base_price', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _imagePathMeta =
      const VerificationMeta('imagePath');
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
      'image_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        categoryId,
        name,
        description,
        basePrice,
        imagePath,
        isActive,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'products';
  @override
  VerificationContext validateIntegrity(Insertable<ProductsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('base_price')) {
      context.handle(_basePriceMeta,
          basePrice.isAcceptableOrUnknown(data['base_price']!, _basePriceMeta));
    }
    if (data.containsKey('image_path')) {
      context.handle(_imagePathMeta,
          imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProductsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProductsTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}category_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      basePrice: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}base_price'])!,
      imagePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_path']),
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $ProductsTableTable createAlias(String alias) {
    return $ProductsTableTable(attachedDatabase, alias);
  }
}

class ProductsTableData extends DataClass
    implements Insertable<ProductsTableData> {
  final int id;
  final int categoryId;
  final String name;
  final String? description;
  final double basePrice;
  final String? imagePath;
  final bool isActive;
  final String createdAt;
  final String updatedAt;
  const ProductsTableData(
      {required this.id,
      required this.categoryId,
      required this.name,
      this.description,
      required this.basePrice,
      this.imagePath,
      required this.isActive,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['category_id'] = Variable<int>(categoryId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['base_price'] = Variable<double>(basePrice);
    if (!nullToAbsent || imagePath != null) {
      map['image_path'] = Variable<String>(imagePath);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    return map;
  }

  ProductsTableCompanion toCompanion(bool nullToAbsent) {
    return ProductsTableCompanion(
      id: Value(id),
      categoryId: Value(categoryId),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      basePrice: Value(basePrice),
      imagePath: imagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(imagePath),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ProductsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProductsTableData(
      id: serializer.fromJson<int>(json['id']),
      categoryId: serializer.fromJson<int>(json['categoryId']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      basePrice: serializer.fromJson<double>(json['basePrice']),
      imagePath: serializer.fromJson<String?>(json['imagePath']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'categoryId': serializer.toJson<int>(categoryId),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'basePrice': serializer.toJson<double>(basePrice),
      'imagePath': serializer.toJson<String?>(imagePath),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
    };
  }

  ProductsTableData copyWith(
          {int? id,
          int? categoryId,
          String? name,
          Value<String?> description = const Value.absent(),
          double? basePrice,
          Value<String?> imagePath = const Value.absent(),
          bool? isActive,
          String? createdAt,
          String? updatedAt}) =>
      ProductsTableData(
        id: id ?? this.id,
        categoryId: categoryId ?? this.categoryId,
        name: name ?? this.name,
        description: description.present ? description.value : this.description,
        basePrice: basePrice ?? this.basePrice,
        imagePath: imagePath.present ? imagePath.value : this.imagePath,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  ProductsTableData copyWithCompanion(ProductsTableCompanion data) {
    return ProductsTableData(
      id: data.id.present ? data.id.value : this.id,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      name: data.name.present ? data.name.value : this.name,
      description:
          data.description.present ? data.description.value : this.description,
      basePrice: data.basePrice.present ? data.basePrice.value : this.basePrice,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProductsTableData(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('basePrice: $basePrice, ')
          ..write('imagePath: $imagePath, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, categoryId, name, description, basePrice,
      imagePath, isActive, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProductsTableData &&
          other.id == this.id &&
          other.categoryId == this.categoryId &&
          other.name == this.name &&
          other.description == this.description &&
          other.basePrice == this.basePrice &&
          other.imagePath == this.imagePath &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ProductsTableCompanion extends UpdateCompanion<ProductsTableData> {
  final Value<int> id;
  final Value<int> categoryId;
  final Value<String> name;
  final Value<String?> description;
  final Value<double> basePrice;
  final Value<String?> imagePath;
  final Value<bool> isActive;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  const ProductsTableCompanion({
    this.id = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.basePrice = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ProductsTableCompanion.insert({
    this.id = const Value.absent(),
    required int categoryId,
    required String name,
    this.description = const Value.absent(),
    this.basePrice = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.isActive = const Value.absent(),
    required String createdAt,
    required String updatedAt,
  })  : categoryId = Value(categoryId),
        name = Value(name),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<ProductsTableData> custom({
    Expression<int>? id,
    Expression<int>? categoryId,
    Expression<String>? name,
    Expression<String>? description,
    Expression<double>? basePrice,
    Expression<String>? imagePath,
    Expression<bool>? isActive,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (categoryId != null) 'category_id': categoryId,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (basePrice != null) 'base_price': basePrice,
      if (imagePath != null) 'image_path': imagePath,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ProductsTableCompanion copyWith(
      {Value<int>? id,
      Value<int>? categoryId,
      Value<String>? name,
      Value<String?>? description,
      Value<double>? basePrice,
      Value<String?>? imagePath,
      Value<bool>? isActive,
      Value<String>? createdAt,
      Value<String>? updatedAt}) {
    return ProductsTableCompanion(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      description: description ?? this.description,
      basePrice: basePrice ?? this.basePrice,
      imagePath: imagePath ?? this.imagePath,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (basePrice.present) {
      map['base_price'] = Variable<double>(basePrice.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductsTableCompanion(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('basePrice: $basePrice, ')
          ..write('imagePath: $imagePath, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $ProductVariantsTableTable extends ProductVariantsTable
    with TableInfo<$ProductVariantsTableTable, ProductVariantsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductVariantsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _productIdMeta =
      const VerificationMeta('productId');
  @override
  late final GeneratedColumn<int> productId = GeneratedColumn<int>(
      'product_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES products (id)'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _priceAdjustmentMeta =
      const VerificationMeta('priceAdjustment');
  @override
  late final GeneratedColumn<double> priceAdjustment = GeneratedColumn<double>(
      'price_adjustment', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  @override
  List<GeneratedColumn> get $columns =>
      [id, productId, name, priceAdjustment, isActive];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'product_variants';
  @override
  VerificationContext validateIntegrity(
      Insertable<ProductVariantsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('product_id')) {
      context.handle(_productIdMeta,
          productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta));
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('price_adjustment')) {
      context.handle(
          _priceAdjustmentMeta,
          priceAdjustment.isAcceptableOrUnknown(
              data['price_adjustment']!, _priceAdjustmentMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProductVariantsTableData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProductVariantsTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      productId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}product_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      priceAdjustment: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}price_adjustment'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
    );
  }

  @override
  $ProductVariantsTableTable createAlias(String alias) {
    return $ProductVariantsTableTable(attachedDatabase, alias);
  }
}

class ProductVariantsTableData extends DataClass
    implements Insertable<ProductVariantsTableData> {
  final int id;
  final int productId;
  final String name;
  final double priceAdjustment;
  final bool isActive;
  const ProductVariantsTableData(
      {required this.id,
      required this.productId,
      required this.name,
      required this.priceAdjustment,
      required this.isActive});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['product_id'] = Variable<int>(productId);
    map['name'] = Variable<String>(name);
    map['price_adjustment'] = Variable<double>(priceAdjustment);
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  ProductVariantsTableCompanion toCompanion(bool nullToAbsent) {
    return ProductVariantsTableCompanion(
      id: Value(id),
      productId: Value(productId),
      name: Value(name),
      priceAdjustment: Value(priceAdjustment),
      isActive: Value(isActive),
    );
  }

  factory ProductVariantsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProductVariantsTableData(
      id: serializer.fromJson<int>(json['id']),
      productId: serializer.fromJson<int>(json['productId']),
      name: serializer.fromJson<String>(json['name']),
      priceAdjustment: serializer.fromJson<double>(json['priceAdjustment']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'productId': serializer.toJson<int>(productId),
      'name': serializer.toJson<String>(name),
      'priceAdjustment': serializer.toJson<double>(priceAdjustment),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  ProductVariantsTableData copyWith(
          {int? id,
          int? productId,
          String? name,
          double? priceAdjustment,
          bool? isActive}) =>
      ProductVariantsTableData(
        id: id ?? this.id,
        productId: productId ?? this.productId,
        name: name ?? this.name,
        priceAdjustment: priceAdjustment ?? this.priceAdjustment,
        isActive: isActive ?? this.isActive,
      );
  ProductVariantsTableData copyWithCompanion(
      ProductVariantsTableCompanion data) {
    return ProductVariantsTableData(
      id: data.id.present ? data.id.value : this.id,
      productId: data.productId.present ? data.productId.value : this.productId,
      name: data.name.present ? data.name.value : this.name,
      priceAdjustment: data.priceAdjustment.present
          ? data.priceAdjustment.value
          : this.priceAdjustment,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProductVariantsTableData(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('name: $name, ')
          ..write('priceAdjustment: $priceAdjustment, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, productId, name, priceAdjustment, isActive);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProductVariantsTableData &&
          other.id == this.id &&
          other.productId == this.productId &&
          other.name == this.name &&
          other.priceAdjustment == this.priceAdjustment &&
          other.isActive == this.isActive);
}

class ProductVariantsTableCompanion
    extends UpdateCompanion<ProductVariantsTableData> {
  final Value<int> id;
  final Value<int> productId;
  final Value<String> name;
  final Value<double> priceAdjustment;
  final Value<bool> isActive;
  const ProductVariantsTableCompanion({
    this.id = const Value.absent(),
    this.productId = const Value.absent(),
    this.name = const Value.absent(),
    this.priceAdjustment = const Value.absent(),
    this.isActive = const Value.absent(),
  });
  ProductVariantsTableCompanion.insert({
    this.id = const Value.absent(),
    required int productId,
    required String name,
    this.priceAdjustment = const Value.absent(),
    this.isActive = const Value.absent(),
  })  : productId = Value(productId),
        name = Value(name);
  static Insertable<ProductVariantsTableData> custom({
    Expression<int>? id,
    Expression<int>? productId,
    Expression<String>? name,
    Expression<double>? priceAdjustment,
    Expression<bool>? isActive,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (productId != null) 'product_id': productId,
      if (name != null) 'name': name,
      if (priceAdjustment != null) 'price_adjustment': priceAdjustment,
      if (isActive != null) 'is_active': isActive,
    });
  }

  ProductVariantsTableCompanion copyWith(
      {Value<int>? id,
      Value<int>? productId,
      Value<String>? name,
      Value<double>? priceAdjustment,
      Value<bool>? isActive}) {
    return ProductVariantsTableCompanion(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      name: name ?? this.name,
      priceAdjustment: priceAdjustment ?? this.priceAdjustment,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<int>(productId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (priceAdjustment.present) {
      map['price_adjustment'] = Variable<double>(priceAdjustment.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductVariantsTableCompanion(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('name: $name, ')
          ..write('priceAdjustment: $priceAdjustment, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }
}

class $AddonsTableTable extends AddonsTable
    with TableInfo<$AddonsTableTable, AddonsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AddonsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<double> price = GeneratedColumn<double>(
      'price', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, name, price, isActive, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'addons';
  @override
  VerificationContext validateIntegrity(Insertable<AddonsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('price')) {
      context.handle(
          _priceMeta, price.isAcceptableOrUnknown(data['price']!, _priceMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AddonsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AddonsTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      price: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}price'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $AddonsTableTable createAlias(String alias) {
    return $AddonsTableTable(attachedDatabase, alias);
  }
}

class AddonsTableData extends DataClass implements Insertable<AddonsTableData> {
  final int id;
  final String name;
  final double price;
  final bool isActive;
  final String createdAt;
  const AddonsTableData(
      {required this.id,
      required this.name,
      required this.price,
      required this.isActive,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['price'] = Variable<double>(price);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<String>(createdAt);
    return map;
  }

  AddonsTableCompanion toCompanion(bool nullToAbsent) {
    return AddonsTableCompanion(
      id: Value(id),
      name: Value(name),
      price: Value(price),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
    );
  }

  factory AddonsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AddonsTableData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      price: serializer.fromJson<double>(json['price']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'price': serializer.toJson<double>(price),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<String>(createdAt),
    };
  }

  AddonsTableData copyWith(
          {int? id,
          String? name,
          double? price,
          bool? isActive,
          String? createdAt}) =>
      AddonsTableData(
        id: id ?? this.id,
        name: name ?? this.name,
        price: price ?? this.price,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
      );
  AddonsTableData copyWithCompanion(AddonsTableCompanion data) {
    return AddonsTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      price: data.price.present ? data.price.value : this.price,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AddonsTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('price: $price, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, price, isActive, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AddonsTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.price == this.price &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt);
}

class AddonsTableCompanion extends UpdateCompanion<AddonsTableData> {
  final Value<int> id;
  final Value<String> name;
  final Value<double> price;
  final Value<bool> isActive;
  final Value<String> createdAt;
  const AddonsTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.price = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  AddonsTableCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.price = const Value.absent(),
    this.isActive = const Value.absent(),
    required String createdAt,
  })  : name = Value(name),
        createdAt = Value(createdAt);
  static Insertable<AddonsTableData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<double>? price,
    Expression<bool>? isActive,
    Expression<String>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (price != null) 'price': price,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  AddonsTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<double>? price,
      Value<bool>? isActive,
      Value<String>? createdAt}) {
    return AddonsTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (price.present) {
      map['price'] = Variable<double>(price.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AddonsTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('price: $price, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $TransactionsTableTable extends TransactionsTable
    with TableInfo<$TransactionsTableTable, TransactionsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _invoiceNumberMeta =
      const VerificationMeta('invoiceNumber');
  @override
  late final GeneratedColumn<String> invoiceNumber = GeneratedColumn<String>(
      'invoice_number', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _cashierIdMeta =
      const VerificationMeta('cashierId');
  @override
  late final GeneratedColumn<int> cashierId = GeneratedColumn<int>(
      'cashier_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES users (id)'));
  static const VerificationMeta _cashierNameMeta =
      const VerificationMeta('cashierName');
  @override
  late final GeneratedColumn<String> cashierName = GeneratedColumn<String>(
      'cashier_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _subtotalMeta =
      const VerificationMeta('subtotal');
  @override
  late final GeneratedColumn<double> subtotal = GeneratedColumn<double>(
      'subtotal', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _discountTypeMeta =
      const VerificationMeta('discountType');
  @override
  late final GeneratedColumn<String> discountType = GeneratedColumn<String>(
      'discount_type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('nominal'));
  static const VerificationMeta _discountValueMeta =
      const VerificationMeta('discountValue');
  @override
  late final GeneratedColumn<double> discountValue = GeneratedColumn<double>(
      'discount_value', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _discountAmountMeta =
      const VerificationMeta('discountAmount');
  @override
  late final GeneratedColumn<double> discountAmount = GeneratedColumn<double>(
      'discount_amount', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _taxPercentMeta =
      const VerificationMeta('taxPercent');
  @override
  late final GeneratedColumn<double> taxPercent = GeneratedColumn<double>(
      'tax_percent', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _taxAmountMeta =
      const VerificationMeta('taxAmount');
  @override
  late final GeneratedColumn<double> taxAmount = GeneratedColumn<double>(
      'tax_amount', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _servicePercentMeta =
      const VerificationMeta('servicePercent');
  @override
  late final GeneratedColumn<double> servicePercent = GeneratedColumn<double>(
      'service_percent', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _serviceAmountMeta =
      const VerificationMeta('serviceAmount');
  @override
  late final GeneratedColumn<double> serviceAmount = GeneratedColumn<double>(
      'service_amount', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _totalMeta = const VerificationMeta('total');
  @override
  late final GeneratedColumn<double> total = GeneratedColumn<double>(
      'total', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _paymentMethodMeta =
      const VerificationMeta('paymentMethod');
  @override
  late final GeneratedColumn<String> paymentMethod = GeneratedColumn<String>(
      'payment_method', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _paymentLabelMeta =
      const VerificationMeta('paymentLabel');
  @override
  late final GeneratedColumn<String> paymentLabel = GeneratedColumn<String>(
      'payment_label', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _amountPaidMeta =
      const VerificationMeta('amountPaid');
  @override
  late final GeneratedColumn<double> amountPaid = GeneratedColumn<double>(
      'amount_paid', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _changeAmountMeta =
      const VerificationMeta('changeAmount');
  @override
  late final GeneratedColumn<double> changeAmount = GeneratedColumn<double>(
      'change_amount', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        invoiceNumber,
        cashierId,
        cashierName,
        subtotal,
        discountType,
        discountValue,
        discountAmount,
        taxPercent,
        taxAmount,
        servicePercent,
        serviceAmount,
        total,
        paymentMethod,
        paymentLabel,
        amountPaid,
        changeAmount,
        note,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(
      Insertable<TransactionsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('invoice_number')) {
      context.handle(
          _invoiceNumberMeta,
          invoiceNumber.isAcceptableOrUnknown(
              data['invoice_number']!, _invoiceNumberMeta));
    } else if (isInserting) {
      context.missing(_invoiceNumberMeta);
    }
    if (data.containsKey('cashier_id')) {
      context.handle(_cashierIdMeta,
          cashierId.isAcceptableOrUnknown(data['cashier_id']!, _cashierIdMeta));
    } else if (isInserting) {
      context.missing(_cashierIdMeta);
    }
    if (data.containsKey('cashier_name')) {
      context.handle(
          _cashierNameMeta,
          cashierName.isAcceptableOrUnknown(
              data['cashier_name']!, _cashierNameMeta));
    } else if (isInserting) {
      context.missing(_cashierNameMeta);
    }
    if (data.containsKey('subtotal')) {
      context.handle(_subtotalMeta,
          subtotal.isAcceptableOrUnknown(data['subtotal']!, _subtotalMeta));
    }
    if (data.containsKey('discount_type')) {
      context.handle(
          _discountTypeMeta,
          discountType.isAcceptableOrUnknown(
              data['discount_type']!, _discountTypeMeta));
    }
    if (data.containsKey('discount_value')) {
      context.handle(
          _discountValueMeta,
          discountValue.isAcceptableOrUnknown(
              data['discount_value']!, _discountValueMeta));
    }
    if (data.containsKey('discount_amount')) {
      context.handle(
          _discountAmountMeta,
          discountAmount.isAcceptableOrUnknown(
              data['discount_amount']!, _discountAmountMeta));
    }
    if (data.containsKey('tax_percent')) {
      context.handle(
          _taxPercentMeta,
          taxPercent.isAcceptableOrUnknown(
              data['tax_percent']!, _taxPercentMeta));
    }
    if (data.containsKey('tax_amount')) {
      context.handle(_taxAmountMeta,
          taxAmount.isAcceptableOrUnknown(data['tax_amount']!, _taxAmountMeta));
    }
    if (data.containsKey('service_percent')) {
      context.handle(
          _servicePercentMeta,
          servicePercent.isAcceptableOrUnknown(
              data['service_percent']!, _servicePercentMeta));
    }
    if (data.containsKey('service_amount')) {
      context.handle(
          _serviceAmountMeta,
          serviceAmount.isAcceptableOrUnknown(
              data['service_amount']!, _serviceAmountMeta));
    }
    if (data.containsKey('total')) {
      context.handle(
          _totalMeta, total.isAcceptableOrUnknown(data['total']!, _totalMeta));
    }
    if (data.containsKey('payment_method')) {
      context.handle(
          _paymentMethodMeta,
          paymentMethod.isAcceptableOrUnknown(
              data['payment_method']!, _paymentMethodMeta));
    } else if (isInserting) {
      context.missing(_paymentMethodMeta);
    }
    if (data.containsKey('payment_label')) {
      context.handle(
          _paymentLabelMeta,
          paymentLabel.isAcceptableOrUnknown(
              data['payment_label']!, _paymentLabelMeta));
    }
    if (data.containsKey('amount_paid')) {
      context.handle(
          _amountPaidMeta,
          amountPaid.isAcceptableOrUnknown(
              data['amount_paid']!, _amountPaidMeta));
    }
    if (data.containsKey('change_amount')) {
      context.handle(
          _changeAmountMeta,
          changeAmount.isAcceptableOrUnknown(
              data['change_amount']!, _changeAmountMeta));
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TransactionsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransactionsTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      invoiceNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}invoice_number'])!,
      cashierId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}cashier_id'])!,
      cashierName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cashier_name'])!,
      subtotal: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}subtotal'])!,
      discountType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}discount_type'])!,
      discountValue: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}discount_value'])!,
      discountAmount: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}discount_amount'])!,
      taxPercent: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}tax_percent'])!,
      taxAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}tax_amount'])!,
      servicePercent: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}service_percent'])!,
      serviceAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}service_amount'])!,
      total: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}total'])!,
      paymentMethod: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payment_method'])!,
      paymentLabel: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payment_label']),
      amountPaid: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount_paid'])!,
      changeAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}change_amount'])!,
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $TransactionsTableTable createAlias(String alias) {
    return $TransactionsTableTable(attachedDatabase, alias);
  }
}

class TransactionsTableData extends DataClass
    implements Insertable<TransactionsTableData> {
  final int id;
  final String invoiceNumber;
  final int cashierId;
  final String cashierName;
  final double subtotal;
  final String discountType;
  final double discountValue;
  final double discountAmount;
  final double taxPercent;
  final double taxAmount;
  final double servicePercent;
  final double serviceAmount;
  final double total;
  final String paymentMethod;
  final String? paymentLabel;
  final double amountPaid;
  final double changeAmount;
  final String? note;
  final String createdAt;
  const TransactionsTableData(
      {required this.id,
      required this.invoiceNumber,
      required this.cashierId,
      required this.cashierName,
      required this.subtotal,
      required this.discountType,
      required this.discountValue,
      required this.discountAmount,
      required this.taxPercent,
      required this.taxAmount,
      required this.servicePercent,
      required this.serviceAmount,
      required this.total,
      required this.paymentMethod,
      this.paymentLabel,
      required this.amountPaid,
      required this.changeAmount,
      this.note,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['invoice_number'] = Variable<String>(invoiceNumber);
    map['cashier_id'] = Variable<int>(cashierId);
    map['cashier_name'] = Variable<String>(cashierName);
    map['subtotal'] = Variable<double>(subtotal);
    map['discount_type'] = Variable<String>(discountType);
    map['discount_value'] = Variable<double>(discountValue);
    map['discount_amount'] = Variable<double>(discountAmount);
    map['tax_percent'] = Variable<double>(taxPercent);
    map['tax_amount'] = Variable<double>(taxAmount);
    map['service_percent'] = Variable<double>(servicePercent);
    map['service_amount'] = Variable<double>(serviceAmount);
    map['total'] = Variable<double>(total);
    map['payment_method'] = Variable<String>(paymentMethod);
    if (!nullToAbsent || paymentLabel != null) {
      map['payment_label'] = Variable<String>(paymentLabel);
    }
    map['amount_paid'] = Variable<double>(amountPaid);
    map['change_amount'] = Variable<double>(changeAmount);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<String>(createdAt);
    return map;
  }

  TransactionsTableCompanion toCompanion(bool nullToAbsent) {
    return TransactionsTableCompanion(
      id: Value(id),
      invoiceNumber: Value(invoiceNumber),
      cashierId: Value(cashierId),
      cashierName: Value(cashierName),
      subtotal: Value(subtotal),
      discountType: Value(discountType),
      discountValue: Value(discountValue),
      discountAmount: Value(discountAmount),
      taxPercent: Value(taxPercent),
      taxAmount: Value(taxAmount),
      servicePercent: Value(servicePercent),
      serviceAmount: Value(serviceAmount),
      total: Value(total),
      paymentMethod: Value(paymentMethod),
      paymentLabel: paymentLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(paymentLabel),
      amountPaid: Value(amountPaid),
      changeAmount: Value(changeAmount),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
    );
  }

  factory TransactionsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransactionsTableData(
      id: serializer.fromJson<int>(json['id']),
      invoiceNumber: serializer.fromJson<String>(json['invoiceNumber']),
      cashierId: serializer.fromJson<int>(json['cashierId']),
      cashierName: serializer.fromJson<String>(json['cashierName']),
      subtotal: serializer.fromJson<double>(json['subtotal']),
      discountType: serializer.fromJson<String>(json['discountType']),
      discountValue: serializer.fromJson<double>(json['discountValue']),
      discountAmount: serializer.fromJson<double>(json['discountAmount']),
      taxPercent: serializer.fromJson<double>(json['taxPercent']),
      taxAmount: serializer.fromJson<double>(json['taxAmount']),
      servicePercent: serializer.fromJson<double>(json['servicePercent']),
      serviceAmount: serializer.fromJson<double>(json['serviceAmount']),
      total: serializer.fromJson<double>(json['total']),
      paymentMethod: serializer.fromJson<String>(json['paymentMethod']),
      paymentLabel: serializer.fromJson<String?>(json['paymentLabel']),
      amountPaid: serializer.fromJson<double>(json['amountPaid']),
      changeAmount: serializer.fromJson<double>(json['changeAmount']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'invoiceNumber': serializer.toJson<String>(invoiceNumber),
      'cashierId': serializer.toJson<int>(cashierId),
      'cashierName': serializer.toJson<String>(cashierName),
      'subtotal': serializer.toJson<double>(subtotal),
      'discountType': serializer.toJson<String>(discountType),
      'discountValue': serializer.toJson<double>(discountValue),
      'discountAmount': serializer.toJson<double>(discountAmount),
      'taxPercent': serializer.toJson<double>(taxPercent),
      'taxAmount': serializer.toJson<double>(taxAmount),
      'servicePercent': serializer.toJson<double>(servicePercent),
      'serviceAmount': serializer.toJson<double>(serviceAmount),
      'total': serializer.toJson<double>(total),
      'paymentMethod': serializer.toJson<String>(paymentMethod),
      'paymentLabel': serializer.toJson<String?>(paymentLabel),
      'amountPaid': serializer.toJson<double>(amountPaid),
      'changeAmount': serializer.toJson<double>(changeAmount),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<String>(createdAt),
    };
  }

  TransactionsTableData copyWith(
          {int? id,
          String? invoiceNumber,
          int? cashierId,
          String? cashierName,
          double? subtotal,
          String? discountType,
          double? discountValue,
          double? discountAmount,
          double? taxPercent,
          double? taxAmount,
          double? servicePercent,
          double? serviceAmount,
          double? total,
          String? paymentMethod,
          Value<String?> paymentLabel = const Value.absent(),
          double? amountPaid,
          double? changeAmount,
          Value<String?> note = const Value.absent(),
          String? createdAt}) =>
      TransactionsTableData(
        id: id ?? this.id,
        invoiceNumber: invoiceNumber ?? this.invoiceNumber,
        cashierId: cashierId ?? this.cashierId,
        cashierName: cashierName ?? this.cashierName,
        subtotal: subtotal ?? this.subtotal,
        discountType: discountType ?? this.discountType,
        discountValue: discountValue ?? this.discountValue,
        discountAmount: discountAmount ?? this.discountAmount,
        taxPercent: taxPercent ?? this.taxPercent,
        taxAmount: taxAmount ?? this.taxAmount,
        servicePercent: servicePercent ?? this.servicePercent,
        serviceAmount: serviceAmount ?? this.serviceAmount,
        total: total ?? this.total,
        paymentMethod: paymentMethod ?? this.paymentMethod,
        paymentLabel:
            paymentLabel.present ? paymentLabel.value : this.paymentLabel,
        amountPaid: amountPaid ?? this.amountPaid,
        changeAmount: changeAmount ?? this.changeAmount,
        note: note.present ? note.value : this.note,
        createdAt: createdAt ?? this.createdAt,
      );
  TransactionsTableData copyWithCompanion(TransactionsTableCompanion data) {
    return TransactionsTableData(
      id: data.id.present ? data.id.value : this.id,
      invoiceNumber: data.invoiceNumber.present
          ? data.invoiceNumber.value
          : this.invoiceNumber,
      cashierId: data.cashierId.present ? data.cashierId.value : this.cashierId,
      cashierName:
          data.cashierName.present ? data.cashierName.value : this.cashierName,
      subtotal: data.subtotal.present ? data.subtotal.value : this.subtotal,
      discountType: data.discountType.present
          ? data.discountType.value
          : this.discountType,
      discountValue: data.discountValue.present
          ? data.discountValue.value
          : this.discountValue,
      discountAmount: data.discountAmount.present
          ? data.discountAmount.value
          : this.discountAmount,
      taxPercent:
          data.taxPercent.present ? data.taxPercent.value : this.taxPercent,
      taxAmount: data.taxAmount.present ? data.taxAmount.value : this.taxAmount,
      servicePercent: data.servicePercent.present
          ? data.servicePercent.value
          : this.servicePercent,
      serviceAmount: data.serviceAmount.present
          ? data.serviceAmount.value
          : this.serviceAmount,
      total: data.total.present ? data.total.value : this.total,
      paymentMethod: data.paymentMethod.present
          ? data.paymentMethod.value
          : this.paymentMethod,
      paymentLabel: data.paymentLabel.present
          ? data.paymentLabel.value
          : this.paymentLabel,
      amountPaid:
          data.amountPaid.present ? data.amountPaid.value : this.amountPaid,
      changeAmount: data.changeAmount.present
          ? data.changeAmount.value
          : this.changeAmount,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsTableData(')
          ..write('id: $id, ')
          ..write('invoiceNumber: $invoiceNumber, ')
          ..write('cashierId: $cashierId, ')
          ..write('cashierName: $cashierName, ')
          ..write('subtotal: $subtotal, ')
          ..write('discountType: $discountType, ')
          ..write('discountValue: $discountValue, ')
          ..write('discountAmount: $discountAmount, ')
          ..write('taxPercent: $taxPercent, ')
          ..write('taxAmount: $taxAmount, ')
          ..write('servicePercent: $servicePercent, ')
          ..write('serviceAmount: $serviceAmount, ')
          ..write('total: $total, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('paymentLabel: $paymentLabel, ')
          ..write('amountPaid: $amountPaid, ')
          ..write('changeAmount: $changeAmount, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      invoiceNumber,
      cashierId,
      cashierName,
      subtotal,
      discountType,
      discountValue,
      discountAmount,
      taxPercent,
      taxAmount,
      servicePercent,
      serviceAmount,
      total,
      paymentMethod,
      paymentLabel,
      amountPaid,
      changeAmount,
      note,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionsTableData &&
          other.id == this.id &&
          other.invoiceNumber == this.invoiceNumber &&
          other.cashierId == this.cashierId &&
          other.cashierName == this.cashierName &&
          other.subtotal == this.subtotal &&
          other.discountType == this.discountType &&
          other.discountValue == this.discountValue &&
          other.discountAmount == this.discountAmount &&
          other.taxPercent == this.taxPercent &&
          other.taxAmount == this.taxAmount &&
          other.servicePercent == this.servicePercent &&
          other.serviceAmount == this.serviceAmount &&
          other.total == this.total &&
          other.paymentMethod == this.paymentMethod &&
          other.paymentLabel == this.paymentLabel &&
          other.amountPaid == this.amountPaid &&
          other.changeAmount == this.changeAmount &&
          other.note == this.note &&
          other.createdAt == this.createdAt);
}

class TransactionsTableCompanion
    extends UpdateCompanion<TransactionsTableData> {
  final Value<int> id;
  final Value<String> invoiceNumber;
  final Value<int> cashierId;
  final Value<String> cashierName;
  final Value<double> subtotal;
  final Value<String> discountType;
  final Value<double> discountValue;
  final Value<double> discountAmount;
  final Value<double> taxPercent;
  final Value<double> taxAmount;
  final Value<double> servicePercent;
  final Value<double> serviceAmount;
  final Value<double> total;
  final Value<String> paymentMethod;
  final Value<String?> paymentLabel;
  final Value<double> amountPaid;
  final Value<double> changeAmount;
  final Value<String?> note;
  final Value<String> createdAt;
  const TransactionsTableCompanion({
    this.id = const Value.absent(),
    this.invoiceNumber = const Value.absent(),
    this.cashierId = const Value.absent(),
    this.cashierName = const Value.absent(),
    this.subtotal = const Value.absent(),
    this.discountType = const Value.absent(),
    this.discountValue = const Value.absent(),
    this.discountAmount = const Value.absent(),
    this.taxPercent = const Value.absent(),
    this.taxAmount = const Value.absent(),
    this.servicePercent = const Value.absent(),
    this.serviceAmount = const Value.absent(),
    this.total = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.paymentLabel = const Value.absent(),
    this.amountPaid = const Value.absent(),
    this.changeAmount = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  TransactionsTableCompanion.insert({
    this.id = const Value.absent(),
    required String invoiceNumber,
    required int cashierId,
    required String cashierName,
    this.subtotal = const Value.absent(),
    this.discountType = const Value.absent(),
    this.discountValue = const Value.absent(),
    this.discountAmount = const Value.absent(),
    this.taxPercent = const Value.absent(),
    this.taxAmount = const Value.absent(),
    this.servicePercent = const Value.absent(),
    this.serviceAmount = const Value.absent(),
    this.total = const Value.absent(),
    required String paymentMethod,
    this.paymentLabel = const Value.absent(),
    this.amountPaid = const Value.absent(),
    this.changeAmount = const Value.absent(),
    this.note = const Value.absent(),
    required String createdAt,
  })  : invoiceNumber = Value(invoiceNumber),
        cashierId = Value(cashierId),
        cashierName = Value(cashierName),
        paymentMethod = Value(paymentMethod),
        createdAt = Value(createdAt);
  static Insertable<TransactionsTableData> custom({
    Expression<int>? id,
    Expression<String>? invoiceNumber,
    Expression<int>? cashierId,
    Expression<String>? cashierName,
    Expression<double>? subtotal,
    Expression<String>? discountType,
    Expression<double>? discountValue,
    Expression<double>? discountAmount,
    Expression<double>? taxPercent,
    Expression<double>? taxAmount,
    Expression<double>? servicePercent,
    Expression<double>? serviceAmount,
    Expression<double>? total,
    Expression<String>? paymentMethod,
    Expression<String>? paymentLabel,
    Expression<double>? amountPaid,
    Expression<double>? changeAmount,
    Expression<String>? note,
    Expression<String>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (invoiceNumber != null) 'invoice_number': invoiceNumber,
      if (cashierId != null) 'cashier_id': cashierId,
      if (cashierName != null) 'cashier_name': cashierName,
      if (subtotal != null) 'subtotal': subtotal,
      if (discountType != null) 'discount_type': discountType,
      if (discountValue != null) 'discount_value': discountValue,
      if (discountAmount != null) 'discount_amount': discountAmount,
      if (taxPercent != null) 'tax_percent': taxPercent,
      if (taxAmount != null) 'tax_amount': taxAmount,
      if (servicePercent != null) 'service_percent': servicePercent,
      if (serviceAmount != null) 'service_amount': serviceAmount,
      if (total != null) 'total': total,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (paymentLabel != null) 'payment_label': paymentLabel,
      if (amountPaid != null) 'amount_paid': amountPaid,
      if (changeAmount != null) 'change_amount': changeAmount,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  TransactionsTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? invoiceNumber,
      Value<int>? cashierId,
      Value<String>? cashierName,
      Value<double>? subtotal,
      Value<String>? discountType,
      Value<double>? discountValue,
      Value<double>? discountAmount,
      Value<double>? taxPercent,
      Value<double>? taxAmount,
      Value<double>? servicePercent,
      Value<double>? serviceAmount,
      Value<double>? total,
      Value<String>? paymentMethod,
      Value<String?>? paymentLabel,
      Value<double>? amountPaid,
      Value<double>? changeAmount,
      Value<String?>? note,
      Value<String>? createdAt}) {
    return TransactionsTableCompanion(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      cashierId: cashierId ?? this.cashierId,
      cashierName: cashierName ?? this.cashierName,
      subtotal: subtotal ?? this.subtotal,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      discountAmount: discountAmount ?? this.discountAmount,
      taxPercent: taxPercent ?? this.taxPercent,
      taxAmount: taxAmount ?? this.taxAmount,
      servicePercent: servicePercent ?? this.servicePercent,
      serviceAmount: serviceAmount ?? this.serviceAmount,
      total: total ?? this.total,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentLabel: paymentLabel ?? this.paymentLabel,
      amountPaid: amountPaid ?? this.amountPaid,
      changeAmount: changeAmount ?? this.changeAmount,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (invoiceNumber.present) {
      map['invoice_number'] = Variable<String>(invoiceNumber.value);
    }
    if (cashierId.present) {
      map['cashier_id'] = Variable<int>(cashierId.value);
    }
    if (cashierName.present) {
      map['cashier_name'] = Variable<String>(cashierName.value);
    }
    if (subtotal.present) {
      map['subtotal'] = Variable<double>(subtotal.value);
    }
    if (discountType.present) {
      map['discount_type'] = Variable<String>(discountType.value);
    }
    if (discountValue.present) {
      map['discount_value'] = Variable<double>(discountValue.value);
    }
    if (discountAmount.present) {
      map['discount_amount'] = Variable<double>(discountAmount.value);
    }
    if (taxPercent.present) {
      map['tax_percent'] = Variable<double>(taxPercent.value);
    }
    if (taxAmount.present) {
      map['tax_amount'] = Variable<double>(taxAmount.value);
    }
    if (servicePercent.present) {
      map['service_percent'] = Variable<double>(servicePercent.value);
    }
    if (serviceAmount.present) {
      map['service_amount'] = Variable<double>(serviceAmount.value);
    }
    if (total.present) {
      map['total'] = Variable<double>(total.value);
    }
    if (paymentMethod.present) {
      map['payment_method'] = Variable<String>(paymentMethod.value);
    }
    if (paymentLabel.present) {
      map['payment_label'] = Variable<String>(paymentLabel.value);
    }
    if (amountPaid.present) {
      map['amount_paid'] = Variable<double>(amountPaid.value);
    }
    if (changeAmount.present) {
      map['change_amount'] = Variable<double>(changeAmount.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsTableCompanion(')
          ..write('id: $id, ')
          ..write('invoiceNumber: $invoiceNumber, ')
          ..write('cashierId: $cashierId, ')
          ..write('cashierName: $cashierName, ')
          ..write('subtotal: $subtotal, ')
          ..write('discountType: $discountType, ')
          ..write('discountValue: $discountValue, ')
          ..write('discountAmount: $discountAmount, ')
          ..write('taxPercent: $taxPercent, ')
          ..write('taxAmount: $taxAmount, ')
          ..write('servicePercent: $servicePercent, ')
          ..write('serviceAmount: $serviceAmount, ')
          ..write('total: $total, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('paymentLabel: $paymentLabel, ')
          ..write('amountPaid: $amountPaid, ')
          ..write('changeAmount: $changeAmount, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $TransactionItemsTableTable extends TransactionItemsTable
    with TableInfo<$TransactionItemsTableTable, TransactionItemsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionItemsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _transactionIdMeta =
      const VerificationMeta('transactionId');
  @override
  late final GeneratedColumn<int> transactionId = GeneratedColumn<int>(
      'transaction_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES transactions (id)'));
  static const VerificationMeta _productIdMeta =
      const VerificationMeta('productId');
  @override
  late final GeneratedColumn<int> productId = GeneratedColumn<int>(
      'product_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _productNameSnapshotMeta =
      const VerificationMeta('productNameSnapshot');
  @override
  late final GeneratedColumn<String> productNameSnapshot =
      GeneratedColumn<String>('product_name_snapshot', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _variantNameSnapshotMeta =
      const VerificationMeta('variantNameSnapshot');
  @override
  late final GeneratedColumn<String> variantNameSnapshot =
      GeneratedColumn<String>('variant_name_snapshot', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _addonNamesSnapshotMeta =
      const VerificationMeta('addonNamesSnapshot');
  @override
  late final GeneratedColumn<String> addonNamesSnapshot =
      GeneratedColumn<String>('addon_names_snapshot', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _unitPriceMeta =
      const VerificationMeta('unitPrice');
  @override
  late final GeneratedColumn<double> unitPrice = GeneratedColumn<double>(
      'unit_price', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _qtyMeta = const VerificationMeta('qty');
  @override
  late final GeneratedColumn<int> qty = GeneratedColumn<int>(
      'qty', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _totalMeta = const VerificationMeta('total');
  @override
  late final GeneratedColumn<double> total = GeneratedColumn<double>(
      'total', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        transactionId,
        productId,
        productNameSnapshot,
        variantNameSnapshot,
        addonNamesSnapshot,
        unitPrice,
        qty,
        note,
        total
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transaction_items';
  @override
  VerificationContext validateIntegrity(
      Insertable<TransactionItemsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('transaction_id')) {
      context.handle(
          _transactionIdMeta,
          transactionId.isAcceptableOrUnknown(
              data['transaction_id']!, _transactionIdMeta));
    } else if (isInserting) {
      context.missing(_transactionIdMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(_productIdMeta,
          productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta));
    }
    if (data.containsKey('product_name_snapshot')) {
      context.handle(
          _productNameSnapshotMeta,
          productNameSnapshot.isAcceptableOrUnknown(
              data['product_name_snapshot']!, _productNameSnapshotMeta));
    } else if (isInserting) {
      context.missing(_productNameSnapshotMeta);
    }
    if (data.containsKey('variant_name_snapshot')) {
      context.handle(
          _variantNameSnapshotMeta,
          variantNameSnapshot.isAcceptableOrUnknown(
              data['variant_name_snapshot']!, _variantNameSnapshotMeta));
    }
    if (data.containsKey('addon_names_snapshot')) {
      context.handle(
          _addonNamesSnapshotMeta,
          addonNamesSnapshot.isAcceptableOrUnknown(
              data['addon_names_snapshot']!, _addonNamesSnapshotMeta));
    }
    if (data.containsKey('unit_price')) {
      context.handle(_unitPriceMeta,
          unitPrice.isAcceptableOrUnknown(data['unit_price']!, _unitPriceMeta));
    } else if (isInserting) {
      context.missing(_unitPriceMeta);
    }
    if (data.containsKey('qty')) {
      context.handle(
          _qtyMeta, qty.isAcceptableOrUnknown(data['qty']!, _qtyMeta));
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('total')) {
      context.handle(
          _totalMeta, total.isAcceptableOrUnknown(data['total']!, _totalMeta));
    } else if (isInserting) {
      context.missing(_totalMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TransactionItemsTableData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransactionItemsTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      transactionId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}transaction_id'])!,
      productId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}product_id']),
      productNameSnapshot: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}product_name_snapshot'])!,
      variantNameSnapshot: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}variant_name_snapshot']),
      addonNamesSnapshot: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}addon_names_snapshot']),
      unitPrice: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}unit_price'])!,
      qty: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}qty'])!,
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
      total: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}total'])!,
    );
  }

  @override
  $TransactionItemsTableTable createAlias(String alias) {
    return $TransactionItemsTableTable(attachedDatabase, alias);
  }
}

class TransactionItemsTableData extends DataClass
    implements Insertable<TransactionItemsTableData> {
  final int id;
  final int transactionId;
  final int? productId;
  final String productNameSnapshot;
  final String? variantNameSnapshot;
  final String? addonNamesSnapshot;
  final double unitPrice;
  final int qty;
  final String? note;
  final double total;
  const TransactionItemsTableData(
      {required this.id,
      required this.transactionId,
      this.productId,
      required this.productNameSnapshot,
      this.variantNameSnapshot,
      this.addonNamesSnapshot,
      required this.unitPrice,
      required this.qty,
      this.note,
      required this.total});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['transaction_id'] = Variable<int>(transactionId);
    if (!nullToAbsent || productId != null) {
      map['product_id'] = Variable<int>(productId);
    }
    map['product_name_snapshot'] = Variable<String>(productNameSnapshot);
    if (!nullToAbsent || variantNameSnapshot != null) {
      map['variant_name_snapshot'] = Variable<String>(variantNameSnapshot);
    }
    if (!nullToAbsent || addonNamesSnapshot != null) {
      map['addon_names_snapshot'] = Variable<String>(addonNamesSnapshot);
    }
    map['unit_price'] = Variable<double>(unitPrice);
    map['qty'] = Variable<int>(qty);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['total'] = Variable<double>(total);
    return map;
  }

  TransactionItemsTableCompanion toCompanion(bool nullToAbsent) {
    return TransactionItemsTableCompanion(
      id: Value(id),
      transactionId: Value(transactionId),
      productId: productId == null && nullToAbsent
          ? const Value.absent()
          : Value(productId),
      productNameSnapshot: Value(productNameSnapshot),
      variantNameSnapshot: variantNameSnapshot == null && nullToAbsent
          ? const Value.absent()
          : Value(variantNameSnapshot),
      addonNamesSnapshot: addonNamesSnapshot == null && nullToAbsent
          ? const Value.absent()
          : Value(addonNamesSnapshot),
      unitPrice: Value(unitPrice),
      qty: Value(qty),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      total: Value(total),
    );
  }

  factory TransactionItemsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransactionItemsTableData(
      id: serializer.fromJson<int>(json['id']),
      transactionId: serializer.fromJson<int>(json['transactionId']),
      productId: serializer.fromJson<int?>(json['productId']),
      productNameSnapshot:
          serializer.fromJson<String>(json['productNameSnapshot']),
      variantNameSnapshot:
          serializer.fromJson<String?>(json['variantNameSnapshot']),
      addonNamesSnapshot:
          serializer.fromJson<String?>(json['addonNamesSnapshot']),
      unitPrice: serializer.fromJson<double>(json['unitPrice']),
      qty: serializer.fromJson<int>(json['qty']),
      note: serializer.fromJson<String?>(json['note']),
      total: serializer.fromJson<double>(json['total']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'transactionId': serializer.toJson<int>(transactionId),
      'productId': serializer.toJson<int?>(productId),
      'productNameSnapshot': serializer.toJson<String>(productNameSnapshot),
      'variantNameSnapshot': serializer.toJson<String?>(variantNameSnapshot),
      'addonNamesSnapshot': serializer.toJson<String?>(addonNamesSnapshot),
      'unitPrice': serializer.toJson<double>(unitPrice),
      'qty': serializer.toJson<int>(qty),
      'note': serializer.toJson<String?>(note),
      'total': serializer.toJson<double>(total),
    };
  }

  TransactionItemsTableData copyWith(
          {int? id,
          int? transactionId,
          Value<int?> productId = const Value.absent(),
          String? productNameSnapshot,
          Value<String?> variantNameSnapshot = const Value.absent(),
          Value<String?> addonNamesSnapshot = const Value.absent(),
          double? unitPrice,
          int? qty,
          Value<String?> note = const Value.absent(),
          double? total}) =>
      TransactionItemsTableData(
        id: id ?? this.id,
        transactionId: transactionId ?? this.transactionId,
        productId: productId.present ? productId.value : this.productId,
        productNameSnapshot: productNameSnapshot ?? this.productNameSnapshot,
        variantNameSnapshot: variantNameSnapshot.present
            ? variantNameSnapshot.value
            : this.variantNameSnapshot,
        addonNamesSnapshot: addonNamesSnapshot.present
            ? addonNamesSnapshot.value
            : this.addonNamesSnapshot,
        unitPrice: unitPrice ?? this.unitPrice,
        qty: qty ?? this.qty,
        note: note.present ? note.value : this.note,
        total: total ?? this.total,
      );
  TransactionItemsTableData copyWithCompanion(
      TransactionItemsTableCompanion data) {
    return TransactionItemsTableData(
      id: data.id.present ? data.id.value : this.id,
      transactionId: data.transactionId.present
          ? data.transactionId.value
          : this.transactionId,
      productId: data.productId.present ? data.productId.value : this.productId,
      productNameSnapshot: data.productNameSnapshot.present
          ? data.productNameSnapshot.value
          : this.productNameSnapshot,
      variantNameSnapshot: data.variantNameSnapshot.present
          ? data.variantNameSnapshot.value
          : this.variantNameSnapshot,
      addonNamesSnapshot: data.addonNamesSnapshot.present
          ? data.addonNamesSnapshot.value
          : this.addonNamesSnapshot,
      unitPrice: data.unitPrice.present ? data.unitPrice.value : this.unitPrice,
      qty: data.qty.present ? data.qty.value : this.qty,
      note: data.note.present ? data.note.value : this.note,
      total: data.total.present ? data.total.value : this.total,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransactionItemsTableData(')
          ..write('id: $id, ')
          ..write('transactionId: $transactionId, ')
          ..write('productId: $productId, ')
          ..write('productNameSnapshot: $productNameSnapshot, ')
          ..write('variantNameSnapshot: $variantNameSnapshot, ')
          ..write('addonNamesSnapshot: $addonNamesSnapshot, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('qty: $qty, ')
          ..write('note: $note, ')
          ..write('total: $total')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      transactionId,
      productId,
      productNameSnapshot,
      variantNameSnapshot,
      addonNamesSnapshot,
      unitPrice,
      qty,
      note,
      total);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionItemsTableData &&
          other.id == this.id &&
          other.transactionId == this.transactionId &&
          other.productId == this.productId &&
          other.productNameSnapshot == this.productNameSnapshot &&
          other.variantNameSnapshot == this.variantNameSnapshot &&
          other.addonNamesSnapshot == this.addonNamesSnapshot &&
          other.unitPrice == this.unitPrice &&
          other.qty == this.qty &&
          other.note == this.note &&
          other.total == this.total);
}

class TransactionItemsTableCompanion
    extends UpdateCompanion<TransactionItemsTableData> {
  final Value<int> id;
  final Value<int> transactionId;
  final Value<int?> productId;
  final Value<String> productNameSnapshot;
  final Value<String?> variantNameSnapshot;
  final Value<String?> addonNamesSnapshot;
  final Value<double> unitPrice;
  final Value<int> qty;
  final Value<String?> note;
  final Value<double> total;
  const TransactionItemsTableCompanion({
    this.id = const Value.absent(),
    this.transactionId = const Value.absent(),
    this.productId = const Value.absent(),
    this.productNameSnapshot = const Value.absent(),
    this.variantNameSnapshot = const Value.absent(),
    this.addonNamesSnapshot = const Value.absent(),
    this.unitPrice = const Value.absent(),
    this.qty = const Value.absent(),
    this.note = const Value.absent(),
    this.total = const Value.absent(),
  });
  TransactionItemsTableCompanion.insert({
    this.id = const Value.absent(),
    required int transactionId,
    this.productId = const Value.absent(),
    required String productNameSnapshot,
    this.variantNameSnapshot = const Value.absent(),
    this.addonNamesSnapshot = const Value.absent(),
    required double unitPrice,
    this.qty = const Value.absent(),
    this.note = const Value.absent(),
    required double total,
  })  : transactionId = Value(transactionId),
        productNameSnapshot = Value(productNameSnapshot),
        unitPrice = Value(unitPrice),
        total = Value(total);
  static Insertable<TransactionItemsTableData> custom({
    Expression<int>? id,
    Expression<int>? transactionId,
    Expression<int>? productId,
    Expression<String>? productNameSnapshot,
    Expression<String>? variantNameSnapshot,
    Expression<String>? addonNamesSnapshot,
    Expression<double>? unitPrice,
    Expression<int>? qty,
    Expression<String>? note,
    Expression<double>? total,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (transactionId != null) 'transaction_id': transactionId,
      if (productId != null) 'product_id': productId,
      if (productNameSnapshot != null)
        'product_name_snapshot': productNameSnapshot,
      if (variantNameSnapshot != null)
        'variant_name_snapshot': variantNameSnapshot,
      if (addonNamesSnapshot != null)
        'addon_names_snapshot': addonNamesSnapshot,
      if (unitPrice != null) 'unit_price': unitPrice,
      if (qty != null) 'qty': qty,
      if (note != null) 'note': note,
      if (total != null) 'total': total,
    });
  }

  TransactionItemsTableCompanion copyWith(
      {Value<int>? id,
      Value<int>? transactionId,
      Value<int?>? productId,
      Value<String>? productNameSnapshot,
      Value<String?>? variantNameSnapshot,
      Value<String?>? addonNamesSnapshot,
      Value<double>? unitPrice,
      Value<int>? qty,
      Value<String?>? note,
      Value<double>? total}) {
    return TransactionItemsTableCompanion(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      productId: productId ?? this.productId,
      productNameSnapshot: productNameSnapshot ?? this.productNameSnapshot,
      variantNameSnapshot: variantNameSnapshot ?? this.variantNameSnapshot,
      addonNamesSnapshot: addonNamesSnapshot ?? this.addonNamesSnapshot,
      unitPrice: unitPrice ?? this.unitPrice,
      qty: qty ?? this.qty,
      note: note ?? this.note,
      total: total ?? this.total,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (transactionId.present) {
      map['transaction_id'] = Variable<int>(transactionId.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<int>(productId.value);
    }
    if (productNameSnapshot.present) {
      map['product_name_snapshot'] =
          Variable<String>(productNameSnapshot.value);
    }
    if (variantNameSnapshot.present) {
      map['variant_name_snapshot'] =
          Variable<String>(variantNameSnapshot.value);
    }
    if (addonNamesSnapshot.present) {
      map['addon_names_snapshot'] = Variable<String>(addonNamesSnapshot.value);
    }
    if (unitPrice.present) {
      map['unit_price'] = Variable<double>(unitPrice.value);
    }
    if (qty.present) {
      map['qty'] = Variable<int>(qty.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (total.present) {
      map['total'] = Variable<double>(total.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionItemsTableCompanion(')
          ..write('id: $id, ')
          ..write('transactionId: $transactionId, ')
          ..write('productId: $productId, ')
          ..write('productNameSnapshot: $productNameSnapshot, ')
          ..write('variantNameSnapshot: $variantNameSnapshot, ')
          ..write('addonNamesSnapshot: $addonNamesSnapshot, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('qty: $qty, ')
          ..write('note: $note, ')
          ..write('total: $total')
          ..write(')'))
        .toString();
  }
}

class $SettingsTableTable extends SettingsTable
    with TableInfo<$SettingsTableTable, SettingsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _storeNameMeta =
      const VerificationMeta('storeName');
  @override
  late final GeneratedColumn<String> storeName = GeneratedColumn<String>(
      'store_name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('Coffee Shop'));
  static const VerificationMeta _storeAddressMeta =
      const VerificationMeta('storeAddress');
  @override
  late final GeneratedColumn<String> storeAddress = GeneratedColumn<String>(
      'store_address', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _storePhoneMeta =
      const VerificationMeta('storePhone');
  @override
  late final GeneratedColumn<String> storePhone = GeneratedColumn<String>(
      'store_phone', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _storeFooterMeta =
      const VerificationMeta('storeFooter');
  @override
  late final GeneratedColumn<String> storeFooter = GeneratedColumn<String>(
      'store_footer', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('Terima kasih atas kunjungan Anda'));
  static const VerificationMeta _taxPercentMeta =
      const VerificationMeta('taxPercent');
  @override
  late final GeneratedColumn<double> taxPercent = GeneratedColumn<double>(
      'tax_percent', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _servicePercentMeta =
      const VerificationMeta('servicePercent');
  @override
  late final GeneratedColumn<double> servicePercent = GeneratedColumn<double>(
      'service_percent', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _currencySymbolMeta =
      const VerificationMeta('currencySymbol');
  @override
  late final GeneratedColumn<String> currencySymbol = GeneratedColumn<String>(
      'currency_symbol', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('Rp'));
  static const VerificationMeta _logoPathMeta =
      const VerificationMeta('logoPath');
  @override
  late final GeneratedColumn<String> logoPath = GeneratedColumn<String>(
      'logo_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        storeName,
        storeAddress,
        storePhone,
        storeFooter,
        taxPercent,
        servicePercent,
        currencySymbol,
        logoPath,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(Insertable<SettingsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('store_name')) {
      context.handle(_storeNameMeta,
          storeName.isAcceptableOrUnknown(data['store_name']!, _storeNameMeta));
    }
    if (data.containsKey('store_address')) {
      context.handle(
          _storeAddressMeta,
          storeAddress.isAcceptableOrUnknown(
              data['store_address']!, _storeAddressMeta));
    }
    if (data.containsKey('store_phone')) {
      context.handle(
          _storePhoneMeta,
          storePhone.isAcceptableOrUnknown(
              data['store_phone']!, _storePhoneMeta));
    }
    if (data.containsKey('store_footer')) {
      context.handle(
          _storeFooterMeta,
          storeFooter.isAcceptableOrUnknown(
              data['store_footer']!, _storeFooterMeta));
    }
    if (data.containsKey('tax_percent')) {
      context.handle(
          _taxPercentMeta,
          taxPercent.isAcceptableOrUnknown(
              data['tax_percent']!, _taxPercentMeta));
    }
    if (data.containsKey('service_percent')) {
      context.handle(
          _servicePercentMeta,
          servicePercent.isAcceptableOrUnknown(
              data['service_percent']!, _servicePercentMeta));
    }
    if (data.containsKey('currency_symbol')) {
      context.handle(
          _currencySymbolMeta,
          currencySymbol.isAcceptableOrUnknown(
              data['currency_symbol']!, _currencySymbolMeta));
    }
    if (data.containsKey('logo_path')) {
      context.handle(_logoPathMeta,
          logoPath.isAcceptableOrUnknown(data['logo_path']!, _logoPathMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SettingsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingsTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      storeName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}store_name'])!,
      storeAddress: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}store_address']),
      storePhone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}store_phone']),
      storeFooter: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}store_footer'])!,
      taxPercent: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}tax_percent'])!,
      servicePercent: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}service_percent'])!,
      currencySymbol: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}currency_symbol'])!,
      logoPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}logo_path']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $SettingsTableTable createAlias(String alias) {
    return $SettingsTableTable(attachedDatabase, alias);
  }
}

class SettingsTableData extends DataClass
    implements Insertable<SettingsTableData> {
  final int id;
  final String storeName;
  final String? storeAddress;
  final String? storePhone;
  final String storeFooter;
  final double taxPercent;
  final double servicePercent;
  final String currencySymbol;
  final String? logoPath;
  final String updatedAt;
  const SettingsTableData(
      {required this.id,
      required this.storeName,
      this.storeAddress,
      this.storePhone,
      required this.storeFooter,
      required this.taxPercent,
      required this.servicePercent,
      required this.currencySymbol,
      this.logoPath,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['store_name'] = Variable<String>(storeName);
    if (!nullToAbsent || storeAddress != null) {
      map['store_address'] = Variable<String>(storeAddress);
    }
    if (!nullToAbsent || storePhone != null) {
      map['store_phone'] = Variable<String>(storePhone);
    }
    map['store_footer'] = Variable<String>(storeFooter);
    map['tax_percent'] = Variable<double>(taxPercent);
    map['service_percent'] = Variable<double>(servicePercent);
    map['currency_symbol'] = Variable<String>(currencySymbol);
    if (!nullToAbsent || logoPath != null) {
      map['logo_path'] = Variable<String>(logoPath);
    }
    map['updated_at'] = Variable<String>(updatedAt);
    return map;
  }

  SettingsTableCompanion toCompanion(bool nullToAbsent) {
    return SettingsTableCompanion(
      id: Value(id),
      storeName: Value(storeName),
      storeAddress: storeAddress == null && nullToAbsent
          ? const Value.absent()
          : Value(storeAddress),
      storePhone: storePhone == null && nullToAbsent
          ? const Value.absent()
          : Value(storePhone),
      storeFooter: Value(storeFooter),
      taxPercent: Value(taxPercent),
      servicePercent: Value(servicePercent),
      currencySymbol: Value(currencySymbol),
      logoPath: logoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(logoPath),
      updatedAt: Value(updatedAt),
    );
  }

  factory SettingsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingsTableData(
      id: serializer.fromJson<int>(json['id']),
      storeName: serializer.fromJson<String>(json['storeName']),
      storeAddress: serializer.fromJson<String?>(json['storeAddress']),
      storePhone: serializer.fromJson<String?>(json['storePhone']),
      storeFooter: serializer.fromJson<String>(json['storeFooter']),
      taxPercent: serializer.fromJson<double>(json['taxPercent']),
      servicePercent: serializer.fromJson<double>(json['servicePercent']),
      currencySymbol: serializer.fromJson<String>(json['currencySymbol']),
      logoPath: serializer.fromJson<String?>(json['logoPath']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'storeName': serializer.toJson<String>(storeName),
      'storeAddress': serializer.toJson<String?>(storeAddress),
      'storePhone': serializer.toJson<String?>(storePhone),
      'storeFooter': serializer.toJson<String>(storeFooter),
      'taxPercent': serializer.toJson<double>(taxPercent),
      'servicePercent': serializer.toJson<double>(servicePercent),
      'currencySymbol': serializer.toJson<String>(currencySymbol),
      'logoPath': serializer.toJson<String?>(logoPath),
      'updatedAt': serializer.toJson<String>(updatedAt),
    };
  }

  SettingsTableData copyWith(
          {int? id,
          String? storeName,
          Value<String?> storeAddress = const Value.absent(),
          Value<String?> storePhone = const Value.absent(),
          String? storeFooter,
          double? taxPercent,
          double? servicePercent,
          String? currencySymbol,
          Value<String?> logoPath = const Value.absent(),
          String? updatedAt}) =>
      SettingsTableData(
        id: id ?? this.id,
        storeName: storeName ?? this.storeName,
        storeAddress:
            storeAddress.present ? storeAddress.value : this.storeAddress,
        storePhone: storePhone.present ? storePhone.value : this.storePhone,
        storeFooter: storeFooter ?? this.storeFooter,
        taxPercent: taxPercent ?? this.taxPercent,
        servicePercent: servicePercent ?? this.servicePercent,
        currencySymbol: currencySymbol ?? this.currencySymbol,
        logoPath: logoPath.present ? logoPath.value : this.logoPath,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  SettingsTableData copyWithCompanion(SettingsTableCompanion data) {
    return SettingsTableData(
      id: data.id.present ? data.id.value : this.id,
      storeName: data.storeName.present ? data.storeName.value : this.storeName,
      storeAddress: data.storeAddress.present
          ? data.storeAddress.value
          : this.storeAddress,
      storePhone:
          data.storePhone.present ? data.storePhone.value : this.storePhone,
      storeFooter:
          data.storeFooter.present ? data.storeFooter.value : this.storeFooter,
      taxPercent:
          data.taxPercent.present ? data.taxPercent.value : this.taxPercent,
      servicePercent: data.servicePercent.present
          ? data.servicePercent.value
          : this.servicePercent,
      currencySymbol: data.currencySymbol.present
          ? data.currencySymbol.value
          : this.currencySymbol,
      logoPath: data.logoPath.present ? data.logoPath.value : this.logoPath,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingsTableData(')
          ..write('id: $id, ')
          ..write('storeName: $storeName, ')
          ..write('storeAddress: $storeAddress, ')
          ..write('storePhone: $storePhone, ')
          ..write('storeFooter: $storeFooter, ')
          ..write('taxPercent: $taxPercent, ')
          ..write('servicePercent: $servicePercent, ')
          ..write('currencySymbol: $currencySymbol, ')
          ..write('logoPath: $logoPath, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      storeName,
      storeAddress,
      storePhone,
      storeFooter,
      taxPercent,
      servicePercent,
      currencySymbol,
      logoPath,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingsTableData &&
          other.id == this.id &&
          other.storeName == this.storeName &&
          other.storeAddress == this.storeAddress &&
          other.storePhone == this.storePhone &&
          other.storeFooter == this.storeFooter &&
          other.taxPercent == this.taxPercent &&
          other.servicePercent == this.servicePercent &&
          other.currencySymbol == this.currencySymbol &&
          other.logoPath == this.logoPath &&
          other.updatedAt == this.updatedAt);
}

class SettingsTableCompanion extends UpdateCompanion<SettingsTableData> {
  final Value<int> id;
  final Value<String> storeName;
  final Value<String?> storeAddress;
  final Value<String?> storePhone;
  final Value<String> storeFooter;
  final Value<double> taxPercent;
  final Value<double> servicePercent;
  final Value<String> currencySymbol;
  final Value<String?> logoPath;
  final Value<String> updatedAt;
  const SettingsTableCompanion({
    this.id = const Value.absent(),
    this.storeName = const Value.absent(),
    this.storeAddress = const Value.absent(),
    this.storePhone = const Value.absent(),
    this.storeFooter = const Value.absent(),
    this.taxPercent = const Value.absent(),
    this.servicePercent = const Value.absent(),
    this.currencySymbol = const Value.absent(),
    this.logoPath = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  SettingsTableCompanion.insert({
    this.id = const Value.absent(),
    this.storeName = const Value.absent(),
    this.storeAddress = const Value.absent(),
    this.storePhone = const Value.absent(),
    this.storeFooter = const Value.absent(),
    this.taxPercent = const Value.absent(),
    this.servicePercent = const Value.absent(),
    this.currencySymbol = const Value.absent(),
    this.logoPath = const Value.absent(),
    required String updatedAt,
  }) : updatedAt = Value(updatedAt);
  static Insertable<SettingsTableData> custom({
    Expression<int>? id,
    Expression<String>? storeName,
    Expression<String>? storeAddress,
    Expression<String>? storePhone,
    Expression<String>? storeFooter,
    Expression<double>? taxPercent,
    Expression<double>? servicePercent,
    Expression<String>? currencySymbol,
    Expression<String>? logoPath,
    Expression<String>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (storeName != null) 'store_name': storeName,
      if (storeAddress != null) 'store_address': storeAddress,
      if (storePhone != null) 'store_phone': storePhone,
      if (storeFooter != null) 'store_footer': storeFooter,
      if (taxPercent != null) 'tax_percent': taxPercent,
      if (servicePercent != null) 'service_percent': servicePercent,
      if (currencySymbol != null) 'currency_symbol': currencySymbol,
      if (logoPath != null) 'logo_path': logoPath,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  SettingsTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? storeName,
      Value<String?>? storeAddress,
      Value<String?>? storePhone,
      Value<String>? storeFooter,
      Value<double>? taxPercent,
      Value<double>? servicePercent,
      Value<String>? currencySymbol,
      Value<String?>? logoPath,
      Value<String>? updatedAt}) {
    return SettingsTableCompanion(
      id: id ?? this.id,
      storeName: storeName ?? this.storeName,
      storeAddress: storeAddress ?? this.storeAddress,
      storePhone: storePhone ?? this.storePhone,
      storeFooter: storeFooter ?? this.storeFooter,
      taxPercent: taxPercent ?? this.taxPercent,
      servicePercent: servicePercent ?? this.servicePercent,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      logoPath: logoPath ?? this.logoPath,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (storeName.present) {
      map['store_name'] = Variable<String>(storeName.value);
    }
    if (storeAddress.present) {
      map['store_address'] = Variable<String>(storeAddress.value);
    }
    if (storePhone.present) {
      map['store_phone'] = Variable<String>(storePhone.value);
    }
    if (storeFooter.present) {
      map['store_footer'] = Variable<String>(storeFooter.value);
    }
    if (taxPercent.present) {
      map['tax_percent'] = Variable<double>(taxPercent.value);
    }
    if (servicePercent.present) {
      map['service_percent'] = Variable<double>(servicePercent.value);
    }
    if (currencySymbol.present) {
      map['currency_symbol'] = Variable<String>(currencySymbol.value);
    }
    if (logoPath.present) {
      map['logo_path'] = Variable<String>(logoPath.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsTableCompanion(')
          ..write('id: $id, ')
          ..write('storeName: $storeName, ')
          ..write('storeAddress: $storeAddress, ')
          ..write('storePhone: $storePhone, ')
          ..write('storeFooter: $storeFooter, ')
          ..write('taxPercent: $taxPercent, ')
          ..write('servicePercent: $servicePercent, ')
          ..write('currencySymbol: $currencySymbol, ')
          ..write('logoPath: $logoPath, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UsersTableTable usersTable = $UsersTableTable(this);
  late final $CategoriesTableTable categoriesTable =
      $CategoriesTableTable(this);
  late final $ProductsTableTable productsTable = $ProductsTableTable(this);
  late final $ProductVariantsTableTable productVariantsTable =
      $ProductVariantsTableTable(this);
  late final $AddonsTableTable addonsTable = $AddonsTableTable(this);
  late final $TransactionsTableTable transactionsTable =
      $TransactionsTableTable(this);
  late final $TransactionItemsTableTable transactionItemsTable =
      $TransactionItemsTableTable(this);
  late final $SettingsTableTable settingsTable = $SettingsTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        usersTable,
        categoriesTable,
        productsTable,
        productVariantsTable,
        addonsTable,
        transactionsTable,
        transactionItemsTable,
        settingsTable
      ];
}

typedef $$UsersTableTableCreateCompanionBuilder = UsersTableCompanion Function({
  Value<int> id,
  required String name,
  required String username,
  required String password,
  Value<String> role,
  Value<bool> isActive,
  required String createdAt,
  required String updatedAt,
});
typedef $$UsersTableTableUpdateCompanionBuilder = UsersTableCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> username,
  Value<String> password,
  Value<String> role,
  Value<bool> isActive,
  Value<String> createdAt,
  Value<String> updatedAt,
});

final class $$UsersTableTableReferences
    extends BaseReferences<_$AppDatabase, $UsersTableTable, UsersTableData> {
  $$UsersTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TransactionsTableTable,
      List<TransactionsTableData>> _transactionsTableRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.transactionsTable,
          aliasName: $_aliasNameGenerator(
              db.usersTable.id, db.transactionsTable.cashierId));

  $$TransactionsTableTableProcessedTableManager get transactionsTableRefs {
    final manager =
        $$TransactionsTableTableTableManager($_db, $_db.transactionsTable)
            .filter((f) => f.cashierId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_transactionsTableRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$UsersTableTableFilterComposer
    extends Composer<_$AppDatabase, $UsersTableTable> {
  $$UsersTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get username => $composableBuilder(
      column: $table.username, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get password => $composableBuilder(
      column: $table.password, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> transactionsTableRefs(
      Expression<bool> Function($$TransactionsTableTableFilterComposer f) f) {
    final $$TransactionsTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.transactionsTable,
        getReferencedColumn: (t) => t.cashierId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableTableFilterComposer(
              $db: $db,
              $table: $db.transactionsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$UsersTableTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTableTable> {
  $$UsersTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get username => $composableBuilder(
      column: $table.username, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get password => $composableBuilder(
      column: $table.password, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$UsersTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTableTable> {
  $$UsersTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<String> get password =>
      $composableBuilder(column: $table.password, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> transactionsTableRefs<T extends Object>(
      Expression<T> Function($$TransactionsTableTableAnnotationComposer a) f) {
    final $$TransactionsTableTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.transactionsTable,
            getReferencedColumn: (t) => t.cashierId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$TransactionsTableTableAnnotationComposer(
                  $db: $db,
                  $table: $db.transactionsTable,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$UsersTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UsersTableTable,
    UsersTableData,
    $$UsersTableTableFilterComposer,
    $$UsersTableTableOrderingComposer,
    $$UsersTableTableAnnotationComposer,
    $$UsersTableTableCreateCompanionBuilder,
    $$UsersTableTableUpdateCompanionBuilder,
    (UsersTableData, $$UsersTableTableReferences),
    UsersTableData,
    PrefetchHooks Function({bool transactionsTableRefs})> {
  $$UsersTableTableTableManager(_$AppDatabase db, $UsersTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> username = const Value.absent(),
            Value<String> password = const Value.absent(),
            Value<String> role = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<String> createdAt = const Value.absent(),
            Value<String> updatedAt = const Value.absent(),
          }) =>
              UsersTableCompanion(
            id: id,
            name: name,
            username: username,
            password: password,
            role: role,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required String username,
            required String password,
            Value<String> role = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            required String createdAt,
            required String updatedAt,
          }) =>
              UsersTableCompanion.insert(
            id: id,
            name: name,
            username: username,
            password: password,
            role: role,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$UsersTableTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({transactionsTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (transactionsTableRefs) db.transactionsTable
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (transactionsTableRefs)
                    await $_getPrefetchedData<UsersTableData, $UsersTableTable,
                            TransactionsTableData>(
                        currentTable: table,
                        referencedTable: $$UsersTableTableReferences
                            ._transactionsTableRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$UsersTableTableReferences(db, table, p0)
                                .transactionsTableRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.cashierId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$UsersTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UsersTableTable,
    UsersTableData,
    $$UsersTableTableFilterComposer,
    $$UsersTableTableOrderingComposer,
    $$UsersTableTableAnnotationComposer,
    $$UsersTableTableCreateCompanionBuilder,
    $$UsersTableTableUpdateCompanionBuilder,
    (UsersTableData, $$UsersTableTableReferences),
    UsersTableData,
    PrefetchHooks Function({bool transactionsTableRefs})>;
typedef $$CategoriesTableTableCreateCompanionBuilder = CategoriesTableCompanion
    Function({
  Value<int> id,
  required String name,
  Value<int> sortOrder,
  Value<bool> isActive,
  required String createdAt,
  required String updatedAt,
});
typedef $$CategoriesTableTableUpdateCompanionBuilder = CategoriesTableCompanion
    Function({
  Value<int> id,
  Value<String> name,
  Value<int> sortOrder,
  Value<bool> isActive,
  Value<String> createdAt,
  Value<String> updatedAt,
});

final class $$CategoriesTableTableReferences extends BaseReferences<
    _$AppDatabase, $CategoriesTableTable, CategoriesTableData> {
  $$CategoriesTableTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ProductsTableTable, List<ProductsTableData>>
      _productsTableRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.productsTable,
              aliasName: $_aliasNameGenerator(
                  db.categoriesTable.id, db.productsTable.categoryId));

  $$ProductsTableTableProcessedTableManager get productsTableRefs {
    final manager = $$ProductsTableTableTableManager($_db, $_db.productsTable)
        .filter((f) => f.categoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_productsTableRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$CategoriesTableTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTableTable> {
  $$CategoriesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> productsTableRefs(
      Expression<bool> Function($$ProductsTableTableFilterComposer f) f) {
    final $$ProductsTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.productsTable,
        getReferencedColumn: (t) => t.categoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductsTableTableFilterComposer(
              $db: $db,
              $table: $db.productsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$CategoriesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTableTable> {
  $$CategoriesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$CategoriesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTableTable> {
  $$CategoriesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> productsTableRefs<T extends Object>(
      Expression<T> Function($$ProductsTableTableAnnotationComposer a) f) {
    final $$ProductsTableTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.productsTable,
        getReferencedColumn: (t) => t.categoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductsTableTableAnnotationComposer(
              $db: $db,
              $table: $db.productsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$CategoriesTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CategoriesTableTable,
    CategoriesTableData,
    $$CategoriesTableTableFilterComposer,
    $$CategoriesTableTableOrderingComposer,
    $$CategoriesTableTableAnnotationComposer,
    $$CategoriesTableTableCreateCompanionBuilder,
    $$CategoriesTableTableUpdateCompanionBuilder,
    (CategoriesTableData, $$CategoriesTableTableReferences),
    CategoriesTableData,
    PrefetchHooks Function({bool productsTableRefs})> {
  $$CategoriesTableTableTableManager(
      _$AppDatabase db, $CategoriesTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<String> createdAt = const Value.absent(),
            Value<String> updatedAt = const Value.absent(),
          }) =>
              CategoriesTableCompanion(
            id: id,
            name: name,
            sortOrder: sortOrder,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            Value<int> sortOrder = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            required String createdAt,
            required String updatedAt,
          }) =>
              CategoriesTableCompanion.insert(
            id: id,
            name: name,
            sortOrder: sortOrder,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$CategoriesTableTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({productsTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (productsTableRefs) db.productsTable
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (productsTableRefs)
                    await $_getPrefetchedData<CategoriesTableData,
                            $CategoriesTableTable, ProductsTableData>(
                        currentTable: table,
                        referencedTable: $$CategoriesTableTableReferences
                            ._productsTableRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CategoriesTableTableReferences(db, table, p0)
                                .productsTableRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.categoryId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$CategoriesTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CategoriesTableTable,
    CategoriesTableData,
    $$CategoriesTableTableFilterComposer,
    $$CategoriesTableTableOrderingComposer,
    $$CategoriesTableTableAnnotationComposer,
    $$CategoriesTableTableCreateCompanionBuilder,
    $$CategoriesTableTableUpdateCompanionBuilder,
    (CategoriesTableData, $$CategoriesTableTableReferences),
    CategoriesTableData,
    PrefetchHooks Function({bool productsTableRefs})>;
typedef $$ProductsTableTableCreateCompanionBuilder = ProductsTableCompanion
    Function({
  Value<int> id,
  required int categoryId,
  required String name,
  Value<String?> description,
  Value<double> basePrice,
  Value<String?> imagePath,
  Value<bool> isActive,
  required String createdAt,
  required String updatedAt,
});
typedef $$ProductsTableTableUpdateCompanionBuilder = ProductsTableCompanion
    Function({
  Value<int> id,
  Value<int> categoryId,
  Value<String> name,
  Value<String?> description,
  Value<double> basePrice,
  Value<String?> imagePath,
  Value<bool> isActive,
  Value<String> createdAt,
  Value<String> updatedAt,
});

final class $$ProductsTableTableReferences extends BaseReferences<_$AppDatabase,
    $ProductsTableTable, ProductsTableData> {
  $$ProductsTableTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $CategoriesTableTable _categoryIdTable(_$AppDatabase db) =>
      db.categoriesTable.createAlias($_aliasNameGenerator(
          db.productsTable.categoryId, db.categoriesTable.id));

  $$CategoriesTableTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<int>('category_id')!;

    final manager =
        $$CategoriesTableTableTableManager($_db, $_db.categoriesTable)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$ProductVariantsTableTable,
      List<ProductVariantsTableData>> _productVariantsTableRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.productVariantsTable,
          aliasName: $_aliasNameGenerator(
              db.productsTable.id, db.productVariantsTable.productId));

  $$ProductVariantsTableTableProcessedTableManager
      get productVariantsTableRefs {
    final manager =
        $$ProductVariantsTableTableTableManager($_db, $_db.productVariantsTable)
            .filter((f) => f.productId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_productVariantsTableRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ProductsTableTableFilterComposer
    extends Composer<_$AppDatabase, $ProductsTableTable> {
  $$ProductsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get basePrice => $composableBuilder(
      column: $table.basePrice, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imagePath => $composableBuilder(
      column: $table.imagePath, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$CategoriesTableTableFilterComposer get categoryId {
    final $$CategoriesTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categoriesTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableTableFilterComposer(
              $db: $db,
              $table: $db.categoriesTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> productVariantsTableRefs(
      Expression<bool> Function($$ProductVariantsTableTableFilterComposer f)
          f) {
    final $$ProductVariantsTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.productVariantsTable,
        getReferencedColumn: (t) => t.productId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductVariantsTableTableFilterComposer(
              $db: $db,
              $table: $db.productVariantsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ProductsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductsTableTable> {
  $$ProductsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get basePrice => $composableBuilder(
      column: $table.basePrice, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imagePath => $composableBuilder(
      column: $table.imagePath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$CategoriesTableTableOrderingComposer get categoryId {
    final $$CategoriesTableTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categoriesTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableTableOrderingComposer(
              $db: $db,
              $table: $db.categoriesTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ProductsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductsTableTable> {
  $$ProductsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<double> get basePrice =>
      $composableBuilder(column: $table.basePrice, builder: (column) => column);

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$CategoriesTableTableAnnotationComposer get categoryId {
    final $$CategoriesTableTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categoriesTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableTableAnnotationComposer(
              $db: $db,
              $table: $db.categoriesTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> productVariantsTableRefs<T extends Object>(
      Expression<T> Function($$ProductVariantsTableTableAnnotationComposer a)
          f) {
    final $$ProductVariantsTableTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.productVariantsTable,
            getReferencedColumn: (t) => t.productId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$ProductVariantsTableTableAnnotationComposer(
                  $db: $db,
                  $table: $db.productVariantsTable,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$ProductsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ProductsTableTable,
    ProductsTableData,
    $$ProductsTableTableFilterComposer,
    $$ProductsTableTableOrderingComposer,
    $$ProductsTableTableAnnotationComposer,
    $$ProductsTableTableCreateCompanionBuilder,
    $$ProductsTableTableUpdateCompanionBuilder,
    (ProductsTableData, $$ProductsTableTableReferences),
    ProductsTableData,
    PrefetchHooks Function({bool categoryId, bool productVariantsTableRefs})> {
  $$ProductsTableTableTableManager(_$AppDatabase db, $ProductsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> categoryId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<double> basePrice = const Value.absent(),
            Value<String?> imagePath = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<String> createdAt = const Value.absent(),
            Value<String> updatedAt = const Value.absent(),
          }) =>
              ProductsTableCompanion(
            id: id,
            categoryId: categoryId,
            name: name,
            description: description,
            basePrice: basePrice,
            imagePath: imagePath,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int categoryId,
            required String name,
            Value<String?> description = const Value.absent(),
            Value<double> basePrice = const Value.absent(),
            Value<String?> imagePath = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            required String createdAt,
            required String updatedAt,
          }) =>
              ProductsTableCompanion.insert(
            id: id,
            categoryId: categoryId,
            name: name,
            description: description,
            basePrice: basePrice,
            imagePath: imagePath,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ProductsTableTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {categoryId = false, productVariantsTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (productVariantsTableRefs) db.productVariantsTable
              ],
              addJoins: <
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
                      dynamic>>(state) {
                if (categoryId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.categoryId,
                    referencedTable:
                        $$ProductsTableTableReferences._categoryIdTable(db),
                    referencedColumn:
                        $$ProductsTableTableReferences._categoryIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (productVariantsTableRefs)
                    await $_getPrefetchedData<ProductsTableData,
                            $ProductsTableTable, ProductVariantsTableData>(
                        currentTable: table,
                        referencedTable: $$ProductsTableTableReferences
                            ._productVariantsTableRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProductsTableTableReferences(db, table, p0)
                                .productVariantsTableRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.productId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ProductsTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ProductsTableTable,
    ProductsTableData,
    $$ProductsTableTableFilterComposer,
    $$ProductsTableTableOrderingComposer,
    $$ProductsTableTableAnnotationComposer,
    $$ProductsTableTableCreateCompanionBuilder,
    $$ProductsTableTableUpdateCompanionBuilder,
    (ProductsTableData, $$ProductsTableTableReferences),
    ProductsTableData,
    PrefetchHooks Function({bool categoryId, bool productVariantsTableRefs})>;
typedef $$ProductVariantsTableTableCreateCompanionBuilder
    = ProductVariantsTableCompanion Function({
  Value<int> id,
  required int productId,
  required String name,
  Value<double> priceAdjustment,
  Value<bool> isActive,
});
typedef $$ProductVariantsTableTableUpdateCompanionBuilder
    = ProductVariantsTableCompanion Function({
  Value<int> id,
  Value<int> productId,
  Value<String> name,
  Value<double> priceAdjustment,
  Value<bool> isActive,
});

final class $$ProductVariantsTableTableReferences extends BaseReferences<
    _$AppDatabase, $ProductVariantsTableTable, ProductVariantsTableData> {
  $$ProductVariantsTableTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $ProductsTableTable _productIdTable(_$AppDatabase db) =>
      db.productsTable.createAlias($_aliasNameGenerator(
          db.productVariantsTable.productId, db.productsTable.id));

  $$ProductsTableTableProcessedTableManager get productId {
    final $_column = $_itemColumn<int>('product_id')!;

    final manager = $$ProductsTableTableTableManager($_db, $_db.productsTable)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_productIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ProductVariantsTableTableFilterComposer
    extends Composer<_$AppDatabase, $ProductVariantsTableTable> {
  $$ProductVariantsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get priceAdjustment => $composableBuilder(
      column: $table.priceAdjustment,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  $$ProductsTableTableFilterComposer get productId {
    final $$ProductsTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.productId,
        referencedTable: $db.productsTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductsTableTableFilterComposer(
              $db: $db,
              $table: $db.productsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ProductVariantsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductVariantsTableTable> {
  $$ProductVariantsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get priceAdjustment => $composableBuilder(
      column: $table.priceAdjustment,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  $$ProductsTableTableOrderingComposer get productId {
    final $$ProductsTableTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.productId,
        referencedTable: $db.productsTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductsTableTableOrderingComposer(
              $db: $db,
              $table: $db.productsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ProductVariantsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductVariantsTableTable> {
  $$ProductVariantsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get priceAdjustment => $composableBuilder(
      column: $table.priceAdjustment, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  $$ProductsTableTableAnnotationComposer get productId {
    final $$ProductsTableTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.productId,
        referencedTable: $db.productsTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductsTableTableAnnotationComposer(
              $db: $db,
              $table: $db.productsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ProductVariantsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ProductVariantsTableTable,
    ProductVariantsTableData,
    $$ProductVariantsTableTableFilterComposer,
    $$ProductVariantsTableTableOrderingComposer,
    $$ProductVariantsTableTableAnnotationComposer,
    $$ProductVariantsTableTableCreateCompanionBuilder,
    $$ProductVariantsTableTableUpdateCompanionBuilder,
    (ProductVariantsTableData, $$ProductVariantsTableTableReferences),
    ProductVariantsTableData,
    PrefetchHooks Function({bool productId})> {
  $$ProductVariantsTableTableTableManager(
      _$AppDatabase db, $ProductVariantsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductVariantsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductVariantsTableTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductVariantsTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> productId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<double> priceAdjustment = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
          }) =>
              ProductVariantsTableCompanion(
            id: id,
            productId: productId,
            name: name,
            priceAdjustment: priceAdjustment,
            isActive: isActive,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int productId,
            required String name,
            Value<double> priceAdjustment = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
          }) =>
              ProductVariantsTableCompanion.insert(
            id: id,
            productId: productId,
            name: name,
            priceAdjustment: priceAdjustment,
            isActive: isActive,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ProductVariantsTableTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({productId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (productId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.productId,
                    referencedTable: $$ProductVariantsTableTableReferences
                        ._productIdTable(db),
                    referencedColumn: $$ProductVariantsTableTableReferences
                        ._productIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$ProductVariantsTableTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $ProductVariantsTableTable,
        ProductVariantsTableData,
        $$ProductVariantsTableTableFilterComposer,
        $$ProductVariantsTableTableOrderingComposer,
        $$ProductVariantsTableTableAnnotationComposer,
        $$ProductVariantsTableTableCreateCompanionBuilder,
        $$ProductVariantsTableTableUpdateCompanionBuilder,
        (ProductVariantsTableData, $$ProductVariantsTableTableReferences),
        ProductVariantsTableData,
        PrefetchHooks Function({bool productId})>;
typedef $$AddonsTableTableCreateCompanionBuilder = AddonsTableCompanion
    Function({
  Value<int> id,
  required String name,
  Value<double> price,
  Value<bool> isActive,
  required String createdAt,
});
typedef $$AddonsTableTableUpdateCompanionBuilder = AddonsTableCompanion
    Function({
  Value<int> id,
  Value<String> name,
  Value<double> price,
  Value<bool> isActive,
  Value<String> createdAt,
});

class $$AddonsTableTableFilterComposer
    extends Composer<_$AppDatabase, $AddonsTableTable> {
  $$AddonsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get price => $composableBuilder(
      column: $table.price, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$AddonsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $AddonsTableTable> {
  $$AddonsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get price => $composableBuilder(
      column: $table.price, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$AddonsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $AddonsTableTable> {
  $$AddonsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$AddonsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AddonsTableTable,
    AddonsTableData,
    $$AddonsTableTableFilterComposer,
    $$AddonsTableTableOrderingComposer,
    $$AddonsTableTableAnnotationComposer,
    $$AddonsTableTableCreateCompanionBuilder,
    $$AddonsTableTableUpdateCompanionBuilder,
    (
      AddonsTableData,
      BaseReferences<_$AppDatabase, $AddonsTableTable, AddonsTableData>
    ),
    AddonsTableData,
    PrefetchHooks Function()> {
  $$AddonsTableTableTableManager(_$AppDatabase db, $AddonsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AddonsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AddonsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AddonsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<double> price = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<String> createdAt = const Value.absent(),
          }) =>
              AddonsTableCompanion(
            id: id,
            name: name,
            price: price,
            isActive: isActive,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            Value<double> price = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            required String createdAt,
          }) =>
              AddonsTableCompanion.insert(
            id: id,
            name: name,
            price: price,
            isActive: isActive,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AddonsTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AddonsTableTable,
    AddonsTableData,
    $$AddonsTableTableFilterComposer,
    $$AddonsTableTableOrderingComposer,
    $$AddonsTableTableAnnotationComposer,
    $$AddonsTableTableCreateCompanionBuilder,
    $$AddonsTableTableUpdateCompanionBuilder,
    (
      AddonsTableData,
      BaseReferences<_$AppDatabase, $AddonsTableTable, AddonsTableData>
    ),
    AddonsTableData,
    PrefetchHooks Function()>;
typedef $$TransactionsTableTableCreateCompanionBuilder
    = TransactionsTableCompanion Function({
  Value<int> id,
  required String invoiceNumber,
  required int cashierId,
  required String cashierName,
  Value<double> subtotal,
  Value<String> discountType,
  Value<double> discountValue,
  Value<double> discountAmount,
  Value<double> taxPercent,
  Value<double> taxAmount,
  Value<double> servicePercent,
  Value<double> serviceAmount,
  Value<double> total,
  required String paymentMethod,
  Value<String?> paymentLabel,
  Value<double> amountPaid,
  Value<double> changeAmount,
  Value<String?> note,
  required String createdAt,
});
typedef $$TransactionsTableTableUpdateCompanionBuilder
    = TransactionsTableCompanion Function({
  Value<int> id,
  Value<String> invoiceNumber,
  Value<int> cashierId,
  Value<String> cashierName,
  Value<double> subtotal,
  Value<String> discountType,
  Value<double> discountValue,
  Value<double> discountAmount,
  Value<double> taxPercent,
  Value<double> taxAmount,
  Value<double> servicePercent,
  Value<double> serviceAmount,
  Value<double> total,
  Value<String> paymentMethod,
  Value<String?> paymentLabel,
  Value<double> amountPaid,
  Value<double> changeAmount,
  Value<String?> note,
  Value<String> createdAt,
});

final class $$TransactionsTableTableReferences extends BaseReferences<
    _$AppDatabase, $TransactionsTableTable, TransactionsTableData> {
  $$TransactionsTableTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $UsersTableTable _cashierIdTable(_$AppDatabase db) =>
      db.usersTable.createAlias($_aliasNameGenerator(
          db.transactionsTable.cashierId, db.usersTable.id));

  $$UsersTableTableProcessedTableManager get cashierId {
    final $_column = $_itemColumn<int>('cashier_id')!;

    final manager = $$UsersTableTableTableManager($_db, $_db.usersTable)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_cashierIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$TransactionItemsTableTable,
      List<TransactionItemsTableData>> _transactionItemsTableRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.transactionItemsTable,
          aliasName: $_aliasNameGenerator(
              db.transactionsTable.id, db.transactionItemsTable.transactionId));

  $$TransactionItemsTableTableProcessedTableManager
      get transactionItemsTableRefs {
    final manager = $$TransactionItemsTableTableTableManager(
            $_db, $_db.transactionItemsTable)
        .filter((f) => f.transactionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_transactionItemsTableRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$TransactionsTableTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionsTableTable> {
  $$TransactionsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get invoiceNumber => $composableBuilder(
      column: $table.invoiceNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cashierName => $composableBuilder(
      column: $table.cashierName, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get subtotal => $composableBuilder(
      column: $table.subtotal, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get discountType => $composableBuilder(
      column: $table.discountType, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get discountValue => $composableBuilder(
      column: $table.discountValue, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get discountAmount => $composableBuilder(
      column: $table.discountAmount,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get taxPercent => $composableBuilder(
      column: $table.taxPercent, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get taxAmount => $composableBuilder(
      column: $table.taxAmount, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get servicePercent => $composableBuilder(
      column: $table.servicePercent,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get serviceAmount => $composableBuilder(
      column: $table.serviceAmount, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get total => $composableBuilder(
      column: $table.total, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get paymentMethod => $composableBuilder(
      column: $table.paymentMethod, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get paymentLabel => $composableBuilder(
      column: $table.paymentLabel, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get amountPaid => $composableBuilder(
      column: $table.amountPaid, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get changeAmount => $composableBuilder(
      column: $table.changeAmount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$UsersTableTableFilterComposer get cashierId {
    final $$UsersTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.cashierId,
        referencedTable: $db.usersTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableTableFilterComposer(
              $db: $db,
              $table: $db.usersTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> transactionItemsTableRefs(
      Expression<bool> Function($$TransactionItemsTableTableFilterComposer f)
          f) {
    final $$TransactionItemsTableTableFilterComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.transactionItemsTable,
            getReferencedColumn: (t) => t.transactionId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$TransactionItemsTableTableFilterComposer(
                  $db: $db,
                  $table: $db.transactionItemsTable,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$TransactionsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionsTableTable> {
  $$TransactionsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get invoiceNumber => $composableBuilder(
      column: $table.invoiceNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cashierName => $composableBuilder(
      column: $table.cashierName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get subtotal => $composableBuilder(
      column: $table.subtotal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get discountType => $composableBuilder(
      column: $table.discountType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get discountValue => $composableBuilder(
      column: $table.discountValue,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get discountAmount => $composableBuilder(
      column: $table.discountAmount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get taxPercent => $composableBuilder(
      column: $table.taxPercent, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get taxAmount => $composableBuilder(
      column: $table.taxAmount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get servicePercent => $composableBuilder(
      column: $table.servicePercent,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get serviceAmount => $composableBuilder(
      column: $table.serviceAmount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get total => $composableBuilder(
      column: $table.total, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get paymentMethod => $composableBuilder(
      column: $table.paymentMethod,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get paymentLabel => $composableBuilder(
      column: $table.paymentLabel,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get amountPaid => $composableBuilder(
      column: $table.amountPaid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get changeAmount => $composableBuilder(
      column: $table.changeAmount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$UsersTableTableOrderingComposer get cashierId {
    final $$UsersTableTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.cashierId,
        referencedTable: $db.usersTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableTableOrderingComposer(
              $db: $db,
              $table: $db.usersTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TransactionsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionsTableTable> {
  $$TransactionsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get invoiceNumber => $composableBuilder(
      column: $table.invoiceNumber, builder: (column) => column);

  GeneratedColumn<String> get cashierName => $composableBuilder(
      column: $table.cashierName, builder: (column) => column);

  GeneratedColumn<double> get subtotal =>
      $composableBuilder(column: $table.subtotal, builder: (column) => column);

  GeneratedColumn<String> get discountType => $composableBuilder(
      column: $table.discountType, builder: (column) => column);

  GeneratedColumn<double> get discountValue => $composableBuilder(
      column: $table.discountValue, builder: (column) => column);

  GeneratedColumn<double> get discountAmount => $composableBuilder(
      column: $table.discountAmount, builder: (column) => column);

  GeneratedColumn<double> get taxPercent => $composableBuilder(
      column: $table.taxPercent, builder: (column) => column);

  GeneratedColumn<double> get taxAmount =>
      $composableBuilder(column: $table.taxAmount, builder: (column) => column);

  GeneratedColumn<double> get servicePercent => $composableBuilder(
      column: $table.servicePercent, builder: (column) => column);

  GeneratedColumn<double> get serviceAmount => $composableBuilder(
      column: $table.serviceAmount, builder: (column) => column);

  GeneratedColumn<double> get total =>
      $composableBuilder(column: $table.total, builder: (column) => column);

  GeneratedColumn<String> get paymentMethod => $composableBuilder(
      column: $table.paymentMethod, builder: (column) => column);

  GeneratedColumn<String> get paymentLabel => $composableBuilder(
      column: $table.paymentLabel, builder: (column) => column);

  GeneratedColumn<double> get amountPaid => $composableBuilder(
      column: $table.amountPaid, builder: (column) => column);

  GeneratedColumn<double> get changeAmount => $composableBuilder(
      column: $table.changeAmount, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$UsersTableTableAnnotationComposer get cashierId {
    final $$UsersTableTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.cashierId,
        referencedTable: $db.usersTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableTableAnnotationComposer(
              $db: $db,
              $table: $db.usersTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> transactionItemsTableRefs<T extends Object>(
      Expression<T> Function($$TransactionItemsTableTableAnnotationComposer a)
          f) {
    final $$TransactionItemsTableTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.transactionItemsTable,
            getReferencedColumn: (t) => t.transactionId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$TransactionItemsTableTableAnnotationComposer(
                  $db: $db,
                  $table: $db.transactionItemsTable,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$TransactionsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TransactionsTableTable,
    TransactionsTableData,
    $$TransactionsTableTableFilterComposer,
    $$TransactionsTableTableOrderingComposer,
    $$TransactionsTableTableAnnotationComposer,
    $$TransactionsTableTableCreateCompanionBuilder,
    $$TransactionsTableTableUpdateCompanionBuilder,
    (TransactionsTableData, $$TransactionsTableTableReferences),
    TransactionsTableData,
    PrefetchHooks Function({bool cashierId, bool transactionItemsTableRefs})> {
  $$TransactionsTableTableTableManager(
      _$AppDatabase db, $TransactionsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionsTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> invoiceNumber = const Value.absent(),
            Value<int> cashierId = const Value.absent(),
            Value<String> cashierName = const Value.absent(),
            Value<double> subtotal = const Value.absent(),
            Value<String> discountType = const Value.absent(),
            Value<double> discountValue = const Value.absent(),
            Value<double> discountAmount = const Value.absent(),
            Value<double> taxPercent = const Value.absent(),
            Value<double> taxAmount = const Value.absent(),
            Value<double> servicePercent = const Value.absent(),
            Value<double> serviceAmount = const Value.absent(),
            Value<double> total = const Value.absent(),
            Value<String> paymentMethod = const Value.absent(),
            Value<String?> paymentLabel = const Value.absent(),
            Value<double> amountPaid = const Value.absent(),
            Value<double> changeAmount = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<String> createdAt = const Value.absent(),
          }) =>
              TransactionsTableCompanion(
            id: id,
            invoiceNumber: invoiceNumber,
            cashierId: cashierId,
            cashierName: cashierName,
            subtotal: subtotal,
            discountType: discountType,
            discountValue: discountValue,
            discountAmount: discountAmount,
            taxPercent: taxPercent,
            taxAmount: taxAmount,
            servicePercent: servicePercent,
            serviceAmount: serviceAmount,
            total: total,
            paymentMethod: paymentMethod,
            paymentLabel: paymentLabel,
            amountPaid: amountPaid,
            changeAmount: changeAmount,
            note: note,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String invoiceNumber,
            required int cashierId,
            required String cashierName,
            Value<double> subtotal = const Value.absent(),
            Value<String> discountType = const Value.absent(),
            Value<double> discountValue = const Value.absent(),
            Value<double> discountAmount = const Value.absent(),
            Value<double> taxPercent = const Value.absent(),
            Value<double> taxAmount = const Value.absent(),
            Value<double> servicePercent = const Value.absent(),
            Value<double> serviceAmount = const Value.absent(),
            Value<double> total = const Value.absent(),
            required String paymentMethod,
            Value<String?> paymentLabel = const Value.absent(),
            Value<double> amountPaid = const Value.absent(),
            Value<double> changeAmount = const Value.absent(),
            Value<String?> note = const Value.absent(),
            required String createdAt,
          }) =>
              TransactionsTableCompanion.insert(
            id: id,
            invoiceNumber: invoiceNumber,
            cashierId: cashierId,
            cashierName: cashierName,
            subtotal: subtotal,
            discountType: discountType,
            discountValue: discountValue,
            discountAmount: discountAmount,
            taxPercent: taxPercent,
            taxAmount: taxAmount,
            servicePercent: servicePercent,
            serviceAmount: serviceAmount,
            total: total,
            paymentMethod: paymentMethod,
            paymentLabel: paymentLabel,
            amountPaid: amountPaid,
            changeAmount: changeAmount,
            note: note,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$TransactionsTableTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {cashierId = false, transactionItemsTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (transactionItemsTableRefs) db.transactionItemsTable
              ],
              addJoins: <
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
                      dynamic>>(state) {
                if (cashierId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.cashierId,
                    referencedTable:
                        $$TransactionsTableTableReferences._cashierIdTable(db),
                    referencedColumn: $$TransactionsTableTableReferences
                        ._cashierIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (transactionItemsTableRefs)
                    await $_getPrefetchedData<TransactionsTableData,
                            $TransactionsTableTable, TransactionItemsTableData>(
                        currentTable: table,
                        referencedTable: $$TransactionsTableTableReferences
                            ._transactionItemsTableRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TransactionsTableTableReferences(db, table, p0)
                                .transactionItemsTableRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.transactionId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$TransactionsTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TransactionsTableTable,
    TransactionsTableData,
    $$TransactionsTableTableFilterComposer,
    $$TransactionsTableTableOrderingComposer,
    $$TransactionsTableTableAnnotationComposer,
    $$TransactionsTableTableCreateCompanionBuilder,
    $$TransactionsTableTableUpdateCompanionBuilder,
    (TransactionsTableData, $$TransactionsTableTableReferences),
    TransactionsTableData,
    PrefetchHooks Function({bool cashierId, bool transactionItemsTableRefs})>;
typedef $$TransactionItemsTableTableCreateCompanionBuilder
    = TransactionItemsTableCompanion Function({
  Value<int> id,
  required int transactionId,
  Value<int?> productId,
  required String productNameSnapshot,
  Value<String?> variantNameSnapshot,
  Value<String?> addonNamesSnapshot,
  required double unitPrice,
  Value<int> qty,
  Value<String?> note,
  required double total,
});
typedef $$TransactionItemsTableTableUpdateCompanionBuilder
    = TransactionItemsTableCompanion Function({
  Value<int> id,
  Value<int> transactionId,
  Value<int?> productId,
  Value<String> productNameSnapshot,
  Value<String?> variantNameSnapshot,
  Value<String?> addonNamesSnapshot,
  Value<double> unitPrice,
  Value<int> qty,
  Value<String?> note,
  Value<double> total,
});

final class $$TransactionItemsTableTableReferences extends BaseReferences<
    _$AppDatabase, $TransactionItemsTableTable, TransactionItemsTableData> {
  $$TransactionItemsTableTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $TransactionsTableTable _transactionIdTable(_$AppDatabase db) =>
      db.transactionsTable.createAlias($_aliasNameGenerator(
          db.transactionItemsTable.transactionId, db.transactionsTable.id));

  $$TransactionsTableTableProcessedTableManager get transactionId {
    final $_column = $_itemColumn<int>('transaction_id')!;

    final manager =
        $$TransactionsTableTableTableManager($_db, $_db.transactionsTable)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_transactionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$TransactionItemsTableTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionItemsTableTable> {
  $$TransactionItemsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get productId => $composableBuilder(
      column: $table.productId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get productNameSnapshot => $composableBuilder(
      column: $table.productNameSnapshot,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get variantNameSnapshot => $composableBuilder(
      column: $table.variantNameSnapshot,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get addonNamesSnapshot => $composableBuilder(
      column: $table.addonNamesSnapshot,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get unitPrice => $composableBuilder(
      column: $table.unitPrice, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get qty => $composableBuilder(
      column: $table.qty, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get total => $composableBuilder(
      column: $table.total, builder: (column) => ColumnFilters(column));

  $$TransactionsTableTableFilterComposer get transactionId {
    final $$TransactionsTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.transactionId,
        referencedTable: $db.transactionsTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableTableFilterComposer(
              $db: $db,
              $table: $db.transactionsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TransactionItemsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionItemsTableTable> {
  $$TransactionItemsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get productId => $composableBuilder(
      column: $table.productId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get productNameSnapshot => $composableBuilder(
      column: $table.productNameSnapshot,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get variantNameSnapshot => $composableBuilder(
      column: $table.variantNameSnapshot,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get addonNamesSnapshot => $composableBuilder(
      column: $table.addonNamesSnapshot,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get unitPrice => $composableBuilder(
      column: $table.unitPrice, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get qty => $composableBuilder(
      column: $table.qty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get total => $composableBuilder(
      column: $table.total, builder: (column) => ColumnOrderings(column));

  $$TransactionsTableTableOrderingComposer get transactionId {
    final $$TransactionsTableTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.transactionId,
        referencedTable: $db.transactionsTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableTableOrderingComposer(
              $db: $db,
              $table: $db.transactionsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TransactionItemsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionItemsTableTable> {
  $$TransactionItemsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<String> get productNameSnapshot => $composableBuilder(
      column: $table.productNameSnapshot, builder: (column) => column);

  GeneratedColumn<String> get variantNameSnapshot => $composableBuilder(
      column: $table.variantNameSnapshot, builder: (column) => column);

  GeneratedColumn<String> get addonNamesSnapshot => $composableBuilder(
      column: $table.addonNamesSnapshot, builder: (column) => column);

  GeneratedColumn<double> get unitPrice =>
      $composableBuilder(column: $table.unitPrice, builder: (column) => column);

  GeneratedColumn<int> get qty =>
      $composableBuilder(column: $table.qty, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<double> get total =>
      $composableBuilder(column: $table.total, builder: (column) => column);

  $$TransactionsTableTableAnnotationComposer get transactionId {
    final $$TransactionsTableTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.transactionId,
            referencedTable: $db.transactionsTable,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$TransactionsTableTableAnnotationComposer(
                  $db: $db,
                  $table: $db.transactionsTable,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }
}

class $$TransactionItemsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TransactionItemsTableTable,
    TransactionItemsTableData,
    $$TransactionItemsTableTableFilterComposer,
    $$TransactionItemsTableTableOrderingComposer,
    $$TransactionItemsTableTableAnnotationComposer,
    $$TransactionItemsTableTableCreateCompanionBuilder,
    $$TransactionItemsTableTableUpdateCompanionBuilder,
    (TransactionItemsTableData, $$TransactionItemsTableTableReferences),
    TransactionItemsTableData,
    PrefetchHooks Function({bool transactionId})> {
  $$TransactionItemsTableTableTableManager(
      _$AppDatabase db, $TransactionItemsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionItemsTableTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionItemsTableTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionItemsTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> transactionId = const Value.absent(),
            Value<int?> productId = const Value.absent(),
            Value<String> productNameSnapshot = const Value.absent(),
            Value<String?> variantNameSnapshot = const Value.absent(),
            Value<String?> addonNamesSnapshot = const Value.absent(),
            Value<double> unitPrice = const Value.absent(),
            Value<int> qty = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<double> total = const Value.absent(),
          }) =>
              TransactionItemsTableCompanion(
            id: id,
            transactionId: transactionId,
            productId: productId,
            productNameSnapshot: productNameSnapshot,
            variantNameSnapshot: variantNameSnapshot,
            addonNamesSnapshot: addonNamesSnapshot,
            unitPrice: unitPrice,
            qty: qty,
            note: note,
            total: total,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int transactionId,
            Value<int?> productId = const Value.absent(),
            required String productNameSnapshot,
            Value<String?> variantNameSnapshot = const Value.absent(),
            Value<String?> addonNamesSnapshot = const Value.absent(),
            required double unitPrice,
            Value<int> qty = const Value.absent(),
            Value<String?> note = const Value.absent(),
            required double total,
          }) =>
              TransactionItemsTableCompanion.insert(
            id: id,
            transactionId: transactionId,
            productId: productId,
            productNameSnapshot: productNameSnapshot,
            variantNameSnapshot: variantNameSnapshot,
            addonNamesSnapshot: addonNamesSnapshot,
            unitPrice: unitPrice,
            qty: qty,
            note: note,
            total: total,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$TransactionItemsTableTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({transactionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (transactionId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.transactionId,
                    referencedTable: $$TransactionItemsTableTableReferences
                        ._transactionIdTable(db),
                    referencedColumn: $$TransactionItemsTableTableReferences
                        ._transactionIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$TransactionItemsTableTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $TransactionItemsTableTable,
        TransactionItemsTableData,
        $$TransactionItemsTableTableFilterComposer,
        $$TransactionItemsTableTableOrderingComposer,
        $$TransactionItemsTableTableAnnotationComposer,
        $$TransactionItemsTableTableCreateCompanionBuilder,
        $$TransactionItemsTableTableUpdateCompanionBuilder,
        (TransactionItemsTableData, $$TransactionItemsTableTableReferences),
        TransactionItemsTableData,
        PrefetchHooks Function({bool transactionId})>;
typedef $$SettingsTableTableCreateCompanionBuilder = SettingsTableCompanion
    Function({
  Value<int> id,
  Value<String> storeName,
  Value<String?> storeAddress,
  Value<String?> storePhone,
  Value<String> storeFooter,
  Value<double> taxPercent,
  Value<double> servicePercent,
  Value<String> currencySymbol,
  Value<String?> logoPath,
  required String updatedAt,
});
typedef $$SettingsTableTableUpdateCompanionBuilder = SettingsTableCompanion
    Function({
  Value<int> id,
  Value<String> storeName,
  Value<String?> storeAddress,
  Value<String?> storePhone,
  Value<String> storeFooter,
  Value<double> taxPercent,
  Value<double> servicePercent,
  Value<String> currencySymbol,
  Value<String?> logoPath,
  Value<String> updatedAt,
});

class $$SettingsTableTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTableTable> {
  $$SettingsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get storeName => $composableBuilder(
      column: $table.storeName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get storeAddress => $composableBuilder(
      column: $table.storeAddress, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get storePhone => $composableBuilder(
      column: $table.storePhone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get storeFooter => $composableBuilder(
      column: $table.storeFooter, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get taxPercent => $composableBuilder(
      column: $table.taxPercent, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get servicePercent => $composableBuilder(
      column: $table.servicePercent,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get currencySymbol => $composableBuilder(
      column: $table.currencySymbol,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get logoPath => $composableBuilder(
      column: $table.logoPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$SettingsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTableTable> {
  $$SettingsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get storeName => $composableBuilder(
      column: $table.storeName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get storeAddress => $composableBuilder(
      column: $table.storeAddress,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get storePhone => $composableBuilder(
      column: $table.storePhone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get storeFooter => $composableBuilder(
      column: $table.storeFooter, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get taxPercent => $composableBuilder(
      column: $table.taxPercent, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get servicePercent => $composableBuilder(
      column: $table.servicePercent,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get currencySymbol => $composableBuilder(
      column: $table.currencySymbol,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get logoPath => $composableBuilder(
      column: $table.logoPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$SettingsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTableTable> {
  $$SettingsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get storeName =>
      $composableBuilder(column: $table.storeName, builder: (column) => column);

  GeneratedColumn<String> get storeAddress => $composableBuilder(
      column: $table.storeAddress, builder: (column) => column);

  GeneratedColumn<String> get storePhone => $composableBuilder(
      column: $table.storePhone, builder: (column) => column);

  GeneratedColumn<String> get storeFooter => $composableBuilder(
      column: $table.storeFooter, builder: (column) => column);

  GeneratedColumn<double> get taxPercent => $composableBuilder(
      column: $table.taxPercent, builder: (column) => column);

  GeneratedColumn<double> get servicePercent => $composableBuilder(
      column: $table.servicePercent, builder: (column) => column);

  GeneratedColumn<String> get currencySymbol => $composableBuilder(
      column: $table.currencySymbol, builder: (column) => column);

  GeneratedColumn<String> get logoPath =>
      $composableBuilder(column: $table.logoPath, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SettingsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SettingsTableTable,
    SettingsTableData,
    $$SettingsTableTableFilterComposer,
    $$SettingsTableTableOrderingComposer,
    $$SettingsTableTableAnnotationComposer,
    $$SettingsTableTableCreateCompanionBuilder,
    $$SettingsTableTableUpdateCompanionBuilder,
    (
      SettingsTableData,
      BaseReferences<_$AppDatabase, $SettingsTableTable, SettingsTableData>
    ),
    SettingsTableData,
    PrefetchHooks Function()> {
  $$SettingsTableTableTableManager(_$AppDatabase db, $SettingsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> storeName = const Value.absent(),
            Value<String?> storeAddress = const Value.absent(),
            Value<String?> storePhone = const Value.absent(),
            Value<String> storeFooter = const Value.absent(),
            Value<double> taxPercent = const Value.absent(),
            Value<double> servicePercent = const Value.absent(),
            Value<String> currencySymbol = const Value.absent(),
            Value<String?> logoPath = const Value.absent(),
            Value<String> updatedAt = const Value.absent(),
          }) =>
              SettingsTableCompanion(
            id: id,
            storeName: storeName,
            storeAddress: storeAddress,
            storePhone: storePhone,
            storeFooter: storeFooter,
            taxPercent: taxPercent,
            servicePercent: servicePercent,
            currencySymbol: currencySymbol,
            logoPath: logoPath,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> storeName = const Value.absent(),
            Value<String?> storeAddress = const Value.absent(),
            Value<String?> storePhone = const Value.absent(),
            Value<String> storeFooter = const Value.absent(),
            Value<double> taxPercent = const Value.absent(),
            Value<double> servicePercent = const Value.absent(),
            Value<String> currencySymbol = const Value.absent(),
            Value<String?> logoPath = const Value.absent(),
            required String updatedAt,
          }) =>
              SettingsTableCompanion.insert(
            id: id,
            storeName: storeName,
            storeAddress: storeAddress,
            storePhone: storePhone,
            storeFooter: storeFooter,
            taxPercent: taxPercent,
            servicePercent: servicePercent,
            currencySymbol: currencySymbol,
            logoPath: logoPath,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SettingsTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SettingsTableTable,
    SettingsTableData,
    $$SettingsTableTableFilterComposer,
    $$SettingsTableTableOrderingComposer,
    $$SettingsTableTableAnnotationComposer,
    $$SettingsTableTableCreateCompanionBuilder,
    $$SettingsTableTableUpdateCompanionBuilder,
    (
      SettingsTableData,
      BaseReferences<_$AppDatabase, $SettingsTableTable, SettingsTableData>
    ),
    SettingsTableData,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UsersTableTableTableManager get usersTable =>
      $$UsersTableTableTableManager(_db, _db.usersTable);
  $$CategoriesTableTableTableManager get categoriesTable =>
      $$CategoriesTableTableTableManager(_db, _db.categoriesTable);
  $$ProductsTableTableTableManager get productsTable =>
      $$ProductsTableTableTableManager(_db, _db.productsTable);
  $$ProductVariantsTableTableTableManager get productVariantsTable =>
      $$ProductVariantsTableTableTableManager(_db, _db.productVariantsTable);
  $$AddonsTableTableTableManager get addonsTable =>
      $$AddonsTableTableTableManager(_db, _db.addonsTable);
  $$TransactionsTableTableTableManager get transactionsTable =>
      $$TransactionsTableTableTableManager(_db, _db.transactionsTable);
  $$TransactionItemsTableTableTableManager get transactionItemsTable =>
      $$TransactionItemsTableTableTableManager(_db, _db.transactionItemsTable);
  $$SettingsTableTableTableManager get settingsTable =>
      $$SettingsTableTableTableManager(_db, _db.settingsTable);
}
