Park Observer 2.0 To Do List
============================

# Code

## Planned Features 1
User requested features I intend to implement.
  * Support "required" for form attributes; add validation message
  * Implement alarm control
  * Angle distance location option with north (not course) as the angular basis
  * Settings option to flip buttons map controls on bottom, survey controls on top

## Planned Features 2
Functionality I plan to implement for parity with Park Observer 1.0.
  * Multi-line text fields
  * Add version# to settings (in footer or sub section)
  * File save conflict resolutions for survey
  * Survey Pick list should allow renaming
  * Add openURL to SceneDelegate
    - Open map, protocol, archive by "Add to App"
    - Respond to errors: cancel, replace, keep both
    - Prompt for follow-ons: Unpack archive?, new survey from protocol?; load survey? load map?
    - create file associations so email, safari, files and other apps will launch PO with URL
    - Alerts on contentView for use by SceneDelegate openUrl

## Planned Features 3
New functionality I want to implement.
  * Change footer in file pick lists when there are no files
  * Allow multiple error messages in VStack with ForEach. Close button to hide all or hide individuals
  * Feature selector should use map label when defined
  * Group features by type on the feature Selector view.
  * Edit form should get focus when displayed (and editable)
  * Get MapInfo data from user and encode in a json file.
  * GPS Settings in User Settings View
  * Format CSV per protocol definition
  * User setting for turning on/off display of gps points and/or track logs
  * User setting for hit test area (small:11, medium:22, large:44) - default medium
  * swipe to close slide out view
  * dynamic sized text in scale bar
  * Add a graphic for the observers location (set symbology in mission)
  * Add info button to protocol pick list to show protocol file structure
  * Add info button to survey pick list to show protocol info and feature counts/dates
  * Add progress view to survey pick list item while archiving.

## Bugs and broken features

### Critical
These create errors in stored data or limit required functionality.
  * In SurveyController.slideoutcloseactions if selector was shown, then check each item in selectedObservations for changes and save as needed.
  * Fix Angle Distance Section - Needs to use helper (and give initial focus) when creating new AD location
    - make sure angles and distances are within reasonable ranges (i.e. distance > 0) angles -180 -> 180 or 0 -> 360
  * Angle Distance graphics do not move when angle/distance edits are saved
  * Move to GPS does not work without a track log - Fix for Presenter needing GPS from Controller
  * Move to GPS does not appear to work with a track log (however reload the survey and it is moved)
  * Move to GPS while creating a new touch observation starts a new observation,
    and does not appear to move observation (although reload shows it moved).
  * Hide/Disable weather button as appropriate;
  * Fix Bug - able to create MP (weather button) without track log in Test Protocol 2 (requires track log)
  * optional track logging and observing is only partially implemented
  * Turning off background track logging (in settings) while track logging does not take effect until the track log is closed.
  * Totalizer has a number of issues:
    - Start observing resets the totalize counts.
    - Counts did not appear consistent or correct (increasing not observing while observing)
    - The tracked field sometimes showed correctly, but sometimes appeared as "??"

### Nice to fix
These are obvious errors that can be worked around or ignored.
  * Sometimes a label does not display for a cabin in test protocol 2.  In consistent and not repeatable.
  * First text entry after launch disappears from form's text box,
    but is saved (and shows in label and subsequent edits).  Steps to repeat:
      1) quit app. open test protocol 2 survey. start track log, start transect (no edits). tap map to add cabin. tap in name field, enter name, hit enter, text disappears. now all text box edits work correctly
      2) quit app. open test protocol 2 survey. start track log, start transect (make text box edit). Edit disappears.  subsequent edits work.
  * Settings - background track log toggle needs to abide by authorization
    - Control should be hidden if user had explicitly rejected Always
    - may be impossible to determine, since In Use is used when Not asked, or asked and denied
  * User can provide a unique value renderer for track logs and or gps points,
    but graphics do not have the necessary attributes
  * Check that user provided range on numbers have lower < upper
  * Selecting the most recent Mission Property (for default) does not consider adhoc locations
  * Slide out View does not check width on rotation
  * Refresh file views when they are re-shown
  * Safe area on device with safe area mucks with styling of slide out view

### Annoying
These relate to rarely used or potential functionality.
  * encode(AnyJSON(agsRenderer.toJSON())) converts 0 to false, so result is no longer valid on read


## Code Issues
Maintainability issues in the code that are generally invisible to the user.
  * ObservationPresenter is creating a retain cycle
  * Create doc strings for all public members
  * Cleanup SurveyController - Break into testable components
  * Refactor Filesystem around appFile
  * Replace print statements with unified logging
  * Remove magic numbers and static strings
  * Use a single Track logs layer
  * Simplify building ranges in Attribute Form Definition
  * search for use of forced unwrapping (!) and replace with try do catch
  * search for array access by index and verify index in bounds
  * bad key in kvo access can crash app, review all cases of value(for:)
  * Cleanup Survey.saveAsArchive (use Futures<Void, Error>)

## Questions
Implementation issues than need additional consideration.
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

## Omitted features
Features from Park Observer 1.0 I don't plan to implement, unless requested.
  * Browse and download tile caches (*.tpk) from akrgis.nps.gov
  * Browse and download protocol files (*.obsprot) from akrgis.nps.gov
  * Upload surveys to akrgis.nps.gov (sync to server)
  * Email CSV/survey
  * Show detailed survey/protocol/location info
  * Map Target and add location at target feature (target visibility could be limited to as needed)
  * Analytics/crash logging service
  * Thumbnails for maps

## Feature Ideas
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


# Testing

## Unit Testing
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

## UI (or interactive) Testing
  * Test Gps failure condition and correct resumption of data collection
  * Test computed and multi-value labels
  * Test the size of form controls when large dynamic fonts are used
  * Test lists of features addable with/without touch based on state of config/trackLogging/observing
  * Test switch to background mode when creating a new observation (may request GPS in foreground and get it in background)


# Documentation
  * Post new specs and schema to existing website.
  * Edit/Cleanup the Park Observer 2.0 section of specs in the new project
  * Create Readme.md and license file for gitHub
  * Review Issues in old Park Observer; add to to do list, or create new Issues
  * Review bug fixes in version change documents in website/downloads; add to Issues
  * Contributing guidelines - step by step processes for:
    - fixing bugs
    - adding features
    - publishing new versions


# Notes
  * Every object (struct/class/enum/etc) should be either:
    1) immutable data (struct/enum/tuple/primitive)
    2) an object with a well defined responsibility.
       - should have limited surface area for users to modify state
       - should have well defined methods/properties for modifying state
       - all user input should be validated and may throw
       - can answer questions based on current state (via functions or computed properties)
       - can publish changes in state to subscribers
