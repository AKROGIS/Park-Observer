# Adding the ArcGIS SDK

This project has a dependency on the ArcGIS Runtime SDK for iOS
100.12.0 or greater (previous versions of 100.x will not work
without modification to the build instructions, and version
10.2.5 will definitely not work).

The ArcGIS Runtime SDK is automatically added to the project as
a dependency with the Swift Package Manager.  An internet
connection is required if the building on a new machine that has
not yet downloaded the dependency.

The project is set to use the most recent minor version i.e.
100.12.0+, but not 100.13.0+.  This is because Esri deprecates
features in the minor releases. To use a more recent version
of the ArcGIS Runtime SDK, set the version number in the package
dependencies tab of the project build instructions.
