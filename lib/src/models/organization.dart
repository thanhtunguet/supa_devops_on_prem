import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';

class GetOrganizationsResponse {
  GetOrganizationsResponse({
    required this.count,
    required this.organizations,
  });

  factory GetOrganizationsResponse.fromJson(Map<String, dynamic> json) {
    return GetOrganizationsResponse(
      count: json['count'] as int,
      organizations: List<Organization>.from(
        (json['value'] as List<dynamic>).map((dynamic json) {
          if (json is Map<String, dynamic>) {
            return Organization.fromJson(json);
          }
          return Organization(
            accountId: 'DefaultCollection',
            accountUri: 'DefaultCollection',
            accountName: 'DefaultCollection',
            properties: {},
          );
        }),
      ),
    );
  }

  static List<Organization> fromResponse(Response res) =>
      GetOrganizationsResponse.fromJson(
        jsonDecode(res.body) as Map<String, dynamic>,
      ).organizations ??
      [];

  final int? count;
  final List<Organization>? organizations;
}

class Organization {
  Organization({
    required this.accountId,
    required this.accountUri,
    required this.accountName,
    required this.properties,
  });

  factory Organization.fromJson(Map<String, dynamic> json) => Organization(
        accountId: json['id'] as String?,
        accountUri: json['url'] as String?,
        accountName: json['name'] as String?,
        properties: {
          'avatarUrl': json['avatarUrl'] as String?,
        },
      );

  final String? accountId;
  final String? accountUri;
  final String? accountName;
  final Map<String, dynamic>? properties;

  @override
  String toString() {
    return 'Organization(accountId: $accountId, accountUri: $accountUri, accountName: $accountName, properties: $properties)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Organization &&
        other.accountId == accountId &&
        other.accountUri == accountUri &&
        other.accountName == accountName &&
        mapEquals(other.properties, properties);
  }

  @override
  int get hashCode {
    return accountId.hashCode ^
        accountUri.hashCode ^
        accountName.hashCode ^
        properties.hashCode;
  }
}
