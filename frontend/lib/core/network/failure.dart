import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';

import '../../l10n/app_localizations.dart';

/// The one error type the UI deals with. The backend sends stable error codes
/// (`{"detail": "...", "code": "unit_label_taken"}`); we map the *code* to a
/// localized message, never the English `detail`.
class Failure implements Exception {
  const Failure({this.code, this.statusCode, this.offline = false});

  final String? code;
  final int? statusCode;

  /// No response at all: no connectivity, timeout, DNS, etc.
  final bool offline;

  factory Failure.from(Object error) {
    if (error is Failure) return error;
    if (error is DioException) {
      final data = error.response?.data;
      final status = error.response?.statusCode;
      final code = data is Map && data['code'] is String
          ? data['code'] as String
          : (status == 422 ? 'validation_error' : null);
      return Failure(
        code: code,
        statusCode: status,
        offline: error.response == null,
      );
    }
    return const Failure();
  }

  @override
  String toString() => 'Failure(code: $code, status: $statusCode)';
}

/// Runs an API call and converts any transport/HTTP error into a [Failure].
Future<T> guardApi<T>(Future<T> Function() call) async {
  try {
    return await call();
  } on DioException catch (e) {
    throw Failure.from(e);
  }
}

/// Localized, user-facing message for any error.
String failureText(BuildContext context, Object error) {
  final l10n = AppLocalizations.of(context)!;
  final failure = Failure.from(error);
  if (failure.offline) return l10n.errNetwork;
  return switch (failure.code) {
    'invalid_credentials' => l10n.errInvalidCredentials,
    'email_taken' => l10n.errEmailTaken,
    'invalid_token' => l10n.errSessionExpired,
    'validation_error' => l10n.errValidation,
    'property_not_found' => l10n.errPropertyNotFound,
    'access_denied' => l10n.errAccessDenied,
    'property_inactive' => l10n.errPropertyInactive,
    'manager_not_found' => l10n.errManagerNotFound,
    'already_has_access' => l10n.errAlreadyHasAccess,
    'last_owner' => l10n.errLastOwner,
    'unit_type_not_found' => l10n.errUnitTypeNotFound,
    'unit_not_found' => l10n.errUnitNotFound,
    'unit_type_name_taken' => l10n.errUnitTypeNameTaken,
    'unit_label_taken' => l10n.errUnitLabelTaken,
    'tenant_not_found' => l10n.errTenantNotFound,
    'tenant_phone_taken' => l10n.errTenantPhoneTaken,
    'lease_not_found' => l10n.errLeaseNotFound,
    'lease_already_terminated' => l10n.errLeaseAlreadyTerminated,
    'unit_already_leased' => l10n.errUnitAlreadyLeased,
    _ => l10n.errGeneric,
  };
}
