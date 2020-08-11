Park Observer 2.0 To Do List
============================

# Features

## Priority 1
User requested features I intend to implement.
  * Add optional "required" property for form attributes; add validation message

## Priority 2
Functionality I plan to implement for parity with Park Observer 1.0.
  * Survey pick list should allow renaming the survey
  * Support opening obsprot/archive/map from email, browser or the files app
  * Warn when deleting observation

## Priority 3
New functionality I want to implement.
  * User (and/or protocol) settings for GPS accuracy and frequency (time and/or distance)
  * Change footer in file pick lists when there are no files
  * Allow multiple concurrent messages. Close button to hide all or hide individuals
  * Feature selector should use map label when defined
  * Group features by type on the feature Selector view.
  * Edit form should get focus when displayed (and editable)
  * Get MapInfo data from user and encode in a json file.
  * Implement GPS Settings in settings view
  * Format CSV per protocol definition
  * User setting for turning on/off display of gps points and/or track logs
  * User setting for hit test area (small:11, medium:22, large:44) - default medium
  * Swipe to close slide out view
  * Dynamic sized text in scale bar
  * Add a graphic for the observers location (set symbology in mission)
  * Add info button to protocol pick list to show protocol file structure
  * Add info button to survey pick list to show protocol info and feature counts/dates
  * Add progress view to survey pick list item while archiving.
  * Add warning when angle is outside range of deadAhead +/- 90°
  * Add configuration option to choose "Survey" or "Transect" for the observing button

## Considering
Potential features than need additional consideration.
  * Next button on the keyboard? navigation between form elements?
  * Differentiate the two stop buttons?
  * Can a user easily refresh the graphics if needed? What about 1 survey, and 1 map 
  * Split track logs at 1000 vertices?
  * Warn when deleting archives?
  * Scale bar fade in/out after zoom?
  * Color the add observation button to match observation symbology?
  * Provide button to show map legend?
  * After importing a survey prompt to make survey active?
  * After creating a new survey prompt to make active?
  * Revisit database schema - explore schema migration

## Potential
Features ideas open for discussion, but no plans/time to implement.
  * Display "Getting Started" screens if first launch
  * Support general form validation (Issue #61) i.e. sum of count calfs + males + females > 0
  * Add a observation attribute type for a sketch-able geometry.
    The underlying storage would be a WKTString describing the line or polygon.
  * Support selecting and editing track logs (via associated map properties)
  * Add audio clips to observations
  * Add photo points, and camera button to UI
  * Companion app to build protocol files
  * Calculated fields
  * Static vs. dynamic mission properties (static at start track logging, mission properties at weather/start observing)
  * Move mission property points (snap to a gps point)
  * Delete mission property points
  * Browse and download tile caches (*.tpk) from ArcGIS Online
  * Browse and download protocol files (*.obsprot) from GitHub
  * Protocol V3 - complete re-write.
  * Hi speed KIMU interface. Coded string like a180d100k4w which is decoded into the appropriate attributes
  * Load feature classes like nests or transects and use the attribute (nest ID or transect ID) of
    the closest feature to populate observation (NOTE: much easier to do in post processing)

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
  * When returning from background addGpsLocation can be called from cache and from locationManager out of order
  * Sometimes a label does not display for a cabin in test protocol 2.  Inconsistent and not repeatable.
  * First text entry after launch disappears from form's text box,
    but is saved (and shows in label and subsequent edits).  Steps to repeat:
      1) quit app. open test protocol 2 survey. start track log, start transect (no edits). tap map to add cabin. tap in name field, enter name, hit enter, text disappears. now all text box edits work correctly
      2) quit app. open test protocol 2 survey. start track log, start transect (make text box edit). Edit disappears.  subsequent edits work.
  * Settings - background track log toggle needs to abide by authorization
    - Control should be hidden if user had explicitly rejected Always
    - may be impossible to determine, since In Use is used when Not asked, or asked and denied
  * Add notice to turn on notification in settings if denied for alarm setting
  * User can provide a unique value renderer for track logs and or gps points,
    but graphics do not have the necessary attributes
  * Check that user provided range on numbers have lower < upper
  * Getting the most recent Mission Property (for default) from database does not consider adhoc locations
  * Slide out view does not check width on device rotation
  * Refresh the current file list if the slide out is hidden and re-shown
  * Safe area on device with safe area mucks with styling of slide out view
  * Action Sheets on iPad do not show up in correct location (especially for items at bottom of file list) - Apple Bug (https://stackoverflow.com/q/61676063/542911)
  * TextFields do not fix their display (per the formatter) until return is pressed (losing focus is not enough);
    - The bindings are good (they represent the last valid value (per the formatter), not the value in the text box).
  * When exporting, the export date is updated before we know if the export succeeds.  If it fails, we need to undo the export date.
  * Need to be able to delete status messages when they no longer apply.
  * Banner should stand out more; Maybe the background should be less transparent not full width.
    - maybe next to the scalebar on the ipad (below/above) on the iPhone
  * Alarm does not play alert sound when app is active
  * If you delete a feature from the selector, it should be removed from the selector list

## Annoying
These bugs are related to potential functionality (so while incorrect, they have no impact yet).
  * encode(AnyJSON(agsRenderer.toJSON())) converts 0 to false, so result is no longer valid on read


# Documentation
  * Create Readme.md and license file for gitHub
  * Post new specs and schema to existing website.
  * Edit/Cleanup the Park Observer 2.0 section of specs in the new project
  * Create a simple how to document with screenshots
  * Contributing guidelines - step by step processes for:
    - fixing bugs
    - adding features
    - publishing new versions


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
  * Put all TODOs into this document
  * Refactor Filesystem around appFile
  * Cleanup SurveyController
  * Refactor to reduce testing dependant on CoreData
  * ObservationPresenter is creating a retain cycle (break at end of observing didSet)
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
