// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_db.dart';

// ignore_for_file: type=lint
class $SuppliersTable extends Suppliers
    with TableInfo<$SuppliersTable, Supplier> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SuppliersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contactMeta = const VerificationMeta(
    'contact',
  );
  @override
  late final GeneratedColumn<String> contact = GeneratedColumn<String>(
    'contact',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, contact, address, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'suppliers';
  @override
  VerificationContext validateIntegrity(
    Insertable<Supplier> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('contact')) {
      context.handle(
        _contactMeta,
        contact.isAcceptableOrUnknown(data['contact']!, _contactMeta),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Supplier map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Supplier(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      contact: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contact'],
      ),
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SuppliersTable createAlias(String alias) {
    return $SuppliersTable(attachedDatabase, alias);
  }
}

class Supplier extends DataClass implements Insertable<Supplier> {
  final String id;
  final String name;
  final String? contact;
  final String? address;
  final DateTime createdAt;
  const Supplier({
    required this.id,
    required this.name,
    this.contact,
    this.address,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || contact != null) {
      map['contact'] = Variable<String>(contact);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SuppliersCompanion toCompanion(bool nullToAbsent) {
    return SuppliersCompanion(
      id: Value(id),
      name: Value(name),
      contact: contact == null && nullToAbsent
          ? const Value.absent()
          : Value(contact),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      createdAt: Value(createdAt),
    );
  }

  factory Supplier.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Supplier(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      contact: serializer.fromJson<String?>(json['contact']),
      address: serializer.fromJson<String?>(json['address']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'contact': serializer.toJson<String?>(contact),
      'address': serializer.toJson<String?>(address),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Supplier copyWith({
    String? id,
    String? name,
    Value<String?> contact = const Value.absent(),
    Value<String?> address = const Value.absent(),
    DateTime? createdAt,
  }) => Supplier(
    id: id ?? this.id,
    name: name ?? this.name,
    contact: contact.present ? contact.value : this.contact,
    address: address.present ? address.value : this.address,
    createdAt: createdAt ?? this.createdAt,
  );
  Supplier copyWithCompanion(SuppliersCompanion data) {
    return Supplier(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      contact: data.contact.present ? data.contact.value : this.contact,
      address: data.address.present ? data.address.value : this.address,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Supplier(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('contact: $contact, ')
          ..write('address: $address, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, contact, address, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Supplier &&
          other.id == this.id &&
          other.name == this.name &&
          other.contact == this.contact &&
          other.address == this.address &&
          other.createdAt == this.createdAt);
}

class SuppliersCompanion extends UpdateCompanion<Supplier> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> contact;
  final Value<String?> address;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const SuppliersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.contact = const Value.absent(),
    this.address = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SuppliersCompanion.insert({
    required String id,
    required String name,
    this.contact = const Value.absent(),
    this.address = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<Supplier> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? contact,
    Expression<String>? address,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (contact != null) 'contact': contact,
      if (address != null) 'address': address,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SuppliersCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? contact,
    Value<String?>? address,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return SuppliersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      contact: contact ?? this.contact,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (contact.present) {
      map['contact'] = Variable<String>(contact.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SuppliersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('contact: $contact, ')
          ..write('address: $address, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ClientsTable extends Clients with TableInfo<$ClientsTable, Client> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClientsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contactMeta = const VerificationMeta(
    'contact',
  );
  @override
  late final GeneratedColumn<String> contact = GeneratedColumn<String>(
    'contact',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isBlacklistedMeta = const VerificationMeta(
    'isBlacklisted',
  );
  @override
  late final GeneratedColumn<bool> isBlacklisted = GeneratedColumn<bool>(
    'is_blacklisted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_blacklisted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    contact,
    address,
    isBlacklisted,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'clients';
  @override
  VerificationContext validateIntegrity(
    Insertable<Client> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('contact')) {
      context.handle(
        _contactMeta,
        contact.isAcceptableOrUnknown(data['contact']!, _contactMeta),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('is_blacklisted')) {
      context.handle(
        _isBlacklistedMeta,
        isBlacklisted.isAcceptableOrUnknown(
          data['is_blacklisted']!,
          _isBlacklistedMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Client map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Client(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      contact: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contact'],
      ),
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
      isBlacklisted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_blacklisted'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ClientsTable createAlias(String alias) {
    return $ClientsTable(attachedDatabase, alias);
  }
}

class Client extends DataClass implements Insertable<Client> {
  final String id;
  final String name;
  final String? contact;
  final String? address;
  final bool isBlacklisted;
  final DateTime createdAt;
  const Client({
    required this.id,
    required this.name,
    this.contact,
    this.address,
    required this.isBlacklisted,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || contact != null) {
      map['contact'] = Variable<String>(contact);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    map['is_blacklisted'] = Variable<bool>(isBlacklisted);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ClientsCompanion toCompanion(bool nullToAbsent) {
    return ClientsCompanion(
      id: Value(id),
      name: Value(name),
      contact: contact == null && nullToAbsent
          ? const Value.absent()
          : Value(contact),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      isBlacklisted: Value(isBlacklisted),
      createdAt: Value(createdAt),
    );
  }

  factory Client.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Client(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      contact: serializer.fromJson<String?>(json['contact']),
      address: serializer.fromJson<String?>(json['address']),
      isBlacklisted: serializer.fromJson<bool>(json['isBlacklisted']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'contact': serializer.toJson<String?>(contact),
      'address': serializer.toJson<String?>(address),
      'isBlacklisted': serializer.toJson<bool>(isBlacklisted),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Client copyWith({
    String? id,
    String? name,
    Value<String?> contact = const Value.absent(),
    Value<String?> address = const Value.absent(),
    bool? isBlacklisted,
    DateTime? createdAt,
  }) => Client(
    id: id ?? this.id,
    name: name ?? this.name,
    contact: contact.present ? contact.value : this.contact,
    address: address.present ? address.value : this.address,
    isBlacklisted: isBlacklisted ?? this.isBlacklisted,
    createdAt: createdAt ?? this.createdAt,
  );
  Client copyWithCompanion(ClientsCompanion data) {
    return Client(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      contact: data.contact.present ? data.contact.value : this.contact,
      address: data.address.present ? data.address.value : this.address,
      isBlacklisted: data.isBlacklisted.present
          ? data.isBlacklisted.value
          : this.isBlacklisted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Client(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('contact: $contact, ')
          ..write('address: $address, ')
          ..write('isBlacklisted: $isBlacklisted, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, contact, address, isBlacklisted, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Client &&
          other.id == this.id &&
          other.name == this.name &&
          other.contact == this.contact &&
          other.address == this.address &&
          other.isBlacklisted == this.isBlacklisted &&
          other.createdAt == this.createdAt);
}

class ClientsCompanion extends UpdateCompanion<Client> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> contact;
  final Value<String?> address;
  final Value<bool> isBlacklisted;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ClientsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.contact = const Value.absent(),
    this.address = const Value.absent(),
    this.isBlacklisted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ClientsCompanion.insert({
    required String id,
    required String name,
    this.contact = const Value.absent(),
    this.address = const Value.absent(),
    this.isBlacklisted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<Client> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? contact,
    Expression<String>? address,
    Expression<bool>? isBlacklisted,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (contact != null) 'contact': contact,
      if (address != null) 'address': address,
      if (isBlacklisted != null) 'is_blacklisted': isBlacklisted,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ClientsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? contact,
    Value<String?>? address,
    Value<bool>? isBlacklisted,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return ClientsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      contact: contact ?? this.contact,
      address: address ?? this.address,
      isBlacklisted: isBlacklisted ?? this.isBlacklisted,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (contact.present) {
      map['contact'] = Variable<String>(contact.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (isBlacklisted.present) {
      map['is_blacklisted'] = Variable<bool>(isBlacklisted.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClientsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('contact: $contact, ')
          ..write('address: $address, ')
          ..write('isBlacklisted: $isBlacklisted, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProductsTable extends Products with TableInfo<$ProductsTable, Product> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productCodeMeta = const VerificationMeta(
    'productCode',
  );
  @override
  late final GeneratedColumn<String> productCode = GeneratedColumn<String>(
    'product_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _supplierIdMeta = const VerificationMeta(
    'supplierId',
  );
  @override
  late final GeneratedColumn<String> supplierId = GeneratedColumn<String>(
    'supplier_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES suppliers (id)',
    ),
  );
  static const VerificationMeta _piecesPerBoxMeta = const VerificationMeta(
    'piecesPerBox',
  );
  @override
  late final GeneratedColumn<int> piecesPerBox = GeneratedColumn<int>(
    'pieces_per_box',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _reorderPointMeta = const VerificationMeta(
    'reorderPoint',
  );
  @override
  late final GeneratedColumn<int> reorderPoint = GeneratedColumn<int>(
    'reorder_point',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reorderQuantityMeta = const VerificationMeta(
    'reorderQuantity',
  );
  @override
  late final GeneratedColumn<int> reorderQuantity = GeneratedColumn<int>(
    'reorder_quantity',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    productCode,
    supplierId,
    piecesPerBox,
    createdAt,
    isDeleted,
    reorderPoint,
    reorderQuantity,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'products';
  @override
  VerificationContext validateIntegrity(
    Insertable<Product> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('product_code')) {
      context.handle(
        _productCodeMeta,
        productCode.isAcceptableOrUnknown(
          data['product_code']!,
          _productCodeMeta,
        ),
      );
    }
    if (data.containsKey('supplier_id')) {
      context.handle(
        _supplierIdMeta,
        supplierId.isAcceptableOrUnknown(data['supplier_id']!, _supplierIdMeta),
      );
    } else if (isInserting) {
      context.missing(_supplierIdMeta);
    }
    if (data.containsKey('pieces_per_box')) {
      context.handle(
        _piecesPerBoxMeta,
        piecesPerBox.isAcceptableOrUnknown(
          data['pieces_per_box']!,
          _piecesPerBoxMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_piecesPerBoxMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('reorder_point')) {
      context.handle(
        _reorderPointMeta,
        reorderPoint.isAcceptableOrUnknown(
          data['reorder_point']!,
          _reorderPointMeta,
        ),
      );
    }
    if (data.containsKey('reorder_quantity')) {
      context.handle(
        _reorderQuantityMeta,
        reorderQuantity.isAcceptableOrUnknown(
          data['reorder_quantity']!,
          _reorderQuantityMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Product map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Product(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      productCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_code'],
      ),
      supplierId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}supplier_id'],
      )!,
      piecesPerBox: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pieces_per_box'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      reorderPoint: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reorder_point'],
      ),
      reorderQuantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reorder_quantity'],
      ),
    );
  }

  @override
  $ProductsTable createAlias(String alias) {
    return $ProductsTable(attachedDatabase, alias);
  }
}

class Product extends DataClass implements Insertable<Product> {
  final String id;
  final String name;
  final String? productCode;
  final String supplierId;
  final int piecesPerBox;
  final DateTime createdAt;
  final bool isDeleted;
  final int? reorderPoint;
  final int? reorderQuantity;
  const Product({
    required this.id,
    required this.name,
    this.productCode,
    required this.supplierId,
    required this.piecesPerBox,
    required this.createdAt,
    required this.isDeleted,
    this.reorderPoint,
    this.reorderQuantity,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || productCode != null) {
      map['product_code'] = Variable<String>(productCode);
    }
    map['supplier_id'] = Variable<String>(supplierId);
    map['pieces_per_box'] = Variable<int>(piecesPerBox);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    if (!nullToAbsent || reorderPoint != null) {
      map['reorder_point'] = Variable<int>(reorderPoint);
    }
    if (!nullToAbsent || reorderQuantity != null) {
      map['reorder_quantity'] = Variable<int>(reorderQuantity);
    }
    return map;
  }

  ProductsCompanion toCompanion(bool nullToAbsent) {
    return ProductsCompanion(
      id: Value(id),
      name: Value(name),
      productCode: productCode == null && nullToAbsent
          ? const Value.absent()
          : Value(productCode),
      supplierId: Value(supplierId),
      piecesPerBox: Value(piecesPerBox),
      createdAt: Value(createdAt),
      isDeleted: Value(isDeleted),
      reorderPoint: reorderPoint == null && nullToAbsent
          ? const Value.absent()
          : Value(reorderPoint),
      reorderQuantity: reorderQuantity == null && nullToAbsent
          ? const Value.absent()
          : Value(reorderQuantity),
    );
  }

  factory Product.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Product(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      productCode: serializer.fromJson<String?>(json['productCode']),
      supplierId: serializer.fromJson<String>(json['supplierId']),
      piecesPerBox: serializer.fromJson<int>(json['piecesPerBox']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      reorderPoint: serializer.fromJson<int?>(json['reorderPoint']),
      reorderQuantity: serializer.fromJson<int?>(json['reorderQuantity']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'productCode': serializer.toJson<String?>(productCode),
      'supplierId': serializer.toJson<String>(supplierId),
      'piecesPerBox': serializer.toJson<int>(piecesPerBox),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'reorderPoint': serializer.toJson<int?>(reorderPoint),
      'reorderQuantity': serializer.toJson<int?>(reorderQuantity),
    };
  }

  Product copyWith({
    String? id,
    String? name,
    Value<String?> productCode = const Value.absent(),
    String? supplierId,
    int? piecesPerBox,
    DateTime? createdAt,
    bool? isDeleted,
    Value<int?> reorderPoint = const Value.absent(),
    Value<int?> reorderQuantity = const Value.absent(),
  }) => Product(
    id: id ?? this.id,
    name: name ?? this.name,
    productCode: productCode.present ? productCode.value : this.productCode,
    supplierId: supplierId ?? this.supplierId,
    piecesPerBox: piecesPerBox ?? this.piecesPerBox,
    createdAt: createdAt ?? this.createdAt,
    isDeleted: isDeleted ?? this.isDeleted,
    reorderPoint: reorderPoint.present ? reorderPoint.value : this.reorderPoint,
    reorderQuantity: reorderQuantity.present
        ? reorderQuantity.value
        : this.reorderQuantity,
  );
  Product copyWithCompanion(ProductsCompanion data) {
    return Product(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      productCode: data.productCode.present
          ? data.productCode.value
          : this.productCode,
      supplierId: data.supplierId.present
          ? data.supplierId.value
          : this.supplierId,
      piecesPerBox: data.piecesPerBox.present
          ? data.piecesPerBox.value
          : this.piecesPerBox,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      reorderPoint: data.reorderPoint.present
          ? data.reorderPoint.value
          : this.reorderPoint,
      reorderQuantity: data.reorderQuantity.present
          ? data.reorderQuantity.value
          : this.reorderQuantity,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Product(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('productCode: $productCode, ')
          ..write('supplierId: $supplierId, ')
          ..write('piecesPerBox: $piecesPerBox, ')
          ..write('createdAt: $createdAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('reorderPoint: $reorderPoint, ')
          ..write('reorderQuantity: $reorderQuantity')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    productCode,
    supplierId,
    piecesPerBox,
    createdAt,
    isDeleted,
    reorderPoint,
    reorderQuantity,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Product &&
          other.id == this.id &&
          other.name == this.name &&
          other.productCode == this.productCode &&
          other.supplierId == this.supplierId &&
          other.piecesPerBox == this.piecesPerBox &&
          other.createdAt == this.createdAt &&
          other.isDeleted == this.isDeleted &&
          other.reorderPoint == this.reorderPoint &&
          other.reorderQuantity == this.reorderQuantity);
}

class ProductsCompanion extends UpdateCompanion<Product> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> productCode;
  final Value<String> supplierId;
  final Value<int> piecesPerBox;
  final Value<DateTime> createdAt;
  final Value<bool> isDeleted;
  final Value<int?> reorderPoint;
  final Value<int?> reorderQuantity;
  final Value<int> rowid;
  const ProductsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.productCode = const Value.absent(),
    this.supplierId = const Value.absent(),
    this.piecesPerBox = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.reorderPoint = const Value.absent(),
    this.reorderQuantity = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProductsCompanion.insert({
    required String id,
    required String name,
    this.productCode = const Value.absent(),
    required String supplierId,
    required int piecesPerBox,
    this.createdAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.reorderPoint = const Value.absent(),
    this.reorderQuantity = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       supplierId = Value(supplierId),
       piecesPerBox = Value(piecesPerBox);
  static Insertable<Product> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? productCode,
    Expression<String>? supplierId,
    Expression<int>? piecesPerBox,
    Expression<DateTime>? createdAt,
    Expression<bool>? isDeleted,
    Expression<int>? reorderPoint,
    Expression<int>? reorderQuantity,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (productCode != null) 'product_code': productCode,
      if (supplierId != null) 'supplier_id': supplierId,
      if (piecesPerBox != null) 'pieces_per_box': piecesPerBox,
      if (createdAt != null) 'created_at': createdAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (reorderPoint != null) 'reorder_point': reorderPoint,
      if (reorderQuantity != null) 'reorder_quantity': reorderQuantity,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProductsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? productCode,
    Value<String>? supplierId,
    Value<int>? piecesPerBox,
    Value<DateTime>? createdAt,
    Value<bool>? isDeleted,
    Value<int?>? reorderPoint,
    Value<int?>? reorderQuantity,
    Value<int>? rowid,
  }) {
    return ProductsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      productCode: productCode ?? this.productCode,
      supplierId: supplierId ?? this.supplierId,
      piecesPerBox: piecesPerBox ?? this.piecesPerBox,
      createdAt: createdAt ?? this.createdAt,
      isDeleted: isDeleted ?? this.isDeleted,
      reorderPoint: reorderPoint ?? this.reorderPoint,
      reorderQuantity: reorderQuantity ?? this.reorderQuantity,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (productCode.present) {
      map['product_code'] = Variable<String>(productCode.value);
    }
    if (supplierId.present) {
      map['supplier_id'] = Variable<String>(supplierId.value);
    }
    if (piecesPerBox.present) {
      map['pieces_per_box'] = Variable<int>(piecesPerBox.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (reorderPoint.present) {
      map['reorder_point'] = Variable<int>(reorderPoint.value);
    }
    if (reorderQuantity.present) {
      map['reorder_quantity'] = Variable<int>(reorderQuantity.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('productCode: $productCode, ')
          ..write('supplierId: $supplierId, ')
          ..write('piecesPerBox: $piecesPerBox, ')
          ..write('createdAt: $createdAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('reorderPoint: $reorderPoint, ')
          ..write('reorderQuantity: $reorderQuantity, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProductPricesTable extends ProductPrices
    with TableInfo<$ProductPricesTable, ProductPrice> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductPricesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES products (id)',
    ),
  );
  static const VerificationMeta _withdrawalPriceMeta = const VerificationMeta(
    'withdrawalPrice',
  );
  @override
  late final GeneratedColumn<double> withdrawalPrice = GeneratedColumn<double>(
    'withdrawal_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sellingPriceMeta = const VerificationMeta(
    'sellingPrice',
  );
  @override
  late final GeneratedColumn<double> sellingPrice = GeneratedColumn<double>(
    'selling_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sellingPriceOpMeta = const VerificationMeta(
    'sellingPriceOp',
  );
  @override
  late final GeneratedColumn<double> sellingPriceOp = GeneratedColumn<double>(
    'selling_price_op',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _effectiveFromMeta = const VerificationMeta(
    'effectiveFrom',
  );
  @override
  late final GeneratedColumn<DateTime> effectiveFrom =
      GeneratedColumn<DateTime>(
        'effective_from',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
        defaultValue: currentDateAndTime,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    productId,
    withdrawalPrice,
    sellingPrice,
    sellingPriceOp,
    effectiveFrom,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'product_prices';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProductPrice> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('withdrawal_price')) {
      context.handle(
        _withdrawalPriceMeta,
        withdrawalPrice.isAcceptableOrUnknown(
          data['withdrawal_price']!,
          _withdrawalPriceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_withdrawalPriceMeta);
    }
    if (data.containsKey('selling_price')) {
      context.handle(
        _sellingPriceMeta,
        sellingPrice.isAcceptableOrUnknown(
          data['selling_price']!,
          _sellingPriceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sellingPriceMeta);
    }
    if (data.containsKey('selling_price_op')) {
      context.handle(
        _sellingPriceOpMeta,
        sellingPriceOp.isAcceptableOrUnknown(
          data['selling_price_op']!,
          _sellingPriceOpMeta,
        ),
      );
    }
    if (data.containsKey('effective_from')) {
      context.handle(
        _effectiveFromMeta,
        effectiveFrom.isAcceptableOrUnknown(
          data['effective_from']!,
          _effectiveFromMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProductPrice map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProductPrice(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      )!,
      withdrawalPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}withdrawal_price'],
      )!,
      sellingPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}selling_price'],
      )!,
      sellingPriceOp: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}selling_price_op'],
      ),
      effectiveFrom: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}effective_from'],
      )!,
    );
  }

  @override
  $ProductPricesTable createAlias(String alias) {
    return $ProductPricesTable(attachedDatabase, alias);
  }
}

class ProductPrice extends DataClass implements Insertable<ProductPrice> {
  final String id;
  final String productId;
  final double withdrawalPrice;
  final double sellingPrice;
  final double? sellingPriceOp;
  final DateTime effectiveFrom;
  const ProductPrice({
    required this.id,
    required this.productId,
    required this.withdrawalPrice,
    required this.sellingPrice,
    this.sellingPriceOp,
    required this.effectiveFrom,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['product_id'] = Variable<String>(productId);
    map['withdrawal_price'] = Variable<double>(withdrawalPrice);
    map['selling_price'] = Variable<double>(sellingPrice);
    if (!nullToAbsent || sellingPriceOp != null) {
      map['selling_price_op'] = Variable<double>(sellingPriceOp);
    }
    map['effective_from'] = Variable<DateTime>(effectiveFrom);
    return map;
  }

  ProductPricesCompanion toCompanion(bool nullToAbsent) {
    return ProductPricesCompanion(
      id: Value(id),
      productId: Value(productId),
      withdrawalPrice: Value(withdrawalPrice),
      sellingPrice: Value(sellingPrice),
      sellingPriceOp: sellingPriceOp == null && nullToAbsent
          ? const Value.absent()
          : Value(sellingPriceOp),
      effectiveFrom: Value(effectiveFrom),
    );
  }

  factory ProductPrice.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProductPrice(
      id: serializer.fromJson<String>(json['id']),
      productId: serializer.fromJson<String>(json['productId']),
      withdrawalPrice: serializer.fromJson<double>(json['withdrawalPrice']),
      sellingPrice: serializer.fromJson<double>(json['sellingPrice']),
      sellingPriceOp: serializer.fromJson<double?>(json['sellingPriceOp']),
      effectiveFrom: serializer.fromJson<DateTime>(json['effectiveFrom']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'productId': serializer.toJson<String>(productId),
      'withdrawalPrice': serializer.toJson<double>(withdrawalPrice),
      'sellingPrice': serializer.toJson<double>(sellingPrice),
      'sellingPriceOp': serializer.toJson<double?>(sellingPriceOp),
      'effectiveFrom': serializer.toJson<DateTime>(effectiveFrom),
    };
  }

  ProductPrice copyWith({
    String? id,
    String? productId,
    double? withdrawalPrice,
    double? sellingPrice,
    Value<double?> sellingPriceOp = const Value.absent(),
    DateTime? effectiveFrom,
  }) => ProductPrice(
    id: id ?? this.id,
    productId: productId ?? this.productId,
    withdrawalPrice: withdrawalPrice ?? this.withdrawalPrice,
    sellingPrice: sellingPrice ?? this.sellingPrice,
    sellingPriceOp: sellingPriceOp.present
        ? sellingPriceOp.value
        : this.sellingPriceOp,
    effectiveFrom: effectiveFrom ?? this.effectiveFrom,
  );
  ProductPrice copyWithCompanion(ProductPricesCompanion data) {
    return ProductPrice(
      id: data.id.present ? data.id.value : this.id,
      productId: data.productId.present ? data.productId.value : this.productId,
      withdrawalPrice: data.withdrawalPrice.present
          ? data.withdrawalPrice.value
          : this.withdrawalPrice,
      sellingPrice: data.sellingPrice.present
          ? data.sellingPrice.value
          : this.sellingPrice,
      sellingPriceOp: data.sellingPriceOp.present
          ? data.sellingPriceOp.value
          : this.sellingPriceOp,
      effectiveFrom: data.effectiveFrom.present
          ? data.effectiveFrom.value
          : this.effectiveFrom,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProductPrice(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('withdrawalPrice: $withdrawalPrice, ')
          ..write('sellingPrice: $sellingPrice, ')
          ..write('sellingPriceOp: $sellingPriceOp, ')
          ..write('effectiveFrom: $effectiveFrom')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    productId,
    withdrawalPrice,
    sellingPrice,
    sellingPriceOp,
    effectiveFrom,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProductPrice &&
          other.id == this.id &&
          other.productId == this.productId &&
          other.withdrawalPrice == this.withdrawalPrice &&
          other.sellingPrice == this.sellingPrice &&
          other.sellingPriceOp == this.sellingPriceOp &&
          other.effectiveFrom == this.effectiveFrom);
}

class ProductPricesCompanion extends UpdateCompanion<ProductPrice> {
  final Value<String> id;
  final Value<String> productId;
  final Value<double> withdrawalPrice;
  final Value<double> sellingPrice;
  final Value<double?> sellingPriceOp;
  final Value<DateTime> effectiveFrom;
  final Value<int> rowid;
  const ProductPricesCompanion({
    this.id = const Value.absent(),
    this.productId = const Value.absent(),
    this.withdrawalPrice = const Value.absent(),
    this.sellingPrice = const Value.absent(),
    this.sellingPriceOp = const Value.absent(),
    this.effectiveFrom = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProductPricesCompanion.insert({
    required String id,
    required String productId,
    required double withdrawalPrice,
    required double sellingPrice,
    this.sellingPriceOp = const Value.absent(),
    this.effectiveFrom = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       productId = Value(productId),
       withdrawalPrice = Value(withdrawalPrice),
       sellingPrice = Value(sellingPrice);
  static Insertable<ProductPrice> custom({
    Expression<String>? id,
    Expression<String>? productId,
    Expression<double>? withdrawalPrice,
    Expression<double>? sellingPrice,
    Expression<double>? sellingPriceOp,
    Expression<DateTime>? effectiveFrom,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (productId != null) 'product_id': productId,
      if (withdrawalPrice != null) 'withdrawal_price': withdrawalPrice,
      if (sellingPrice != null) 'selling_price': sellingPrice,
      if (sellingPriceOp != null) 'selling_price_op': sellingPriceOp,
      if (effectiveFrom != null) 'effective_from': effectiveFrom,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProductPricesCompanion copyWith({
    Value<String>? id,
    Value<String>? productId,
    Value<double>? withdrawalPrice,
    Value<double>? sellingPrice,
    Value<double?>? sellingPriceOp,
    Value<DateTime>? effectiveFrom,
    Value<int>? rowid,
  }) {
    return ProductPricesCompanion(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      withdrawalPrice: withdrawalPrice ?? this.withdrawalPrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      sellingPriceOp: sellingPriceOp ?? this.sellingPriceOp,
      effectiveFrom: effectiveFrom ?? this.effectiveFrom,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (withdrawalPrice.present) {
      map['withdrawal_price'] = Variable<double>(withdrawalPrice.value);
    }
    if (sellingPrice.present) {
      map['selling_price'] = Variable<double>(sellingPrice.value);
    }
    if (sellingPriceOp.present) {
      map['selling_price_op'] = Variable<double>(sellingPriceOp.value);
    }
    if (effectiveFrom.present) {
      map['effective_from'] = Variable<DateTime>(effectiveFrom.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductPricesCompanion(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('withdrawalPrice: $withdrawalPrice, ')
          ..write('sellingPrice: $sellingPrice, ')
          ..write('sellingPriceOp: $sellingPriceOp, ')
          ..write('effectiveFrom: $effectiveFrom, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProductDiscountsTable extends ProductDiscounts
    with TableInfo<$ProductDiscountsTable, ProductDiscount> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductDiscountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES products (id)',
    ),
  );
  static const VerificationMeta _minQuantityPiecesMeta = const VerificationMeta(
    'minQuantityPieces',
  );
  @override
  late final GeneratedColumn<int> minQuantityPieces = GeneratedColumn<int>(
    'min_quantity_pieces',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _discountPercentMeta = const VerificationMeta(
    'discountPercent',
  );
  @override
  late final GeneratedColumn<double> discountPercent = GeneratedColumn<double>(
    'discount_percent',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _discountTypeMeta = const VerificationMeta(
    'discountType',
  );
  @override
  late final GeneratedColumn<String> discountType = GeneratedColumn<String>(
    'discount_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('percent'),
  );
  static const VerificationMeta _freeQuantityPiecesMeta =
      const VerificationMeta('freeQuantityPieces');
  @override
  late final GeneratedColumn<int> freeQuantityPieces = GeneratedColumn<int>(
    'free_quantity_pieces',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _freeQuantityUnitMeta = const VerificationMeta(
    'freeQuantityUnit',
  );
  @override
  late final GeneratedColumn<String> freeQuantityUnit = GeneratedColumn<String>(
    'free_quantity_unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('box'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    productId,
    minQuantityPieces,
    discountPercent,
    discountType,
    freeQuantityPieces,
    freeQuantityUnit,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'product_discounts';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProductDiscount> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('min_quantity_pieces')) {
      context.handle(
        _minQuantityPiecesMeta,
        minQuantityPieces.isAcceptableOrUnknown(
          data['min_quantity_pieces']!,
          _minQuantityPiecesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_minQuantityPiecesMeta);
    }
    if (data.containsKey('discount_percent')) {
      context.handle(
        _discountPercentMeta,
        discountPercent.isAcceptableOrUnknown(
          data['discount_percent']!,
          _discountPercentMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_discountPercentMeta);
    }
    if (data.containsKey('discount_type')) {
      context.handle(
        _discountTypeMeta,
        discountType.isAcceptableOrUnknown(
          data['discount_type']!,
          _discountTypeMeta,
        ),
      );
    }
    if (data.containsKey('free_quantity_pieces')) {
      context.handle(
        _freeQuantityPiecesMeta,
        freeQuantityPieces.isAcceptableOrUnknown(
          data['free_quantity_pieces']!,
          _freeQuantityPiecesMeta,
        ),
      );
    }
    if (data.containsKey('free_quantity_unit')) {
      context.handle(
        _freeQuantityUnitMeta,
        freeQuantityUnit.isAcceptableOrUnknown(
          data['free_quantity_unit']!,
          _freeQuantityUnitMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProductDiscount map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProductDiscount(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      )!,
      minQuantityPieces: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}min_quantity_pieces'],
      )!,
      discountPercent: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}discount_percent'],
      )!,
      discountType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}discount_type'],
      )!,
      freeQuantityPieces: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}free_quantity_pieces'],
      ),
      freeQuantityUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}free_quantity_unit'],
      )!,
    );
  }

  @override
  $ProductDiscountsTable createAlias(String alias) {
    return $ProductDiscountsTable(attachedDatabase, alias);
  }
}

class ProductDiscount extends DataClass implements Insertable<ProductDiscount> {
  final String id;
  final String productId;
  final int minQuantityPieces;
  final double discountPercent;
  final String discountType;
  final int? freeQuantityPieces;
  final String freeQuantityUnit;
  const ProductDiscount({
    required this.id,
    required this.productId,
    required this.minQuantityPieces,
    required this.discountPercent,
    required this.discountType,
    this.freeQuantityPieces,
    required this.freeQuantityUnit,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['product_id'] = Variable<String>(productId);
    map['min_quantity_pieces'] = Variable<int>(minQuantityPieces);
    map['discount_percent'] = Variable<double>(discountPercent);
    map['discount_type'] = Variable<String>(discountType);
    if (!nullToAbsent || freeQuantityPieces != null) {
      map['free_quantity_pieces'] = Variable<int>(freeQuantityPieces);
    }
    map['free_quantity_unit'] = Variable<String>(freeQuantityUnit);
    return map;
  }

  ProductDiscountsCompanion toCompanion(bool nullToAbsent) {
    return ProductDiscountsCompanion(
      id: Value(id),
      productId: Value(productId),
      minQuantityPieces: Value(minQuantityPieces),
      discountPercent: Value(discountPercent),
      discountType: Value(discountType),
      freeQuantityPieces: freeQuantityPieces == null && nullToAbsent
          ? const Value.absent()
          : Value(freeQuantityPieces),
      freeQuantityUnit: Value(freeQuantityUnit),
    );
  }

  factory ProductDiscount.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProductDiscount(
      id: serializer.fromJson<String>(json['id']),
      productId: serializer.fromJson<String>(json['productId']),
      minQuantityPieces: serializer.fromJson<int>(json['minQuantityPieces']),
      discountPercent: serializer.fromJson<double>(json['discountPercent']),
      discountType: serializer.fromJson<String>(json['discountType']),
      freeQuantityPieces: serializer.fromJson<int?>(json['freeQuantityPieces']),
      freeQuantityUnit: serializer.fromJson<String>(json['freeQuantityUnit']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'productId': serializer.toJson<String>(productId),
      'minQuantityPieces': serializer.toJson<int>(minQuantityPieces),
      'discountPercent': serializer.toJson<double>(discountPercent),
      'discountType': serializer.toJson<String>(discountType),
      'freeQuantityPieces': serializer.toJson<int?>(freeQuantityPieces),
      'freeQuantityUnit': serializer.toJson<String>(freeQuantityUnit),
    };
  }

  ProductDiscount copyWith({
    String? id,
    String? productId,
    int? minQuantityPieces,
    double? discountPercent,
    String? discountType,
    Value<int?> freeQuantityPieces = const Value.absent(),
    String? freeQuantityUnit,
  }) => ProductDiscount(
    id: id ?? this.id,
    productId: productId ?? this.productId,
    minQuantityPieces: minQuantityPieces ?? this.minQuantityPieces,
    discountPercent: discountPercent ?? this.discountPercent,
    discountType: discountType ?? this.discountType,
    freeQuantityPieces: freeQuantityPieces.present
        ? freeQuantityPieces.value
        : this.freeQuantityPieces,
    freeQuantityUnit: freeQuantityUnit ?? this.freeQuantityUnit,
  );
  ProductDiscount copyWithCompanion(ProductDiscountsCompanion data) {
    return ProductDiscount(
      id: data.id.present ? data.id.value : this.id,
      productId: data.productId.present ? data.productId.value : this.productId,
      minQuantityPieces: data.minQuantityPieces.present
          ? data.minQuantityPieces.value
          : this.minQuantityPieces,
      discountPercent: data.discountPercent.present
          ? data.discountPercent.value
          : this.discountPercent,
      discountType: data.discountType.present
          ? data.discountType.value
          : this.discountType,
      freeQuantityPieces: data.freeQuantityPieces.present
          ? data.freeQuantityPieces.value
          : this.freeQuantityPieces,
      freeQuantityUnit: data.freeQuantityUnit.present
          ? data.freeQuantityUnit.value
          : this.freeQuantityUnit,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProductDiscount(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('minQuantityPieces: $minQuantityPieces, ')
          ..write('discountPercent: $discountPercent, ')
          ..write('discountType: $discountType, ')
          ..write('freeQuantityPieces: $freeQuantityPieces, ')
          ..write('freeQuantityUnit: $freeQuantityUnit')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    productId,
    minQuantityPieces,
    discountPercent,
    discountType,
    freeQuantityPieces,
    freeQuantityUnit,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProductDiscount &&
          other.id == this.id &&
          other.productId == this.productId &&
          other.minQuantityPieces == this.minQuantityPieces &&
          other.discountPercent == this.discountPercent &&
          other.discountType == this.discountType &&
          other.freeQuantityPieces == this.freeQuantityPieces &&
          other.freeQuantityUnit == this.freeQuantityUnit);
}

class ProductDiscountsCompanion extends UpdateCompanion<ProductDiscount> {
  final Value<String> id;
  final Value<String> productId;
  final Value<int> minQuantityPieces;
  final Value<double> discountPercent;
  final Value<String> discountType;
  final Value<int?> freeQuantityPieces;
  final Value<String> freeQuantityUnit;
  final Value<int> rowid;
  const ProductDiscountsCompanion({
    this.id = const Value.absent(),
    this.productId = const Value.absent(),
    this.minQuantityPieces = const Value.absent(),
    this.discountPercent = const Value.absent(),
    this.discountType = const Value.absent(),
    this.freeQuantityPieces = const Value.absent(),
    this.freeQuantityUnit = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProductDiscountsCompanion.insert({
    required String id,
    required String productId,
    required int minQuantityPieces,
    required double discountPercent,
    this.discountType = const Value.absent(),
    this.freeQuantityPieces = const Value.absent(),
    this.freeQuantityUnit = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       productId = Value(productId),
       minQuantityPieces = Value(minQuantityPieces),
       discountPercent = Value(discountPercent);
  static Insertable<ProductDiscount> custom({
    Expression<String>? id,
    Expression<String>? productId,
    Expression<int>? minQuantityPieces,
    Expression<double>? discountPercent,
    Expression<String>? discountType,
    Expression<int>? freeQuantityPieces,
    Expression<String>? freeQuantityUnit,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (productId != null) 'product_id': productId,
      if (minQuantityPieces != null) 'min_quantity_pieces': minQuantityPieces,
      if (discountPercent != null) 'discount_percent': discountPercent,
      if (discountType != null) 'discount_type': discountType,
      if (freeQuantityPieces != null)
        'free_quantity_pieces': freeQuantityPieces,
      if (freeQuantityUnit != null) 'free_quantity_unit': freeQuantityUnit,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProductDiscountsCompanion copyWith({
    Value<String>? id,
    Value<String>? productId,
    Value<int>? minQuantityPieces,
    Value<double>? discountPercent,
    Value<String>? discountType,
    Value<int?>? freeQuantityPieces,
    Value<String>? freeQuantityUnit,
    Value<int>? rowid,
  }) {
    return ProductDiscountsCompanion(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      minQuantityPieces: minQuantityPieces ?? this.minQuantityPieces,
      discountPercent: discountPercent ?? this.discountPercent,
      discountType: discountType ?? this.discountType,
      freeQuantityPieces: freeQuantityPieces ?? this.freeQuantityPieces,
      freeQuantityUnit: freeQuantityUnit ?? this.freeQuantityUnit,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (minQuantityPieces.present) {
      map['min_quantity_pieces'] = Variable<int>(minQuantityPieces.value);
    }
    if (discountPercent.present) {
      map['discount_percent'] = Variable<double>(discountPercent.value);
    }
    if (discountType.present) {
      map['discount_type'] = Variable<String>(discountType.value);
    }
    if (freeQuantityPieces.present) {
      map['free_quantity_pieces'] = Variable<int>(freeQuantityPieces.value);
    }
    if (freeQuantityUnit.present) {
      map['free_quantity_unit'] = Variable<String>(freeQuantityUnit.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductDiscountsCompanion(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('minQuantityPieces: $minQuantityPieces, ')
          ..write('discountPercent: $discountPercent, ')
          ..write('discountType: $discountType, ')
          ..write('freeQuantityPieces: $freeQuantityPieces, ')
          ..write('freeQuantityUnit: $freeQuantityUnit, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProductSupplierPricesTable extends ProductSupplierPrices
    with TableInfo<$ProductSupplierPricesTable, ProductSupplierPrice> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductSupplierPricesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES products (id)',
    ),
  );
  static const VerificationMeta _priceBoxMeta = const VerificationMeta(
    'priceBox',
  );
  @override
  late final GeneratedColumn<double> priceBox = GeneratedColumn<double>(
    'price_box',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _discountPercentsMeta = const VerificationMeta(
    'discountPercents',
  );
  @override
  late final GeneratedColumn<String> discountPercents = GeneratedColumn<String>(
    'discount_percents',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _vatEnabledMeta = const VerificationMeta(
    'vatEnabled',
  );
  @override
  late final GeneratedColumn<bool> vatEnabled = GeneratedColumn<bool>(
    'vat_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("vat_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _buyMinQuantityPiecesMeta =
      const VerificationMeta('buyMinQuantityPieces');
  @override
  late final GeneratedColumn<int> buyMinQuantityPieces = GeneratedColumn<int>(
    'buy_min_quantity_pieces',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _freeQuantityPiecesMeta =
      const VerificationMeta('freeQuantityPieces');
  @override
  late final GeneratedColumn<int> freeQuantityPieces = GeneratedColumn<int>(
    'free_quantity_pieces',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _freeQuantityUnitMeta = const VerificationMeta(
    'freeQuantityUnit',
  );
  @override
  late final GeneratedColumn<String> freeQuantityUnit = GeneratedColumn<String>(
    'free_quantity_unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('box'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    productId,
    priceBox,
    discountPercents,
    vatEnabled,
    buyMinQuantityPieces,
    freeQuantityPieces,
    freeQuantityUnit,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'product_supplier_prices';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProductSupplierPrice> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('price_box')) {
      context.handle(
        _priceBoxMeta,
        priceBox.isAcceptableOrUnknown(data['price_box']!, _priceBoxMeta),
      );
    } else if (isInserting) {
      context.missing(_priceBoxMeta);
    }
    if (data.containsKey('discount_percents')) {
      context.handle(
        _discountPercentsMeta,
        discountPercents.isAcceptableOrUnknown(
          data['discount_percents']!,
          _discountPercentsMeta,
        ),
      );
    }
    if (data.containsKey('vat_enabled')) {
      context.handle(
        _vatEnabledMeta,
        vatEnabled.isAcceptableOrUnknown(data['vat_enabled']!, _vatEnabledMeta),
      );
    }
    if (data.containsKey('buy_min_quantity_pieces')) {
      context.handle(
        _buyMinQuantityPiecesMeta,
        buyMinQuantityPieces.isAcceptableOrUnknown(
          data['buy_min_quantity_pieces']!,
          _buyMinQuantityPiecesMeta,
        ),
      );
    }
    if (data.containsKey('free_quantity_pieces')) {
      context.handle(
        _freeQuantityPiecesMeta,
        freeQuantityPieces.isAcceptableOrUnknown(
          data['free_quantity_pieces']!,
          _freeQuantityPiecesMeta,
        ),
      );
    }
    if (data.containsKey('free_quantity_unit')) {
      context.handle(
        _freeQuantityUnitMeta,
        freeQuantityUnit.isAcceptableOrUnknown(
          data['free_quantity_unit']!,
          _freeQuantityUnitMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProductSupplierPrice map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProductSupplierPrice(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      )!,
      priceBox: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}price_box'],
      )!,
      discountPercents: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}discount_percents'],
      ),
      vatEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}vat_enabled'],
      )!,
      buyMinQuantityPieces: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}buy_min_quantity_pieces'],
      ),
      freeQuantityPieces: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}free_quantity_pieces'],
      ),
      freeQuantityUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}free_quantity_unit'],
      )!,
    );
  }

  @override
  $ProductSupplierPricesTable createAlias(String alias) {
    return $ProductSupplierPricesTable(attachedDatabase, alias);
  }
}

class ProductSupplierPrice extends DataClass
    implements Insertable<ProductSupplierPrice> {
  final String id;
  final String productId;
  final double priceBox;
  final String? discountPercents;
  final bool vatEnabled;
  final int? buyMinQuantityPieces;
  final int? freeQuantityPieces;
  final String freeQuantityUnit;
  const ProductSupplierPrice({
    required this.id,
    required this.productId,
    required this.priceBox,
    this.discountPercents,
    required this.vatEnabled,
    this.buyMinQuantityPieces,
    this.freeQuantityPieces,
    required this.freeQuantityUnit,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['product_id'] = Variable<String>(productId);
    map['price_box'] = Variable<double>(priceBox);
    if (!nullToAbsent || discountPercents != null) {
      map['discount_percents'] = Variable<String>(discountPercents);
    }
    map['vat_enabled'] = Variable<bool>(vatEnabled);
    if (!nullToAbsent || buyMinQuantityPieces != null) {
      map['buy_min_quantity_pieces'] = Variable<int>(buyMinQuantityPieces);
    }
    if (!nullToAbsent || freeQuantityPieces != null) {
      map['free_quantity_pieces'] = Variable<int>(freeQuantityPieces);
    }
    map['free_quantity_unit'] = Variable<String>(freeQuantityUnit);
    return map;
  }

  ProductSupplierPricesCompanion toCompanion(bool nullToAbsent) {
    return ProductSupplierPricesCompanion(
      id: Value(id),
      productId: Value(productId),
      priceBox: Value(priceBox),
      discountPercents: discountPercents == null && nullToAbsent
          ? const Value.absent()
          : Value(discountPercents),
      vatEnabled: Value(vatEnabled),
      buyMinQuantityPieces: buyMinQuantityPieces == null && nullToAbsent
          ? const Value.absent()
          : Value(buyMinQuantityPieces),
      freeQuantityPieces: freeQuantityPieces == null && nullToAbsent
          ? const Value.absent()
          : Value(freeQuantityPieces),
      freeQuantityUnit: Value(freeQuantityUnit),
    );
  }

  factory ProductSupplierPrice.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProductSupplierPrice(
      id: serializer.fromJson<String>(json['id']),
      productId: serializer.fromJson<String>(json['productId']),
      priceBox: serializer.fromJson<double>(json['priceBox']),
      discountPercents: serializer.fromJson<String?>(json['discountPercents']),
      vatEnabled: serializer.fromJson<bool>(json['vatEnabled']),
      buyMinQuantityPieces: serializer.fromJson<int?>(
        json['buyMinQuantityPieces'],
      ),
      freeQuantityPieces: serializer.fromJson<int?>(json['freeQuantityPieces']),
      freeQuantityUnit: serializer.fromJson<String>(json['freeQuantityUnit']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'productId': serializer.toJson<String>(productId),
      'priceBox': serializer.toJson<double>(priceBox),
      'discountPercents': serializer.toJson<String?>(discountPercents),
      'vatEnabled': serializer.toJson<bool>(vatEnabled),
      'buyMinQuantityPieces': serializer.toJson<int?>(buyMinQuantityPieces),
      'freeQuantityPieces': serializer.toJson<int?>(freeQuantityPieces),
      'freeQuantityUnit': serializer.toJson<String>(freeQuantityUnit),
    };
  }

  ProductSupplierPrice copyWith({
    String? id,
    String? productId,
    double? priceBox,
    Value<String?> discountPercents = const Value.absent(),
    bool? vatEnabled,
    Value<int?> buyMinQuantityPieces = const Value.absent(),
    Value<int?> freeQuantityPieces = const Value.absent(),
    String? freeQuantityUnit,
  }) => ProductSupplierPrice(
    id: id ?? this.id,
    productId: productId ?? this.productId,
    priceBox: priceBox ?? this.priceBox,
    discountPercents: discountPercents.present
        ? discountPercents.value
        : this.discountPercents,
    vatEnabled: vatEnabled ?? this.vatEnabled,
    buyMinQuantityPieces: buyMinQuantityPieces.present
        ? buyMinQuantityPieces.value
        : this.buyMinQuantityPieces,
    freeQuantityPieces: freeQuantityPieces.present
        ? freeQuantityPieces.value
        : this.freeQuantityPieces,
    freeQuantityUnit: freeQuantityUnit ?? this.freeQuantityUnit,
  );
  ProductSupplierPrice copyWithCompanion(ProductSupplierPricesCompanion data) {
    return ProductSupplierPrice(
      id: data.id.present ? data.id.value : this.id,
      productId: data.productId.present ? data.productId.value : this.productId,
      priceBox: data.priceBox.present ? data.priceBox.value : this.priceBox,
      discountPercents: data.discountPercents.present
          ? data.discountPercents.value
          : this.discountPercents,
      vatEnabled: data.vatEnabled.present
          ? data.vatEnabled.value
          : this.vatEnabled,
      buyMinQuantityPieces: data.buyMinQuantityPieces.present
          ? data.buyMinQuantityPieces.value
          : this.buyMinQuantityPieces,
      freeQuantityPieces: data.freeQuantityPieces.present
          ? data.freeQuantityPieces.value
          : this.freeQuantityPieces,
      freeQuantityUnit: data.freeQuantityUnit.present
          ? data.freeQuantityUnit.value
          : this.freeQuantityUnit,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProductSupplierPrice(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('priceBox: $priceBox, ')
          ..write('discountPercents: $discountPercents, ')
          ..write('vatEnabled: $vatEnabled, ')
          ..write('buyMinQuantityPieces: $buyMinQuantityPieces, ')
          ..write('freeQuantityPieces: $freeQuantityPieces, ')
          ..write('freeQuantityUnit: $freeQuantityUnit')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    productId,
    priceBox,
    discountPercents,
    vatEnabled,
    buyMinQuantityPieces,
    freeQuantityPieces,
    freeQuantityUnit,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProductSupplierPrice &&
          other.id == this.id &&
          other.productId == this.productId &&
          other.priceBox == this.priceBox &&
          other.discountPercents == this.discountPercents &&
          other.vatEnabled == this.vatEnabled &&
          other.buyMinQuantityPieces == this.buyMinQuantityPieces &&
          other.freeQuantityPieces == this.freeQuantityPieces &&
          other.freeQuantityUnit == this.freeQuantityUnit);
}

class ProductSupplierPricesCompanion
    extends UpdateCompanion<ProductSupplierPrice> {
  final Value<String> id;
  final Value<String> productId;
  final Value<double> priceBox;
  final Value<String?> discountPercents;
  final Value<bool> vatEnabled;
  final Value<int?> buyMinQuantityPieces;
  final Value<int?> freeQuantityPieces;
  final Value<String> freeQuantityUnit;
  final Value<int> rowid;
  const ProductSupplierPricesCompanion({
    this.id = const Value.absent(),
    this.productId = const Value.absent(),
    this.priceBox = const Value.absent(),
    this.discountPercents = const Value.absent(),
    this.vatEnabled = const Value.absent(),
    this.buyMinQuantityPieces = const Value.absent(),
    this.freeQuantityPieces = const Value.absent(),
    this.freeQuantityUnit = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProductSupplierPricesCompanion.insert({
    required String id,
    required String productId,
    required double priceBox,
    this.discountPercents = const Value.absent(),
    this.vatEnabled = const Value.absent(),
    this.buyMinQuantityPieces = const Value.absent(),
    this.freeQuantityPieces = const Value.absent(),
    this.freeQuantityUnit = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       productId = Value(productId),
       priceBox = Value(priceBox);
  static Insertable<ProductSupplierPrice> custom({
    Expression<String>? id,
    Expression<String>? productId,
    Expression<double>? priceBox,
    Expression<String>? discountPercents,
    Expression<bool>? vatEnabled,
    Expression<int>? buyMinQuantityPieces,
    Expression<int>? freeQuantityPieces,
    Expression<String>? freeQuantityUnit,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (productId != null) 'product_id': productId,
      if (priceBox != null) 'price_box': priceBox,
      if (discountPercents != null) 'discount_percents': discountPercents,
      if (vatEnabled != null) 'vat_enabled': vatEnabled,
      if (buyMinQuantityPieces != null)
        'buy_min_quantity_pieces': buyMinQuantityPieces,
      if (freeQuantityPieces != null)
        'free_quantity_pieces': freeQuantityPieces,
      if (freeQuantityUnit != null) 'free_quantity_unit': freeQuantityUnit,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProductSupplierPricesCompanion copyWith({
    Value<String>? id,
    Value<String>? productId,
    Value<double>? priceBox,
    Value<String?>? discountPercents,
    Value<bool>? vatEnabled,
    Value<int?>? buyMinQuantityPieces,
    Value<int?>? freeQuantityPieces,
    Value<String>? freeQuantityUnit,
    Value<int>? rowid,
  }) {
    return ProductSupplierPricesCompanion(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      priceBox: priceBox ?? this.priceBox,
      discountPercents: discountPercents ?? this.discountPercents,
      vatEnabled: vatEnabled ?? this.vatEnabled,
      buyMinQuantityPieces: buyMinQuantityPieces ?? this.buyMinQuantityPieces,
      freeQuantityPieces: freeQuantityPieces ?? this.freeQuantityPieces,
      freeQuantityUnit: freeQuantityUnit ?? this.freeQuantityUnit,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (priceBox.present) {
      map['price_box'] = Variable<double>(priceBox.value);
    }
    if (discountPercents.present) {
      map['discount_percents'] = Variable<String>(discountPercents.value);
    }
    if (vatEnabled.present) {
      map['vat_enabled'] = Variable<bool>(vatEnabled.value);
    }
    if (buyMinQuantityPieces.present) {
      map['buy_min_quantity_pieces'] = Variable<int>(
        buyMinQuantityPieces.value,
      );
    }
    if (freeQuantityPieces.present) {
      map['free_quantity_pieces'] = Variable<int>(freeQuantityPieces.value);
    }
    if (freeQuantityUnit.present) {
      map['free_quantity_unit'] = Variable<String>(freeQuantityUnit.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductSupplierPricesCompanion(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('priceBox: $priceBox, ')
          ..write('discountPercents: $discountPercents, ')
          ..write('vatEnabled: $vatEnabled, ')
          ..write('buyMinQuantityPieces: $buyMinQuantityPieces, ')
          ..write('freeQuantityPieces: $freeQuantityPieces, ')
          ..write('freeQuantityUnit: $freeQuantityUnit, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InventoryTable extends Inventory
    with TableInfo<$InventoryTable, InventoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InventoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES products (id)',
    ),
  );
  static const VerificationMeta _quantityPiecesMeta = const VerificationMeta(
    'quantityPieces',
  );
  @override
  late final GeneratedColumn<int> quantityPieces = GeneratedColumn<int>(
    'quantity_pieces',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastUpdatedMeta = const VerificationMeta(
    'lastUpdated',
  );
  @override
  late final GeneratedColumn<DateTime> lastUpdated = GeneratedColumn<DateTime>(
    'last_updated',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    productId,
    quantityPieces,
    lastUpdated,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'inventory';
  @override
  VerificationContext validateIntegrity(
    Insertable<InventoryData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('quantity_pieces')) {
      context.handle(
        _quantityPiecesMeta,
        quantityPieces.isAcceptableOrUnknown(
          data['quantity_pieces']!,
          _quantityPiecesMeta,
        ),
      );
    }
    if (data.containsKey('last_updated')) {
      context.handle(
        _lastUpdatedMeta,
        lastUpdated.isAcceptableOrUnknown(
          data['last_updated']!,
          _lastUpdatedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InventoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InventoryData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      )!,
      quantityPieces: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity_pieces'],
      )!,
      lastUpdated: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_updated'],
      )!,
    );
  }

  @override
  $InventoryTable createAlias(String alias) {
    return $InventoryTable(attachedDatabase, alias);
  }
}

class InventoryData extends DataClass implements Insertable<InventoryData> {
  final String id;
  final String productId;
  final int quantityPieces;
  final DateTime lastUpdated;
  const InventoryData({
    required this.id,
    required this.productId,
    required this.quantityPieces,
    required this.lastUpdated,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['product_id'] = Variable<String>(productId);
    map['quantity_pieces'] = Variable<int>(quantityPieces);
    map['last_updated'] = Variable<DateTime>(lastUpdated);
    return map;
  }

  InventoryCompanion toCompanion(bool nullToAbsent) {
    return InventoryCompanion(
      id: Value(id),
      productId: Value(productId),
      quantityPieces: Value(quantityPieces),
      lastUpdated: Value(lastUpdated),
    );
  }

  factory InventoryData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InventoryData(
      id: serializer.fromJson<String>(json['id']),
      productId: serializer.fromJson<String>(json['productId']),
      quantityPieces: serializer.fromJson<int>(json['quantityPieces']),
      lastUpdated: serializer.fromJson<DateTime>(json['lastUpdated']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'productId': serializer.toJson<String>(productId),
      'quantityPieces': serializer.toJson<int>(quantityPieces),
      'lastUpdated': serializer.toJson<DateTime>(lastUpdated),
    };
  }

  InventoryData copyWith({
    String? id,
    String? productId,
    int? quantityPieces,
    DateTime? lastUpdated,
  }) => InventoryData(
    id: id ?? this.id,
    productId: productId ?? this.productId,
    quantityPieces: quantityPieces ?? this.quantityPieces,
    lastUpdated: lastUpdated ?? this.lastUpdated,
  );
  InventoryData copyWithCompanion(InventoryCompanion data) {
    return InventoryData(
      id: data.id.present ? data.id.value : this.id,
      productId: data.productId.present ? data.productId.value : this.productId,
      quantityPieces: data.quantityPieces.present
          ? data.quantityPieces.value
          : this.quantityPieces,
      lastUpdated: data.lastUpdated.present
          ? data.lastUpdated.value
          : this.lastUpdated,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InventoryData(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('quantityPieces: $quantityPieces, ')
          ..write('lastUpdated: $lastUpdated')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, productId, quantityPieces, lastUpdated);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InventoryData &&
          other.id == this.id &&
          other.productId == this.productId &&
          other.quantityPieces == this.quantityPieces &&
          other.lastUpdated == this.lastUpdated);
}

class InventoryCompanion extends UpdateCompanion<InventoryData> {
  final Value<String> id;
  final Value<String> productId;
  final Value<int> quantityPieces;
  final Value<DateTime> lastUpdated;
  final Value<int> rowid;
  const InventoryCompanion({
    this.id = const Value.absent(),
    this.productId = const Value.absent(),
    this.quantityPieces = const Value.absent(),
    this.lastUpdated = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InventoryCompanion.insert({
    required String id,
    required String productId,
    this.quantityPieces = const Value.absent(),
    this.lastUpdated = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       productId = Value(productId);
  static Insertable<InventoryData> custom({
    Expression<String>? id,
    Expression<String>? productId,
    Expression<int>? quantityPieces,
    Expression<DateTime>? lastUpdated,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (productId != null) 'product_id': productId,
      if (quantityPieces != null) 'quantity_pieces': quantityPieces,
      if (lastUpdated != null) 'last_updated': lastUpdated,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InventoryCompanion copyWith({
    Value<String>? id,
    Value<String>? productId,
    Value<int>? quantityPieces,
    Value<DateTime>? lastUpdated,
    Value<int>? rowid,
  }) {
    return InventoryCompanion(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      quantityPieces: quantityPieces ?? this.quantityPieces,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (quantityPieces.present) {
      map['quantity_pieces'] = Variable<int>(quantityPieces.value);
    }
    if (lastUpdated.present) {
      map['last_updated'] = Variable<DateTime>(lastUpdated.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InventoryCompanion(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('quantityPieces: $quantityPieces, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InvoicesTable extends Invoices with TableInfo<$InvoicesTable, Invoice> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InvoicesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _clientIdMeta = const VerificationMeta(
    'clientId',
  );
  @override
  late final GeneratedColumn<String> clientId = GeneratedColumn<String>(
    'client_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES clients (id)',
    ),
  );
  static const VerificationMeta _invoiceDateMeta = const VerificationMeta(
    'invoiceDate',
  );
  @override
  late final GeneratedColumn<DateTime> invoiceDate = GeneratedColumn<DateTime>(
    'invoice_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _totalAmountMeta = const VerificationMeta(
    'totalAmount',
  );
  @override
  late final GeneratedColumn<double> totalAmount = GeneratedColumn<double>(
    'total_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('draft'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _invoiceNumberMeta = const VerificationMeta(
    'invoiceNumber',
  );
  @override
  late final GeneratedColumn<String> invoiceNumber = GeneratedColumn<String>(
    'invoice_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sequenceNumberMeta = const VerificationMeta(
    'sequenceNumber',
  );
  @override
  late final GeneratedColumn<int> sequenceNumber = GeneratedColumn<int>(
    'sequence_number',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _invoiceTypeMeta = const VerificationMeta(
    'invoiceType',
  );
  @override
  late final GeneratedColumn<String> invoiceType = GeneratedColumn<String>(
    'invoice_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('delivery'),
  );
  static const VerificationMeta _paymentTypeMeta = const VerificationMeta(
    'paymentType',
  );
  @override
  late final GeneratedColumn<String> paymentType = GeneratedColumn<String>(
    'payment_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('cash'),
  );
  static const VerificationMeta _partialAmountMeta = const VerificationMeta(
    'partialAmount',
  );
  @override
  late final GeneratedColumn<double> partialAmount = GeneratedColumn<double>(
    'partial_amount',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _partialDateMeta = const VerificationMeta(
    'partialDate',
  );
  @override
  late final GeneratedColumn<DateTime> partialDate = GeneratedColumn<DateTime>(
    'partial_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _checkReferenceMeta = const VerificationMeta(
    'checkReference',
  );
  @override
  late final GeneratedColumn<String> checkReference = GeneratedColumn<String>(
    'check_reference',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _checkAmountMeta = const VerificationMeta(
    'checkAmount',
  );
  @override
  late final GeneratedColumn<double> checkAmount = GeneratedColumn<double>(
    'check_amount',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _checkIssuedDateMeta = const VerificationMeta(
    'checkIssuedDate',
  );
  @override
  late final GeneratedColumn<DateTime> checkIssuedDate =
      GeneratedColumn<DateTime>(
        'check_issued_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _checkDueDateMeta = const VerificationMeta(
    'checkDueDate',
  );
  @override
  late final GeneratedColumn<DateTime> checkDueDate = GeneratedColumn<DateTime>(
    'check_due_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _actualAmountMeta = const VerificationMeta(
    'actualAmount',
  );
  @override
  late final GeneratedColumn<double> actualAmount = GeneratedColumn<double>(
    'actual_amount',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _swapAmountMeta = const VerificationMeta(
    'swapAmount',
  );
  @override
  late final GeneratedColumn<double> swapAmount = GeneratedColumn<double>(
    'swap_amount',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stockPulledOutAmountMeta =
      const VerificationMeta('stockPulledOutAmount');
  @override
  late final GeneratedColumn<double> stockPulledOutAmount =
      GeneratedColumn<double>(
        'stock_pulled_out_amount',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _stockPulledOutCostMeta =
      const VerificationMeta('stockPulledOutCost');
  @override
  late final GeneratedColumn<double> stockPulledOutCost =
      GeneratedColumn<double>(
        'stock_pulled_out_cost',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _includeInLayoutMeta = const VerificationMeta(
    'includeInLayout',
  );
  @override
  late final GeneratedColumn<bool> includeInLayout = GeneratedColumn<bool>(
    'include_in_layout',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("include_in_layout" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    clientId,
    invoiceDate,
    totalAmount,
    status,
    createdAt,
    invoiceNumber,
    sequenceNumber,
    invoiceType,
    paymentType,
    partialAmount,
    partialDate,
    checkReference,
    checkAmount,
    checkIssuedDate,
    checkDueDate,
    notes,
    actualAmount,
    swapAmount,
    stockPulledOutAmount,
    stockPulledOutCost,
    includeInLayout,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'invoices';
  @override
  VerificationContext validateIntegrity(
    Insertable<Invoice> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('client_id')) {
      context.handle(
        _clientIdMeta,
        clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_clientIdMeta);
    }
    if (data.containsKey('invoice_date')) {
      context.handle(
        _invoiceDateMeta,
        invoiceDate.isAcceptableOrUnknown(
          data['invoice_date']!,
          _invoiceDateMeta,
        ),
      );
    }
    if (data.containsKey('total_amount')) {
      context.handle(
        _totalAmountMeta,
        totalAmount.isAcceptableOrUnknown(
          data['total_amount']!,
          _totalAmountMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('invoice_number')) {
      context.handle(
        _invoiceNumberMeta,
        invoiceNumber.isAcceptableOrUnknown(
          data['invoice_number']!,
          _invoiceNumberMeta,
        ),
      );
    }
    if (data.containsKey('sequence_number')) {
      context.handle(
        _sequenceNumberMeta,
        sequenceNumber.isAcceptableOrUnknown(
          data['sequence_number']!,
          _sequenceNumberMeta,
        ),
      );
    }
    if (data.containsKey('invoice_type')) {
      context.handle(
        _invoiceTypeMeta,
        invoiceType.isAcceptableOrUnknown(
          data['invoice_type']!,
          _invoiceTypeMeta,
        ),
      );
    }
    if (data.containsKey('payment_type')) {
      context.handle(
        _paymentTypeMeta,
        paymentType.isAcceptableOrUnknown(
          data['payment_type']!,
          _paymentTypeMeta,
        ),
      );
    }
    if (data.containsKey('partial_amount')) {
      context.handle(
        _partialAmountMeta,
        partialAmount.isAcceptableOrUnknown(
          data['partial_amount']!,
          _partialAmountMeta,
        ),
      );
    }
    if (data.containsKey('partial_date')) {
      context.handle(
        _partialDateMeta,
        partialDate.isAcceptableOrUnknown(
          data['partial_date']!,
          _partialDateMeta,
        ),
      );
    }
    if (data.containsKey('check_reference')) {
      context.handle(
        _checkReferenceMeta,
        checkReference.isAcceptableOrUnknown(
          data['check_reference']!,
          _checkReferenceMeta,
        ),
      );
    }
    if (data.containsKey('check_amount')) {
      context.handle(
        _checkAmountMeta,
        checkAmount.isAcceptableOrUnknown(
          data['check_amount']!,
          _checkAmountMeta,
        ),
      );
    }
    if (data.containsKey('check_issued_date')) {
      context.handle(
        _checkIssuedDateMeta,
        checkIssuedDate.isAcceptableOrUnknown(
          data['check_issued_date']!,
          _checkIssuedDateMeta,
        ),
      );
    }
    if (data.containsKey('check_due_date')) {
      context.handle(
        _checkDueDateMeta,
        checkDueDate.isAcceptableOrUnknown(
          data['check_due_date']!,
          _checkDueDateMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('actual_amount')) {
      context.handle(
        _actualAmountMeta,
        actualAmount.isAcceptableOrUnknown(
          data['actual_amount']!,
          _actualAmountMeta,
        ),
      );
    }
    if (data.containsKey('swap_amount')) {
      context.handle(
        _swapAmountMeta,
        swapAmount.isAcceptableOrUnknown(data['swap_amount']!, _swapAmountMeta),
      );
    }
    if (data.containsKey('stock_pulled_out_amount')) {
      context.handle(
        _stockPulledOutAmountMeta,
        stockPulledOutAmount.isAcceptableOrUnknown(
          data['stock_pulled_out_amount']!,
          _stockPulledOutAmountMeta,
        ),
      );
    }
    if (data.containsKey('stock_pulled_out_cost')) {
      context.handle(
        _stockPulledOutCostMeta,
        stockPulledOutCost.isAcceptableOrUnknown(
          data['stock_pulled_out_cost']!,
          _stockPulledOutCostMeta,
        ),
      );
    }
    if (data.containsKey('include_in_layout')) {
      context.handle(
        _includeInLayoutMeta,
        includeInLayout.isAcceptableOrUnknown(
          data['include_in_layout']!,
          _includeInLayoutMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Invoice map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Invoice(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      clientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_id'],
      )!,
      invoiceDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}invoice_date'],
      )!,
      totalAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_amount'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      invoiceNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}invoice_number'],
      ),
      sequenceNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sequence_number'],
      ),
      invoiceType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}invoice_type'],
      )!,
      paymentType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_type'],
      )!,
      partialAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}partial_amount'],
      ),
      partialDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}partial_date'],
      ),
      checkReference: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}check_reference'],
      ),
      checkAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}check_amount'],
      ),
      checkIssuedDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}check_issued_date'],
      ),
      checkDueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}check_due_date'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      actualAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}actual_amount'],
      ),
      swapAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}swap_amount'],
      ),
      stockPulledOutAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}stock_pulled_out_amount'],
      ),
      stockPulledOutCost: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}stock_pulled_out_cost'],
      ),
      includeInLayout: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}include_in_layout'],
      )!,
    );
  }

  @override
  $InvoicesTable createAlias(String alias) {
    return $InvoicesTable(attachedDatabase, alias);
  }
}

class Invoice extends DataClass implements Insertable<Invoice> {
  final String id;
  final String clientId;
  final DateTime invoiceDate;
  final double totalAmount;
  final String status;
  final DateTime createdAt;
  final String? invoiceNumber;
  final int? sequenceNumber;
  final String invoiceType;
  final String paymentType;
  final double? partialAmount;
  final DateTime? partialDate;
  final String? checkReference;
  final double? checkAmount;
  final DateTime? checkIssuedDate;
  final DateTime? checkDueDate;
  final String? notes;
  final double? actualAmount;
  final double? swapAmount;
  final double? stockPulledOutAmount;
  final double? stockPulledOutCost;
  final bool includeInLayout;
  const Invoice({
    required this.id,
    required this.clientId,
    required this.invoiceDate,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    this.invoiceNumber,
    this.sequenceNumber,
    required this.invoiceType,
    required this.paymentType,
    this.partialAmount,
    this.partialDate,
    this.checkReference,
    this.checkAmount,
    this.checkIssuedDate,
    this.checkDueDate,
    this.notes,
    this.actualAmount,
    this.swapAmount,
    this.stockPulledOutAmount,
    this.stockPulledOutCost,
    required this.includeInLayout,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['client_id'] = Variable<String>(clientId);
    map['invoice_date'] = Variable<DateTime>(invoiceDate);
    map['total_amount'] = Variable<double>(totalAmount);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || invoiceNumber != null) {
      map['invoice_number'] = Variable<String>(invoiceNumber);
    }
    if (!nullToAbsent || sequenceNumber != null) {
      map['sequence_number'] = Variable<int>(sequenceNumber);
    }
    map['invoice_type'] = Variable<String>(invoiceType);
    map['payment_type'] = Variable<String>(paymentType);
    if (!nullToAbsent || partialAmount != null) {
      map['partial_amount'] = Variable<double>(partialAmount);
    }
    if (!nullToAbsent || partialDate != null) {
      map['partial_date'] = Variable<DateTime>(partialDate);
    }
    if (!nullToAbsent || checkReference != null) {
      map['check_reference'] = Variable<String>(checkReference);
    }
    if (!nullToAbsent || checkAmount != null) {
      map['check_amount'] = Variable<double>(checkAmount);
    }
    if (!nullToAbsent || checkIssuedDate != null) {
      map['check_issued_date'] = Variable<DateTime>(checkIssuedDate);
    }
    if (!nullToAbsent || checkDueDate != null) {
      map['check_due_date'] = Variable<DateTime>(checkDueDate);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || actualAmount != null) {
      map['actual_amount'] = Variable<double>(actualAmount);
    }
    if (!nullToAbsent || swapAmount != null) {
      map['swap_amount'] = Variable<double>(swapAmount);
    }
    if (!nullToAbsent || stockPulledOutAmount != null) {
      map['stock_pulled_out_amount'] = Variable<double>(stockPulledOutAmount);
    }
    if (!nullToAbsent || stockPulledOutCost != null) {
      map['stock_pulled_out_cost'] = Variable<double>(stockPulledOutCost);
    }
    map['include_in_layout'] = Variable<bool>(includeInLayout);
    return map;
  }

  InvoicesCompanion toCompanion(bool nullToAbsent) {
    return InvoicesCompanion(
      id: Value(id),
      clientId: Value(clientId),
      invoiceDate: Value(invoiceDate),
      totalAmount: Value(totalAmount),
      status: Value(status),
      createdAt: Value(createdAt),
      invoiceNumber: invoiceNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(invoiceNumber),
      sequenceNumber: sequenceNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(sequenceNumber),
      invoiceType: Value(invoiceType),
      paymentType: Value(paymentType),
      partialAmount: partialAmount == null && nullToAbsent
          ? const Value.absent()
          : Value(partialAmount),
      partialDate: partialDate == null && nullToAbsent
          ? const Value.absent()
          : Value(partialDate),
      checkReference: checkReference == null && nullToAbsent
          ? const Value.absent()
          : Value(checkReference),
      checkAmount: checkAmount == null && nullToAbsent
          ? const Value.absent()
          : Value(checkAmount),
      checkIssuedDate: checkIssuedDate == null && nullToAbsent
          ? const Value.absent()
          : Value(checkIssuedDate),
      checkDueDate: checkDueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(checkDueDate),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      actualAmount: actualAmount == null && nullToAbsent
          ? const Value.absent()
          : Value(actualAmount),
      swapAmount: swapAmount == null && nullToAbsent
          ? const Value.absent()
          : Value(swapAmount),
      stockPulledOutAmount: stockPulledOutAmount == null && nullToAbsent
          ? const Value.absent()
          : Value(stockPulledOutAmount),
      stockPulledOutCost: stockPulledOutCost == null && nullToAbsent
          ? const Value.absent()
          : Value(stockPulledOutCost),
      includeInLayout: Value(includeInLayout),
    );
  }

  factory Invoice.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Invoice(
      id: serializer.fromJson<String>(json['id']),
      clientId: serializer.fromJson<String>(json['clientId']),
      invoiceDate: serializer.fromJson<DateTime>(json['invoiceDate']),
      totalAmount: serializer.fromJson<double>(json['totalAmount']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      invoiceNumber: serializer.fromJson<String?>(json['invoiceNumber']),
      sequenceNumber: serializer.fromJson<int?>(json['sequenceNumber']),
      invoiceType: serializer.fromJson<String>(json['invoiceType']),
      paymentType: serializer.fromJson<String>(json['paymentType']),
      partialAmount: serializer.fromJson<double?>(json['partialAmount']),
      partialDate: serializer.fromJson<DateTime?>(json['partialDate']),
      checkReference: serializer.fromJson<String?>(json['checkReference']),
      checkAmount: serializer.fromJson<double?>(json['checkAmount']),
      checkIssuedDate: serializer.fromJson<DateTime?>(json['checkIssuedDate']),
      checkDueDate: serializer.fromJson<DateTime?>(json['checkDueDate']),
      notes: serializer.fromJson<String?>(json['notes']),
      actualAmount: serializer.fromJson<double?>(json['actualAmount']),
      swapAmount: serializer.fromJson<double?>(json['swapAmount']),
      stockPulledOutAmount: serializer.fromJson<double?>(
        json['stockPulledOutAmount'],
      ),
      stockPulledOutCost: serializer.fromJson<double?>(
        json['stockPulledOutCost'],
      ),
      includeInLayout: serializer.fromJson<bool>(json['includeInLayout']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'clientId': serializer.toJson<String>(clientId),
      'invoiceDate': serializer.toJson<DateTime>(invoiceDate),
      'totalAmount': serializer.toJson<double>(totalAmount),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'invoiceNumber': serializer.toJson<String?>(invoiceNumber),
      'sequenceNumber': serializer.toJson<int?>(sequenceNumber),
      'invoiceType': serializer.toJson<String>(invoiceType),
      'paymentType': serializer.toJson<String>(paymentType),
      'partialAmount': serializer.toJson<double?>(partialAmount),
      'partialDate': serializer.toJson<DateTime?>(partialDate),
      'checkReference': serializer.toJson<String?>(checkReference),
      'checkAmount': serializer.toJson<double?>(checkAmount),
      'checkIssuedDate': serializer.toJson<DateTime?>(checkIssuedDate),
      'checkDueDate': serializer.toJson<DateTime?>(checkDueDate),
      'notes': serializer.toJson<String?>(notes),
      'actualAmount': serializer.toJson<double?>(actualAmount),
      'swapAmount': serializer.toJson<double?>(swapAmount),
      'stockPulledOutAmount': serializer.toJson<double?>(stockPulledOutAmount),
      'stockPulledOutCost': serializer.toJson<double?>(stockPulledOutCost),
      'includeInLayout': serializer.toJson<bool>(includeInLayout),
    };
  }

  Invoice copyWith({
    String? id,
    String? clientId,
    DateTime? invoiceDate,
    double? totalAmount,
    String? status,
    DateTime? createdAt,
    Value<String?> invoiceNumber = const Value.absent(),
    Value<int?> sequenceNumber = const Value.absent(),
    String? invoiceType,
    String? paymentType,
    Value<double?> partialAmount = const Value.absent(),
    Value<DateTime?> partialDate = const Value.absent(),
    Value<String?> checkReference = const Value.absent(),
    Value<double?> checkAmount = const Value.absent(),
    Value<DateTime?> checkIssuedDate = const Value.absent(),
    Value<DateTime?> checkDueDate = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    Value<double?> actualAmount = const Value.absent(),
    Value<double?> swapAmount = const Value.absent(),
    Value<double?> stockPulledOutAmount = const Value.absent(),
    Value<double?> stockPulledOutCost = const Value.absent(),
    bool? includeInLayout,
  }) => Invoice(
    id: id ?? this.id,
    clientId: clientId ?? this.clientId,
    invoiceDate: invoiceDate ?? this.invoiceDate,
    totalAmount: totalAmount ?? this.totalAmount,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    invoiceNumber: invoiceNumber.present
        ? invoiceNumber.value
        : this.invoiceNumber,
    sequenceNumber: sequenceNumber.present
        ? sequenceNumber.value
        : this.sequenceNumber,
    invoiceType: invoiceType ?? this.invoiceType,
    paymentType: paymentType ?? this.paymentType,
    partialAmount: partialAmount.present
        ? partialAmount.value
        : this.partialAmount,
    partialDate: partialDate.present ? partialDate.value : this.partialDate,
    checkReference: checkReference.present
        ? checkReference.value
        : this.checkReference,
    checkAmount: checkAmount.present ? checkAmount.value : this.checkAmount,
    checkIssuedDate: checkIssuedDate.present
        ? checkIssuedDate.value
        : this.checkIssuedDate,
    checkDueDate: checkDueDate.present ? checkDueDate.value : this.checkDueDate,
    notes: notes.present ? notes.value : this.notes,
    actualAmount: actualAmount.present ? actualAmount.value : this.actualAmount,
    swapAmount: swapAmount.present ? swapAmount.value : this.swapAmount,
    stockPulledOutAmount: stockPulledOutAmount.present
        ? stockPulledOutAmount.value
        : this.stockPulledOutAmount,
    stockPulledOutCost: stockPulledOutCost.present
        ? stockPulledOutCost.value
        : this.stockPulledOutCost,
    includeInLayout: includeInLayout ?? this.includeInLayout,
  );
  Invoice copyWithCompanion(InvoicesCompanion data) {
    return Invoice(
      id: data.id.present ? data.id.value : this.id,
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      invoiceDate: data.invoiceDate.present
          ? data.invoiceDate.value
          : this.invoiceDate,
      totalAmount: data.totalAmount.present
          ? data.totalAmount.value
          : this.totalAmount,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      invoiceNumber: data.invoiceNumber.present
          ? data.invoiceNumber.value
          : this.invoiceNumber,
      sequenceNumber: data.sequenceNumber.present
          ? data.sequenceNumber.value
          : this.sequenceNumber,
      invoiceType: data.invoiceType.present
          ? data.invoiceType.value
          : this.invoiceType,
      paymentType: data.paymentType.present
          ? data.paymentType.value
          : this.paymentType,
      partialAmount: data.partialAmount.present
          ? data.partialAmount.value
          : this.partialAmount,
      partialDate: data.partialDate.present
          ? data.partialDate.value
          : this.partialDate,
      checkReference: data.checkReference.present
          ? data.checkReference.value
          : this.checkReference,
      checkAmount: data.checkAmount.present
          ? data.checkAmount.value
          : this.checkAmount,
      checkIssuedDate: data.checkIssuedDate.present
          ? data.checkIssuedDate.value
          : this.checkIssuedDate,
      checkDueDate: data.checkDueDate.present
          ? data.checkDueDate.value
          : this.checkDueDate,
      notes: data.notes.present ? data.notes.value : this.notes,
      actualAmount: data.actualAmount.present
          ? data.actualAmount.value
          : this.actualAmount,
      swapAmount: data.swapAmount.present
          ? data.swapAmount.value
          : this.swapAmount,
      stockPulledOutAmount: data.stockPulledOutAmount.present
          ? data.stockPulledOutAmount.value
          : this.stockPulledOutAmount,
      stockPulledOutCost: data.stockPulledOutCost.present
          ? data.stockPulledOutCost.value
          : this.stockPulledOutCost,
      includeInLayout: data.includeInLayout.present
          ? data.includeInLayout.value
          : this.includeInLayout,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Invoice(')
          ..write('id: $id, ')
          ..write('clientId: $clientId, ')
          ..write('invoiceDate: $invoiceDate, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('invoiceNumber: $invoiceNumber, ')
          ..write('sequenceNumber: $sequenceNumber, ')
          ..write('invoiceType: $invoiceType, ')
          ..write('paymentType: $paymentType, ')
          ..write('partialAmount: $partialAmount, ')
          ..write('partialDate: $partialDate, ')
          ..write('checkReference: $checkReference, ')
          ..write('checkAmount: $checkAmount, ')
          ..write('checkIssuedDate: $checkIssuedDate, ')
          ..write('checkDueDate: $checkDueDate, ')
          ..write('notes: $notes, ')
          ..write('actualAmount: $actualAmount, ')
          ..write('swapAmount: $swapAmount, ')
          ..write('stockPulledOutAmount: $stockPulledOutAmount, ')
          ..write('stockPulledOutCost: $stockPulledOutCost, ')
          ..write('includeInLayout: $includeInLayout')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    clientId,
    invoiceDate,
    totalAmount,
    status,
    createdAt,
    invoiceNumber,
    sequenceNumber,
    invoiceType,
    paymentType,
    partialAmount,
    partialDate,
    checkReference,
    checkAmount,
    checkIssuedDate,
    checkDueDate,
    notes,
    actualAmount,
    swapAmount,
    stockPulledOutAmount,
    stockPulledOutCost,
    includeInLayout,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Invoice &&
          other.id == this.id &&
          other.clientId == this.clientId &&
          other.invoiceDate == this.invoiceDate &&
          other.totalAmount == this.totalAmount &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.invoiceNumber == this.invoiceNumber &&
          other.sequenceNumber == this.sequenceNumber &&
          other.invoiceType == this.invoiceType &&
          other.paymentType == this.paymentType &&
          other.partialAmount == this.partialAmount &&
          other.partialDate == this.partialDate &&
          other.checkReference == this.checkReference &&
          other.checkAmount == this.checkAmount &&
          other.checkIssuedDate == this.checkIssuedDate &&
          other.checkDueDate == this.checkDueDate &&
          other.notes == this.notes &&
          other.actualAmount == this.actualAmount &&
          other.swapAmount == this.swapAmount &&
          other.stockPulledOutAmount == this.stockPulledOutAmount &&
          other.stockPulledOutCost == this.stockPulledOutCost &&
          other.includeInLayout == this.includeInLayout);
}

class InvoicesCompanion extends UpdateCompanion<Invoice> {
  final Value<String> id;
  final Value<String> clientId;
  final Value<DateTime> invoiceDate;
  final Value<double> totalAmount;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<String?> invoiceNumber;
  final Value<int?> sequenceNumber;
  final Value<String> invoiceType;
  final Value<String> paymentType;
  final Value<double?> partialAmount;
  final Value<DateTime?> partialDate;
  final Value<String?> checkReference;
  final Value<double?> checkAmount;
  final Value<DateTime?> checkIssuedDate;
  final Value<DateTime?> checkDueDate;
  final Value<String?> notes;
  final Value<double?> actualAmount;
  final Value<double?> swapAmount;
  final Value<double?> stockPulledOutAmount;
  final Value<double?> stockPulledOutCost;
  final Value<bool> includeInLayout;
  final Value<int> rowid;
  const InvoicesCompanion({
    this.id = const Value.absent(),
    this.clientId = const Value.absent(),
    this.invoiceDate = const Value.absent(),
    this.totalAmount = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.invoiceNumber = const Value.absent(),
    this.sequenceNumber = const Value.absent(),
    this.invoiceType = const Value.absent(),
    this.paymentType = const Value.absent(),
    this.partialAmount = const Value.absent(),
    this.partialDate = const Value.absent(),
    this.checkReference = const Value.absent(),
    this.checkAmount = const Value.absent(),
    this.checkIssuedDate = const Value.absent(),
    this.checkDueDate = const Value.absent(),
    this.notes = const Value.absent(),
    this.actualAmount = const Value.absent(),
    this.swapAmount = const Value.absent(),
    this.stockPulledOutAmount = const Value.absent(),
    this.stockPulledOutCost = const Value.absent(),
    this.includeInLayout = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InvoicesCompanion.insert({
    required String id,
    required String clientId,
    this.invoiceDate = const Value.absent(),
    this.totalAmount = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.invoiceNumber = const Value.absent(),
    this.sequenceNumber = const Value.absent(),
    this.invoiceType = const Value.absent(),
    this.paymentType = const Value.absent(),
    this.partialAmount = const Value.absent(),
    this.partialDate = const Value.absent(),
    this.checkReference = const Value.absent(),
    this.checkAmount = const Value.absent(),
    this.checkIssuedDate = const Value.absent(),
    this.checkDueDate = const Value.absent(),
    this.notes = const Value.absent(),
    this.actualAmount = const Value.absent(),
    this.swapAmount = const Value.absent(),
    this.stockPulledOutAmount = const Value.absent(),
    this.stockPulledOutCost = const Value.absent(),
    this.includeInLayout = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       clientId = Value(clientId);
  static Insertable<Invoice> custom({
    Expression<String>? id,
    Expression<String>? clientId,
    Expression<DateTime>? invoiceDate,
    Expression<double>? totalAmount,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<String>? invoiceNumber,
    Expression<int>? sequenceNumber,
    Expression<String>? invoiceType,
    Expression<String>? paymentType,
    Expression<double>? partialAmount,
    Expression<DateTime>? partialDate,
    Expression<String>? checkReference,
    Expression<double>? checkAmount,
    Expression<DateTime>? checkIssuedDate,
    Expression<DateTime>? checkDueDate,
    Expression<String>? notes,
    Expression<double>? actualAmount,
    Expression<double>? swapAmount,
    Expression<double>? stockPulledOutAmount,
    Expression<double>? stockPulledOutCost,
    Expression<bool>? includeInLayout,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (clientId != null) 'client_id': clientId,
      if (invoiceDate != null) 'invoice_date': invoiceDate,
      if (totalAmount != null) 'total_amount': totalAmount,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (invoiceNumber != null) 'invoice_number': invoiceNumber,
      if (sequenceNumber != null) 'sequence_number': sequenceNumber,
      if (invoiceType != null) 'invoice_type': invoiceType,
      if (paymentType != null) 'payment_type': paymentType,
      if (partialAmount != null) 'partial_amount': partialAmount,
      if (partialDate != null) 'partial_date': partialDate,
      if (checkReference != null) 'check_reference': checkReference,
      if (checkAmount != null) 'check_amount': checkAmount,
      if (checkIssuedDate != null) 'check_issued_date': checkIssuedDate,
      if (checkDueDate != null) 'check_due_date': checkDueDate,
      if (notes != null) 'notes': notes,
      if (actualAmount != null) 'actual_amount': actualAmount,
      if (swapAmount != null) 'swap_amount': swapAmount,
      if (stockPulledOutAmount != null)
        'stock_pulled_out_amount': stockPulledOutAmount,
      if (stockPulledOutCost != null)
        'stock_pulled_out_cost': stockPulledOutCost,
      if (includeInLayout != null) 'include_in_layout': includeInLayout,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InvoicesCompanion copyWith({
    Value<String>? id,
    Value<String>? clientId,
    Value<DateTime>? invoiceDate,
    Value<double>? totalAmount,
    Value<String>? status,
    Value<DateTime>? createdAt,
    Value<String?>? invoiceNumber,
    Value<int?>? sequenceNumber,
    Value<String>? invoiceType,
    Value<String>? paymentType,
    Value<double?>? partialAmount,
    Value<DateTime?>? partialDate,
    Value<String?>? checkReference,
    Value<double?>? checkAmount,
    Value<DateTime?>? checkIssuedDate,
    Value<DateTime?>? checkDueDate,
    Value<String?>? notes,
    Value<double?>? actualAmount,
    Value<double?>? swapAmount,
    Value<double?>? stockPulledOutAmount,
    Value<double?>? stockPulledOutCost,
    Value<bool>? includeInLayout,
    Value<int>? rowid,
  }) {
    return InvoicesCompanion(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      sequenceNumber: sequenceNumber ?? this.sequenceNumber,
      invoiceType: invoiceType ?? this.invoiceType,
      paymentType: paymentType ?? this.paymentType,
      partialAmount: partialAmount ?? this.partialAmount,
      partialDate: partialDate ?? this.partialDate,
      checkReference: checkReference ?? this.checkReference,
      checkAmount: checkAmount ?? this.checkAmount,
      checkIssuedDate: checkIssuedDate ?? this.checkIssuedDate,
      checkDueDate: checkDueDate ?? this.checkDueDate,
      notes: notes ?? this.notes,
      actualAmount: actualAmount ?? this.actualAmount,
      swapAmount: swapAmount ?? this.swapAmount,
      stockPulledOutAmount: stockPulledOutAmount ?? this.stockPulledOutAmount,
      stockPulledOutCost: stockPulledOutCost ?? this.stockPulledOutCost,
      includeInLayout: includeInLayout ?? this.includeInLayout,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (invoiceDate.present) {
      map['invoice_date'] = Variable<DateTime>(invoiceDate.value);
    }
    if (totalAmount.present) {
      map['total_amount'] = Variable<double>(totalAmount.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (invoiceNumber.present) {
      map['invoice_number'] = Variable<String>(invoiceNumber.value);
    }
    if (sequenceNumber.present) {
      map['sequence_number'] = Variable<int>(sequenceNumber.value);
    }
    if (invoiceType.present) {
      map['invoice_type'] = Variable<String>(invoiceType.value);
    }
    if (paymentType.present) {
      map['payment_type'] = Variable<String>(paymentType.value);
    }
    if (partialAmount.present) {
      map['partial_amount'] = Variable<double>(partialAmount.value);
    }
    if (partialDate.present) {
      map['partial_date'] = Variable<DateTime>(partialDate.value);
    }
    if (checkReference.present) {
      map['check_reference'] = Variable<String>(checkReference.value);
    }
    if (checkAmount.present) {
      map['check_amount'] = Variable<double>(checkAmount.value);
    }
    if (checkIssuedDate.present) {
      map['check_issued_date'] = Variable<DateTime>(checkIssuedDate.value);
    }
    if (checkDueDate.present) {
      map['check_due_date'] = Variable<DateTime>(checkDueDate.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (actualAmount.present) {
      map['actual_amount'] = Variable<double>(actualAmount.value);
    }
    if (swapAmount.present) {
      map['swap_amount'] = Variable<double>(swapAmount.value);
    }
    if (stockPulledOutAmount.present) {
      map['stock_pulled_out_amount'] = Variable<double>(
        stockPulledOutAmount.value,
      );
    }
    if (stockPulledOutCost.present) {
      map['stock_pulled_out_cost'] = Variable<double>(stockPulledOutCost.value);
    }
    if (includeInLayout.present) {
      map['include_in_layout'] = Variable<bool>(includeInLayout.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InvoicesCompanion(')
          ..write('id: $id, ')
          ..write('clientId: $clientId, ')
          ..write('invoiceDate: $invoiceDate, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('invoiceNumber: $invoiceNumber, ')
          ..write('sequenceNumber: $sequenceNumber, ')
          ..write('invoiceType: $invoiceType, ')
          ..write('paymentType: $paymentType, ')
          ..write('partialAmount: $partialAmount, ')
          ..write('partialDate: $partialDate, ')
          ..write('checkReference: $checkReference, ')
          ..write('checkAmount: $checkAmount, ')
          ..write('checkIssuedDate: $checkIssuedDate, ')
          ..write('checkDueDate: $checkDueDate, ')
          ..write('notes: $notes, ')
          ..write('actualAmount: $actualAmount, ')
          ..write('swapAmount: $swapAmount, ')
          ..write('stockPulledOutAmount: $stockPulledOutAmount, ')
          ..write('stockPulledOutCost: $stockPulledOutCost, ')
          ..write('includeInLayout: $includeInLayout, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InvoiceItemsTable extends InvoiceItems
    with TableInfo<$InvoiceItemsTable, InvoiceItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InvoiceItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _invoiceIdMeta = const VerificationMeta(
    'invoiceId',
  );
  @override
  late final GeneratedColumn<String> invoiceId = GeneratedColumn<String>(
    'invoice_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES invoices (id)',
    ),
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES products (id)',
    ),
  );
  static const VerificationMeta _unitTypeMeta = const VerificationMeta(
    'unitType',
  );
  @override
  late final GeneratedColumn<String> unitType = GeneratedColumn<String>(
    'unit_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pricePerPieceMeta = const VerificationMeta(
    'pricePerPiece',
  );
  @override
  late final GeneratedColumn<double> pricePerPiece = GeneratedColumn<double>(
    'price_per_piece',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subtotalMeta = const VerificationMeta(
    'subtotal',
  );
  @override
  late final GeneratedColumn<double> subtotal = GeneratedColumn<double>(
    'subtotal',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isFreeMeta = const VerificationMeta('isFree');
  @override
  late final GeneratedColumn<bool> isFree = GeneratedColumn<bool>(
    'is_free',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_free" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _discountPercentMeta = const VerificationMeta(
    'discountPercent',
  );
  @override
  late final GeneratedColumn<double> discountPercent = GeneratedColumn<double>(
    'discount_percent',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    invoiceId,
    productId,
    unitType,
    quantity,
    pricePerPiece,
    subtotal,
    isFree,
    discountPercent,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'invoice_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<InvoiceItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('invoice_id')) {
      context.handle(
        _invoiceIdMeta,
        invoiceId.isAcceptableOrUnknown(data['invoice_id']!, _invoiceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_invoiceIdMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('unit_type')) {
      context.handle(
        _unitTypeMeta,
        unitType.isAcceptableOrUnknown(data['unit_type']!, _unitTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_unitTypeMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('price_per_piece')) {
      context.handle(
        _pricePerPieceMeta,
        pricePerPiece.isAcceptableOrUnknown(
          data['price_per_piece']!,
          _pricePerPieceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_pricePerPieceMeta);
    }
    if (data.containsKey('subtotal')) {
      context.handle(
        _subtotalMeta,
        subtotal.isAcceptableOrUnknown(data['subtotal']!, _subtotalMeta),
      );
    } else if (isInserting) {
      context.missing(_subtotalMeta);
    }
    if (data.containsKey('is_free')) {
      context.handle(
        _isFreeMeta,
        isFree.isAcceptableOrUnknown(data['is_free']!, _isFreeMeta),
      );
    }
    if (data.containsKey('discount_percent')) {
      context.handle(
        _discountPercentMeta,
        discountPercent.isAcceptableOrUnknown(
          data['discount_percent']!,
          _discountPercentMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InvoiceItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InvoiceItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      invoiceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}invoice_id'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      )!,
      unitType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit_type'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      )!,
      pricePerPiece: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}price_per_piece'],
      )!,
      subtotal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}subtotal'],
      )!,
      isFree: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_free'],
      )!,
      discountPercent: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}discount_percent'],
      )!,
    );
  }

  @override
  $InvoiceItemsTable createAlias(String alias) {
    return $InvoiceItemsTable(attachedDatabase, alias);
  }
}

class InvoiceItem extends DataClass implements Insertable<InvoiceItem> {
  final String id;
  final String invoiceId;
  final String productId;
  final String unitType;
  final int quantity;
  final double pricePerPiece;
  final double subtotal;
  final bool isFree;
  final double discountPercent;
  const InvoiceItem({
    required this.id,
    required this.invoiceId,
    required this.productId,
    required this.unitType,
    required this.quantity,
    required this.pricePerPiece,
    required this.subtotal,
    required this.isFree,
    required this.discountPercent,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['invoice_id'] = Variable<String>(invoiceId);
    map['product_id'] = Variable<String>(productId);
    map['unit_type'] = Variable<String>(unitType);
    map['quantity'] = Variable<int>(quantity);
    map['price_per_piece'] = Variable<double>(pricePerPiece);
    map['subtotal'] = Variable<double>(subtotal);
    map['is_free'] = Variable<bool>(isFree);
    map['discount_percent'] = Variable<double>(discountPercent);
    return map;
  }

  InvoiceItemsCompanion toCompanion(bool nullToAbsent) {
    return InvoiceItemsCompanion(
      id: Value(id),
      invoiceId: Value(invoiceId),
      productId: Value(productId),
      unitType: Value(unitType),
      quantity: Value(quantity),
      pricePerPiece: Value(pricePerPiece),
      subtotal: Value(subtotal),
      isFree: Value(isFree),
      discountPercent: Value(discountPercent),
    );
  }

  factory InvoiceItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InvoiceItem(
      id: serializer.fromJson<String>(json['id']),
      invoiceId: serializer.fromJson<String>(json['invoiceId']),
      productId: serializer.fromJson<String>(json['productId']),
      unitType: serializer.fromJson<String>(json['unitType']),
      quantity: serializer.fromJson<int>(json['quantity']),
      pricePerPiece: serializer.fromJson<double>(json['pricePerPiece']),
      subtotal: serializer.fromJson<double>(json['subtotal']),
      isFree: serializer.fromJson<bool>(json['isFree']),
      discountPercent: serializer.fromJson<double>(json['discountPercent']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'invoiceId': serializer.toJson<String>(invoiceId),
      'productId': serializer.toJson<String>(productId),
      'unitType': serializer.toJson<String>(unitType),
      'quantity': serializer.toJson<int>(quantity),
      'pricePerPiece': serializer.toJson<double>(pricePerPiece),
      'subtotal': serializer.toJson<double>(subtotal),
      'isFree': serializer.toJson<bool>(isFree),
      'discountPercent': serializer.toJson<double>(discountPercent),
    };
  }

  InvoiceItem copyWith({
    String? id,
    String? invoiceId,
    String? productId,
    String? unitType,
    int? quantity,
    double? pricePerPiece,
    double? subtotal,
    bool? isFree,
    double? discountPercent,
  }) => InvoiceItem(
    id: id ?? this.id,
    invoiceId: invoiceId ?? this.invoiceId,
    productId: productId ?? this.productId,
    unitType: unitType ?? this.unitType,
    quantity: quantity ?? this.quantity,
    pricePerPiece: pricePerPiece ?? this.pricePerPiece,
    subtotal: subtotal ?? this.subtotal,
    isFree: isFree ?? this.isFree,
    discountPercent: discountPercent ?? this.discountPercent,
  );
  InvoiceItem copyWithCompanion(InvoiceItemsCompanion data) {
    return InvoiceItem(
      id: data.id.present ? data.id.value : this.id,
      invoiceId: data.invoiceId.present ? data.invoiceId.value : this.invoiceId,
      productId: data.productId.present ? data.productId.value : this.productId,
      unitType: data.unitType.present ? data.unitType.value : this.unitType,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      pricePerPiece: data.pricePerPiece.present
          ? data.pricePerPiece.value
          : this.pricePerPiece,
      subtotal: data.subtotal.present ? data.subtotal.value : this.subtotal,
      isFree: data.isFree.present ? data.isFree.value : this.isFree,
      discountPercent: data.discountPercent.present
          ? data.discountPercent.value
          : this.discountPercent,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InvoiceItem(')
          ..write('id: $id, ')
          ..write('invoiceId: $invoiceId, ')
          ..write('productId: $productId, ')
          ..write('unitType: $unitType, ')
          ..write('quantity: $quantity, ')
          ..write('pricePerPiece: $pricePerPiece, ')
          ..write('subtotal: $subtotal, ')
          ..write('isFree: $isFree, ')
          ..write('discountPercent: $discountPercent')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    invoiceId,
    productId,
    unitType,
    quantity,
    pricePerPiece,
    subtotal,
    isFree,
    discountPercent,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InvoiceItem &&
          other.id == this.id &&
          other.invoiceId == this.invoiceId &&
          other.productId == this.productId &&
          other.unitType == this.unitType &&
          other.quantity == this.quantity &&
          other.pricePerPiece == this.pricePerPiece &&
          other.subtotal == this.subtotal &&
          other.isFree == this.isFree &&
          other.discountPercent == this.discountPercent);
}

class InvoiceItemsCompanion extends UpdateCompanion<InvoiceItem> {
  final Value<String> id;
  final Value<String> invoiceId;
  final Value<String> productId;
  final Value<String> unitType;
  final Value<int> quantity;
  final Value<double> pricePerPiece;
  final Value<double> subtotal;
  final Value<bool> isFree;
  final Value<double> discountPercent;
  final Value<int> rowid;
  const InvoiceItemsCompanion({
    this.id = const Value.absent(),
    this.invoiceId = const Value.absent(),
    this.productId = const Value.absent(),
    this.unitType = const Value.absent(),
    this.quantity = const Value.absent(),
    this.pricePerPiece = const Value.absent(),
    this.subtotal = const Value.absent(),
    this.isFree = const Value.absent(),
    this.discountPercent = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InvoiceItemsCompanion.insert({
    required String id,
    required String invoiceId,
    required String productId,
    required String unitType,
    required int quantity,
    required double pricePerPiece,
    required double subtotal,
    this.isFree = const Value.absent(),
    this.discountPercent = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       invoiceId = Value(invoiceId),
       productId = Value(productId),
       unitType = Value(unitType),
       quantity = Value(quantity),
       pricePerPiece = Value(pricePerPiece),
       subtotal = Value(subtotal);
  static Insertable<InvoiceItem> custom({
    Expression<String>? id,
    Expression<String>? invoiceId,
    Expression<String>? productId,
    Expression<String>? unitType,
    Expression<int>? quantity,
    Expression<double>? pricePerPiece,
    Expression<double>? subtotal,
    Expression<bool>? isFree,
    Expression<double>? discountPercent,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (invoiceId != null) 'invoice_id': invoiceId,
      if (productId != null) 'product_id': productId,
      if (unitType != null) 'unit_type': unitType,
      if (quantity != null) 'quantity': quantity,
      if (pricePerPiece != null) 'price_per_piece': pricePerPiece,
      if (subtotal != null) 'subtotal': subtotal,
      if (isFree != null) 'is_free': isFree,
      if (discountPercent != null) 'discount_percent': discountPercent,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InvoiceItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? invoiceId,
    Value<String>? productId,
    Value<String>? unitType,
    Value<int>? quantity,
    Value<double>? pricePerPiece,
    Value<double>? subtotal,
    Value<bool>? isFree,
    Value<double>? discountPercent,
    Value<int>? rowid,
  }) {
    return InvoiceItemsCompanion(
      id: id ?? this.id,
      invoiceId: invoiceId ?? this.invoiceId,
      productId: productId ?? this.productId,
      unitType: unitType ?? this.unitType,
      quantity: quantity ?? this.quantity,
      pricePerPiece: pricePerPiece ?? this.pricePerPiece,
      subtotal: subtotal ?? this.subtotal,
      isFree: isFree ?? this.isFree,
      discountPercent: discountPercent ?? this.discountPercent,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (invoiceId.present) {
      map['invoice_id'] = Variable<String>(invoiceId.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (unitType.present) {
      map['unit_type'] = Variable<String>(unitType.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (pricePerPiece.present) {
      map['price_per_piece'] = Variable<double>(pricePerPiece.value);
    }
    if (subtotal.present) {
      map['subtotal'] = Variable<double>(subtotal.value);
    }
    if (isFree.present) {
      map['is_free'] = Variable<bool>(isFree.value);
    }
    if (discountPercent.present) {
      map['discount_percent'] = Variable<double>(discountPercent.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InvoiceItemsCompanion(')
          ..write('id: $id, ')
          ..write('invoiceId: $invoiceId, ')
          ..write('productId: $productId, ')
          ..write('unitType: $unitType, ')
          ..write('quantity: $quantity, ')
          ..write('pricePerPiece: $pricePerPiece, ')
          ..write('subtotal: $subtotal, ')
          ..write('isFree: $isFree, ')
          ..write('discountPercent: $discountPercent, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DeletedInvoiceItemsTable extends DeletedInvoiceItems
    with TableInfo<$DeletedInvoiceItemsTable, DeletedInvoiceItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DeletedInvoiceItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _invoiceIdMeta = const VerificationMeta(
    'invoiceId',
  );
  @override
  late final GeneratedColumn<String> invoiceId = GeneratedColumn<String>(
    'invoice_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES invoices (id)',
    ),
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES products (id)',
    ),
  );
  static const VerificationMeta _unitTypeMeta = const VerificationMeta(
    'unitType',
  );
  @override
  late final GeneratedColumn<String> unitType = GeneratedColumn<String>(
    'unit_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pricePerPieceMeta = const VerificationMeta(
    'pricePerPiece',
  );
  @override
  late final GeneratedColumn<double> pricePerPiece = GeneratedColumn<double>(
    'price_per_piece',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subtotalMeta = const VerificationMeta(
    'subtotal',
  );
  @override
  late final GeneratedColumn<double> subtotal = GeneratedColumn<double>(
    'subtotal',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isFreeMeta = const VerificationMeta('isFree');
  @override
  late final GeneratedColumn<bool> isFree = GeneratedColumn<bool>(
    'is_free',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_free" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    invoiceId,
    productId,
    unitType,
    quantity,
    pricePerPiece,
    subtotal,
    isFree,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'deleted_invoice_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<DeletedInvoiceItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('invoice_id')) {
      context.handle(
        _invoiceIdMeta,
        invoiceId.isAcceptableOrUnknown(data['invoice_id']!, _invoiceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_invoiceIdMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('unit_type')) {
      context.handle(
        _unitTypeMeta,
        unitType.isAcceptableOrUnknown(data['unit_type']!, _unitTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_unitTypeMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('price_per_piece')) {
      context.handle(
        _pricePerPieceMeta,
        pricePerPiece.isAcceptableOrUnknown(
          data['price_per_piece']!,
          _pricePerPieceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_pricePerPieceMeta);
    }
    if (data.containsKey('subtotal')) {
      context.handle(
        _subtotalMeta,
        subtotal.isAcceptableOrUnknown(data['subtotal']!, _subtotalMeta),
      );
    } else if (isInserting) {
      context.missing(_subtotalMeta);
    }
    if (data.containsKey('is_free')) {
      context.handle(
        _isFreeMeta,
        isFree.isAcceptableOrUnknown(data['is_free']!, _isFreeMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DeletedInvoiceItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DeletedInvoiceItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      invoiceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}invoice_id'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      )!,
      unitType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit_type'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      )!,
      pricePerPiece: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}price_per_piece'],
      )!,
      subtotal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}subtotal'],
      )!,
      isFree: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_free'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      )!,
    );
  }

  @override
  $DeletedInvoiceItemsTable createAlias(String alias) {
    return $DeletedInvoiceItemsTable(attachedDatabase, alias);
  }
}

class DeletedInvoiceItem extends DataClass
    implements Insertable<DeletedInvoiceItem> {
  final String id;
  final String invoiceId;
  final String productId;
  final String unitType;
  final int quantity;
  final double pricePerPiece;
  final double subtotal;
  final bool isFree;
  final DateTime deletedAt;
  const DeletedInvoiceItem({
    required this.id,
    required this.invoiceId,
    required this.productId,
    required this.unitType,
    required this.quantity,
    required this.pricePerPiece,
    required this.subtotal,
    required this.isFree,
    required this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['invoice_id'] = Variable<String>(invoiceId);
    map['product_id'] = Variable<String>(productId);
    map['unit_type'] = Variable<String>(unitType);
    map['quantity'] = Variable<int>(quantity);
    map['price_per_piece'] = Variable<double>(pricePerPiece);
    map['subtotal'] = Variable<double>(subtotal);
    map['is_free'] = Variable<bool>(isFree);
    map['deleted_at'] = Variable<DateTime>(deletedAt);
    return map;
  }

  DeletedInvoiceItemsCompanion toCompanion(bool nullToAbsent) {
    return DeletedInvoiceItemsCompanion(
      id: Value(id),
      invoiceId: Value(invoiceId),
      productId: Value(productId),
      unitType: Value(unitType),
      quantity: Value(quantity),
      pricePerPiece: Value(pricePerPiece),
      subtotal: Value(subtotal),
      isFree: Value(isFree),
      deletedAt: Value(deletedAt),
    );
  }

  factory DeletedInvoiceItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DeletedInvoiceItem(
      id: serializer.fromJson<String>(json['id']),
      invoiceId: serializer.fromJson<String>(json['invoiceId']),
      productId: serializer.fromJson<String>(json['productId']),
      unitType: serializer.fromJson<String>(json['unitType']),
      quantity: serializer.fromJson<int>(json['quantity']),
      pricePerPiece: serializer.fromJson<double>(json['pricePerPiece']),
      subtotal: serializer.fromJson<double>(json['subtotal']),
      isFree: serializer.fromJson<bool>(json['isFree']),
      deletedAt: serializer.fromJson<DateTime>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'invoiceId': serializer.toJson<String>(invoiceId),
      'productId': serializer.toJson<String>(productId),
      'unitType': serializer.toJson<String>(unitType),
      'quantity': serializer.toJson<int>(quantity),
      'pricePerPiece': serializer.toJson<double>(pricePerPiece),
      'subtotal': serializer.toJson<double>(subtotal),
      'isFree': serializer.toJson<bool>(isFree),
      'deletedAt': serializer.toJson<DateTime>(deletedAt),
    };
  }

  DeletedInvoiceItem copyWith({
    String? id,
    String? invoiceId,
    String? productId,
    String? unitType,
    int? quantity,
    double? pricePerPiece,
    double? subtotal,
    bool? isFree,
    DateTime? deletedAt,
  }) => DeletedInvoiceItem(
    id: id ?? this.id,
    invoiceId: invoiceId ?? this.invoiceId,
    productId: productId ?? this.productId,
    unitType: unitType ?? this.unitType,
    quantity: quantity ?? this.quantity,
    pricePerPiece: pricePerPiece ?? this.pricePerPiece,
    subtotal: subtotal ?? this.subtotal,
    isFree: isFree ?? this.isFree,
    deletedAt: deletedAt ?? this.deletedAt,
  );
  DeletedInvoiceItem copyWithCompanion(DeletedInvoiceItemsCompanion data) {
    return DeletedInvoiceItem(
      id: data.id.present ? data.id.value : this.id,
      invoiceId: data.invoiceId.present ? data.invoiceId.value : this.invoiceId,
      productId: data.productId.present ? data.productId.value : this.productId,
      unitType: data.unitType.present ? data.unitType.value : this.unitType,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      pricePerPiece: data.pricePerPiece.present
          ? data.pricePerPiece.value
          : this.pricePerPiece,
      subtotal: data.subtotal.present ? data.subtotal.value : this.subtotal,
      isFree: data.isFree.present ? data.isFree.value : this.isFree,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DeletedInvoiceItem(')
          ..write('id: $id, ')
          ..write('invoiceId: $invoiceId, ')
          ..write('productId: $productId, ')
          ..write('unitType: $unitType, ')
          ..write('quantity: $quantity, ')
          ..write('pricePerPiece: $pricePerPiece, ')
          ..write('subtotal: $subtotal, ')
          ..write('isFree: $isFree, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    invoiceId,
    productId,
    unitType,
    quantity,
    pricePerPiece,
    subtotal,
    isFree,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeletedInvoiceItem &&
          other.id == this.id &&
          other.invoiceId == this.invoiceId &&
          other.productId == this.productId &&
          other.unitType == this.unitType &&
          other.quantity == this.quantity &&
          other.pricePerPiece == this.pricePerPiece &&
          other.subtotal == this.subtotal &&
          other.isFree == this.isFree &&
          other.deletedAt == this.deletedAt);
}

class DeletedInvoiceItemsCompanion extends UpdateCompanion<DeletedInvoiceItem> {
  final Value<String> id;
  final Value<String> invoiceId;
  final Value<String> productId;
  final Value<String> unitType;
  final Value<int> quantity;
  final Value<double> pricePerPiece;
  final Value<double> subtotal;
  final Value<bool> isFree;
  final Value<DateTime> deletedAt;
  final Value<int> rowid;
  const DeletedInvoiceItemsCompanion({
    this.id = const Value.absent(),
    this.invoiceId = const Value.absent(),
    this.productId = const Value.absent(),
    this.unitType = const Value.absent(),
    this.quantity = const Value.absent(),
    this.pricePerPiece = const Value.absent(),
    this.subtotal = const Value.absent(),
    this.isFree = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DeletedInvoiceItemsCompanion.insert({
    required String id,
    required String invoiceId,
    required String productId,
    required String unitType,
    required int quantity,
    required double pricePerPiece,
    required double subtotal,
    this.isFree = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       invoiceId = Value(invoiceId),
       productId = Value(productId),
       unitType = Value(unitType),
       quantity = Value(quantity),
       pricePerPiece = Value(pricePerPiece),
       subtotal = Value(subtotal);
  static Insertable<DeletedInvoiceItem> custom({
    Expression<String>? id,
    Expression<String>? invoiceId,
    Expression<String>? productId,
    Expression<String>? unitType,
    Expression<int>? quantity,
    Expression<double>? pricePerPiece,
    Expression<double>? subtotal,
    Expression<bool>? isFree,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (invoiceId != null) 'invoice_id': invoiceId,
      if (productId != null) 'product_id': productId,
      if (unitType != null) 'unit_type': unitType,
      if (quantity != null) 'quantity': quantity,
      if (pricePerPiece != null) 'price_per_piece': pricePerPiece,
      if (subtotal != null) 'subtotal': subtotal,
      if (isFree != null) 'is_free': isFree,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DeletedInvoiceItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? invoiceId,
    Value<String>? productId,
    Value<String>? unitType,
    Value<int>? quantity,
    Value<double>? pricePerPiece,
    Value<double>? subtotal,
    Value<bool>? isFree,
    Value<DateTime>? deletedAt,
    Value<int>? rowid,
  }) {
    return DeletedInvoiceItemsCompanion(
      id: id ?? this.id,
      invoiceId: invoiceId ?? this.invoiceId,
      productId: productId ?? this.productId,
      unitType: unitType ?? this.unitType,
      quantity: quantity ?? this.quantity,
      pricePerPiece: pricePerPiece ?? this.pricePerPiece,
      subtotal: subtotal ?? this.subtotal,
      isFree: isFree ?? this.isFree,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (invoiceId.present) {
      map['invoice_id'] = Variable<String>(invoiceId.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (unitType.present) {
      map['unit_type'] = Variable<String>(unitType.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (pricePerPiece.present) {
      map['price_per_piece'] = Variable<double>(pricePerPiece.value);
    }
    if (subtotal.present) {
      map['subtotal'] = Variable<double>(subtotal.value);
    }
    if (isFree.present) {
      map['is_free'] = Variable<bool>(isFree.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DeletedInvoiceItemsCompanion(')
          ..write('id: $id, ')
          ..write('invoiceId: $invoiceId, ')
          ..write('productId: $productId, ')
          ..write('unitType: $unitType, ')
          ..write('quantity: $quantity, ')
          ..write('pricePerPiece: $pricePerPiece, ')
          ..write('subtotal: $subtotal, ')
          ..write('isFree: $isFree, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BadOrdersTable extends BadOrders
    with TableInfo<$BadOrdersTable, BadOrder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BadOrdersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _clientIdMeta = const VerificationMeta(
    'clientId',
  );
  @override
  late final GeneratedColumn<String> clientId = GeneratedColumn<String>(
    'client_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES clients (id)',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _invoiceIdMeta = const VerificationMeta(
    'invoiceId',
  );
  @override
  late final GeneratedColumn<String> invoiceId = GeneratedColumn<String>(
    'invoice_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    clientId,
    date,
    type,
    notes,
    createdAt,
    invoiceId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bad_orders';
  @override
  VerificationContext validateIntegrity(
    Insertable<BadOrder> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('client_id')) {
      context.handle(
        _clientIdMeta,
        clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_clientIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('invoice_id')) {
      context.handle(
        _invoiceIdMeta,
        invoiceId.isAcceptableOrUnknown(data['invoice_id']!, _invoiceIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BadOrder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BadOrder(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      clientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      invoiceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}invoice_id'],
      ),
    );
  }

  @override
  $BadOrdersTable createAlias(String alias) {
    return $BadOrdersTable(attachedDatabase, alias);
  }
}

class BadOrder extends DataClass implements Insertable<BadOrder> {
  final String id;
  final String clientId;
  final DateTime date;
  final String type;
  final String? notes;
  final DateTime createdAt;
  final String? invoiceId;
  const BadOrder({
    required this.id,
    required this.clientId,
    required this.date,
    required this.type,
    this.notes,
    required this.createdAt,
    this.invoiceId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['client_id'] = Variable<String>(clientId);
    map['date'] = Variable<DateTime>(date);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || invoiceId != null) {
      map['invoice_id'] = Variable<String>(invoiceId);
    }
    return map;
  }

  BadOrdersCompanion toCompanion(bool nullToAbsent) {
    return BadOrdersCompanion(
      id: Value(id),
      clientId: Value(clientId),
      date: Value(date),
      type: Value(type),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
      invoiceId: invoiceId == null && nullToAbsent
          ? const Value.absent()
          : Value(invoiceId),
    );
  }

  factory BadOrder.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BadOrder(
      id: serializer.fromJson<String>(json['id']),
      clientId: serializer.fromJson<String>(json['clientId']),
      date: serializer.fromJson<DateTime>(json['date']),
      type: serializer.fromJson<String>(json['type']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      invoiceId: serializer.fromJson<String?>(json['invoiceId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'clientId': serializer.toJson<String>(clientId),
      'date': serializer.toJson<DateTime>(date),
      'type': serializer.toJson<String>(type),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'invoiceId': serializer.toJson<String?>(invoiceId),
    };
  }

  BadOrder copyWith({
    String? id,
    String? clientId,
    DateTime? date,
    String? type,
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
    Value<String?> invoiceId = const Value.absent(),
  }) => BadOrder(
    id: id ?? this.id,
    clientId: clientId ?? this.clientId,
    date: date ?? this.date,
    type: type ?? this.type,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
    invoiceId: invoiceId.present ? invoiceId.value : this.invoiceId,
  );
  BadOrder copyWithCompanion(BadOrdersCompanion data) {
    return BadOrder(
      id: data.id.present ? data.id.value : this.id,
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      date: data.date.present ? data.date.value : this.date,
      type: data.type.present ? data.type.value : this.type,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      invoiceId: data.invoiceId.present ? data.invoiceId.value : this.invoiceId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BadOrder(')
          ..write('id: $id, ')
          ..write('clientId: $clientId, ')
          ..write('date: $date, ')
          ..write('type: $type, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('invoiceId: $invoiceId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, clientId, date, type, notes, createdAt, invoiceId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BadOrder &&
          other.id == this.id &&
          other.clientId == this.clientId &&
          other.date == this.date &&
          other.type == this.type &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.invoiceId == this.invoiceId);
}

class BadOrdersCompanion extends UpdateCompanion<BadOrder> {
  final Value<String> id;
  final Value<String> clientId;
  final Value<DateTime> date;
  final Value<String> type;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<String?> invoiceId;
  final Value<int> rowid;
  const BadOrdersCompanion({
    this.id = const Value.absent(),
    this.clientId = const Value.absent(),
    this.date = const Value.absent(),
    this.type = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.invoiceId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BadOrdersCompanion.insert({
    required String id,
    required String clientId,
    this.date = const Value.absent(),
    required String type,
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.invoiceId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       clientId = Value(clientId),
       type = Value(type);
  static Insertable<BadOrder> custom({
    Expression<String>? id,
    Expression<String>? clientId,
    Expression<DateTime>? date,
    Expression<String>? type,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<String>? invoiceId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (clientId != null) 'client_id': clientId,
      if (date != null) 'date': date,
      if (type != null) 'type': type,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (invoiceId != null) 'invoice_id': invoiceId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BadOrdersCompanion copyWith({
    Value<String>? id,
    Value<String>? clientId,
    Value<DateTime>? date,
    Value<String>? type,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
    Value<String?>? invoiceId,
    Value<int>? rowid,
  }) {
    return BadOrdersCompanion(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      date: date ?? this.date,
      type: type ?? this.type,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      invoiceId: invoiceId ?? this.invoiceId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (invoiceId.present) {
      map['invoice_id'] = Variable<String>(invoiceId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BadOrdersCompanion(')
          ..write('id: $id, ')
          ..write('clientId: $clientId, ')
          ..write('date: $date, ')
          ..write('type: $type, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('invoiceId: $invoiceId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BadOrderItemsTable extends BadOrderItems
    with TableInfo<$BadOrderItemsTable, BadOrderItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BadOrderItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _badOrderIdMeta = const VerificationMeta(
    'badOrderId',
  );
  @override
  late final GeneratedColumn<String> badOrderId = GeneratedColumn<String>(
    'bad_order_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES bad_orders (id)',
    ),
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES products (id)',
    ),
  );
  static const VerificationMeta _unitTypeMeta = const VerificationMeta(
    'unitType',
  );
  @override
  late final GeneratedColumn<String> unitType = GeneratedColumn<String>(
    'unit_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    badOrderId,
    productId,
    unitType,
    quantity,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bad_order_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<BadOrderItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('bad_order_id')) {
      context.handle(
        _badOrderIdMeta,
        badOrderId.isAcceptableOrUnknown(
          data['bad_order_id']!,
          _badOrderIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_badOrderIdMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('unit_type')) {
      context.handle(
        _unitTypeMeta,
        unitType.isAcceptableOrUnknown(data['unit_type']!, _unitTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_unitTypeMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BadOrderItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BadOrderItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      badOrderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bad_order_id'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      )!,
      unitType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit_type'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      )!,
    );
  }

  @override
  $BadOrderItemsTable createAlias(String alias) {
    return $BadOrderItemsTable(attachedDatabase, alias);
  }
}

class BadOrderItem extends DataClass implements Insertable<BadOrderItem> {
  final String id;
  final String badOrderId;
  final String productId;
  final String unitType;
  final int quantity;
  const BadOrderItem({
    required this.id,
    required this.badOrderId,
    required this.productId,
    required this.unitType,
    required this.quantity,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['bad_order_id'] = Variable<String>(badOrderId);
    map['product_id'] = Variable<String>(productId);
    map['unit_type'] = Variable<String>(unitType);
    map['quantity'] = Variable<int>(quantity);
    return map;
  }

  BadOrderItemsCompanion toCompanion(bool nullToAbsent) {
    return BadOrderItemsCompanion(
      id: Value(id),
      badOrderId: Value(badOrderId),
      productId: Value(productId),
      unitType: Value(unitType),
      quantity: Value(quantity),
    );
  }

  factory BadOrderItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BadOrderItem(
      id: serializer.fromJson<String>(json['id']),
      badOrderId: serializer.fromJson<String>(json['badOrderId']),
      productId: serializer.fromJson<String>(json['productId']),
      unitType: serializer.fromJson<String>(json['unitType']),
      quantity: serializer.fromJson<int>(json['quantity']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'badOrderId': serializer.toJson<String>(badOrderId),
      'productId': serializer.toJson<String>(productId),
      'unitType': serializer.toJson<String>(unitType),
      'quantity': serializer.toJson<int>(quantity),
    };
  }

  BadOrderItem copyWith({
    String? id,
    String? badOrderId,
    String? productId,
    String? unitType,
    int? quantity,
  }) => BadOrderItem(
    id: id ?? this.id,
    badOrderId: badOrderId ?? this.badOrderId,
    productId: productId ?? this.productId,
    unitType: unitType ?? this.unitType,
    quantity: quantity ?? this.quantity,
  );
  BadOrderItem copyWithCompanion(BadOrderItemsCompanion data) {
    return BadOrderItem(
      id: data.id.present ? data.id.value : this.id,
      badOrderId: data.badOrderId.present
          ? data.badOrderId.value
          : this.badOrderId,
      productId: data.productId.present ? data.productId.value : this.productId,
      unitType: data.unitType.present ? data.unitType.value : this.unitType,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BadOrderItem(')
          ..write('id: $id, ')
          ..write('badOrderId: $badOrderId, ')
          ..write('productId: $productId, ')
          ..write('unitType: $unitType, ')
          ..write('quantity: $quantity')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, badOrderId, productId, unitType, quantity);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BadOrderItem &&
          other.id == this.id &&
          other.badOrderId == this.badOrderId &&
          other.productId == this.productId &&
          other.unitType == this.unitType &&
          other.quantity == this.quantity);
}

class BadOrderItemsCompanion extends UpdateCompanion<BadOrderItem> {
  final Value<String> id;
  final Value<String> badOrderId;
  final Value<String> productId;
  final Value<String> unitType;
  final Value<int> quantity;
  final Value<int> rowid;
  const BadOrderItemsCompanion({
    this.id = const Value.absent(),
    this.badOrderId = const Value.absent(),
    this.productId = const Value.absent(),
    this.unitType = const Value.absent(),
    this.quantity = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BadOrderItemsCompanion.insert({
    required String id,
    required String badOrderId,
    required String productId,
    required String unitType,
    required int quantity,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       badOrderId = Value(badOrderId),
       productId = Value(productId),
       unitType = Value(unitType),
       quantity = Value(quantity);
  static Insertable<BadOrderItem> custom({
    Expression<String>? id,
    Expression<String>? badOrderId,
    Expression<String>? productId,
    Expression<String>? unitType,
    Expression<int>? quantity,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (badOrderId != null) 'bad_order_id': badOrderId,
      if (productId != null) 'product_id': productId,
      if (unitType != null) 'unit_type': unitType,
      if (quantity != null) 'quantity': quantity,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BadOrderItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? badOrderId,
    Value<String>? productId,
    Value<String>? unitType,
    Value<int>? quantity,
    Value<int>? rowid,
  }) {
    return BadOrderItemsCompanion(
      id: id ?? this.id,
      badOrderId: badOrderId ?? this.badOrderId,
      productId: productId ?? this.productId,
      unitType: unitType ?? this.unitType,
      quantity: quantity ?? this.quantity,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (badOrderId.present) {
      map['bad_order_id'] = Variable<String>(badOrderId.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (unitType.present) {
      map['unit_type'] = Variable<String>(unitType.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BadOrderItemsCompanion(')
          ..write('id: $id, ')
          ..write('badOrderId: $badOrderId, ')
          ..write('productId: $productId, ')
          ..write('unitType: $unitType, ')
          ..write('quantity: $quantity, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VanAreasTable extends VanAreas with TableInfo<$VanAreasTable, VanArea> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VanAreasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'van_areas';
  @override
  VerificationContext validateIntegrity(
    Insertable<VanArea> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VanArea map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VanArea(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $VanAreasTable createAlias(String alias) {
    return $VanAreasTable(attachedDatabase, alias);
  }
}

class VanArea extends DataClass implements Insertable<VanArea> {
  final String id;
  final String name;
  const VanArea({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  VanAreasCompanion toCompanion(bool nullToAbsent) {
    return VanAreasCompanion(id: Value(id), name: Value(name));
  }

  factory VanArea.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VanArea(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  VanArea copyWith({String? id, String? name}) =>
      VanArea(id: id ?? this.id, name: name ?? this.name);
  VanArea copyWithCompanion(VanAreasCompanion data) {
    return VanArea(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VanArea(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VanArea && other.id == this.id && other.name == this.name);
}

class VanAreasCompanion extends UpdateCompanion<VanArea> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> rowid;
  const VanAreasCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VanAreasCompanion.insert({
    required String id,
    required String name,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<VanArea> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VanAreasCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? rowid,
  }) {
    return VanAreasCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VanAreasCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VanStocksTable extends VanStocks
    with TableInfo<$VanStocksTable, VanStock> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VanStocksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES products (id)',
    ),
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityPiecesMeta = const VerificationMeta(
    'quantityPieces',
  );
  @override
  late final GeneratedColumn<int> quantityPieces = GeneratedColumn<int>(
    'quantity_pieces',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _areaIdMeta = const VerificationMeta('areaId');
  @override
  late final GeneratedColumn<String> areaId = GeneratedColumn<String>(
    'area_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    productId,
    type,
    quantityPieces,
    date,
    notes,
    areaId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'van_stocks';
  @override
  VerificationContext validateIntegrity(
    Insertable<VanStock> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('quantity_pieces')) {
      context.handle(
        _quantityPiecesMeta,
        quantityPieces.isAcceptableOrUnknown(
          data['quantity_pieces']!,
          _quantityPiecesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_quantityPiecesMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('area_id')) {
      context.handle(
        _areaIdMeta,
        areaId.isAcceptableOrUnknown(data['area_id']!, _areaIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VanStock map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VanStock(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      quantityPieces: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity_pieces'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      areaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}area_id'],
      ),
    );
  }

  @override
  $VanStocksTable createAlias(String alias) {
    return $VanStocksTable(attachedDatabase, alias);
  }
}

class VanStock extends DataClass implements Insertable<VanStock> {
  final String id;
  final String productId;
  final String type;
  final int quantityPieces;
  final DateTime date;
  final String? notes;
  final String? areaId;
  const VanStock({
    required this.id,
    required this.productId,
    required this.type,
    required this.quantityPieces,
    required this.date,
    this.notes,
    this.areaId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['product_id'] = Variable<String>(productId);
    map['type'] = Variable<String>(type);
    map['quantity_pieces'] = Variable<int>(quantityPieces);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || areaId != null) {
      map['area_id'] = Variable<String>(areaId);
    }
    return map;
  }

  VanStocksCompanion toCompanion(bool nullToAbsent) {
    return VanStocksCompanion(
      id: Value(id),
      productId: Value(productId),
      type: Value(type),
      quantityPieces: Value(quantityPieces),
      date: Value(date),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      areaId: areaId == null && nullToAbsent
          ? const Value.absent()
          : Value(areaId),
    );
  }

  factory VanStock.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VanStock(
      id: serializer.fromJson<String>(json['id']),
      productId: serializer.fromJson<String>(json['productId']),
      type: serializer.fromJson<String>(json['type']),
      quantityPieces: serializer.fromJson<int>(json['quantityPieces']),
      date: serializer.fromJson<DateTime>(json['date']),
      notes: serializer.fromJson<String?>(json['notes']),
      areaId: serializer.fromJson<String?>(json['areaId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'productId': serializer.toJson<String>(productId),
      'type': serializer.toJson<String>(type),
      'quantityPieces': serializer.toJson<int>(quantityPieces),
      'date': serializer.toJson<DateTime>(date),
      'notes': serializer.toJson<String?>(notes),
      'areaId': serializer.toJson<String?>(areaId),
    };
  }

  VanStock copyWith({
    String? id,
    String? productId,
    String? type,
    int? quantityPieces,
    DateTime? date,
    Value<String?> notes = const Value.absent(),
    Value<String?> areaId = const Value.absent(),
  }) => VanStock(
    id: id ?? this.id,
    productId: productId ?? this.productId,
    type: type ?? this.type,
    quantityPieces: quantityPieces ?? this.quantityPieces,
    date: date ?? this.date,
    notes: notes.present ? notes.value : this.notes,
    areaId: areaId.present ? areaId.value : this.areaId,
  );
  VanStock copyWithCompanion(VanStocksCompanion data) {
    return VanStock(
      id: data.id.present ? data.id.value : this.id,
      productId: data.productId.present ? data.productId.value : this.productId,
      type: data.type.present ? data.type.value : this.type,
      quantityPieces: data.quantityPieces.present
          ? data.quantityPieces.value
          : this.quantityPieces,
      date: data.date.present ? data.date.value : this.date,
      notes: data.notes.present ? data.notes.value : this.notes,
      areaId: data.areaId.present ? data.areaId.value : this.areaId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VanStock(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('type: $type, ')
          ..write('quantityPieces: $quantityPieces, ')
          ..write('date: $date, ')
          ..write('notes: $notes, ')
          ..write('areaId: $areaId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, productId, type, quantityPieces, date, notes, areaId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VanStock &&
          other.id == this.id &&
          other.productId == this.productId &&
          other.type == this.type &&
          other.quantityPieces == this.quantityPieces &&
          other.date == this.date &&
          other.notes == this.notes &&
          other.areaId == this.areaId);
}

class VanStocksCompanion extends UpdateCompanion<VanStock> {
  final Value<String> id;
  final Value<String> productId;
  final Value<String> type;
  final Value<int> quantityPieces;
  final Value<DateTime> date;
  final Value<String?> notes;
  final Value<String?> areaId;
  final Value<int> rowid;
  const VanStocksCompanion({
    this.id = const Value.absent(),
    this.productId = const Value.absent(),
    this.type = const Value.absent(),
    this.quantityPieces = const Value.absent(),
    this.date = const Value.absent(),
    this.notes = const Value.absent(),
    this.areaId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VanStocksCompanion.insert({
    required String id,
    required String productId,
    required String type,
    required int quantityPieces,
    this.date = const Value.absent(),
    this.notes = const Value.absent(),
    this.areaId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       productId = Value(productId),
       type = Value(type),
       quantityPieces = Value(quantityPieces);
  static Insertable<VanStock> custom({
    Expression<String>? id,
    Expression<String>? productId,
    Expression<String>? type,
    Expression<int>? quantityPieces,
    Expression<DateTime>? date,
    Expression<String>? notes,
    Expression<String>? areaId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (productId != null) 'product_id': productId,
      if (type != null) 'type': type,
      if (quantityPieces != null) 'quantity_pieces': quantityPieces,
      if (date != null) 'date': date,
      if (notes != null) 'notes': notes,
      if (areaId != null) 'area_id': areaId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VanStocksCompanion copyWith({
    Value<String>? id,
    Value<String>? productId,
    Value<String>? type,
    Value<int>? quantityPieces,
    Value<DateTime>? date,
    Value<String?>? notes,
    Value<String?>? areaId,
    Value<int>? rowid,
  }) {
    return VanStocksCompanion(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      type: type ?? this.type,
      quantityPieces: quantityPieces ?? this.quantityPieces,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      areaId: areaId ?? this.areaId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (quantityPieces.present) {
      map['quantity_pieces'] = Variable<int>(quantityPieces.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (areaId.present) {
      map['area_id'] = Variable<String>(areaId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VanStocksCompanion(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('type: $type, ')
          ..write('quantityPieces: $quantityPieces, ')
          ..write('date: $date, ')
          ..write('notes: $notes, ')
          ..write('areaId: $areaId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VanStockDraftsTable extends VanStockDrafts
    with TableInfo<$VanStockDraftsTable, VanStockDraft> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VanStockDraftsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _areaIdMeta = const VerificationMeta('areaId');
  @override
  late final GeneratedColumn<String> areaId = GeneratedColumn<String>(
    'area_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _txDateMeta = const VerificationMeta('txDate');
  @override
  late final GeneratedColumn<DateTime> txDate = GeneratedColumn<DateTime>(
    'tx_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _itemsJsonMeta = const VerificationMeta(
    'itemsJson',
  );
  @override
  late final GeneratedColumn<String> itemsJson = GeneratedColumn<String>(
    'items_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    areaId,
    txDate,
    itemsJson,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'van_stock_drafts';
  @override
  VerificationContext validateIntegrity(
    Insertable<VanStockDraft> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('area_id')) {
      context.handle(
        _areaIdMeta,
        areaId.isAcceptableOrUnknown(data['area_id']!, _areaIdMeta),
      );
    }
    if (data.containsKey('tx_date')) {
      context.handle(
        _txDateMeta,
        txDate.isAcceptableOrUnknown(data['tx_date']!, _txDateMeta),
      );
    }
    if (data.containsKey('items_json')) {
      context.handle(
        _itemsJsonMeta,
        itemsJson.isAcceptableOrUnknown(data['items_json']!, _itemsJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_itemsJsonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VanStockDraft map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VanStockDraft(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      areaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}area_id'],
      ),
      txDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}tx_date'],
      )!,
      itemsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}items_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $VanStockDraftsTable createAlias(String alias) {
    return $VanStockDraftsTable(attachedDatabase, alias);
  }
}

class VanStockDraft extends DataClass implements Insertable<VanStockDraft> {
  final String id;
  final String type;
  final String? areaId;
  final DateTime txDate;
  final String itemsJson;
  final DateTime createdAt;
  const VanStockDraft({
    required this.id,
    required this.type,
    this.areaId,
    required this.txDate,
    required this.itemsJson,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || areaId != null) {
      map['area_id'] = Variable<String>(areaId);
    }
    map['tx_date'] = Variable<DateTime>(txDate);
    map['items_json'] = Variable<String>(itemsJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  VanStockDraftsCompanion toCompanion(bool nullToAbsent) {
    return VanStockDraftsCompanion(
      id: Value(id),
      type: Value(type),
      areaId: areaId == null && nullToAbsent
          ? const Value.absent()
          : Value(areaId),
      txDate: Value(txDate),
      itemsJson: Value(itemsJson),
      createdAt: Value(createdAt),
    );
  }

  factory VanStockDraft.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VanStockDraft(
      id: serializer.fromJson<String>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      areaId: serializer.fromJson<String?>(json['areaId']),
      txDate: serializer.fromJson<DateTime>(json['txDate']),
      itemsJson: serializer.fromJson<String>(json['itemsJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<String>(type),
      'areaId': serializer.toJson<String?>(areaId),
      'txDate': serializer.toJson<DateTime>(txDate),
      'itemsJson': serializer.toJson<String>(itemsJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  VanStockDraft copyWith({
    String? id,
    String? type,
    Value<String?> areaId = const Value.absent(),
    DateTime? txDate,
    String? itemsJson,
    DateTime? createdAt,
  }) => VanStockDraft(
    id: id ?? this.id,
    type: type ?? this.type,
    areaId: areaId.present ? areaId.value : this.areaId,
    txDate: txDate ?? this.txDate,
    itemsJson: itemsJson ?? this.itemsJson,
    createdAt: createdAt ?? this.createdAt,
  );
  VanStockDraft copyWithCompanion(VanStockDraftsCompanion data) {
    return VanStockDraft(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      areaId: data.areaId.present ? data.areaId.value : this.areaId,
      txDate: data.txDate.present ? data.txDate.value : this.txDate,
      itemsJson: data.itemsJson.present ? data.itemsJson.value : this.itemsJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VanStockDraft(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('areaId: $areaId, ')
          ..write('txDate: $txDate, ')
          ..write('itemsJson: $itemsJson, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, type, areaId, txDate, itemsJson, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VanStockDraft &&
          other.id == this.id &&
          other.type == this.type &&
          other.areaId == this.areaId &&
          other.txDate == this.txDate &&
          other.itemsJson == this.itemsJson &&
          other.createdAt == this.createdAt);
}

class VanStockDraftsCompanion extends UpdateCompanion<VanStockDraft> {
  final Value<String> id;
  final Value<String> type;
  final Value<String?> areaId;
  final Value<DateTime> txDate;
  final Value<String> itemsJson;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const VanStockDraftsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.areaId = const Value.absent(),
    this.txDate = const Value.absent(),
    this.itemsJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VanStockDraftsCompanion.insert({
    required String id,
    required String type,
    this.areaId = const Value.absent(),
    this.txDate = const Value.absent(),
    required String itemsJson,
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       type = Value(type),
       itemsJson = Value(itemsJson);
  static Insertable<VanStockDraft> custom({
    Expression<String>? id,
    Expression<String>? type,
    Expression<String>? areaId,
    Expression<DateTime>? txDate,
    Expression<String>? itemsJson,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (areaId != null) 'area_id': areaId,
      if (txDate != null) 'tx_date': txDate,
      if (itemsJson != null) 'items_json': itemsJson,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VanStockDraftsCompanion copyWith({
    Value<String>? id,
    Value<String>? type,
    Value<String?>? areaId,
    Value<DateTime>? txDate,
    Value<String>? itemsJson,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return VanStockDraftsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      areaId: areaId ?? this.areaId,
      txDate: txDate ?? this.txDate,
      itemsJson: itemsJson ?? this.itemsJson,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (areaId.present) {
      map['area_id'] = Variable<String>(areaId.value);
    }
    if (txDate.present) {
      map['tx_date'] = Variable<DateTime>(txDate.value);
    }
    if (itemsJson.present) {
      map['items_json'] = Variable<String>(itemsJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VanStockDraftsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('areaId: $areaId, ')
          ..write('txDate: $txDate, ')
          ..write('itemsJson: $itemsJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BadOrderDraftsTable extends BadOrderDrafts
    with TableInfo<$BadOrderDraftsTable, BadOrderDraft> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BadOrderDraftsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _clientIdMeta = const VerificationMeta(
    'clientId',
  );
  @override
  late final GeneratedColumn<String> clientId = GeneratedColumn<String>(
    'client_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noClientMeta = const VerificationMeta(
    'noClient',
  );
  @override
  late final GeneratedColumn<bool> noClient = GeneratedColumn<bool>(
    'no_client',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("no_client" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _itemsJsonMeta = const VerificationMeta(
    'itemsJson',
  );
  @override
  late final GeneratedColumn<String> itemsJson = GeneratedColumn<String>(
    'items_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    clientId,
    noClient,
    date,
    notes,
    itemsJson,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bad_order_drafts';
  @override
  VerificationContext validateIntegrity(
    Insertable<BadOrderDraft> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('client_id')) {
      context.handle(
        _clientIdMeta,
        clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta),
      );
    }
    if (data.containsKey('no_client')) {
      context.handle(
        _noClientMeta,
        noClient.isAcceptableOrUnknown(data['no_client']!, _noClientMeta),
      );
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('items_json')) {
      context.handle(
        _itemsJsonMeta,
        itemsJson.isAcceptableOrUnknown(data['items_json']!, _itemsJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_itemsJsonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BadOrderDraft map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BadOrderDraft(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      clientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_id'],
      ),
      noClient: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}no_client'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      itemsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}items_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $BadOrderDraftsTable createAlias(String alias) {
    return $BadOrderDraftsTable(attachedDatabase, alias);
  }
}

class BadOrderDraft extends DataClass implements Insertable<BadOrderDraft> {
  final String id;
  final String type;
  final String? clientId;
  final bool noClient;
  final DateTime date;
  final String? notes;
  final String itemsJson;
  final DateTime createdAt;
  const BadOrderDraft({
    required this.id,
    required this.type,
    this.clientId,
    required this.noClient,
    required this.date,
    this.notes,
    required this.itemsJson,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || clientId != null) {
      map['client_id'] = Variable<String>(clientId);
    }
    map['no_client'] = Variable<bool>(noClient);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['items_json'] = Variable<String>(itemsJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  BadOrderDraftsCompanion toCompanion(bool nullToAbsent) {
    return BadOrderDraftsCompanion(
      id: Value(id),
      type: Value(type),
      clientId: clientId == null && nullToAbsent
          ? const Value.absent()
          : Value(clientId),
      noClient: Value(noClient),
      date: Value(date),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      itemsJson: Value(itemsJson),
      createdAt: Value(createdAt),
    );
  }

  factory BadOrderDraft.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BadOrderDraft(
      id: serializer.fromJson<String>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      clientId: serializer.fromJson<String?>(json['clientId']),
      noClient: serializer.fromJson<bool>(json['noClient']),
      date: serializer.fromJson<DateTime>(json['date']),
      notes: serializer.fromJson<String?>(json['notes']),
      itemsJson: serializer.fromJson<String>(json['itemsJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<String>(type),
      'clientId': serializer.toJson<String?>(clientId),
      'noClient': serializer.toJson<bool>(noClient),
      'date': serializer.toJson<DateTime>(date),
      'notes': serializer.toJson<String?>(notes),
      'itemsJson': serializer.toJson<String>(itemsJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  BadOrderDraft copyWith({
    String? id,
    String? type,
    Value<String?> clientId = const Value.absent(),
    bool? noClient,
    DateTime? date,
    Value<String?> notes = const Value.absent(),
    String? itemsJson,
    DateTime? createdAt,
  }) => BadOrderDraft(
    id: id ?? this.id,
    type: type ?? this.type,
    clientId: clientId.present ? clientId.value : this.clientId,
    noClient: noClient ?? this.noClient,
    date: date ?? this.date,
    notes: notes.present ? notes.value : this.notes,
    itemsJson: itemsJson ?? this.itemsJson,
    createdAt: createdAt ?? this.createdAt,
  );
  BadOrderDraft copyWithCompanion(BadOrderDraftsCompanion data) {
    return BadOrderDraft(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      noClient: data.noClient.present ? data.noClient.value : this.noClient,
      date: data.date.present ? data.date.value : this.date,
      notes: data.notes.present ? data.notes.value : this.notes,
      itemsJson: data.itemsJson.present ? data.itemsJson.value : this.itemsJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BadOrderDraft(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('clientId: $clientId, ')
          ..write('noClient: $noClient, ')
          ..write('date: $date, ')
          ..write('notes: $notes, ')
          ..write('itemsJson: $itemsJson, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    type,
    clientId,
    noClient,
    date,
    notes,
    itemsJson,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BadOrderDraft &&
          other.id == this.id &&
          other.type == this.type &&
          other.clientId == this.clientId &&
          other.noClient == this.noClient &&
          other.date == this.date &&
          other.notes == this.notes &&
          other.itemsJson == this.itemsJson &&
          other.createdAt == this.createdAt);
}

class BadOrderDraftsCompanion extends UpdateCompanion<BadOrderDraft> {
  final Value<String> id;
  final Value<String> type;
  final Value<String?> clientId;
  final Value<bool> noClient;
  final Value<DateTime> date;
  final Value<String?> notes;
  final Value<String> itemsJson;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const BadOrderDraftsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.clientId = const Value.absent(),
    this.noClient = const Value.absent(),
    this.date = const Value.absent(),
    this.notes = const Value.absent(),
    this.itemsJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BadOrderDraftsCompanion.insert({
    required String id,
    required String type,
    this.clientId = const Value.absent(),
    this.noClient = const Value.absent(),
    this.date = const Value.absent(),
    this.notes = const Value.absent(),
    required String itemsJson,
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       type = Value(type),
       itemsJson = Value(itemsJson);
  static Insertable<BadOrderDraft> custom({
    Expression<String>? id,
    Expression<String>? type,
    Expression<String>? clientId,
    Expression<bool>? noClient,
    Expression<DateTime>? date,
    Expression<String>? notes,
    Expression<String>? itemsJson,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (clientId != null) 'client_id': clientId,
      if (noClient != null) 'no_client': noClient,
      if (date != null) 'date': date,
      if (notes != null) 'notes': notes,
      if (itemsJson != null) 'items_json': itemsJson,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BadOrderDraftsCompanion copyWith({
    Value<String>? id,
    Value<String>? type,
    Value<String?>? clientId,
    Value<bool>? noClient,
    Value<DateTime>? date,
    Value<String?>? notes,
    Value<String>? itemsJson,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return BadOrderDraftsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      clientId: clientId ?? this.clientId,
      noClient: noClient ?? this.noClient,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      itemsJson: itemsJson ?? this.itemsJson,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (noClient.present) {
      map['no_client'] = Variable<bool>(noClient.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (itemsJson.present) {
      map['items_json'] = Variable<String>(itemsJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BadOrderDraftsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('clientId: $clientId, ')
          ..write('noClient: $noClient, ')
          ..write('date: $date, ')
          ..write('notes: $notes, ')
          ..write('itemsJson: $itemsJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StockMovementsTable extends StockMovements
    with TableInfo<$StockMovementsTable, StockMovement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StockMovementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES products (id)',
    ),
  );
  static const VerificationMeta _movementTypeMeta = const VerificationMeta(
    'movementType',
  );
  @override
  late final GeneratedColumn<String> movementType = GeneratedColumn<String>(
    'movement_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityPiecesMeta = const VerificationMeta(
    'quantityPieces',
  );
  @override
  late final GeneratedColumn<int> quantityPieces = GeneratedColumn<int>(
    'quantity_pieces',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _referenceDateMeta = const VerificationMeta(
    'referenceDate',
  );
  @override
  late final GeneratedColumn<DateTime> referenceDate =
      GeneratedColumn<DateTime>(
        'reference_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _invoiceNumberMeta = const VerificationMeta(
    'invoiceNumber',
  );
  @override
  late final GeneratedColumn<String> invoiceNumber = GeneratedColumn<String>(
    'invoice_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _commentsMeta = const VerificationMeta(
    'comments',
  );
  @override
  late final GeneratedColumn<String> comments = GeneratedColumn<String>(
    'comments',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    productId,
    movementType,
    quantityPieces,
    referenceDate,
    invoiceNumber,
    comments,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stock_movements';
  @override
  VerificationContext validateIntegrity(
    Insertable<StockMovement> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('movement_type')) {
      context.handle(
        _movementTypeMeta,
        movementType.isAcceptableOrUnknown(
          data['movement_type']!,
          _movementTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_movementTypeMeta);
    }
    if (data.containsKey('quantity_pieces')) {
      context.handle(
        _quantityPiecesMeta,
        quantityPieces.isAcceptableOrUnknown(
          data['quantity_pieces']!,
          _quantityPiecesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_quantityPiecesMeta);
    }
    if (data.containsKey('reference_date')) {
      context.handle(
        _referenceDateMeta,
        referenceDate.isAcceptableOrUnknown(
          data['reference_date']!,
          _referenceDateMeta,
        ),
      );
    }
    if (data.containsKey('invoice_number')) {
      context.handle(
        _invoiceNumberMeta,
        invoiceNumber.isAcceptableOrUnknown(
          data['invoice_number']!,
          _invoiceNumberMeta,
        ),
      );
    }
    if (data.containsKey('comments')) {
      context.handle(
        _commentsMeta,
        comments.isAcceptableOrUnknown(data['comments']!, _commentsMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StockMovement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StockMovement(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      )!,
      movementType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}movement_type'],
      )!,
      quantityPieces: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity_pieces'],
      )!,
      referenceDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}reference_date'],
      ),
      invoiceNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}invoice_number'],
      ),
      comments: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}comments'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $StockMovementsTable createAlias(String alias) {
    return $StockMovementsTable(attachedDatabase, alias);
  }
}

class StockMovement extends DataClass implements Insertable<StockMovement> {
  final String id;
  final String productId;
  final String movementType;
  final int quantityPieces;
  final DateTime? referenceDate;
  final String? invoiceNumber;
  final String? comments;
  final DateTime createdAt;
  const StockMovement({
    required this.id,
    required this.productId,
    required this.movementType,
    required this.quantityPieces,
    this.referenceDate,
    this.invoiceNumber,
    this.comments,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['product_id'] = Variable<String>(productId);
    map['movement_type'] = Variable<String>(movementType);
    map['quantity_pieces'] = Variable<int>(quantityPieces);
    if (!nullToAbsent || referenceDate != null) {
      map['reference_date'] = Variable<DateTime>(referenceDate);
    }
    if (!nullToAbsent || invoiceNumber != null) {
      map['invoice_number'] = Variable<String>(invoiceNumber);
    }
    if (!nullToAbsent || comments != null) {
      map['comments'] = Variable<String>(comments);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  StockMovementsCompanion toCompanion(bool nullToAbsent) {
    return StockMovementsCompanion(
      id: Value(id),
      productId: Value(productId),
      movementType: Value(movementType),
      quantityPieces: Value(quantityPieces),
      referenceDate: referenceDate == null && nullToAbsent
          ? const Value.absent()
          : Value(referenceDate),
      invoiceNumber: invoiceNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(invoiceNumber),
      comments: comments == null && nullToAbsent
          ? const Value.absent()
          : Value(comments),
      createdAt: Value(createdAt),
    );
  }

  factory StockMovement.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StockMovement(
      id: serializer.fromJson<String>(json['id']),
      productId: serializer.fromJson<String>(json['productId']),
      movementType: serializer.fromJson<String>(json['movementType']),
      quantityPieces: serializer.fromJson<int>(json['quantityPieces']),
      referenceDate: serializer.fromJson<DateTime?>(json['referenceDate']),
      invoiceNumber: serializer.fromJson<String?>(json['invoiceNumber']),
      comments: serializer.fromJson<String?>(json['comments']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'productId': serializer.toJson<String>(productId),
      'movementType': serializer.toJson<String>(movementType),
      'quantityPieces': serializer.toJson<int>(quantityPieces),
      'referenceDate': serializer.toJson<DateTime?>(referenceDate),
      'invoiceNumber': serializer.toJson<String?>(invoiceNumber),
      'comments': serializer.toJson<String?>(comments),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  StockMovement copyWith({
    String? id,
    String? productId,
    String? movementType,
    int? quantityPieces,
    Value<DateTime?> referenceDate = const Value.absent(),
    Value<String?> invoiceNumber = const Value.absent(),
    Value<String?> comments = const Value.absent(),
    DateTime? createdAt,
  }) => StockMovement(
    id: id ?? this.id,
    productId: productId ?? this.productId,
    movementType: movementType ?? this.movementType,
    quantityPieces: quantityPieces ?? this.quantityPieces,
    referenceDate: referenceDate.present
        ? referenceDate.value
        : this.referenceDate,
    invoiceNumber: invoiceNumber.present
        ? invoiceNumber.value
        : this.invoiceNumber,
    comments: comments.present ? comments.value : this.comments,
    createdAt: createdAt ?? this.createdAt,
  );
  StockMovement copyWithCompanion(StockMovementsCompanion data) {
    return StockMovement(
      id: data.id.present ? data.id.value : this.id,
      productId: data.productId.present ? data.productId.value : this.productId,
      movementType: data.movementType.present
          ? data.movementType.value
          : this.movementType,
      quantityPieces: data.quantityPieces.present
          ? data.quantityPieces.value
          : this.quantityPieces,
      referenceDate: data.referenceDate.present
          ? data.referenceDate.value
          : this.referenceDate,
      invoiceNumber: data.invoiceNumber.present
          ? data.invoiceNumber.value
          : this.invoiceNumber,
      comments: data.comments.present ? data.comments.value : this.comments,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StockMovement(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('movementType: $movementType, ')
          ..write('quantityPieces: $quantityPieces, ')
          ..write('referenceDate: $referenceDate, ')
          ..write('invoiceNumber: $invoiceNumber, ')
          ..write('comments: $comments, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    productId,
    movementType,
    quantityPieces,
    referenceDate,
    invoiceNumber,
    comments,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StockMovement &&
          other.id == this.id &&
          other.productId == this.productId &&
          other.movementType == this.movementType &&
          other.quantityPieces == this.quantityPieces &&
          other.referenceDate == this.referenceDate &&
          other.invoiceNumber == this.invoiceNumber &&
          other.comments == this.comments &&
          other.createdAt == this.createdAt);
}

class StockMovementsCompanion extends UpdateCompanion<StockMovement> {
  final Value<String> id;
  final Value<String> productId;
  final Value<String> movementType;
  final Value<int> quantityPieces;
  final Value<DateTime?> referenceDate;
  final Value<String?> invoiceNumber;
  final Value<String?> comments;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const StockMovementsCompanion({
    this.id = const Value.absent(),
    this.productId = const Value.absent(),
    this.movementType = const Value.absent(),
    this.quantityPieces = const Value.absent(),
    this.referenceDate = const Value.absent(),
    this.invoiceNumber = const Value.absent(),
    this.comments = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StockMovementsCompanion.insert({
    required String id,
    required String productId,
    required String movementType,
    required int quantityPieces,
    this.referenceDate = const Value.absent(),
    this.invoiceNumber = const Value.absent(),
    this.comments = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       productId = Value(productId),
       movementType = Value(movementType),
       quantityPieces = Value(quantityPieces);
  static Insertable<StockMovement> custom({
    Expression<String>? id,
    Expression<String>? productId,
    Expression<String>? movementType,
    Expression<int>? quantityPieces,
    Expression<DateTime>? referenceDate,
    Expression<String>? invoiceNumber,
    Expression<String>? comments,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (productId != null) 'product_id': productId,
      if (movementType != null) 'movement_type': movementType,
      if (quantityPieces != null) 'quantity_pieces': quantityPieces,
      if (referenceDate != null) 'reference_date': referenceDate,
      if (invoiceNumber != null) 'invoice_number': invoiceNumber,
      if (comments != null) 'comments': comments,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StockMovementsCompanion copyWith({
    Value<String>? id,
    Value<String>? productId,
    Value<String>? movementType,
    Value<int>? quantityPieces,
    Value<DateTime?>? referenceDate,
    Value<String?>? invoiceNumber,
    Value<String?>? comments,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return StockMovementsCompanion(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      movementType: movementType ?? this.movementType,
      quantityPieces: quantityPieces ?? this.quantityPieces,
      referenceDate: referenceDate ?? this.referenceDate,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      comments: comments ?? this.comments,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (movementType.present) {
      map['movement_type'] = Variable<String>(movementType.value);
    }
    if (quantityPieces.present) {
      map['quantity_pieces'] = Variable<int>(quantityPieces.value);
    }
    if (referenceDate.present) {
      map['reference_date'] = Variable<DateTime>(referenceDate.value);
    }
    if (invoiceNumber.present) {
      map['invoice_number'] = Variable<String>(invoiceNumber.value);
    }
    if (comments.present) {
      map['comments'] = Variable<String>(comments.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StockMovementsCompanion(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('movementType: $movementType, ')
          ..write('quantityPieces: $quantityPieces, ')
          ..write('referenceDate: $referenceDate, ')
          ..write('invoiceNumber: $invoiceNumber, ')
          ..write('comments: $comments, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InvoicePaymentsTable extends InvoicePayments
    with TableInfo<$InvoicePaymentsTable, InvoicePayment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InvoicePaymentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _invoiceIdMeta = const VerificationMeta(
    'invoiceId',
  );
  @override
  late final GeneratedColumn<String> invoiceId = GeneratedColumn<String>(
    'invoice_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES invoices (id)',
    ),
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paymentDateMeta = const VerificationMeta(
    'paymentDate',
  );
  @override
  late final GeneratedColumn<DateTime> paymentDate = GeneratedColumn<DateTime>(
    'payment_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    invoiceId,
    amount,
    paymentDate,
    notes,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'invoice_payments';
  @override
  VerificationContext validateIntegrity(
    Insertable<InvoicePayment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('invoice_id')) {
      context.handle(
        _invoiceIdMeta,
        invoiceId.isAcceptableOrUnknown(data['invoice_id']!, _invoiceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_invoiceIdMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('payment_date')) {
      context.handle(
        _paymentDateMeta,
        paymentDate.isAcceptableOrUnknown(
          data['payment_date']!,
          _paymentDateMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InvoicePayment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InvoicePayment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      invoiceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}invoice_id'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      paymentDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}payment_date'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $InvoicePaymentsTable createAlias(String alias) {
    return $InvoicePaymentsTable(attachedDatabase, alias);
  }
}

class InvoicePayment extends DataClass implements Insertable<InvoicePayment> {
  final String id;
  final String invoiceId;
  final double amount;
  final DateTime? paymentDate;
  final String? notes;
  final DateTime createdAt;
  const InvoicePayment({
    required this.id,
    required this.invoiceId,
    required this.amount,
    this.paymentDate,
    this.notes,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['invoice_id'] = Variable<String>(invoiceId);
    map['amount'] = Variable<double>(amount);
    if (!nullToAbsent || paymentDate != null) {
      map['payment_date'] = Variable<DateTime>(paymentDate);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  InvoicePaymentsCompanion toCompanion(bool nullToAbsent) {
    return InvoicePaymentsCompanion(
      id: Value(id),
      invoiceId: Value(invoiceId),
      amount: Value(amount),
      paymentDate: paymentDate == null && nullToAbsent
          ? const Value.absent()
          : Value(paymentDate),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory InvoicePayment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InvoicePayment(
      id: serializer.fromJson<String>(json['id']),
      invoiceId: serializer.fromJson<String>(json['invoiceId']),
      amount: serializer.fromJson<double>(json['amount']),
      paymentDate: serializer.fromJson<DateTime?>(json['paymentDate']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'invoiceId': serializer.toJson<String>(invoiceId),
      'amount': serializer.toJson<double>(amount),
      'paymentDate': serializer.toJson<DateTime?>(paymentDate),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  InvoicePayment copyWith({
    String? id,
    String? invoiceId,
    double? amount,
    Value<DateTime?> paymentDate = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
  }) => InvoicePayment(
    id: id ?? this.id,
    invoiceId: invoiceId ?? this.invoiceId,
    amount: amount ?? this.amount,
    paymentDate: paymentDate.present ? paymentDate.value : this.paymentDate,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
  );
  InvoicePayment copyWithCompanion(InvoicePaymentsCompanion data) {
    return InvoicePayment(
      id: data.id.present ? data.id.value : this.id,
      invoiceId: data.invoiceId.present ? data.invoiceId.value : this.invoiceId,
      amount: data.amount.present ? data.amount.value : this.amount,
      paymentDate: data.paymentDate.present
          ? data.paymentDate.value
          : this.paymentDate,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InvoicePayment(')
          ..write('id: $id, ')
          ..write('invoiceId: $invoiceId, ')
          ..write('amount: $amount, ')
          ..write('paymentDate: $paymentDate, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, invoiceId, amount, paymentDate, notes, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InvoicePayment &&
          other.id == this.id &&
          other.invoiceId == this.invoiceId &&
          other.amount == this.amount &&
          other.paymentDate == this.paymentDate &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class InvoicePaymentsCompanion extends UpdateCompanion<InvoicePayment> {
  final Value<String> id;
  final Value<String> invoiceId;
  final Value<double> amount;
  final Value<DateTime?> paymentDate;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const InvoicePaymentsCompanion({
    this.id = const Value.absent(),
    this.invoiceId = const Value.absent(),
    this.amount = const Value.absent(),
    this.paymentDate = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InvoicePaymentsCompanion.insert({
    required String id,
    required String invoiceId,
    required double amount,
    this.paymentDate = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       invoiceId = Value(invoiceId),
       amount = Value(amount);
  static Insertable<InvoicePayment> custom({
    Expression<String>? id,
    Expression<String>? invoiceId,
    Expression<double>? amount,
    Expression<DateTime>? paymentDate,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (invoiceId != null) 'invoice_id': invoiceId,
      if (amount != null) 'amount': amount,
      if (paymentDate != null) 'payment_date': paymentDate,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InvoicePaymentsCompanion copyWith({
    Value<String>? id,
    Value<String>? invoiceId,
    Value<double>? amount,
    Value<DateTime?>? paymentDate,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return InvoicePaymentsCompanion(
      id: id ?? this.id,
      invoiceId: invoiceId ?? this.invoiceId,
      amount: amount ?? this.amount,
      paymentDate: paymentDate ?? this.paymentDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (invoiceId.present) {
      map['invoice_id'] = Variable<String>(invoiceId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (paymentDate.present) {
      map['payment_date'] = Variable<DateTime>(paymentDate.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InvoicePaymentsCompanion(')
          ..write('id: $id, ')
          ..write('invoiceId: $invoiceId, ')
          ..write('amount: $amount, ')
          ..write('paymentDate: $paymentDate, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SupplierReceivedInvoicesTable extends SupplierReceivedInvoices
    with TableInfo<$SupplierReceivedInvoicesTable, SupplierReceivedInvoice> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SupplierReceivedInvoicesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _supplierIdMeta = const VerificationMeta(
    'supplierId',
  );
  @override
  late final GeneratedColumn<String> supplierId = GeneratedColumn<String>(
    'supplier_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES suppliers (id)',
    ),
  );
  static const VerificationMeta _receivedDateMeta = const VerificationMeta(
    'receivedDate',
  );
  @override
  late final GeneratedColumn<DateTime> receivedDate = GeneratedColumn<DateTime>(
    'received_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _referenceNumberMeta = const VerificationMeta(
    'referenceNumber',
  );
  @override
  late final GeneratedColumn<String> referenceNumber = GeneratedColumn<String>(
    'reference_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalAmountSystemMeta = const VerificationMeta(
    'totalAmountSystem',
  );
  @override
  late final GeneratedColumn<double> totalAmountSystem =
      GeneratedColumn<double>(
        'total_amount_system',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0.0),
      );
  static const VerificationMeta _totalAmountSupplierMeta =
      const VerificationMeta('totalAmountSupplier');
  @override
  late final GeneratedColumn<double> totalAmountSupplier =
      GeneratedColumn<double>(
        'total_amount_supplier',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0.0),
      );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('received'),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _discountPercentsMeta = const VerificationMeta(
    'discountPercents',
  );
  @override
  late final GeneratedColumn<String> discountPercents = GeneratedColumn<String>(
    'discount_percents',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _vatEnabledMeta = const VerificationMeta(
    'vatEnabled',
  );
  @override
  late final GeneratedColumn<bool> vatEnabled = GeneratedColumn<bool>(
    'vat_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("vat_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    supplierId,
    receivedDate,
    referenceNumber,
    totalAmountSystem,
    totalAmountSupplier,
    status,
    notes,
    createdAt,
    discountPercents,
    vatEnabled,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'supplier_received_invoices';
  @override
  VerificationContext validateIntegrity(
    Insertable<SupplierReceivedInvoice> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('supplier_id')) {
      context.handle(
        _supplierIdMeta,
        supplierId.isAcceptableOrUnknown(data['supplier_id']!, _supplierIdMeta),
      );
    } else if (isInserting) {
      context.missing(_supplierIdMeta);
    }
    if (data.containsKey('received_date')) {
      context.handle(
        _receivedDateMeta,
        receivedDate.isAcceptableOrUnknown(
          data['received_date']!,
          _receivedDateMeta,
        ),
      );
    }
    if (data.containsKey('reference_number')) {
      context.handle(
        _referenceNumberMeta,
        referenceNumber.isAcceptableOrUnknown(
          data['reference_number']!,
          _referenceNumberMeta,
        ),
      );
    }
    if (data.containsKey('total_amount_system')) {
      context.handle(
        _totalAmountSystemMeta,
        totalAmountSystem.isAcceptableOrUnknown(
          data['total_amount_system']!,
          _totalAmountSystemMeta,
        ),
      );
    }
    if (data.containsKey('total_amount_supplier')) {
      context.handle(
        _totalAmountSupplierMeta,
        totalAmountSupplier.isAcceptableOrUnknown(
          data['total_amount_supplier']!,
          _totalAmountSupplierMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('discount_percents')) {
      context.handle(
        _discountPercentsMeta,
        discountPercents.isAcceptableOrUnknown(
          data['discount_percents']!,
          _discountPercentsMeta,
        ),
      );
    }
    if (data.containsKey('vat_enabled')) {
      context.handle(
        _vatEnabledMeta,
        vatEnabled.isAcceptableOrUnknown(data['vat_enabled']!, _vatEnabledMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SupplierReceivedInvoice map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SupplierReceivedInvoice(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      supplierId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}supplier_id'],
      )!,
      receivedDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}received_date'],
      )!,
      referenceNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference_number'],
      ),
      totalAmountSystem: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_amount_system'],
      )!,
      totalAmountSupplier: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_amount_supplier'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      discountPercents: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}discount_percents'],
      ),
      vatEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}vat_enabled'],
      )!,
    );
  }

  @override
  $SupplierReceivedInvoicesTable createAlias(String alias) {
    return $SupplierReceivedInvoicesTable(attachedDatabase, alias);
  }
}

class SupplierReceivedInvoice extends DataClass
    implements Insertable<SupplierReceivedInvoice> {
  final String id;
  final String supplierId;
  final DateTime receivedDate;
  final String? referenceNumber;
  final double totalAmountSystem;
  final double totalAmountSupplier;
  final String status;
  final String? notes;
  final DateTime createdAt;
  final String? discountPercents;
  final bool vatEnabled;
  const SupplierReceivedInvoice({
    required this.id,
    required this.supplierId,
    required this.receivedDate,
    this.referenceNumber,
    required this.totalAmountSystem,
    required this.totalAmountSupplier,
    required this.status,
    this.notes,
    required this.createdAt,
    this.discountPercents,
    required this.vatEnabled,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['supplier_id'] = Variable<String>(supplierId);
    map['received_date'] = Variable<DateTime>(receivedDate);
    if (!nullToAbsent || referenceNumber != null) {
      map['reference_number'] = Variable<String>(referenceNumber);
    }
    map['total_amount_system'] = Variable<double>(totalAmountSystem);
    map['total_amount_supplier'] = Variable<double>(totalAmountSupplier);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || discountPercents != null) {
      map['discount_percents'] = Variable<String>(discountPercents);
    }
    map['vat_enabled'] = Variable<bool>(vatEnabled);
    return map;
  }

  SupplierReceivedInvoicesCompanion toCompanion(bool nullToAbsent) {
    return SupplierReceivedInvoicesCompanion(
      id: Value(id),
      supplierId: Value(supplierId),
      receivedDate: Value(receivedDate),
      referenceNumber: referenceNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(referenceNumber),
      totalAmountSystem: Value(totalAmountSystem),
      totalAmountSupplier: Value(totalAmountSupplier),
      status: Value(status),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
      discountPercents: discountPercents == null && nullToAbsent
          ? const Value.absent()
          : Value(discountPercents),
      vatEnabled: Value(vatEnabled),
    );
  }

  factory SupplierReceivedInvoice.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SupplierReceivedInvoice(
      id: serializer.fromJson<String>(json['id']),
      supplierId: serializer.fromJson<String>(json['supplierId']),
      receivedDate: serializer.fromJson<DateTime>(json['receivedDate']),
      referenceNumber: serializer.fromJson<String?>(json['referenceNumber']),
      totalAmountSystem: serializer.fromJson<double>(json['totalAmountSystem']),
      totalAmountSupplier: serializer.fromJson<double>(
        json['totalAmountSupplier'],
      ),
      status: serializer.fromJson<String>(json['status']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      discountPercents: serializer.fromJson<String?>(json['discountPercents']),
      vatEnabled: serializer.fromJson<bool>(json['vatEnabled']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'supplierId': serializer.toJson<String>(supplierId),
      'receivedDate': serializer.toJson<DateTime>(receivedDate),
      'referenceNumber': serializer.toJson<String?>(referenceNumber),
      'totalAmountSystem': serializer.toJson<double>(totalAmountSystem),
      'totalAmountSupplier': serializer.toJson<double>(totalAmountSupplier),
      'status': serializer.toJson<String>(status),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'discountPercents': serializer.toJson<String?>(discountPercents),
      'vatEnabled': serializer.toJson<bool>(vatEnabled),
    };
  }

  SupplierReceivedInvoice copyWith({
    String? id,
    String? supplierId,
    DateTime? receivedDate,
    Value<String?> referenceNumber = const Value.absent(),
    double? totalAmountSystem,
    double? totalAmountSupplier,
    String? status,
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
    Value<String?> discountPercents = const Value.absent(),
    bool? vatEnabled,
  }) => SupplierReceivedInvoice(
    id: id ?? this.id,
    supplierId: supplierId ?? this.supplierId,
    receivedDate: receivedDate ?? this.receivedDate,
    referenceNumber: referenceNumber.present
        ? referenceNumber.value
        : this.referenceNumber,
    totalAmountSystem: totalAmountSystem ?? this.totalAmountSystem,
    totalAmountSupplier: totalAmountSupplier ?? this.totalAmountSupplier,
    status: status ?? this.status,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
    discountPercents: discountPercents.present
        ? discountPercents.value
        : this.discountPercents,
    vatEnabled: vatEnabled ?? this.vatEnabled,
  );
  SupplierReceivedInvoice copyWithCompanion(
    SupplierReceivedInvoicesCompanion data,
  ) {
    return SupplierReceivedInvoice(
      id: data.id.present ? data.id.value : this.id,
      supplierId: data.supplierId.present
          ? data.supplierId.value
          : this.supplierId,
      receivedDate: data.receivedDate.present
          ? data.receivedDate.value
          : this.receivedDate,
      referenceNumber: data.referenceNumber.present
          ? data.referenceNumber.value
          : this.referenceNumber,
      totalAmountSystem: data.totalAmountSystem.present
          ? data.totalAmountSystem.value
          : this.totalAmountSystem,
      totalAmountSupplier: data.totalAmountSupplier.present
          ? data.totalAmountSupplier.value
          : this.totalAmountSupplier,
      status: data.status.present ? data.status.value : this.status,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      discountPercents: data.discountPercents.present
          ? data.discountPercents.value
          : this.discountPercents,
      vatEnabled: data.vatEnabled.present
          ? data.vatEnabled.value
          : this.vatEnabled,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SupplierReceivedInvoice(')
          ..write('id: $id, ')
          ..write('supplierId: $supplierId, ')
          ..write('receivedDate: $receivedDate, ')
          ..write('referenceNumber: $referenceNumber, ')
          ..write('totalAmountSystem: $totalAmountSystem, ')
          ..write('totalAmountSupplier: $totalAmountSupplier, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('discountPercents: $discountPercents, ')
          ..write('vatEnabled: $vatEnabled')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    supplierId,
    receivedDate,
    referenceNumber,
    totalAmountSystem,
    totalAmountSupplier,
    status,
    notes,
    createdAt,
    discountPercents,
    vatEnabled,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SupplierReceivedInvoice &&
          other.id == this.id &&
          other.supplierId == this.supplierId &&
          other.receivedDate == this.receivedDate &&
          other.referenceNumber == this.referenceNumber &&
          other.totalAmountSystem == this.totalAmountSystem &&
          other.totalAmountSupplier == this.totalAmountSupplier &&
          other.status == this.status &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.discountPercents == this.discountPercents &&
          other.vatEnabled == this.vatEnabled);
}

class SupplierReceivedInvoicesCompanion
    extends UpdateCompanion<SupplierReceivedInvoice> {
  final Value<String> id;
  final Value<String> supplierId;
  final Value<DateTime> receivedDate;
  final Value<String?> referenceNumber;
  final Value<double> totalAmountSystem;
  final Value<double> totalAmountSupplier;
  final Value<String> status;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<String?> discountPercents;
  final Value<bool> vatEnabled;
  final Value<int> rowid;
  const SupplierReceivedInvoicesCompanion({
    this.id = const Value.absent(),
    this.supplierId = const Value.absent(),
    this.receivedDate = const Value.absent(),
    this.referenceNumber = const Value.absent(),
    this.totalAmountSystem = const Value.absent(),
    this.totalAmountSupplier = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.discountPercents = const Value.absent(),
    this.vatEnabled = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SupplierReceivedInvoicesCompanion.insert({
    required String id,
    required String supplierId,
    this.receivedDate = const Value.absent(),
    this.referenceNumber = const Value.absent(),
    this.totalAmountSystem = const Value.absent(),
    this.totalAmountSupplier = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.discountPercents = const Value.absent(),
    this.vatEnabled = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       supplierId = Value(supplierId);
  static Insertable<SupplierReceivedInvoice> custom({
    Expression<String>? id,
    Expression<String>? supplierId,
    Expression<DateTime>? receivedDate,
    Expression<String>? referenceNumber,
    Expression<double>? totalAmountSystem,
    Expression<double>? totalAmountSupplier,
    Expression<String>? status,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<String>? discountPercents,
    Expression<bool>? vatEnabled,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (supplierId != null) 'supplier_id': supplierId,
      if (receivedDate != null) 'received_date': receivedDate,
      if (referenceNumber != null) 'reference_number': referenceNumber,
      if (totalAmountSystem != null) 'total_amount_system': totalAmountSystem,
      if (totalAmountSupplier != null)
        'total_amount_supplier': totalAmountSupplier,
      if (status != null) 'status': status,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (discountPercents != null) 'discount_percents': discountPercents,
      if (vatEnabled != null) 'vat_enabled': vatEnabled,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SupplierReceivedInvoicesCompanion copyWith({
    Value<String>? id,
    Value<String>? supplierId,
    Value<DateTime>? receivedDate,
    Value<String?>? referenceNumber,
    Value<double>? totalAmountSystem,
    Value<double>? totalAmountSupplier,
    Value<String>? status,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
    Value<String?>? discountPercents,
    Value<bool>? vatEnabled,
    Value<int>? rowid,
  }) {
    return SupplierReceivedInvoicesCompanion(
      id: id ?? this.id,
      supplierId: supplierId ?? this.supplierId,
      receivedDate: receivedDate ?? this.receivedDate,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      totalAmountSystem: totalAmountSystem ?? this.totalAmountSystem,
      totalAmountSupplier: totalAmountSupplier ?? this.totalAmountSupplier,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      discountPercents: discountPercents ?? this.discountPercents,
      vatEnabled: vatEnabled ?? this.vatEnabled,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (supplierId.present) {
      map['supplier_id'] = Variable<String>(supplierId.value);
    }
    if (receivedDate.present) {
      map['received_date'] = Variable<DateTime>(receivedDate.value);
    }
    if (referenceNumber.present) {
      map['reference_number'] = Variable<String>(referenceNumber.value);
    }
    if (totalAmountSystem.present) {
      map['total_amount_system'] = Variable<double>(totalAmountSystem.value);
    }
    if (totalAmountSupplier.present) {
      map['total_amount_supplier'] = Variable<double>(
        totalAmountSupplier.value,
      );
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (discountPercents.present) {
      map['discount_percents'] = Variable<String>(discountPercents.value);
    }
    if (vatEnabled.present) {
      map['vat_enabled'] = Variable<bool>(vatEnabled.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SupplierReceivedInvoicesCompanion(')
          ..write('id: $id, ')
          ..write('supplierId: $supplierId, ')
          ..write('receivedDate: $receivedDate, ')
          ..write('referenceNumber: $referenceNumber, ')
          ..write('totalAmountSystem: $totalAmountSystem, ')
          ..write('totalAmountSupplier: $totalAmountSupplier, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('discountPercents: $discountPercents, ')
          ..write('vatEnabled: $vatEnabled, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SupplierReceivedInvoiceItemsTable extends SupplierReceivedInvoiceItems
    with
        TableInfo<
          $SupplierReceivedInvoiceItemsTable,
          SupplierReceivedInvoiceItem
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SupplierReceivedInvoiceItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _receivedInvoiceIdMeta = const VerificationMeta(
    'receivedInvoiceId',
  );
  @override
  late final GeneratedColumn<String> receivedInvoiceId =
      GeneratedColumn<String>(
        'received_invoice_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES supplier_received_invoices (id)',
        ),
      );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES products (id)',
    ),
  );
  static const VerificationMeta _unitTypeMeta = const VerificationMeta(
    'unitType',
  );
  @override
  late final GeneratedColumn<String> unitType = GeneratedColumn<String>(
    'unit_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _systemPriceMeta = const VerificationMeta(
    'systemPrice',
  );
  @override
  late final GeneratedColumn<double> systemPrice = GeneratedColumn<double>(
    'system_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _supplierPriceMeta = const VerificationMeta(
    'supplierPrice',
  );
  @override
  late final GeneratedColumn<double> supplierPrice = GeneratedColumn<double>(
    'supplier_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subtotalSystemMeta = const VerificationMeta(
    'subtotalSystem',
  );
  @override
  late final GeneratedColumn<double> subtotalSystem = GeneratedColumn<double>(
    'subtotal_system',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subtotalSupplierMeta = const VerificationMeta(
    'subtotalSupplier',
  );
  @override
  late final GeneratedColumn<double> subtotalSupplier = GeneratedColumn<double>(
    'subtotal_supplier',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isFreeMeta = const VerificationMeta('isFree');
  @override
  late final GeneratedColumn<bool> isFree = GeneratedColumn<bool>(
    'is_free',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_free" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _rawSupplierPriceMeta = const VerificationMeta(
    'rawSupplierPrice',
  );
  @override
  late final GeneratedColumn<double> rawSupplierPrice = GeneratedColumn<double>(
    'raw_supplier_price',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    receivedInvoiceId,
    productId,
    unitType,
    quantity,
    systemPrice,
    supplierPrice,
    subtotalSystem,
    subtotalSupplier,
    isFree,
    rawSupplierPrice,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'supplier_received_invoice_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<SupplierReceivedInvoiceItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('received_invoice_id')) {
      context.handle(
        _receivedInvoiceIdMeta,
        receivedInvoiceId.isAcceptableOrUnknown(
          data['received_invoice_id']!,
          _receivedInvoiceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_receivedInvoiceIdMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('unit_type')) {
      context.handle(
        _unitTypeMeta,
        unitType.isAcceptableOrUnknown(data['unit_type']!, _unitTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_unitTypeMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('system_price')) {
      context.handle(
        _systemPriceMeta,
        systemPrice.isAcceptableOrUnknown(
          data['system_price']!,
          _systemPriceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_systemPriceMeta);
    }
    if (data.containsKey('supplier_price')) {
      context.handle(
        _supplierPriceMeta,
        supplierPrice.isAcceptableOrUnknown(
          data['supplier_price']!,
          _supplierPriceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_supplierPriceMeta);
    }
    if (data.containsKey('subtotal_system')) {
      context.handle(
        _subtotalSystemMeta,
        subtotalSystem.isAcceptableOrUnknown(
          data['subtotal_system']!,
          _subtotalSystemMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_subtotalSystemMeta);
    }
    if (data.containsKey('subtotal_supplier')) {
      context.handle(
        _subtotalSupplierMeta,
        subtotalSupplier.isAcceptableOrUnknown(
          data['subtotal_supplier']!,
          _subtotalSupplierMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_subtotalSupplierMeta);
    }
    if (data.containsKey('is_free')) {
      context.handle(
        _isFreeMeta,
        isFree.isAcceptableOrUnknown(data['is_free']!, _isFreeMeta),
      );
    }
    if (data.containsKey('raw_supplier_price')) {
      context.handle(
        _rawSupplierPriceMeta,
        rawSupplierPrice.isAcceptableOrUnknown(
          data['raw_supplier_price']!,
          _rawSupplierPriceMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SupplierReceivedInvoiceItem map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SupplierReceivedInvoiceItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      receivedInvoiceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}received_invoice_id'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      )!,
      unitType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit_type'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      )!,
      systemPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}system_price'],
      )!,
      supplierPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}supplier_price'],
      )!,
      subtotalSystem: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}subtotal_system'],
      )!,
      subtotalSupplier: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}subtotal_supplier'],
      )!,
      isFree: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_free'],
      )!,
      rawSupplierPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}raw_supplier_price'],
      ),
    );
  }

  @override
  $SupplierReceivedInvoiceItemsTable createAlias(String alias) {
    return $SupplierReceivedInvoiceItemsTable(attachedDatabase, alias);
  }
}

class SupplierReceivedInvoiceItem extends DataClass
    implements Insertable<SupplierReceivedInvoiceItem> {
  final String id;
  final String receivedInvoiceId;
  final String productId;
  final String unitType;
  final int quantity;
  final double systemPrice;
  final double supplierPrice;
  final double subtotalSystem;
  final double subtotalSupplier;
  final bool isFree;
  final double? rawSupplierPrice;
  const SupplierReceivedInvoiceItem({
    required this.id,
    required this.receivedInvoiceId,
    required this.productId,
    required this.unitType,
    required this.quantity,
    required this.systemPrice,
    required this.supplierPrice,
    required this.subtotalSystem,
    required this.subtotalSupplier,
    required this.isFree,
    this.rawSupplierPrice,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['received_invoice_id'] = Variable<String>(receivedInvoiceId);
    map['product_id'] = Variable<String>(productId);
    map['unit_type'] = Variable<String>(unitType);
    map['quantity'] = Variable<int>(quantity);
    map['system_price'] = Variable<double>(systemPrice);
    map['supplier_price'] = Variable<double>(supplierPrice);
    map['subtotal_system'] = Variable<double>(subtotalSystem);
    map['subtotal_supplier'] = Variable<double>(subtotalSupplier);
    map['is_free'] = Variable<bool>(isFree);
    if (!nullToAbsent || rawSupplierPrice != null) {
      map['raw_supplier_price'] = Variable<double>(rawSupplierPrice);
    }
    return map;
  }

  SupplierReceivedInvoiceItemsCompanion toCompanion(bool nullToAbsent) {
    return SupplierReceivedInvoiceItemsCompanion(
      id: Value(id),
      receivedInvoiceId: Value(receivedInvoiceId),
      productId: Value(productId),
      unitType: Value(unitType),
      quantity: Value(quantity),
      systemPrice: Value(systemPrice),
      supplierPrice: Value(supplierPrice),
      subtotalSystem: Value(subtotalSystem),
      subtotalSupplier: Value(subtotalSupplier),
      isFree: Value(isFree),
      rawSupplierPrice: rawSupplierPrice == null && nullToAbsent
          ? const Value.absent()
          : Value(rawSupplierPrice),
    );
  }

  factory SupplierReceivedInvoiceItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SupplierReceivedInvoiceItem(
      id: serializer.fromJson<String>(json['id']),
      receivedInvoiceId: serializer.fromJson<String>(json['receivedInvoiceId']),
      productId: serializer.fromJson<String>(json['productId']),
      unitType: serializer.fromJson<String>(json['unitType']),
      quantity: serializer.fromJson<int>(json['quantity']),
      systemPrice: serializer.fromJson<double>(json['systemPrice']),
      supplierPrice: serializer.fromJson<double>(json['supplierPrice']),
      subtotalSystem: serializer.fromJson<double>(json['subtotalSystem']),
      subtotalSupplier: serializer.fromJson<double>(json['subtotalSupplier']),
      isFree: serializer.fromJson<bool>(json['isFree']),
      rawSupplierPrice: serializer.fromJson<double?>(json['rawSupplierPrice']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'receivedInvoiceId': serializer.toJson<String>(receivedInvoiceId),
      'productId': serializer.toJson<String>(productId),
      'unitType': serializer.toJson<String>(unitType),
      'quantity': serializer.toJson<int>(quantity),
      'systemPrice': serializer.toJson<double>(systemPrice),
      'supplierPrice': serializer.toJson<double>(supplierPrice),
      'subtotalSystem': serializer.toJson<double>(subtotalSystem),
      'subtotalSupplier': serializer.toJson<double>(subtotalSupplier),
      'isFree': serializer.toJson<bool>(isFree),
      'rawSupplierPrice': serializer.toJson<double?>(rawSupplierPrice),
    };
  }

  SupplierReceivedInvoiceItem copyWith({
    String? id,
    String? receivedInvoiceId,
    String? productId,
    String? unitType,
    int? quantity,
    double? systemPrice,
    double? supplierPrice,
    double? subtotalSystem,
    double? subtotalSupplier,
    bool? isFree,
    Value<double?> rawSupplierPrice = const Value.absent(),
  }) => SupplierReceivedInvoiceItem(
    id: id ?? this.id,
    receivedInvoiceId: receivedInvoiceId ?? this.receivedInvoiceId,
    productId: productId ?? this.productId,
    unitType: unitType ?? this.unitType,
    quantity: quantity ?? this.quantity,
    systemPrice: systemPrice ?? this.systemPrice,
    supplierPrice: supplierPrice ?? this.supplierPrice,
    subtotalSystem: subtotalSystem ?? this.subtotalSystem,
    subtotalSupplier: subtotalSupplier ?? this.subtotalSupplier,
    isFree: isFree ?? this.isFree,
    rawSupplierPrice: rawSupplierPrice.present
        ? rawSupplierPrice.value
        : this.rawSupplierPrice,
  );
  SupplierReceivedInvoiceItem copyWithCompanion(
    SupplierReceivedInvoiceItemsCompanion data,
  ) {
    return SupplierReceivedInvoiceItem(
      id: data.id.present ? data.id.value : this.id,
      receivedInvoiceId: data.receivedInvoiceId.present
          ? data.receivedInvoiceId.value
          : this.receivedInvoiceId,
      productId: data.productId.present ? data.productId.value : this.productId,
      unitType: data.unitType.present ? data.unitType.value : this.unitType,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      systemPrice: data.systemPrice.present
          ? data.systemPrice.value
          : this.systemPrice,
      supplierPrice: data.supplierPrice.present
          ? data.supplierPrice.value
          : this.supplierPrice,
      subtotalSystem: data.subtotalSystem.present
          ? data.subtotalSystem.value
          : this.subtotalSystem,
      subtotalSupplier: data.subtotalSupplier.present
          ? data.subtotalSupplier.value
          : this.subtotalSupplier,
      isFree: data.isFree.present ? data.isFree.value : this.isFree,
      rawSupplierPrice: data.rawSupplierPrice.present
          ? data.rawSupplierPrice.value
          : this.rawSupplierPrice,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SupplierReceivedInvoiceItem(')
          ..write('id: $id, ')
          ..write('receivedInvoiceId: $receivedInvoiceId, ')
          ..write('productId: $productId, ')
          ..write('unitType: $unitType, ')
          ..write('quantity: $quantity, ')
          ..write('systemPrice: $systemPrice, ')
          ..write('supplierPrice: $supplierPrice, ')
          ..write('subtotalSystem: $subtotalSystem, ')
          ..write('subtotalSupplier: $subtotalSupplier, ')
          ..write('isFree: $isFree, ')
          ..write('rawSupplierPrice: $rawSupplierPrice')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    receivedInvoiceId,
    productId,
    unitType,
    quantity,
    systemPrice,
    supplierPrice,
    subtotalSystem,
    subtotalSupplier,
    isFree,
    rawSupplierPrice,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SupplierReceivedInvoiceItem &&
          other.id == this.id &&
          other.receivedInvoiceId == this.receivedInvoiceId &&
          other.productId == this.productId &&
          other.unitType == this.unitType &&
          other.quantity == this.quantity &&
          other.systemPrice == this.systemPrice &&
          other.supplierPrice == this.supplierPrice &&
          other.subtotalSystem == this.subtotalSystem &&
          other.subtotalSupplier == this.subtotalSupplier &&
          other.isFree == this.isFree &&
          other.rawSupplierPrice == this.rawSupplierPrice);
}

class SupplierReceivedInvoiceItemsCompanion
    extends UpdateCompanion<SupplierReceivedInvoiceItem> {
  final Value<String> id;
  final Value<String> receivedInvoiceId;
  final Value<String> productId;
  final Value<String> unitType;
  final Value<int> quantity;
  final Value<double> systemPrice;
  final Value<double> supplierPrice;
  final Value<double> subtotalSystem;
  final Value<double> subtotalSupplier;
  final Value<bool> isFree;
  final Value<double?> rawSupplierPrice;
  final Value<int> rowid;
  const SupplierReceivedInvoiceItemsCompanion({
    this.id = const Value.absent(),
    this.receivedInvoiceId = const Value.absent(),
    this.productId = const Value.absent(),
    this.unitType = const Value.absent(),
    this.quantity = const Value.absent(),
    this.systemPrice = const Value.absent(),
    this.supplierPrice = const Value.absent(),
    this.subtotalSystem = const Value.absent(),
    this.subtotalSupplier = const Value.absent(),
    this.isFree = const Value.absent(),
    this.rawSupplierPrice = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SupplierReceivedInvoiceItemsCompanion.insert({
    required String id,
    required String receivedInvoiceId,
    required String productId,
    required String unitType,
    required int quantity,
    required double systemPrice,
    required double supplierPrice,
    required double subtotalSystem,
    required double subtotalSupplier,
    this.isFree = const Value.absent(),
    this.rawSupplierPrice = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       receivedInvoiceId = Value(receivedInvoiceId),
       productId = Value(productId),
       unitType = Value(unitType),
       quantity = Value(quantity),
       systemPrice = Value(systemPrice),
       supplierPrice = Value(supplierPrice),
       subtotalSystem = Value(subtotalSystem),
       subtotalSupplier = Value(subtotalSupplier);
  static Insertable<SupplierReceivedInvoiceItem> custom({
    Expression<String>? id,
    Expression<String>? receivedInvoiceId,
    Expression<String>? productId,
    Expression<String>? unitType,
    Expression<int>? quantity,
    Expression<double>? systemPrice,
    Expression<double>? supplierPrice,
    Expression<double>? subtotalSystem,
    Expression<double>? subtotalSupplier,
    Expression<bool>? isFree,
    Expression<double>? rawSupplierPrice,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (receivedInvoiceId != null) 'received_invoice_id': receivedInvoiceId,
      if (productId != null) 'product_id': productId,
      if (unitType != null) 'unit_type': unitType,
      if (quantity != null) 'quantity': quantity,
      if (systemPrice != null) 'system_price': systemPrice,
      if (supplierPrice != null) 'supplier_price': supplierPrice,
      if (subtotalSystem != null) 'subtotal_system': subtotalSystem,
      if (subtotalSupplier != null) 'subtotal_supplier': subtotalSupplier,
      if (isFree != null) 'is_free': isFree,
      if (rawSupplierPrice != null) 'raw_supplier_price': rawSupplierPrice,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SupplierReceivedInvoiceItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? receivedInvoiceId,
    Value<String>? productId,
    Value<String>? unitType,
    Value<int>? quantity,
    Value<double>? systemPrice,
    Value<double>? supplierPrice,
    Value<double>? subtotalSystem,
    Value<double>? subtotalSupplier,
    Value<bool>? isFree,
    Value<double?>? rawSupplierPrice,
    Value<int>? rowid,
  }) {
    return SupplierReceivedInvoiceItemsCompanion(
      id: id ?? this.id,
      receivedInvoiceId: receivedInvoiceId ?? this.receivedInvoiceId,
      productId: productId ?? this.productId,
      unitType: unitType ?? this.unitType,
      quantity: quantity ?? this.quantity,
      systemPrice: systemPrice ?? this.systemPrice,
      supplierPrice: supplierPrice ?? this.supplierPrice,
      subtotalSystem: subtotalSystem ?? this.subtotalSystem,
      subtotalSupplier: subtotalSupplier ?? this.subtotalSupplier,
      isFree: isFree ?? this.isFree,
      rawSupplierPrice: rawSupplierPrice ?? this.rawSupplierPrice,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (receivedInvoiceId.present) {
      map['received_invoice_id'] = Variable<String>(receivedInvoiceId.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (unitType.present) {
      map['unit_type'] = Variable<String>(unitType.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (systemPrice.present) {
      map['system_price'] = Variable<double>(systemPrice.value);
    }
    if (supplierPrice.present) {
      map['supplier_price'] = Variable<double>(supplierPrice.value);
    }
    if (subtotalSystem.present) {
      map['subtotal_system'] = Variable<double>(subtotalSystem.value);
    }
    if (subtotalSupplier.present) {
      map['subtotal_supplier'] = Variable<double>(subtotalSupplier.value);
    }
    if (isFree.present) {
      map['is_free'] = Variable<bool>(isFree.value);
    }
    if (rawSupplierPrice.present) {
      map['raw_supplier_price'] = Variable<double>(rawSupplierPrice.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SupplierReceivedInvoiceItemsCompanion(')
          ..write('id: $id, ')
          ..write('receivedInvoiceId: $receivedInvoiceId, ')
          ..write('productId: $productId, ')
          ..write('unitType: $unitType, ')
          ..write('quantity: $quantity, ')
          ..write('systemPrice: $systemPrice, ')
          ..write('supplierPrice: $supplierPrice, ')
          ..write('subtotalSystem: $subtotalSystem, ')
          ..write('subtotalSupplier: $subtotalSupplier, ')
          ..write('isFree: $isFree, ')
          ..write('rawSupplierPrice: $rawSupplierPrice, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PurchaseOrdersTable extends PurchaseOrders
    with TableInfo<$PurchaseOrdersTable, PurchaseOrder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PurchaseOrdersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _supplierIdMeta = const VerificationMeta(
    'supplierId',
  );
  @override
  late final GeneratedColumn<String> supplierId = GeneratedColumn<String>(
    'supplier_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES suppliers (id)',
    ),
  );
  static const VerificationMeta _orderDateMeta = const VerificationMeta(
    'orderDate',
  );
  @override
  late final GeneratedColumn<DateTime> orderDate = GeneratedColumn<DateTime>(
    'order_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _referenceNumberMeta = const VerificationMeta(
    'referenceNumber',
  );
  @override
  late final GeneratedColumn<String> referenceNumber = GeneratedColumn<String>(
    'reference_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalAmountMeta = const VerificationMeta(
    'totalAmount',
  );
  @override
  late final GeneratedColumn<double> totalAmount = GeneratedColumn<double>(
    'total_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('open'),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _discountPercentsMeta = const VerificationMeta(
    'discountPercents',
  );
  @override
  late final GeneratedColumn<String> discountPercents = GeneratedColumn<String>(
    'discount_percents',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _vatEnabledMeta = const VerificationMeta(
    'vatEnabled',
  );
  @override
  late final GeneratedColumn<bool> vatEnabled = GeneratedColumn<bool>(
    'vat_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("vat_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _preparedByMeta = const VerificationMeta(
    'preparedBy',
  );
  @override
  late final GeneratedColumn<String> preparedBy = GeneratedColumn<String>(
    'prepared_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    supplierId,
    orderDate,
    referenceNumber,
    totalAmount,
    status,
    notes,
    createdAt,
    discountPercents,
    vatEnabled,
    preparedBy,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'purchase_orders';
  @override
  VerificationContext validateIntegrity(
    Insertable<PurchaseOrder> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('supplier_id')) {
      context.handle(
        _supplierIdMeta,
        supplierId.isAcceptableOrUnknown(data['supplier_id']!, _supplierIdMeta),
      );
    } else if (isInserting) {
      context.missing(_supplierIdMeta);
    }
    if (data.containsKey('order_date')) {
      context.handle(
        _orderDateMeta,
        orderDate.isAcceptableOrUnknown(data['order_date']!, _orderDateMeta),
      );
    }
    if (data.containsKey('reference_number')) {
      context.handle(
        _referenceNumberMeta,
        referenceNumber.isAcceptableOrUnknown(
          data['reference_number']!,
          _referenceNumberMeta,
        ),
      );
    }
    if (data.containsKey('total_amount')) {
      context.handle(
        _totalAmountMeta,
        totalAmount.isAcceptableOrUnknown(
          data['total_amount']!,
          _totalAmountMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('discount_percents')) {
      context.handle(
        _discountPercentsMeta,
        discountPercents.isAcceptableOrUnknown(
          data['discount_percents']!,
          _discountPercentsMeta,
        ),
      );
    }
    if (data.containsKey('vat_enabled')) {
      context.handle(
        _vatEnabledMeta,
        vatEnabled.isAcceptableOrUnknown(data['vat_enabled']!, _vatEnabledMeta),
      );
    }
    if (data.containsKey('prepared_by')) {
      context.handle(
        _preparedByMeta,
        preparedBy.isAcceptableOrUnknown(data['prepared_by']!, _preparedByMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PurchaseOrder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PurchaseOrder(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      supplierId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}supplier_id'],
      )!,
      orderDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}order_date'],
      )!,
      referenceNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference_number'],
      ),
      totalAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_amount'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      discountPercents: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}discount_percents'],
      ),
      vatEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}vat_enabled'],
      )!,
      preparedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prepared_by'],
      ),
    );
  }

  @override
  $PurchaseOrdersTable createAlias(String alias) {
    return $PurchaseOrdersTable(attachedDatabase, alias);
  }
}

class PurchaseOrder extends DataClass implements Insertable<PurchaseOrder> {
  final String id;
  final String supplierId;
  final DateTime orderDate;
  final String? referenceNumber;
  final double totalAmount;
  final String status;
  final String? notes;
  final DateTime createdAt;
  final String? discountPercents;
  final bool vatEnabled;
  final String? preparedBy;
  const PurchaseOrder({
    required this.id,
    required this.supplierId,
    required this.orderDate,
    this.referenceNumber,
    required this.totalAmount,
    required this.status,
    this.notes,
    required this.createdAt,
    this.discountPercents,
    required this.vatEnabled,
    this.preparedBy,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['supplier_id'] = Variable<String>(supplierId);
    map['order_date'] = Variable<DateTime>(orderDate);
    if (!nullToAbsent || referenceNumber != null) {
      map['reference_number'] = Variable<String>(referenceNumber);
    }
    map['total_amount'] = Variable<double>(totalAmount);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || discountPercents != null) {
      map['discount_percents'] = Variable<String>(discountPercents);
    }
    map['vat_enabled'] = Variable<bool>(vatEnabled);
    if (!nullToAbsent || preparedBy != null) {
      map['prepared_by'] = Variable<String>(preparedBy);
    }
    return map;
  }

  PurchaseOrdersCompanion toCompanion(bool nullToAbsent) {
    return PurchaseOrdersCompanion(
      id: Value(id),
      supplierId: Value(supplierId),
      orderDate: Value(orderDate),
      referenceNumber: referenceNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(referenceNumber),
      totalAmount: Value(totalAmount),
      status: Value(status),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
      discountPercents: discountPercents == null && nullToAbsent
          ? const Value.absent()
          : Value(discountPercents),
      vatEnabled: Value(vatEnabled),
      preparedBy: preparedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(preparedBy),
    );
  }

  factory PurchaseOrder.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PurchaseOrder(
      id: serializer.fromJson<String>(json['id']),
      supplierId: serializer.fromJson<String>(json['supplierId']),
      orderDate: serializer.fromJson<DateTime>(json['orderDate']),
      referenceNumber: serializer.fromJson<String?>(json['referenceNumber']),
      totalAmount: serializer.fromJson<double>(json['totalAmount']),
      status: serializer.fromJson<String>(json['status']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      discountPercents: serializer.fromJson<String?>(json['discountPercents']),
      vatEnabled: serializer.fromJson<bool>(json['vatEnabled']),
      preparedBy: serializer.fromJson<String?>(json['preparedBy']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'supplierId': serializer.toJson<String>(supplierId),
      'orderDate': serializer.toJson<DateTime>(orderDate),
      'referenceNumber': serializer.toJson<String?>(referenceNumber),
      'totalAmount': serializer.toJson<double>(totalAmount),
      'status': serializer.toJson<String>(status),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'discountPercents': serializer.toJson<String?>(discountPercents),
      'vatEnabled': serializer.toJson<bool>(vatEnabled),
      'preparedBy': serializer.toJson<String?>(preparedBy),
    };
  }

  PurchaseOrder copyWith({
    String? id,
    String? supplierId,
    DateTime? orderDate,
    Value<String?> referenceNumber = const Value.absent(),
    double? totalAmount,
    String? status,
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
    Value<String?> discountPercents = const Value.absent(),
    bool? vatEnabled,
    Value<String?> preparedBy = const Value.absent(),
  }) => PurchaseOrder(
    id: id ?? this.id,
    supplierId: supplierId ?? this.supplierId,
    orderDate: orderDate ?? this.orderDate,
    referenceNumber: referenceNumber.present
        ? referenceNumber.value
        : this.referenceNumber,
    totalAmount: totalAmount ?? this.totalAmount,
    status: status ?? this.status,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
    discountPercents: discountPercents.present
        ? discountPercents.value
        : this.discountPercents,
    vatEnabled: vatEnabled ?? this.vatEnabled,
    preparedBy: preparedBy.present ? preparedBy.value : this.preparedBy,
  );
  PurchaseOrder copyWithCompanion(PurchaseOrdersCompanion data) {
    return PurchaseOrder(
      id: data.id.present ? data.id.value : this.id,
      supplierId: data.supplierId.present
          ? data.supplierId.value
          : this.supplierId,
      orderDate: data.orderDate.present ? data.orderDate.value : this.orderDate,
      referenceNumber: data.referenceNumber.present
          ? data.referenceNumber.value
          : this.referenceNumber,
      totalAmount: data.totalAmount.present
          ? data.totalAmount.value
          : this.totalAmount,
      status: data.status.present ? data.status.value : this.status,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      discountPercents: data.discountPercents.present
          ? data.discountPercents.value
          : this.discountPercents,
      vatEnabled: data.vatEnabled.present
          ? data.vatEnabled.value
          : this.vatEnabled,
      preparedBy: data.preparedBy.present
          ? data.preparedBy.value
          : this.preparedBy,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PurchaseOrder(')
          ..write('id: $id, ')
          ..write('supplierId: $supplierId, ')
          ..write('orderDate: $orderDate, ')
          ..write('referenceNumber: $referenceNumber, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('discountPercents: $discountPercents, ')
          ..write('vatEnabled: $vatEnabled, ')
          ..write('preparedBy: $preparedBy')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    supplierId,
    orderDate,
    referenceNumber,
    totalAmount,
    status,
    notes,
    createdAt,
    discountPercents,
    vatEnabled,
    preparedBy,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PurchaseOrder &&
          other.id == this.id &&
          other.supplierId == this.supplierId &&
          other.orderDate == this.orderDate &&
          other.referenceNumber == this.referenceNumber &&
          other.totalAmount == this.totalAmount &&
          other.status == this.status &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.discountPercents == this.discountPercents &&
          other.vatEnabled == this.vatEnabled &&
          other.preparedBy == this.preparedBy);
}

class PurchaseOrdersCompanion extends UpdateCompanion<PurchaseOrder> {
  final Value<String> id;
  final Value<String> supplierId;
  final Value<DateTime> orderDate;
  final Value<String?> referenceNumber;
  final Value<double> totalAmount;
  final Value<String> status;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<String?> discountPercents;
  final Value<bool> vatEnabled;
  final Value<String?> preparedBy;
  final Value<int> rowid;
  const PurchaseOrdersCompanion({
    this.id = const Value.absent(),
    this.supplierId = const Value.absent(),
    this.orderDate = const Value.absent(),
    this.referenceNumber = const Value.absent(),
    this.totalAmount = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.discountPercents = const Value.absent(),
    this.vatEnabled = const Value.absent(),
    this.preparedBy = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PurchaseOrdersCompanion.insert({
    required String id,
    required String supplierId,
    this.orderDate = const Value.absent(),
    this.referenceNumber = const Value.absent(),
    this.totalAmount = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.discountPercents = const Value.absent(),
    this.vatEnabled = const Value.absent(),
    this.preparedBy = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       supplierId = Value(supplierId);
  static Insertable<PurchaseOrder> custom({
    Expression<String>? id,
    Expression<String>? supplierId,
    Expression<DateTime>? orderDate,
    Expression<String>? referenceNumber,
    Expression<double>? totalAmount,
    Expression<String>? status,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<String>? discountPercents,
    Expression<bool>? vatEnabled,
    Expression<String>? preparedBy,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (supplierId != null) 'supplier_id': supplierId,
      if (orderDate != null) 'order_date': orderDate,
      if (referenceNumber != null) 'reference_number': referenceNumber,
      if (totalAmount != null) 'total_amount': totalAmount,
      if (status != null) 'status': status,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (discountPercents != null) 'discount_percents': discountPercents,
      if (vatEnabled != null) 'vat_enabled': vatEnabled,
      if (preparedBy != null) 'prepared_by': preparedBy,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PurchaseOrdersCompanion copyWith({
    Value<String>? id,
    Value<String>? supplierId,
    Value<DateTime>? orderDate,
    Value<String?>? referenceNumber,
    Value<double>? totalAmount,
    Value<String>? status,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
    Value<String?>? discountPercents,
    Value<bool>? vatEnabled,
    Value<String?>? preparedBy,
    Value<int>? rowid,
  }) {
    return PurchaseOrdersCompanion(
      id: id ?? this.id,
      supplierId: supplierId ?? this.supplierId,
      orderDate: orderDate ?? this.orderDate,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      discountPercents: discountPercents ?? this.discountPercents,
      vatEnabled: vatEnabled ?? this.vatEnabled,
      preparedBy: preparedBy ?? this.preparedBy,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (supplierId.present) {
      map['supplier_id'] = Variable<String>(supplierId.value);
    }
    if (orderDate.present) {
      map['order_date'] = Variable<DateTime>(orderDate.value);
    }
    if (referenceNumber.present) {
      map['reference_number'] = Variable<String>(referenceNumber.value);
    }
    if (totalAmount.present) {
      map['total_amount'] = Variable<double>(totalAmount.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (discountPercents.present) {
      map['discount_percents'] = Variable<String>(discountPercents.value);
    }
    if (vatEnabled.present) {
      map['vat_enabled'] = Variable<bool>(vatEnabled.value);
    }
    if (preparedBy.present) {
      map['prepared_by'] = Variable<String>(preparedBy.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PurchaseOrdersCompanion(')
          ..write('id: $id, ')
          ..write('supplierId: $supplierId, ')
          ..write('orderDate: $orderDate, ')
          ..write('referenceNumber: $referenceNumber, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('discountPercents: $discountPercents, ')
          ..write('vatEnabled: $vatEnabled, ')
          ..write('preparedBy: $preparedBy, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PurchaseOrderItemsTable extends PurchaseOrderItems
    with TableInfo<$PurchaseOrderItemsTable, PurchaseOrderItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PurchaseOrderItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _purchaseOrderIdMeta = const VerificationMeta(
    'purchaseOrderId',
  );
  @override
  late final GeneratedColumn<String> purchaseOrderId = GeneratedColumn<String>(
    'purchase_order_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES purchase_orders (id)',
    ),
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES products (id)',
    ),
  );
  static const VerificationMeta _systemPriceMeta = const VerificationMeta(
    'systemPrice',
  );
  @override
  late final GeneratedColumn<double> systemPrice = GeneratedColumn<double>(
    'system_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<double> price = GeneratedColumn<double>(
    'price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _casesMeta = const VerificationMeta('cases');
  @override
  late final GeneratedColumn<double> cases = GeneratedColumn<double>(
    'cases',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isFreeMeta = const VerificationMeta('isFree');
  @override
  late final GeneratedColumn<bool> isFree = GeneratedColumn<bool>(
    'is_free',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_free" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _rawPriceMeta = const VerificationMeta(
    'rawPrice',
  );
  @override
  late final GeneratedColumn<double> rawPrice = GeneratedColumn<double>(
    'raw_price',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    purchaseOrderId,
    productId,
    systemPrice,
    price,
    cases,
    amount,
    isFree,
    rawPrice,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'purchase_order_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<PurchaseOrderItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('purchase_order_id')) {
      context.handle(
        _purchaseOrderIdMeta,
        purchaseOrderId.isAcceptableOrUnknown(
          data['purchase_order_id']!,
          _purchaseOrderIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_purchaseOrderIdMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('system_price')) {
      context.handle(
        _systemPriceMeta,
        systemPrice.isAcceptableOrUnknown(
          data['system_price']!,
          _systemPriceMeta,
        ),
      );
    }
    if (data.containsKey('price')) {
      context.handle(
        _priceMeta,
        price.isAcceptableOrUnknown(data['price']!, _priceMeta),
      );
    } else if (isInserting) {
      context.missing(_priceMeta);
    }
    if (data.containsKey('cases')) {
      context.handle(
        _casesMeta,
        cases.isAcceptableOrUnknown(data['cases']!, _casesMeta),
      );
    } else if (isInserting) {
      context.missing(_casesMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('is_free')) {
      context.handle(
        _isFreeMeta,
        isFree.isAcceptableOrUnknown(data['is_free']!, _isFreeMeta),
      );
    }
    if (data.containsKey('raw_price')) {
      context.handle(
        _rawPriceMeta,
        rawPrice.isAcceptableOrUnknown(data['raw_price']!, _rawPriceMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PurchaseOrderItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PurchaseOrderItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      purchaseOrderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}purchase_order_id'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      )!,
      systemPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}system_price'],
      )!,
      price: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}price'],
      )!,
      cases: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cases'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      isFree: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_free'],
      )!,
      rawPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}raw_price'],
      ),
    );
  }

  @override
  $PurchaseOrderItemsTable createAlias(String alias) {
    return $PurchaseOrderItemsTable(attachedDatabase, alias);
  }
}

class PurchaseOrderItem extends DataClass
    implements Insertable<PurchaseOrderItem> {
  final String id;
  final String purchaseOrderId;
  final String productId;
  final double systemPrice;
  final double price;
  final double cases;
  final double amount;
  final bool isFree;
  final double? rawPrice;
  const PurchaseOrderItem({
    required this.id,
    required this.purchaseOrderId,
    required this.productId,
    required this.systemPrice,
    required this.price,
    required this.cases,
    required this.amount,
    required this.isFree,
    this.rawPrice,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['purchase_order_id'] = Variable<String>(purchaseOrderId);
    map['product_id'] = Variable<String>(productId);
    map['system_price'] = Variable<double>(systemPrice);
    map['price'] = Variable<double>(price);
    map['cases'] = Variable<double>(cases);
    map['amount'] = Variable<double>(amount);
    map['is_free'] = Variable<bool>(isFree);
    if (!nullToAbsent || rawPrice != null) {
      map['raw_price'] = Variable<double>(rawPrice);
    }
    return map;
  }

  PurchaseOrderItemsCompanion toCompanion(bool nullToAbsent) {
    return PurchaseOrderItemsCompanion(
      id: Value(id),
      purchaseOrderId: Value(purchaseOrderId),
      productId: Value(productId),
      systemPrice: Value(systemPrice),
      price: Value(price),
      cases: Value(cases),
      amount: Value(amount),
      isFree: Value(isFree),
      rawPrice: rawPrice == null && nullToAbsent
          ? const Value.absent()
          : Value(rawPrice),
    );
  }

  factory PurchaseOrderItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PurchaseOrderItem(
      id: serializer.fromJson<String>(json['id']),
      purchaseOrderId: serializer.fromJson<String>(json['purchaseOrderId']),
      productId: serializer.fromJson<String>(json['productId']),
      systemPrice: serializer.fromJson<double>(json['systemPrice']),
      price: serializer.fromJson<double>(json['price']),
      cases: serializer.fromJson<double>(json['cases']),
      amount: serializer.fromJson<double>(json['amount']),
      isFree: serializer.fromJson<bool>(json['isFree']),
      rawPrice: serializer.fromJson<double?>(json['rawPrice']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'purchaseOrderId': serializer.toJson<String>(purchaseOrderId),
      'productId': serializer.toJson<String>(productId),
      'systemPrice': serializer.toJson<double>(systemPrice),
      'price': serializer.toJson<double>(price),
      'cases': serializer.toJson<double>(cases),
      'amount': serializer.toJson<double>(amount),
      'isFree': serializer.toJson<bool>(isFree),
      'rawPrice': serializer.toJson<double?>(rawPrice),
    };
  }

  PurchaseOrderItem copyWith({
    String? id,
    String? purchaseOrderId,
    String? productId,
    double? systemPrice,
    double? price,
    double? cases,
    double? amount,
    bool? isFree,
    Value<double?> rawPrice = const Value.absent(),
  }) => PurchaseOrderItem(
    id: id ?? this.id,
    purchaseOrderId: purchaseOrderId ?? this.purchaseOrderId,
    productId: productId ?? this.productId,
    systemPrice: systemPrice ?? this.systemPrice,
    price: price ?? this.price,
    cases: cases ?? this.cases,
    amount: amount ?? this.amount,
    isFree: isFree ?? this.isFree,
    rawPrice: rawPrice.present ? rawPrice.value : this.rawPrice,
  );
  PurchaseOrderItem copyWithCompanion(PurchaseOrderItemsCompanion data) {
    return PurchaseOrderItem(
      id: data.id.present ? data.id.value : this.id,
      purchaseOrderId: data.purchaseOrderId.present
          ? data.purchaseOrderId.value
          : this.purchaseOrderId,
      productId: data.productId.present ? data.productId.value : this.productId,
      systemPrice: data.systemPrice.present
          ? data.systemPrice.value
          : this.systemPrice,
      price: data.price.present ? data.price.value : this.price,
      cases: data.cases.present ? data.cases.value : this.cases,
      amount: data.amount.present ? data.amount.value : this.amount,
      isFree: data.isFree.present ? data.isFree.value : this.isFree,
      rawPrice: data.rawPrice.present ? data.rawPrice.value : this.rawPrice,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PurchaseOrderItem(')
          ..write('id: $id, ')
          ..write('purchaseOrderId: $purchaseOrderId, ')
          ..write('productId: $productId, ')
          ..write('systemPrice: $systemPrice, ')
          ..write('price: $price, ')
          ..write('cases: $cases, ')
          ..write('amount: $amount, ')
          ..write('isFree: $isFree, ')
          ..write('rawPrice: $rawPrice')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    purchaseOrderId,
    productId,
    systemPrice,
    price,
    cases,
    amount,
    isFree,
    rawPrice,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PurchaseOrderItem &&
          other.id == this.id &&
          other.purchaseOrderId == this.purchaseOrderId &&
          other.productId == this.productId &&
          other.systemPrice == this.systemPrice &&
          other.price == this.price &&
          other.cases == this.cases &&
          other.amount == this.amount &&
          other.isFree == this.isFree &&
          other.rawPrice == this.rawPrice);
}

class PurchaseOrderItemsCompanion extends UpdateCompanion<PurchaseOrderItem> {
  final Value<String> id;
  final Value<String> purchaseOrderId;
  final Value<String> productId;
  final Value<double> systemPrice;
  final Value<double> price;
  final Value<double> cases;
  final Value<double> amount;
  final Value<bool> isFree;
  final Value<double?> rawPrice;
  final Value<int> rowid;
  const PurchaseOrderItemsCompanion({
    this.id = const Value.absent(),
    this.purchaseOrderId = const Value.absent(),
    this.productId = const Value.absent(),
    this.systemPrice = const Value.absent(),
    this.price = const Value.absent(),
    this.cases = const Value.absent(),
    this.amount = const Value.absent(),
    this.isFree = const Value.absent(),
    this.rawPrice = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PurchaseOrderItemsCompanion.insert({
    required String id,
    required String purchaseOrderId,
    required String productId,
    this.systemPrice = const Value.absent(),
    required double price,
    required double cases,
    required double amount,
    this.isFree = const Value.absent(),
    this.rawPrice = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       purchaseOrderId = Value(purchaseOrderId),
       productId = Value(productId),
       price = Value(price),
       cases = Value(cases),
       amount = Value(amount);
  static Insertable<PurchaseOrderItem> custom({
    Expression<String>? id,
    Expression<String>? purchaseOrderId,
    Expression<String>? productId,
    Expression<double>? systemPrice,
    Expression<double>? price,
    Expression<double>? cases,
    Expression<double>? amount,
    Expression<bool>? isFree,
    Expression<double>? rawPrice,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (purchaseOrderId != null) 'purchase_order_id': purchaseOrderId,
      if (productId != null) 'product_id': productId,
      if (systemPrice != null) 'system_price': systemPrice,
      if (price != null) 'price': price,
      if (cases != null) 'cases': cases,
      if (amount != null) 'amount': amount,
      if (isFree != null) 'is_free': isFree,
      if (rawPrice != null) 'raw_price': rawPrice,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PurchaseOrderItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? purchaseOrderId,
    Value<String>? productId,
    Value<double>? systemPrice,
    Value<double>? price,
    Value<double>? cases,
    Value<double>? amount,
    Value<bool>? isFree,
    Value<double?>? rawPrice,
    Value<int>? rowid,
  }) {
    return PurchaseOrderItemsCompanion(
      id: id ?? this.id,
      purchaseOrderId: purchaseOrderId ?? this.purchaseOrderId,
      productId: productId ?? this.productId,
      systemPrice: systemPrice ?? this.systemPrice,
      price: price ?? this.price,
      cases: cases ?? this.cases,
      amount: amount ?? this.amount,
      isFree: isFree ?? this.isFree,
      rawPrice: rawPrice ?? this.rawPrice,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (purchaseOrderId.present) {
      map['purchase_order_id'] = Variable<String>(purchaseOrderId.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (systemPrice.present) {
      map['system_price'] = Variable<double>(systemPrice.value);
    }
    if (price.present) {
      map['price'] = Variable<double>(price.value);
    }
    if (cases.present) {
      map['cases'] = Variable<double>(cases.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (isFree.present) {
      map['is_free'] = Variable<bool>(isFree.value);
    }
    if (rawPrice.present) {
      map['raw_price'] = Variable<double>(rawPrice.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PurchaseOrderItemsCompanion(')
          ..write('id: $id, ')
          ..write('purchaseOrderId: $purchaseOrderId, ')
          ..write('productId: $productId, ')
          ..write('systemPrice: $systemPrice, ')
          ..write('price: $price, ')
          ..write('cases: $cases, ')
          ..write('amount: $amount, ')
          ..write('isFree: $isFree, ')
          ..write('rawPrice: $rawPrice, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PreOrderReviewsTable extends PreOrderReviews
    with TableInfo<$PreOrderReviewsTable, PreOrderReview> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PreOrderReviewsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceFileMeta = const VerificationMeta(
    'sourceFile',
  );
  @override
  late final GeneratedColumn<String> sourceFile = GeneratedColumn<String>(
    'source_file',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _originalExportedAtMeta =
      const VerificationMeta('originalExportedAt');
  @override
  late final GeneratedColumn<String> originalExportedAt =
      GeneratedColumn<String>(
        'original_exported_at',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _reviewedAtMeta = const VerificationMeta(
    'reviewedAt',
  );
  @override
  late final GeneratedColumn<DateTime> reviewedAt = GeneratedColumn<DateTime>(
    'reviewed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sourceFile,
    originalExportedAt,
    reviewedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pre_order_reviews';
  @override
  VerificationContext validateIntegrity(
    Insertable<PreOrderReview> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('source_file')) {
      context.handle(
        _sourceFileMeta,
        sourceFile.isAcceptableOrUnknown(data['source_file']!, _sourceFileMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceFileMeta);
    }
    if (data.containsKey('original_exported_at')) {
      context.handle(
        _originalExportedAtMeta,
        originalExportedAt.isAcceptableOrUnknown(
          data['original_exported_at']!,
          _originalExportedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_originalExportedAtMeta);
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
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PreOrderReview map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PreOrderReview(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sourceFile: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_file'],
      )!,
      originalExportedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}original_exported_at'],
      )!,
      reviewedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}reviewed_at'],
      )!,
    );
  }

  @override
  $PreOrderReviewsTable createAlias(String alias) {
    return $PreOrderReviewsTable(attachedDatabase, alias);
  }
}

class PreOrderReview extends DataClass implements Insertable<PreOrderReview> {
  final String id;
  final String sourceFile;
  final String originalExportedAt;
  final DateTime reviewedAt;
  const PreOrderReview({
    required this.id,
    required this.sourceFile,
    required this.originalExportedAt,
    required this.reviewedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['source_file'] = Variable<String>(sourceFile);
    map['original_exported_at'] = Variable<String>(originalExportedAt);
    map['reviewed_at'] = Variable<DateTime>(reviewedAt);
    return map;
  }

  PreOrderReviewsCompanion toCompanion(bool nullToAbsent) {
    return PreOrderReviewsCompanion(
      id: Value(id),
      sourceFile: Value(sourceFile),
      originalExportedAt: Value(originalExportedAt),
      reviewedAt: Value(reviewedAt),
    );
  }

  factory PreOrderReview.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PreOrderReview(
      id: serializer.fromJson<String>(json['id']),
      sourceFile: serializer.fromJson<String>(json['sourceFile']),
      originalExportedAt: serializer.fromJson<String>(
        json['originalExportedAt'],
      ),
      reviewedAt: serializer.fromJson<DateTime>(json['reviewedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sourceFile': serializer.toJson<String>(sourceFile),
      'originalExportedAt': serializer.toJson<String>(originalExportedAt),
      'reviewedAt': serializer.toJson<DateTime>(reviewedAt),
    };
  }

  PreOrderReview copyWith({
    String? id,
    String? sourceFile,
    String? originalExportedAt,
    DateTime? reviewedAt,
  }) => PreOrderReview(
    id: id ?? this.id,
    sourceFile: sourceFile ?? this.sourceFile,
    originalExportedAt: originalExportedAt ?? this.originalExportedAt,
    reviewedAt: reviewedAt ?? this.reviewedAt,
  );
  PreOrderReview copyWithCompanion(PreOrderReviewsCompanion data) {
    return PreOrderReview(
      id: data.id.present ? data.id.value : this.id,
      sourceFile: data.sourceFile.present
          ? data.sourceFile.value
          : this.sourceFile,
      originalExportedAt: data.originalExportedAt.present
          ? data.originalExportedAt.value
          : this.originalExportedAt,
      reviewedAt: data.reviewedAt.present
          ? data.reviewedAt.value
          : this.reviewedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PreOrderReview(')
          ..write('id: $id, ')
          ..write('sourceFile: $sourceFile, ')
          ..write('originalExportedAt: $originalExportedAt, ')
          ..write('reviewedAt: $reviewedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, sourceFile, originalExportedAt, reviewedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PreOrderReview &&
          other.id == this.id &&
          other.sourceFile == this.sourceFile &&
          other.originalExportedAt == this.originalExportedAt &&
          other.reviewedAt == this.reviewedAt);
}

class PreOrderReviewsCompanion extends UpdateCompanion<PreOrderReview> {
  final Value<String> id;
  final Value<String> sourceFile;
  final Value<String> originalExportedAt;
  final Value<DateTime> reviewedAt;
  final Value<int> rowid;
  const PreOrderReviewsCompanion({
    this.id = const Value.absent(),
    this.sourceFile = const Value.absent(),
    this.originalExportedAt = const Value.absent(),
    this.reviewedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PreOrderReviewsCompanion.insert({
    required String id,
    required String sourceFile,
    required String originalExportedAt,
    this.reviewedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sourceFile = Value(sourceFile),
       originalExportedAt = Value(originalExportedAt);
  static Insertable<PreOrderReview> custom({
    Expression<String>? id,
    Expression<String>? sourceFile,
    Expression<String>? originalExportedAt,
    Expression<DateTime>? reviewedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sourceFile != null) 'source_file': sourceFile,
      if (originalExportedAt != null)
        'original_exported_at': originalExportedAt,
      if (reviewedAt != null) 'reviewed_at': reviewedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PreOrderReviewsCompanion copyWith({
    Value<String>? id,
    Value<String>? sourceFile,
    Value<String>? originalExportedAt,
    Value<DateTime>? reviewedAt,
    Value<int>? rowid,
  }) {
    return PreOrderReviewsCompanion(
      id: id ?? this.id,
      sourceFile: sourceFile ?? this.sourceFile,
      originalExportedAt: originalExportedAt ?? this.originalExportedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sourceFile.present) {
      map['source_file'] = Variable<String>(sourceFile.value);
    }
    if (originalExportedAt.present) {
      map['original_exported_at'] = Variable<String>(originalExportedAt.value);
    }
    if (reviewedAt.present) {
      map['reviewed_at'] = Variable<DateTime>(reviewedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PreOrderReviewsCompanion(')
          ..write('id: $id, ')
          ..write('sourceFile: $sourceFile, ')
          ..write('originalExportedAt: $originalExportedAt, ')
          ..write('reviewedAt: $reviewedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PreOrderReviewItemsTable extends PreOrderReviewItems
    with TableInfo<$PreOrderReviewItemsTable, PreOrderReviewItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PreOrderReviewItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reviewIdMeta = const VerificationMeta(
    'reviewId',
  );
  @override
  late final GeneratedColumn<String> reviewId = GeneratedColumn<String>(
    'review_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES pre_order_reviews (id)',
    ),
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _matchedProductIdMeta = const VerificationMeta(
    'matchedProductId',
  );
  @override
  late final GeneratedColumn<String> matchedProductId = GeneratedColumn<String>(
    'matched_product_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _productNameMeta = const VerificationMeta(
    'productName',
  );
  @override
  late final GeneratedColumn<String> productName = GeneratedColumn<String>(
    'product_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productCodeMeta = const VerificationMeta(
    'productCode',
  );
  @override
  late final GeneratedColumn<String> productCode = GeneratedColumn<String>(
    'product_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _supplierNameMeta = const VerificationMeta(
    'supplierName',
  );
  @override
  late final GeneratedColumn<String> supplierName = GeneratedColumn<String>(
    'supplier_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _piecesPerBoxMeta = const VerificationMeta(
    'piecesPerBox',
  );
  @override
  late final GeneratedColumn<int> piecesPerBox = GeneratedColumn<int>(
    'pieces_per_box',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _requestedPiecesMeta = const VerificationMeta(
    'requestedPieces',
  );
  @override
  late final GeneratedColumn<int> requestedPieces = GeneratedColumn<int>(
    'requested_pieces',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _availablePiecesMeta = const VerificationMeta(
    'availablePieces',
  );
  @override
  late final GeneratedColumn<int> availablePieces = GeneratedColumn<int>(
    'available_pieces',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _confirmedPiecesMeta = const VerificationMeta(
    'confirmedPieces',
  );
  @override
  late final GeneratedColumn<int> confirmedPieces = GeneratedColumn<int>(
    'confirmed_pieces',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    reviewId,
    productId,
    matchedProductId,
    productName,
    productCode,
    supplierName,
    piecesPerBox,
    requestedPieces,
    availablePieces,
    confirmedPieces,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pre_order_review_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<PreOrderReviewItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('review_id')) {
      context.handle(
        _reviewIdMeta,
        reviewId.isAcceptableOrUnknown(data['review_id']!, _reviewIdMeta),
      );
    } else if (isInserting) {
      context.missing(_reviewIdMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    }
    if (data.containsKey('matched_product_id')) {
      context.handle(
        _matchedProductIdMeta,
        matchedProductId.isAcceptableOrUnknown(
          data['matched_product_id']!,
          _matchedProductIdMeta,
        ),
      );
    }
    if (data.containsKey('product_name')) {
      context.handle(
        _productNameMeta,
        productName.isAcceptableOrUnknown(
          data['product_name']!,
          _productNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_productNameMeta);
    }
    if (data.containsKey('product_code')) {
      context.handle(
        _productCodeMeta,
        productCode.isAcceptableOrUnknown(
          data['product_code']!,
          _productCodeMeta,
        ),
      );
    }
    if (data.containsKey('supplier_name')) {
      context.handle(
        _supplierNameMeta,
        supplierName.isAcceptableOrUnknown(
          data['supplier_name']!,
          _supplierNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_supplierNameMeta);
    }
    if (data.containsKey('pieces_per_box')) {
      context.handle(
        _piecesPerBoxMeta,
        piecesPerBox.isAcceptableOrUnknown(
          data['pieces_per_box']!,
          _piecesPerBoxMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_piecesPerBoxMeta);
    }
    if (data.containsKey('requested_pieces')) {
      context.handle(
        _requestedPiecesMeta,
        requestedPieces.isAcceptableOrUnknown(
          data['requested_pieces']!,
          _requestedPiecesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_requestedPiecesMeta);
    }
    if (data.containsKey('available_pieces')) {
      context.handle(
        _availablePiecesMeta,
        availablePieces.isAcceptableOrUnknown(
          data['available_pieces']!,
          _availablePiecesMeta,
        ),
      );
    }
    if (data.containsKey('confirmed_pieces')) {
      context.handle(
        _confirmedPiecesMeta,
        confirmedPieces.isAcceptableOrUnknown(
          data['confirmed_pieces']!,
          _confirmedPiecesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_confirmedPiecesMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PreOrderReviewItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PreOrderReviewItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      reviewId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}review_id'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      ),
      matchedProductId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}matched_product_id'],
      ),
      productName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_name'],
      )!,
      productCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_code'],
      ),
      supplierName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}supplier_name'],
      )!,
      piecesPerBox: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pieces_per_box'],
      )!,
      requestedPieces: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}requested_pieces'],
      )!,
      availablePieces: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}available_pieces'],
      )!,
      confirmedPieces: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}confirmed_pieces'],
      )!,
    );
  }

  @override
  $PreOrderReviewItemsTable createAlias(String alias) {
    return $PreOrderReviewItemsTable(attachedDatabase, alias);
  }
}

class PreOrderReviewItem extends DataClass
    implements Insertable<PreOrderReviewItem> {
  final String id;
  final String reviewId;
  final String? productId;
  final String? matchedProductId;
  final String productName;
  final String? productCode;
  final String supplierName;
  final int piecesPerBox;
  final int requestedPieces;
  final int availablePieces;
  final int confirmedPieces;
  const PreOrderReviewItem({
    required this.id,
    required this.reviewId,
    this.productId,
    this.matchedProductId,
    required this.productName,
    this.productCode,
    required this.supplierName,
    required this.piecesPerBox,
    required this.requestedPieces,
    required this.availablePieces,
    required this.confirmedPieces,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['review_id'] = Variable<String>(reviewId);
    if (!nullToAbsent || productId != null) {
      map['product_id'] = Variable<String>(productId);
    }
    if (!nullToAbsent || matchedProductId != null) {
      map['matched_product_id'] = Variable<String>(matchedProductId);
    }
    map['product_name'] = Variable<String>(productName);
    if (!nullToAbsent || productCode != null) {
      map['product_code'] = Variable<String>(productCode);
    }
    map['supplier_name'] = Variable<String>(supplierName);
    map['pieces_per_box'] = Variable<int>(piecesPerBox);
    map['requested_pieces'] = Variable<int>(requestedPieces);
    map['available_pieces'] = Variable<int>(availablePieces);
    map['confirmed_pieces'] = Variable<int>(confirmedPieces);
    return map;
  }

  PreOrderReviewItemsCompanion toCompanion(bool nullToAbsent) {
    return PreOrderReviewItemsCompanion(
      id: Value(id),
      reviewId: Value(reviewId),
      productId: productId == null && nullToAbsent
          ? const Value.absent()
          : Value(productId),
      matchedProductId: matchedProductId == null && nullToAbsent
          ? const Value.absent()
          : Value(matchedProductId),
      productName: Value(productName),
      productCode: productCode == null && nullToAbsent
          ? const Value.absent()
          : Value(productCode),
      supplierName: Value(supplierName),
      piecesPerBox: Value(piecesPerBox),
      requestedPieces: Value(requestedPieces),
      availablePieces: Value(availablePieces),
      confirmedPieces: Value(confirmedPieces),
    );
  }

  factory PreOrderReviewItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PreOrderReviewItem(
      id: serializer.fromJson<String>(json['id']),
      reviewId: serializer.fromJson<String>(json['reviewId']),
      productId: serializer.fromJson<String?>(json['productId']),
      matchedProductId: serializer.fromJson<String?>(json['matchedProductId']),
      productName: serializer.fromJson<String>(json['productName']),
      productCode: serializer.fromJson<String?>(json['productCode']),
      supplierName: serializer.fromJson<String>(json['supplierName']),
      piecesPerBox: serializer.fromJson<int>(json['piecesPerBox']),
      requestedPieces: serializer.fromJson<int>(json['requestedPieces']),
      availablePieces: serializer.fromJson<int>(json['availablePieces']),
      confirmedPieces: serializer.fromJson<int>(json['confirmedPieces']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'reviewId': serializer.toJson<String>(reviewId),
      'productId': serializer.toJson<String?>(productId),
      'matchedProductId': serializer.toJson<String?>(matchedProductId),
      'productName': serializer.toJson<String>(productName),
      'productCode': serializer.toJson<String?>(productCode),
      'supplierName': serializer.toJson<String>(supplierName),
      'piecesPerBox': serializer.toJson<int>(piecesPerBox),
      'requestedPieces': serializer.toJson<int>(requestedPieces),
      'availablePieces': serializer.toJson<int>(availablePieces),
      'confirmedPieces': serializer.toJson<int>(confirmedPieces),
    };
  }

  PreOrderReviewItem copyWith({
    String? id,
    String? reviewId,
    Value<String?> productId = const Value.absent(),
    Value<String?> matchedProductId = const Value.absent(),
    String? productName,
    Value<String?> productCode = const Value.absent(),
    String? supplierName,
    int? piecesPerBox,
    int? requestedPieces,
    int? availablePieces,
    int? confirmedPieces,
  }) => PreOrderReviewItem(
    id: id ?? this.id,
    reviewId: reviewId ?? this.reviewId,
    productId: productId.present ? productId.value : this.productId,
    matchedProductId: matchedProductId.present
        ? matchedProductId.value
        : this.matchedProductId,
    productName: productName ?? this.productName,
    productCode: productCode.present ? productCode.value : this.productCode,
    supplierName: supplierName ?? this.supplierName,
    piecesPerBox: piecesPerBox ?? this.piecesPerBox,
    requestedPieces: requestedPieces ?? this.requestedPieces,
    availablePieces: availablePieces ?? this.availablePieces,
    confirmedPieces: confirmedPieces ?? this.confirmedPieces,
  );
  PreOrderReviewItem copyWithCompanion(PreOrderReviewItemsCompanion data) {
    return PreOrderReviewItem(
      id: data.id.present ? data.id.value : this.id,
      reviewId: data.reviewId.present ? data.reviewId.value : this.reviewId,
      productId: data.productId.present ? data.productId.value : this.productId,
      matchedProductId: data.matchedProductId.present
          ? data.matchedProductId.value
          : this.matchedProductId,
      productName: data.productName.present
          ? data.productName.value
          : this.productName,
      productCode: data.productCode.present
          ? data.productCode.value
          : this.productCode,
      supplierName: data.supplierName.present
          ? data.supplierName.value
          : this.supplierName,
      piecesPerBox: data.piecesPerBox.present
          ? data.piecesPerBox.value
          : this.piecesPerBox,
      requestedPieces: data.requestedPieces.present
          ? data.requestedPieces.value
          : this.requestedPieces,
      availablePieces: data.availablePieces.present
          ? data.availablePieces.value
          : this.availablePieces,
      confirmedPieces: data.confirmedPieces.present
          ? data.confirmedPieces.value
          : this.confirmedPieces,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PreOrderReviewItem(')
          ..write('id: $id, ')
          ..write('reviewId: $reviewId, ')
          ..write('productId: $productId, ')
          ..write('matchedProductId: $matchedProductId, ')
          ..write('productName: $productName, ')
          ..write('productCode: $productCode, ')
          ..write('supplierName: $supplierName, ')
          ..write('piecesPerBox: $piecesPerBox, ')
          ..write('requestedPieces: $requestedPieces, ')
          ..write('availablePieces: $availablePieces, ')
          ..write('confirmedPieces: $confirmedPieces')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    reviewId,
    productId,
    matchedProductId,
    productName,
    productCode,
    supplierName,
    piecesPerBox,
    requestedPieces,
    availablePieces,
    confirmedPieces,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PreOrderReviewItem &&
          other.id == this.id &&
          other.reviewId == this.reviewId &&
          other.productId == this.productId &&
          other.matchedProductId == this.matchedProductId &&
          other.productName == this.productName &&
          other.productCode == this.productCode &&
          other.supplierName == this.supplierName &&
          other.piecesPerBox == this.piecesPerBox &&
          other.requestedPieces == this.requestedPieces &&
          other.availablePieces == this.availablePieces &&
          other.confirmedPieces == this.confirmedPieces);
}

class PreOrderReviewItemsCompanion extends UpdateCompanion<PreOrderReviewItem> {
  final Value<String> id;
  final Value<String> reviewId;
  final Value<String?> productId;
  final Value<String?> matchedProductId;
  final Value<String> productName;
  final Value<String?> productCode;
  final Value<String> supplierName;
  final Value<int> piecesPerBox;
  final Value<int> requestedPieces;
  final Value<int> availablePieces;
  final Value<int> confirmedPieces;
  final Value<int> rowid;
  const PreOrderReviewItemsCompanion({
    this.id = const Value.absent(),
    this.reviewId = const Value.absent(),
    this.productId = const Value.absent(),
    this.matchedProductId = const Value.absent(),
    this.productName = const Value.absent(),
    this.productCode = const Value.absent(),
    this.supplierName = const Value.absent(),
    this.piecesPerBox = const Value.absent(),
    this.requestedPieces = const Value.absent(),
    this.availablePieces = const Value.absent(),
    this.confirmedPieces = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PreOrderReviewItemsCompanion.insert({
    required String id,
    required String reviewId,
    this.productId = const Value.absent(),
    this.matchedProductId = const Value.absent(),
    required String productName,
    this.productCode = const Value.absent(),
    required String supplierName,
    required int piecesPerBox,
    required int requestedPieces,
    this.availablePieces = const Value.absent(),
    required int confirmedPieces,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       reviewId = Value(reviewId),
       productName = Value(productName),
       supplierName = Value(supplierName),
       piecesPerBox = Value(piecesPerBox),
       requestedPieces = Value(requestedPieces),
       confirmedPieces = Value(confirmedPieces);
  static Insertable<PreOrderReviewItem> custom({
    Expression<String>? id,
    Expression<String>? reviewId,
    Expression<String>? productId,
    Expression<String>? matchedProductId,
    Expression<String>? productName,
    Expression<String>? productCode,
    Expression<String>? supplierName,
    Expression<int>? piecesPerBox,
    Expression<int>? requestedPieces,
    Expression<int>? availablePieces,
    Expression<int>? confirmedPieces,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (reviewId != null) 'review_id': reviewId,
      if (productId != null) 'product_id': productId,
      if (matchedProductId != null) 'matched_product_id': matchedProductId,
      if (productName != null) 'product_name': productName,
      if (productCode != null) 'product_code': productCode,
      if (supplierName != null) 'supplier_name': supplierName,
      if (piecesPerBox != null) 'pieces_per_box': piecesPerBox,
      if (requestedPieces != null) 'requested_pieces': requestedPieces,
      if (availablePieces != null) 'available_pieces': availablePieces,
      if (confirmedPieces != null) 'confirmed_pieces': confirmedPieces,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PreOrderReviewItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? reviewId,
    Value<String?>? productId,
    Value<String?>? matchedProductId,
    Value<String>? productName,
    Value<String?>? productCode,
    Value<String>? supplierName,
    Value<int>? piecesPerBox,
    Value<int>? requestedPieces,
    Value<int>? availablePieces,
    Value<int>? confirmedPieces,
    Value<int>? rowid,
  }) {
    return PreOrderReviewItemsCompanion(
      id: id ?? this.id,
      reviewId: reviewId ?? this.reviewId,
      productId: productId ?? this.productId,
      matchedProductId: matchedProductId ?? this.matchedProductId,
      productName: productName ?? this.productName,
      productCode: productCode ?? this.productCode,
      supplierName: supplierName ?? this.supplierName,
      piecesPerBox: piecesPerBox ?? this.piecesPerBox,
      requestedPieces: requestedPieces ?? this.requestedPieces,
      availablePieces: availablePieces ?? this.availablePieces,
      confirmedPieces: confirmedPieces ?? this.confirmedPieces,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (reviewId.present) {
      map['review_id'] = Variable<String>(reviewId.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (matchedProductId.present) {
      map['matched_product_id'] = Variable<String>(matchedProductId.value);
    }
    if (productName.present) {
      map['product_name'] = Variable<String>(productName.value);
    }
    if (productCode.present) {
      map['product_code'] = Variable<String>(productCode.value);
    }
    if (supplierName.present) {
      map['supplier_name'] = Variable<String>(supplierName.value);
    }
    if (piecesPerBox.present) {
      map['pieces_per_box'] = Variable<int>(piecesPerBox.value);
    }
    if (requestedPieces.present) {
      map['requested_pieces'] = Variable<int>(requestedPieces.value);
    }
    if (availablePieces.present) {
      map['available_pieces'] = Variable<int>(availablePieces.value);
    }
    if (confirmedPieces.present) {
      map['confirmed_pieces'] = Variable<int>(confirmedPieces.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PreOrderReviewItemsCompanion(')
          ..write('id: $id, ')
          ..write('reviewId: $reviewId, ')
          ..write('productId: $productId, ')
          ..write('matchedProductId: $matchedProductId, ')
          ..write('productName: $productName, ')
          ..write('productCode: $productCode, ')
          ..write('supplierName: $supplierName, ')
          ..write('piecesPerBox: $piecesPerBox, ')
          ..write('requestedPieces: $requestedPieces, ')
          ..write('availablePieces: $availablePieces, ')
          ..write('confirmedPieces: $confirmedPieces, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StocksLoadingsTable extends StocksLoadings
    with TableInfo<$StocksLoadingsTable, StocksLoading> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StocksLoadingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _loadingDateMeta = const VerificationMeta(
    'loadingDate',
  );
  @override
  late final GeneratedColumn<DateTime> loadingDate = GeneratedColumn<DateTime>(
    'loading_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _importedAtMeta = const VerificationMeta(
    'importedAt',
  );
  @override
  late final GeneratedColumn<DateTime> importedAt = GeneratedColumn<DateTime>(
    'imported_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, loadingDate, importedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stocks_loadings';
  @override
  VerificationContext validateIntegrity(
    Insertable<StocksLoading> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('loading_date')) {
      context.handle(
        _loadingDateMeta,
        loadingDate.isAcceptableOrUnknown(
          data['loading_date']!,
          _loadingDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_loadingDateMeta);
    }
    if (data.containsKey('imported_at')) {
      context.handle(
        _importedAtMeta,
        importedAt.isAcceptableOrUnknown(data['imported_at']!, _importedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StocksLoading map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StocksLoading(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      loadingDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}loading_date'],
      )!,
      importedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}imported_at'],
      )!,
    );
  }

  @override
  $StocksLoadingsTable createAlias(String alias) {
    return $StocksLoadingsTable(attachedDatabase, alias);
  }
}

class StocksLoading extends DataClass implements Insertable<StocksLoading> {
  final String id;

  /// The date the loading is intended for (display / layout date).
  final DateTime loadingDate;
  final DateTime importedAt;
  const StocksLoading({
    required this.id,
    required this.loadingDate,
    required this.importedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['loading_date'] = Variable<DateTime>(loadingDate);
    map['imported_at'] = Variable<DateTime>(importedAt);
    return map;
  }

  StocksLoadingsCompanion toCompanion(bool nullToAbsent) {
    return StocksLoadingsCompanion(
      id: Value(id),
      loadingDate: Value(loadingDate),
      importedAt: Value(importedAt),
    );
  }

  factory StocksLoading.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StocksLoading(
      id: serializer.fromJson<String>(json['id']),
      loadingDate: serializer.fromJson<DateTime>(json['loadingDate']),
      importedAt: serializer.fromJson<DateTime>(json['importedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'loadingDate': serializer.toJson<DateTime>(loadingDate),
      'importedAt': serializer.toJson<DateTime>(importedAt),
    };
  }

  StocksLoading copyWith({
    String? id,
    DateTime? loadingDate,
    DateTime? importedAt,
  }) => StocksLoading(
    id: id ?? this.id,
    loadingDate: loadingDate ?? this.loadingDate,
    importedAt: importedAt ?? this.importedAt,
  );
  StocksLoading copyWithCompanion(StocksLoadingsCompanion data) {
    return StocksLoading(
      id: data.id.present ? data.id.value : this.id,
      loadingDate: data.loadingDate.present
          ? data.loadingDate.value
          : this.loadingDate,
      importedAt: data.importedAt.present
          ? data.importedAt.value
          : this.importedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StocksLoading(')
          ..write('id: $id, ')
          ..write('loadingDate: $loadingDate, ')
          ..write('importedAt: $importedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, loadingDate, importedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StocksLoading &&
          other.id == this.id &&
          other.loadingDate == this.loadingDate &&
          other.importedAt == this.importedAt);
}

class StocksLoadingsCompanion extends UpdateCompanion<StocksLoading> {
  final Value<String> id;
  final Value<DateTime> loadingDate;
  final Value<DateTime> importedAt;
  final Value<int> rowid;
  const StocksLoadingsCompanion({
    this.id = const Value.absent(),
    this.loadingDate = const Value.absent(),
    this.importedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StocksLoadingsCompanion.insert({
    required String id,
    required DateTime loadingDate,
    this.importedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       loadingDate = Value(loadingDate);
  static Insertable<StocksLoading> custom({
    Expression<String>? id,
    Expression<DateTime>? loadingDate,
    Expression<DateTime>? importedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (loadingDate != null) 'loading_date': loadingDate,
      if (importedAt != null) 'imported_at': importedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StocksLoadingsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? loadingDate,
    Value<DateTime>? importedAt,
    Value<int>? rowid,
  }) {
    return StocksLoadingsCompanion(
      id: id ?? this.id,
      loadingDate: loadingDate ?? this.loadingDate,
      importedAt: importedAt ?? this.importedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (loadingDate.present) {
      map['loading_date'] = Variable<DateTime>(loadingDate.value);
    }
    if (importedAt.present) {
      map['imported_at'] = Variable<DateTime>(importedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StocksLoadingsCompanion(')
          ..write('id: $id, ')
          ..write('loadingDate: $loadingDate, ')
          ..write('importedAt: $importedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StocksLoadingItemsTable extends StocksLoadingItems
    with TableInfo<$StocksLoadingItemsTable, StocksLoadingItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StocksLoadingItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stocksLoadingIdMeta = const VerificationMeta(
    'stocksLoadingId',
  );
  @override
  late final GeneratedColumn<String> stocksLoadingId = GeneratedColumn<String>(
    'stocks_loading_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES stocks_loadings (id)',
    ),
  );
  static const VerificationMeta _productCodeMeta = const VerificationMeta(
    'productCode',
  );
  @override
  late final GeneratedColumn<String> productCode = GeneratedColumn<String>(
    'product_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _productNameMeta = const VerificationMeta(
    'productName',
  );
  @override
  late final GeneratedColumn<String> productName = GeneratedColumn<String>(
    'product_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _supplierNameMeta = const VerificationMeta(
    'supplierName',
  );
  @override
  late final GeneratedColumn<String> supplierName = GeneratedColumn<String>(
    'supplier_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityPiecesMeta = const VerificationMeta(
    'quantityPieces',
  );
  @override
  late final GeneratedColumn<int> quantityPieces = GeneratedColumn<int>(
    'quantity_pieces',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _piecesPerBoxMeta = const VerificationMeta(
    'piecesPerBox',
  );
  @override
  late final GeneratedColumn<int> piecesPerBox = GeneratedColumn<int>(
    'pieces_per_box',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    stocksLoadingId,
    productCode,
    productName,
    supplierName,
    quantityPieces,
    piecesPerBox,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stocks_loading_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<StocksLoadingItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('stocks_loading_id')) {
      context.handle(
        _stocksLoadingIdMeta,
        stocksLoadingId.isAcceptableOrUnknown(
          data['stocks_loading_id']!,
          _stocksLoadingIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_stocksLoadingIdMeta);
    }
    if (data.containsKey('product_code')) {
      context.handle(
        _productCodeMeta,
        productCode.isAcceptableOrUnknown(
          data['product_code']!,
          _productCodeMeta,
        ),
      );
    }
    if (data.containsKey('product_name')) {
      context.handle(
        _productNameMeta,
        productName.isAcceptableOrUnknown(
          data['product_name']!,
          _productNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_productNameMeta);
    }
    if (data.containsKey('supplier_name')) {
      context.handle(
        _supplierNameMeta,
        supplierName.isAcceptableOrUnknown(
          data['supplier_name']!,
          _supplierNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_supplierNameMeta);
    }
    if (data.containsKey('quantity_pieces')) {
      context.handle(
        _quantityPiecesMeta,
        quantityPieces.isAcceptableOrUnknown(
          data['quantity_pieces']!,
          _quantityPiecesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_quantityPiecesMeta);
    }
    if (data.containsKey('pieces_per_box')) {
      context.handle(
        _piecesPerBoxMeta,
        piecesPerBox.isAcceptableOrUnknown(
          data['pieces_per_box']!,
          _piecesPerBoxMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StocksLoadingItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StocksLoadingItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      stocksLoadingId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stocks_loading_id'],
      )!,
      productCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_code'],
      ),
      productName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_name'],
      )!,
      supplierName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}supplier_name'],
      )!,
      quantityPieces: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity_pieces'],
      )!,
      piecesPerBox: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pieces_per_box'],
      )!,
    );
  }

  @override
  $StocksLoadingItemsTable createAlias(String alias) {
    return $StocksLoadingItemsTable(attachedDatabase, alias);
  }
}

class StocksLoadingItem extends DataClass
    implements Insertable<StocksLoadingItem> {
  final String id;
  final String stocksLoadingId;
  final String? productCode;
  final String productName;
  final String supplierName;
  final int quantityPieces;
  final int piecesPerBox;
  const StocksLoadingItem({
    required this.id,
    required this.stocksLoadingId,
    this.productCode,
    required this.productName,
    required this.supplierName,
    required this.quantityPieces,
    required this.piecesPerBox,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['stocks_loading_id'] = Variable<String>(stocksLoadingId);
    if (!nullToAbsent || productCode != null) {
      map['product_code'] = Variable<String>(productCode);
    }
    map['product_name'] = Variable<String>(productName);
    map['supplier_name'] = Variable<String>(supplierName);
    map['quantity_pieces'] = Variable<int>(quantityPieces);
    map['pieces_per_box'] = Variable<int>(piecesPerBox);
    return map;
  }

  StocksLoadingItemsCompanion toCompanion(bool nullToAbsent) {
    return StocksLoadingItemsCompanion(
      id: Value(id),
      stocksLoadingId: Value(stocksLoadingId),
      productCode: productCode == null && nullToAbsent
          ? const Value.absent()
          : Value(productCode),
      productName: Value(productName),
      supplierName: Value(supplierName),
      quantityPieces: Value(quantityPieces),
      piecesPerBox: Value(piecesPerBox),
    );
  }

  factory StocksLoadingItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StocksLoadingItem(
      id: serializer.fromJson<String>(json['id']),
      stocksLoadingId: serializer.fromJson<String>(json['stocksLoadingId']),
      productCode: serializer.fromJson<String?>(json['productCode']),
      productName: serializer.fromJson<String>(json['productName']),
      supplierName: serializer.fromJson<String>(json['supplierName']),
      quantityPieces: serializer.fromJson<int>(json['quantityPieces']),
      piecesPerBox: serializer.fromJson<int>(json['piecesPerBox']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'stocksLoadingId': serializer.toJson<String>(stocksLoadingId),
      'productCode': serializer.toJson<String?>(productCode),
      'productName': serializer.toJson<String>(productName),
      'supplierName': serializer.toJson<String>(supplierName),
      'quantityPieces': serializer.toJson<int>(quantityPieces),
      'piecesPerBox': serializer.toJson<int>(piecesPerBox),
    };
  }

  StocksLoadingItem copyWith({
    String? id,
    String? stocksLoadingId,
    Value<String?> productCode = const Value.absent(),
    String? productName,
    String? supplierName,
    int? quantityPieces,
    int? piecesPerBox,
  }) => StocksLoadingItem(
    id: id ?? this.id,
    stocksLoadingId: stocksLoadingId ?? this.stocksLoadingId,
    productCode: productCode.present ? productCode.value : this.productCode,
    productName: productName ?? this.productName,
    supplierName: supplierName ?? this.supplierName,
    quantityPieces: quantityPieces ?? this.quantityPieces,
    piecesPerBox: piecesPerBox ?? this.piecesPerBox,
  );
  StocksLoadingItem copyWithCompanion(StocksLoadingItemsCompanion data) {
    return StocksLoadingItem(
      id: data.id.present ? data.id.value : this.id,
      stocksLoadingId: data.stocksLoadingId.present
          ? data.stocksLoadingId.value
          : this.stocksLoadingId,
      productCode: data.productCode.present
          ? data.productCode.value
          : this.productCode,
      productName: data.productName.present
          ? data.productName.value
          : this.productName,
      supplierName: data.supplierName.present
          ? data.supplierName.value
          : this.supplierName,
      quantityPieces: data.quantityPieces.present
          ? data.quantityPieces.value
          : this.quantityPieces,
      piecesPerBox: data.piecesPerBox.present
          ? data.piecesPerBox.value
          : this.piecesPerBox,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StocksLoadingItem(')
          ..write('id: $id, ')
          ..write('stocksLoadingId: $stocksLoadingId, ')
          ..write('productCode: $productCode, ')
          ..write('productName: $productName, ')
          ..write('supplierName: $supplierName, ')
          ..write('quantityPieces: $quantityPieces, ')
          ..write('piecesPerBox: $piecesPerBox')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    stocksLoadingId,
    productCode,
    productName,
    supplierName,
    quantityPieces,
    piecesPerBox,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StocksLoadingItem &&
          other.id == this.id &&
          other.stocksLoadingId == this.stocksLoadingId &&
          other.productCode == this.productCode &&
          other.productName == this.productName &&
          other.supplierName == this.supplierName &&
          other.quantityPieces == this.quantityPieces &&
          other.piecesPerBox == this.piecesPerBox);
}

class StocksLoadingItemsCompanion extends UpdateCompanion<StocksLoadingItem> {
  final Value<String> id;
  final Value<String> stocksLoadingId;
  final Value<String?> productCode;
  final Value<String> productName;
  final Value<String> supplierName;
  final Value<int> quantityPieces;
  final Value<int> piecesPerBox;
  final Value<int> rowid;
  const StocksLoadingItemsCompanion({
    this.id = const Value.absent(),
    this.stocksLoadingId = const Value.absent(),
    this.productCode = const Value.absent(),
    this.productName = const Value.absent(),
    this.supplierName = const Value.absent(),
    this.quantityPieces = const Value.absent(),
    this.piecesPerBox = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StocksLoadingItemsCompanion.insert({
    required String id,
    required String stocksLoadingId,
    this.productCode = const Value.absent(),
    required String productName,
    required String supplierName,
    required int quantityPieces,
    this.piecesPerBox = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       stocksLoadingId = Value(stocksLoadingId),
       productName = Value(productName),
       supplierName = Value(supplierName),
       quantityPieces = Value(quantityPieces);
  static Insertable<StocksLoadingItem> custom({
    Expression<String>? id,
    Expression<String>? stocksLoadingId,
    Expression<String>? productCode,
    Expression<String>? productName,
    Expression<String>? supplierName,
    Expression<int>? quantityPieces,
    Expression<int>? piecesPerBox,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (stocksLoadingId != null) 'stocks_loading_id': stocksLoadingId,
      if (productCode != null) 'product_code': productCode,
      if (productName != null) 'product_name': productName,
      if (supplierName != null) 'supplier_name': supplierName,
      if (quantityPieces != null) 'quantity_pieces': quantityPieces,
      if (piecesPerBox != null) 'pieces_per_box': piecesPerBox,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StocksLoadingItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? stocksLoadingId,
    Value<String?>? productCode,
    Value<String>? productName,
    Value<String>? supplierName,
    Value<int>? quantityPieces,
    Value<int>? piecesPerBox,
    Value<int>? rowid,
  }) {
    return StocksLoadingItemsCompanion(
      id: id ?? this.id,
      stocksLoadingId: stocksLoadingId ?? this.stocksLoadingId,
      productCode: productCode ?? this.productCode,
      productName: productName ?? this.productName,
      supplierName: supplierName ?? this.supplierName,
      quantityPieces: quantityPieces ?? this.quantityPieces,
      piecesPerBox: piecesPerBox ?? this.piecesPerBox,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (stocksLoadingId.present) {
      map['stocks_loading_id'] = Variable<String>(stocksLoadingId.value);
    }
    if (productCode.present) {
      map['product_code'] = Variable<String>(productCode.value);
    }
    if (productName.present) {
      map['product_name'] = Variable<String>(productName.value);
    }
    if (supplierName.present) {
      map['supplier_name'] = Variable<String>(supplierName.value);
    }
    if (quantityPieces.present) {
      map['quantity_pieces'] = Variable<int>(quantityPieces.value);
    }
    if (piecesPerBox.present) {
      map['pieces_per_box'] = Variable<int>(piecesPerBox.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StocksLoadingItemsCompanion(')
          ..write('id: $id, ')
          ..write('stocksLoadingId: $stocksLoadingId, ')
          ..write('productCode: $productCode, ')
          ..write('productName: $productName, ')
          ..write('supplierName: $supplierName, ')
          ..write('quantityPieces: $quantityPieces, ')
          ..write('piecesPerBox: $piecesPerBox, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncQueueTable extends SyncQueue
    with TableInfo<$SyncQueueTable, SyncQueueData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetTableMeta = const VerificationMeta(
    'targetTable',
  );
  @override
  late final GeneratedColumn<String> targetTable = GeneratedColumn<String>(
    'target_table',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordIdMeta = const VerificationMeta(
    'recordId',
  );
  @override
  late final GeneratedColumn<String> recordId = GeneratedColumn<String>(
    'record_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operationMeta = const VerificationMeta(
    'operation',
  );
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
    'operation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    targetTable,
    recordId,
    operation,
    payload,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncQueueData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('target_table')) {
      context.handle(
        _targetTableMeta,
        targetTable.isAcceptableOrUnknown(
          data['target_table']!,
          _targetTableMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetTableMeta);
    }
    if (data.containsKey('record_id')) {
      context.handle(
        _recordIdMeta,
        recordId.isAcceptableOrUnknown(data['record_id']!, _recordIdMeta),
      );
    } else if (isInserting) {
      context.missing(_recordIdMeta);
    }
    if (data.containsKey('operation')) {
      context.handle(
        _operationMeta,
        operation.isAcceptableOrUnknown(data['operation']!, _operationMeta),
      );
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncQueueData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      targetTable: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_table'],
      )!,
      recordId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}record_id'],
      )!,
      operation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SyncQueueTable createAlias(String alias) {
    return $SyncQueueTable(attachedDatabase, alias);
  }
}

class SyncQueueData extends DataClass implements Insertable<SyncQueueData> {
  final String id;
  final String targetTable;
  final String recordId;
  final String operation;
  final String payload;
  final DateTime createdAt;
  const SyncQueueData({
    required this.id,
    required this.targetTable,
    required this.recordId,
    required this.operation,
    required this.payload,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['target_table'] = Variable<String>(targetTable);
    map['record_id'] = Variable<String>(recordId);
    map['operation'] = Variable<String>(operation);
    map['payload'] = Variable<String>(payload);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SyncQueueCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueCompanion(
      id: Value(id),
      targetTable: Value(targetTable),
      recordId: Value(recordId),
      operation: Value(operation),
      payload: Value(payload),
      createdAt: Value(createdAt),
    );
  }

  factory SyncQueueData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueData(
      id: serializer.fromJson<String>(json['id']),
      targetTable: serializer.fromJson<String>(json['targetTable']),
      recordId: serializer.fromJson<String>(json['recordId']),
      operation: serializer.fromJson<String>(json['operation']),
      payload: serializer.fromJson<String>(json['payload']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'targetTable': serializer.toJson<String>(targetTable),
      'recordId': serializer.toJson<String>(recordId),
      'operation': serializer.toJson<String>(operation),
      'payload': serializer.toJson<String>(payload),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SyncQueueData copyWith({
    String? id,
    String? targetTable,
    String? recordId,
    String? operation,
    String? payload,
    DateTime? createdAt,
  }) => SyncQueueData(
    id: id ?? this.id,
    targetTable: targetTable ?? this.targetTable,
    recordId: recordId ?? this.recordId,
    operation: operation ?? this.operation,
    payload: payload ?? this.payload,
    createdAt: createdAt ?? this.createdAt,
  );
  SyncQueueData copyWithCompanion(SyncQueueCompanion data) {
    return SyncQueueData(
      id: data.id.present ? data.id.value : this.id,
      targetTable: data.targetTable.present
          ? data.targetTable.value
          : this.targetTable,
      recordId: data.recordId.present ? data.recordId.value : this.recordId,
      operation: data.operation.present ? data.operation.value : this.operation,
      payload: data.payload.present ? data.payload.value : this.payload,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueData(')
          ..write('id: $id, ')
          ..write('targetTable: $targetTable, ')
          ..write('recordId: $recordId, ')
          ..write('operation: $operation, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, targetTable, recordId, operation, payload, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueData &&
          other.id == this.id &&
          other.targetTable == this.targetTable &&
          other.recordId == this.recordId &&
          other.operation == this.operation &&
          other.payload == this.payload &&
          other.createdAt == this.createdAt);
}

class SyncQueueCompanion extends UpdateCompanion<SyncQueueData> {
  final Value<String> id;
  final Value<String> targetTable;
  final Value<String> recordId;
  final Value<String> operation;
  final Value<String> payload;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const SyncQueueCompanion({
    this.id = const Value.absent(),
    this.targetTable = const Value.absent(),
    this.recordId = const Value.absent(),
    this.operation = const Value.absent(),
    this.payload = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncQueueCompanion.insert({
    required String id,
    required String targetTable,
    required String recordId,
    required String operation,
    required String payload,
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       targetTable = Value(targetTable),
       recordId = Value(recordId),
       operation = Value(operation),
       payload = Value(payload);
  static Insertable<SyncQueueData> custom({
    Expression<String>? id,
    Expression<String>? targetTable,
    Expression<String>? recordId,
    Expression<String>? operation,
    Expression<String>? payload,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (targetTable != null) 'target_table': targetTable,
      if (recordId != null) 'record_id': recordId,
      if (operation != null) 'operation': operation,
      if (payload != null) 'payload': payload,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncQueueCompanion copyWith({
    Value<String>? id,
    Value<String>? targetTable,
    Value<String>? recordId,
    Value<String>? operation,
    Value<String>? payload,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return SyncQueueCompanion(
      id: id ?? this.id,
      targetTable: targetTable ?? this.targetTable,
      recordId: recordId ?? this.recordId,
      operation: operation ?? this.operation,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (targetTable.present) {
      map['target_table'] = Variable<String>(targetTable.value);
    }
    if (recordId.present) {
      map['record_id'] = Variable<String>(recordId.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueCompanion(')
          ..write('id: $id, ')
          ..write('targetTable: $targetTable, ')
          ..write('recordId: $recordId, ')
          ..write('operation: $operation, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$LocalDatabase extends GeneratedDatabase {
  _$LocalDatabase(QueryExecutor e) : super(e);
  $LocalDatabaseManager get managers => $LocalDatabaseManager(this);
  late final $SuppliersTable suppliers = $SuppliersTable(this);
  late final $ClientsTable clients = $ClientsTable(this);
  late final $ProductsTable products = $ProductsTable(this);
  late final $ProductPricesTable productPrices = $ProductPricesTable(this);
  late final $ProductDiscountsTable productDiscounts = $ProductDiscountsTable(
    this,
  );
  late final $ProductSupplierPricesTable productSupplierPrices =
      $ProductSupplierPricesTable(this);
  late final $InventoryTable inventory = $InventoryTable(this);
  late final $InvoicesTable invoices = $InvoicesTable(this);
  late final $InvoiceItemsTable invoiceItems = $InvoiceItemsTable(this);
  late final $DeletedInvoiceItemsTable deletedInvoiceItems =
      $DeletedInvoiceItemsTable(this);
  late final $BadOrdersTable badOrders = $BadOrdersTable(this);
  late final $BadOrderItemsTable badOrderItems = $BadOrderItemsTable(this);
  late final $VanAreasTable vanAreas = $VanAreasTable(this);
  late final $VanStocksTable vanStocks = $VanStocksTable(this);
  late final $VanStockDraftsTable vanStockDrafts = $VanStockDraftsTable(this);
  late final $BadOrderDraftsTable badOrderDrafts = $BadOrderDraftsTable(this);
  late final $StockMovementsTable stockMovements = $StockMovementsTable(this);
  late final $InvoicePaymentsTable invoicePayments = $InvoicePaymentsTable(
    this,
  );
  late final $SupplierReceivedInvoicesTable supplierReceivedInvoices =
      $SupplierReceivedInvoicesTable(this);
  late final $SupplierReceivedInvoiceItemsTable supplierReceivedInvoiceItems =
      $SupplierReceivedInvoiceItemsTable(this);
  late final $PurchaseOrdersTable purchaseOrders = $PurchaseOrdersTable(this);
  late final $PurchaseOrderItemsTable purchaseOrderItems =
      $PurchaseOrderItemsTable(this);
  late final $PreOrderReviewsTable preOrderReviews = $PreOrderReviewsTable(
    this,
  );
  late final $PreOrderReviewItemsTable preOrderReviewItems =
      $PreOrderReviewItemsTable(this);
  late final $StocksLoadingsTable stocksLoadings = $StocksLoadingsTable(this);
  late final $StocksLoadingItemsTable stocksLoadingItems =
      $StocksLoadingItemsTable(this);
  late final $SyncQueueTable syncQueue = $SyncQueueTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    suppliers,
    clients,
    products,
    productPrices,
    productDiscounts,
    productSupplierPrices,
    inventory,
    invoices,
    invoiceItems,
    deletedInvoiceItems,
    badOrders,
    badOrderItems,
    vanAreas,
    vanStocks,
    vanStockDrafts,
    badOrderDrafts,
    stockMovements,
    invoicePayments,
    supplierReceivedInvoices,
    supplierReceivedInvoiceItems,
    purchaseOrders,
    purchaseOrderItems,
    preOrderReviews,
    preOrderReviewItems,
    stocksLoadings,
    stocksLoadingItems,
    syncQueue,
  ];
}

typedef $$SuppliersTableCreateCompanionBuilder =
    SuppliersCompanion Function({
      required String id,
      required String name,
      Value<String?> contact,
      Value<String?> address,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$SuppliersTableUpdateCompanionBuilder =
    SuppliersCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> contact,
      Value<String?> address,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$SuppliersTableReferences
    extends BaseReferences<_$LocalDatabase, $SuppliersTable, Supplier> {
  $$SuppliersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ProductsTable, List<Product>> _productsRefsTable(
    _$LocalDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.products,
    aliasName: $_aliasNameGenerator(db.suppliers.id, db.products.supplierId),
  );

  $$ProductsTableProcessedTableManager get productsRefs {
    final manager = $$ProductsTableTableManager(
      $_db,
      $_db.products,
    ).filter((f) => f.supplierId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_productsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $SupplierReceivedInvoicesTable,
    List<SupplierReceivedInvoice>
  >
  _supplierReceivedInvoicesRefsTable(_$LocalDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.supplierReceivedInvoices,
        aliasName: $_aliasNameGenerator(
          db.suppliers.id,
          db.supplierReceivedInvoices.supplierId,
        ),
      );

  $$SupplierReceivedInvoicesTableProcessedTableManager
  get supplierReceivedInvoicesRefs {
    final manager = $$SupplierReceivedInvoicesTableTableManager(
      $_db,
      $_db.supplierReceivedInvoices,
    ).filter((f) => f.supplierId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _supplierReceivedInvoicesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PurchaseOrdersTable, List<PurchaseOrder>>
  _purchaseOrdersRefsTable(_$LocalDatabase db) => MultiTypedResultKey.fromTable(
    db.purchaseOrders,
    aliasName: $_aliasNameGenerator(
      db.suppliers.id,
      db.purchaseOrders.supplierId,
    ),
  );

  $$PurchaseOrdersTableProcessedTableManager get purchaseOrdersRefs {
    final manager = $$PurchaseOrdersTableTableManager(
      $_db,
      $_db.purchaseOrders,
    ).filter((f) => f.supplierId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_purchaseOrdersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SuppliersTableFilterComposer
    extends Composer<_$LocalDatabase, $SuppliersTable> {
  $$SuppliersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contact => $composableBuilder(
    column: $table.contact,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> productsRefs(
    Expression<bool> Function($$ProductsTableFilterComposer f) f,
  ) {
    final $$ProductsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.supplierId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableFilterComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> supplierReceivedInvoicesRefs(
    Expression<bool> Function($$SupplierReceivedInvoicesTableFilterComposer f)
    f,
  ) {
    final $$SupplierReceivedInvoicesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.supplierReceivedInvoices,
          getReferencedColumn: (t) => t.supplierId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SupplierReceivedInvoicesTableFilterComposer(
                $db: $db,
                $table: $db.supplierReceivedInvoices,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> purchaseOrdersRefs(
    Expression<bool> Function($$PurchaseOrdersTableFilterComposer f) f,
  ) {
    final $$PurchaseOrdersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.purchaseOrders,
      getReferencedColumn: (t) => t.supplierId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PurchaseOrdersTableFilterComposer(
            $db: $db,
            $table: $db.purchaseOrders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SuppliersTableOrderingComposer
    extends Composer<_$LocalDatabase, $SuppliersTable> {
  $$SuppliersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contact => $composableBuilder(
    column: $table.contact,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SuppliersTableAnnotationComposer
    extends Composer<_$LocalDatabase, $SuppliersTable> {
  $$SuppliersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get contact =>
      $composableBuilder(column: $table.contact, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> productsRefs<T extends Object>(
    Expression<T> Function($$ProductsTableAnnotationComposer a) f,
  ) {
    final $$ProductsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.supplierId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableAnnotationComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> supplierReceivedInvoicesRefs<T extends Object>(
    Expression<T> Function($$SupplierReceivedInvoicesTableAnnotationComposer a)
    f,
  ) {
    final $$SupplierReceivedInvoicesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.supplierReceivedInvoices,
          getReferencedColumn: (t) => t.supplierId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SupplierReceivedInvoicesTableAnnotationComposer(
                $db: $db,
                $table: $db.supplierReceivedInvoices,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> purchaseOrdersRefs<T extends Object>(
    Expression<T> Function($$PurchaseOrdersTableAnnotationComposer a) f,
  ) {
    final $$PurchaseOrdersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.purchaseOrders,
      getReferencedColumn: (t) => t.supplierId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PurchaseOrdersTableAnnotationComposer(
            $db: $db,
            $table: $db.purchaseOrders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SuppliersTableTableManager
    extends
        RootTableManager<
          _$LocalDatabase,
          $SuppliersTable,
          Supplier,
          $$SuppliersTableFilterComposer,
          $$SuppliersTableOrderingComposer,
          $$SuppliersTableAnnotationComposer,
          $$SuppliersTableCreateCompanionBuilder,
          $$SuppliersTableUpdateCompanionBuilder,
          (Supplier, $$SuppliersTableReferences),
          Supplier,
          PrefetchHooks Function({
            bool productsRefs,
            bool supplierReceivedInvoicesRefs,
            bool purchaseOrdersRefs,
          })
        > {
  $$SuppliersTableTableManager(_$LocalDatabase db, $SuppliersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SuppliersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SuppliersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SuppliersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> contact = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SuppliersCompanion(
                id: id,
                name: name,
                contact: contact,
                address: address,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> contact = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SuppliersCompanion.insert(
                id: id,
                name: name,
                contact: contact,
                address: address,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SuppliersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                productsRefs = false,
                supplierReceivedInvoicesRefs = false,
                purchaseOrdersRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (productsRefs) db.products,
                    if (supplierReceivedInvoicesRefs)
                      db.supplierReceivedInvoices,
                    if (purchaseOrdersRefs) db.purchaseOrders,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (productsRefs)
                        await $_getPrefetchedData<
                          Supplier,
                          $SuppliersTable,
                          Product
                        >(
                          currentTable: table,
                          referencedTable: $$SuppliersTableReferences
                              ._productsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SuppliersTableReferences(
                                db,
                                table,
                                p0,
                              ).productsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.supplierId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (supplierReceivedInvoicesRefs)
                        await $_getPrefetchedData<
                          Supplier,
                          $SuppliersTable,
                          SupplierReceivedInvoice
                        >(
                          currentTable: table,
                          referencedTable: $$SuppliersTableReferences
                              ._supplierReceivedInvoicesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SuppliersTableReferences(
                                db,
                                table,
                                p0,
                              ).supplierReceivedInvoicesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.supplierId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (purchaseOrdersRefs)
                        await $_getPrefetchedData<
                          Supplier,
                          $SuppliersTable,
                          PurchaseOrder
                        >(
                          currentTable: table,
                          referencedTable: $$SuppliersTableReferences
                              ._purchaseOrdersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SuppliersTableReferences(
                                db,
                                table,
                                p0,
                              ).purchaseOrdersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.supplierId == item.id,
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

typedef $$SuppliersTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDatabase,
      $SuppliersTable,
      Supplier,
      $$SuppliersTableFilterComposer,
      $$SuppliersTableOrderingComposer,
      $$SuppliersTableAnnotationComposer,
      $$SuppliersTableCreateCompanionBuilder,
      $$SuppliersTableUpdateCompanionBuilder,
      (Supplier, $$SuppliersTableReferences),
      Supplier,
      PrefetchHooks Function({
        bool productsRefs,
        bool supplierReceivedInvoicesRefs,
        bool purchaseOrdersRefs,
      })
    >;
typedef $$ClientsTableCreateCompanionBuilder =
    ClientsCompanion Function({
      required String id,
      required String name,
      Value<String?> contact,
      Value<String?> address,
      Value<bool> isBlacklisted,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$ClientsTableUpdateCompanionBuilder =
    ClientsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> contact,
      Value<String?> address,
      Value<bool> isBlacklisted,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$ClientsTableReferences
    extends BaseReferences<_$LocalDatabase, $ClientsTable, Client> {
  $$ClientsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$InvoicesTable, List<Invoice>> _invoicesRefsTable(
    _$LocalDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.invoices,
    aliasName: $_aliasNameGenerator(db.clients.id, db.invoices.clientId),
  );

  $$InvoicesTableProcessedTableManager get invoicesRefs {
    final manager = $$InvoicesTableTableManager(
      $_db,
      $_db.invoices,
    ).filter((f) => f.clientId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_invoicesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$BadOrdersTable, List<BadOrder>>
  _badOrdersRefsTable(_$LocalDatabase db) => MultiTypedResultKey.fromTable(
    db.badOrders,
    aliasName: $_aliasNameGenerator(db.clients.id, db.badOrders.clientId),
  );

  $$BadOrdersTableProcessedTableManager get badOrdersRefs {
    final manager = $$BadOrdersTableTableManager(
      $_db,
      $_db.badOrders,
    ).filter((f) => f.clientId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_badOrdersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ClientsTableFilterComposer
    extends Composer<_$LocalDatabase, $ClientsTable> {
  $$ClientsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contact => $composableBuilder(
    column: $table.contact,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isBlacklisted => $composableBuilder(
    column: $table.isBlacklisted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> invoicesRefs(
    Expression<bool> Function($$InvoicesTableFilterComposer f) f,
  ) {
    final $$InvoicesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.invoices,
      getReferencedColumn: (t) => t.clientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvoicesTableFilterComposer(
            $db: $db,
            $table: $db.invoices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> badOrdersRefs(
    Expression<bool> Function($$BadOrdersTableFilterComposer f) f,
  ) {
    final $$BadOrdersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.badOrders,
      getReferencedColumn: (t) => t.clientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BadOrdersTableFilterComposer(
            $db: $db,
            $table: $db.badOrders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ClientsTableOrderingComposer
    extends Composer<_$LocalDatabase, $ClientsTable> {
  $$ClientsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contact => $composableBuilder(
    column: $table.contact,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isBlacklisted => $composableBuilder(
    column: $table.isBlacklisted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ClientsTableAnnotationComposer
    extends Composer<_$LocalDatabase, $ClientsTable> {
  $$ClientsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get contact =>
      $composableBuilder(column: $table.contact, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<bool> get isBlacklisted => $composableBuilder(
    column: $table.isBlacklisted,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> invoicesRefs<T extends Object>(
    Expression<T> Function($$InvoicesTableAnnotationComposer a) f,
  ) {
    final $$InvoicesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.invoices,
      getReferencedColumn: (t) => t.clientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvoicesTableAnnotationComposer(
            $db: $db,
            $table: $db.invoices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> badOrdersRefs<T extends Object>(
    Expression<T> Function($$BadOrdersTableAnnotationComposer a) f,
  ) {
    final $$BadOrdersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.badOrders,
      getReferencedColumn: (t) => t.clientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BadOrdersTableAnnotationComposer(
            $db: $db,
            $table: $db.badOrders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ClientsTableTableManager
    extends
        RootTableManager<
          _$LocalDatabase,
          $ClientsTable,
          Client,
          $$ClientsTableFilterComposer,
          $$ClientsTableOrderingComposer,
          $$ClientsTableAnnotationComposer,
          $$ClientsTableCreateCompanionBuilder,
          $$ClientsTableUpdateCompanionBuilder,
          (Client, $$ClientsTableReferences),
          Client,
          PrefetchHooks Function({bool invoicesRefs, bool badOrdersRefs})
        > {
  $$ClientsTableTableManager(_$LocalDatabase db, $ClientsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ClientsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ClientsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ClientsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> contact = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<bool> isBlacklisted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ClientsCompanion(
                id: id,
                name: name,
                contact: contact,
                address: address,
                isBlacklisted: isBlacklisted,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> contact = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<bool> isBlacklisted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ClientsCompanion.insert(
                id: id,
                name: name,
                contact: contact,
                address: address,
                isBlacklisted: isBlacklisted,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ClientsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({invoicesRefs = false, badOrdersRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (invoicesRefs) db.invoices,
                    if (badOrdersRefs) db.badOrders,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (invoicesRefs)
                        await $_getPrefetchedData<
                          Client,
                          $ClientsTable,
                          Invoice
                        >(
                          currentTable: table,
                          referencedTable: $$ClientsTableReferences
                              ._invoicesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ClientsTableReferences(
                                db,
                                table,
                                p0,
                              ).invoicesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.clientId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (badOrdersRefs)
                        await $_getPrefetchedData<
                          Client,
                          $ClientsTable,
                          BadOrder
                        >(
                          currentTable: table,
                          referencedTable: $$ClientsTableReferences
                              ._badOrdersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ClientsTableReferences(
                                db,
                                table,
                                p0,
                              ).badOrdersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.clientId == item.id,
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

typedef $$ClientsTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDatabase,
      $ClientsTable,
      Client,
      $$ClientsTableFilterComposer,
      $$ClientsTableOrderingComposer,
      $$ClientsTableAnnotationComposer,
      $$ClientsTableCreateCompanionBuilder,
      $$ClientsTableUpdateCompanionBuilder,
      (Client, $$ClientsTableReferences),
      Client,
      PrefetchHooks Function({bool invoicesRefs, bool badOrdersRefs})
    >;
typedef $$ProductsTableCreateCompanionBuilder =
    ProductsCompanion Function({
      required String id,
      required String name,
      Value<String?> productCode,
      required String supplierId,
      required int piecesPerBox,
      Value<DateTime> createdAt,
      Value<bool> isDeleted,
      Value<int?> reorderPoint,
      Value<int?> reorderQuantity,
      Value<int> rowid,
    });
typedef $$ProductsTableUpdateCompanionBuilder =
    ProductsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> productCode,
      Value<String> supplierId,
      Value<int> piecesPerBox,
      Value<DateTime> createdAt,
      Value<bool> isDeleted,
      Value<int?> reorderPoint,
      Value<int?> reorderQuantity,
      Value<int> rowid,
    });

final class $$ProductsTableReferences
    extends BaseReferences<_$LocalDatabase, $ProductsTable, Product> {
  $$ProductsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SuppliersTable _supplierIdTable(_$LocalDatabase db) =>
      db.suppliers.createAlias(
        $_aliasNameGenerator(db.products.supplierId, db.suppliers.id),
      );

  $$SuppliersTableProcessedTableManager get supplierId {
    final $_column = $_itemColumn<String>('supplier_id')!;

    final manager = $$SuppliersTableTableManager(
      $_db,
      $_db.suppliers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_supplierIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ProductPricesTable, List<ProductPrice>>
  _productPricesRefsTable(_$LocalDatabase db) => MultiTypedResultKey.fromTable(
    db.productPrices,
    aliasName: $_aliasNameGenerator(db.products.id, db.productPrices.productId),
  );

  $$ProductPricesTableProcessedTableManager get productPricesRefs {
    final manager = $$ProductPricesTableTableManager(
      $_db,
      $_db.productPrices,
    ).filter((f) => f.productId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_productPricesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ProductDiscountsTable, List<ProductDiscount>>
  _productDiscountsRefsTable(_$LocalDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.productDiscounts,
        aliasName: $_aliasNameGenerator(
          db.products.id,
          db.productDiscounts.productId,
        ),
      );

  $$ProductDiscountsTableProcessedTableManager get productDiscountsRefs {
    final manager = $$ProductDiscountsTableTableManager(
      $_db,
      $_db.productDiscounts,
    ).filter((f) => f.productId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _productDiscountsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $ProductSupplierPricesTable,
    List<ProductSupplierPrice>
  >
  _productSupplierPricesRefsTable(_$LocalDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.productSupplierPrices,
        aliasName: $_aliasNameGenerator(
          db.products.id,
          db.productSupplierPrices.productId,
        ),
      );

  $$ProductSupplierPricesTableProcessedTableManager
  get productSupplierPricesRefs {
    final manager = $$ProductSupplierPricesTableTableManager(
      $_db,
      $_db.productSupplierPrices,
    ).filter((f) => f.productId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _productSupplierPricesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$InventoryTable, List<InventoryData>>
  _inventoryRefsTable(_$LocalDatabase db) => MultiTypedResultKey.fromTable(
    db.inventory,
    aliasName: $_aliasNameGenerator(db.products.id, db.inventory.productId),
  );

  $$InventoryTableProcessedTableManager get inventoryRefs {
    final manager = $$InventoryTableTableManager(
      $_db,
      $_db.inventory,
    ).filter((f) => f.productId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_inventoryRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$InvoiceItemsTable, List<InvoiceItem>>
  _invoiceItemsRefsTable(_$LocalDatabase db) => MultiTypedResultKey.fromTable(
    db.invoiceItems,
    aliasName: $_aliasNameGenerator(db.products.id, db.invoiceItems.productId),
  );

  $$InvoiceItemsTableProcessedTableManager get invoiceItemsRefs {
    final manager = $$InvoiceItemsTableTableManager(
      $_db,
      $_db.invoiceItems,
    ).filter((f) => f.productId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_invoiceItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $DeletedInvoiceItemsTable,
    List<DeletedInvoiceItem>
  >
  _deletedInvoiceItemsRefsTable(_$LocalDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.deletedInvoiceItems,
        aliasName: $_aliasNameGenerator(
          db.products.id,
          db.deletedInvoiceItems.productId,
        ),
      );

  $$DeletedInvoiceItemsTableProcessedTableManager get deletedInvoiceItemsRefs {
    final manager = $$DeletedInvoiceItemsTableTableManager(
      $_db,
      $_db.deletedInvoiceItems,
    ).filter((f) => f.productId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _deletedInvoiceItemsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$BadOrderItemsTable, List<BadOrderItem>>
  _badOrderItemsRefsTable(_$LocalDatabase db) => MultiTypedResultKey.fromTable(
    db.badOrderItems,
    aliasName: $_aliasNameGenerator(db.products.id, db.badOrderItems.productId),
  );

  $$BadOrderItemsTableProcessedTableManager get badOrderItemsRefs {
    final manager = $$BadOrderItemsTableTableManager(
      $_db,
      $_db.badOrderItems,
    ).filter((f) => f.productId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_badOrderItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$VanStocksTable, List<VanStock>>
  _vanStocksRefsTable(_$LocalDatabase db) => MultiTypedResultKey.fromTable(
    db.vanStocks,
    aliasName: $_aliasNameGenerator(db.products.id, db.vanStocks.productId),
  );

  $$VanStocksTableProcessedTableManager get vanStocksRefs {
    final manager = $$VanStocksTableTableManager(
      $_db,
      $_db.vanStocks,
    ).filter((f) => f.productId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_vanStocksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$StockMovementsTable, List<StockMovement>>
  _stockMovementsRefsTable(_$LocalDatabase db) => MultiTypedResultKey.fromTable(
    db.stockMovements,
    aliasName: $_aliasNameGenerator(
      db.products.id,
      db.stockMovements.productId,
    ),
  );

  $$StockMovementsTableProcessedTableManager get stockMovementsRefs {
    final manager = $$StockMovementsTableTableManager(
      $_db,
      $_db.stockMovements,
    ).filter((f) => f.productId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_stockMovementsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $SupplierReceivedInvoiceItemsTable,
    List<SupplierReceivedInvoiceItem>
  >
  _supplierReceivedInvoiceItemsRefsTable(_$LocalDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.supplierReceivedInvoiceItems,
        aliasName: $_aliasNameGenerator(
          db.products.id,
          db.supplierReceivedInvoiceItems.productId,
        ),
      );

  $$SupplierReceivedInvoiceItemsTableProcessedTableManager
  get supplierReceivedInvoiceItemsRefs {
    final manager = $$SupplierReceivedInvoiceItemsTableTableManager(
      $_db,
      $_db.supplierReceivedInvoiceItems,
    ).filter((f) => f.productId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _supplierReceivedInvoiceItemsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PurchaseOrderItemsTable, List<PurchaseOrderItem>>
  _purchaseOrderItemsRefsTable(_$LocalDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.purchaseOrderItems,
        aliasName: $_aliasNameGenerator(
          db.products.id,
          db.purchaseOrderItems.productId,
        ),
      );

  $$PurchaseOrderItemsTableProcessedTableManager get purchaseOrderItemsRefs {
    final manager = $$PurchaseOrderItemsTableTableManager(
      $_db,
      $_db.purchaseOrderItems,
    ).filter((f) => f.productId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _purchaseOrderItemsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ProductsTableFilterComposer
    extends Composer<_$LocalDatabase, $ProductsTable> {
  $$ProductsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productCode => $composableBuilder(
    column: $table.productCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get piecesPerBox => $composableBuilder(
    column: $table.piecesPerBox,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reorderPoint => $composableBuilder(
    column: $table.reorderPoint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reorderQuantity => $composableBuilder(
    column: $table.reorderQuantity,
    builder: (column) => ColumnFilters(column),
  );

  $$SuppliersTableFilterComposer get supplierId {
    final $$SuppliersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.supplierId,
      referencedTable: $db.suppliers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SuppliersTableFilterComposer(
            $db: $db,
            $table: $db.suppliers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> productPricesRefs(
    Expression<bool> Function($$ProductPricesTableFilterComposer f) f,
  ) {
    final $$ProductPricesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.productPrices,
      getReferencedColumn: (t) => t.productId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductPricesTableFilterComposer(
            $db: $db,
            $table: $db.productPrices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> productDiscountsRefs(
    Expression<bool> Function($$ProductDiscountsTableFilterComposer f) f,
  ) {
    final $$ProductDiscountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.productDiscounts,
      getReferencedColumn: (t) => t.productId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductDiscountsTableFilterComposer(
            $db: $db,
            $table: $db.productDiscounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> productSupplierPricesRefs(
    Expression<bool> Function($$ProductSupplierPricesTableFilterComposer f) f,
  ) {
    final $$ProductSupplierPricesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.productSupplierPrices,
          getReferencedColumn: (t) => t.productId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ProductSupplierPricesTableFilterComposer(
                $db: $db,
                $table: $db.productSupplierPrices,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> inventoryRefs(
    Expression<bool> Function($$InventoryTableFilterComposer f) f,
  ) {
    final $$InventoryTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.inventory,
      getReferencedColumn: (t) => t.productId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InventoryTableFilterComposer(
            $db: $db,
            $table: $db.inventory,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> invoiceItemsRefs(
    Expression<bool> Function($$InvoiceItemsTableFilterComposer f) f,
  ) {
    final $$InvoiceItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.invoiceItems,
      getReferencedColumn: (t) => t.productId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvoiceItemsTableFilterComposer(
            $db: $db,
            $table: $db.invoiceItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> deletedInvoiceItemsRefs(
    Expression<bool> Function($$DeletedInvoiceItemsTableFilterComposer f) f,
  ) {
    final $$DeletedInvoiceItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.deletedInvoiceItems,
      getReferencedColumn: (t) => t.productId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DeletedInvoiceItemsTableFilterComposer(
            $db: $db,
            $table: $db.deletedInvoiceItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> badOrderItemsRefs(
    Expression<bool> Function($$BadOrderItemsTableFilterComposer f) f,
  ) {
    final $$BadOrderItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.badOrderItems,
      getReferencedColumn: (t) => t.productId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BadOrderItemsTableFilterComposer(
            $db: $db,
            $table: $db.badOrderItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> vanStocksRefs(
    Expression<bool> Function($$VanStocksTableFilterComposer f) f,
  ) {
    final $$VanStocksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.vanStocks,
      getReferencedColumn: (t) => t.productId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VanStocksTableFilterComposer(
            $db: $db,
            $table: $db.vanStocks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> stockMovementsRefs(
    Expression<bool> Function($$StockMovementsTableFilterComposer f) f,
  ) {
    final $$StockMovementsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.stockMovements,
      getReferencedColumn: (t) => t.productId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StockMovementsTableFilterComposer(
            $db: $db,
            $table: $db.stockMovements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> supplierReceivedInvoiceItemsRefs(
    Expression<bool> Function(
      $$SupplierReceivedInvoiceItemsTableFilterComposer f,
    )
    f,
  ) {
    final $$SupplierReceivedInvoiceItemsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.supplierReceivedInvoiceItems,
          getReferencedColumn: (t) => t.productId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SupplierReceivedInvoiceItemsTableFilterComposer(
                $db: $db,
                $table: $db.supplierReceivedInvoiceItems,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> purchaseOrderItemsRefs(
    Expression<bool> Function($$PurchaseOrderItemsTableFilterComposer f) f,
  ) {
    final $$PurchaseOrderItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.purchaseOrderItems,
      getReferencedColumn: (t) => t.productId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PurchaseOrderItemsTableFilterComposer(
            $db: $db,
            $table: $db.purchaseOrderItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProductsTableOrderingComposer
    extends Composer<_$LocalDatabase, $ProductsTable> {
  $$ProductsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productCode => $composableBuilder(
    column: $table.productCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get piecesPerBox => $composableBuilder(
    column: $table.piecesPerBox,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reorderPoint => $composableBuilder(
    column: $table.reorderPoint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reorderQuantity => $composableBuilder(
    column: $table.reorderQuantity,
    builder: (column) => ColumnOrderings(column),
  );

  $$SuppliersTableOrderingComposer get supplierId {
    final $$SuppliersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.supplierId,
      referencedTable: $db.suppliers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SuppliersTableOrderingComposer(
            $db: $db,
            $table: $db.suppliers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProductsTableAnnotationComposer
    extends Composer<_$LocalDatabase, $ProductsTable> {
  $$ProductsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get productCode => $composableBuilder(
    column: $table.productCode,
    builder: (column) => column,
  );

  GeneratedColumn<int> get piecesPerBox => $composableBuilder(
    column: $table.piecesPerBox,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<int> get reorderPoint => $composableBuilder(
    column: $table.reorderPoint,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reorderQuantity => $composableBuilder(
    column: $table.reorderQuantity,
    builder: (column) => column,
  );

  $$SuppliersTableAnnotationComposer get supplierId {
    final $$SuppliersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.supplierId,
      referencedTable: $db.suppliers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SuppliersTableAnnotationComposer(
            $db: $db,
            $table: $db.suppliers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> productPricesRefs<T extends Object>(
    Expression<T> Function($$ProductPricesTableAnnotationComposer a) f,
  ) {
    final $$ProductPricesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.productPrices,
      getReferencedColumn: (t) => t.productId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductPricesTableAnnotationComposer(
            $db: $db,
            $table: $db.productPrices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> productDiscountsRefs<T extends Object>(
    Expression<T> Function($$ProductDiscountsTableAnnotationComposer a) f,
  ) {
    final $$ProductDiscountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.productDiscounts,
      getReferencedColumn: (t) => t.productId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductDiscountsTableAnnotationComposer(
            $db: $db,
            $table: $db.productDiscounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> productSupplierPricesRefs<T extends Object>(
    Expression<T> Function($$ProductSupplierPricesTableAnnotationComposer a) f,
  ) {
    final $$ProductSupplierPricesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.productSupplierPrices,
          getReferencedColumn: (t) => t.productId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ProductSupplierPricesTableAnnotationComposer(
                $db: $db,
                $table: $db.productSupplierPrices,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> inventoryRefs<T extends Object>(
    Expression<T> Function($$InventoryTableAnnotationComposer a) f,
  ) {
    final $$InventoryTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.inventory,
      getReferencedColumn: (t) => t.productId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InventoryTableAnnotationComposer(
            $db: $db,
            $table: $db.inventory,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> invoiceItemsRefs<T extends Object>(
    Expression<T> Function($$InvoiceItemsTableAnnotationComposer a) f,
  ) {
    final $$InvoiceItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.invoiceItems,
      getReferencedColumn: (t) => t.productId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvoiceItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.invoiceItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> deletedInvoiceItemsRefs<T extends Object>(
    Expression<T> Function($$DeletedInvoiceItemsTableAnnotationComposer a) f,
  ) {
    final $$DeletedInvoiceItemsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.deletedInvoiceItems,
          getReferencedColumn: (t) => t.productId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$DeletedInvoiceItemsTableAnnotationComposer(
                $db: $db,
                $table: $db.deletedInvoiceItems,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> badOrderItemsRefs<T extends Object>(
    Expression<T> Function($$BadOrderItemsTableAnnotationComposer a) f,
  ) {
    final $$BadOrderItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.badOrderItems,
      getReferencedColumn: (t) => t.productId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BadOrderItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.badOrderItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> vanStocksRefs<T extends Object>(
    Expression<T> Function($$VanStocksTableAnnotationComposer a) f,
  ) {
    final $$VanStocksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.vanStocks,
      getReferencedColumn: (t) => t.productId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VanStocksTableAnnotationComposer(
            $db: $db,
            $table: $db.vanStocks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> stockMovementsRefs<T extends Object>(
    Expression<T> Function($$StockMovementsTableAnnotationComposer a) f,
  ) {
    final $$StockMovementsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.stockMovements,
      getReferencedColumn: (t) => t.productId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StockMovementsTableAnnotationComposer(
            $db: $db,
            $table: $db.stockMovements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> supplierReceivedInvoiceItemsRefs<T extends Object>(
    Expression<T> Function(
      $$SupplierReceivedInvoiceItemsTableAnnotationComposer a,
    )
    f,
  ) {
    final $$SupplierReceivedInvoiceItemsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.supplierReceivedInvoiceItems,
          getReferencedColumn: (t) => t.productId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SupplierReceivedInvoiceItemsTableAnnotationComposer(
                $db: $db,
                $table: $db.supplierReceivedInvoiceItems,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> purchaseOrderItemsRefs<T extends Object>(
    Expression<T> Function($$PurchaseOrderItemsTableAnnotationComposer a) f,
  ) {
    final $$PurchaseOrderItemsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.purchaseOrderItems,
          getReferencedColumn: (t) => t.productId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PurchaseOrderItemsTableAnnotationComposer(
                $db: $db,
                $table: $db.purchaseOrderItems,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ProductsTableTableManager
    extends
        RootTableManager<
          _$LocalDatabase,
          $ProductsTable,
          Product,
          $$ProductsTableFilterComposer,
          $$ProductsTableOrderingComposer,
          $$ProductsTableAnnotationComposer,
          $$ProductsTableCreateCompanionBuilder,
          $$ProductsTableUpdateCompanionBuilder,
          (Product, $$ProductsTableReferences),
          Product,
          PrefetchHooks Function({
            bool supplierId,
            bool productPricesRefs,
            bool productDiscountsRefs,
            bool productSupplierPricesRefs,
            bool inventoryRefs,
            bool invoiceItemsRefs,
            bool deletedInvoiceItemsRefs,
            bool badOrderItemsRefs,
            bool vanStocksRefs,
            bool stockMovementsRefs,
            bool supplierReceivedInvoiceItemsRefs,
            bool purchaseOrderItemsRefs,
          })
        > {
  $$ProductsTableTableManager(_$LocalDatabase db, $ProductsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> productCode = const Value.absent(),
                Value<String> supplierId = const Value.absent(),
                Value<int> piecesPerBox = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int?> reorderPoint = const Value.absent(),
                Value<int?> reorderQuantity = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductsCompanion(
                id: id,
                name: name,
                productCode: productCode,
                supplierId: supplierId,
                piecesPerBox: piecesPerBox,
                createdAt: createdAt,
                isDeleted: isDeleted,
                reorderPoint: reorderPoint,
                reorderQuantity: reorderQuantity,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> productCode = const Value.absent(),
                required String supplierId,
                required int piecesPerBox,
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int?> reorderPoint = const Value.absent(),
                Value<int?> reorderQuantity = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductsCompanion.insert(
                id: id,
                name: name,
                productCode: productCode,
                supplierId: supplierId,
                piecesPerBox: piecesPerBox,
                createdAt: createdAt,
                isDeleted: isDeleted,
                reorderPoint: reorderPoint,
                reorderQuantity: reorderQuantity,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProductsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                supplierId = false,
                productPricesRefs = false,
                productDiscountsRefs = false,
                productSupplierPricesRefs = false,
                inventoryRefs = false,
                invoiceItemsRefs = false,
                deletedInvoiceItemsRefs = false,
                badOrderItemsRefs = false,
                vanStocksRefs = false,
                stockMovementsRefs = false,
                supplierReceivedInvoiceItemsRefs = false,
                purchaseOrderItemsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (productPricesRefs) db.productPrices,
                    if (productDiscountsRefs) db.productDiscounts,
                    if (productSupplierPricesRefs) db.productSupplierPrices,
                    if (inventoryRefs) db.inventory,
                    if (invoiceItemsRefs) db.invoiceItems,
                    if (deletedInvoiceItemsRefs) db.deletedInvoiceItems,
                    if (badOrderItemsRefs) db.badOrderItems,
                    if (vanStocksRefs) db.vanStocks,
                    if (stockMovementsRefs) db.stockMovements,
                    if (supplierReceivedInvoiceItemsRefs)
                      db.supplierReceivedInvoiceItems,
                    if (purchaseOrderItemsRefs) db.purchaseOrderItems,
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
                        if (supplierId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.supplierId,
                                    referencedTable: $$ProductsTableReferences
                                        ._supplierIdTable(db),
                                    referencedColumn: $$ProductsTableReferences
                                        ._supplierIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (productPricesRefs)
                        await $_getPrefetchedData<
                          Product,
                          $ProductsTable,
                          ProductPrice
                        >(
                          currentTable: table,
                          referencedTable: $$ProductsTableReferences
                              ._productPricesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProductsTableReferences(
                                db,
                                table,
                                p0,
                              ).productPricesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.productId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (productDiscountsRefs)
                        await $_getPrefetchedData<
                          Product,
                          $ProductsTable,
                          ProductDiscount
                        >(
                          currentTable: table,
                          referencedTable: $$ProductsTableReferences
                              ._productDiscountsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProductsTableReferences(
                                db,
                                table,
                                p0,
                              ).productDiscountsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.productId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (productSupplierPricesRefs)
                        await $_getPrefetchedData<
                          Product,
                          $ProductsTable,
                          ProductSupplierPrice
                        >(
                          currentTable: table,
                          referencedTable: $$ProductsTableReferences
                              ._productSupplierPricesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProductsTableReferences(
                                db,
                                table,
                                p0,
                              ).productSupplierPricesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.productId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (inventoryRefs)
                        await $_getPrefetchedData<
                          Product,
                          $ProductsTable,
                          InventoryData
                        >(
                          currentTable: table,
                          referencedTable: $$ProductsTableReferences
                              ._inventoryRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProductsTableReferences(
                                db,
                                table,
                                p0,
                              ).inventoryRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.productId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (invoiceItemsRefs)
                        await $_getPrefetchedData<
                          Product,
                          $ProductsTable,
                          InvoiceItem
                        >(
                          currentTable: table,
                          referencedTable: $$ProductsTableReferences
                              ._invoiceItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProductsTableReferences(
                                db,
                                table,
                                p0,
                              ).invoiceItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.productId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (deletedInvoiceItemsRefs)
                        await $_getPrefetchedData<
                          Product,
                          $ProductsTable,
                          DeletedInvoiceItem
                        >(
                          currentTable: table,
                          referencedTable: $$ProductsTableReferences
                              ._deletedInvoiceItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProductsTableReferences(
                                db,
                                table,
                                p0,
                              ).deletedInvoiceItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.productId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (badOrderItemsRefs)
                        await $_getPrefetchedData<
                          Product,
                          $ProductsTable,
                          BadOrderItem
                        >(
                          currentTable: table,
                          referencedTable: $$ProductsTableReferences
                              ._badOrderItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProductsTableReferences(
                                db,
                                table,
                                p0,
                              ).badOrderItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.productId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (vanStocksRefs)
                        await $_getPrefetchedData<
                          Product,
                          $ProductsTable,
                          VanStock
                        >(
                          currentTable: table,
                          referencedTable: $$ProductsTableReferences
                              ._vanStocksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProductsTableReferences(
                                db,
                                table,
                                p0,
                              ).vanStocksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.productId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (stockMovementsRefs)
                        await $_getPrefetchedData<
                          Product,
                          $ProductsTable,
                          StockMovement
                        >(
                          currentTable: table,
                          referencedTable: $$ProductsTableReferences
                              ._stockMovementsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProductsTableReferences(
                                db,
                                table,
                                p0,
                              ).stockMovementsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.productId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (supplierReceivedInvoiceItemsRefs)
                        await $_getPrefetchedData<
                          Product,
                          $ProductsTable,
                          SupplierReceivedInvoiceItem
                        >(
                          currentTable: table,
                          referencedTable: $$ProductsTableReferences
                              ._supplierReceivedInvoiceItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProductsTableReferences(
                                db,
                                table,
                                p0,
                              ).supplierReceivedInvoiceItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.productId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (purchaseOrderItemsRefs)
                        await $_getPrefetchedData<
                          Product,
                          $ProductsTable,
                          PurchaseOrderItem
                        >(
                          currentTable: table,
                          referencedTable: $$ProductsTableReferences
                              ._purchaseOrderItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProductsTableReferences(
                                db,
                                table,
                                p0,
                              ).purchaseOrderItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.productId == item.id,
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

typedef $$ProductsTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDatabase,
      $ProductsTable,
      Product,
      $$ProductsTableFilterComposer,
      $$ProductsTableOrderingComposer,
      $$ProductsTableAnnotationComposer,
      $$ProductsTableCreateCompanionBuilder,
      $$ProductsTableUpdateCompanionBuilder,
      (Product, $$ProductsTableReferences),
      Product,
      PrefetchHooks Function({
        bool supplierId,
        bool productPricesRefs,
        bool productDiscountsRefs,
        bool productSupplierPricesRefs,
        bool inventoryRefs,
        bool invoiceItemsRefs,
        bool deletedInvoiceItemsRefs,
        bool badOrderItemsRefs,
        bool vanStocksRefs,
        bool stockMovementsRefs,
        bool supplierReceivedInvoiceItemsRefs,
        bool purchaseOrderItemsRefs,
      })
    >;
typedef $$ProductPricesTableCreateCompanionBuilder =
    ProductPricesCompanion Function({
      required String id,
      required String productId,
      required double withdrawalPrice,
      required double sellingPrice,
      Value<double?> sellingPriceOp,
      Value<DateTime> effectiveFrom,
      Value<int> rowid,
    });
typedef $$ProductPricesTableUpdateCompanionBuilder =
    ProductPricesCompanion Function({
      Value<String> id,
      Value<String> productId,
      Value<double> withdrawalPrice,
      Value<double> sellingPrice,
      Value<double?> sellingPriceOp,
      Value<DateTime> effectiveFrom,
      Value<int> rowid,
    });

final class $$ProductPricesTableReferences
    extends BaseReferences<_$LocalDatabase, $ProductPricesTable, ProductPrice> {
  $$ProductPricesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ProductsTable _productIdTable(_$LocalDatabase db) =>
      db.products.createAlias(
        $_aliasNameGenerator(db.productPrices.productId, db.products.id),
      );

  $$ProductsTableProcessedTableManager get productId {
    final $_column = $_itemColumn<String>('product_id')!;

    final manager = $$ProductsTableTableManager(
      $_db,
      $_db.products,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_productIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ProductPricesTableFilterComposer
    extends Composer<_$LocalDatabase, $ProductPricesTable> {
  $$ProductPricesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get withdrawalPrice => $composableBuilder(
    column: $table.withdrawalPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sellingPrice => $composableBuilder(
    column: $table.sellingPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sellingPriceOp => $composableBuilder(
    column: $table.sellingPriceOp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get effectiveFrom => $composableBuilder(
    column: $table.effectiveFrom,
    builder: (column) => ColumnFilters(column),
  );

  $$ProductsTableFilterComposer get productId {
    final $$ProductsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableFilterComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProductPricesTableOrderingComposer
    extends Composer<_$LocalDatabase, $ProductPricesTable> {
  $$ProductPricesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get withdrawalPrice => $composableBuilder(
    column: $table.withdrawalPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sellingPrice => $composableBuilder(
    column: $table.sellingPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sellingPriceOp => $composableBuilder(
    column: $table.sellingPriceOp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get effectiveFrom => $composableBuilder(
    column: $table.effectiveFrom,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProductsTableOrderingComposer get productId {
    final $$ProductsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableOrderingComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProductPricesTableAnnotationComposer
    extends Composer<_$LocalDatabase, $ProductPricesTable> {
  $$ProductPricesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get withdrawalPrice => $composableBuilder(
    column: $table.withdrawalPrice,
    builder: (column) => column,
  );

  GeneratedColumn<double> get sellingPrice => $composableBuilder(
    column: $table.sellingPrice,
    builder: (column) => column,
  );

  GeneratedColumn<double> get sellingPriceOp => $composableBuilder(
    column: $table.sellingPriceOp,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get effectiveFrom => $composableBuilder(
    column: $table.effectiveFrom,
    builder: (column) => column,
  );

  $$ProductsTableAnnotationComposer get productId {
    final $$ProductsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableAnnotationComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProductPricesTableTableManager
    extends
        RootTableManager<
          _$LocalDatabase,
          $ProductPricesTable,
          ProductPrice,
          $$ProductPricesTableFilterComposer,
          $$ProductPricesTableOrderingComposer,
          $$ProductPricesTableAnnotationComposer,
          $$ProductPricesTableCreateCompanionBuilder,
          $$ProductPricesTableUpdateCompanionBuilder,
          (ProductPrice, $$ProductPricesTableReferences),
          ProductPrice,
          PrefetchHooks Function({bool productId})
        > {
  $$ProductPricesTableTableManager(
    _$LocalDatabase db,
    $ProductPricesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductPricesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductPricesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductPricesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> productId = const Value.absent(),
                Value<double> withdrawalPrice = const Value.absent(),
                Value<double> sellingPrice = const Value.absent(),
                Value<double?> sellingPriceOp = const Value.absent(),
                Value<DateTime> effectiveFrom = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductPricesCompanion(
                id: id,
                productId: productId,
                withdrawalPrice: withdrawalPrice,
                sellingPrice: sellingPrice,
                sellingPriceOp: sellingPriceOp,
                effectiveFrom: effectiveFrom,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String productId,
                required double withdrawalPrice,
                required double sellingPrice,
                Value<double?> sellingPriceOp = const Value.absent(),
                Value<DateTime> effectiveFrom = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductPricesCompanion.insert(
                id: id,
                productId: productId,
                withdrawalPrice: withdrawalPrice,
                sellingPrice: sellingPrice,
                sellingPriceOp: sellingPriceOp,
                effectiveFrom: effectiveFrom,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProductPricesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({productId = false}) {
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
                    if (productId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.productId,
                                referencedTable: $$ProductPricesTableReferences
                                    ._productIdTable(db),
                                referencedColumn: $$ProductPricesTableReferences
                                    ._productIdTable(db)
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

typedef $$ProductPricesTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDatabase,
      $ProductPricesTable,
      ProductPrice,
      $$ProductPricesTableFilterComposer,
      $$ProductPricesTableOrderingComposer,
      $$ProductPricesTableAnnotationComposer,
      $$ProductPricesTableCreateCompanionBuilder,
      $$ProductPricesTableUpdateCompanionBuilder,
      (ProductPrice, $$ProductPricesTableReferences),
      ProductPrice,
      PrefetchHooks Function({bool productId})
    >;
typedef $$ProductDiscountsTableCreateCompanionBuilder =
    ProductDiscountsCompanion Function({
      required String id,
      required String productId,
      required int minQuantityPieces,
      required double discountPercent,
      Value<String> discountType,
      Value<int?> freeQuantityPieces,
      Value<String> freeQuantityUnit,
      Value<int> rowid,
    });
typedef $$ProductDiscountsTableUpdateCompanionBuilder =
    ProductDiscountsCompanion Function({
      Value<String> id,
      Value<String> productId,
      Value<int> minQuantityPieces,
      Value<double> discountPercent,
      Value<String> discountType,
      Value<int?> freeQuantityPieces,
      Value<String> freeQuantityUnit,
      Value<int> rowid,
    });

final class $$ProductDiscountsTableReferences
    extends
        BaseReferences<
          _$LocalDatabase,
          $ProductDiscountsTable,
          ProductDiscount
        > {
  $$ProductDiscountsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ProductsTable _productIdTable(_$LocalDatabase db) =>
      db.products.createAlias(
        $_aliasNameGenerator(db.productDiscounts.productId, db.products.id),
      );

  $$ProductsTableProcessedTableManager get productId {
    final $_column = $_itemColumn<String>('product_id')!;

    final manager = $$ProductsTableTableManager(
      $_db,
      $_db.products,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_productIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ProductDiscountsTableFilterComposer
    extends Composer<_$LocalDatabase, $ProductDiscountsTable> {
  $$ProductDiscountsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minQuantityPieces => $composableBuilder(
    column: $table.minQuantityPieces,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get discountPercent => $composableBuilder(
    column: $table.discountPercent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get discountType => $composableBuilder(
    column: $table.discountType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get freeQuantityPieces => $composableBuilder(
    column: $table.freeQuantityPieces,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get freeQuantityUnit => $composableBuilder(
    column: $table.freeQuantityUnit,
    builder: (column) => ColumnFilters(column),
  );

  $$ProductsTableFilterComposer get productId {
    final $$ProductsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableFilterComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProductDiscountsTableOrderingComposer
    extends Composer<_$LocalDatabase, $ProductDiscountsTable> {
  $$ProductDiscountsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minQuantityPieces => $composableBuilder(
    column: $table.minQuantityPieces,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get discountPercent => $composableBuilder(
    column: $table.discountPercent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get discountType => $composableBuilder(
    column: $table.discountType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get freeQuantityPieces => $composableBuilder(
    column: $table.freeQuantityPieces,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get freeQuantityUnit => $composableBuilder(
    column: $table.freeQuantityUnit,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProductsTableOrderingComposer get productId {
    final $$ProductsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableOrderingComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProductDiscountsTableAnnotationComposer
    extends Composer<_$LocalDatabase, $ProductDiscountsTable> {
  $$ProductDiscountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get minQuantityPieces => $composableBuilder(
    column: $table.minQuantityPieces,
    builder: (column) => column,
  );

  GeneratedColumn<double> get discountPercent => $composableBuilder(
    column: $table.discountPercent,
    builder: (column) => column,
  );

  GeneratedColumn<String> get discountType => $composableBuilder(
    column: $table.discountType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get freeQuantityPieces => $composableBuilder(
    column: $table.freeQuantityPieces,
    builder: (column) => column,
  );

  GeneratedColumn<String> get freeQuantityUnit => $composableBuilder(
    column: $table.freeQuantityUnit,
    builder: (column) => column,
  );

  $$ProductsTableAnnotationComposer get productId {
    final $$ProductsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableAnnotationComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProductDiscountsTableTableManager
    extends
        RootTableManager<
          _$LocalDatabase,
          $ProductDiscountsTable,
          ProductDiscount,
          $$ProductDiscountsTableFilterComposer,
          $$ProductDiscountsTableOrderingComposer,
          $$ProductDiscountsTableAnnotationComposer,
          $$ProductDiscountsTableCreateCompanionBuilder,
          $$ProductDiscountsTableUpdateCompanionBuilder,
          (ProductDiscount, $$ProductDiscountsTableReferences),
          ProductDiscount,
          PrefetchHooks Function({bool productId})
        > {
  $$ProductDiscountsTableTableManager(
    _$LocalDatabase db,
    $ProductDiscountsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductDiscountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductDiscountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductDiscountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> productId = const Value.absent(),
                Value<int> minQuantityPieces = const Value.absent(),
                Value<double> discountPercent = const Value.absent(),
                Value<String> discountType = const Value.absent(),
                Value<int?> freeQuantityPieces = const Value.absent(),
                Value<String> freeQuantityUnit = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductDiscountsCompanion(
                id: id,
                productId: productId,
                minQuantityPieces: minQuantityPieces,
                discountPercent: discountPercent,
                discountType: discountType,
                freeQuantityPieces: freeQuantityPieces,
                freeQuantityUnit: freeQuantityUnit,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String productId,
                required int minQuantityPieces,
                required double discountPercent,
                Value<String> discountType = const Value.absent(),
                Value<int?> freeQuantityPieces = const Value.absent(),
                Value<String> freeQuantityUnit = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductDiscountsCompanion.insert(
                id: id,
                productId: productId,
                minQuantityPieces: minQuantityPieces,
                discountPercent: discountPercent,
                discountType: discountType,
                freeQuantityPieces: freeQuantityPieces,
                freeQuantityUnit: freeQuantityUnit,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProductDiscountsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({productId = false}) {
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
                    if (productId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.productId,
                                referencedTable:
                                    $$ProductDiscountsTableReferences
                                        ._productIdTable(db),
                                referencedColumn:
                                    $$ProductDiscountsTableReferences
                                        ._productIdTable(db)
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

typedef $$ProductDiscountsTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDatabase,
      $ProductDiscountsTable,
      ProductDiscount,
      $$ProductDiscountsTableFilterComposer,
      $$ProductDiscountsTableOrderingComposer,
      $$ProductDiscountsTableAnnotationComposer,
      $$ProductDiscountsTableCreateCompanionBuilder,
      $$ProductDiscountsTableUpdateCompanionBuilder,
      (ProductDiscount, $$ProductDiscountsTableReferences),
      ProductDiscount,
      PrefetchHooks Function({bool productId})
    >;
typedef $$ProductSupplierPricesTableCreateCompanionBuilder =
    ProductSupplierPricesCompanion Function({
      required String id,
      required String productId,
      required double priceBox,
      Value<String?> discountPercents,
      Value<bool> vatEnabled,
      Value<int?> buyMinQuantityPieces,
      Value<int?> freeQuantityPieces,
      Value<String> freeQuantityUnit,
      Value<int> rowid,
    });
typedef $$ProductSupplierPricesTableUpdateCompanionBuilder =
    ProductSupplierPricesCompanion Function({
      Value<String> id,
      Value<String> productId,
      Value<double> priceBox,
      Value<String?> discountPercents,
      Value<bool> vatEnabled,
      Value<int?> buyMinQuantityPieces,
      Value<int?> freeQuantityPieces,
      Value<String> freeQuantityUnit,
      Value<int> rowid,
    });

final class $$ProductSupplierPricesTableReferences
    extends
        BaseReferences<
          _$LocalDatabase,
          $ProductSupplierPricesTable,
          ProductSupplierPrice
        > {
  $$ProductSupplierPricesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ProductsTable _productIdTable(_$LocalDatabase db) =>
      db.products.createAlias(
        $_aliasNameGenerator(
          db.productSupplierPrices.productId,
          db.products.id,
        ),
      );

  $$ProductsTableProcessedTableManager get productId {
    final $_column = $_itemColumn<String>('product_id')!;

    final manager = $$ProductsTableTableManager(
      $_db,
      $_db.products,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_productIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ProductSupplierPricesTableFilterComposer
    extends Composer<_$LocalDatabase, $ProductSupplierPricesTable> {
  $$ProductSupplierPricesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get priceBox => $composableBuilder(
    column: $table.priceBox,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get discountPercents => $composableBuilder(
    column: $table.discountPercents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get vatEnabled => $composableBuilder(
    column: $table.vatEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get buyMinQuantityPieces => $composableBuilder(
    column: $table.buyMinQuantityPieces,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get freeQuantityPieces => $composableBuilder(
    column: $table.freeQuantityPieces,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get freeQuantityUnit => $composableBuilder(
    column: $table.freeQuantityUnit,
    builder: (column) => ColumnFilters(column),
  );

  $$ProductsTableFilterComposer get productId {
    final $$ProductsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableFilterComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProductSupplierPricesTableOrderingComposer
    extends Composer<_$LocalDatabase, $ProductSupplierPricesTable> {
  $$ProductSupplierPricesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get priceBox => $composableBuilder(
    column: $table.priceBox,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get discountPercents => $composableBuilder(
    column: $table.discountPercents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get vatEnabled => $composableBuilder(
    column: $table.vatEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get buyMinQuantityPieces => $composableBuilder(
    column: $table.buyMinQuantityPieces,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get freeQuantityPieces => $composableBuilder(
    column: $table.freeQuantityPieces,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get freeQuantityUnit => $composableBuilder(
    column: $table.freeQuantityUnit,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProductsTableOrderingComposer get productId {
    final $$ProductsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableOrderingComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProductSupplierPricesTableAnnotationComposer
    extends Composer<_$LocalDatabase, $ProductSupplierPricesTable> {
  $$ProductSupplierPricesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get priceBox =>
      $composableBuilder(column: $table.priceBox, builder: (column) => column);

  GeneratedColumn<String> get discountPercents => $composableBuilder(
    column: $table.discountPercents,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get vatEnabled => $composableBuilder(
    column: $table.vatEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<int> get buyMinQuantityPieces => $composableBuilder(
    column: $table.buyMinQuantityPieces,
    builder: (column) => column,
  );

  GeneratedColumn<int> get freeQuantityPieces => $composableBuilder(
    column: $table.freeQuantityPieces,
    builder: (column) => column,
  );

  GeneratedColumn<String> get freeQuantityUnit => $composableBuilder(
    column: $table.freeQuantityUnit,
    builder: (column) => column,
  );

  $$ProductsTableAnnotationComposer get productId {
    final $$ProductsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableAnnotationComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProductSupplierPricesTableTableManager
    extends
        RootTableManager<
          _$LocalDatabase,
          $ProductSupplierPricesTable,
          ProductSupplierPrice,
          $$ProductSupplierPricesTableFilterComposer,
          $$ProductSupplierPricesTableOrderingComposer,
          $$ProductSupplierPricesTableAnnotationComposer,
          $$ProductSupplierPricesTableCreateCompanionBuilder,
          $$ProductSupplierPricesTableUpdateCompanionBuilder,
          (ProductSupplierPrice, $$ProductSupplierPricesTableReferences),
          ProductSupplierPrice,
          PrefetchHooks Function({bool productId})
        > {
  $$ProductSupplierPricesTableTableManager(
    _$LocalDatabase db,
    $ProductSupplierPricesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductSupplierPricesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ProductSupplierPricesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ProductSupplierPricesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> productId = const Value.absent(),
                Value<double> priceBox = const Value.absent(),
                Value<String?> discountPercents = const Value.absent(),
                Value<bool> vatEnabled = const Value.absent(),
                Value<int?> buyMinQuantityPieces = const Value.absent(),
                Value<int?> freeQuantityPieces = const Value.absent(),
                Value<String> freeQuantityUnit = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductSupplierPricesCompanion(
                id: id,
                productId: productId,
                priceBox: priceBox,
                discountPercents: discountPercents,
                vatEnabled: vatEnabled,
                buyMinQuantityPieces: buyMinQuantityPieces,
                freeQuantityPieces: freeQuantityPieces,
                freeQuantityUnit: freeQuantityUnit,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String productId,
                required double priceBox,
                Value<String?> discountPercents = const Value.absent(),
                Value<bool> vatEnabled = const Value.absent(),
                Value<int?> buyMinQuantityPieces = const Value.absent(),
                Value<int?> freeQuantityPieces = const Value.absent(),
                Value<String> freeQuantityUnit = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductSupplierPricesCompanion.insert(
                id: id,
                productId: productId,
                priceBox: priceBox,
                discountPercents: discountPercents,
                vatEnabled: vatEnabled,
                buyMinQuantityPieces: buyMinQuantityPieces,
                freeQuantityPieces: freeQuantityPieces,
                freeQuantityUnit: freeQuantityUnit,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProductSupplierPricesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({productId = false}) {
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
                    if (productId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.productId,
                                referencedTable:
                                    $$ProductSupplierPricesTableReferences
                                        ._productIdTable(db),
                                referencedColumn:
                                    $$ProductSupplierPricesTableReferences
                                        ._productIdTable(db)
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

typedef $$ProductSupplierPricesTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDatabase,
      $ProductSupplierPricesTable,
      ProductSupplierPrice,
      $$ProductSupplierPricesTableFilterComposer,
      $$ProductSupplierPricesTableOrderingComposer,
      $$ProductSupplierPricesTableAnnotationComposer,
      $$ProductSupplierPricesTableCreateCompanionBuilder,
      $$ProductSupplierPricesTableUpdateCompanionBuilder,
      (ProductSupplierPrice, $$ProductSupplierPricesTableReferences),
      ProductSupplierPrice,
      PrefetchHooks Function({bool productId})
    >;
typedef $$InventoryTableCreateCompanionBuilder =
    InventoryCompanion Function({
      required String id,
      required String productId,
      Value<int> quantityPieces,
      Value<DateTime> lastUpdated,
      Value<int> rowid,
    });
typedef $$InventoryTableUpdateCompanionBuilder =
    InventoryCompanion Function({
      Value<String> id,
      Value<String> productId,
      Value<int> quantityPieces,
      Value<DateTime> lastUpdated,
      Value<int> rowid,
    });

final class $$InventoryTableReferences
    extends BaseReferences<_$LocalDatabase, $InventoryTable, InventoryData> {
  $$InventoryTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProductsTable _productIdTable(_$LocalDatabase db) =>
      db.products.createAlias(
        $_aliasNameGenerator(db.inventory.productId, db.products.id),
      );

  $$ProductsTableProcessedTableManager get productId {
    final $_column = $_itemColumn<String>('product_id')!;

    final manager = $$ProductsTableTableManager(
      $_db,
      $_db.products,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_productIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$InventoryTableFilterComposer
    extends Composer<_$LocalDatabase, $InventoryTable> {
  $$InventoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantityPieces => $composableBuilder(
    column: $table.quantityPieces,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => ColumnFilters(column),
  );

  $$ProductsTableFilterComposer get productId {
    final $$ProductsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableFilterComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InventoryTableOrderingComposer
    extends Composer<_$LocalDatabase, $InventoryTable> {
  $$InventoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantityPieces => $composableBuilder(
    column: $table.quantityPieces,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProductsTableOrderingComposer get productId {
    final $$ProductsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableOrderingComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InventoryTableAnnotationComposer
    extends Composer<_$LocalDatabase, $InventoryTable> {
  $$InventoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get quantityPieces => $composableBuilder(
    column: $table.quantityPieces,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => column,
  );

  $$ProductsTableAnnotationComposer get productId {
    final $$ProductsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableAnnotationComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InventoryTableTableManager
    extends
        RootTableManager<
          _$LocalDatabase,
          $InventoryTable,
          InventoryData,
          $$InventoryTableFilterComposer,
          $$InventoryTableOrderingComposer,
          $$InventoryTableAnnotationComposer,
          $$InventoryTableCreateCompanionBuilder,
          $$InventoryTableUpdateCompanionBuilder,
          (InventoryData, $$InventoryTableReferences),
          InventoryData,
          PrefetchHooks Function({bool productId})
        > {
  $$InventoryTableTableManager(_$LocalDatabase db, $InventoryTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InventoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InventoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InventoryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> productId = const Value.absent(),
                Value<int> quantityPieces = const Value.absent(),
                Value<DateTime> lastUpdated = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InventoryCompanion(
                id: id,
                productId: productId,
                quantityPieces: quantityPieces,
                lastUpdated: lastUpdated,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String productId,
                Value<int> quantityPieces = const Value.absent(),
                Value<DateTime> lastUpdated = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InventoryCompanion.insert(
                id: id,
                productId: productId,
                quantityPieces: quantityPieces,
                lastUpdated: lastUpdated,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$InventoryTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({productId = false}) {
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
                    if (productId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.productId,
                                referencedTable: $$InventoryTableReferences
                                    ._productIdTable(db),
                                referencedColumn: $$InventoryTableReferences
                                    ._productIdTable(db)
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

typedef $$InventoryTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDatabase,
      $InventoryTable,
      InventoryData,
      $$InventoryTableFilterComposer,
      $$InventoryTableOrderingComposer,
      $$InventoryTableAnnotationComposer,
      $$InventoryTableCreateCompanionBuilder,
      $$InventoryTableUpdateCompanionBuilder,
      (InventoryData, $$InventoryTableReferences),
      InventoryData,
      PrefetchHooks Function({bool productId})
    >;
typedef $$InvoicesTableCreateCompanionBuilder =
    InvoicesCompanion Function({
      required String id,
      required String clientId,
      Value<DateTime> invoiceDate,
      Value<double> totalAmount,
      Value<String> status,
      Value<DateTime> createdAt,
      Value<String?> invoiceNumber,
      Value<int?> sequenceNumber,
      Value<String> invoiceType,
      Value<String> paymentType,
      Value<double?> partialAmount,
      Value<DateTime?> partialDate,
      Value<String?> checkReference,
      Value<double?> checkAmount,
      Value<DateTime?> checkIssuedDate,
      Value<DateTime?> checkDueDate,
      Value<String?> notes,
      Value<double?> actualAmount,
      Value<double?> swapAmount,
      Value<double?> stockPulledOutAmount,
      Value<double?> stockPulledOutCost,
      Value<bool> includeInLayout,
      Value<int> rowid,
    });
typedef $$InvoicesTableUpdateCompanionBuilder =
    InvoicesCompanion Function({
      Value<String> id,
      Value<String> clientId,
      Value<DateTime> invoiceDate,
      Value<double> totalAmount,
      Value<String> status,
      Value<DateTime> createdAt,
      Value<String?> invoiceNumber,
      Value<int?> sequenceNumber,
      Value<String> invoiceType,
      Value<String> paymentType,
      Value<double?> partialAmount,
      Value<DateTime?> partialDate,
      Value<String?> checkReference,
      Value<double?> checkAmount,
      Value<DateTime?> checkIssuedDate,
      Value<DateTime?> checkDueDate,
      Value<String?> notes,
      Value<double?> actualAmount,
      Value<double?> swapAmount,
      Value<double?> stockPulledOutAmount,
      Value<double?> stockPulledOutCost,
      Value<bool> includeInLayout,
      Value<int> rowid,
    });

final class $$InvoicesTableReferences
    extends BaseReferences<_$LocalDatabase, $InvoicesTable, Invoice> {
  $$InvoicesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ClientsTable _clientIdTable(_$LocalDatabase db) => db.clients
      .createAlias($_aliasNameGenerator(db.invoices.clientId, db.clients.id));

  $$ClientsTableProcessedTableManager get clientId {
    final $_column = $_itemColumn<String>('client_id')!;

    final manager = $$ClientsTableTableManager(
      $_db,
      $_db.clients,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_clientIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$InvoiceItemsTable, List<InvoiceItem>>
  _invoiceItemsRefsTable(_$LocalDatabase db) => MultiTypedResultKey.fromTable(
    db.invoiceItems,
    aliasName: $_aliasNameGenerator(db.invoices.id, db.invoiceItems.invoiceId),
  );

  $$InvoiceItemsTableProcessedTableManager get invoiceItemsRefs {
    final manager = $$InvoiceItemsTableTableManager(
      $_db,
      $_db.invoiceItems,
    ).filter((f) => f.invoiceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_invoiceItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $DeletedInvoiceItemsTable,
    List<DeletedInvoiceItem>
  >
  _deletedInvoiceItemsRefsTable(_$LocalDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.deletedInvoiceItems,
        aliasName: $_aliasNameGenerator(
          db.invoices.id,
          db.deletedInvoiceItems.invoiceId,
        ),
      );

  $$DeletedInvoiceItemsTableProcessedTableManager get deletedInvoiceItemsRefs {
    final manager = $$DeletedInvoiceItemsTableTableManager(
      $_db,
      $_db.deletedInvoiceItems,
    ).filter((f) => f.invoiceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _deletedInvoiceItemsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$InvoicePaymentsTable, List<InvoicePayment>>
  _invoicePaymentsRefsTable(_$LocalDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.invoicePayments,
        aliasName: $_aliasNameGenerator(
          db.invoices.id,
          db.invoicePayments.invoiceId,
        ),
      );

  $$InvoicePaymentsTableProcessedTableManager get invoicePaymentsRefs {
    final manager = $$InvoicePaymentsTableTableManager(
      $_db,
      $_db.invoicePayments,
    ).filter((f) => f.invoiceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _invoicePaymentsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$InvoicesTableFilterComposer
    extends Composer<_$LocalDatabase, $InvoicesTable> {
  $$InvoicesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get invoiceDate => $composableBuilder(
    column: $table.invoiceDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get invoiceNumber => $composableBuilder(
    column: $table.invoiceNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sequenceNumber => $composableBuilder(
    column: $table.sequenceNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get invoiceType => $composableBuilder(
    column: $table.invoiceType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentType => $composableBuilder(
    column: $table.paymentType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get partialAmount => $composableBuilder(
    column: $table.partialAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get partialDate => $composableBuilder(
    column: $table.partialDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get checkReference => $composableBuilder(
    column: $table.checkReference,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get checkAmount => $composableBuilder(
    column: $table.checkAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get checkIssuedDate => $composableBuilder(
    column: $table.checkIssuedDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get checkDueDate => $composableBuilder(
    column: $table.checkDueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get actualAmount => $composableBuilder(
    column: $table.actualAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get swapAmount => $composableBuilder(
    column: $table.swapAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get stockPulledOutAmount => $composableBuilder(
    column: $table.stockPulledOutAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get stockPulledOutCost => $composableBuilder(
    column: $table.stockPulledOutCost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get includeInLayout => $composableBuilder(
    column: $table.includeInLayout,
    builder: (column) => ColumnFilters(column),
  );

  $$ClientsTableFilterComposer get clientId {
    final $$ClientsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clientId,
      referencedTable: $db.clients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientsTableFilterComposer(
            $db: $db,
            $table: $db.clients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> invoiceItemsRefs(
    Expression<bool> Function($$InvoiceItemsTableFilterComposer f) f,
  ) {
    final $$InvoiceItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.invoiceItems,
      getReferencedColumn: (t) => t.invoiceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvoiceItemsTableFilterComposer(
            $db: $db,
            $table: $db.invoiceItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> deletedInvoiceItemsRefs(
    Expression<bool> Function($$DeletedInvoiceItemsTableFilterComposer f) f,
  ) {
    final $$DeletedInvoiceItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.deletedInvoiceItems,
      getReferencedColumn: (t) => t.invoiceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DeletedInvoiceItemsTableFilterComposer(
            $db: $db,
            $table: $db.deletedInvoiceItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> invoicePaymentsRefs(
    Expression<bool> Function($$InvoicePaymentsTableFilterComposer f) f,
  ) {
    final $$InvoicePaymentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.invoicePayments,
      getReferencedColumn: (t) => t.invoiceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvoicePaymentsTableFilterComposer(
            $db: $db,
            $table: $db.invoicePayments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$InvoicesTableOrderingComposer
    extends Composer<_$LocalDatabase, $InvoicesTable> {
  $$InvoicesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get invoiceDate => $composableBuilder(
    column: $table.invoiceDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get invoiceNumber => $composableBuilder(
    column: $table.invoiceNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sequenceNumber => $composableBuilder(
    column: $table.sequenceNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get invoiceType => $composableBuilder(
    column: $table.invoiceType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentType => $composableBuilder(
    column: $table.paymentType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get partialAmount => $composableBuilder(
    column: $table.partialAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get partialDate => $composableBuilder(
    column: $table.partialDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get checkReference => $composableBuilder(
    column: $table.checkReference,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get checkAmount => $composableBuilder(
    column: $table.checkAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get checkIssuedDate => $composableBuilder(
    column: $table.checkIssuedDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get checkDueDate => $composableBuilder(
    column: $table.checkDueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get actualAmount => $composableBuilder(
    column: $table.actualAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get swapAmount => $composableBuilder(
    column: $table.swapAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get stockPulledOutAmount => $composableBuilder(
    column: $table.stockPulledOutAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get stockPulledOutCost => $composableBuilder(
    column: $table.stockPulledOutCost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get includeInLayout => $composableBuilder(
    column: $table.includeInLayout,
    builder: (column) => ColumnOrderings(column),
  );

  $$ClientsTableOrderingComposer get clientId {
    final $$ClientsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clientId,
      referencedTable: $db.clients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientsTableOrderingComposer(
            $db: $db,
            $table: $db.clients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InvoicesTableAnnotationComposer
    extends Composer<_$LocalDatabase, $InvoicesTable> {
  $$InvoicesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get invoiceDate => $composableBuilder(
    column: $table.invoiceDate,
    builder: (column) => column,
  );

  GeneratedColumn<double> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get invoiceNumber => $composableBuilder(
    column: $table.invoiceNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sequenceNumber => $composableBuilder(
    column: $table.sequenceNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get invoiceType => $composableBuilder(
    column: $table.invoiceType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get paymentType => $composableBuilder(
    column: $table.paymentType,
    builder: (column) => column,
  );

  GeneratedColumn<double> get partialAmount => $composableBuilder(
    column: $table.partialAmount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get partialDate => $composableBuilder(
    column: $table.partialDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get checkReference => $composableBuilder(
    column: $table.checkReference,
    builder: (column) => column,
  );

  GeneratedColumn<double> get checkAmount => $composableBuilder(
    column: $table.checkAmount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get checkIssuedDate => $composableBuilder(
    column: $table.checkIssuedDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get checkDueDate => $composableBuilder(
    column: $table.checkDueDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<double> get actualAmount => $composableBuilder(
    column: $table.actualAmount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get swapAmount => $composableBuilder(
    column: $table.swapAmount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get stockPulledOutAmount => $composableBuilder(
    column: $table.stockPulledOutAmount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get stockPulledOutCost => $composableBuilder(
    column: $table.stockPulledOutCost,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get includeInLayout => $composableBuilder(
    column: $table.includeInLayout,
    builder: (column) => column,
  );

  $$ClientsTableAnnotationComposer get clientId {
    final $$ClientsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clientId,
      referencedTable: $db.clients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientsTableAnnotationComposer(
            $db: $db,
            $table: $db.clients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> invoiceItemsRefs<T extends Object>(
    Expression<T> Function($$InvoiceItemsTableAnnotationComposer a) f,
  ) {
    final $$InvoiceItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.invoiceItems,
      getReferencedColumn: (t) => t.invoiceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvoiceItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.invoiceItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> deletedInvoiceItemsRefs<T extends Object>(
    Expression<T> Function($$DeletedInvoiceItemsTableAnnotationComposer a) f,
  ) {
    final $$DeletedInvoiceItemsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.deletedInvoiceItems,
          getReferencedColumn: (t) => t.invoiceId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$DeletedInvoiceItemsTableAnnotationComposer(
                $db: $db,
                $table: $db.deletedInvoiceItems,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> invoicePaymentsRefs<T extends Object>(
    Expression<T> Function($$InvoicePaymentsTableAnnotationComposer a) f,
  ) {
    final $$InvoicePaymentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.invoicePayments,
      getReferencedColumn: (t) => t.invoiceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvoicePaymentsTableAnnotationComposer(
            $db: $db,
            $table: $db.invoicePayments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$InvoicesTableTableManager
    extends
        RootTableManager<
          _$LocalDatabase,
          $InvoicesTable,
          Invoice,
          $$InvoicesTableFilterComposer,
          $$InvoicesTableOrderingComposer,
          $$InvoicesTableAnnotationComposer,
          $$InvoicesTableCreateCompanionBuilder,
          $$InvoicesTableUpdateCompanionBuilder,
          (Invoice, $$InvoicesTableReferences),
          Invoice,
          PrefetchHooks Function({
            bool clientId,
            bool invoiceItemsRefs,
            bool deletedInvoiceItemsRefs,
            bool invoicePaymentsRefs,
          })
        > {
  $$InvoicesTableTableManager(_$LocalDatabase db, $InvoicesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InvoicesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InvoicesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InvoicesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> clientId = const Value.absent(),
                Value<DateTime> invoiceDate = const Value.absent(),
                Value<double> totalAmount = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String?> invoiceNumber = const Value.absent(),
                Value<int?> sequenceNumber = const Value.absent(),
                Value<String> invoiceType = const Value.absent(),
                Value<String> paymentType = const Value.absent(),
                Value<double?> partialAmount = const Value.absent(),
                Value<DateTime?> partialDate = const Value.absent(),
                Value<String?> checkReference = const Value.absent(),
                Value<double?> checkAmount = const Value.absent(),
                Value<DateTime?> checkIssuedDate = const Value.absent(),
                Value<DateTime?> checkDueDate = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<double?> actualAmount = const Value.absent(),
                Value<double?> swapAmount = const Value.absent(),
                Value<double?> stockPulledOutAmount = const Value.absent(),
                Value<double?> stockPulledOutCost = const Value.absent(),
                Value<bool> includeInLayout = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InvoicesCompanion(
                id: id,
                clientId: clientId,
                invoiceDate: invoiceDate,
                totalAmount: totalAmount,
                status: status,
                createdAt: createdAt,
                invoiceNumber: invoiceNumber,
                sequenceNumber: sequenceNumber,
                invoiceType: invoiceType,
                paymentType: paymentType,
                partialAmount: partialAmount,
                partialDate: partialDate,
                checkReference: checkReference,
                checkAmount: checkAmount,
                checkIssuedDate: checkIssuedDate,
                checkDueDate: checkDueDate,
                notes: notes,
                actualAmount: actualAmount,
                swapAmount: swapAmount,
                stockPulledOutAmount: stockPulledOutAmount,
                stockPulledOutCost: stockPulledOutCost,
                includeInLayout: includeInLayout,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String clientId,
                Value<DateTime> invoiceDate = const Value.absent(),
                Value<double> totalAmount = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String?> invoiceNumber = const Value.absent(),
                Value<int?> sequenceNumber = const Value.absent(),
                Value<String> invoiceType = const Value.absent(),
                Value<String> paymentType = const Value.absent(),
                Value<double?> partialAmount = const Value.absent(),
                Value<DateTime?> partialDate = const Value.absent(),
                Value<String?> checkReference = const Value.absent(),
                Value<double?> checkAmount = const Value.absent(),
                Value<DateTime?> checkIssuedDate = const Value.absent(),
                Value<DateTime?> checkDueDate = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<double?> actualAmount = const Value.absent(),
                Value<double?> swapAmount = const Value.absent(),
                Value<double?> stockPulledOutAmount = const Value.absent(),
                Value<double?> stockPulledOutCost = const Value.absent(),
                Value<bool> includeInLayout = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InvoicesCompanion.insert(
                id: id,
                clientId: clientId,
                invoiceDate: invoiceDate,
                totalAmount: totalAmount,
                status: status,
                createdAt: createdAt,
                invoiceNumber: invoiceNumber,
                sequenceNumber: sequenceNumber,
                invoiceType: invoiceType,
                paymentType: paymentType,
                partialAmount: partialAmount,
                partialDate: partialDate,
                checkReference: checkReference,
                checkAmount: checkAmount,
                checkIssuedDate: checkIssuedDate,
                checkDueDate: checkDueDate,
                notes: notes,
                actualAmount: actualAmount,
                swapAmount: swapAmount,
                stockPulledOutAmount: stockPulledOutAmount,
                stockPulledOutCost: stockPulledOutCost,
                includeInLayout: includeInLayout,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$InvoicesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                clientId = false,
                invoiceItemsRefs = false,
                deletedInvoiceItemsRefs = false,
                invoicePaymentsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (invoiceItemsRefs) db.invoiceItems,
                    if (deletedInvoiceItemsRefs) db.deletedInvoiceItems,
                    if (invoicePaymentsRefs) db.invoicePayments,
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
                        if (clientId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.clientId,
                                    referencedTable: $$InvoicesTableReferences
                                        ._clientIdTable(db),
                                    referencedColumn: $$InvoicesTableReferences
                                        ._clientIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (invoiceItemsRefs)
                        await $_getPrefetchedData<
                          Invoice,
                          $InvoicesTable,
                          InvoiceItem
                        >(
                          currentTable: table,
                          referencedTable: $$InvoicesTableReferences
                              ._invoiceItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$InvoicesTableReferences(
                                db,
                                table,
                                p0,
                              ).invoiceItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.invoiceId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (deletedInvoiceItemsRefs)
                        await $_getPrefetchedData<
                          Invoice,
                          $InvoicesTable,
                          DeletedInvoiceItem
                        >(
                          currentTable: table,
                          referencedTable: $$InvoicesTableReferences
                              ._deletedInvoiceItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$InvoicesTableReferences(
                                db,
                                table,
                                p0,
                              ).deletedInvoiceItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.invoiceId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (invoicePaymentsRefs)
                        await $_getPrefetchedData<
                          Invoice,
                          $InvoicesTable,
                          InvoicePayment
                        >(
                          currentTable: table,
                          referencedTable: $$InvoicesTableReferences
                              ._invoicePaymentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$InvoicesTableReferences(
                                db,
                                table,
                                p0,
                              ).invoicePaymentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.invoiceId == item.id,
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

typedef $$InvoicesTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDatabase,
      $InvoicesTable,
      Invoice,
      $$InvoicesTableFilterComposer,
      $$InvoicesTableOrderingComposer,
      $$InvoicesTableAnnotationComposer,
      $$InvoicesTableCreateCompanionBuilder,
      $$InvoicesTableUpdateCompanionBuilder,
      (Invoice, $$InvoicesTableReferences),
      Invoice,
      PrefetchHooks Function({
        bool clientId,
        bool invoiceItemsRefs,
        bool deletedInvoiceItemsRefs,
        bool invoicePaymentsRefs,
      })
    >;
typedef $$InvoiceItemsTableCreateCompanionBuilder =
    InvoiceItemsCompanion Function({
      required String id,
      required String invoiceId,
      required String productId,
      required String unitType,
      required int quantity,
      required double pricePerPiece,
      required double subtotal,
      Value<bool> isFree,
      Value<double> discountPercent,
      Value<int> rowid,
    });
typedef $$InvoiceItemsTableUpdateCompanionBuilder =
    InvoiceItemsCompanion Function({
      Value<String> id,
      Value<String> invoiceId,
      Value<String> productId,
      Value<String> unitType,
      Value<int> quantity,
      Value<double> pricePerPiece,
      Value<double> subtotal,
      Value<bool> isFree,
      Value<double> discountPercent,
      Value<int> rowid,
    });

final class $$InvoiceItemsTableReferences
    extends BaseReferences<_$LocalDatabase, $InvoiceItemsTable, InvoiceItem> {
  $$InvoiceItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $InvoicesTable _invoiceIdTable(_$LocalDatabase db) =>
      db.invoices.createAlias(
        $_aliasNameGenerator(db.invoiceItems.invoiceId, db.invoices.id),
      );

  $$InvoicesTableProcessedTableManager get invoiceId {
    final $_column = $_itemColumn<String>('invoice_id')!;

    final manager = $$InvoicesTableTableManager(
      $_db,
      $_db.invoices,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_invoiceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ProductsTable _productIdTable(_$LocalDatabase db) =>
      db.products.createAlias(
        $_aliasNameGenerator(db.invoiceItems.productId, db.products.id),
      );

  $$ProductsTableProcessedTableManager get productId {
    final $_column = $_itemColumn<String>('product_id')!;

    final manager = $$ProductsTableTableManager(
      $_db,
      $_db.products,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_productIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$InvoiceItemsTableFilterComposer
    extends Composer<_$LocalDatabase, $InvoiceItemsTable> {
  $$InvoiceItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unitType => $composableBuilder(
    column: $table.unitType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get pricePerPiece => $composableBuilder(
    column: $table.pricePerPiece,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get subtotal => $composableBuilder(
    column: $table.subtotal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFree => $composableBuilder(
    column: $table.isFree,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get discountPercent => $composableBuilder(
    column: $table.discountPercent,
    builder: (column) => ColumnFilters(column),
  );

  $$InvoicesTableFilterComposer get invoiceId {
    final $$InvoicesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.invoiceId,
      referencedTable: $db.invoices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvoicesTableFilterComposer(
            $db: $db,
            $table: $db.invoices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProductsTableFilterComposer get productId {
    final $$ProductsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableFilterComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InvoiceItemsTableOrderingComposer
    extends Composer<_$LocalDatabase, $InvoiceItemsTable> {
  $$InvoiceItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unitType => $composableBuilder(
    column: $table.unitType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get pricePerPiece => $composableBuilder(
    column: $table.pricePerPiece,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get subtotal => $composableBuilder(
    column: $table.subtotal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFree => $composableBuilder(
    column: $table.isFree,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get discountPercent => $composableBuilder(
    column: $table.discountPercent,
    builder: (column) => ColumnOrderings(column),
  );

  $$InvoicesTableOrderingComposer get invoiceId {
    final $$InvoicesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.invoiceId,
      referencedTable: $db.invoices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvoicesTableOrderingComposer(
            $db: $db,
            $table: $db.invoices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProductsTableOrderingComposer get productId {
    final $$ProductsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableOrderingComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InvoiceItemsTableAnnotationComposer
    extends Composer<_$LocalDatabase, $InvoiceItemsTable> {
  $$InvoiceItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get unitType =>
      $composableBuilder(column: $table.unitType, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<double> get pricePerPiece => $composableBuilder(
    column: $table.pricePerPiece,
    builder: (column) => column,
  );

  GeneratedColumn<double> get subtotal =>
      $composableBuilder(column: $table.subtotal, builder: (column) => column);

  GeneratedColumn<bool> get isFree =>
      $composableBuilder(column: $table.isFree, builder: (column) => column);

  GeneratedColumn<double> get discountPercent => $composableBuilder(
    column: $table.discountPercent,
    builder: (column) => column,
  );

  $$InvoicesTableAnnotationComposer get invoiceId {
    final $$InvoicesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.invoiceId,
      referencedTable: $db.invoices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvoicesTableAnnotationComposer(
            $db: $db,
            $table: $db.invoices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProductsTableAnnotationComposer get productId {
    final $$ProductsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableAnnotationComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InvoiceItemsTableTableManager
    extends
        RootTableManager<
          _$LocalDatabase,
          $InvoiceItemsTable,
          InvoiceItem,
          $$InvoiceItemsTableFilterComposer,
          $$InvoiceItemsTableOrderingComposer,
          $$InvoiceItemsTableAnnotationComposer,
          $$InvoiceItemsTableCreateCompanionBuilder,
          $$InvoiceItemsTableUpdateCompanionBuilder,
          (InvoiceItem, $$InvoiceItemsTableReferences),
          InvoiceItem,
          PrefetchHooks Function({bool invoiceId, bool productId})
        > {
  $$InvoiceItemsTableTableManager(_$LocalDatabase db, $InvoiceItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InvoiceItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InvoiceItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InvoiceItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> invoiceId = const Value.absent(),
                Value<String> productId = const Value.absent(),
                Value<String> unitType = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<double> pricePerPiece = const Value.absent(),
                Value<double> subtotal = const Value.absent(),
                Value<bool> isFree = const Value.absent(),
                Value<double> discountPercent = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InvoiceItemsCompanion(
                id: id,
                invoiceId: invoiceId,
                productId: productId,
                unitType: unitType,
                quantity: quantity,
                pricePerPiece: pricePerPiece,
                subtotal: subtotal,
                isFree: isFree,
                discountPercent: discountPercent,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String invoiceId,
                required String productId,
                required String unitType,
                required int quantity,
                required double pricePerPiece,
                required double subtotal,
                Value<bool> isFree = const Value.absent(),
                Value<double> discountPercent = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InvoiceItemsCompanion.insert(
                id: id,
                invoiceId: invoiceId,
                productId: productId,
                unitType: unitType,
                quantity: quantity,
                pricePerPiece: pricePerPiece,
                subtotal: subtotal,
                isFree: isFree,
                discountPercent: discountPercent,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$InvoiceItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({invoiceId = false, productId = false}) {
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
                    if (invoiceId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.invoiceId,
                                referencedTable: $$InvoiceItemsTableReferences
                                    ._invoiceIdTable(db),
                                referencedColumn: $$InvoiceItemsTableReferences
                                    ._invoiceIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (productId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.productId,
                                referencedTable: $$InvoiceItemsTableReferences
                                    ._productIdTable(db),
                                referencedColumn: $$InvoiceItemsTableReferences
                                    ._productIdTable(db)
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

typedef $$InvoiceItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDatabase,
      $InvoiceItemsTable,
      InvoiceItem,
      $$InvoiceItemsTableFilterComposer,
      $$InvoiceItemsTableOrderingComposer,
      $$InvoiceItemsTableAnnotationComposer,
      $$InvoiceItemsTableCreateCompanionBuilder,
      $$InvoiceItemsTableUpdateCompanionBuilder,
      (InvoiceItem, $$InvoiceItemsTableReferences),
      InvoiceItem,
      PrefetchHooks Function({bool invoiceId, bool productId})
    >;
typedef $$DeletedInvoiceItemsTableCreateCompanionBuilder =
    DeletedInvoiceItemsCompanion Function({
      required String id,
      required String invoiceId,
      required String productId,
      required String unitType,
      required int quantity,
      required double pricePerPiece,
      required double subtotal,
      Value<bool> isFree,
      Value<DateTime> deletedAt,
      Value<int> rowid,
    });
typedef $$DeletedInvoiceItemsTableUpdateCompanionBuilder =
    DeletedInvoiceItemsCompanion Function({
      Value<String> id,
      Value<String> invoiceId,
      Value<String> productId,
      Value<String> unitType,
      Value<int> quantity,
      Value<double> pricePerPiece,
      Value<double> subtotal,
      Value<bool> isFree,
      Value<DateTime> deletedAt,
      Value<int> rowid,
    });

final class $$DeletedInvoiceItemsTableReferences
    extends
        BaseReferences<
          _$LocalDatabase,
          $DeletedInvoiceItemsTable,
          DeletedInvoiceItem
        > {
  $$DeletedInvoiceItemsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $InvoicesTable _invoiceIdTable(_$LocalDatabase db) =>
      db.invoices.createAlias(
        $_aliasNameGenerator(db.deletedInvoiceItems.invoiceId, db.invoices.id),
      );

  $$InvoicesTableProcessedTableManager get invoiceId {
    final $_column = $_itemColumn<String>('invoice_id')!;

    final manager = $$InvoicesTableTableManager(
      $_db,
      $_db.invoices,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_invoiceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ProductsTable _productIdTable(_$LocalDatabase db) =>
      db.products.createAlias(
        $_aliasNameGenerator(db.deletedInvoiceItems.productId, db.products.id),
      );

  $$ProductsTableProcessedTableManager get productId {
    final $_column = $_itemColumn<String>('product_id')!;

    final manager = $$ProductsTableTableManager(
      $_db,
      $_db.products,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_productIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DeletedInvoiceItemsTableFilterComposer
    extends Composer<_$LocalDatabase, $DeletedInvoiceItemsTable> {
  $$DeletedInvoiceItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unitType => $composableBuilder(
    column: $table.unitType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get pricePerPiece => $composableBuilder(
    column: $table.pricePerPiece,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get subtotal => $composableBuilder(
    column: $table.subtotal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFree => $composableBuilder(
    column: $table.isFree,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$InvoicesTableFilterComposer get invoiceId {
    final $$InvoicesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.invoiceId,
      referencedTable: $db.invoices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvoicesTableFilterComposer(
            $db: $db,
            $table: $db.invoices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProductsTableFilterComposer get productId {
    final $$ProductsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableFilterComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DeletedInvoiceItemsTableOrderingComposer
    extends Composer<_$LocalDatabase, $DeletedInvoiceItemsTable> {
  $$DeletedInvoiceItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unitType => $composableBuilder(
    column: $table.unitType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get pricePerPiece => $composableBuilder(
    column: $table.pricePerPiece,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get subtotal => $composableBuilder(
    column: $table.subtotal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFree => $composableBuilder(
    column: $table.isFree,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$InvoicesTableOrderingComposer get invoiceId {
    final $$InvoicesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.invoiceId,
      referencedTable: $db.invoices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvoicesTableOrderingComposer(
            $db: $db,
            $table: $db.invoices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProductsTableOrderingComposer get productId {
    final $$ProductsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableOrderingComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DeletedInvoiceItemsTableAnnotationComposer
    extends Composer<_$LocalDatabase, $DeletedInvoiceItemsTable> {
  $$DeletedInvoiceItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get unitType =>
      $composableBuilder(column: $table.unitType, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<double> get pricePerPiece => $composableBuilder(
    column: $table.pricePerPiece,
    builder: (column) => column,
  );

  GeneratedColumn<double> get subtotal =>
      $composableBuilder(column: $table.subtotal, builder: (column) => column);

  GeneratedColumn<bool> get isFree =>
      $composableBuilder(column: $table.isFree, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$InvoicesTableAnnotationComposer get invoiceId {
    final $$InvoicesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.invoiceId,
      referencedTable: $db.invoices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvoicesTableAnnotationComposer(
            $db: $db,
            $table: $db.invoices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProductsTableAnnotationComposer get productId {
    final $$ProductsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableAnnotationComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DeletedInvoiceItemsTableTableManager
    extends
        RootTableManager<
          _$LocalDatabase,
          $DeletedInvoiceItemsTable,
          DeletedInvoiceItem,
          $$DeletedInvoiceItemsTableFilterComposer,
          $$DeletedInvoiceItemsTableOrderingComposer,
          $$DeletedInvoiceItemsTableAnnotationComposer,
          $$DeletedInvoiceItemsTableCreateCompanionBuilder,
          $$DeletedInvoiceItemsTableUpdateCompanionBuilder,
          (DeletedInvoiceItem, $$DeletedInvoiceItemsTableReferences),
          DeletedInvoiceItem,
          PrefetchHooks Function({bool invoiceId, bool productId})
        > {
  $$DeletedInvoiceItemsTableTableManager(
    _$LocalDatabase db,
    $DeletedInvoiceItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DeletedInvoiceItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DeletedInvoiceItemsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$DeletedInvoiceItemsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> invoiceId = const Value.absent(),
                Value<String> productId = const Value.absent(),
                Value<String> unitType = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<double> pricePerPiece = const Value.absent(),
                Value<double> subtotal = const Value.absent(),
                Value<bool> isFree = const Value.absent(),
                Value<DateTime> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DeletedInvoiceItemsCompanion(
                id: id,
                invoiceId: invoiceId,
                productId: productId,
                unitType: unitType,
                quantity: quantity,
                pricePerPiece: pricePerPiece,
                subtotal: subtotal,
                isFree: isFree,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String invoiceId,
                required String productId,
                required String unitType,
                required int quantity,
                required double pricePerPiece,
                required double subtotal,
                Value<bool> isFree = const Value.absent(),
                Value<DateTime> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DeletedInvoiceItemsCompanion.insert(
                id: id,
                invoiceId: invoiceId,
                productId: productId,
                unitType: unitType,
                quantity: quantity,
                pricePerPiece: pricePerPiece,
                subtotal: subtotal,
                isFree: isFree,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DeletedInvoiceItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({invoiceId = false, productId = false}) {
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
                    if (invoiceId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.invoiceId,
                                referencedTable:
                                    $$DeletedInvoiceItemsTableReferences
                                        ._invoiceIdTable(db),
                                referencedColumn:
                                    $$DeletedInvoiceItemsTableReferences
                                        ._invoiceIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (productId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.productId,
                                referencedTable:
                                    $$DeletedInvoiceItemsTableReferences
                                        ._productIdTable(db),
                                referencedColumn:
                                    $$DeletedInvoiceItemsTableReferences
                                        ._productIdTable(db)
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

typedef $$DeletedInvoiceItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDatabase,
      $DeletedInvoiceItemsTable,
      DeletedInvoiceItem,
      $$DeletedInvoiceItemsTableFilterComposer,
      $$DeletedInvoiceItemsTableOrderingComposer,
      $$DeletedInvoiceItemsTableAnnotationComposer,
      $$DeletedInvoiceItemsTableCreateCompanionBuilder,
      $$DeletedInvoiceItemsTableUpdateCompanionBuilder,
      (DeletedInvoiceItem, $$DeletedInvoiceItemsTableReferences),
      DeletedInvoiceItem,
      PrefetchHooks Function({bool invoiceId, bool productId})
    >;
typedef $$BadOrdersTableCreateCompanionBuilder =
    BadOrdersCompanion Function({
      required String id,
      required String clientId,
      Value<DateTime> date,
      required String type,
      Value<String?> notes,
      Value<DateTime> createdAt,
      Value<String?> invoiceId,
      Value<int> rowid,
    });
typedef $$BadOrdersTableUpdateCompanionBuilder =
    BadOrdersCompanion Function({
      Value<String> id,
      Value<String> clientId,
      Value<DateTime> date,
      Value<String> type,
      Value<String?> notes,
      Value<DateTime> createdAt,
      Value<String?> invoiceId,
      Value<int> rowid,
    });

final class $$BadOrdersTableReferences
    extends BaseReferences<_$LocalDatabase, $BadOrdersTable, BadOrder> {
  $$BadOrdersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ClientsTable _clientIdTable(_$LocalDatabase db) => db.clients
      .createAlias($_aliasNameGenerator(db.badOrders.clientId, db.clients.id));

  $$ClientsTableProcessedTableManager get clientId {
    final $_column = $_itemColumn<String>('client_id')!;

    final manager = $$ClientsTableTableManager(
      $_db,
      $_db.clients,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_clientIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$BadOrderItemsTable, List<BadOrderItem>>
  _badOrderItemsRefsTable(_$LocalDatabase db) => MultiTypedResultKey.fromTable(
    db.badOrderItems,
    aliasName: $_aliasNameGenerator(
      db.badOrders.id,
      db.badOrderItems.badOrderId,
    ),
  );

  $$BadOrderItemsTableProcessedTableManager get badOrderItemsRefs {
    final manager = $$BadOrderItemsTableTableManager(
      $_db,
      $_db.badOrderItems,
    ).filter((f) => f.badOrderId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_badOrderItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$BadOrdersTableFilterComposer
    extends Composer<_$LocalDatabase, $BadOrdersTable> {
  $$BadOrdersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get invoiceId => $composableBuilder(
    column: $table.invoiceId,
    builder: (column) => ColumnFilters(column),
  );

  $$ClientsTableFilterComposer get clientId {
    final $$ClientsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clientId,
      referencedTable: $db.clients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientsTableFilterComposer(
            $db: $db,
            $table: $db.clients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> badOrderItemsRefs(
    Expression<bool> Function($$BadOrderItemsTableFilterComposer f) f,
  ) {
    final $$BadOrderItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.badOrderItems,
      getReferencedColumn: (t) => t.badOrderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BadOrderItemsTableFilterComposer(
            $db: $db,
            $table: $db.badOrderItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BadOrdersTableOrderingComposer
    extends Composer<_$LocalDatabase, $BadOrdersTable> {
  $$BadOrdersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get invoiceId => $composableBuilder(
    column: $table.invoiceId,
    builder: (column) => ColumnOrderings(column),
  );

  $$ClientsTableOrderingComposer get clientId {
    final $$ClientsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clientId,
      referencedTable: $db.clients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientsTableOrderingComposer(
            $db: $db,
            $table: $db.clients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BadOrdersTableAnnotationComposer
    extends Composer<_$LocalDatabase, $BadOrdersTable> {
  $$BadOrdersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get invoiceId =>
      $composableBuilder(column: $table.invoiceId, builder: (column) => column);

  $$ClientsTableAnnotationComposer get clientId {
    final $$ClientsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clientId,
      referencedTable: $db.clients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientsTableAnnotationComposer(
            $db: $db,
            $table: $db.clients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> badOrderItemsRefs<T extends Object>(
    Expression<T> Function($$BadOrderItemsTableAnnotationComposer a) f,
  ) {
    final $$BadOrderItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.badOrderItems,
      getReferencedColumn: (t) => t.badOrderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BadOrderItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.badOrderItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BadOrdersTableTableManager
    extends
        RootTableManager<
          _$LocalDatabase,
          $BadOrdersTable,
          BadOrder,
          $$BadOrdersTableFilterComposer,
          $$BadOrdersTableOrderingComposer,
          $$BadOrdersTableAnnotationComposer,
          $$BadOrdersTableCreateCompanionBuilder,
          $$BadOrdersTableUpdateCompanionBuilder,
          (BadOrder, $$BadOrdersTableReferences),
          BadOrder,
          PrefetchHooks Function({bool clientId, bool badOrderItemsRefs})
        > {
  $$BadOrdersTableTableManager(_$LocalDatabase db, $BadOrdersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BadOrdersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BadOrdersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BadOrdersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> clientId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String?> invoiceId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BadOrdersCompanion(
                id: id,
                clientId: clientId,
                date: date,
                type: type,
                notes: notes,
                createdAt: createdAt,
                invoiceId: invoiceId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String clientId,
                Value<DateTime> date = const Value.absent(),
                required String type,
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String?> invoiceId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BadOrdersCompanion.insert(
                id: id,
                clientId: clientId,
                date: date,
                type: type,
                notes: notes,
                createdAt: createdAt,
                invoiceId: invoiceId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$BadOrdersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({clientId = false, badOrderItemsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (badOrderItemsRefs) db.badOrderItems,
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
                        if (clientId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.clientId,
                                    referencedTable: $$BadOrdersTableReferences
                                        ._clientIdTable(db),
                                    referencedColumn: $$BadOrdersTableReferences
                                        ._clientIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (badOrderItemsRefs)
                        await $_getPrefetchedData<
                          BadOrder,
                          $BadOrdersTable,
                          BadOrderItem
                        >(
                          currentTable: table,
                          referencedTable: $$BadOrdersTableReferences
                              ._badOrderItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BadOrdersTableReferences(
                                db,
                                table,
                                p0,
                              ).badOrderItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.badOrderId == item.id,
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

typedef $$BadOrdersTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDatabase,
      $BadOrdersTable,
      BadOrder,
      $$BadOrdersTableFilterComposer,
      $$BadOrdersTableOrderingComposer,
      $$BadOrdersTableAnnotationComposer,
      $$BadOrdersTableCreateCompanionBuilder,
      $$BadOrdersTableUpdateCompanionBuilder,
      (BadOrder, $$BadOrdersTableReferences),
      BadOrder,
      PrefetchHooks Function({bool clientId, bool badOrderItemsRefs})
    >;
typedef $$BadOrderItemsTableCreateCompanionBuilder =
    BadOrderItemsCompanion Function({
      required String id,
      required String badOrderId,
      required String productId,
      required String unitType,
      required int quantity,
      Value<int> rowid,
    });
typedef $$BadOrderItemsTableUpdateCompanionBuilder =
    BadOrderItemsCompanion Function({
      Value<String> id,
      Value<String> badOrderId,
      Value<String> productId,
      Value<String> unitType,
      Value<int> quantity,
      Value<int> rowid,
    });

final class $$BadOrderItemsTableReferences
    extends BaseReferences<_$LocalDatabase, $BadOrderItemsTable, BadOrderItem> {
  $$BadOrderItemsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $BadOrdersTable _badOrderIdTable(_$LocalDatabase db) =>
      db.badOrders.createAlias(
        $_aliasNameGenerator(db.badOrderItems.badOrderId, db.badOrders.id),
      );

  $$BadOrdersTableProcessedTableManager get badOrderId {
    final $_column = $_itemColumn<String>('bad_order_id')!;

    final manager = $$BadOrdersTableTableManager(
      $_db,
      $_db.badOrders,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_badOrderIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ProductsTable _productIdTable(_$LocalDatabase db) =>
      db.products.createAlias(
        $_aliasNameGenerator(db.badOrderItems.productId, db.products.id),
      );

  $$ProductsTableProcessedTableManager get productId {
    final $_column = $_itemColumn<String>('product_id')!;

    final manager = $$ProductsTableTableManager(
      $_db,
      $_db.products,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_productIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$BadOrderItemsTableFilterComposer
    extends Composer<_$LocalDatabase, $BadOrderItemsTable> {
  $$BadOrderItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unitType => $composableBuilder(
    column: $table.unitType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  $$BadOrdersTableFilterComposer get badOrderId {
    final $$BadOrdersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.badOrderId,
      referencedTable: $db.badOrders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BadOrdersTableFilterComposer(
            $db: $db,
            $table: $db.badOrders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProductsTableFilterComposer get productId {
    final $$ProductsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableFilterComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BadOrderItemsTableOrderingComposer
    extends Composer<_$LocalDatabase, $BadOrderItemsTable> {
  $$BadOrderItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unitType => $composableBuilder(
    column: $table.unitType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  $$BadOrdersTableOrderingComposer get badOrderId {
    final $$BadOrdersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.badOrderId,
      referencedTable: $db.badOrders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BadOrdersTableOrderingComposer(
            $db: $db,
            $table: $db.badOrders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProductsTableOrderingComposer get productId {
    final $$ProductsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableOrderingComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BadOrderItemsTableAnnotationComposer
    extends Composer<_$LocalDatabase, $BadOrderItemsTable> {
  $$BadOrderItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get unitType =>
      $composableBuilder(column: $table.unitType, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  $$BadOrdersTableAnnotationComposer get badOrderId {
    final $$BadOrdersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.badOrderId,
      referencedTable: $db.badOrders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BadOrdersTableAnnotationComposer(
            $db: $db,
            $table: $db.badOrders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProductsTableAnnotationComposer get productId {
    final $$ProductsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableAnnotationComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BadOrderItemsTableTableManager
    extends
        RootTableManager<
          _$LocalDatabase,
          $BadOrderItemsTable,
          BadOrderItem,
          $$BadOrderItemsTableFilterComposer,
          $$BadOrderItemsTableOrderingComposer,
          $$BadOrderItemsTableAnnotationComposer,
          $$BadOrderItemsTableCreateCompanionBuilder,
          $$BadOrderItemsTableUpdateCompanionBuilder,
          (BadOrderItem, $$BadOrderItemsTableReferences),
          BadOrderItem,
          PrefetchHooks Function({bool badOrderId, bool productId})
        > {
  $$BadOrderItemsTableTableManager(
    _$LocalDatabase db,
    $BadOrderItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BadOrderItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BadOrderItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BadOrderItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> badOrderId = const Value.absent(),
                Value<String> productId = const Value.absent(),
                Value<String> unitType = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BadOrderItemsCompanion(
                id: id,
                badOrderId: badOrderId,
                productId: productId,
                unitType: unitType,
                quantity: quantity,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String badOrderId,
                required String productId,
                required String unitType,
                required int quantity,
                Value<int> rowid = const Value.absent(),
              }) => BadOrderItemsCompanion.insert(
                id: id,
                badOrderId: badOrderId,
                productId: productId,
                unitType: unitType,
                quantity: quantity,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$BadOrderItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({badOrderId = false, productId = false}) {
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
                    if (badOrderId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.badOrderId,
                                referencedTable: $$BadOrderItemsTableReferences
                                    ._badOrderIdTable(db),
                                referencedColumn: $$BadOrderItemsTableReferences
                                    ._badOrderIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (productId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.productId,
                                referencedTable: $$BadOrderItemsTableReferences
                                    ._productIdTable(db),
                                referencedColumn: $$BadOrderItemsTableReferences
                                    ._productIdTable(db)
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

typedef $$BadOrderItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDatabase,
      $BadOrderItemsTable,
      BadOrderItem,
      $$BadOrderItemsTableFilterComposer,
      $$BadOrderItemsTableOrderingComposer,
      $$BadOrderItemsTableAnnotationComposer,
      $$BadOrderItemsTableCreateCompanionBuilder,
      $$BadOrderItemsTableUpdateCompanionBuilder,
      (BadOrderItem, $$BadOrderItemsTableReferences),
      BadOrderItem,
      PrefetchHooks Function({bool badOrderId, bool productId})
    >;
typedef $$VanAreasTableCreateCompanionBuilder =
    VanAreasCompanion Function({
      required String id,
      required String name,
      Value<int> rowid,
    });
typedef $$VanAreasTableUpdateCompanionBuilder =
    VanAreasCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<int> rowid,
    });

class $$VanAreasTableFilterComposer
    extends Composer<_$LocalDatabase, $VanAreasTable> {
  $$VanAreasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VanAreasTableOrderingComposer
    extends Composer<_$LocalDatabase, $VanAreasTable> {
  $$VanAreasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VanAreasTableAnnotationComposer
    extends Composer<_$LocalDatabase, $VanAreasTable> {
  $$VanAreasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);
}

class $$VanAreasTableTableManager
    extends
        RootTableManager<
          _$LocalDatabase,
          $VanAreasTable,
          VanArea,
          $$VanAreasTableFilterComposer,
          $$VanAreasTableOrderingComposer,
          $$VanAreasTableAnnotationComposer,
          $$VanAreasTableCreateCompanionBuilder,
          $$VanAreasTableUpdateCompanionBuilder,
          (VanArea, BaseReferences<_$LocalDatabase, $VanAreasTable, VanArea>),
          VanArea,
          PrefetchHooks Function()
        > {
  $$VanAreasTableTableManager(_$LocalDatabase db, $VanAreasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VanAreasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VanAreasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VanAreasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VanAreasCompanion(id: id, name: name, rowid: rowid),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<int> rowid = const Value.absent(),
              }) => VanAreasCompanion.insert(id: id, name: name, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VanAreasTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDatabase,
      $VanAreasTable,
      VanArea,
      $$VanAreasTableFilterComposer,
      $$VanAreasTableOrderingComposer,
      $$VanAreasTableAnnotationComposer,
      $$VanAreasTableCreateCompanionBuilder,
      $$VanAreasTableUpdateCompanionBuilder,
      (VanArea, BaseReferences<_$LocalDatabase, $VanAreasTable, VanArea>),
      VanArea,
      PrefetchHooks Function()
    >;
typedef $$VanStocksTableCreateCompanionBuilder =
    VanStocksCompanion Function({
      required String id,
      required String productId,
      required String type,
      required int quantityPieces,
      Value<DateTime> date,
      Value<String?> notes,
      Value<String?> areaId,
      Value<int> rowid,
    });
typedef $$VanStocksTableUpdateCompanionBuilder =
    VanStocksCompanion Function({
      Value<String> id,
      Value<String> productId,
      Value<String> type,
      Value<int> quantityPieces,
      Value<DateTime> date,
      Value<String?> notes,
      Value<String?> areaId,
      Value<int> rowid,
    });

final class $$VanStocksTableReferences
    extends BaseReferences<_$LocalDatabase, $VanStocksTable, VanStock> {
  $$VanStocksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProductsTable _productIdTable(_$LocalDatabase db) =>
      db.products.createAlias(
        $_aliasNameGenerator(db.vanStocks.productId, db.products.id),
      );

  $$ProductsTableProcessedTableManager get productId {
    final $_column = $_itemColumn<String>('product_id')!;

    final manager = $$ProductsTableTableManager(
      $_db,
      $_db.products,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_productIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$VanStocksTableFilterComposer
    extends Composer<_$LocalDatabase, $VanStocksTable> {
  $$VanStocksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantityPieces => $composableBuilder(
    column: $table.quantityPieces,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get areaId => $composableBuilder(
    column: $table.areaId,
    builder: (column) => ColumnFilters(column),
  );

  $$ProductsTableFilterComposer get productId {
    final $$ProductsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableFilterComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VanStocksTableOrderingComposer
    extends Composer<_$LocalDatabase, $VanStocksTable> {
  $$VanStocksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantityPieces => $composableBuilder(
    column: $table.quantityPieces,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get areaId => $composableBuilder(
    column: $table.areaId,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProductsTableOrderingComposer get productId {
    final $$ProductsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableOrderingComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VanStocksTableAnnotationComposer
    extends Composer<_$LocalDatabase, $VanStocksTable> {
  $$VanStocksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get quantityPieces => $composableBuilder(
    column: $table.quantityPieces,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get areaId =>
      $composableBuilder(column: $table.areaId, builder: (column) => column);

  $$ProductsTableAnnotationComposer get productId {
    final $$ProductsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableAnnotationComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VanStocksTableTableManager
    extends
        RootTableManager<
          _$LocalDatabase,
          $VanStocksTable,
          VanStock,
          $$VanStocksTableFilterComposer,
          $$VanStocksTableOrderingComposer,
          $$VanStocksTableAnnotationComposer,
          $$VanStocksTableCreateCompanionBuilder,
          $$VanStocksTableUpdateCompanionBuilder,
          (VanStock, $$VanStocksTableReferences),
          VanStock,
          PrefetchHooks Function({bool productId})
        > {
  $$VanStocksTableTableManager(_$LocalDatabase db, $VanStocksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VanStocksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VanStocksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VanStocksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> productId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int> quantityPieces = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> areaId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VanStocksCompanion(
                id: id,
                productId: productId,
                type: type,
                quantityPieces: quantityPieces,
                date: date,
                notes: notes,
                areaId: areaId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String productId,
                required String type,
                required int quantityPieces,
                Value<DateTime> date = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> areaId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VanStocksCompanion.insert(
                id: id,
                productId: productId,
                type: type,
                quantityPieces: quantityPieces,
                date: date,
                notes: notes,
                areaId: areaId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$VanStocksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({productId = false}) {
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
                    if (productId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.productId,
                                referencedTable: $$VanStocksTableReferences
                                    ._productIdTable(db),
                                referencedColumn: $$VanStocksTableReferences
                                    ._productIdTable(db)
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

typedef $$VanStocksTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDatabase,
      $VanStocksTable,
      VanStock,
      $$VanStocksTableFilterComposer,
      $$VanStocksTableOrderingComposer,
      $$VanStocksTableAnnotationComposer,
      $$VanStocksTableCreateCompanionBuilder,
      $$VanStocksTableUpdateCompanionBuilder,
      (VanStock, $$VanStocksTableReferences),
      VanStock,
      PrefetchHooks Function({bool productId})
    >;
typedef $$VanStockDraftsTableCreateCompanionBuilder =
    VanStockDraftsCompanion Function({
      required String id,
      required String type,
      Value<String?> areaId,
      Value<DateTime> txDate,
      required String itemsJson,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$VanStockDraftsTableUpdateCompanionBuilder =
    VanStockDraftsCompanion Function({
      Value<String> id,
      Value<String> type,
      Value<String?> areaId,
      Value<DateTime> txDate,
      Value<String> itemsJson,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$VanStockDraftsTableFilterComposer
    extends Composer<_$LocalDatabase, $VanStockDraftsTable> {
  $$VanStockDraftsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get areaId => $composableBuilder(
    column: $table.areaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get txDate => $composableBuilder(
    column: $table.txDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemsJson => $composableBuilder(
    column: $table.itemsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VanStockDraftsTableOrderingComposer
    extends Composer<_$LocalDatabase, $VanStockDraftsTable> {
  $$VanStockDraftsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get areaId => $composableBuilder(
    column: $table.areaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get txDate => $composableBuilder(
    column: $table.txDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemsJson => $composableBuilder(
    column: $table.itemsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VanStockDraftsTableAnnotationComposer
    extends Composer<_$LocalDatabase, $VanStockDraftsTable> {
  $$VanStockDraftsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get areaId =>
      $composableBuilder(column: $table.areaId, builder: (column) => column);

  GeneratedColumn<DateTime> get txDate =>
      $composableBuilder(column: $table.txDate, builder: (column) => column);

  GeneratedColumn<String> get itemsJson =>
      $composableBuilder(column: $table.itemsJson, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$VanStockDraftsTableTableManager
    extends
        RootTableManager<
          _$LocalDatabase,
          $VanStockDraftsTable,
          VanStockDraft,
          $$VanStockDraftsTableFilterComposer,
          $$VanStockDraftsTableOrderingComposer,
          $$VanStockDraftsTableAnnotationComposer,
          $$VanStockDraftsTableCreateCompanionBuilder,
          $$VanStockDraftsTableUpdateCompanionBuilder,
          (
            VanStockDraft,
            BaseReferences<
              _$LocalDatabase,
              $VanStockDraftsTable,
              VanStockDraft
            >,
          ),
          VanStockDraft,
          PrefetchHooks Function()
        > {
  $$VanStockDraftsTableTableManager(
    _$LocalDatabase db,
    $VanStockDraftsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VanStockDraftsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VanStockDraftsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VanStockDraftsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> areaId = const Value.absent(),
                Value<DateTime> txDate = const Value.absent(),
                Value<String> itemsJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VanStockDraftsCompanion(
                id: id,
                type: type,
                areaId: areaId,
                txDate: txDate,
                itemsJson: itemsJson,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String type,
                Value<String?> areaId = const Value.absent(),
                Value<DateTime> txDate = const Value.absent(),
                required String itemsJson,
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VanStockDraftsCompanion.insert(
                id: id,
                type: type,
                areaId: areaId,
                txDate: txDate,
                itemsJson: itemsJson,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VanStockDraftsTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDatabase,
      $VanStockDraftsTable,
      VanStockDraft,
      $$VanStockDraftsTableFilterComposer,
      $$VanStockDraftsTableOrderingComposer,
      $$VanStockDraftsTableAnnotationComposer,
      $$VanStockDraftsTableCreateCompanionBuilder,
      $$VanStockDraftsTableUpdateCompanionBuilder,
      (
        VanStockDraft,
        BaseReferences<_$LocalDatabase, $VanStockDraftsTable, VanStockDraft>,
      ),
      VanStockDraft,
      PrefetchHooks Function()
    >;
typedef $$BadOrderDraftsTableCreateCompanionBuilder =
    BadOrderDraftsCompanion Function({
      required String id,
      required String type,
      Value<String?> clientId,
      Value<bool> noClient,
      Value<DateTime> date,
      Value<String?> notes,
      required String itemsJson,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$BadOrderDraftsTableUpdateCompanionBuilder =
    BadOrderDraftsCompanion Function({
      Value<String> id,
      Value<String> type,
      Value<String?> clientId,
      Value<bool> noClient,
      Value<DateTime> date,
      Value<String?> notes,
      Value<String> itemsJson,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$BadOrderDraftsTableFilterComposer
    extends Composer<_$LocalDatabase, $BadOrderDraftsTable> {
  $$BadOrderDraftsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get noClient => $composableBuilder(
    column: $table.noClient,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemsJson => $composableBuilder(
    column: $table.itemsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BadOrderDraftsTableOrderingComposer
    extends Composer<_$LocalDatabase, $BadOrderDraftsTable> {
  $$BadOrderDraftsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get noClient => $composableBuilder(
    column: $table.noClient,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemsJson => $composableBuilder(
    column: $table.itemsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BadOrderDraftsTableAnnotationComposer
    extends Composer<_$LocalDatabase, $BadOrderDraftsTable> {
  $$BadOrderDraftsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get clientId =>
      $composableBuilder(column: $table.clientId, builder: (column) => column);

  GeneratedColumn<bool> get noClient =>
      $composableBuilder(column: $table.noClient, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get itemsJson =>
      $composableBuilder(column: $table.itemsJson, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$BadOrderDraftsTableTableManager
    extends
        RootTableManager<
          _$LocalDatabase,
          $BadOrderDraftsTable,
          BadOrderDraft,
          $$BadOrderDraftsTableFilterComposer,
          $$BadOrderDraftsTableOrderingComposer,
          $$BadOrderDraftsTableAnnotationComposer,
          $$BadOrderDraftsTableCreateCompanionBuilder,
          $$BadOrderDraftsTableUpdateCompanionBuilder,
          (
            BadOrderDraft,
            BaseReferences<
              _$LocalDatabase,
              $BadOrderDraftsTable,
              BadOrderDraft
            >,
          ),
          BadOrderDraft,
          PrefetchHooks Function()
        > {
  $$BadOrderDraftsTableTableManager(
    _$LocalDatabase db,
    $BadOrderDraftsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BadOrderDraftsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BadOrderDraftsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BadOrderDraftsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> clientId = const Value.absent(),
                Value<bool> noClient = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String> itemsJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BadOrderDraftsCompanion(
                id: id,
                type: type,
                clientId: clientId,
                noClient: noClient,
                date: date,
                notes: notes,
                itemsJson: itemsJson,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String type,
                Value<String?> clientId = const Value.absent(),
                Value<bool> noClient = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required String itemsJson,
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BadOrderDraftsCompanion.insert(
                id: id,
                type: type,
                clientId: clientId,
                noClient: noClient,
                date: date,
                notes: notes,
                itemsJson: itemsJson,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BadOrderDraftsTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDatabase,
      $BadOrderDraftsTable,
      BadOrderDraft,
      $$BadOrderDraftsTableFilterComposer,
      $$BadOrderDraftsTableOrderingComposer,
      $$BadOrderDraftsTableAnnotationComposer,
      $$BadOrderDraftsTableCreateCompanionBuilder,
      $$BadOrderDraftsTableUpdateCompanionBuilder,
      (
        BadOrderDraft,
        BaseReferences<_$LocalDatabase, $BadOrderDraftsTable, BadOrderDraft>,
      ),
      BadOrderDraft,
      PrefetchHooks Function()
    >;
typedef $$StockMovementsTableCreateCompanionBuilder =
    StockMovementsCompanion Function({
      required String id,
      required String productId,
      required String movementType,
      required int quantityPieces,
      Value<DateTime?> referenceDate,
      Value<String?> invoiceNumber,
      Value<String?> comments,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$StockMovementsTableUpdateCompanionBuilder =
    StockMovementsCompanion Function({
      Value<String> id,
      Value<String> productId,
      Value<String> movementType,
      Value<int> quantityPieces,
      Value<DateTime?> referenceDate,
      Value<String?> invoiceNumber,
      Value<String?> comments,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$StockMovementsTableReferences
    extends
        BaseReferences<_$LocalDatabase, $StockMovementsTable, StockMovement> {
  $$StockMovementsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ProductsTable _productIdTable(_$LocalDatabase db) =>
      db.products.createAlias(
        $_aliasNameGenerator(db.stockMovements.productId, db.products.id),
      );

  $$ProductsTableProcessedTableManager get productId {
    final $_column = $_itemColumn<String>('product_id')!;

    final manager = $$ProductsTableTableManager(
      $_db,
      $_db.products,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_productIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$StockMovementsTableFilterComposer
    extends Composer<_$LocalDatabase, $StockMovementsTable> {
  $$StockMovementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get movementType => $composableBuilder(
    column: $table.movementType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantityPieces => $composableBuilder(
    column: $table.quantityPieces,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get referenceDate => $composableBuilder(
    column: $table.referenceDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get invoiceNumber => $composableBuilder(
    column: $table.invoiceNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get comments => $composableBuilder(
    column: $table.comments,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ProductsTableFilterComposer get productId {
    final $$ProductsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableFilterComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StockMovementsTableOrderingComposer
    extends Composer<_$LocalDatabase, $StockMovementsTable> {
  $$StockMovementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get movementType => $composableBuilder(
    column: $table.movementType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantityPieces => $composableBuilder(
    column: $table.quantityPieces,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get referenceDate => $composableBuilder(
    column: $table.referenceDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get invoiceNumber => $composableBuilder(
    column: $table.invoiceNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get comments => $composableBuilder(
    column: $table.comments,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProductsTableOrderingComposer get productId {
    final $$ProductsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableOrderingComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StockMovementsTableAnnotationComposer
    extends Composer<_$LocalDatabase, $StockMovementsTable> {
  $$StockMovementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get movementType => $composableBuilder(
    column: $table.movementType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get quantityPieces => $composableBuilder(
    column: $table.quantityPieces,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get referenceDate => $composableBuilder(
    column: $table.referenceDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get invoiceNumber => $composableBuilder(
    column: $table.invoiceNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get comments =>
      $composableBuilder(column: $table.comments, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ProductsTableAnnotationComposer get productId {
    final $$ProductsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableAnnotationComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StockMovementsTableTableManager
    extends
        RootTableManager<
          _$LocalDatabase,
          $StockMovementsTable,
          StockMovement,
          $$StockMovementsTableFilterComposer,
          $$StockMovementsTableOrderingComposer,
          $$StockMovementsTableAnnotationComposer,
          $$StockMovementsTableCreateCompanionBuilder,
          $$StockMovementsTableUpdateCompanionBuilder,
          (StockMovement, $$StockMovementsTableReferences),
          StockMovement,
          PrefetchHooks Function({bool productId})
        > {
  $$StockMovementsTableTableManager(
    _$LocalDatabase db,
    $StockMovementsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StockMovementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StockMovementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StockMovementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> productId = const Value.absent(),
                Value<String> movementType = const Value.absent(),
                Value<int> quantityPieces = const Value.absent(),
                Value<DateTime?> referenceDate = const Value.absent(),
                Value<String?> invoiceNumber = const Value.absent(),
                Value<String?> comments = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StockMovementsCompanion(
                id: id,
                productId: productId,
                movementType: movementType,
                quantityPieces: quantityPieces,
                referenceDate: referenceDate,
                invoiceNumber: invoiceNumber,
                comments: comments,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String productId,
                required String movementType,
                required int quantityPieces,
                Value<DateTime?> referenceDate = const Value.absent(),
                Value<String?> invoiceNumber = const Value.absent(),
                Value<String?> comments = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StockMovementsCompanion.insert(
                id: id,
                productId: productId,
                movementType: movementType,
                quantityPieces: quantityPieces,
                referenceDate: referenceDate,
                invoiceNumber: invoiceNumber,
                comments: comments,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$StockMovementsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({productId = false}) {
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
                    if (productId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.productId,
                                referencedTable: $$StockMovementsTableReferences
                                    ._productIdTable(db),
                                referencedColumn:
                                    $$StockMovementsTableReferences
                                        ._productIdTable(db)
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

typedef $$StockMovementsTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDatabase,
      $StockMovementsTable,
      StockMovement,
      $$StockMovementsTableFilterComposer,
      $$StockMovementsTableOrderingComposer,
      $$StockMovementsTableAnnotationComposer,
      $$StockMovementsTableCreateCompanionBuilder,
      $$StockMovementsTableUpdateCompanionBuilder,
      (StockMovement, $$StockMovementsTableReferences),
      StockMovement,
      PrefetchHooks Function({bool productId})
    >;
typedef $$InvoicePaymentsTableCreateCompanionBuilder =
    InvoicePaymentsCompanion Function({
      required String id,
      required String invoiceId,
      required double amount,
      Value<DateTime?> paymentDate,
      Value<String?> notes,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$InvoicePaymentsTableUpdateCompanionBuilder =
    InvoicePaymentsCompanion Function({
      Value<String> id,
      Value<String> invoiceId,
      Value<double> amount,
      Value<DateTime?> paymentDate,
      Value<String?> notes,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$InvoicePaymentsTableReferences
    extends
        BaseReferences<_$LocalDatabase, $InvoicePaymentsTable, InvoicePayment> {
  $$InvoicePaymentsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $InvoicesTable _invoiceIdTable(_$LocalDatabase db) =>
      db.invoices.createAlias(
        $_aliasNameGenerator(db.invoicePayments.invoiceId, db.invoices.id),
      );

  $$InvoicesTableProcessedTableManager get invoiceId {
    final $_column = $_itemColumn<String>('invoice_id')!;

    final manager = $$InvoicesTableTableManager(
      $_db,
      $_db.invoices,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_invoiceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$InvoicePaymentsTableFilterComposer
    extends Composer<_$LocalDatabase, $InvoicePaymentsTable> {
  $$InvoicePaymentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get paymentDate => $composableBuilder(
    column: $table.paymentDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$InvoicesTableFilterComposer get invoiceId {
    final $$InvoicesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.invoiceId,
      referencedTable: $db.invoices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvoicesTableFilterComposer(
            $db: $db,
            $table: $db.invoices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InvoicePaymentsTableOrderingComposer
    extends Composer<_$LocalDatabase, $InvoicePaymentsTable> {
  $$InvoicePaymentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get paymentDate => $composableBuilder(
    column: $table.paymentDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$InvoicesTableOrderingComposer get invoiceId {
    final $$InvoicesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.invoiceId,
      referencedTable: $db.invoices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvoicesTableOrderingComposer(
            $db: $db,
            $table: $db.invoices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InvoicePaymentsTableAnnotationComposer
    extends Composer<_$LocalDatabase, $InvoicePaymentsTable> {
  $$InvoicePaymentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<DateTime> get paymentDate => $composableBuilder(
    column: $table.paymentDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$InvoicesTableAnnotationComposer get invoiceId {
    final $$InvoicesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.invoiceId,
      referencedTable: $db.invoices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvoicesTableAnnotationComposer(
            $db: $db,
            $table: $db.invoices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InvoicePaymentsTableTableManager
    extends
        RootTableManager<
          _$LocalDatabase,
          $InvoicePaymentsTable,
          InvoicePayment,
          $$InvoicePaymentsTableFilterComposer,
          $$InvoicePaymentsTableOrderingComposer,
          $$InvoicePaymentsTableAnnotationComposer,
          $$InvoicePaymentsTableCreateCompanionBuilder,
          $$InvoicePaymentsTableUpdateCompanionBuilder,
          (InvoicePayment, $$InvoicePaymentsTableReferences),
          InvoicePayment,
          PrefetchHooks Function({bool invoiceId})
        > {
  $$InvoicePaymentsTableTableManager(
    _$LocalDatabase db,
    $InvoicePaymentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InvoicePaymentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InvoicePaymentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InvoicePaymentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> invoiceId = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<DateTime?> paymentDate = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InvoicePaymentsCompanion(
                id: id,
                invoiceId: invoiceId,
                amount: amount,
                paymentDate: paymentDate,
                notes: notes,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String invoiceId,
                required double amount,
                Value<DateTime?> paymentDate = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InvoicePaymentsCompanion.insert(
                id: id,
                invoiceId: invoiceId,
                amount: amount,
                paymentDate: paymentDate,
                notes: notes,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$InvoicePaymentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({invoiceId = false}) {
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
                    if (invoiceId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.invoiceId,
                                referencedTable:
                                    $$InvoicePaymentsTableReferences
                                        ._invoiceIdTable(db),
                                referencedColumn:
                                    $$InvoicePaymentsTableReferences
                                        ._invoiceIdTable(db)
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

typedef $$InvoicePaymentsTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDatabase,
      $InvoicePaymentsTable,
      InvoicePayment,
      $$InvoicePaymentsTableFilterComposer,
      $$InvoicePaymentsTableOrderingComposer,
      $$InvoicePaymentsTableAnnotationComposer,
      $$InvoicePaymentsTableCreateCompanionBuilder,
      $$InvoicePaymentsTableUpdateCompanionBuilder,
      (InvoicePayment, $$InvoicePaymentsTableReferences),
      InvoicePayment,
      PrefetchHooks Function({bool invoiceId})
    >;
typedef $$SupplierReceivedInvoicesTableCreateCompanionBuilder =
    SupplierReceivedInvoicesCompanion Function({
      required String id,
      required String supplierId,
      Value<DateTime> receivedDate,
      Value<String?> referenceNumber,
      Value<double> totalAmountSystem,
      Value<double> totalAmountSupplier,
      Value<String> status,
      Value<String?> notes,
      Value<DateTime> createdAt,
      Value<String?> discountPercents,
      Value<bool> vatEnabled,
      Value<int> rowid,
    });
typedef $$SupplierReceivedInvoicesTableUpdateCompanionBuilder =
    SupplierReceivedInvoicesCompanion Function({
      Value<String> id,
      Value<String> supplierId,
      Value<DateTime> receivedDate,
      Value<String?> referenceNumber,
      Value<double> totalAmountSystem,
      Value<double> totalAmountSupplier,
      Value<String> status,
      Value<String?> notes,
      Value<DateTime> createdAt,
      Value<String?> discountPercents,
      Value<bool> vatEnabled,
      Value<int> rowid,
    });

final class $$SupplierReceivedInvoicesTableReferences
    extends
        BaseReferences<
          _$LocalDatabase,
          $SupplierReceivedInvoicesTable,
          SupplierReceivedInvoice
        > {
  $$SupplierReceivedInvoicesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SuppliersTable _supplierIdTable(_$LocalDatabase db) =>
      db.suppliers.createAlias(
        $_aliasNameGenerator(
          db.supplierReceivedInvoices.supplierId,
          db.suppliers.id,
        ),
      );

  $$SuppliersTableProcessedTableManager get supplierId {
    final $_column = $_itemColumn<String>('supplier_id')!;

    final manager = $$SuppliersTableTableManager(
      $_db,
      $_db.suppliers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_supplierIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $SupplierReceivedInvoiceItemsTable,
    List<SupplierReceivedInvoiceItem>
  >
  _supplierReceivedInvoiceItemsRefsTable(_$LocalDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.supplierReceivedInvoiceItems,
        aliasName: $_aliasNameGenerator(
          db.supplierReceivedInvoices.id,
          db.supplierReceivedInvoiceItems.receivedInvoiceId,
        ),
      );

  $$SupplierReceivedInvoiceItemsTableProcessedTableManager
  get supplierReceivedInvoiceItemsRefs {
    final manager =
        $$SupplierReceivedInvoiceItemsTableTableManager(
          $_db,
          $_db.supplierReceivedInvoiceItems,
        ).filter(
          (f) => f.receivedInvoiceId.id.sqlEquals($_itemColumn<String>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _supplierReceivedInvoiceItemsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SupplierReceivedInvoicesTableFilterComposer
    extends Composer<_$LocalDatabase, $SupplierReceivedInvoicesTable> {
  $$SupplierReceivedInvoicesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get receivedDate => $composableBuilder(
    column: $table.receivedDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get referenceNumber => $composableBuilder(
    column: $table.referenceNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalAmountSystem => $composableBuilder(
    column: $table.totalAmountSystem,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalAmountSupplier => $composableBuilder(
    column: $table.totalAmountSupplier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get discountPercents => $composableBuilder(
    column: $table.discountPercents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get vatEnabled => $composableBuilder(
    column: $table.vatEnabled,
    builder: (column) => ColumnFilters(column),
  );

  $$SuppliersTableFilterComposer get supplierId {
    final $$SuppliersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.supplierId,
      referencedTable: $db.suppliers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SuppliersTableFilterComposer(
            $db: $db,
            $table: $db.suppliers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> supplierReceivedInvoiceItemsRefs(
    Expression<bool> Function(
      $$SupplierReceivedInvoiceItemsTableFilterComposer f,
    )
    f,
  ) {
    final $$SupplierReceivedInvoiceItemsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.supplierReceivedInvoiceItems,
          getReferencedColumn: (t) => t.receivedInvoiceId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SupplierReceivedInvoiceItemsTableFilterComposer(
                $db: $db,
                $table: $db.supplierReceivedInvoiceItems,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$SupplierReceivedInvoicesTableOrderingComposer
    extends Composer<_$LocalDatabase, $SupplierReceivedInvoicesTable> {
  $$SupplierReceivedInvoicesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get receivedDate => $composableBuilder(
    column: $table.receivedDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get referenceNumber => $composableBuilder(
    column: $table.referenceNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalAmountSystem => $composableBuilder(
    column: $table.totalAmountSystem,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalAmountSupplier => $composableBuilder(
    column: $table.totalAmountSupplier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get discountPercents => $composableBuilder(
    column: $table.discountPercents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get vatEnabled => $composableBuilder(
    column: $table.vatEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  $$SuppliersTableOrderingComposer get supplierId {
    final $$SuppliersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.supplierId,
      referencedTable: $db.suppliers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SuppliersTableOrderingComposer(
            $db: $db,
            $table: $db.suppliers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SupplierReceivedInvoicesTableAnnotationComposer
    extends Composer<_$LocalDatabase, $SupplierReceivedInvoicesTable> {
  $$SupplierReceivedInvoicesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get receivedDate => $composableBuilder(
    column: $table.receivedDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get referenceNumber => $composableBuilder(
    column: $table.referenceNumber,
    builder: (column) => column,
  );

  GeneratedColumn<double> get totalAmountSystem => $composableBuilder(
    column: $table.totalAmountSystem,
    builder: (column) => column,
  );

  GeneratedColumn<double> get totalAmountSupplier => $composableBuilder(
    column: $table.totalAmountSupplier,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get discountPercents => $composableBuilder(
    column: $table.discountPercents,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get vatEnabled => $composableBuilder(
    column: $table.vatEnabled,
    builder: (column) => column,
  );

  $$SuppliersTableAnnotationComposer get supplierId {
    final $$SuppliersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.supplierId,
      referencedTable: $db.suppliers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SuppliersTableAnnotationComposer(
            $db: $db,
            $table: $db.suppliers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> supplierReceivedInvoiceItemsRefs<T extends Object>(
    Expression<T> Function(
      $$SupplierReceivedInvoiceItemsTableAnnotationComposer a,
    )
    f,
  ) {
    final $$SupplierReceivedInvoiceItemsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.supplierReceivedInvoiceItems,
          getReferencedColumn: (t) => t.receivedInvoiceId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SupplierReceivedInvoiceItemsTableAnnotationComposer(
                $db: $db,
                $table: $db.supplierReceivedInvoiceItems,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$SupplierReceivedInvoicesTableTableManager
    extends
        RootTableManager<
          _$LocalDatabase,
          $SupplierReceivedInvoicesTable,
          SupplierReceivedInvoice,
          $$SupplierReceivedInvoicesTableFilterComposer,
          $$SupplierReceivedInvoicesTableOrderingComposer,
          $$SupplierReceivedInvoicesTableAnnotationComposer,
          $$SupplierReceivedInvoicesTableCreateCompanionBuilder,
          $$SupplierReceivedInvoicesTableUpdateCompanionBuilder,
          (SupplierReceivedInvoice, $$SupplierReceivedInvoicesTableReferences),
          SupplierReceivedInvoice,
          PrefetchHooks Function({
            bool supplierId,
            bool supplierReceivedInvoiceItemsRefs,
          })
        > {
  $$SupplierReceivedInvoicesTableTableManager(
    _$LocalDatabase db,
    $SupplierReceivedInvoicesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SupplierReceivedInvoicesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$SupplierReceivedInvoicesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$SupplierReceivedInvoicesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> supplierId = const Value.absent(),
                Value<DateTime> receivedDate = const Value.absent(),
                Value<String?> referenceNumber = const Value.absent(),
                Value<double> totalAmountSystem = const Value.absent(),
                Value<double> totalAmountSupplier = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String?> discountPercents = const Value.absent(),
                Value<bool> vatEnabled = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SupplierReceivedInvoicesCompanion(
                id: id,
                supplierId: supplierId,
                receivedDate: receivedDate,
                referenceNumber: referenceNumber,
                totalAmountSystem: totalAmountSystem,
                totalAmountSupplier: totalAmountSupplier,
                status: status,
                notes: notes,
                createdAt: createdAt,
                discountPercents: discountPercents,
                vatEnabled: vatEnabled,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String supplierId,
                Value<DateTime> receivedDate = const Value.absent(),
                Value<String?> referenceNumber = const Value.absent(),
                Value<double> totalAmountSystem = const Value.absent(),
                Value<double> totalAmountSupplier = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String?> discountPercents = const Value.absent(),
                Value<bool> vatEnabled = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SupplierReceivedInvoicesCompanion.insert(
                id: id,
                supplierId: supplierId,
                receivedDate: receivedDate,
                referenceNumber: referenceNumber,
                totalAmountSystem: totalAmountSystem,
                totalAmountSupplier: totalAmountSupplier,
                status: status,
                notes: notes,
                createdAt: createdAt,
                discountPercents: discountPercents,
                vatEnabled: vatEnabled,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SupplierReceivedInvoicesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({supplierId = false, supplierReceivedInvoiceItemsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (supplierReceivedInvoiceItemsRefs)
                      db.supplierReceivedInvoiceItems,
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
                        if (supplierId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.supplierId,
                                    referencedTable:
                                        $$SupplierReceivedInvoicesTableReferences
                                            ._supplierIdTable(db),
                                    referencedColumn:
                                        $$SupplierReceivedInvoicesTableReferences
                                            ._supplierIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (supplierReceivedInvoiceItemsRefs)
                        await $_getPrefetchedData<
                          SupplierReceivedInvoice,
                          $SupplierReceivedInvoicesTable,
                          SupplierReceivedInvoiceItem
                        >(
                          currentTable: table,
                          referencedTable:
                              $$SupplierReceivedInvoicesTableReferences
                                  ._supplierReceivedInvoiceItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SupplierReceivedInvoicesTableReferences(
                                db,
                                table,
                                p0,
                              ).supplierReceivedInvoiceItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.receivedInvoiceId == item.id,
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

typedef $$SupplierReceivedInvoicesTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDatabase,
      $SupplierReceivedInvoicesTable,
      SupplierReceivedInvoice,
      $$SupplierReceivedInvoicesTableFilterComposer,
      $$SupplierReceivedInvoicesTableOrderingComposer,
      $$SupplierReceivedInvoicesTableAnnotationComposer,
      $$SupplierReceivedInvoicesTableCreateCompanionBuilder,
      $$SupplierReceivedInvoicesTableUpdateCompanionBuilder,
      (SupplierReceivedInvoice, $$SupplierReceivedInvoicesTableReferences),
      SupplierReceivedInvoice,
      PrefetchHooks Function({
        bool supplierId,
        bool supplierReceivedInvoiceItemsRefs,
      })
    >;
typedef $$SupplierReceivedInvoiceItemsTableCreateCompanionBuilder =
    SupplierReceivedInvoiceItemsCompanion Function({
      required String id,
      required String receivedInvoiceId,
      required String productId,
      required String unitType,
      required int quantity,
      required double systemPrice,
      required double supplierPrice,
      required double subtotalSystem,
      required double subtotalSupplier,
      Value<bool> isFree,
      Value<double?> rawSupplierPrice,
      Value<int> rowid,
    });
typedef $$SupplierReceivedInvoiceItemsTableUpdateCompanionBuilder =
    SupplierReceivedInvoiceItemsCompanion Function({
      Value<String> id,
      Value<String> receivedInvoiceId,
      Value<String> productId,
      Value<String> unitType,
      Value<int> quantity,
      Value<double> systemPrice,
      Value<double> supplierPrice,
      Value<double> subtotalSystem,
      Value<double> subtotalSupplier,
      Value<bool> isFree,
      Value<double?> rawSupplierPrice,
      Value<int> rowid,
    });

final class $$SupplierReceivedInvoiceItemsTableReferences
    extends
        BaseReferences<
          _$LocalDatabase,
          $SupplierReceivedInvoiceItemsTable,
          SupplierReceivedInvoiceItem
        > {
  $$SupplierReceivedInvoiceItemsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SupplierReceivedInvoicesTable _receivedInvoiceIdTable(
    _$LocalDatabase db,
  ) => db.supplierReceivedInvoices.createAlias(
    $_aliasNameGenerator(
      db.supplierReceivedInvoiceItems.receivedInvoiceId,
      db.supplierReceivedInvoices.id,
    ),
  );

  $$SupplierReceivedInvoicesTableProcessedTableManager get receivedInvoiceId {
    final $_column = $_itemColumn<String>('received_invoice_id')!;

    final manager = $$SupplierReceivedInvoicesTableTableManager(
      $_db,
      $_db.supplierReceivedInvoices,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_receivedInvoiceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ProductsTable _productIdTable(_$LocalDatabase db) =>
      db.products.createAlias(
        $_aliasNameGenerator(
          db.supplierReceivedInvoiceItems.productId,
          db.products.id,
        ),
      );

  $$ProductsTableProcessedTableManager get productId {
    final $_column = $_itemColumn<String>('product_id')!;

    final manager = $$ProductsTableTableManager(
      $_db,
      $_db.products,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_productIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SupplierReceivedInvoiceItemsTableFilterComposer
    extends Composer<_$LocalDatabase, $SupplierReceivedInvoiceItemsTable> {
  $$SupplierReceivedInvoiceItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unitType => $composableBuilder(
    column: $table.unitType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get systemPrice => $composableBuilder(
    column: $table.systemPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get supplierPrice => $composableBuilder(
    column: $table.supplierPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get subtotalSystem => $composableBuilder(
    column: $table.subtotalSystem,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get subtotalSupplier => $composableBuilder(
    column: $table.subtotalSupplier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFree => $composableBuilder(
    column: $table.isFree,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rawSupplierPrice => $composableBuilder(
    column: $table.rawSupplierPrice,
    builder: (column) => ColumnFilters(column),
  );

  $$SupplierReceivedInvoicesTableFilterComposer get receivedInvoiceId {
    final $$SupplierReceivedInvoicesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.receivedInvoiceId,
          referencedTable: $db.supplierReceivedInvoices,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SupplierReceivedInvoicesTableFilterComposer(
                $db: $db,
                $table: $db.supplierReceivedInvoices,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$ProductsTableFilterComposer get productId {
    final $$ProductsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableFilterComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SupplierReceivedInvoiceItemsTableOrderingComposer
    extends Composer<_$LocalDatabase, $SupplierReceivedInvoiceItemsTable> {
  $$SupplierReceivedInvoiceItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unitType => $composableBuilder(
    column: $table.unitType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get systemPrice => $composableBuilder(
    column: $table.systemPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get supplierPrice => $composableBuilder(
    column: $table.supplierPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get subtotalSystem => $composableBuilder(
    column: $table.subtotalSystem,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get subtotalSupplier => $composableBuilder(
    column: $table.subtotalSupplier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFree => $composableBuilder(
    column: $table.isFree,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rawSupplierPrice => $composableBuilder(
    column: $table.rawSupplierPrice,
    builder: (column) => ColumnOrderings(column),
  );

  $$SupplierReceivedInvoicesTableOrderingComposer get receivedInvoiceId {
    final $$SupplierReceivedInvoicesTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.receivedInvoiceId,
          referencedTable: $db.supplierReceivedInvoices,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SupplierReceivedInvoicesTableOrderingComposer(
                $db: $db,
                $table: $db.supplierReceivedInvoices,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$ProductsTableOrderingComposer get productId {
    final $$ProductsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableOrderingComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SupplierReceivedInvoiceItemsTableAnnotationComposer
    extends Composer<_$LocalDatabase, $SupplierReceivedInvoiceItemsTable> {
  $$SupplierReceivedInvoiceItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get unitType =>
      $composableBuilder(column: $table.unitType, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<double> get systemPrice => $composableBuilder(
    column: $table.systemPrice,
    builder: (column) => column,
  );

  GeneratedColumn<double> get supplierPrice => $composableBuilder(
    column: $table.supplierPrice,
    builder: (column) => column,
  );

  GeneratedColumn<double> get subtotalSystem => $composableBuilder(
    column: $table.subtotalSystem,
    builder: (column) => column,
  );

  GeneratedColumn<double> get subtotalSupplier => $composableBuilder(
    column: $table.subtotalSupplier,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isFree =>
      $composableBuilder(column: $table.isFree, builder: (column) => column);

  GeneratedColumn<double> get rawSupplierPrice => $composableBuilder(
    column: $table.rawSupplierPrice,
    builder: (column) => column,
  );

  $$SupplierReceivedInvoicesTableAnnotationComposer get receivedInvoiceId {
    final $$SupplierReceivedInvoicesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.receivedInvoiceId,
          referencedTable: $db.supplierReceivedInvoices,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SupplierReceivedInvoicesTableAnnotationComposer(
                $db: $db,
                $table: $db.supplierReceivedInvoices,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$ProductsTableAnnotationComposer get productId {
    final $$ProductsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableAnnotationComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SupplierReceivedInvoiceItemsTableTableManager
    extends
        RootTableManager<
          _$LocalDatabase,
          $SupplierReceivedInvoiceItemsTable,
          SupplierReceivedInvoiceItem,
          $$SupplierReceivedInvoiceItemsTableFilterComposer,
          $$SupplierReceivedInvoiceItemsTableOrderingComposer,
          $$SupplierReceivedInvoiceItemsTableAnnotationComposer,
          $$SupplierReceivedInvoiceItemsTableCreateCompanionBuilder,
          $$SupplierReceivedInvoiceItemsTableUpdateCompanionBuilder,
          (
            SupplierReceivedInvoiceItem,
            $$SupplierReceivedInvoiceItemsTableReferences,
          ),
          SupplierReceivedInvoiceItem,
          PrefetchHooks Function({bool receivedInvoiceId, bool productId})
        > {
  $$SupplierReceivedInvoiceItemsTableTableManager(
    _$LocalDatabase db,
    $SupplierReceivedInvoiceItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SupplierReceivedInvoiceItemsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$SupplierReceivedInvoiceItemsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$SupplierReceivedInvoiceItemsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> receivedInvoiceId = const Value.absent(),
                Value<String> productId = const Value.absent(),
                Value<String> unitType = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<double> systemPrice = const Value.absent(),
                Value<double> supplierPrice = const Value.absent(),
                Value<double> subtotalSystem = const Value.absent(),
                Value<double> subtotalSupplier = const Value.absent(),
                Value<bool> isFree = const Value.absent(),
                Value<double?> rawSupplierPrice = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SupplierReceivedInvoiceItemsCompanion(
                id: id,
                receivedInvoiceId: receivedInvoiceId,
                productId: productId,
                unitType: unitType,
                quantity: quantity,
                systemPrice: systemPrice,
                supplierPrice: supplierPrice,
                subtotalSystem: subtotalSystem,
                subtotalSupplier: subtotalSupplier,
                isFree: isFree,
                rawSupplierPrice: rawSupplierPrice,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String receivedInvoiceId,
                required String productId,
                required String unitType,
                required int quantity,
                required double systemPrice,
                required double supplierPrice,
                required double subtotalSystem,
                required double subtotalSupplier,
                Value<bool> isFree = const Value.absent(),
                Value<double?> rawSupplierPrice = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SupplierReceivedInvoiceItemsCompanion.insert(
                id: id,
                receivedInvoiceId: receivedInvoiceId,
                productId: productId,
                unitType: unitType,
                quantity: quantity,
                systemPrice: systemPrice,
                supplierPrice: supplierPrice,
                subtotalSystem: subtotalSystem,
                subtotalSupplier: subtotalSupplier,
                isFree: isFree,
                rawSupplierPrice: rawSupplierPrice,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SupplierReceivedInvoiceItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({receivedInvoiceId = false, productId = false}) {
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
                    if (receivedInvoiceId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.receivedInvoiceId,
                                referencedTable:
                                    $$SupplierReceivedInvoiceItemsTableReferences
                                        ._receivedInvoiceIdTable(db),
                                referencedColumn:
                                    $$SupplierReceivedInvoiceItemsTableReferences
                                        ._receivedInvoiceIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (productId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.productId,
                                referencedTable:
                                    $$SupplierReceivedInvoiceItemsTableReferences
                                        ._productIdTable(db),
                                referencedColumn:
                                    $$SupplierReceivedInvoiceItemsTableReferences
                                        ._productIdTable(db)
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

typedef $$SupplierReceivedInvoiceItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDatabase,
      $SupplierReceivedInvoiceItemsTable,
      SupplierReceivedInvoiceItem,
      $$SupplierReceivedInvoiceItemsTableFilterComposer,
      $$SupplierReceivedInvoiceItemsTableOrderingComposer,
      $$SupplierReceivedInvoiceItemsTableAnnotationComposer,
      $$SupplierReceivedInvoiceItemsTableCreateCompanionBuilder,
      $$SupplierReceivedInvoiceItemsTableUpdateCompanionBuilder,
      (
        SupplierReceivedInvoiceItem,
        $$SupplierReceivedInvoiceItemsTableReferences,
      ),
      SupplierReceivedInvoiceItem,
      PrefetchHooks Function({bool receivedInvoiceId, bool productId})
    >;
typedef $$PurchaseOrdersTableCreateCompanionBuilder =
    PurchaseOrdersCompanion Function({
      required String id,
      required String supplierId,
      Value<DateTime> orderDate,
      Value<String?> referenceNumber,
      Value<double> totalAmount,
      Value<String> status,
      Value<String?> notes,
      Value<DateTime> createdAt,
      Value<String?> discountPercents,
      Value<bool> vatEnabled,
      Value<String?> preparedBy,
      Value<int> rowid,
    });
typedef $$PurchaseOrdersTableUpdateCompanionBuilder =
    PurchaseOrdersCompanion Function({
      Value<String> id,
      Value<String> supplierId,
      Value<DateTime> orderDate,
      Value<String?> referenceNumber,
      Value<double> totalAmount,
      Value<String> status,
      Value<String?> notes,
      Value<DateTime> createdAt,
      Value<String?> discountPercents,
      Value<bool> vatEnabled,
      Value<String?> preparedBy,
      Value<int> rowid,
    });

final class $$PurchaseOrdersTableReferences
    extends
        BaseReferences<_$LocalDatabase, $PurchaseOrdersTable, PurchaseOrder> {
  $$PurchaseOrdersTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SuppliersTable _supplierIdTable(_$LocalDatabase db) =>
      db.suppliers.createAlias(
        $_aliasNameGenerator(db.purchaseOrders.supplierId, db.suppliers.id),
      );

  $$SuppliersTableProcessedTableManager get supplierId {
    final $_column = $_itemColumn<String>('supplier_id')!;

    final manager = $$SuppliersTableTableManager(
      $_db,
      $_db.suppliers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_supplierIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$PurchaseOrderItemsTable, List<PurchaseOrderItem>>
  _purchaseOrderItemsRefsTable(_$LocalDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.purchaseOrderItems,
        aliasName: $_aliasNameGenerator(
          db.purchaseOrders.id,
          db.purchaseOrderItems.purchaseOrderId,
        ),
      );

  $$PurchaseOrderItemsTableProcessedTableManager get purchaseOrderItemsRefs {
    final manager =
        $$PurchaseOrderItemsTableTableManager(
          $_db,
          $_db.purchaseOrderItems,
        ).filter(
          (f) => f.purchaseOrderId.id.sqlEquals($_itemColumn<String>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _purchaseOrderItemsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PurchaseOrdersTableFilterComposer
    extends Composer<_$LocalDatabase, $PurchaseOrdersTable> {
  $$PurchaseOrdersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get orderDate => $composableBuilder(
    column: $table.orderDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get referenceNumber => $composableBuilder(
    column: $table.referenceNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get discountPercents => $composableBuilder(
    column: $table.discountPercents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get vatEnabled => $composableBuilder(
    column: $table.vatEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get preparedBy => $composableBuilder(
    column: $table.preparedBy,
    builder: (column) => ColumnFilters(column),
  );

  $$SuppliersTableFilterComposer get supplierId {
    final $$SuppliersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.supplierId,
      referencedTable: $db.suppliers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SuppliersTableFilterComposer(
            $db: $db,
            $table: $db.suppliers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> purchaseOrderItemsRefs(
    Expression<bool> Function($$PurchaseOrderItemsTableFilterComposer f) f,
  ) {
    final $$PurchaseOrderItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.purchaseOrderItems,
      getReferencedColumn: (t) => t.purchaseOrderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PurchaseOrderItemsTableFilterComposer(
            $db: $db,
            $table: $db.purchaseOrderItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PurchaseOrdersTableOrderingComposer
    extends Composer<_$LocalDatabase, $PurchaseOrdersTable> {
  $$PurchaseOrdersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get orderDate => $composableBuilder(
    column: $table.orderDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get referenceNumber => $composableBuilder(
    column: $table.referenceNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get discountPercents => $composableBuilder(
    column: $table.discountPercents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get vatEnabled => $composableBuilder(
    column: $table.vatEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get preparedBy => $composableBuilder(
    column: $table.preparedBy,
    builder: (column) => ColumnOrderings(column),
  );

  $$SuppliersTableOrderingComposer get supplierId {
    final $$SuppliersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.supplierId,
      referencedTable: $db.suppliers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SuppliersTableOrderingComposer(
            $db: $db,
            $table: $db.suppliers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PurchaseOrdersTableAnnotationComposer
    extends Composer<_$LocalDatabase, $PurchaseOrdersTable> {
  $$PurchaseOrdersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get orderDate =>
      $composableBuilder(column: $table.orderDate, builder: (column) => column);

  GeneratedColumn<String> get referenceNumber => $composableBuilder(
    column: $table.referenceNumber,
    builder: (column) => column,
  );

  GeneratedColumn<double> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get discountPercents => $composableBuilder(
    column: $table.discountPercents,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get vatEnabled => $composableBuilder(
    column: $table.vatEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<String> get preparedBy => $composableBuilder(
    column: $table.preparedBy,
    builder: (column) => column,
  );

  $$SuppliersTableAnnotationComposer get supplierId {
    final $$SuppliersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.supplierId,
      referencedTable: $db.suppliers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SuppliersTableAnnotationComposer(
            $db: $db,
            $table: $db.suppliers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> purchaseOrderItemsRefs<T extends Object>(
    Expression<T> Function($$PurchaseOrderItemsTableAnnotationComposer a) f,
  ) {
    final $$PurchaseOrderItemsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.purchaseOrderItems,
          getReferencedColumn: (t) => t.purchaseOrderId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PurchaseOrderItemsTableAnnotationComposer(
                $db: $db,
                $table: $db.purchaseOrderItems,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$PurchaseOrdersTableTableManager
    extends
        RootTableManager<
          _$LocalDatabase,
          $PurchaseOrdersTable,
          PurchaseOrder,
          $$PurchaseOrdersTableFilterComposer,
          $$PurchaseOrdersTableOrderingComposer,
          $$PurchaseOrdersTableAnnotationComposer,
          $$PurchaseOrdersTableCreateCompanionBuilder,
          $$PurchaseOrdersTableUpdateCompanionBuilder,
          (PurchaseOrder, $$PurchaseOrdersTableReferences),
          PurchaseOrder,
          PrefetchHooks Function({bool supplierId, bool purchaseOrderItemsRefs})
        > {
  $$PurchaseOrdersTableTableManager(
    _$LocalDatabase db,
    $PurchaseOrdersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PurchaseOrdersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PurchaseOrdersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PurchaseOrdersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> supplierId = const Value.absent(),
                Value<DateTime> orderDate = const Value.absent(),
                Value<String?> referenceNumber = const Value.absent(),
                Value<double> totalAmount = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String?> discountPercents = const Value.absent(),
                Value<bool> vatEnabled = const Value.absent(),
                Value<String?> preparedBy = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PurchaseOrdersCompanion(
                id: id,
                supplierId: supplierId,
                orderDate: orderDate,
                referenceNumber: referenceNumber,
                totalAmount: totalAmount,
                status: status,
                notes: notes,
                createdAt: createdAt,
                discountPercents: discountPercents,
                vatEnabled: vatEnabled,
                preparedBy: preparedBy,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String supplierId,
                Value<DateTime> orderDate = const Value.absent(),
                Value<String?> referenceNumber = const Value.absent(),
                Value<double> totalAmount = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String?> discountPercents = const Value.absent(),
                Value<bool> vatEnabled = const Value.absent(),
                Value<String?> preparedBy = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PurchaseOrdersCompanion.insert(
                id: id,
                supplierId: supplierId,
                orderDate: orderDate,
                referenceNumber: referenceNumber,
                totalAmount: totalAmount,
                status: status,
                notes: notes,
                createdAt: createdAt,
                discountPercents: discountPercents,
                vatEnabled: vatEnabled,
                preparedBy: preparedBy,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PurchaseOrdersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({supplierId = false, purchaseOrderItemsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (purchaseOrderItemsRefs) db.purchaseOrderItems,
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
                        if (supplierId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.supplierId,
                                    referencedTable:
                                        $$PurchaseOrdersTableReferences
                                            ._supplierIdTable(db),
                                    referencedColumn:
                                        $$PurchaseOrdersTableReferences
                                            ._supplierIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (purchaseOrderItemsRefs)
                        await $_getPrefetchedData<
                          PurchaseOrder,
                          $PurchaseOrdersTable,
                          PurchaseOrderItem
                        >(
                          currentTable: table,
                          referencedTable: $$PurchaseOrdersTableReferences
                              ._purchaseOrderItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PurchaseOrdersTableReferences(
                                db,
                                table,
                                p0,
                              ).purchaseOrderItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.purchaseOrderId == item.id,
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

typedef $$PurchaseOrdersTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDatabase,
      $PurchaseOrdersTable,
      PurchaseOrder,
      $$PurchaseOrdersTableFilterComposer,
      $$PurchaseOrdersTableOrderingComposer,
      $$PurchaseOrdersTableAnnotationComposer,
      $$PurchaseOrdersTableCreateCompanionBuilder,
      $$PurchaseOrdersTableUpdateCompanionBuilder,
      (PurchaseOrder, $$PurchaseOrdersTableReferences),
      PurchaseOrder,
      PrefetchHooks Function({bool supplierId, bool purchaseOrderItemsRefs})
    >;
typedef $$PurchaseOrderItemsTableCreateCompanionBuilder =
    PurchaseOrderItemsCompanion Function({
      required String id,
      required String purchaseOrderId,
      required String productId,
      Value<double> systemPrice,
      required double price,
      required double cases,
      required double amount,
      Value<bool> isFree,
      Value<double?> rawPrice,
      Value<int> rowid,
    });
typedef $$PurchaseOrderItemsTableUpdateCompanionBuilder =
    PurchaseOrderItemsCompanion Function({
      Value<String> id,
      Value<String> purchaseOrderId,
      Value<String> productId,
      Value<double> systemPrice,
      Value<double> price,
      Value<double> cases,
      Value<double> amount,
      Value<bool> isFree,
      Value<double?> rawPrice,
      Value<int> rowid,
    });

final class $$PurchaseOrderItemsTableReferences
    extends
        BaseReferences<
          _$LocalDatabase,
          $PurchaseOrderItemsTable,
          PurchaseOrderItem
        > {
  $$PurchaseOrderItemsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PurchaseOrdersTable _purchaseOrderIdTable(_$LocalDatabase db) =>
      db.purchaseOrders.createAlias(
        $_aliasNameGenerator(
          db.purchaseOrderItems.purchaseOrderId,
          db.purchaseOrders.id,
        ),
      );

  $$PurchaseOrdersTableProcessedTableManager get purchaseOrderId {
    final $_column = $_itemColumn<String>('purchase_order_id')!;

    final manager = $$PurchaseOrdersTableTableManager(
      $_db,
      $_db.purchaseOrders,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_purchaseOrderIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ProductsTable _productIdTable(_$LocalDatabase db) =>
      db.products.createAlias(
        $_aliasNameGenerator(db.purchaseOrderItems.productId, db.products.id),
      );

  $$ProductsTableProcessedTableManager get productId {
    final $_column = $_itemColumn<String>('product_id')!;

    final manager = $$ProductsTableTableManager(
      $_db,
      $_db.products,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_productIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PurchaseOrderItemsTableFilterComposer
    extends Composer<_$LocalDatabase, $PurchaseOrderItemsTable> {
  $$PurchaseOrderItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get systemPrice => $composableBuilder(
    column: $table.systemPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get cases => $composableBuilder(
    column: $table.cases,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFree => $composableBuilder(
    column: $table.isFree,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rawPrice => $composableBuilder(
    column: $table.rawPrice,
    builder: (column) => ColumnFilters(column),
  );

  $$PurchaseOrdersTableFilterComposer get purchaseOrderId {
    final $$PurchaseOrdersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.purchaseOrderId,
      referencedTable: $db.purchaseOrders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PurchaseOrdersTableFilterComposer(
            $db: $db,
            $table: $db.purchaseOrders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProductsTableFilterComposer get productId {
    final $$ProductsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableFilterComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PurchaseOrderItemsTableOrderingComposer
    extends Composer<_$LocalDatabase, $PurchaseOrderItemsTable> {
  $$PurchaseOrderItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get systemPrice => $composableBuilder(
    column: $table.systemPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get cases => $composableBuilder(
    column: $table.cases,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFree => $composableBuilder(
    column: $table.isFree,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rawPrice => $composableBuilder(
    column: $table.rawPrice,
    builder: (column) => ColumnOrderings(column),
  );

  $$PurchaseOrdersTableOrderingComposer get purchaseOrderId {
    final $$PurchaseOrdersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.purchaseOrderId,
      referencedTable: $db.purchaseOrders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PurchaseOrdersTableOrderingComposer(
            $db: $db,
            $table: $db.purchaseOrders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProductsTableOrderingComposer get productId {
    final $$ProductsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableOrderingComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PurchaseOrderItemsTableAnnotationComposer
    extends Composer<_$LocalDatabase, $PurchaseOrderItemsTable> {
  $$PurchaseOrderItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get systemPrice => $composableBuilder(
    column: $table.systemPrice,
    builder: (column) => column,
  );

  GeneratedColumn<double> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumn<double> get cases =>
      $composableBuilder(column: $table.cases, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<bool> get isFree =>
      $composableBuilder(column: $table.isFree, builder: (column) => column);

  GeneratedColumn<double> get rawPrice =>
      $composableBuilder(column: $table.rawPrice, builder: (column) => column);

  $$PurchaseOrdersTableAnnotationComposer get purchaseOrderId {
    final $$PurchaseOrdersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.purchaseOrderId,
      referencedTable: $db.purchaseOrders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PurchaseOrdersTableAnnotationComposer(
            $db: $db,
            $table: $db.purchaseOrders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProductsTableAnnotationComposer get productId {
    final $$ProductsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableAnnotationComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PurchaseOrderItemsTableTableManager
    extends
        RootTableManager<
          _$LocalDatabase,
          $PurchaseOrderItemsTable,
          PurchaseOrderItem,
          $$PurchaseOrderItemsTableFilterComposer,
          $$PurchaseOrderItemsTableOrderingComposer,
          $$PurchaseOrderItemsTableAnnotationComposer,
          $$PurchaseOrderItemsTableCreateCompanionBuilder,
          $$PurchaseOrderItemsTableUpdateCompanionBuilder,
          (PurchaseOrderItem, $$PurchaseOrderItemsTableReferences),
          PurchaseOrderItem,
          PrefetchHooks Function({bool purchaseOrderId, bool productId})
        > {
  $$PurchaseOrderItemsTableTableManager(
    _$LocalDatabase db,
    $PurchaseOrderItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PurchaseOrderItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PurchaseOrderItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PurchaseOrderItemsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> purchaseOrderId = const Value.absent(),
                Value<String> productId = const Value.absent(),
                Value<double> systemPrice = const Value.absent(),
                Value<double> price = const Value.absent(),
                Value<double> cases = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<bool> isFree = const Value.absent(),
                Value<double?> rawPrice = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PurchaseOrderItemsCompanion(
                id: id,
                purchaseOrderId: purchaseOrderId,
                productId: productId,
                systemPrice: systemPrice,
                price: price,
                cases: cases,
                amount: amount,
                isFree: isFree,
                rawPrice: rawPrice,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String purchaseOrderId,
                required String productId,
                Value<double> systemPrice = const Value.absent(),
                required double price,
                required double cases,
                required double amount,
                Value<bool> isFree = const Value.absent(),
                Value<double?> rawPrice = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PurchaseOrderItemsCompanion.insert(
                id: id,
                purchaseOrderId: purchaseOrderId,
                productId: productId,
                systemPrice: systemPrice,
                price: price,
                cases: cases,
                amount: amount,
                isFree: isFree,
                rawPrice: rawPrice,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PurchaseOrderItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({purchaseOrderId = false, productId = false}) {
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
                        if (purchaseOrderId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.purchaseOrderId,
                                    referencedTable:
                                        $$PurchaseOrderItemsTableReferences
                                            ._purchaseOrderIdTable(db),
                                    referencedColumn:
                                        $$PurchaseOrderItemsTableReferences
                                            ._purchaseOrderIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (productId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.productId,
                                    referencedTable:
                                        $$PurchaseOrderItemsTableReferences
                                            ._productIdTable(db),
                                    referencedColumn:
                                        $$PurchaseOrderItemsTableReferences
                                            ._productIdTable(db)
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

typedef $$PurchaseOrderItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDatabase,
      $PurchaseOrderItemsTable,
      PurchaseOrderItem,
      $$PurchaseOrderItemsTableFilterComposer,
      $$PurchaseOrderItemsTableOrderingComposer,
      $$PurchaseOrderItemsTableAnnotationComposer,
      $$PurchaseOrderItemsTableCreateCompanionBuilder,
      $$PurchaseOrderItemsTableUpdateCompanionBuilder,
      (PurchaseOrderItem, $$PurchaseOrderItemsTableReferences),
      PurchaseOrderItem,
      PrefetchHooks Function({bool purchaseOrderId, bool productId})
    >;
typedef $$PreOrderReviewsTableCreateCompanionBuilder =
    PreOrderReviewsCompanion Function({
      required String id,
      required String sourceFile,
      required String originalExportedAt,
      Value<DateTime> reviewedAt,
      Value<int> rowid,
    });
typedef $$PreOrderReviewsTableUpdateCompanionBuilder =
    PreOrderReviewsCompanion Function({
      Value<String> id,
      Value<String> sourceFile,
      Value<String> originalExportedAt,
      Value<DateTime> reviewedAt,
      Value<int> rowid,
    });

final class $$PreOrderReviewsTableReferences
    extends
        BaseReferences<_$LocalDatabase, $PreOrderReviewsTable, PreOrderReview> {
  $$PreOrderReviewsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<
    $PreOrderReviewItemsTable,
    List<PreOrderReviewItem>
  >
  _preOrderReviewItemsRefsTable(_$LocalDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.preOrderReviewItems,
        aliasName: $_aliasNameGenerator(
          db.preOrderReviews.id,
          db.preOrderReviewItems.reviewId,
        ),
      );

  $$PreOrderReviewItemsTableProcessedTableManager get preOrderReviewItemsRefs {
    final manager = $$PreOrderReviewItemsTableTableManager(
      $_db,
      $_db.preOrderReviewItems,
    ).filter((f) => f.reviewId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _preOrderReviewItemsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PreOrderReviewsTableFilterComposer
    extends Composer<_$LocalDatabase, $PreOrderReviewsTable> {
  $$PreOrderReviewsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceFile => $composableBuilder(
    column: $table.sourceFile,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originalExportedAt => $composableBuilder(
    column: $table.originalExportedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get reviewedAt => $composableBuilder(
    column: $table.reviewedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> preOrderReviewItemsRefs(
    Expression<bool> Function($$PreOrderReviewItemsTableFilterComposer f) f,
  ) {
    final $$PreOrderReviewItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.preOrderReviewItems,
      getReferencedColumn: (t) => t.reviewId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PreOrderReviewItemsTableFilterComposer(
            $db: $db,
            $table: $db.preOrderReviewItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PreOrderReviewsTableOrderingComposer
    extends Composer<_$LocalDatabase, $PreOrderReviewsTable> {
  $$PreOrderReviewsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceFile => $composableBuilder(
    column: $table.sourceFile,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originalExportedAt => $composableBuilder(
    column: $table.originalExportedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get reviewedAt => $composableBuilder(
    column: $table.reviewedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PreOrderReviewsTableAnnotationComposer
    extends Composer<_$LocalDatabase, $PreOrderReviewsTable> {
  $$PreOrderReviewsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sourceFile => $composableBuilder(
    column: $table.sourceFile,
    builder: (column) => column,
  );

  GeneratedColumn<String> get originalExportedAt => $composableBuilder(
    column: $table.originalExportedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get reviewedAt => $composableBuilder(
    column: $table.reviewedAt,
    builder: (column) => column,
  );

  Expression<T> preOrderReviewItemsRefs<T extends Object>(
    Expression<T> Function($$PreOrderReviewItemsTableAnnotationComposer a) f,
  ) {
    final $$PreOrderReviewItemsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.preOrderReviewItems,
          getReferencedColumn: (t) => t.reviewId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PreOrderReviewItemsTableAnnotationComposer(
                $db: $db,
                $table: $db.preOrderReviewItems,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$PreOrderReviewsTableTableManager
    extends
        RootTableManager<
          _$LocalDatabase,
          $PreOrderReviewsTable,
          PreOrderReview,
          $$PreOrderReviewsTableFilterComposer,
          $$PreOrderReviewsTableOrderingComposer,
          $$PreOrderReviewsTableAnnotationComposer,
          $$PreOrderReviewsTableCreateCompanionBuilder,
          $$PreOrderReviewsTableUpdateCompanionBuilder,
          (PreOrderReview, $$PreOrderReviewsTableReferences),
          PreOrderReview,
          PrefetchHooks Function({bool preOrderReviewItemsRefs})
        > {
  $$PreOrderReviewsTableTableManager(
    _$LocalDatabase db,
    $PreOrderReviewsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PreOrderReviewsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PreOrderReviewsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PreOrderReviewsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sourceFile = const Value.absent(),
                Value<String> originalExportedAt = const Value.absent(),
                Value<DateTime> reviewedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PreOrderReviewsCompanion(
                id: id,
                sourceFile: sourceFile,
                originalExportedAt: originalExportedAt,
                reviewedAt: reviewedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sourceFile,
                required String originalExportedAt,
                Value<DateTime> reviewedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PreOrderReviewsCompanion.insert(
                id: id,
                sourceFile: sourceFile,
                originalExportedAt: originalExportedAt,
                reviewedAt: reviewedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PreOrderReviewsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({preOrderReviewItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (preOrderReviewItemsRefs) db.preOrderReviewItems,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (preOrderReviewItemsRefs)
                    await $_getPrefetchedData<
                      PreOrderReview,
                      $PreOrderReviewsTable,
                      PreOrderReviewItem
                    >(
                      currentTable: table,
                      referencedTable: $$PreOrderReviewsTableReferences
                          ._preOrderReviewItemsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$PreOrderReviewsTableReferences(
                            db,
                            table,
                            p0,
                          ).preOrderReviewItemsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.reviewId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$PreOrderReviewsTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDatabase,
      $PreOrderReviewsTable,
      PreOrderReview,
      $$PreOrderReviewsTableFilterComposer,
      $$PreOrderReviewsTableOrderingComposer,
      $$PreOrderReviewsTableAnnotationComposer,
      $$PreOrderReviewsTableCreateCompanionBuilder,
      $$PreOrderReviewsTableUpdateCompanionBuilder,
      (PreOrderReview, $$PreOrderReviewsTableReferences),
      PreOrderReview,
      PrefetchHooks Function({bool preOrderReviewItemsRefs})
    >;
typedef $$PreOrderReviewItemsTableCreateCompanionBuilder =
    PreOrderReviewItemsCompanion Function({
      required String id,
      required String reviewId,
      Value<String?> productId,
      Value<String?> matchedProductId,
      required String productName,
      Value<String?> productCode,
      required String supplierName,
      required int piecesPerBox,
      required int requestedPieces,
      Value<int> availablePieces,
      required int confirmedPieces,
      Value<int> rowid,
    });
typedef $$PreOrderReviewItemsTableUpdateCompanionBuilder =
    PreOrderReviewItemsCompanion Function({
      Value<String> id,
      Value<String> reviewId,
      Value<String?> productId,
      Value<String?> matchedProductId,
      Value<String> productName,
      Value<String?> productCode,
      Value<String> supplierName,
      Value<int> piecesPerBox,
      Value<int> requestedPieces,
      Value<int> availablePieces,
      Value<int> confirmedPieces,
      Value<int> rowid,
    });

final class $$PreOrderReviewItemsTableReferences
    extends
        BaseReferences<
          _$LocalDatabase,
          $PreOrderReviewItemsTable,
          PreOrderReviewItem
        > {
  $$PreOrderReviewItemsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PreOrderReviewsTable _reviewIdTable(_$LocalDatabase db) =>
      db.preOrderReviews.createAlias(
        $_aliasNameGenerator(
          db.preOrderReviewItems.reviewId,
          db.preOrderReviews.id,
        ),
      );

  $$PreOrderReviewsTableProcessedTableManager get reviewId {
    final $_column = $_itemColumn<String>('review_id')!;

    final manager = $$PreOrderReviewsTableTableManager(
      $_db,
      $_db.preOrderReviews,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_reviewIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PreOrderReviewItemsTableFilterComposer
    extends Composer<_$LocalDatabase, $PreOrderReviewItemsTable> {
  $$PreOrderReviewItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get matchedProductId => $composableBuilder(
    column: $table.matchedProductId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productCode => $composableBuilder(
    column: $table.productCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get supplierName => $composableBuilder(
    column: $table.supplierName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get piecesPerBox => $composableBuilder(
    column: $table.piecesPerBox,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get requestedPieces => $composableBuilder(
    column: $table.requestedPieces,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get availablePieces => $composableBuilder(
    column: $table.availablePieces,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get confirmedPieces => $composableBuilder(
    column: $table.confirmedPieces,
    builder: (column) => ColumnFilters(column),
  );

  $$PreOrderReviewsTableFilterComposer get reviewId {
    final $$PreOrderReviewsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.reviewId,
      referencedTable: $db.preOrderReviews,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PreOrderReviewsTableFilterComposer(
            $db: $db,
            $table: $db.preOrderReviews,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PreOrderReviewItemsTableOrderingComposer
    extends Composer<_$LocalDatabase, $PreOrderReviewItemsTable> {
  $$PreOrderReviewItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get matchedProductId => $composableBuilder(
    column: $table.matchedProductId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productCode => $composableBuilder(
    column: $table.productCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get supplierName => $composableBuilder(
    column: $table.supplierName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get piecesPerBox => $composableBuilder(
    column: $table.piecesPerBox,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get requestedPieces => $composableBuilder(
    column: $table.requestedPieces,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get availablePieces => $composableBuilder(
    column: $table.availablePieces,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get confirmedPieces => $composableBuilder(
    column: $table.confirmedPieces,
    builder: (column) => ColumnOrderings(column),
  );

  $$PreOrderReviewsTableOrderingComposer get reviewId {
    final $$PreOrderReviewsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.reviewId,
      referencedTable: $db.preOrderReviews,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PreOrderReviewsTableOrderingComposer(
            $db: $db,
            $table: $db.preOrderReviews,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PreOrderReviewItemsTableAnnotationComposer
    extends Composer<_$LocalDatabase, $PreOrderReviewItemsTable> {
  $$PreOrderReviewItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<String> get matchedProductId => $composableBuilder(
    column: $table.matchedProductId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get productCode => $composableBuilder(
    column: $table.productCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get supplierName => $composableBuilder(
    column: $table.supplierName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get piecesPerBox => $composableBuilder(
    column: $table.piecesPerBox,
    builder: (column) => column,
  );

  GeneratedColumn<int> get requestedPieces => $composableBuilder(
    column: $table.requestedPieces,
    builder: (column) => column,
  );

  GeneratedColumn<int> get availablePieces => $composableBuilder(
    column: $table.availablePieces,
    builder: (column) => column,
  );

  GeneratedColumn<int> get confirmedPieces => $composableBuilder(
    column: $table.confirmedPieces,
    builder: (column) => column,
  );

  $$PreOrderReviewsTableAnnotationComposer get reviewId {
    final $$PreOrderReviewsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.reviewId,
      referencedTable: $db.preOrderReviews,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PreOrderReviewsTableAnnotationComposer(
            $db: $db,
            $table: $db.preOrderReviews,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PreOrderReviewItemsTableTableManager
    extends
        RootTableManager<
          _$LocalDatabase,
          $PreOrderReviewItemsTable,
          PreOrderReviewItem,
          $$PreOrderReviewItemsTableFilterComposer,
          $$PreOrderReviewItemsTableOrderingComposer,
          $$PreOrderReviewItemsTableAnnotationComposer,
          $$PreOrderReviewItemsTableCreateCompanionBuilder,
          $$PreOrderReviewItemsTableUpdateCompanionBuilder,
          (PreOrderReviewItem, $$PreOrderReviewItemsTableReferences),
          PreOrderReviewItem,
          PrefetchHooks Function({bool reviewId})
        > {
  $$PreOrderReviewItemsTableTableManager(
    _$LocalDatabase db,
    $PreOrderReviewItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PreOrderReviewItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PreOrderReviewItemsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PreOrderReviewItemsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> reviewId = const Value.absent(),
                Value<String?> productId = const Value.absent(),
                Value<String?> matchedProductId = const Value.absent(),
                Value<String> productName = const Value.absent(),
                Value<String?> productCode = const Value.absent(),
                Value<String> supplierName = const Value.absent(),
                Value<int> piecesPerBox = const Value.absent(),
                Value<int> requestedPieces = const Value.absent(),
                Value<int> availablePieces = const Value.absent(),
                Value<int> confirmedPieces = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PreOrderReviewItemsCompanion(
                id: id,
                reviewId: reviewId,
                productId: productId,
                matchedProductId: matchedProductId,
                productName: productName,
                productCode: productCode,
                supplierName: supplierName,
                piecesPerBox: piecesPerBox,
                requestedPieces: requestedPieces,
                availablePieces: availablePieces,
                confirmedPieces: confirmedPieces,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String reviewId,
                Value<String?> productId = const Value.absent(),
                Value<String?> matchedProductId = const Value.absent(),
                required String productName,
                Value<String?> productCode = const Value.absent(),
                required String supplierName,
                required int piecesPerBox,
                required int requestedPieces,
                Value<int> availablePieces = const Value.absent(),
                required int confirmedPieces,
                Value<int> rowid = const Value.absent(),
              }) => PreOrderReviewItemsCompanion.insert(
                id: id,
                reviewId: reviewId,
                productId: productId,
                matchedProductId: matchedProductId,
                productName: productName,
                productCode: productCode,
                supplierName: supplierName,
                piecesPerBox: piecesPerBox,
                requestedPieces: requestedPieces,
                availablePieces: availablePieces,
                confirmedPieces: confirmedPieces,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PreOrderReviewItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({reviewId = false}) {
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
                    if (reviewId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.reviewId,
                                referencedTable:
                                    $$PreOrderReviewItemsTableReferences
                                        ._reviewIdTable(db),
                                referencedColumn:
                                    $$PreOrderReviewItemsTableReferences
                                        ._reviewIdTable(db)
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

typedef $$PreOrderReviewItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDatabase,
      $PreOrderReviewItemsTable,
      PreOrderReviewItem,
      $$PreOrderReviewItemsTableFilterComposer,
      $$PreOrderReviewItemsTableOrderingComposer,
      $$PreOrderReviewItemsTableAnnotationComposer,
      $$PreOrderReviewItemsTableCreateCompanionBuilder,
      $$PreOrderReviewItemsTableUpdateCompanionBuilder,
      (PreOrderReviewItem, $$PreOrderReviewItemsTableReferences),
      PreOrderReviewItem,
      PrefetchHooks Function({bool reviewId})
    >;
typedef $$StocksLoadingsTableCreateCompanionBuilder =
    StocksLoadingsCompanion Function({
      required String id,
      required DateTime loadingDate,
      Value<DateTime> importedAt,
      Value<int> rowid,
    });
typedef $$StocksLoadingsTableUpdateCompanionBuilder =
    StocksLoadingsCompanion Function({
      Value<String> id,
      Value<DateTime> loadingDate,
      Value<DateTime> importedAt,
      Value<int> rowid,
    });

final class $$StocksLoadingsTableReferences
    extends
        BaseReferences<_$LocalDatabase, $StocksLoadingsTable, StocksLoading> {
  $$StocksLoadingsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$StocksLoadingItemsTable, List<StocksLoadingItem>>
  _stocksLoadingItemsRefsTable(_$LocalDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.stocksLoadingItems,
        aliasName: $_aliasNameGenerator(
          db.stocksLoadings.id,
          db.stocksLoadingItems.stocksLoadingId,
        ),
      );

  $$StocksLoadingItemsTableProcessedTableManager get stocksLoadingItemsRefs {
    final manager =
        $$StocksLoadingItemsTableTableManager(
          $_db,
          $_db.stocksLoadingItems,
        ).filter(
          (f) => f.stocksLoadingId.id.sqlEquals($_itemColumn<String>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _stocksLoadingItemsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$StocksLoadingsTableFilterComposer
    extends Composer<_$LocalDatabase, $StocksLoadingsTable> {
  $$StocksLoadingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get loadingDate => $composableBuilder(
    column: $table.loadingDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> stocksLoadingItemsRefs(
    Expression<bool> Function($$StocksLoadingItemsTableFilterComposer f) f,
  ) {
    final $$StocksLoadingItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.stocksLoadingItems,
      getReferencedColumn: (t) => t.stocksLoadingId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StocksLoadingItemsTableFilterComposer(
            $db: $db,
            $table: $db.stocksLoadingItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$StocksLoadingsTableOrderingComposer
    extends Composer<_$LocalDatabase, $StocksLoadingsTable> {
  $$StocksLoadingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get loadingDate => $composableBuilder(
    column: $table.loadingDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StocksLoadingsTableAnnotationComposer
    extends Composer<_$LocalDatabase, $StocksLoadingsTable> {
  $$StocksLoadingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get loadingDate => $composableBuilder(
    column: $table.loadingDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => column,
  );

  Expression<T> stocksLoadingItemsRefs<T extends Object>(
    Expression<T> Function($$StocksLoadingItemsTableAnnotationComposer a) f,
  ) {
    final $$StocksLoadingItemsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.stocksLoadingItems,
          getReferencedColumn: (t) => t.stocksLoadingId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$StocksLoadingItemsTableAnnotationComposer(
                $db: $db,
                $table: $db.stocksLoadingItems,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$StocksLoadingsTableTableManager
    extends
        RootTableManager<
          _$LocalDatabase,
          $StocksLoadingsTable,
          StocksLoading,
          $$StocksLoadingsTableFilterComposer,
          $$StocksLoadingsTableOrderingComposer,
          $$StocksLoadingsTableAnnotationComposer,
          $$StocksLoadingsTableCreateCompanionBuilder,
          $$StocksLoadingsTableUpdateCompanionBuilder,
          (StocksLoading, $$StocksLoadingsTableReferences),
          StocksLoading,
          PrefetchHooks Function({bool stocksLoadingItemsRefs})
        > {
  $$StocksLoadingsTableTableManager(
    _$LocalDatabase db,
    $StocksLoadingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StocksLoadingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StocksLoadingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StocksLoadingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> loadingDate = const Value.absent(),
                Value<DateTime> importedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StocksLoadingsCompanion(
                id: id,
                loadingDate: loadingDate,
                importedAt: importedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime loadingDate,
                Value<DateTime> importedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StocksLoadingsCompanion.insert(
                id: id,
                loadingDate: loadingDate,
                importedAt: importedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$StocksLoadingsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({stocksLoadingItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (stocksLoadingItemsRefs) db.stocksLoadingItems,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (stocksLoadingItemsRefs)
                    await $_getPrefetchedData<
                      StocksLoading,
                      $StocksLoadingsTable,
                      StocksLoadingItem
                    >(
                      currentTable: table,
                      referencedTable: $$StocksLoadingsTableReferences
                          ._stocksLoadingItemsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$StocksLoadingsTableReferences(
                            db,
                            table,
                            p0,
                          ).stocksLoadingItemsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.stocksLoadingId == item.id,
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

typedef $$StocksLoadingsTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDatabase,
      $StocksLoadingsTable,
      StocksLoading,
      $$StocksLoadingsTableFilterComposer,
      $$StocksLoadingsTableOrderingComposer,
      $$StocksLoadingsTableAnnotationComposer,
      $$StocksLoadingsTableCreateCompanionBuilder,
      $$StocksLoadingsTableUpdateCompanionBuilder,
      (StocksLoading, $$StocksLoadingsTableReferences),
      StocksLoading,
      PrefetchHooks Function({bool stocksLoadingItemsRefs})
    >;
typedef $$StocksLoadingItemsTableCreateCompanionBuilder =
    StocksLoadingItemsCompanion Function({
      required String id,
      required String stocksLoadingId,
      Value<String?> productCode,
      required String productName,
      required String supplierName,
      required int quantityPieces,
      Value<int> piecesPerBox,
      Value<int> rowid,
    });
typedef $$StocksLoadingItemsTableUpdateCompanionBuilder =
    StocksLoadingItemsCompanion Function({
      Value<String> id,
      Value<String> stocksLoadingId,
      Value<String?> productCode,
      Value<String> productName,
      Value<String> supplierName,
      Value<int> quantityPieces,
      Value<int> piecesPerBox,
      Value<int> rowid,
    });

final class $$StocksLoadingItemsTableReferences
    extends
        BaseReferences<
          _$LocalDatabase,
          $StocksLoadingItemsTable,
          StocksLoadingItem
        > {
  $$StocksLoadingItemsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $StocksLoadingsTable _stocksLoadingIdTable(_$LocalDatabase db) =>
      db.stocksLoadings.createAlias(
        $_aliasNameGenerator(
          db.stocksLoadingItems.stocksLoadingId,
          db.stocksLoadings.id,
        ),
      );

  $$StocksLoadingsTableProcessedTableManager get stocksLoadingId {
    final $_column = $_itemColumn<String>('stocks_loading_id')!;

    final manager = $$StocksLoadingsTableTableManager(
      $_db,
      $_db.stocksLoadings,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_stocksLoadingIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$StocksLoadingItemsTableFilterComposer
    extends Composer<_$LocalDatabase, $StocksLoadingItemsTable> {
  $$StocksLoadingItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productCode => $composableBuilder(
    column: $table.productCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get supplierName => $composableBuilder(
    column: $table.supplierName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantityPieces => $composableBuilder(
    column: $table.quantityPieces,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get piecesPerBox => $composableBuilder(
    column: $table.piecesPerBox,
    builder: (column) => ColumnFilters(column),
  );

  $$StocksLoadingsTableFilterComposer get stocksLoadingId {
    final $$StocksLoadingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.stocksLoadingId,
      referencedTable: $db.stocksLoadings,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StocksLoadingsTableFilterComposer(
            $db: $db,
            $table: $db.stocksLoadings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StocksLoadingItemsTableOrderingComposer
    extends Composer<_$LocalDatabase, $StocksLoadingItemsTable> {
  $$StocksLoadingItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productCode => $composableBuilder(
    column: $table.productCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get supplierName => $composableBuilder(
    column: $table.supplierName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantityPieces => $composableBuilder(
    column: $table.quantityPieces,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get piecesPerBox => $composableBuilder(
    column: $table.piecesPerBox,
    builder: (column) => ColumnOrderings(column),
  );

  $$StocksLoadingsTableOrderingComposer get stocksLoadingId {
    final $$StocksLoadingsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.stocksLoadingId,
      referencedTable: $db.stocksLoadings,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StocksLoadingsTableOrderingComposer(
            $db: $db,
            $table: $db.stocksLoadings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StocksLoadingItemsTableAnnotationComposer
    extends Composer<_$LocalDatabase, $StocksLoadingItemsTable> {
  $$StocksLoadingItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get productCode => $composableBuilder(
    column: $table.productCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get supplierName => $composableBuilder(
    column: $table.supplierName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get quantityPieces => $composableBuilder(
    column: $table.quantityPieces,
    builder: (column) => column,
  );

  GeneratedColumn<int> get piecesPerBox => $composableBuilder(
    column: $table.piecesPerBox,
    builder: (column) => column,
  );

  $$StocksLoadingsTableAnnotationComposer get stocksLoadingId {
    final $$StocksLoadingsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.stocksLoadingId,
      referencedTable: $db.stocksLoadings,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StocksLoadingsTableAnnotationComposer(
            $db: $db,
            $table: $db.stocksLoadings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StocksLoadingItemsTableTableManager
    extends
        RootTableManager<
          _$LocalDatabase,
          $StocksLoadingItemsTable,
          StocksLoadingItem,
          $$StocksLoadingItemsTableFilterComposer,
          $$StocksLoadingItemsTableOrderingComposer,
          $$StocksLoadingItemsTableAnnotationComposer,
          $$StocksLoadingItemsTableCreateCompanionBuilder,
          $$StocksLoadingItemsTableUpdateCompanionBuilder,
          (StocksLoadingItem, $$StocksLoadingItemsTableReferences),
          StocksLoadingItem,
          PrefetchHooks Function({bool stocksLoadingId})
        > {
  $$StocksLoadingItemsTableTableManager(
    _$LocalDatabase db,
    $StocksLoadingItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StocksLoadingItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StocksLoadingItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StocksLoadingItemsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> stocksLoadingId = const Value.absent(),
                Value<String?> productCode = const Value.absent(),
                Value<String> productName = const Value.absent(),
                Value<String> supplierName = const Value.absent(),
                Value<int> quantityPieces = const Value.absent(),
                Value<int> piecesPerBox = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StocksLoadingItemsCompanion(
                id: id,
                stocksLoadingId: stocksLoadingId,
                productCode: productCode,
                productName: productName,
                supplierName: supplierName,
                quantityPieces: quantityPieces,
                piecesPerBox: piecesPerBox,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String stocksLoadingId,
                Value<String?> productCode = const Value.absent(),
                required String productName,
                required String supplierName,
                required int quantityPieces,
                Value<int> piecesPerBox = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StocksLoadingItemsCompanion.insert(
                id: id,
                stocksLoadingId: stocksLoadingId,
                productCode: productCode,
                productName: productName,
                supplierName: supplierName,
                quantityPieces: quantityPieces,
                piecesPerBox: piecesPerBox,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$StocksLoadingItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({stocksLoadingId = false}) {
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
                    if (stocksLoadingId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.stocksLoadingId,
                                referencedTable:
                                    $$StocksLoadingItemsTableReferences
                                        ._stocksLoadingIdTable(db),
                                referencedColumn:
                                    $$StocksLoadingItemsTableReferences
                                        ._stocksLoadingIdTable(db)
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

typedef $$StocksLoadingItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDatabase,
      $StocksLoadingItemsTable,
      StocksLoadingItem,
      $$StocksLoadingItemsTableFilterComposer,
      $$StocksLoadingItemsTableOrderingComposer,
      $$StocksLoadingItemsTableAnnotationComposer,
      $$StocksLoadingItemsTableCreateCompanionBuilder,
      $$StocksLoadingItemsTableUpdateCompanionBuilder,
      (StocksLoadingItem, $$StocksLoadingItemsTableReferences),
      StocksLoadingItem,
      PrefetchHooks Function({bool stocksLoadingId})
    >;
typedef $$SyncQueueTableCreateCompanionBuilder =
    SyncQueueCompanion Function({
      required String id,
      required String targetTable,
      required String recordId,
      required String operation,
      required String payload,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$SyncQueueTableUpdateCompanionBuilder =
    SyncQueueCompanion Function({
      Value<String> id,
      Value<String> targetTable,
      Value<String> recordId,
      Value<String> operation,
      Value<String> payload,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$SyncQueueTableFilterComposer
    extends Composer<_$LocalDatabase, $SyncQueueTable> {
  $$SyncQueueTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetTable => $composableBuilder(
    column: $table.targetTable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recordId => $composableBuilder(
    column: $table.recordId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncQueueTableOrderingComposer
    extends Composer<_$LocalDatabase, $SyncQueueTable> {
  $$SyncQueueTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetTable => $composableBuilder(
    column: $table.targetTable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recordId => $composableBuilder(
    column: $table.recordId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncQueueTableAnnotationComposer
    extends Composer<_$LocalDatabase, $SyncQueueTable> {
  $$SyncQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get targetTable => $composableBuilder(
    column: $table.targetTable,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recordId =>
      $composableBuilder(column: $table.recordId, builder: (column) => column);

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SyncQueueTableTableManager
    extends
        RootTableManager<
          _$LocalDatabase,
          $SyncQueueTable,
          SyncQueueData,
          $$SyncQueueTableFilterComposer,
          $$SyncQueueTableOrderingComposer,
          $$SyncQueueTableAnnotationComposer,
          $$SyncQueueTableCreateCompanionBuilder,
          $$SyncQueueTableUpdateCompanionBuilder,
          (
            SyncQueueData,
            BaseReferences<_$LocalDatabase, $SyncQueueTable, SyncQueueData>,
          ),
          SyncQueueData,
          PrefetchHooks Function()
        > {
  $$SyncQueueTableTableManager(_$LocalDatabase db, $SyncQueueTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncQueueTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncQueueTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> targetTable = const Value.absent(),
                Value<String> recordId = const Value.absent(),
                Value<String> operation = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncQueueCompanion(
                id: id,
                targetTable: targetTable,
                recordId: recordId,
                operation: operation,
                payload: payload,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String targetTable,
                required String recordId,
                required String operation,
                required String payload,
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncQueueCompanion.insert(
                id: id,
                targetTable: targetTable,
                recordId: recordId,
                operation: operation,
                payload: payload,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncQueueTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDatabase,
      $SyncQueueTable,
      SyncQueueData,
      $$SyncQueueTableFilterComposer,
      $$SyncQueueTableOrderingComposer,
      $$SyncQueueTableAnnotationComposer,
      $$SyncQueueTableCreateCompanionBuilder,
      $$SyncQueueTableUpdateCompanionBuilder,
      (
        SyncQueueData,
        BaseReferences<_$LocalDatabase, $SyncQueueTable, SyncQueueData>,
      ),
      SyncQueueData,
      PrefetchHooks Function()
    >;

class $LocalDatabaseManager {
  final _$LocalDatabase _db;
  $LocalDatabaseManager(this._db);
  $$SuppliersTableTableManager get suppliers =>
      $$SuppliersTableTableManager(_db, _db.suppliers);
  $$ClientsTableTableManager get clients =>
      $$ClientsTableTableManager(_db, _db.clients);
  $$ProductsTableTableManager get products =>
      $$ProductsTableTableManager(_db, _db.products);
  $$ProductPricesTableTableManager get productPrices =>
      $$ProductPricesTableTableManager(_db, _db.productPrices);
  $$ProductDiscountsTableTableManager get productDiscounts =>
      $$ProductDiscountsTableTableManager(_db, _db.productDiscounts);
  $$ProductSupplierPricesTableTableManager get productSupplierPrices =>
      $$ProductSupplierPricesTableTableManager(_db, _db.productSupplierPrices);
  $$InventoryTableTableManager get inventory =>
      $$InventoryTableTableManager(_db, _db.inventory);
  $$InvoicesTableTableManager get invoices =>
      $$InvoicesTableTableManager(_db, _db.invoices);
  $$InvoiceItemsTableTableManager get invoiceItems =>
      $$InvoiceItemsTableTableManager(_db, _db.invoiceItems);
  $$DeletedInvoiceItemsTableTableManager get deletedInvoiceItems =>
      $$DeletedInvoiceItemsTableTableManager(_db, _db.deletedInvoiceItems);
  $$BadOrdersTableTableManager get badOrders =>
      $$BadOrdersTableTableManager(_db, _db.badOrders);
  $$BadOrderItemsTableTableManager get badOrderItems =>
      $$BadOrderItemsTableTableManager(_db, _db.badOrderItems);
  $$VanAreasTableTableManager get vanAreas =>
      $$VanAreasTableTableManager(_db, _db.vanAreas);
  $$VanStocksTableTableManager get vanStocks =>
      $$VanStocksTableTableManager(_db, _db.vanStocks);
  $$VanStockDraftsTableTableManager get vanStockDrafts =>
      $$VanStockDraftsTableTableManager(_db, _db.vanStockDrafts);
  $$BadOrderDraftsTableTableManager get badOrderDrafts =>
      $$BadOrderDraftsTableTableManager(_db, _db.badOrderDrafts);
  $$StockMovementsTableTableManager get stockMovements =>
      $$StockMovementsTableTableManager(_db, _db.stockMovements);
  $$InvoicePaymentsTableTableManager get invoicePayments =>
      $$InvoicePaymentsTableTableManager(_db, _db.invoicePayments);
  $$SupplierReceivedInvoicesTableTableManager get supplierReceivedInvoices =>
      $$SupplierReceivedInvoicesTableTableManager(
        _db,
        _db.supplierReceivedInvoices,
      );
  $$SupplierReceivedInvoiceItemsTableTableManager
  get supplierReceivedInvoiceItems =>
      $$SupplierReceivedInvoiceItemsTableTableManager(
        _db,
        _db.supplierReceivedInvoiceItems,
      );
  $$PurchaseOrdersTableTableManager get purchaseOrders =>
      $$PurchaseOrdersTableTableManager(_db, _db.purchaseOrders);
  $$PurchaseOrderItemsTableTableManager get purchaseOrderItems =>
      $$PurchaseOrderItemsTableTableManager(_db, _db.purchaseOrderItems);
  $$PreOrderReviewsTableTableManager get preOrderReviews =>
      $$PreOrderReviewsTableTableManager(_db, _db.preOrderReviews);
  $$PreOrderReviewItemsTableTableManager get preOrderReviewItems =>
      $$PreOrderReviewItemsTableTableManager(_db, _db.preOrderReviewItems);
  $$StocksLoadingsTableTableManager get stocksLoadings =>
      $$StocksLoadingsTableTableManager(_db, _db.stocksLoadings);
  $$StocksLoadingItemsTableTableManager get stocksLoadingItems =>
      $$StocksLoadingItemsTableTableManager(_db, _db.stocksLoadingItems);
  $$SyncQueueTableTableManager get syncQueue =>
      $$SyncQueueTableTableManager(_db, _db.syncQueue);
}
