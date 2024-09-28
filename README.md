# ard_blue_app

Project for 2024 Creative Innovation Contest, College of Electronics & Information.<br>
<br>
This repository only contains mobile application part of the project. Repository for the website is [here.](https://github.com/grden/arduino-blue-web)

## Introduction

Researchers highlight the urgent need for improved heat illness prevention measures in the Korean army due to increasing temperatures linked to global warming and other environmental changes.<br>
<br>
To address this, we proposed a solution centered around providing objective data. By sending objective data to the command control center, heat illness-related incidents could be prevented in advance.<br>
<br>
As a result, we developed a watch capable of detecting safety information from soldiers and notifying both the soldiers and command control centers through a mobile app and website.<be>
<br>
<br>
<img width="1133" alt="preview" src="https://github.com/user-attachments/assets/477e5561-b2ce-4d68-9fac-f7d37b7c2d81">

## Service Architecture

<img width="1131" alt="architecture" src="https://github.com/user-attachments/assets/dd548151-e72e-48d6-9233-d8dda4983797">

## Usage

|Health Monitor Screen|Connect to Devices Screen|Detailed Information Screen|
|:---:|:---:|:---:|
|<img src="https://github.com/user-attachments/assets/104b30fc-b89c-43f5-8b0d-2f8d99b88143" width="240">|<img src="https://github.com/user-attachments/assets/98a0129f-5cbe-443d-8d4b-5481bae2f9f7" width="240">|<img src="https://github.com/user-attachments/assets/1b3ff926-3eaa-4386-b211-ca6b143e2da7" width="240">|
|Receive a stream of data from Arduino and display changes. Information includes: heart rate, body temperature, and current location.|When the ‘Start Scan’ button(center bottom) is pressed, the app will scan for specialized Arduino devices and display it in the list. You can connect to the device by tapping the ‘Connect’ button.|When a connection is made, a detailed information screen is available. You can discover and read bluetooth services and characteristics of connected device.
|
