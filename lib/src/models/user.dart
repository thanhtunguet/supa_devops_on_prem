import 'dart:convert';

import 'package:azure_devops/src/models/shared.dart';
import 'package:http/http.dart';

class GetUsersResponse {
  GetUsersResponse({
    required this.count,
    required this.users,
  });

  factory GetUsersResponse.fromJson(Map<String, dynamic> json) =>
      GetUsersResponse(
        count: json['count'] as int?,
        users: json['value'] == null
            ? []
            : List<GraphUser>.from(
                (json['value'] as List<dynamic>)
                    .map((x) => GraphUser.fromJson(x as Map<String, dynamic>)),
              ),
      );

  static List<GraphUser> fromResponse(Response res) =>
      GetUsersResponse.fromJson(jsonDecode(res.body) as Map<String, dynamic>)
          .users ??
      [];

  final int? count;
  final List<GraphUser>? users;
}

class GraphUser {
  GraphUser({
    this.subjectKind,
    this.domain,
    this.principalName,
    this.mailAddress,
    this.origin,
    this.originId,
    this.displayName,
    this.links,
    this.url,
    this.descriptor,
    this.metaType,
    this.directoryAlias,
  });

  factory GraphUser.all() => GraphUser(displayName: 'All', mailAddress: 'all');

  factory GraphUser.fromJson(Map<String, dynamic> json) => GraphUser(
        subjectKind: json['subjectKind'] as String?,
        domain: json['domain'] as String?,
        principalName: json['principalName'] as String?,
        mailAddress: json['mailAddress'] as String?,
        origin: json['origin'] as String?,
        originId: json['originId'] as String?,
        displayName: json['displayName'] as String?,
        links: json['Links'] == null
            ? null
            : Links.fromJson(json['Links'] as Map<String, dynamic>),
        url: json['url'] as String?,
        descriptor: json['descriptor'] as String?,
        metaType: json['metaType'] as String?,
        directoryAlias: json['directoryAlias'] as String?,
      );

  factory GraphUser.fromApiJson(Map<String, dynamic> json) => GraphUser(
        domain: json['Domain'] as String?,
        mailAddress: json['MailAddress'] as String?,
        displayName: json['DisplayName'] as String?,
        descriptor: json['EntityId'] as String?,
        metaType: json['IdentityType'] as String?,
        principalName: json['AccountName'] as String?,
        directoryAlias: json['SubHeader'] as String?,
        originId: json['TeamFoundationId'] as String?,
        url:
            'https://devops.supa.vn:7443/DefaultCollection/7bead6c8-1e52-459c-bb95-a8345a729ee0/_api/_common/GetDdsAvatar?id=${json['EntityId']}&__v=5',
      );

  final String? subjectKind;
  final String? domain;
  final String? principalName;
  final String? mailAddress;
  final String? origin;
  final String? originId;
  final String? displayName;
  final Links? links;
  final String? url;
  final String? descriptor;
  final String? metaType;
  final String? directoryAlias;

  @override
  String toString() {
    return 'User(subjectKind: $subjectKind, domain: $domain, principalName: $principalName, mailAddress: $mailAddress, origin: $origin, originId: $originId, displayName: $displayName, links: $links, url: $url, descriptor: $descriptor, metaType: $metaType, directoryAlias: $directoryAlias)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is GraphUser && other.mailAddress == mailAddress;
  }

  @override
  int get hashCode {
    return mailAddress.hashCode;
  }

  GraphUser copyWith({String? displayName, String? mailAddress}) {
    return GraphUser(
      subjectKind: subjectKind,
      domain: domain,
      principalName: principalName,
      mailAddress: mailAddress ?? this.mailAddress,
      origin: origin,
      originId: originId,
      displayName: displayName ?? this.displayName,
      links: links,
      url: url,
      descriptor: descriptor,
      metaType: metaType,
      directoryAlias: directoryAlias,
    );
  }
}

class UserMe {
  UserMe({
    required this.displayName,
    required this.publicAlias,
    required this.emailAddress,
    required this.coreRevision,
    required this.timeStamp,
    required this.id,
    required this.revision,
    required this.userPreferences,
  });

  factory UserMe.fromJson(Map<String, dynamic> json) => UserMe(
        displayName: json['identity']['DisplayName'] as String?,
        publicAlias: json['identity']['AccountName'] as String?,
        emailAddress: json['identity']['AccountName'] as String,
        coreRevision: json['coreRevision'] as int?,
        timeStamp: json['timeStamp'] == null
            ? null
            : DateTime.parse(json['timeStamp'].toString()).toLocal(),
        id: json['id'] as String?,
        revision: json['revision'] as int?,
        userPreferences: json['userPreferences'] != null
            ? UserPreferences.fromJson(
                json['userPreferences'] as Map<String, dynamic>,
              )
            : null,
      );

  final String? displayName;
  final String? publicAlias;
  final String? emailAddress;
  final int? coreRevision;
  final DateTime? timeStamp;
  final String? id;
  final int? revision;
  final UserPreferences? userPreferences;

  @override
  String toString() {
    return 'MiniUser(displayName: $displayName, publicAlias: $publicAlias, emailAddress: $emailAddress, coreRevision: $coreRevision, timeStamp: $timeStamp, id: $id, revision: $revision)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserMe &&
        other.displayName == displayName &&
        other.publicAlias == publicAlias &&
        other.emailAddress == emailAddress &&
        other.coreRevision == coreRevision &&
        other.timeStamp == timeStamp &&
        other.id == id &&
        other.revision == revision;
  }

  @override
  int get hashCode {
    return displayName.hashCode ^
        publicAlias.hashCode ^
        emailAddress.hashCode ^
        coreRevision.hashCode ^
        timeStamp.hashCode ^
        id.hashCode ^
        revision.hashCode;
  }
}

class UserIdentity {
  UserIdentity({required this.id});

  factory UserIdentity.fromResponse(Response res) {
    final json = jsonDecode(res.body) as Map<String, dynamic>?;
    return UserIdentity(
      id: (json?['value'] as List<dynamic>?)?.firstOrNull?['id']?.toString(),
    );
  }

  final String? id;
}

class UserPreferences {
  UserPreferences({
    this.customDisplayName,
    this.preferredEmail,
    this.isEmailConfirmationPending,
    this.theme,
    this.typeAheadDisabled,
    this.resetEmail,
    this.resetDisplayName,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      customDisplayName: json['CustomDisplayName'] as String?,
      preferredEmail: json['PreferredEmail'] as String?,
      isEmailConfirmationPending: json['IsEmailConfirmationPending'] as bool?,
      theme: json['Theme'] as String?,
      typeAheadDisabled: json['TypeAheadDisabled'] as bool?,
      resetEmail: json['ResetEmail'] as bool?,
      resetDisplayName: json['ResetDisplayName'] as bool?,
    );
  }
  final String? customDisplayName;
  final String? preferredEmail;
  final bool? isEmailConfirmationPending;
  final String? theme;
  final bool? typeAheadDisabled;
  final bool? resetEmail;
  final bool? resetDisplayName;
}
