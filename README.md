# Asterisk

[Asterisk](https://www.asterisk.org/) is "an open-source framework for building
communications applications".
`package:asterisk` is a package for writing these communication applications in
Dart!

Asterisk allows building powerful communication systems. By providing an
abstraction over channels, bridges and endpoints and supporting a wide range of
protocols including VoIP (through SIP and RTP), it is a great choice for all
kinds of applications dealing with phone calls.
How calls are handled in Asterisk is defined in a _dialplan_, a text file which
can get complex to write and maintain in growing setups. And while Asterisk
supports a large number of builtin applications, these are sometimes hard to
setup and understand, or don't support the feature you need.

Fortunately, Asterisk contains a [RESTful interface](https://docs.asterisk.org/Configuration/Interfaces/Asterisk-REST-Interface-ARI/Getting-Started-with-ARI/),
which can be used to interact with calls. This enables you to write your own
communication apps in a language you already know.

## Features

`package:asterisk` provides high-level Dart bindings to both the Asterisk REST
interface as well as the web-socket notification mechanism for events.

Here are just some of the things you can build with this package:

- An automated voicemail system.
- Voice-based timers.
- Call-Roulette.
- Your very own telephone conference setup.
- A customer service system, with hold queues and everything.

There are even more examples in `examples/` - go check them out!

However, note that this package doesn't support real-time interaction with
calls. You can record calls and play sounds, but this isn't a softphone.

## Getting started

Using this package requires a running Asterisk server. To interact with the
actual phone network, you need a VoIP provider that server can talk to.

### Local testing

For testing, you can emulate a local phone network, placing calls in a web
browser thanks to WebRTC.
To get started, run

```
docker run -ti --network host ghcr.io/simolus3/asterisk_demo:latest
```

Starting asterisk will print a lot of errors as it tires to load a lot of
modules we don't need - once it prints "Asterisk Ready.", the system is ready
to go.

Visit http://localhost:8088/. When opening the website for the first time, a
settings screen will be shown.
You need to enter a SIP username under "Account" - the server will accept
`201`, `202`, `203`, `204` or `205`. They all use `demo` as their passsword and
are reachable by dialing their account number.

Next, run an example to call:

```
dart run example/whoami.dart
```

## Usage

TODO: Include short and useful examples for package users. Add longer examples
to `/example` folder. 

```dart
const like = 'sample';
```
