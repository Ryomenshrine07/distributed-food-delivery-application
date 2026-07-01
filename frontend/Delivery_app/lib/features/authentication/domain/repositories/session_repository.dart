import 'dart:async';
import '../entities/partner_session.dart';

abstract class SessionRepository {
  Stream<PartnerSession?> get sessionChanges;
  PartnerSession? get currentSession;
  
  Future<void> saveSession(String token);
  Future<void> clearSession();
}
