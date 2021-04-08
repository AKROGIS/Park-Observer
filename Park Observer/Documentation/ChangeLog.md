# Change Log

The official change log is in the
[git commit history](https://github.com/AKROGIS/Park-Observer/commits/master).
This is a user facing summary for publishing on the website.  Newest changes
are at the top. The first group is always the current list of unpublished
changes, so it has no date. The date is the date that release was published.

## Unpublished Changes

* Removed 10 character limit on feature names in protocol file.

## 2021-03-29 Beta6

* Add minimum height to multiline text fields to prevent collapsing to zero
  height in attribute form.
* Rebuilt with a new developer profile. Expires 3/29/2022, previous betas
  expired 3/17/2021.

## 2021-02-18: Beta5

* Improve clarity of error message when survey does not load.
* Fixed bug for incorrect drawing of compass rose button on iOS 14.0.
* Fixed bug where DecimalEntry incorrectly added a stepper when the attribute
  type was an Int16/Int32/Int64.
* DecimalEntry with fractionDigits = 0 now correctly display no decimals instead
  of 6.
* Upgraded to version 100.10.0 of the esri ArcGIS Runtime API for iOS.
* Upgraded to the new base map styles in version 100.10.
* Fix iOS 14 issue with keyboard appearance shrinking height of slide out menu.
* Fix iOS 14 multiline text field.
* Fix iOS 14 bug where tristate toggle would only change between nil and On
  (could not set to Off).
* Fix Bug that required fractionDigits = 0 with DecimalEntry with attribute type
  of Int. No fractionDigits = 0 is assumed. Other values are ignored - could be
  an error, but I decided otherwise.

## 2020-09-04: Beta4

* Added an option in the protocol file to specify label for the start/stop
  observing button (i.e. "Survey", "Transect").
* Replaced "Mission Properties" with "{observing label} Info", e.g.
  "Survey Info" in attribute editor.
* Protocol property dialog.title was not used, so it is now optional in the
  protocol file.
* Fixed bug: protocol feature.label.field must **case_sensitive** match one of
  feature.attribute.name.
* Allow protocol with label definition and no attributes (label could be a
  constant).
* Removed second vertical accuracy line from GPS details form.
* Do not show mission property button or editor when no mission or
  mission.attributes defined in protocol.
* Fixed bug where gps points, mission property points and track logs did not
  draw on map when there was no mission defined in protocol.
* Fixed bug where features with no dialog were not added to map at map touch
  (when multiple allowed).
* Fixed bug where protocol date in list was 1 day earlier than the date in the
  protocol details view.
* Fixed bug where totalizer shows ?? for field value for the first track log in
  a survey even after setting the field value.
* Fixed bug where the info message "touch map to move observation" disappears
  when track logging.
* Added capability to have multiple error/warning and info messages at the same
  time.
* Improve contrast in error(red), warning(yellow), and info(green) messages.
* Fixed text alignment in *Add feature at GPS button* with larger (accessible)
  fonts.

## 2020-08-21: Beta3

* On first launch the app selects an online map for the default.
* On first launch the app creates a sample survey and set it as the default.
* Fixed a bug that failed to update labels and symbology when changing
  attributes from null to non-null.
* Fixed a display glitch with the disclosure angle for the details view in
  survey and protocol lists.
* Fixed a bug where the editor was not presented when creating a new feature at
  the map touch location.
* Fixed a bug where the track log properties editor was not displayed at the
  proper times.
* Add default limits of 0..100 on the stepper control (for legacy compatibility).
* Disable the save button when there are no changes.
* Fixed a bug where mission properties at touch location were incorrectly drawn
  at the gps location.
* Now if you tap to select multiple features, and then delete one, it is removed
  from the list of selected features.
* The undo button while editing the survey name was confusing. It is now a
  "clear text" button and a new undo button was added.
* Made the totalizer and info banner more visible.
* Made the totalizer with fields behave like the old Park Observer (shows total
  for entire survey not just current track log).
* The feature selector/presenter now shows the feature id in the title.
* Added support for the gps_interval property in the protocol file
* Provided user settings for GPS filters: accuracy, distance, and duration.

## 2020-08-14: Beta2

* Fixed bugs in totalizer.
* Fixed bug with disabling background track logging.
* Added alarm interval to settings.
* Added "required" property to attributes. UI Forces user to provide non-null
  attribute value.
* Added "azimuth/distance" option to location methods (angle is relative to
  north, not course).
* Fixed bugs with angle/distance forms (start with null, make required and
  validate).
* App shows a warning when angle is behind you (based on course; only for
  angle/distance).
* Made the [github repo](https://github.com/AKROGIS/Park-Observer) public.
* Added user setting to put attribute buttons on top of form (instead of bottom).
* Added confirmation alert when deleting an observation.
* Added an optional time and location of observation to the attribute form.
* Added support for editing survey names.
* Added form showing details/structure of survey protocol.
* Added form showing details of the survey.
* Survey protocol files and archives can now be opened with Park Observer from
  email and files app (however there is no UI yet).

## 2020-08-07: Beta1

* First public release.
