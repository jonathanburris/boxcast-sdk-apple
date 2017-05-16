# BoxCast SDK for Apple Platforms

The official BoxCast SDK for integrating with the BoxCast API on Apple platforms.

## Features

- [x] List Live and Archived Broadcasts
- [x] Detail A Broadcast
- [x] Play Live and Archived Broadcasts
- [x] Documentation

## Requirements

- iOS 9.0+
- Xcode 8.2+
- Swift 3.0+

## Installation

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

1. Install Carthage with [Homebrew](http://brew.sh/) using the following command:

	```bash
	$ brew update
	$ brew install carthage
	```

2. Edit your `Cartfile` to integrate BoxCast into your Xcode project:

	```ogdl
	github "boxcast/boxcast-sdk-apple" ~> 0.1
	```

3. Run `carthage update`. This will fetch BoxCast into a `Carthage/Checkouts` folder and build the framework.

4. On your application targets’ “General” settings tab, in the “Linked Frameworks and Libraries” section, drag and drop `BoxCast.framework` from the `Carthage/Build` folder.

5. On your application targets’ “Build Phases” settings tab, click the “+” icon and choose “New Run Script Phase”. Create a Run Script in which you specify your shell (ex: /bin/sh), add the following contents to the script area below the shell:

	```
	/usr/local/bin/carthage copy-frameworks
	```

	and add the paths to the frameworks you want to use under “Input Files”, e.g.:

	```
	$(SRCROOT)/Carthage/Build/iOS/BoxCast.framework
	$(SRCROOT)/Carthage/Build/iOS/Alamofire.framework
	```

## Usage

## Demo

There is a demo app included with this project to help you get a feel for how this SDK can be used. Just open up the `BoxCast.xcodeproj` select the `Demo` scheme and run it.

> Carthage must be installed on your machine or the project won't build.

## Documentation