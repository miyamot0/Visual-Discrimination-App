# Project name: Visual Discrimination App

This project is a Flutter-powered application designed to gauge a learner's ability to make visual discriminations (i.e., colors). This is built entirely in Google's Flutter, tested across Android and iOS. Only Android and iOS are actively maintained and under evaluation at this point.

## Instructions

- Web Login (optional): [https://visualdiscriminationproject.github.io/](https://visualdiscriminationproject.github.io/)
- App Login: Log in per supplied credentials
- Add Participant: In home screen, hit add participant (Name, describe, and input session conditions)
- Pre-training (1 sample, 1 comparison): Select the 'Edit' icon and then 'Practice (1s/1c)'
- Pre-training (1 sample, 2 comparison): Select the 'Edit' icon and then 'Practice (1s/2c)'
- Run Session: Press the 'Play' icon on the home page
- Show Data: Select the 'Edit' icon and then press 'Show Data'
- Edit Session Conditions: Select the 'Edit' icon and then press 'Edit Session'

## Derivative Works

This project is a derivative work of an earlier project and uses licensed software:

- [Fast Talker](https://github.com/miyamot0/FastTalkerSkiaSharp) - MIT - Copyright 2016-2018 Shawn Gilroy. [www.smallnstats.com]
- [Cross-Platform-Communication-App](https://github.com/miyamot0/Cross-Platform-Communication-App) - MIT - Copyright 2016-2017 Shawn Gilroy. [www.smallnstats.com](http://www.smallnstats.com)
- [coding-with-flutter-login-demo](https://github.com/bizz84/coding-with-flutter-login-demo) - MIT - Copyright 2018 Andrea Bizzotto [bizz84@gmail.com](bizz84@gmail.com)

## Dependencies

- firebase_auth - Copyright 2017 The Chromium Authors (BSD-3). [Github](https://github.com/flutter/plugins)
- cloud_firestore - Copyright 2017 The Chromium Authors (BSD-3). [Github](https://github.com/flutter/plugins)
- audioplayers - Copyright 2017 Luan Nico (MIT). [Github](https://github.com/luanpotter/audioplayers)
- flutter_charts - Copyright 2017 Milan Zimmermann (BSD-2). [Github](https://github.com/mzimmerm/flutter_charts)
- queries - Copyright (c) 2014, Andrew Mezoni (BSD-3). [Github](https://github.com/mezoni/queries)

## Assets

This project uses open assets to support its functionality:

- [Short Success Sound Glockenspiel Treasure Video Game.mp3](https://freesound.org/people/FunWithSound/sounds/456965/) - CC0 - Copyright 2019 FunWithSound
- [Smiley Face](https://pixabay.com/en/smiley-face-happy-thumbs-up-thumb-147407/) - Public Domain - Copyright 2019 Pixabay

## Installation

This application can be installed as either an Android or iOS application.  

## Development

This is currently under active development and evaluation.

## Building

flutter build ios --release
xcodebuild -workspace Runner.xcworkspace -scheme Runner -sdk iphoneos -configuration Release archive -archivePath $PWD/build/Runner.xcarchive
xcodebuild -exportArchive -archivePath $PWD/build/Runner.xcarchive -exportOptionsPlist exportOptions.plist -exportPath $PWD/build/Runner.ipa

## License

Copyright 2018-2019, Shawn P. Gilroy (sgilroy1@lsu.edu)/Louisiana State University - MIT