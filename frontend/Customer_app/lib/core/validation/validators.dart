/// Pure, side-effect-free input validators for the authentication forms.
///
/// These functions back the field-level validation messages (Req 1.3) and the
/// registration and login submit gates (Property 2). They perform no I/O and
/// hold no state, which keeps them trivially testable across many inputs.
///
/// Validation rules:
/// * Email     - must be well-formed (see [_emailPattern]).
/// * Password  - length 8-25 for registration, 8-15 for login.
/// * Full name - must be non-blank (not empty and not whitespace-only).
/// * Phone     - must match the Indian mobile pattern `^[6-9]\d{9}$`.
library;

/// Inclusive minimum password length shared by registration and login.
const int kPasswordMinLength = 8;

/// Inclusive maximum password length for registration (Req 1.1).
const int kRegisterPasswordMaxLength = 25;

/// Inclusive maximum password length for login (Req 2.1).
const int kLoginPasswordMaxLength = 15;

/// Well-formedness pattern for an email address.
///
/// Requires a non-empty local part, an `@`, a domain label, and at least one
/// dot-separated label (a TLD). Deliberately pragmatic rather than fully
/// RFC 5322 compliant.
final RegExp _emailPattern =
    RegExp(r'^[\w.+-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)+$');

/// Indian mobile-number pattern: a leading 6-9 followed by nine digits.
final RegExp _phonePattern = RegExp(r'^[6-9]\d{9}$');

/// Returns `true` when [email] is well-formed.
bool isValidEmail(String email) => _emailPattern.hasMatch(email);

/// Returns `true` when [password] satisfies the registration length bounds
/// (8-25 inclusive).
bool isValidRegisterPassword(String password) =>
    password.length >= kPasswordMinLength &&
    password.length <= kRegisterPasswordMaxLength;

/// Returns `true` when [password] satisfies the login length bounds
/// (8-15 inclusive).
bool isValidLoginPassword(String password) =>
    password.length >= kPasswordMinLength &&
    password.length <= kLoginPasswordMaxLength;

/// Returns `true` when [fullName] is non-blank - it contains at least one
/// non-whitespace character. Whitespace-only names are rejected.
bool isNonBlankName(String fullName) => fullName.trim().isNotEmpty;

/// Returns `true` when [phone] matches the Indian mobile pattern
/// `^[6-9]\d{9}$`.
bool isValidPhone(String phone) => _phonePattern.hasMatch(phone);

/// Submit gate for the registration form.
///
/// Returns `true` if and only if the email is well-formed, the password length
/// is within 8-25, the full name is non-blank, and the phone matches
/// `^[6-9]\d{9}$` (Property 2; Req 1.1, 1.3).
bool canSubmitRegistration({
  required String email,
  required String password,
  required String fullName,
  required String phone,
}) =>
    isValidEmail(email) &&
    isValidRegisterPassword(password) &&
    isNonBlankName(fullName) &&
    isValidPhone(phone);

/// Submit gate for the login form.
///
/// Returns `true` if and only if the email is well-formed and the password
/// length is within 8-15 (Property 2; Req 2.1).
bool canSubmitLogin({
  required String email,
  required String password,
}) =>
    isValidEmail(email) && isValidLoginPassword(password);
