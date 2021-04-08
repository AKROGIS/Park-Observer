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
  * User setting for turning on/off display of gps points and/or track logs
  * User setting for hit test area (small:11, medium:22, large:44) - default medium
  * Highlight the selected feature(s)
  * Add a graphic for the observers location (set symbology in mission) - New option in protocol file
  * If GPS is denied when starting a track log or adding a feature, then raise "Go to settings" alert
  * Change footer in file pick lists when there are no files
  * Get MapInfo data from user and encode in a json file.
  * Format CSV per protocol definition
  * Dynamic sized text in scale bar

## Considering
Potential features than need additional consideration.
  * For gps-intervals greater than a few seconds, set a timer, and only turn on the GPS when the timer goes off.
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
  * Deprecation warning for locationManager autorization status in iOS14.
  * Deprecation warning for testing in iOS14
  * A specific attribute survey crashes app (EXC_BAD_ACCESS) in apple coredata code when closing survey
    I can still load it, edit it and save it without problem.

## Nice to fix
These bugs can be worked around or ignored.
  * Defaults for when to display of the edit dialog is confusing for some combinations of the tracklogs/transects properties.
  * When waiting on GPS (i.e. exceeds allowable error), hide edit, show cancel, disallow save.
  * Canceling a mission property dialog when launched from tracklogging or observing button does not cancel operation only attribute editing.
  * Getting the most recent Mission Property (for default) from database does not consider adhoc locations
  * Problem with Mission Properties with required values and no editing on start tracklog (values will be null)
  * When editing multiple features, if one has validation errors when you decide to move another feature, the validation interrupts the move
  * When exporting, the export date is updated before we know if the export succeeds.  If it fails, we need to undo the export date.
  * When returning from background addGpsLocation can be called from cache and from locationManager out of order
  * Chaos may ensue if the user does not tap on the map when "Moving to map location"; start modal mode?
  * Slide out view does not check width on device rotation (limit to maxWidth as % of screenwidth)
  * Refresh the current file list if the slide out is hidden and re-shown
  * Alarm does not play alert sound when app is active
  * Add notice to turn on notification in settings if denied for alarm setting
  * User can provide a unique value renderer for track logs and or gps points, but graphics do not have the necessary attributes
  * The safe area (on devices with safe area - iPhone X and 11) mucks with styling of slide out view
  * Mission Properties are not created when start/stop observing, and tracklog = none
  * The default mission property "display editor" properties are not appropriate for all cases (i.e. tracklog = none)
  * ObservationPresenter/Selector title needs to be updated if the feature has a label field and it is edited.
  * Doubt that .ignoresSafeArea() is being used correctly on modern devices and with keyboard appearance.

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
  * In iOS 14.0 and 14.1 the TextField (including Decimal and Int Text boxes) in View/SlideOutViews/AttributeFormView.swift
    no longer works. Every new character is erased after entry (but last character typed is added to the text when focus is lost).
    This bug did not exist in iOS 13.x and was fixed in iOS 14.2+


# Documentation

  * Finish Documentation/Protocol Guide.md
  * Finish Documentation/Contributing.md
  * Finish website help/index.md
  * Finish website help/user_guide.md


# Change Log

## Beta7
  * Removed 10 character limit on feature names in protocol file.

## 2021-03-29 Beta6
  * Add minimum height to multiline text fields to prevent collapsing to zero height in attribute form.
  * Rebuilt with a new developer profile, (expires 3/29/2022)

## 2021-02-18: Beta5
  * Improve clarity of error message when survey does not load.
  * Fixed bug for incorrect drawing of compass rose button on iOS 14.0.
  * Fixed bug where DecimalEntry incorrectly added a stepper when the attribute type was an Int16/Int32/Int64.
  * DecimalEntry with fractionDigits = 0 now correctly display no decimals instead of 6.
  * Upgraded to version 100.10.0 of the esri ArcGIS Runtime API for iOS.
  * Upgraded to the new basemap styles in version 100.10
  * Fix iOS 14 issue with keyboard appearance shrinking height of slideout menu
  * Fix iOS 14 multiline text field
  * Fix iOS 14 bug where tristate toggle would only change between nil and On (could not set to Off).
  * Fix Bug that required fractiondigits = 0 with DecimalEntry with attribute type of Int. No franctionDigits = 0 is assumed
    Other values are ignored - could be an error, but I decided otherwise.

## 2020-09-04: Beta4

  * Added an option in the protocol file to specify label for the start/stop observing button (i.e. "Survey", "Transect").
  * Replaced "Mission Properties" with "{observing label} Info", e.g. "Survey Info" in attribute editor.
  * Protocol property dialog.title was not used, so it is now optional in the protocol file.
  * Fixed bug: protocol feature.label.field must **case_sensitive** match one of feature.attribute.name.
  * Allow protocol with label definition and no attributes (label could be a constant).
  * Removed second vertical accuracy line from GPS details form.
  * Do not show mission property button or editor when no mission or mission.attributes defined in protocol.
  * Fixed bug where gps points, mission property points and track logs did not draw on map when there was no mission defined in protocol.
  * Fixed bug where features with no dialog were not added to map at map touch (when multiple allowed).
  * Fixed bug where protocol date in list was 1 day earlier than the date in the protocol details view.
  * Fixed bug where totalizer shows ?? for field value for the first tracklog in a survey even after setting the field value.
  * Fixed bug where the info message "touch map to move observation" disappears when track logging.
  * Added capability to have multiple error/warning and info messages at the same time.
  * Improve contrast in error(red), warning(yellow), and info(green) messages.
  * Fixed text alignment in *Add feature at GPS button* with larger (accessible) fonts

## 2020-08-21: Beta3

  * On first launch the app selects an online map for the default.
  * On first launch the app creates a sample survey and set it as the default.
  * Fixed a bug that failed to update labels and symbology when changing attributes from null to non-null
  * Fixed a display glitch with the disclosure angle for the details view in survey and protocol lists.
  * Fixed a bug where the editor was not presented when creating a new feature at the map touch location.
  * Fixed a bug where the track log properties editor was not displayed at the proper times.
  * Add default limits of 0..100 on the stepper control (for legacy compatibility).
  * Disable the save button when there are no changes.
  * Fixed a bug where mission properties at touch location were incorrectly drawn at the gps location.
  * Now if you tap to select multiple features, and then delete one, it is removed from the list of selected
    features.
  * The undo button while editing the survey name was confusing. It is now a "clear text" button and
    a new undo button was added.
  * Made the totalizer and info banner more visible
  * Made the totalizer with fields behave like the old Park Observer (shows total for entire survey not just
    current track log)
  * The feature selector/presenter now shows the feature id in the title.
  * Added support for the gps_interval property in the protocol file
  * Provided user settings for GPS filters: accuracy, distance, and duration.

## 2020-08-14: Beta2

  * Fixed bugs in totalizer.
  * Fixed bug with disabling background track logging.
  * Added alarm interval to settings.
  * Added "required" property to attributes. UI Forces user to provide non-null attribute value.
  * Added "azimuth/distance" option to location methods (angle is relative to north, not course).
  * Fixed bugs with angle/distance forms (start with null, make required and validate).
  * App shows a warning when angle is behind you (based on course; only for angle/distance).
  * Made the [github repo](https://github.com/AKROGIS/Park-Observer) public.
  * Added user setting to put attribute buttons on top of form (instead of bottom).
  * Added confirmation alert when deleting an observation.
  * Added an optional time and location of observation to the attribute form.
  * Added support for editing survey names.
  * Added form showing details/structure of survey protocol.
  * Added form showing details of the survey.
  * Survey protocol files and archives can now be opened with Park Observer from email and files app (however
    there is no UI yet).

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
  * Test lists of features addable with/without touch based on state of config/trackLogging/observing
  * Test switch to background mode when creating a new observation (may request GPS in foreground and get it in background)

## Code Cleanup
Maintainability issues in the code that are generally invisible to the user.
  * Cleanup SurveyController
  * SurveyController should listen to ObservationPresenter.awaitingGPS then trigger Async GPS request.
  * Fix timestamp property in ObservationPresenter (should be optional, but ObservationSelectorView doesn't like that)
  * Cleanup handling of error messages in ObservationPresenter
  * ObservationPresenter is creating a retain cycle (break at end of SurveyController.observing didSet)
  * Refactor to reduce testing dependant on CoreData
  * Create doc strings for all public members
  * Replace print statements with unified logging
  * Remove magic numbers and static strings
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
