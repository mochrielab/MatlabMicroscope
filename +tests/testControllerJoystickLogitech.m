import YMicroscope.*

js = ControllerJoystickLogitech();

js.getSpeed()
display('get speed')

js.emitActionEvents()
display('emit action')

js.emitMotionEvents()
display('emit motion')
