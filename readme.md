# matlab package for controlling microscope

## classes contains

- Microscope: assemble of different device controllers

- Camera: controllers for camera type devices. interfaced with micromanager

- Lightsource: controllers for light source type devices

- Controller: user interface type devices. (joystick, keyboard, etc)

- Stage: stage type devices. (piezo stage, electric moter stage, etc)

- EventLoop: matlab loop for updating and retrieving values during UI

- Trigger: clocking device type.

- MicroscopeActions: execution commands of microscope

- UIView and UIViewController: an UI to interact with all devices

- TiffIO: image saving class.

## introduction

all device controller are grouped in YMicroscope package

all testing scripts are grouped in tests package

## syntax

- all properties are in lower case

- method with lowercase verb and first letter upper case noun.

- properties of devices have setAccess protected and getAccess public.
They are intended to be get accessed using default getter and being 
set using method getPropertyname.