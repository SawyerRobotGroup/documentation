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
* [xcontext](pub.dev/packages/xcontext)
* [widgetx](pub.dev/packages/widgetx)
* [derry](pub.dev/packages/derry)
* [freezed](pub.dev/packages/freezed)
* [breakpoint](pub.dev/packages/breakpoint)
* [wiredash](pub.dev/packages/wiredash)
* [flutter_launcher_icons](pub.dev/packages/flutter_launcher_icons) -- however, this [fork](https://github.com/personalizedrefrigerator/flutter_launcher_icons) is currently needed to generate icons for web
  
## Packages to explore
* [fluttercommunity packages](https://pub.dev/publishers/fluttercommunity.dev/packages) 
* [textstyle_extensions](https://pub.dev/packages/textstyle_extensions)
* [rnd](pub.dev/packages/rnd)


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


## State Management Recommendations
Use any of the following options, they each have their benefits.
Most of what we have done is the first option. However, with mutable state it can cause bad states more frequently.
Immutable states are highly recommended to avoid two mutations that cause inconsistent state. 
See the [freezed package](pub.dev/packages/freezed) for my recommendation on making states immutable.
Also, recommended to design with the goal in mind of making illegal states unrepresentable. 
See [this](https://www.youtube.com/watch?v=RMiN59x3uH0&list=PLB6lc7nQ1n4iS5p-IezFFgqP6YvAJy84U) tutorial series for more info.
(It shows very good clean architecture principles) 

For UI related state, (animations / text controllers, etc) please use [flutter_hooks](pub.dev/packages/flutter_hooks)

* ChangeNotifier with [provider](pub.dev/packages/provider) or [injectable](pub.dev/packages/injectable) or [riverpod](pub.dev/packages/riverpod)
* [StateNotifier](pub.dev/packages/state_notifier) along with [provider](pub.dev/packages/provider) or [injectable](pub.dev/packages/injectable) or [riverpod](pub.dev/packages/riverpod)
* [maestro](pub.dev/packages/maestro)
* [get](pub.dev/packages/get)
* [flutter_bloc](pub.dev/packages/flutter_bloc) along with [provider](pub.dev/packages/provider) or [injectable](pub.dev/packages/injectable) or [riverpod](pub.dev/packages/riverpod)