# NPS Maintenance

A "_How To_" guide for maintaining Park Observer inside NPS.
This is intended to help reluctant programmers maintain the code base
in the event that the primary developer retires :wink:.

Instructions below assume you have a clone of the repo on your development
computer and that you have commit privileges to the repo.  If you do not have
commit access you will need to create a fork and issue a pull request when
your work is done.

## Fixing Bugs

1) Create an issue in GitHub. Ensure it is reproducible. Document step by step
   how to reproduce the bug and the behavior you expect.  If a bug is not
   reproducible, or the expected outcome is unknown it may be impossible to
   correctly fix the bug. For more info search on
   [bug reporting best practices](https://duckduckgo.com/?q=bug+reporting+best+practices).
2) Create a branch in git for this bug.
3) Create at least one test case that should pass, but fails due to the bug.
4) Fix the code. Make only the minimal amount of changes to fix the bug at issue.
   Do not do additional "code cleanup", or add/extend other features.
   If you see other things that should be fixed, create new issues in GitHub for
   future consideration.
5) Verify that the code compiles without warnings.
6) Verify the code passes all the new tests.
7) Run (and pass) __ALL__ tests to ensure you did not break something else with
   your changes.
8) Do a functional test on the simulators and a real device. Do not just test
   your bug, but run through several mock data collection scenarios with various
   protocol files to ensure nothing unexpected was impacted.
9) Run `swift-format` on changed files to lint the code.
10) Bump the patch (3rd) number of the version i.e. `2.0.0` -> `2.0.1`. Skip
    this step if the minor or patch number has already been bumped since the
    last published version.
11) Get a peer to review your code (or review the pull request).
12) Merge the branch (or pull request) into master.
13) Close the issue (linking to the pull request or last commit).
14) Summarize the bug fix in the [Change Log](./ChangeLog.md).
15) There is no need to publish a new version immediately unless there is an
    urgent user request.

## Adding A New Feature

1) Create an issue in GitHub. Discuss the functionality with all affected users
   to ensure the scope is well understood.
2) Create a branch in git for this feature.
3) Update documentation. This is helpful to do up front, as it clarifies the
   functionality. Try and get user review of the documentation before coding.
4) Create at least one test case that should pass, but fails due to a lack of
   the new feature. You will need to design and stub out an API to get the test
   code to compile.
5) Build the new feature. Make only the minimal amount of changes implement the
   feature at issue. Do not do additional "code cleanup", fix bugs, or
   add/extend other features. If you see other things that should be fixed,
   create new issues in GitHub for future consideration.
6) Verify that the code compiles without warnings
7) Verify the code passes all the new tests.
8) Run (and pass) __ALL__ tests to ensure you did not break something else with
   your changes.
9) Do a functional test on the simulators and a real device. Do not just test
   your bug, but run through several mock data collection scenarios with various
   protocol files to ensure nothing unexpected was impacted.
10) Run `swift-format` on changed files to lint the code.
11) Bump the patch (3rd) number of the version i.e. 2.0.0 -> 2.0.1
12) Revisit the documentation and ensure it matches the actual implementation.
13) If the new functionality requires an change to the protocol (*.obsprot)
    file:
    * Strive to make changes additive (i.e. do not change or remove existing
      properties in the protocol specification as that would break existing
      protocol files).
    * Update the [protocol documentation](./Protocol%20Specification.md)
    * update the [schema file](./protocol.v2.schema.json)
    * Use an online validator (see the
      [protocol documentation](./Protocol%20Specification.md) to ensure that all
      known protocol files pass.
14) Bump the minor (2rd) number of the version, and reset the patch (3rd) number
    to zero. i.e. `2.0.3` -> `2.1.0`. Skip this step if the minor number has
    already been bumped since the last published version.
15) Get a peer to review your code (or review the pull request).
16) Merge the branch (or pull request) into master.
17) Close the issue (linking to the pull request or last commit).
18) Summarize the new feature in the [Change Log](./ChangeLog.md).
19) There is no need to publish a new version immediately unless there is an
    urgent user request.

## Publishing an Update

1) Set up the signing certificate (see the following section).
2) Open the project in Xcode
3) Ensure that the version number is different than the last published version.
   See the instructions above. If this is just a new code signing, i.e.
   extending the expiration date without any code changes, then bump the
   patch (3rd) number.
4) Create an archive.
   * This step will fail if your Apple ID is not in the Team's development
     account. See the section on
     [Certificates and Provisioning Profiles](#certificates-and-provisioning-profiles)
     below for details.
5) Create an ipa
   * In the _Organizer_ window, select the archive you want to sign and publish.
   * Click the blue `Distribute App` button
   * Select `Enterprise` then `Next`
     * App Thinning: None
     * Rebuild from BitCode: Either option is ok. Checked is slower, but the
       `*.ipa` file is slightly smaller.
     * Include Manifest: Uncheck
     * Click `Next`
   * Select `Automatically manage signing` then `Next`
     * This step will fail if you do not have the team's Developer ID private
       key. See the section on
       [Certificates and Provisioning Profiles](#certificates-and-provisioning-profiles)
       below for details.
     * If this step fails with a private key installed, click `Previous` and
       select `Manually manage signing` and select a distribution profile and
       distribution certificate in the `Next` page.
   * Review the summary and click `Export`
     * Select a location to save the export file
     * Rename the `ipa` as `ParkObserver2.0.0.beta4.ipa` or similar
6) Update the web site
   * Copy the `*.ipa` to the teams drive and to the website `Downloads2` folder.
   * Edit the following files in <https://github.com/AKROGIS/Park-Observer-Website>
     * `Downloads2/Changelog.html`
       * Create a new section for this release.
       * Convert the [Change Log](./ChangeLog.md) to html using an online
         markdown to html converter.
       * Copy paste the html for this release into the new section.
     * `Downloads2/versionlist.json`
       * Copy/paste the entry for the previous version.
       * Edit the copy to reflect the record for the new version.
     * `Downloads2/ParkObserver2.plist`
       * Update the `ipa` name in two paths to point to the new `ipa` file.
   * Commit the changes
   * Copy the changed files to the published website folder.

## Setting up a Mac

The username and password for the GIS teams iMac Pro computer is stored in
in the GIS team's password keeper.  That account has been used to create and
maintain Park Observer.  However a future maintainer will need to add
their Apple ID to the XCode preferences for code signing.  The following
bullets assume you are using a different computer.

### Software

* Install XCode from the Mac App Store
* Install [swift-format](https://github.com/apple/swift-format) from the
  GitHub repo.
* Install [GitHub Desktop](https://desktop.github.com/)

### Code

* Use GitHub Desktop (or the git command line) to clone this repo to your
  computer.
* Install the [ArcGIS Runtime SDK for iOS](./Adding%20ArcGIS.md)

### Certificates and Provisioning Profiles

The Alaska Region GIS Team has an Apple Enterprise Developer's Account and
license. You must use the team's signing certificate to create a provisioning
profile and an installation package that can be installed on any NPS iOS device.
To use the team's signing certificate, you need a copy of the team's private
key (which is in the team's password keeper), and an Apple ID that is in the
teams Apple Enterprise Developer's Account.

* Add your Apple ID to the Accounts in XCode Preferences
  * If your Apple ID is a member of the Enterprise Developer Program,
    you will be able to build the repo for development and testing.
  * If your Apple ID is NOT a member of the Enterprise Developer Program,
    the see the [repo Readme](../README.md#building) for build details.
* Install the private key
  * You will need the GIS Team's private encryption key in order to sign
    an archive (in the publishing steps above)
  * Download the private key file `NPS_iOS_Distribution_private_key.p12` from
    the team's password keeper on the team's network drive to the mac.
  * Install the private key in _KeyChain_.
    * Double click the `*.p12` file.
    * Select `login` for the `Keychain` in the _Add Certificates_ dialog, and
      click `Add`.
    * Enter the password for the `*.p12` file (in the password keeper) and
      click `OK`.
  * **GUARD THE PRIVATE KEY AND DO NOT LOSE IT.**
    If the private encryption key is lost, then you will need to create a new
    one and revoke the existing signing certificate - **which will cause all
    copies of Park Observer in the wild to stop working!**  You can then
    create a new signing certificate with the new private key.  See
    [Apple Developer Certificates](https://developer.apple.com/support/certificates/)
    for more information about certificates.  Note that we are only using
    an iOS Distribution Certificate.  We do not need any other _capabilities_
    like _Apple Pay_ or _Push Notifications_.
  * If the team's password keeper is lost or corrupted and that private key is
    lost, it can be exported _KeyChain_ on any mac computer that has the private
    key installed.

## Using Git/GitHub

### Submit an Issue

### Clone a Repository

### Create a Branch

## Using X code

### Create a test

### Running tests

### Running on a simulator

### Running on a device

### Change the version number

### Create an Archive

Archives are a compiled release build ready for code signing. They are
maintained by Xcode (They are on the GIS team's iMac Pro). Old archives can
be resigned when the profile or certificate they were signed with expires.
Typically, I only support the current version, and build a new archive for
each release.

* Open the project in XCode
* In the _Active Scheme_ tool bar, set the device to "Any IOS Device (arm64)"
* Select _Archive_ in the _Product_ menu.
* When the build is done, XCode will open up the _Organizer_ and display a
  list of all the current user's archives.
* You can review the list of archives by selecting _Organizer_ in the _Windows_
  menu.

### Formatting Code

All of the Swift code in the project is formatted with the default settings
of the [swift-format](https://github.com/apple/swift-format) command line tool.
As of April 2021, it is not part of XCode and must be installed separately.
A version for XCode 12 (Swift 5.3) has already been installed on the GIS
team's iMac Pro.

* To format a file, run `swift-format -i file.swift`
* To recursively format all files in a folder, run: `swift-format -i -r folder`
