import 'package:lichess_mobile/src/utils/list_extension.dart';
extension ListExtension<T> on List<T> {
  T? getOrNull(int index) => index >= 0 && index < length ? this[index] : null;
}
