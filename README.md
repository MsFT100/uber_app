# Flutter Uber Clone / Taxi App
#![](images/thumb.jpg)

## Getting Started

Get the apk for this project at this [link](https://flutter.io/docs/get-started/codelab)

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
