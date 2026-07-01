/// Represents a decoded Spring `Page<T>` response.
///
/// Contains the content list and pagination metadata needed to drive
/// infinite scroll (stop when [last] is true, request page [number] + 1
/// for the next page).
class PageResult<T> {
  const PageResult({
    required this.content,
    required this.number,
    required this.size,
    required this.totalElements,
    required this.totalPages,
    required this.last,
    required this.first,
  });

  /// The list of items on this page.
  final List<T> content;

  /// Zero-based page index.
  final int number;

  /// Requested page size.
  final int size;

  /// Total number of elements across all pages.
  final int totalElements;

  /// Total number of pages.
  final int totalPages;

  /// Whether this is the last page.
  final bool last;

  /// Whether this is the first page.
  final bool first;

  /// Decodes a raw JSON map (Spring Page shape) into a typed [PageResult].
  ///
  /// [fromJsonT] decodes each element in the `content` array.
  factory PageResult.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    final rawContent = json['content'] as List<dynamic>? ?? [];
    final content = rawContent.map((item) => fromJsonT(item)).toList();

    return PageResult<T>(
      content: content,
      number: json['number'] as int? ?? 0,
      size: json['size'] as int? ?? 0,
      totalElements: json['totalElements'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 0,
      last: json['last'] as bool? ?? true,
      first: json['first'] as bool? ?? true,
    );
  }
}
