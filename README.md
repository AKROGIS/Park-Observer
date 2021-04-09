# Park Observer 2.0

![Park Observer 2.0 Logo](Park%20Observer/Assets/Assets.xcassets/AppIcon.appiconset/180.png)

An iOS application for spatial data collection.
The application is well suited for collecting the location,
time and user defined attributes of **observations**, as well
as well as where you went looking for the observations.

Park Observer was developed by the GIS Team at the
Alaska Region of the National Park Service.

Park Observer 2.0 is built with SwiftUI and requires iOS 13+.
For older versions of iOS, please see the [original version
of Park Observer](https://github.com/AKROGIS/Observer)

## Building

To build Park Observer, you will need a computer with macOS and XCode.
XCode can be downloaded for free from the App Store App in macOS.
Development was done on macOS 11 (Big Sur) and XCode 12. Using a previous
version may work but it is on you to figure it out. Usually you cannot test on
the current version of iOS unless you have the most current version of XCode
which typically requires the most current version of macOS.

If you are maintaining Park Observer for the Alaska Region NPS, see the
[NPS maintenance document](Documentation/NPS_Maintenance.md)
for details on publishing with the enterprise license.

If you don't have an Apple Developer account, you can still build and install
Park Observer on your personal device.  You  will need an
[Apple ID](https://support.apple.com/apple-id).

  1) Clone this repo to your computer
  2) Install the ArcGIS Runtime for iOS.
     ([Instructions](Documentation/Adding%20ArcGIS.md))
  3) Open `Park Observer.xcodeproj` in XCode
  4) To run in a simulator, select a simulator and click the run button.
  5) To run on your personal device, follow the following instructions
     (adapted for Xcode 12 from this
     [Stack Overflow answer](https://stackoverflow.com/a/4952845/542911)).
     * In Xcode, add your Apple ID to the Account preferences.
     * In the project navigator, select the project and your target to
       display the project editor.
     * Select the _Signing & Capabilities_ tab
     * Replace `gov.nps.akro` in the **Bundle Identifier** with something
       unique to you.
     * Choose your name from the *Team* pop-up menu.
     * XCode should now create a provisioning profile and signing certificate.
     * Connect your device to your Mac and choose your device from the Scheme
       toolbar menu.
     * Click **Run** button. Xcode installs the app on the device before
       launching the app.
     * After the first attempted launch (which will likely fail), go to the
       Settings app, and under **General/Device Management**, select your
       Development ID and then click the **Trust** button.
     * You can now manually launch the app on your device.

## Usage

If you are on the National Park Service Network, then see the website
<https://akrgis.nps.gov/apps/observer> for complete documentation on installing
and using Park Observer.  Others can see the documents for that website in the
[Park Observer Website repo](https://github.com/AKROGIS/Park-Observer-Website/).
The [Getting Started](https://github.com/AKROGIS/Park-Observer-Website/blob/master/help2/index.md)
and [User Guide](https://github.com/AKROGIS/Park-Observer-Website/blob/master/help2/user_guide.md)
documents are a good place to start.
