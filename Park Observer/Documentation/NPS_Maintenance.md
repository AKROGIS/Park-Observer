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
14) There is no need to publish a new version immediately unless there is an
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
18) There is no need to publish a new version immediately unless there is an
    urgent user request.

## Publishing an Update

1) Open the project in Xcode
2) Ensure that the version number is different than the last published version.
   See the instructions above. If this is just a new code signing, i.e.
   extending the expiration date without any code changes, then bump the
   patch (3rd) number.
3) Create an Archive.
4) Create an ipa
   * In the Archive Window, select new archive (should be named for the new version number)
   * Click the blue "Distribute App" button
   * Select `Enterprise` then `Next`
     * App Thinning: None
     * Rebuild from Bitcode: uncheck
     * Include Manifest: uncheck
     * click `Next`
   * Select `Automatically manage Signing` then `Next` (You may need to authenticate)
   * Review the summary and click `Export`
     * Select a location to save the export file
     * Rename the `ipa` as `ParkObserver2.0.0.beta4.ipa` or similar
5) Update the web site
   * Copy the `ipa` to the teams drive and to the website downloads folder
   * Edit the following files in <https://github.com/AKROGIS/Park-Observer-Website>
     * `Downloads2/Changelog.html` - Create a new section for this release and summarize the changes
     * `Downloads2/versionlist.json` - copy/paste/edit a new entry for the new version
     * `Downloads2/ParkObserver2.plist` - update the paths to reflect the new version (2 places)
     * Commit the changes, and copy to the published website folder.

## Setting up a Mac

* Certificates
* Software

## Using Git/GitHub

### Submit an Issue

### Create a Branch
* Cloning
* Branches

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

### Formatting code

All of the Swift code in the project is formatted with the default settings
of the [swift-format](https://github.com/apple/swift-format) command line tool.
As of April 2021, it is not part of XCode and must be installed separately.
A version for XCode 12 (Swift 5.3) has already been installed on the GIS
team's iMac Pro.

* To format a file, run `swift-format -i file.swift`
* To recursively format all files in a folder, run: `swift-format -i -r folder`
