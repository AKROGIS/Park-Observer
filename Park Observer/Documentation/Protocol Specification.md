Protocol Specification -- 2.0
=============================

*This document is for Park Observer 2.0.  If you are still using Park Observer 1.x
please see [this version](Protocol_Specification_V1.html).* 

*If you are new to Park Observer, please start with the
[help documents](../help2) and [example protocols](../protocols2/).*

This document is a technical reference for the structure and accepted content of the
Park Observer protocol file,
A more general reference can be found in the [Protocol Guide](Protocol_Guide_V2.html)

This specification describes version 1 (v1) and 2 (v2) of the protocol file.
Items that were introduced in version 2 are marked (v2).
Since most of the items introduced in v2 are optional and do not conflict with
v1, Park Observer will honor v2 items even if found in a v1 file.
Symbology is a notable exception and will be discussed in detail.
For clarity you are encouraged to use a v2 protocol file (defined below) when using v2 items.

The protocol file is a plain text file in `JSON` (javascript object notation) format.
The file typically contains only `ASCII` characters.
If special characters (accents marks, emoji, etc.) are needed, the file must be encoded in `UTF8`.
The protocol file name must end with `.obsprot`, which is short for observation protocol.

A protocol file contains one JSON object.
An object begins with an opening curly bracket (`{`) and ends with an closing curly bracket (`}`)
An object is a list of properties (name-value pairs) separated by a comma(`,`).
Property names must be enclosed in double quotes (`"`) and are case sensitive.
A colon (`:`) separates the property name from the property value.
A property value can be an object, a text string enclosed in double quotes (`"`),
a number, or one of the special symbols: `true`, `false`, and `null`.
A property value can also be a list of property values.
A list begins with an opening square bracket (`[`), and ends with a closing square bracket (`]`).
Items in the list are separated by a comma (`,`).

The official specifications of the JSON file format can be found at http://www.json.org/.
The JSON file format is very specific and it is easy to introduce errors when editing by
hand.  There are a number of online JSON linters (e.g. https://jsonlint.com) that will
check your protocol file to ensure it is valid JSON.  Most linters will also provide suggestions
for how to fix invalid JSON.

A JSON linter will only check for valid JSON, it will not check for compliance with
this document. For that you will need to use a Schema Validator.
This specification is also defined in a machine readable form in
[`protocol.v1.schema.json`](protocol.v1.schema.json)
and [`protocol.v2.schema.json`](protocol.v2.schema.json).
These schemas are also JSON files in the
[JSON Schema](http://json-schema.org/) format.
These schema files can be used to validate a protocol file to ensure that it is not just valid
JSON, but meets the requirements of this specification.
One example of an online validator is https://www.jsonschemavalidator.net.

**IMPORTANT:**
This specification and the related schema documents, define the proper format of the
`obsprot` file.  It is possible that the implementation in Park Observer is more relaxed.
For example Park Observer might provide default values when a required value is missing,
or accept different spellings, but that behavior is subject to change without notice.

Starting with Park Observer 2.0, creating a new survey will use strict validation
rules on the `obsprot` file.  This may cause the survey creation to fail, even though
an existing survey will still load with the same `obsprot` file. An `obsprot` file that
fails validation must be corrected before it can be used in a new survey.

The JSON object in the protocol file understands properties with the following names.
Properties can appear in any order, but usually in the order shown.
Properties marked with an (o) are optional; the others are required.

* [`meta-name`](#-meta-name-)
* [`meta-version`](#-meta-version-)
* [`name`](#-name-)
* [`version`](#-version-)
* [`date`](#-date-) (o)
* [`description`](#-description-) (o)
* [`observing`](#-observing-) (o)(v2)
* [`notobserving`](#-notobserving-) (o)(v2)
* [`status_message_fontsize`](#-status_message_fontsize-) (o)(v2)
* [`cancel_on_top`](#-cancel_on_top-) (o)(v2)
* [`gps_interval`](#-gps_interval-) (o)(v2)
* [`tracklogs`](#-tracklogs-) (o)(v2)
* [`transects`](#-transects-) (o)(v2)
* [`transect-label`](#-transect-label-) (o)(v2)
* [`mission`](#-mission-) (o)
* [`features`](#-features-)
* [`csv`](#-csv-) (o)

Each of these properties are defined in the following sections.

# `meta-name`
This property is required and must be a string equal to `"NPS-Protocol-Specification"`.
This property designates the file as subscribing to these specifications.

# `meta-version`
This property is required and must be an integer.
This property designates the version of the specification defining the content of the protocol file.
At this time, the only valid values are `1` and `2`.
Version `1` has been deprecated.

# `name`
This property is required and must be a string.
This is a short moniker used to reference this protocol.
It will be used in lists to choose among different protocols.

Names do not need to be unique, but having two protocols with the same name can cause confusion.
Protocols can evolve (see [`version`](#-version-) and [`date`](#-date-)).
The same name should be used for different version of the same protocol.

Technically, a name is not required by the Park Observer application.
However, the post processing tools (like the POZ to FGDB translator) require a name.
A protocol without a name is very hard to work with.

# `version`
This property is required and must be a number.
The version number looks like a floating point number (i.e. `2.1`)
but is actually two integers separated by a decimal point.
The first integer is the major version number the second integer is the minor version number.
The version number is used to track the evolution of a named protocol.
The version number will be displayed along with the name when presenting a list of protocols.

A change in the major version number represents a change in the database structure of the protocol.
If you add, remove, rename, or change the type of mission or feature attributes (defined below),
then you should update the major version number of your protocol.
Databases created with the post-processing tools will be named with the protocol name and the major version number.
All surveys with the same protocol name and major version number can go into the same database.
Surveys with the same protocol name and a different major version number will go into different databases.
Databases created with different major version numbers of the same protocol will be difficult
to merge because the database structure is different.

Any other changes to a protocol should be accompanied by an increase in the minor version number.
For example, changes in symbology, location methods, and default or pick list values.

Technically, a version is not required by the Park Observer application.
However, the post processing tools require a major version number.
A protocol without a version number is easily confused with other protocols with the same name.

Because the major/minor version is a single number in the JSON file, the minor version number is
limited to the range 0..9.  This is due to the fact that 1.20 is the same number as 1.2, so the
minor number in both cases will be 2.  There is no limit to the major version.

# `date`
This property is optional. There is no default value.
If provided it must be a string that represent the date (but not time)
in the ISO format `YYYY-MM-DD` (e.g. `"2016-05-24"`).
This should be the date that the protocol file was last modified.
If provided, the date will be used in lists to help choose among different protocols.
If the date is missing, the wrong type, or an invalid date,
then the Park Observer will consider the date unknown.

# `description`
This property is optional. If provided it must be a string. There is no default value.
The description can be used to provide more information about the protocol than is available
in the protocol name.nIt typically describes who wrote the protocol and which surveys or
organizations it supports. Contact information can also be included.

# `observing`
This property is optional. If provided it must be a string. There is no default value.
If a non-empty string is provided it will be displayed on the map when the Park Observer
application is recording __and__ observing (i.e. on-transect).

This property is ignored in versions of Park Observer before 0.9.8b.

# `notobserving`
This property is optional. If provided it must be a string. There is no default value.
If a non-empty string is provided it will be displayed on the map when the Park Observer
application is recording __but not__ observing (i.e. off-transect).

This property is ignored in versions of Park Observer before 0.9.8b.

# `status_message_fontsize`
This property is optional. If provided it must be a positive number. The default is `16.0`.
This property specifies the size (in points, i.e. 1/72 of an inch) of
the `notobserving` and `observing` text.

This property is ignored in versions of Park Observer before 1.2.0.
Starting with Park Observer 2.0.0 this property is ignored.  The font
size is determined by the standard system font which can be managed with
the settings app. 

# `cancel_on_top`
This property is optional.  If provided it must be `true` or `false`. The default is `false`.
If `true` the attribute editors will put the buttons (Cancel, Delete, Move, Save, ...) on the
top of the attribute editing forms, otherwise the button will be on the bottom of the form.

This property is ignored in versions of Park Observer before 0.9.8b.
Starting with Park Observer 2.0.0, this property is ignored.  It can be set by the
user in the settings.

# `gps_interval`
This property is optional.  If provided it must be a positive number.  There is no default.
The property is the number of seconds to wait between adding new GPS points to the track log.
When making observations, or starting/stopping recording/observing the most recently available
GPS point will be used regardless of this setting.
If omitted, or not a positive number, GPS points are added to the track log as often as provided
by the GPS device being used.  Typically the iPad's builtin GPS provides locations about 1 per second.
Some external GPS devices can provide multiple locations per second.
A number lower than the device can support will effectively be ignored.
Using an interval greater than the GPS can support may reduce battery consumption by allowing the GPS to rest.

This property is ignored in versions of Park Observer before 0.9.8b.

# `tracklogs`
This property is optional. If provided it must be one of the following stings.  The default is `"required"`.
This property determines if a track log is desired or required.

This property is ignored in versions of Park Observer before 2.0.

 * `"none"` - The start/stop track log button is not available, and track logs are never collected.
 * `"optional"` - The user can start/stop observing regardless of the state of track logging.
 * `"required"` - The user must start a track log before they can start observing.

# `transects`
This property is optional. If provided it must be one of the following stings.  The default is `"per-feature"`.
This property determines the requirements for making an observation.
If `tracklogs` is `"required"`, then observations can only be made when track logging despite the state
of this property.

This property is ignored in versions of Park Observer before 2.0.

 * `"none"` - The start/stop survey (observing/transect) button is not available;
   It is assumed that the user is always observing, and observations can be made any time
   This sets the `allow_off_transect_observations` property of all features to `true`
 * `"optional"` - The user can add an observation at any time, regardless of the state of surveying (observing/transect).
   This sets the `allow_off_transect_observations` property of all features to `true`
 * `"required"` - The user must start a survey (observing/transect) before they can add an observation.
   This sets the `allow_off_transect_observations` property of all features to `false`
 * `"per-feature"` - The user can add an observation of a feature based on the state of the feature's
   `allow_off_transect_observations` property.


# `mission`

This property is optional.  If provided it must be an object.  There is no default.
This object describes the attributes and symbology of the survey mission.
The attributes are things that may be constant for the entire survey, i.e. observer name, as
well as dynamic attributes like the weather that may apply to many observations.
It also describes the look and feel of the editing form and when the attributes should be edited.

A `mission` object has the following properties:

* [`attributes`](#-mission-attributes-) (o)
* [`dialog`](#-mission-dialog-) (o)
* [`edit_at_start_recording`](#-mission-edit_at_start_recording-) (o)(v2)
* [`edit_at_start_first_observing`](#-mission-edit_at_start_first_observing-) (o)(v2)
* [`edit_at_start_reobserving`](#-mission-edit_at_start_reobserving-)(o)(v2)
* [`edit_prior_at_stop_observing`](#-mission-edit_prior_at_stop_observing-) (o)(v2)
* [`edit_at_stop_observing`](#-mission-edit_at_stop_observing-) (o)(v2)
* [`symbology`](#-mission-symbology-) (o)
* [`on-symbology`](#-mission-on-symbology-) (o)
* [`off-symbology`](#-mission-off-symbology-) (o)
* [`gps-symbology`](#-mission-gps-symbology-) (o)(v2)
* [`totalizer`](#-mission-totalizer-) (o)(v2)

Each of these properties are defined in the following sections.

## `mission.attributes`
An optional list of `attribute` objects.
Both `mission`s and `feature`s can have a list of `attribute` objects.
The attributes are descriptive characteristics for each segment of the survey.
A mission with no attributes only collects the location where the the user
stopped and started observing (i.e. went on/off transect). The mission
attributes are often things like the names of the observers, and the weather.

All the attributes default to a value of `null` until they are edited.
The exception is the `id` attribute which starts at `1` and increments by `1` for each each observation.
The `id` attribute can provide each observation with an automatic, unique, and sequential identifier.
All attributes, except the `id` will never change unless you also have a `dialog` property.

If there is an attribute list then there must be at least one valid `attribute` object in it.
Each `attribute` has the following properties:

* [`name`](#-attribute-name-)
* [`type`](#-attribute-type-)
* [`required`](#-attribute-required-) (o)(v2)

### `attribute.name`
A required string identifying the attribute.  This will be the name of the column in an exported
CSV file, or a field in an ArcGIS geo-database.
The name must start with a letter or underscore (`_`), and be followed by zero or more letters, numbers,
or underscores. It must be no longer than 30 characters.
Spaces and special characters are prohibited.
Each name must be unique within the mission or feature.
Different features can have attributes with the same name, but if they do they must have the same type.
Mission attributes and feature attributes are unrelated -- they can have the same name with different types.
**Important** Do not rely on upper/lowercase to distinguish two attributes;
`Species`, `species`, and `SPECIES` are the same attribute name.
However, the names in this protocol must
match in capitalization.  If you use `Species` in a `mission.totalizer` or a `feature.label`,
it must also be referred to as `Species` in the dialog element and `Species` in the attributes list.

### `attribute.type`
A required number that identifies the type (kind) of data the attribute stores.
The type must be an integer code with the following definitions.
These numbers (with the exception of 0) correspond with NSAttributeType in the iOS SDK.

-   0 -> sequential integer id (not editable, only available in v2)
-	100 -> 16bit integer
-	200 -> 32bit integer
-	300 -> 64bit integer
-	400 -> NSDecimal (currently not supported by esri)
-	500 -> double precision floating point number
-	600 -> single precision floating point number
-	700 -> string
-	800 -> boolean (converts to an esri integer; true => 1, false =>  0)
-	900 -> DateTime
-	1000 -> binary blob (not supported)

The type 0 is ignored in versions of Park Observer before 0.9.8.
Only one attribute can have a type of 0.

### `attribute.required`
This property is optional. If provided it must be `true` or `false`. The default is `false`.
If `true` then this attribute is required to have a value (i.e. null is not allowed).
The attribute editor will display a validation error when saving if this attribute
is null. The attribute editor will not close until validation errors are resolved,
or edits are aborted.  If an attribute is required, then it must have a
matching element in the dialog property (in order to provide a value)

This property is ignored in versions of Park Observer before 2.0.0.

## `mission.dialog`
This property is optional.  If provided it must be an object.  There is no default.
Both `mission`s and `feature`s can have a `dialog` object.
The dialog property describes the format of the editing form for the mission's attributes.
A dialog is not required, but the mission attributes cannot be edited without one.
If the dialog property is provided then the `attributes` property is required.
If a dialog is provided, there must be at least one section in the dialog and one element in each section.
All elements in the dialog except labels must refer to an attribute in the list of mission attributes.
It is an error if a dialog element refers to an attribute that is not in the list
or if the type of the attribute does not match the type of the dialog element.

A dialog is not required even if attributes are provided.
It is possible that the only attribute is a sequential Id which is
not editable and requires no dialog
It is possible that attribute list is defined to match an external database schema
but some of those attributes are not collected in the survey
(and do not have matching elements in the dialog).

 * [`title`](#-dialog-title-) (o)
 * [`grouped`](#-dialog-grouped-) (o)
 * [`sections`](#-dialog-sections-)

### `dialog.title`
This property is optional.  If provided it must be a string.  There is no default.
This text is placed as a title at the top of the editing form.

Starting with Park Observer 2.0, this property is ignored.
The text on the top of the attribute editor is set by the observation being edited.

### `dialog.grouped`
This property is optional.  If provided it must be a boolean.  The default is `false`.
Starting with Park Observer 2.0.0, this property has no effect (sections are visually distinct,
and `grouped` does not render any differently).

### `dialog.sections`
This property is required and must be a list of one or more `section` objects.
A dialog form is made up of one or more sections which group the editing controls
into logical collections. Each `section` object has the following properties.

* [`title`](#-dialog-section-title-) (o)
* [`elements`](#-dialog-section-elements-)

#### `dialog.section.title`
This property is optional.  If provided it must be a string.  There is no default.
This text is placed as a title at the top of the section.

#### `dialog.section.elements`
This property is required and must be a list of one or more `element` objects.
Elements make up the interesting parts of the form.  They are usually tied to an attribute
and determine how the attribute can be edited.  Examples of form elements are text boxes,
on/off switches, and pick lists. Each `element` has the following properties.  Some
properties are only relevant for certain types of elements.

 * [`title`](#-dialog-section-element-title-) (o)
 * [`type`](#-dialog-section-element-type-)
 * [`bind`](#-dialog-section-element-bind-) (o)
 * [`items`](#-dialog-section-element-items-) (o)
 * [`selected`](#-dialog-section-element-selected-) (o)
 * [`boolValue`](#-dialog-section-element-boolvalue-) (o)
 * [`minimumValue`](#-dialog-section-element-minimumvalue-) (o)
 * [`maximumValue`](#-dialog-section-element-maximumvalue-) (o)
 * [`numberValue`](#-dialog-section-element-numbervalue-) (o)
 * [`placeholder`](#-dialog-section-element-placeholder-) (o)
 * [`fractionDigits`](#-dialog-section-element-fractiondigits-) (o)
 * [`keyboardType`](#-dialog-section-element-keyboardtype-) (o)
 * [`autocorrectionType`](#-dialog-section-element-autocorrectiontype-) (o)
 * [`autocapitalizationType`](#-dialog-section-element-autocapitalizationtype-) (o)
 * [`key`](#-dialog-section-element-key-) (o)

##### `dialog.section.element.title`
This property is optional.  If provided it must be a string.  There is no default.
This is a name/prompt that names the data in this form element.  This usually appears to
the left of the attribute value in a different font. This is often the
only property used by an `element` with a `type` of `"QLabelElement"`.

##### `dialog.section.element.type`
This property is required and must be one of the following text strings.
It describes the display and editing properties for the form element.  Park Observer
only supports the following types.  These are case sensitive.

* `"QBooleanElement"` - an on/off switch, defaults to off.
* `"QDecimalElement"` - a "real" number editor with a limited number of digits after the decimal.
* `"QEntryElement"` - a single line text box.
* `"QIntegerElement"` - an integer input box with stepper (+/-) buttons.
* `"QLabelElement"` - non-editable text on its own line in the form.
* `"QMultilineElement"` - a multi-line text box.
* `"QRadioElement"` - A single selection pick list (as a vertical list of items in a sub form)
* `"QSegmentedElement"` - A single selection pick list (as a horizontal row of buttons)


##### `dialog.section.element.bind`
This property is required for all `type`s except `"QLabelElement"` (where it is optional).
If provided it must be a specially formatted string.  There is no default.
This string encodes the type and attribute name of the data for this element.
`"QLabelElement"` only uses the `"value:` bind value when
displaying a unique feature id.  The `bind` value must start with one of the following:

 * `"boolValue:` - a boolean (true or false) value
 * `"numberValue:`
 * `"selected:` - the zero based index of the selected item in `items`
 * `"selectedItem:`  - the text of the selected item in `items`
 * `"textValue:`
 * `"value:` - used for Unique ID Attributes (Attribute Type = 0)

and be followed by an attribute name from the list of attributes.
This will determine the type of value extracted from the form element,
and which attribute it is tied to (i.e. read from and saved to).
It is important that the type above matches the type of the attribute in
the attributes section.  Note that there must always be a colon (`:`) in the
bind string separating the type from the name. It is an error if the
attribute name in the bind property is not in the list of attributes.

##### `dialog.section.element.items`
This property is optional.  If provided it must be a list of one or more strings.  There is no default.
This property provides the list of choices for pick list type elements.
It is required for `"QRadioElement"` and `"QSegmentedElement"`, and ignored for all other types.

##### `dialog.section.element.selected`
This property is optional.  If provided it must be an integer.  There is no default.
If provided it sets the default value for the related attribute,
otherwise the default value is null (i.e. nothing is selected).
It is the zero based index of the default selection in the list of items.
If not provided, nothing is selected initially.

Protocol authors are discouraged from using this property to set an initial value,
as it causes confusion regarding whether the observer actually observed the default value,
or if the observer failed to make an observation (and it might not have been the default)
Having no default value will set the attribute to null if no observation was made.
If a default value is desired when there was no observation this can be done in post
processing without losing the fact that no observation was actually made.

##### `dialog.section.element.boolValue`
This property is optional.  If provided it must be an integer value of 0 or 1.  There is no default.
If provided it sets the default value for the related attribute
otherwise the default value is null (i.e. neither true nor false).
This property sets the default value for the `"QBooleanElement"`. It is ignored by all other types.

Protocol authors are discouraged from using this property to set an initial value,
see the discussion for [`selected`](#-dialog-section-element-selected-).

##### `dialog.section.element.minimumValue`
This property is optional.  If provided it must be a number.
This is the minimum value allowed in `"QIntegerElement"` or `"QDecimalElement"`.
The default is 0 if `type` is `"QIntegerElement"`, otherwise there is no default
and the minimum value is determined by the [`attribute.type`](#-attribute-type-).

##### `dialog.section.element.maximumValue`
This property is optional.  If provided it must be a number.
This is the maximum value allowed in `"QIntegerElement"` or `"QDecimalElement"`.
The default is 100 if `type` is `"QIntegerElement"`, otherwise there is no default
and the maximum value is determined by the [`attribute.type`](#-attribute-type-).

##### `dialog.section.element.numberValue`
This property is optional.  If provided it must be a number.   There is no default.
If provided it sets the default value for the related attribute.
This sets the initial value in `"QIntegerElement"` or `"QDecimalElement"`.

Protocol authors are discouraged from using this property to set an initial value,
see the discussion for [`selected`](#-dialog-section-element-selected-).

##### `dialog.section.element.placeholder`
This property is optional.  If provided it must be a text string.  There is no default.
This is the background text to put in a text box to suggest to the user what to enter.

##### `dialog.section.element.fractionDigits`
This property is optional.  If provided it must be an integer.   There is no default.
This is a limit on the number of digits to be shown after the decimal point. It is only
used by `"QDecimalElement"`.

##### `dialog.section.element.keyboardType`
This property is optional.  If provided it must be one of the text strings below.
The default is `"Default"`.
This determines what kind of keyboard will appear when text editing is required.

 * `"Default"`
 * `"ASCIICapable"`
 * `"NumbersAndPunctuation"`
 * `"URL"`
 * `"NumberPad"`
 * `"PhonePad"`
 * `"NamePhonePad"`
 * `"EmailAddress"`
 * `"DecimalPad"`
 * `"Twitter"`
 * `"Alphabet"`

##### `dialog.section.element.autocorrectionType`
This property is optional.  If provided it must be one of the text strings below.
The default is `"Default"`.
This determines if a text box will auto correct (fix spelling) the user's typing.
`"Default"` allows iOS to decide when to apply auto correction.  If you have a preference, choose
one of the other options.

 * `"Default"`
 * `"No"`
 * `"Yes"`

##### `dialog.section.element.autocapitalizationType`
This property is optional.  If provided it must be one of the text strings below.
The default is `"None"`.
This determines if and how a text box will auto capitalize the user's typing.

 * `"None"`
 * `"Words"`
 * `"Sentences"`
 * `"AllCharacters"`

##### `dialog.section.element.key`
This property is optional.  If provided it must be a string. There is no default.
A unique identifier for this element in the form. It is an alternative to bind for
referencing the data in the form. `bind`, but not `key` is used in Park Observer.
This was not well understood initially and most protocols have a key property
defined even though it is not used.

This property is ignored in all versions of Park Observer.

## `mission.edit_at_start_recording`
This property is optional.  If provided it must be a boolean. The default is `true`.
If `true`, the mission attributes editor will be displayed when the start recording button is pushed.

This property is ignored in versions of Park Observer before 1.2.0.

## `mission.edit_at_start_first_observing`
This property is optional.  If provided it must be a boolean. The default is `false`.
If `true`, then editor will be displayed when start observing button is pushed after start recording.

This property is ignored in versions of Park Observer before 1.2.0.

## `mission.edit_at_start_reobserving`
This property is optional.  If provided it must be a boolean. The default is `true`.
If `true`, then editor will be displayed when start observing button is pushed after stop observing.

This property is ignored in versions of Park Observer before 1.2.0.

## `mission.edit_prior_at_stop_observing`
This property is optional.  If provided it must be a boolean. The default is `false`.
If `true`, then editor will be displayed for the prior track log segment when done observing
(stop observing or stop recording button press).
See the note for `edit_at_stop_observing` for an additional constraint.

This property is ignored in versions of Park Observer before 1.2.0.

## `mission.edit_at_stop_observing`
This property is optional.  If provided it must be a boolean. The default is `false`.
If `true`, then editor will be displayed when when done observing (stop observing or stop recording button press)

**Note:** Only one of `edit_prior_at_stop_observing` and `edit_at_stop_observing` should be set to `true`.
If both are set to `true`, `edit_prior_at_stop_observing` is ignored.
(In this case, you can edit the prior mission property by taping the marker on the map)

This property is ignored in versions of Park Observer before 1.2.0.

## `mission.symbology`
An optional object as defined in the [symbology](#symbology) section at the end of this document.
This object defines how a mission properties point is drawn on the map.  This point occurs
when starting recording, starting/stopping observing, and when editing the mission attributes.
The default is a 12 point solid green circle.

## `mission.on-symbology`
An optional object as defined in the [symbology](#symbology) section at the end of this document.
This object defines the look of the track log line when observing (i.e. on-transect).
The default is a 3 point wide solid red line.

## `mission.off-symbology`
An optional object as defined in the [symbology](#symbology) section at the end of this document.
This object defines the look of the track log line when not observing (i.e. off-transect).
The default is a 1.5 point wide solid gray line.

## `mission.gps-symbology`
An optional object as defined in the [symbology](#symbology) section at the end of this document.
This object defines the look of the GPS points along the track log.
The default is a 6 point blue circle.

This property is ignored in versions of Park Observer before 0.9.8.  In that case,
all GPS points are rendered as a blue 6 point circle.

## `mission.totalizer`
This property is optional. If provided it must be an object as defined below. There is no default.
The totalizer object is used to define the parameters displaying a totalizer which shows 
information on how long the user has been track logging (recording) and/or observing (on-transect).
If the property is not provided, no totalizer will be shown on the map.  The totalizer requires that
track logging be enabled (i.e. the `tracklog` property must not be `"none"`). If an empty object is
given to the totalizer, it will display how many kilometers the user has been observing on the
current track log. The totalizer can be given an optional list of fields to monitor.  If `fields`  is empty,
the totalizer resets to zero every time the user starts/stops track logging. If  `fields` is provided, then
the totalizer never resets, but rather shows the total time/distance (for the entire survey) recording/
observing for the current set of values for the provided fields.  When one or more of the fields
changes, a different set of totals will be displayed. The fields must be in the mission attributes.
`fields` is typically set to the transect id and the totalizer show the total time or
distance recording/observing on the current transect.

This property is ignored in versions of Park Observer before 0.9.8b.
Prior to 2.0.0 no totalizer was shown unless fields had a valid value, and one of the _include_ properties was `true`.

The `totalizer` has the following properties

* [`fields`](#-mission-totalizer-fields-) (o)
* [`fontsize`](#-mission-totalizer-fontsize-) (o)
* [`includeon`](#-mission-totalizer-includeon-) (o)
* [`includeoff`](#-mission-totalizer-includeoff-) (o)
* [`includetotal`](#-mission-totalizer-includetotal-) (o)
* [`units`](#-mission-totalizer-units-) (o)

### `mission.totalizer.fields`
This property is optional. If provided it must be a list of one or more strings.
There is no default. The list contains attribute names. When any of the attribute 
in this list change, a different total is displayed. The attributes in the list must 
be in referenced in the mission dialog (so that it can be changed -- monitoring a 
unchanging field is pointless).  The names in the list must be unique.

### `mission.totalizer.fontsize`
This property is optional. If provided it must be a positive number. The default is 14.0.
This property indicates the size (in points) of the totalizer text.

Starting with Park Observer 2.0.0 this property is ignored.  The font
size is determined by the standard system font which can be managed with
the settings app.

### `mission.totalizer.includeon`
This property is optional. If provided it must be a boolean. The default is `true`.
This property indicates if the total while "observing" should be displayed.

### `mission.totalizer.includeoff`
This property is optional. If provided it must be a boolean. The default is `false`.
This property indicates if the total while "recording" but not "observing"
should be displayed.

### `mission.totalizer.includetotal`
This property is optional. If provided it must be a boolean. The default is `false`.
This property indicates if the total regardless of "observing" status should be displayed.

### `mission.totalizer.units`
This property is optional. If provided it must be a string. The default is `"kilometers"`.
The property indicates the kind of total to display.
It must be one of `"kilometers"`, `"miles"` or `"minutes"`.



# `features`

This property is required and must be a list of one or more `feature` objects.
A feature is a kind of thing that will be observed during your survey.
Often it is an animal species.
It is defined by a list of attributes that you will collect every time you observe the feature.
You can have multiple features in your protocol, however many surveys only observe one feature.
The number of features in a protocol file should be kept as small as possible to keep the survey
focused and easier to manage.

Each `feature` is an object with the following properties

* [`name`](#-feature-name-)
* [`attributes`](#-feature-attributes-) (o)
* [`dialog`](#-feature-dialog-) (o)
* [`allow_off_transect_observations`](#-feature-allow_off_transect_observations-) (o)
* [`locations`](#-feature-locations-)
* [`symbology`](#-feature-symbology-) (o)
* [`label`](#-feature-label-) (o)

## `feature.name`
This property is required and must be a non-empty text string.
Each feature name must be unique name. The name is used in the interface to let the
user choose among different feature types. All the observation in one feature will
be exported in a CSV file with this name, and a geo-database table with this name.
It should be short and descriptive.
Starting with Park Observer 2.0.0, this string must be 10 characters or less.

## `feature.attributes`
An optional list of attributes to collect for this feature.
A Feature with no attributes only collects a location and the name of the feature.

See the [`mission.attributes`](#-mission-attributes-) section for details.

## `feature.dialog`
An optional property that describes the format of the editing form for this feature's attributes.

See the [`mission.dialog`](#-mission-dialog-) section for details.

## `feature.allow_off_transect_observations`
This property is optional. If provided it must be a boolean. The default is `false`.
If `true`, then this feature can be observed while off transect (not observing)

This property is ignored in versions of Park Observer before 1.2.0.

## `feature.locations`
This property is required and must be a list of one or more `location` objects.
A `location` is an object that describes the permitted techniques for specifying
the location of an observation. A `location` is defined by the following properties:

* [`type`](#-feature-location-type-)
* [`allow`](#-feature-location-allow-) (o)
* [`default`](#-feature-location-default-) (o)
* [`deadAhead`](#-feature-location-deadahead-) (o)
* [`baseline`](#-feature-location-baseline-) (deprecated)
* [`direction`](#-feature-location-direction-) (o)
* [`units`](#-feature-location-units-) (o)

### `feature.location.type`
This property is required and must be one of the following strings:

 * `"gps"` - locates the observation at the devices GPS location
 * `"mapTarget"` - locates the observation where the target is on the map
 * `"mapTouch"` - locates the observation where the user touches the map
 * `"angleDistance"` - locates the observation at an angle and distance from the GPS location and course.
 * `"azimuthDistance"` - locates the observation at the azimuth and distance from the GPS location.

`"adhocTarget"` is a deprecated synonym for `"mapTarget"`, and
`"adhocTouch"` is a deprecated synonym for `"mapTouch"`.  These types should not be
used in new protocol files, but may still exist in older files.

`azimuthDistance` is ignored in versions of Park Observer before 2.0.0.

Starting with Park Observer 2.0.0:

 * `"mapTarget"` is ignored (there is no map target).
 * providing multiple locations with the same type is an error.
 * multiple locations cannot `allow` both type = `"angleDistance"` and type = `"azimuthDistance"`
 * `"gps"` is ignored if `"angleDistance"` exists and is `allowed`
 * `"gps"` is ignored if `"azimuthDistance"` exists and is `allowed`

See the [Protocol Guide](Protocol_Guide_V2.html) for details on how the user interface behaves with
different location types.

### `feature.location.allow`
This property is optional. If provided it must be a boolean. The default is `true`.
If the value is `false`, this type of location method is not allowed.
This is equivalent to not providing the location method in the list.

### `feature.location.default`
This property is optional. If provided it must be a boolean. The default is `false`.
This is used to determine which "allowed" non-touch location method should be used
by default (until the user specifies their preference).
Only one non-touch locations should have a `true` value, otherwise the behavior is undefined.

Starting with Park Observer 2.0.0, this property is ignored.  With the removal of `"mapTarget"`,
there is no longer confusion as to which location type applies in a given situation.

### `feature.location.deadAhead`
This property is optional. If provided it must be a number between 0.0 and 360.0. The default is 0.0.
The numeric value provided is the angle measurement in degrees that means the feature is dead ahead
(i.e. on course or trajectory of the device per the GPS)

### `feature.location.baseline`
**Deprecated**
This property is a deprecated synonym for `deadAhead`.
Its use is discouraged, but it may be found in older protocol files.
`baseline` is ignored if `deadAhead` is provided.

### `feature.location.direction`
This property is optional. If provided it must be one of `"cw"` or `"ccw"`. The default is `"cw"`.
With `"cw"`, angles for the `"angleDistance"` location type will increase in the clockwise direction,
otherwise they increase in the counter-clockwise direction.

### `feature.location.units`
This property is optional. If provided it must be one of `"feet"`, `"meters"` or `"yards"`.
The default is `"meters"`.
With `"meters"`, distances for the `"angleDistance"` or `"azimuthDistance"` location types
will be in meters. Otherwise they will be in feet or yards.

## `feature.symbology`
An optional object as defined in the [symbology](#symbology) section at the end of this document.
This object defines how an observation of this feature is drawn on the map.
The default is a 14 point solid red circle.

## `feature.label`
This property is optional. If provided it must be an object.  There is no default.
The label object defines how the feature will be labeled on the map.

This `label` object has the following properties:

* [`field`](#-feature-label-field-) (o)
* [`color`](#-feature-label-color-) (o)
* [`size`](#-feature-label-size-) (o)
* [`symbol`](#-feature-label-symbol-) (o)
* [`definition`](#-feature-label-definition-) (o) (v2)

### `feature.label.field`
This property is optional. If provided it must be a non-empty text string.
The string must match one of the [attribute names](#-attribute-name-) for this feature.
It is an error to provide both `field` and `definition` properties.
It is an error if neither a `field` nor `definition` property is provided.

### `feature.label.color`
This property is optional. If provided it must be an string.  The default is "#FFFFFF" (white)
See [symbology.color](#-symbology-color-) for more details.
This property is ignored if the `symbol` or `definition` property is provided.

### `feature.label.size`
This property is optional. If provided it must be an positive number.  The default is 14.0.
It specifies the size in points of the label text.
See [symbology.size](#-symbology-size-) for more details.
This property is ignored if the `symbol` or `definition` property is provided.

### `feature.label.symbol`
This property is optional. If provided it must be an object.  There is no default.
The symbol is a esri text symbol JSON object.
See the section on [Esri Objects](#esri-objects) below for more information.
It is an error if the JSON object is malformed or unrecognized.
This property is ignored if the `definition` property is provided.

### `feature.label.definition`
This property is optional. If provided it must be an object.  There is no default.
The definition is a esri label definition JSON object.
See the section on [Esri Objects](#esri-objects) below for more information.
It is an error if the JSON object is malformed or unrecognized.
It is an error to provide both `field` and `definition` properties.
It is an error if neither a `field` nor `definition` property is provided.


# `csv`

This property is optional. If provided it must be an object.  There is no default.

This object describes the format of the CSV exported survey data.
Currently the format of the CSV files output by Park Observer is hard coded.
This part of the protocol file is ignored by Park Observer, and only used
by tools that convert the CSV data to an esri feature classes.

If provided it must be a object identical to [`csv.json`](csv.json).
It is used by post processing tools like the POZ to FGDB translator to understand 
how the CSV export files are formatted. If it is not provided, post processing tools  
will use [`csv.json`](csv.json).

A future version of Park Observer may use this property to allow users to configure 
the format of the exported CSV files.

The CSV object has the following properties.  All are required.

* [`features`](#-csv-features-)
* [`gps_points`](#-csv-gps_points-)
* [`track_logs`](#-csv-track_logs-)

## `csv.features`
An object that describes how to build the observer and feature point feature classes from the CSV
file containing the observed features. The features object has the following properties.
All are required.

 * [`feature_field_map`](#-csv-features-feature_field_map-)
 * [`feature_field_names`](#-csv-features-feature_field_names-)
 * [`feature_field_types`](#-csv-features-feature_field_types-)
 * [`feature_key_indexes`](#-csv-features-feature_key_indexes-)
 * [`header`](#-csv-features-header-)
 * [`obs_field_map`](#-csv-features-obs_field_map-)
 * [`obs_field_names`](#-csv-features-obs_field_names-)
 * [`obs_field_types`](#-csv-features-obs_field_types-)
 * [`obs_key_indexes`](#-csv-features-obs_key_indexes-)
 * [`obs_name`](#-csv-features-obs_name-)

### `csv.features.feature_field_map`
A list of integer column indices from the CSV header, starting with zero,
for the columns containing the data for the observed feature tables.

### `csv.features.feature_field_names`
A list of the string field names from the CSV header that will create
the observed feature tables.

### `csv.features.feature_field_types`
A list of the string field types for each column listed in
the `feature_field_names` property.

### `csv.features.feature_key_indexes`
A list of 3 integer column indices, starting with zero, for the columns
containing the time, x and y coordinates of the feature.

### `csv.features.header`
The header of the CSV file; a text string with the column names in order separated by a comma(`,`).

### `csv.features.obs_field_map`
A list of integer column indices from the CSV header, starting with zero,
for the columns containing the data for the observer table.

### `csv.features.obs_field_names`
A list of the field names from the CSV header that will create the observed feature table.

### `csv.features.obs_field_types`
A list of the field types for each column listed in the `obs_field_names` property.

### `csv.features.obs_key_indexes`
A list of 3 integer column indices, starting with zero, for the columns
containing the time, x and y coordinates of the observer.

### `csv.features.obs_name`
The name of the table in the esri geo-database that will contain the data
for the observer of the features.

## `csv.gps_points`
An object that describes how to build the GPS point feature class
from the CSV file containing the GPS points. The `gps_points` object
has the following properties.
All are required.

 * [`field_names`](#-csv-gps_points-field_names-)
 * [`field_types`](#-csv-gps_points-field_types-)
 * [`key_indexes`](#-csv-gps_points-key_indexes-)
 * [`name`](#-csv-gps_points-name-)

### `csv.gps_points.field_names`
A list of the field names in the header of the CSV file in order.

### `csv.gps_points.field_types`
A list of the field types in the columns of the CSV file in order.

### `csv.gps_points.key_indexes`
A list of 3 integer column indices, starting with zero, for the columns
containing the time, x and y coordinates of the point.

### `csv.gps_points.name`
The name of the CSV file, and the table in the esri geo-database.

## `csv.track_logs`
An object that describes how to build the GPS point feature class
from the CSV file containing the track logs and mission properties.
The track_logs object has the following properties.
All are required.

 * [`end_key_indexes`](#-csv-track_logs-end_key_indexes-)
 * [`field_names`](#-csv-track_logs-field_names-)
 * [`field_types`](#-csv-track_logs-field_types-)
 * [`name`](#-csv-track_logs-name-)
 * [`start_key_indexes`](#-csv-track_logs-start_key_indexes-)

### `csv.track_logs.end_key_indexes`
A list of 3 integer column indices, starting with zero, for the
columns containing the time, x and y coordinates of the first point in the track log.

### `csv.track_logs.field_names`
A list of the field names in the header of the CSV file in order.

### `csv.track_logs.field_types`
A list of the field types in the columns of the CSV file in order.

### `csv.track_logs.name`
The name of the CSV file, and the table in the esri geo-database.

### `csv.track_logs.start_key_indexes`
A list of 3 integer column indices, starting with zero, for the
columns containing the time, x and y coordinates of the last point in the track log.



# Symbology
The symbology that Park Observer understands changed at 0.9.8.  Before that, only version 1
symbology was understood.  After that it depended on which `"meta-version"` the document
specified.  Starting with Park Observer 2.0.0, both versions of the symbology are
understood correctly, regardless of the `"meta-version"` of the document.

## `"meta-version": 1`
In version 1, the symbology object had only two optional properties.  If the symbology
property is missing, empty or incomplete then Park Observer will use the default symbology
specified in the individual objects above. The version 1 symbology object has the following
properties:

* [`color`](#-symbology-color-)
* [`size`](#-symbology-size-)

### `symbology.color`
This property is optional. If provided it must be a text string. There is no default.
The color element is a string in the form "#FFFFFF"
where F is a hexadecimal digit (0-9,A-F).
The hex pairs represent the intensity of Red, Green, and Blue respectively.
Starting with Park Observer 2.0.0 a malformed color string is an error.
If the property is missing, then the default is determined by the object being rendered.

### `symbology.size`
This property is optional. If provided it must be a non-negative number. There is no default.
The size is a number for the diameter in points of the simple circle marker symbol,
or the width of a simple solid line.
Starting with Park Observer 2.0.0 an invalid size is an error.
If the property is missing, then the default is determined by the object being rendered.

## `"meta-version": 2`
With version 2, the symbology object can be an esri Renderers JSON object. 
See the section on [Esri Objects](#esri-objects) below for more information.
It is an error if the object has a `type` property of either `"simple"`,
`"classBreaks"`, or `"uniqueValue"` and does not produce a valid renderer object.
If the symbology object is not esri renderer object, but is empty, or has
one of the version 1 properties, it is treated as a version 1 symbology object.

When using an esri Renderer, it is on you to verify you are using the right type
of symbol for the object being rendered (i.e a marker symbols like `"esriSMS"` for
points and the line symbol `"esriSLM"` for track logs).

If you wish to not draw the track logs or GPS points, then you need to provide valid symbology
with either 0 size, or a fully transparent color.



# Esri Objects

This section describes the esri JSON objects used in the protocol specification,
mostly by linking to the online documentation provided by esri.  However at the time
of writing, there are some gaps, particularly with regard to default values.
These gaps were closed with some testing that is documented below.  These tests are
valid for Park Observer 2.0.0 which uses version 100.8 of the esri SDK.  I expect that
these default will remain stable, but since esri has not documented them, they may
change.  If a particular value is important to you it is best to specify it explicitly
rather than relying on the undocumented default behavior.

## Text Symbol

The feature label can specify the label format with an esri text symbol
JSON object as described in the
[text symbol section of the ArcGIS ReST API](http://resources.arcgis.com/en/help/arcgis-rest-api/#/Symbol_Objects/02r3000000n5000000/).

The minimal text symbol is:
```
{
  "type": "esriTS"
}
```

Which comes with the following default values:
```
"color": [0, 0, 0, 255]          // opaque black
"backgroundColor": [0, 0, 0, 0]  // transparent black
"borderLineSize": 0.0
"borderLineColor": [0, 0, 0, 0]
"haloSize": 0.0
"haloColor": [0, 0, 0, 0]
"verticalAlignment": "middle"
"horizontalAlignment": "center"
"angle": 0.0
"xoffset": 0.0
"yoffset": 0.0
"kerning": false
"font": {
  "family": ""
  "size": 8.0
  "style": "normal"
  "weight": "normal"
  "decoration": "none"
}
"text: ""
```

The runtime SDK has the following text symbol properties
that cannot be set in JSON but have the following defaults:
```
"angleAlignment": "AGSMarkerSymbolAngleAlignmentScreen"
"leaderOffsetX": 0.0
"leaderOffsetY": 0.0
"outline": { "style": "esriSLSSolid" }
```
The following documented text symbol property is supported in the Runtime SDK
```
"rightToLeft": false
```

## Label Definition
The feature label can specify the label format with an esri label definition
JSON object as defined in the
[Web map specification](https://developers.arcgis.com/web-map-specification/objects/labelingInfo/)
for labelingInfo.
**NOTE:** "In order to provide a more accurate representation
of labels created in ArcGIS Pro (for a mobile map package, for example), ArcGIS
Runtime defines additional JSON properties that are not included in the Web map
specification. Refer to the
[JSON label class properties](https://developers.arcgis.com/ios/latest/swift/guide/json-label-class-properties.htm) topic for a description of the available properties, their expected values, and
the defaults used for each."
from https://developers.arcgis.com/ios/latest/swift/guide/add-labels.htm

Additional references: 
https://developers.arcgis.com/documentation/common-data-types/labeling-objects.htm
and https://developers.arcgis.com/ios/latest/api-reference/interface_a_g_s_label_definition.html

A simple example which labels the feature with the id number if it is greater than 10.
Using the default text symbol (see above), and the default labeling properties
(see references)
```
{
  "labelExpression": "[id]",
  "where": "id > 10"
}
```

Using Arcade which labels the feature with the capitalized first letter of the name.
```
{
  "labelExpressionInfo": {"expression": "Upper(Left($feature.name, 1))"}
}
```

Using a simple expression to concatenate multiple values with static text and a newline.  A test symbol is used to increase the font size.
```
{
  "labelExpression":  "\"Name: \" CONCAT [name] CONCAT NEWLINE CONCAT \"id: \" CONCAT [id]",
  "symbol": { "type": "esriTS", "font": {"size": 18} }
}
```


## Renderers

Features and several properties of the mission can specify the symbology format with an esri renderer
JSON object as described in
[Renderer objects in the ArcGIS ReST API](https://developers.arcgis.com/documentation/common-data-types/renderer-objects.htm).
Each renderer has a `type` property which is required and must be one of 

* `"simple"` for a simple (single symbol) renderer
* `"classBreaks"` for a class breaks renderer
* `"uniqueValue"` for a unique value renderer

### Simple Renderer
The minimal simple renderer is:
```
{
  "type": "simple"
}
```

Which comes with the following default values:
```
"symbol": null
"label": ""
"description": ""
"rotationType": "geographic"
"rotationExpression": ""
```

This renderer is useless, as it has no symbol.  An appropriate symbol (as discussed below)
needs to be provided to match the geometry of the feature being symbolized.

### Unique Value Renderer:
Similarly, the minimal (although useless) unique value renderer is:
```
{
  "type": "uniqueValue"
}
```

Which comes with the following default values:
```
"field1": null
"field2": null
"field3": null
"fieldDelimiter": ""
"defaultSymbol": null
"defaultLabel": ""
"rotationType": "geographic"
"rotationExpression": ""
"uniqueValueInfos": []
```

A more useful example is:
```
{
  "type": "uniqueValue",
  "field1": "name",
  "field2": "id",
  "fieldDelimiter": ",",
  "defaultSymbol": {"type":"esriSMS", "size": 10},
  "uniqueValueInfos": [{
    "value": "bob,0",
    "symbol": {"type":"esriSMS", "size": 20, "color": [255,255,255,255]}
  },{
    "value": "BOB,0",
    "symbol": {"type":"esriSMS", "size": 30, "color": [255,255,255,255]}
  },{
    "value": "bob,1",
    "symbol": {"type":"esriSMS", "size": 20, "color": [0,0,0,255]}
  },{
    "value": "BOB,1",
    "symbol": {"type":"esriSMS", "size": 30, "color": [0,0,0,255]}
  }]
}
```

The defaults in this case are:

```
"field3": null
"defaultLabel": ""
"rotationType": "geographic"
"rotationExpression": ""
```

And for each item in the `uniqueValueInfos` list the defaults are 
```
"label": ""
"description": ""
```

**NOTE:** `uniqueValueInfos.value` is a single string regardless of the number or type
of fields used. If more than 1 field is used, then `fieldDelimiter` is required and must
be included in the `uniqueValueInfos.value` string to separate the values.  There must
be same number of values in the `uniqueValueInfos.value` string as there are fields defined. 


### Class Breaks Renderer:
Similarly, the minimal valid (although useless) class breaks renderer is:
```
{
  "type": "classBreaks"
}
```

This has the following defaults:
```
"field": null
"classificationMethod": "esriClassifyManual"
"normalizationType": "esriNormalizeNone"
"normalizationField": null
"normalizationTotal": null (NaN)
"defaultSymbol": null
"defaultLabel": ""
"backgroundFillSymbol": null
"minValue": null (NaN)
"rotationType": "geographic"
"rotationExpression": ""
"classBreakInfos": []
```

While not defined in https://developers.arcgis.com/documentation/common-data-types/renderer-objects.htm
the known classification methods in the SDK are listed here.
Only `esriClassifyManual` (the default) is mentioned in the documentation.

* `esriClassifyDefinedInterval`
* `esriClassifyEqualInterval`
* `esriClassifyGeometricalInterval`
* `esriClassifyNaturalBreaks`
* `esriClassifyQuantile`
* `esriClassifyStandardDeviation`
* `esriClassifyManual`

A more useful minimal example is:
```
{
  "type": "classBreaks",
  "field": "age",
  "minValue": 0,
  "defaultSymbol": {"type":"esriSMS", "size": 5},
  "classBreakInfos": [{
    "classMaxValue": 25,
    "symbol": {"type":"esriSMS", "size": 10}
  },{
    "classMaxValue": 100,
    "symbol": {"type":"esriSMS", "size": 20}
  }]
}
```

The defaults in this case are:
```
"classificationMethod": "esriClassifyManual"
"normalizationType": "esriNormalizeNone"
"normalizationField": null
"normalizationTotal": null (NaN)
"defaultLabel": ""
"backgroundFillSymbol": null
"rotationType": "geographic"
"rotationExpression": ""
```

And for each item in the `classBreakInfos` list the defaults are 
```
"classMinValue": null (NaN)
"label": ""
"description": ""
```


## Symbols

The renderers require a symbol that matches the geometry type of the feature
being rendered. The JSON object for symbols is described in the
[ArcGIS ReST API](http://resources.arcgis.com/en/help/arcgis-rest-api/#/Symbol_Objects/02r3000000n5000000/)
and the [Runtime SDK Documentation](https://developers.arcgis.com/documentation/common-data-types/symbol-objects.htm).

### Simple Marker Symbol
The minimal simple marker symbol (for points) is:
```
{
  "type": "esriSMS"
}
```

Which comes with the following default values:
```
"style": "esriSMSCircle"
"color":  [211, 211, 211, 255] // Light Gray (82% white); Opaque
"outline": null
"size": 8.0
"angle": 0.0
"xoffset": 0.0
"yoffset": 0.0
```

With a minimal outline, it is:
```
{
  "type": "esriSMS",
  "outline": {}
}
```

The `outline` object comes with the following default values:
```
"color": [211, 211, 211, 255] // Light Gray (82% white); Opaque
"style": "esriSLSSolid"
"width": 1.0
```

The runtime SDK has the following simple marker symbol properties
that cannot be set in JSON but have the following defaults:
```
"angleAlignment": "AGSMarkerSymbolAngleAlignmentScreen"
"leaderOffsetX": 0.0
"leaderOffsetY": 0.0
"outline": { "style": "esriSLSSolid" }
```

### Simple Line Symbol
The minimal simple line symbol is:
```
{
  "type": "esriSLS"
}
```

Which comes with the following default values:
```
"color": [211, 211, 211, 255] // Light Gray (82% white); Opaque
"style": "esriSLSSolid"
"width": 1.0
```

The runtime SDK has the following simple line symbol properties
that cannot be set in JSON but have the following defaults:
```
"antialias": false
"markerPlacement": "AGSSimpleLineSymbolMarkerPlacementEnd"
"markerStyle": "AGSSimpleLineSymbolMarkerStyleNone"
```

### Picture Marker Symbol
The minimal picture marker symbol is:
```
{
"type": "esriPMS"
}
```

But this is is useless, as there is no image to display.
If you want to use a graphic image for your marker symbol, it is best to use
the `contentType` and `imageData` properties to provide a base64 encoded image.
If you use the `url` property, it must be a full network URL, and the network
must be available when running the app, or the image will not display.

The minimal picture marker symbol comes with the following default values:
```
"url": ""
"imageData": ""
"contentType": ""
"width": 0.0
"height": 0.0
"angle": 0.0
"xoffset": 0.0
"yoffset": 0.0
```

The runtime SDK has the following simple line symbol properties
that cannot be set in JSON but have the following defaults:
```
"angleAlignment": "AGSMarkerSymbolAngleAlignmentScreen"
"leaderOffsetX": 0.0
"leaderOffsetY": 0.0
"opacity": 1.0
```
