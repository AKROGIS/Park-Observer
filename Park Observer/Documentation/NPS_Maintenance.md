# NPS Maintenance

A "_How To_" guide for maintaining Park Observer inside NPS.
This is intended to help reluctant programmers maintain the code base
in the event that the primary developer retires :wink:.

## Fixing Bugs

1) Create an issue in GitHub. Ensure it is reproducible.  Document step by step how to create the bug.
2) Create a code branch
2) Create a test case that should pass, but fails due to the bug.
2) Fix the code. making only the minimal amount of changes to fix the bug in question.
   Do not do additional "code cleanup", or add/extend other features.
If you see other things that should be fixed, create new issues in GitHub for future consideration.
2) Verify that the code compiles without warnings
2) Verify the code passes the test.
2) Run (and pass) __ALL__ tests to ensure you did not break something else with your change.
2) Do a functional test on the simulators real device. Do not just test your bug, but run thru
   several mock data collection scenarios with various protocol files to ensure nothing unexpected
   was impacted.
2) Run `swift-format` on changed files to lint the code
2) Bump the patch (3rd) number of the version i.e. 2.0.0 -> 2.0.1
2) Do a GitHub pull request for your fix
2) Get a code review.
2) Commit the pull request to master
2) Close the issue (linking to the pull request or last commit).
2) No need to publish a new version, unless you want to, or there is a request.

## Adding A New Feature

1) Create an issue in GitHub. Discuss functionality with affected users to ensure the scope is well understood.
2) Create a code branch
2) Update documentation - this is helpful to do up front, as it clarifies the functionality
2) Create a test case that should pass, but fails due to a lack of features.  You will need to design and stub out an API to get the test code to compile
2) Build the new feature. making only the minimal amount of changes to fix the bug in question.
Do not do additional "code cleanup", or add/extend other features.
If you see other things that should be fixed, create new issues in GitHub for future consideration.
2) Verify that the code compiles without warnings
2) Verify the code passes the test.
2) Do a functional test on the simulators and real devices
2) Runs swift-format to lint the code
2) revisit the documentation and ensure it matches the actual implementation
2) If the new functionality requires an addition to the protocol (*.obsprot) file
   * update the protocol documentation
   * update the schema file
   * use an online validator to ensure that the existing protocol files, and the new protocol files pass.
   * Strive hard to make changes additive (i.e. they do not break existing protocols)
2) Bump the minor (2rd) number of the version, nd reset the patch (3rd) number i.e. 2.0.1 -> 2.2.0
2) Do a GitHub pull request for your new feature
2) Get a code review.
2) Commit the pull request to master.
2) Close the issue (linking to the pull request or last commit).
2) No need to publish a new version, unless you want to, or there is a request.

## Publishing an Update

1) Make sure the version number is different than the last published version
2) Create an archive
   * Set device to "Any IOS Device"
   * Menu: Product -> Archive
3) Create an ipa
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
4) Update the web site
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

* Cloning
* Issues
* Branches
* Pull requests

## Using X code
