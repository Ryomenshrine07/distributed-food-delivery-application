import 'package:freezed_annotation/freezed_annotation.dart';

part 'partner_session.freezed.dart';

@freezed
abstract class PartnerSession with _$PartnerSession {
  const factory PartnerSession({
    required String partnerId,
    required String email,
    required String role,
    required String name,
    required String phone,
    required DateTime exp,
  }) = _PartnerSession;
  
  const PartnerSession._();
  
  bool get isExpired => DateTime.now().isAfter(exp);
}
