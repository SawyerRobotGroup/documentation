## Flutter Packages

Packages are reusable libraries of code in dart.
Anyone can create a package and upload it to [pub.dev](pub.dev).
We use several packages of our own creation, as well as others.

There is lots of good documentation on [pub.dev](pub.dev) for each package.
You can usually also browse the API reference.

## Usage

To use a package add a line to your `pubspec.yaml` in the root of the flutter project.
This line contains the package name followed by a colon and a version number.
The `^` means any package that is compatible with that version.
Since we are usually pretty flexible with the version and are constantly updating our code,
sometimes you'll see the key `any` which specifies that we are okay with any version. 
This will fetch the latest version from [pub.dev](pub.dev)

```yaml
dependencies:
  your_package_name: ^0.0.1
  another_package: any
```

## Common Packages Recommended for use in all new projects, and integration into old projects

* [provider](pub.dev/packages/provider)
* [roslib](pub.dev/packages/roslib)

## New Packages To Start Using
Currently we aren't using everywhere, but probably should use (in order of usefulness in day-to-day work):
* [dartx](pub.dev/packages/dartx)
* [flutter_hooks](pub.dev/packages/flutter_hooks)
* [dartros](pub.dev/packages/dartros)
* [maestro](pub.dev/packages/maestro)
* [freezed](pub.dev/packages/freezed)
* [xcontext](pub.dev/packages/xcontext)
  
## Custom Packages
* [dartros](pub.dev/packages/dartros) (Still a work in progress)
* [flutter_rosutils](pub.dev/packages/flutter_rosutils) Some helpers for the roslib library to keep state of flutter application in sync with what is happening in ROS
* [dart_statistics](pub.dev/packages/dart_statistics) Used in the proficiency assessment work, with the mouse-cheese world flutter application

## Sawyer Faces
* [flare_flutter](pub.dev/packages/flare_flutter) (Animation framework)

## Speech App
* [googleapis](pub.dev/packages/googleapis)

## SSharp
* [socket_io](pub.dev/packages/socket_io)