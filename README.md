# Flutter Uber Clone / Taxi App
#![](images/thumb.jpg)


## Overview
Bucoride app is a full-featured ride-sharing platform inspired by Uber. It allows users to book rides, track drivers in real-time, and manage payments seamlessly. Drivers can post their availability, accept ride requests, and navigate to pick-up and drop-off locations.
The app offers two user roles — Passengers and Drivers — each with personalized dashboards and features.
Key functionalities include live location tracking, ride booking and confirmation, trip history, in-app wallets, free ride promotions, referral bonuses, real-time chat between drivers and passengers, and secure authentication.

Built with a scalable architecture and a clean UI, the Uber Clone App is designed to deliver a smooth and intuitive experience for both riders and drivers.

## Developer instructions
---
**NOTE**: 
* To run this project, you **MUST** install Flutter SDK on your machine. Refer to [Flutter's documentation](https://docs.flutter.dev/get-started/install) and follow a step-by-step guide on how you can install Flutter SDK on your OS.

* Make sure you have installed Android Studio or a text editor of your choice - VS Code or XCode.

* Make sure your machine supports virtualization - required to run an emulator. If it doesn't, don't worry, you can install `scrcpy` on your machine or use Android Studio's `mirror device` feature.

**Scrcpy Installation guide** 
* [Install scrcpy on Windows](https://github.com/Genymobile/scrcpy/blob/master/doc/windows.md)
* [Install scrcpy on Linux](https://github.com/Genymobile/scrcpy/blob/master/doc/linux.md)
* [Install scrcpy on MacOS](https://github.com/Genymobile/scrcpy/blob/master/doc/macos.md)

---


#### Installation guide for developers

1. Git clone

Clone this repository by opening your terminal/CMD and change the current working directory to Desktop - use `cd Desktop` command.
```bash
    cd Desktop    # or your desired directory
    git clone https://github.com/GameRich-tech/uber_app_client.git
```

2. Open the cloned repository on your text editor and run this command:
```bash
    $ flutter run
```
3. Make sure you have a very strong internet connection so that the necessary gradle files can be downloaded. These files are necessary to build the project `apk` file.

---
**Keep in mind**:
* When building the application for the first time, it may take 10 - 15 minutes to finish the installation and build process.
* When running the application using the `flutter run` command, it may take atleast a minute to install the build files on a physical device.
---


## Contributor expectations
Incase of a bug or you wish to make a contribution, create a new branch using the git command `git checkout -b <name of your branch>` and create a pull request. Wait for review.

You can also open an issue using the `Issues` tab. The reported issue will be reviewed and a solution may be provided.

---
## Miscellaneous


There are mainly two aspects to consider in order to have this project working:
1. Don't forget to add your own google maps api into the androidmanifest.xml file
2. This is not requered but you can conect the project to your firebase project by chamging the google-services.json file


#keytool -genkey -v -keystore my-release-key.keystore -keyalg RSA -keysize 2048 -validity 10000 -alias my-key-alias

Windows PowerShell
Copyright (C) Microsoft Corporation. All rights reserved.

Try the new cross-platform PowerShell https://aka.ms/pscore6

PS D:\AndroidStudioProjects\uber_app> keytool -genkey -v -keystore my-release-key.keystore -keyalg RSA -keysize 2048 -validity 10000 -alias my-key-alias
Enter keystore password:  
Re-enter new password:
What is your first and last name?
[Unknown]:  Gamerich Technologies
What is the name of your organizational unit?
[Unknown]:  Gamerich Technologies
What is the name of your organization?
[Unknown]:  Gamerich Technologies
What is the name of your City or Locality?
[Unknown]:  Nairobi
What is the name of your State or Province?
[Unknown]:  Nairobi
What is the two-letter country code for this unit?
[Unknown]:  KE
Is CN=Gamerich Technologies, OU=Gamerich Technologies, O=Gamerich Technologies, L=Nairobi, ST=Nairobi, C=KE correct?
[no]:  yes

Generating 2,048 bit RSA key pair and self-signed certificate (SHA256withRSA) with a validity of 10,000 days
for: CN=Gamerich Technologies, OU=Gamerich Technologies, O=Gamerich Technologies, L=Nairobi, ST=Nairobi, C=KE
[Storing my-release-key.keystore]
PS D:\AndroidStudioProjects\uber_app> 
