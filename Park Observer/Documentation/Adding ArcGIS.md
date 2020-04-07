#  Adding the ArcGIS SDK
This project has a dependency on the ArcGIS Runtime SDK for iOS.
This document describes a manual installation process for this project
that does not require any 3rd party package managers.

It was last updated for version 100.7.0 on 2020-04-01

1) Download the SDK from https://developers.arcgis.com/ios.
Run the installer.  This will install the ArcGIS framework under
`${HOME}/Library/SDKs/ArcGIS/iOS`.
You can support multiple versions by renaming the last folder with the
version number and using symbolic links to point `iOS` to the version
you want to use.  i.e. `ln -s iOS_100.7.0 iOS`. You also need to rename
`${HOME}/Library/Application Support/AGSiOSRuntimeSDK`. You could also
copy the framework from another computer that has it, however do not
add it to the repo as it contains a 500MB+ binary file.

The following steps have already been done for this project, but you
would need to do them for a new project.  It is possible that you may
need to repair the path of the framework in step 2 if you move the location of your project, install the repo on a different machine, or
move/rename the location of the framework. Xcode stores a relative
path to the framework.

2) Drag and drop the file (folder) `ArcGIS.framework` from the
`${HOME}/Library/SDKs/ArcGIS/iOS/Frameworks/Dynamic`
directory into the **Embedded Binaries** section in the **General**
tab of your target's build settings,

3) Switch to the **Build Phases** tab of your target's build settings,
click the **+** to add a new **Run Script Phase**.
Then paste in the following text :
```
bash "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/ArcGIS.framework/strip-frameworks.sh"
```

4) Finally, add the `#import <ArcGIS/ArcGIS.h>` statement to your
Objective-C files or `import ArcGIS` statement to your Swift files
where you wish to use the API.
