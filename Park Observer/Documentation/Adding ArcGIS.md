#  Adding the ArcGIS SDK
This project has a dependency on the ArcGIS Runtime SDK for iOS
100.7.0 or greater (previous versions of 100.x may work, but version
10.2.5 definitely does not work). This document describes a manual
installation process for this project that does not require any 3rd party
package managers.

Xcode 12.3 or higher requires a format for the SDK that was not
adopted until 100.10.0, therefore the
[build instructions](https://developers.arcgis.com/ios/reference/release-notes/#breaking-api-changess)
changed at version 100.10.0.  

This was last updated for version 100.10.0 on 2021-02-08.
Instructions for previous versions are in the earlier versions
of this document (see the commit history).

1) Download the SDK from https://developers.arcgis.com/ios.
Run the installer.  This will install the ArcGIS framework under
`${HOME}/Library/ArcGIS/`. You can support multiple versions
by renaming the last folder with the version number and using
symbolic links to point `ArcGIS` to the version you want to use.
i.e. `ln -s ArcGIS_100.10.0 ArcGIS`. You also need to rename
`${HOME}/Library/Application Support/AGSiOSRuntimeSDK`.
You could also copy the framework from another computer that has it,
however do not add it to the repo as it contains a 500MB+ binary file.

The following steps have already been done for this project, but you
would need to do them for a new project.  It is possible that you may
need to repair the path of the framework in step 2 if you move the
location of your project, install the repo on a different machine, or
move/rename the location of the framework. Xcode stores a relative
path to the framework.

2) Drag and drop the file (folder) `ArcGIS.xcframework` from the
`${HOME}/Library/SDKs/ArcGIS/Frameworks`
directory into the **Frameworks, Libraries, and Embedded Content**
section in the **General** tab of your target's build settings,

3) Finally, add the `#import <ArcGIS/ArcGIS.h>` statement to your
Objective-C files or `import ArcGIS` statement to your Swift files
where you wish to use the API.
