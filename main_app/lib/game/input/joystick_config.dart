import 'virtual_joystick.dart';

export 'virtual_joystick.dart';

/// Legacy alias helper for [VirtualJoystick].
abstract final class JoystickConfig {
  static dynamic createJoystick() => VirtualJoystick.create();
}
