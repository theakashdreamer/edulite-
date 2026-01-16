import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../../data/draft_database.dart';

class MailDraft {
  final int? id;
  final String from;
  final String to;
  final String subject;
  final List<dynamic> delta;
  final DateTime updatedAt;

  MailDraft({
    this.id,
    required this.from,
    required this.to,
    required this.subject,
    required this.delta,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'from_email': from,
      'to_email': to,
      'subject': subject,
      'delta': delta.toString(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory MailDraft.fromMap(Map<String, dynamic> map) {
    return MailDraft(
      id: map['id'],
      from: map['from_email'],
      to: map['to_email'],
      subject: map['subject'],
      delta: _parseDelta(map['delta']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  static List<dynamic> _parseDelta(String raw) {
    return List<dynamic>.from(
      raw
          .replaceAll('[', '')
          .replaceAll(']', '')
          .split('},')
          .map((e) => e.endsWith('}') ? e : '$e}'),
    );
  }
}
class DraftRepository {
  /// Save or update draft
  static Future<void> saveDraft(MailDraft draft) async {
    final db = await DraftDatabase.database;

    await db.insert(
      'drafts',
      {
        ...draft.toMap(),
        'delta': jsonEncode(draft.delta),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Load latest draft
  static Future<MailDraft?> loadDraft() async {
    final db = await DraftDatabase.database;

    final result = await db.query(
      'drafts',
      orderBy: 'updated_at DESC',
      limit: 1,
    );

    if (result.isEmpty) return null;

    final map = result.first;
    return MailDraft(
      id: map['id'] as int,
      from: map['from_email'] as String,
      to: map['to_email'] as String,
      subject: map['subject'] as String,
      delta: jsonDecode(map['delta'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  /// Delete draft after send
  static Future<void> clearDraft() async {
    final db = await DraftDatabase.database;
    await db.delete('drafts');
  }
}
