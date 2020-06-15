
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
(riverpod) is new and has very little documentation, so I would advise against it.

## TODO: An example of some of these approaches