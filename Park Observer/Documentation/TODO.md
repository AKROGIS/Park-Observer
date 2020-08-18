Park Observer 2.0 To Do List
============================

# Features

## Priority 1
User requested features I intend to implement.

## Priority 2
Functionality I plan to implement for parity with Park Observer 1.0.
  * Add UI/Alerts when adding obsprot/archive/map from email, browser or the files app

## Priority 3
New functionality I want to implement.
  * User (and/or protocol) settings for GPS accuracy and frequency (time and/or distance)
  * User setting for turning on/off display of gps points and/or track logs
  * User setting for hit test area (small:11, medium:22, large:44) - default medium
  * Text alignment in Add feature at GPS button breaks down with accessible (larger) fonts
  * Feature selector/presenter should show map label when defined otherwise the id if defined
  * Group features by type on the feature Selector view.
  * If GPS is denied when starting a track log or adding a feature, then raise "Go to settings" alert
  * Change footer in file pick lists when there are no files
  * Allow multiple concurrent messages. Close button to hide all or hide individuals
  * Option to choose "Survey" or "Transect" for the observing button - New option in protocol file
  * Get MapInfo data from user and encode in a json file.
  * Format CSV per protocol definition
  * Add a graphic for the observers location (set symbology in mission) - New option in protocol file
  * Dynamic sized text in scale bar

## Considering
Potential features than need additional consideration.
  * Warn when deleting archives?
  * Scale bar fade in/out after zoom?
  * Color the add observation button to match observation symbology?
  * Provide button to show map legend?
  * Differentiate the two stop buttons?
  * After importing a survey prompt to make survey active?
  * After creating a new survey prompt to make active?
  * Should the Info Banner should stand out more?
    - Maybe the background should be less transparent and not full width.
    - Maybe it should be next to the scalebar on the ipad (below/above) on the iPhone
  * Split track logs at 1000 vertices?
  * Revisit database schema - explore schema migration

## Potential
Features ideas open for discussion, but no plans/time to implement.
  * Calculated fields
  * Support general form validation (Old Issue #61) i.e. sum of counts > 0
  * Add photo points, and camera button to UI
  * Add audio clips to observations
  * Add a observation attribute type for a sketch-able geometry.
    The underlying storage would be a WKTString describing the line or polygon.
  * Static vs. dynamic mission properties (static at start track logging, mission properties at weather/start observing)
  * Support selecting and editing track logs (via associated map properties)
  * Move mission property points (snap to a gps point)
  * Delete mission property points
  * Browse and download tile caches (*.tpk) from ArcGIS Online
  * Browse and download protocol files (*.obsprot) from GitHub
  * Hi speed KIMU interface. Coded string like a180d100k4w which is decoded into the appropriate attributes
  * Load feature classes like nests or transects and use an attribute (i.e. nest ID or transect ID) of
    the closest feature to populate observation (NOTE: This is much easier to do in post processing)
  * Protocol V3 - complete re-write.
  * Companion app to build protocol files
  * Display "Getting Started" screens if first launch

## Omitted
Features from Park Observer 1.0 I don't plan to implement, unless requested.
  * Browse and download tile caches (*.tpk) from akrgis.nps.gov
  * Browse and download protocol files (*.obsprot) from akrgis.nps.gov
  * Upload surveys to akrgis.nps.gov (sync to server)
  * Email CSV/survey
  * Add feature at target location (target was cross hairs at center of screen)
  * Analytics/crash logging service
  * Thumbnails for maps


# Bugs

## Critical
These bugs create errors in stored data.

## Important
These bugs limit required functionality.

## Nice to fix
These bugs can be worked around or ignored.
  * Do not show attribute editor if no dialog _and_ not angleDistance
  * Canceling a mission property dialog when launched from tracklogging or observing button does not cancel operation only attribute editing.
  * Check that user provided range on numbers have lower < upper
  * Getting the most recent Mission Property (for default) from database does not consider adhoc locations
  * Problem with Mission Properties with required values and no editing on start tracklog (values will be null)
  * When editing multiple features, if one has validation errors when you decide to move another feature, the validation interrupts the move
  * When exporting, the export date is updated before we know if the export succeeds.  If it fails, we need to undo the export date.
  * When returning from background addGpsLocation can be called from cache and from locationManager out of order
  * Chaos may ensue if the user does not tap on the map when "Moving to map location"; start modal mode?
  * Need to be able to delete status messages when they no longer apply.
  * Slide out view does not check width on device rotation (limit to maxWidth as % of screenwidth)
  * Refresh the current file list if the slide out is hidden and re-shown
  * Alarm does not play alert sound when app is active
  * Add notice to turn on notification in settings if denied for alarm setting
  * User can provide a unique value renderer for track logs and or gps points, but graphics do not have the necessary attributes
  * The safe area (on devices with safe area - iPhone X and 11) mucks with styling of slide out view
 
## Annoying
These bugs are related to potential functionality (so while incorrect, they have no impact yet).
  * encode(AnyJSON(agsRenderer.toJSON())) converts 0 to false, so result is no longer valid on read

## Not mine
These issues are in software provided by others (Apple, Esri). If they become a problem, a work around may be possible
  * TextFields with number formatters can show an invalid value. They do not update the display the return key is pressed --
    they do not update when moving focus to another control with a screen touch.  The data saved will be the last valid value
    the the user typed.  For example if the field limited numbers to 360, and the user typed  2-5-4-3, the display would show
    2543, but 254 would be saved.   The work around is to always press the return key when done editing a number field.
  * Action Sheets on the iPad do not show up in correct location (especially for items at bottom of file list)
    This is a known Apple bug(https://stackoverflow.com/q/61676063/542911)
  * Background Track Log toggle is settings is not hidden when the user has rejected _Always_ (background) location authorization.
    The system does not track if _Always_ authorization was requested and rejected.  If the app has not requested _Always_ authorization
    it will have _In Use_, _Denied_, or _Unknown_ authorization.  If the app has requested _Always_ and the user has rejected it,
    the authorization still be one of _In Use_, _Denied_, or _Unknown_ authorization.
  * Text/Number fields in attribute editing form should get focus when displayed and editable.
    The user should be able to navigate to next/previous Text/Number field with a next/prev key on the on-screen keyboard, or
    the tab (shift-tab) keys on a bluetooth keyboard.  Unfortunately, this is not supported in SwiftUI (iOS 13 and 14_beta).
    See https://developer.apple.com/forums/thread/650263


# Documentation
  * Post new specs and schema to existing website.
  * Edit/Cleanup the Park Observer 2.0 section of specs in the new project
  * Create a simple how to document with screenshots
  * Contributing guidelines - step by step processes for:
    - fixing bugs
    - adding features
    - publishing new versions

# Change Log

## 2020-08-21: Beta3

* On first launch select an online map for the default.
* On first launch create sample survey and set it as the default.
* Fixed bug that failed to update label and rendering when changing attribute from null to non-null
* Fixed display glitch with disclosure angle for details view in survey and protocol lists.
* Fixed bug where editor was not presented when creating a new feature at the map touch location
* Fixed bug where the track log properties editor was not displayed at the proper times
* Add default limits of 0..100 on the stepper control (for legacy compatibility)
* Disable save button when there are no changes
* Fixed bug where mission properties at touch location were mis drawn at gps location.
* If you tap to select multiple features, and then delete one, it is removed from the list of selected features.

## 2020-08-14: Beta2

 * Fix Bugs in totalizer
 * Properly disable background tracklogging
 * Add alarm interval to settings
 * Add "required" property to attributes.  UI Forces user to provide non-null attribute value
 * Add "azimuth/distance" option to location methods (angle is relative to north, not course)
 * Fix bugs with angle/distance forms (start with null, make required and validate)
 * Show warning when angle is behind you (based on course; only for angle/distance)
 * Make [github repo](https://github.com/regan-sarwas/park-observer) public
 * Add user setting to put attribute buttons on top of form (instead of bottom)
 * Add confirmation alert when deleting an observation
 * Add an optional time and location of observation to the attribute form
 * Support editing of survey names
 * Add forms showing details/structure of survey protocol
 * Add form showing details of survey
 * Survey protocol files and archives can be opened with Park Observer from email and files app (no UI yet)

## 2020-08-07: Beta1

# Programmer Notes

## Testing

### Unit Testing
  * Observation:new() and New MissionProperty:new() methods
  * New default dialog values
  * MapInfo tests
  * Add tests for new protocol properties: track logs and transects
  * Add tests for extensions to Feature and [Feature] (i.e. allowGPS, locatableWithMapTouch)
  * Add tests for failure cases, see code coverage analysis
  * Additional Survey Tests
    - correct date and status in info
  * Test reading from closed NSManagedObjectContext
    - close w/ unsaved changes, save on closed context, close a closed context
    - reload a loaded context, load a closed context

### UI (or interactive) Testing
  * Test Gps failure condition and correct resumption of data collection
  * Test computed and multi-value labels
  * Test the size of form controls when large dynamic fonts are used
  * Test lists of features addable with/without touch based on state of config/trackLogging/observing
  * Test switch to background mode when creating a new observation (may request GPS in foreground and get it in background)

## Code Cleanup
Maintainability issues in the code that are generally invisible to the user.
  * Refactor Filesystem around appFile
  * Cleanup SurveyController
  * SurveyController should listen to ObservationPresenter.awaitingGPS then trigger Async GPS request.
  * Fix timestamp property in ObservationPresenter (should be optional, but ObservationSelectorView doesn't like that)
  * Cleanup handling of error messages in ObservationPresenter
  * ObservationPresenter is creating a retain cycle (break at end of SurveyController.observing didSet)
  * Refactor to reduce testing dependant on CoreData
  * Create doc strings for all public members
  * Replace print statements with unified logging
  * Remove magic numbers and static strings
  * Use a single Track logs layer
  * Simplify building ranges in Attribute Form Definition
  * Search for use of forced unwrapping (!) and replace with try do catch
  * Search for array access by index and verify index in bounds
  * bad key in kvo access can crash app, review all cases of value(for:)
  * Cleanup Survey.saveAsArchive (use Futures<Void, Error>)

## Notes
  * Every object (struct/class/enum/etc) should be either:
    1) immutable data (struct/enum/tuple/primitive)
    2) an object with a well defined responsibility.
       - should have limited surface area for users to modify state
       - should have well defined methods/properties for modifying state
       - all user input should be validated and may throw
       - can answer questions based on current state (via functions or computed properties)
       - can publish changes in state to subscribers
