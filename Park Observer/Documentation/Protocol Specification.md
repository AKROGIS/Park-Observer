# Protocol Specification

The protocol file (*.obsprot) is a plain text file in `JSON` (javascript object notation) format.
The file typically contains only `ASCII` characters.
If special characters (accents marks, emoji, etc.) are needed, the file must be encoded in `UTF8`.

The file contains one object.
An object begins with an opening curly bracket (`{`) and ends with an closing curly bracket (`}`)
Properties in the object are separated by a comma(`,`)
Property names must be enclosed in double quotes (`"`).
A colon (:) separates the property name from the property value.
A property value can be an object, a string of text enclosed in double quotes (`"`),
a number, or one of the special symbols: `true`, `false`, and `null`.
A property value can also be a list of property values.
A list begins with an opening square bracket (`[`), and ends with a closing square bracker (`]`).
Items in the list are separated by a comma (`,`).

Official specifications on the JSON file format the can be found at http://www.json.org/.
The JSON file format is very specific and it is easy to introduce errors when editing by
hand.  There are a number of online JSON linters (i.e. https://jsonlint.com) that will
check your protocol file to ensure it is valid JSON, and help you find and fix those errors.

This specification describes versions 1 (v1) and 2. Properties that were introduced
in version 2 are marked v2.  Since most of the properties introduced in v2 are
optional and do not conflict with properties in v1 Park Observer will decode the
v2 properties even if found in a v1 file.  The exception is the symbology properties.
For clarity you are encouraged to mark you protocol file as v2 when using the newer
properties.

This specification is defined in a human and machine readable form in `protocol.v1.schema.json`
and `protocol.v2.schema.json`.  These schemas are written in [JSON Schema](http://json-schema.org/).
These schema files can be used to validate a protocol file to ensure that it is not just valid
JSON, but meets the requirements of this specification.  One example is
the online validator at https://www.jsonschemavalidator.net.  The validator will work best
if you have already verified that your protocol is a valid JSON file.

The main object in the file has the following properties.
Properties marked with an (o) are optional; the others are required.

*	meta-name
*	meta-version
*	name
*	version
*	date (o)
*	description (o)
*	mission (o)
*	features
*	observing (o)(v2)
*	notobserving (o)(v2)
* status_message_fontsize (o)(v2)
* cancel_on_top (o)(v2)
* gps_interval (o)(v2)
*	csv (o)

Each of these properties are defined in the following sections.

**IMPORTANT:**
This specification and the related schema document, define the proper format of the
obsprot file.  It is possible that the implementation in Park Obsererver is more relaxed,
for example it might provide default values when a required value is missing, or accept
different spellings, but that behaviour is subject to change without notice.

**IMPORTANT:**
Due to the permissive nature of the Park Observer implementation of this specification,
many of the properties introduced in a later version of the specification will also be
honored provided the definition of that property does not conflict with existing properties
and that the new property has a default value. In practice, that mean that most properties
introduced in future versions of the specification will also be available in obsprot files
that declare this version.  However, this
behaviour is not guaranteed.  You are urged to upgrade your obsprot file if you wish to
use a property introduced in a new version of the specification.

## meta-name
This required property designates the file as subscribing to this file format.
It must be `NPS-Protocol-Specification`.

## meta-version
A required integer that defines the version of the specification.
This is version 2.

## name
A required identifier (name) for this protocol.
The name should be a short piece of text that uniquely identifies the types of surveys that use this protocol.
The same name can and should be used for different version of the same protocol (see version and date properties).
The same name can be used with unrelated protocols, but this should be avoided where known.
The name, version, date, and description will be available to the user to pick the appropriate
protocol for their survey.

## version
A required version of this named protocol.
The version number looks like a floating point number but is actually two integers separated by a decimal point.
The first number is the major version number the second number is the minor version number.
A change in the major version number represents a change in the database structure of the protocol.
Two protocol files with the same name that differ in the major version number
cannot share the same feature classes (GIS database) without some data manipulation.
A change in the minor version number represents all other changes to the protocol file.
For example, changes in symbology, location methods, or picklist values would bump the minor number.
It is assumed that two protocol files with the same name and major version number can share the
same feature classes (GIS database) regardless of chamges in the minor version number

## date
The publication date of the protocol file.
The date is a string in iso format, i.e. YYYY-MM-DD
While this property is optional it is helpful in sorting protocols with the same name.
The name, version, date, and description will be available to the user to pick the appropriate
protocol for their survey.

## description
An optional description for this protocol.
It typically describes who wrote the protocol and which surveys or organizations it supports.
Contact information can also be included.
While this property is not required it is helpful in guiding the user's selection of the right
protocol for their survey.

## observing
An optional message to display on screen when observing (on transect).
The default is nothing.

## notobserving
An optional message to display on screen when track logging (recording) but not observing (off transect).
The default is nothing.

## status_message_fontsize
An optional floating point value that indicate the size (in points) of the `notobserving` text.  The default is 16.0.
The `observing` text will always be 2 points bigger, bold, and red.

## cancel_on_top
An optional boolean property. A value of `true` will put the `cancel`/`delete` button(s) on the top of the observation attributes form.
The default is `false` -- the `cancel`/`delete` button(s) will be on the bottom of the form.

## gps_interval
An optional numeric property which specifies the number of seconds between
saving successive GPS points to the tracklog.
This property can be helpful when the GPS delivers locations at a very high rate
(more than 1 per second), or if a detailed tracklog is not required.
The default is 0 (zero) which implies that all locations provided by the GPS are saved in the tracklog.
A number lower than the device can support will be ignored, and the default value will be used.
Using an interval greater than the GPS can support may reduce battery consumption by allowing the GPS to rest.
Regardless of this setting creating an observation will request a current location,
even if it is in the middle of the GPS interval.

## mission
An object that describes segments of the survey.
This includes attributes that are fairly constant for the entire survey, i.e. observer name,
as well as dynamic attributes like the weather.
It also describes the look and feel of the editing form,
and when the attributes should be edited.

A mission has the following properties

* attributes (o)
* dialog (o)
* edit_at_start_recording (o)(v2)
* edit_at_start_first_observing (o)(v2)
* edit_at_start_reobserving (o)(v2)
* edit_prior_at_stop_observing (o)(v2)
* edit_at_stop_observing (o)(v2)
* symbology
* on-symbology (o)
* off-symbology (o)
* gps-symbology (o)(v2)
* totalizer (o)(v2)

### attributes
An optional list of attributes that apply to segments of the tracklog.
A mission with no attributes, only collects the location where the the user
stopped and started observing (i.e. went on/off transect). The mission
attributes are often things like the names of the observers, and the weather.

Each `attribute` has the following properties

* name
* type

#### name
A required string identifying the attribute.  This will be the name of the field in ArcGIS.
It must start with a letter or underscore (`_`), and be followed by one or more letters, numbers,
or underscores. It must be at least 2 characters long, and no longer than 30 characters.
Spaces and special characters are prohibited.
The name must be unique within the mission or feature.
Different features can have attributes with the same name, but if they do they must have the same type.
Mission property and feature attributes are unrelated -- they can have the same name with different types.
**Important** Do not rely on upper/lowercase to distinguish two attributes; 
consider `Name`, `name`, and `NAME` to be the same.

#### type
A required number that identifies the type (kind) of data the attribute stores
The type must be an integer code with the following definitions (from NSAttributeType)
-   0 -> sequential integer id (not editable, only availalbe in v2)
-	100 -> 16bit integer
-	200 -> 32bit integer
-	300 -> 64bit integer
-	400 -> NSDecimal (currently not supported by ESRI)
-	500 -> double precision floating point number
-	600 -> single precision floating point number
-	700 -> string
-	800 -> boolean (converts to an ESRI integer 0 = NO, 1 = YES)
-	900 -> datetime
-	1000 -> binary blob (? no UI support, check on ESRI support)

### dialog
Provides the look and feel of the attribute editing form presented to the user.
Required if the mission has attributes.  There should be one element in the dialog
for each attribute that will be displayed and/or edited in the form.  This format
was due to the selection of [QuickDialog](https://github.com/escoz/QuickDialog) as
the form editor. While QuickDialog may have supported more properties than defined
below, the following are the only ones typically used by ParkObserver, and the only
ones that will be supported in the future.

 * title (o)
 * grouped (o)
 * sections

#### title
Optional text (title) placed at the top of the editing form.

#### grouped
Determines if the sections in this form are grouped.  I.e. there is visual separation between sections.  This property is optional.  If it is missing it will default to false.

#### sections
A section is a list of form elements collected into a single section.  Each section has
the following properties.

* title (o)
* elements

##### title
Optional text (title) placed at the top of the editing form.

##### elements
Elements make up the interesting parts of the form.  They are usually tied to an attribute
and determine how the attribute can be edited.  Examples of form elements are text boxes,
on/off switches, and picklists. Each element has the following properties.  Some
properties are only relevant for certain types of elements.

 * title (o)
 * type
 * bind (o)
 * items (o)
 * selected (o)
 * boolValue (o)
 * minimumValue (o)
 * maximumValue (o)
 * numberValue (o)
 * placeholder (o)
 * fractionDigits (o)
 * keyboardType (o)
 * autocorrectionType (o)
 * autocapitalizationType (o)
 * key (o)

###### title
The name/prompt that describes the data in this form element.  This usually appears to
the left of the attribute value in a different font.  This optional. This is often the
only property used by a `QLabelElement`.

###### type
Describes the display and editing properties for the form element.  Park Observer
only supports the following types.  These are case sensitive.

* `QBooleanElement` - an on/off switch, defaults to off.
* `QDecimalElement` - a "real" number editor with a limited number of digits after the decimal.
* `QEntryElement` - a single line text box.
* `QIntegerElement` - an integer input box with stepper (+1/-1) buttons.
* `QLabelElement` - non-editable text on its own line in the form.
* `QMultilineElement` - a multi-line text box.
* `QRadioElement` - A single selection picklist (as a vertical list of titles)
* `QSegmentedElement` - A single selection picklist (as a horizontal row of buttons)


###### bind
A special string that encodes the type and attribute name of the data for this element.
It is required by all form elements except label. (Label only uses the `value:` type when
displaying a unique feature id).  The bind value must start with one of the following:

 * `boolValue:` - a boolean (true or false) value
 * `numberValue:`
 * `selected:` - the zero based index of the selected item in `items`
 * `selectedItem:`  - the text of the selected item in `items`
 * `textValue:`
 * `value:` - used for Unique ID Attributes (Type = 0)

followed by an attribute name from the list of Attributes.
This will determine the type of value extracted from the form element,
and which attribute it is tied to (i.e. read from and saved to).
It is important that the type above matches the type of the attrribute in
the Attributes section.  Note that the will always be a colon (:) in the
bind string seperating the type from the name.

###### items
A list of choices for picklist type elements. Required for `QRadioElement`
and `QSegmentedElement`, and ignored for all other types.

###### selected
The zero based index of the intially selected item from the list of items.
If not provided, nothing is selected initiailly.

###### boolValue
An optional integer value (0 or 1) that is the default value for
`QBooleanElement`. The default is 0 (false).

###### minimumValue
An optional integer value that is the minimum value allowed in `QIntegerElement`.
The default is 0.

###### maximumValue
An optional integer value that is the maximum value allowed in `QIntegerElement`.
The default is 100.

###### numberValue
An optional number that is the initial value for `QIntegerElement` or `QDecimalElement`.
There is no default; that is the initial value is null. Protocol authors are discouraged
from using an initial value, as it causes confusion regarding whether there was an
observation of the default value, or there was no observation.  Leaving as null removes
the ambiguity.  If a default value is desired when there was no observation this can be
done in post processing without lossing the fact that no observation was actually made.

###### placeholder
Optional text to put in a text box to suggest to the user what to enter.

###### fractionDigits
Optional limit on the number of digits to be shown after the decimal point. Only
used by `QDecimalElement`.

###### keyboardType
An optional value that determines what kind of keyboard will appear when text editing is required.
If provided it must be one of the following **Case sensitive** values.  `Default` is the default.

 * `Default`
 * `ASCIICapable`
 * `NumbersAndPunctuation`
 * `URL`
 * `NumberPad`
 * `PhonePad`
 * `NamePhonePad`
 * `EmailAddress`
 * `DecimalPad`
 * `Twitter`
 * `Alphabet`

###### autocorrectionType
An optional value that determines if a text box will auto correct (fix spelling) the user's typing.
If provided it must be one of the following **Case sensitive** values.  `Default` is the default.
`Default` allows iOS to decide when to apply autocorrection.  If you have a preference, choose
one of the other options.

 * `Default`
 * `No`
 * `Yes`

###### autocapitalizationType
An optional value that determines if and how a text box will auto capitalize the user's typing.
If provided it must be one of the following **Case sensitive** values.  `None` is the default.

 * `None`
 * `Words`
 * `Sentences`
 * `AllCharacters`

###### key
A unique identifier for this element in the form. It is an alternative to bind for
referencing the data. `bind`, but not `key` is used in Park Observer.
This was not well understood initially and most protocols have a key property
defined even though it it is not used.

### edit_at_start_recording
An optional boolean value that defaults to true.  If true, the mission attributes editor will be displayed when the start recording button is pushed.

### edit_at_start_first_observing
An optional boolean value that defaults to false.
If true, then editor will be displayed when start observing button is pushed after start recording

### edit_at_start_reobserving
An optional boolean value that defaults to true.
If true, then editor will be displayed when start observing button is pushed after stop observing

### edit_prior_at_stop_observing
An optional boolean value that defaults to false.
If true, then editor will be displayed for prior track log when done observing (stop observing or stop recording button)
See the note for `edit_at_stop_observing` for an additional requirement.

### edit_at_stop_observing
An optional boolean value that defaults to false.
If true, then editor will be displayed when when done observing (stop observing or stop recording button)
Note: only one of `edit_prior_at_stop_observing` and `edit_at_stop_observing` should be set to true.
If both are set to true, `edit_prior_at_stop_observing` is ignored  (you can edit the prior mission property by taping to marker on the map)

# FIXME: Clean up the Symbology section (merge with end notes)

### symbology
This required property defines how the mission property point will be displayed on the map.
This is a point where the mission properties are edited.  Typically it every time the user
stops/starts recording or starts/stops observing.  This object has two formats.
See the discussion on symbology at the end of this document.

A version 1 symbolgy object has the following properties

* color
* size

A version2 symbology object is defined by the [renderer object in the ArcGIS ReST API](https://developers.arcgis.com/documentation/common-data-types/renderer-objects.htm)

#### color
The symbology may have an optional "color" element
The color element is a string in the form "#FFFFFF"
where F is a hexadecimal digit.
The Hex pairs represent the Red, Green, and Blue respectively.
The default if not provided, or malformed is "#000000" (black)

#### size
The symbology may have an optional "size" element
The size is an integer number for the size in points of the simple circle marker symbol
The default is 12 if not provided.

### on-symbology
Required. These are the same as the symbology property defined for features
These symbology properties define the look of the track log when observing (on or on-transect), and not observing (off).
The default is a 1 point wide solid black line.

### off-symbology
Required. These are the same as the symbology property defined for features
These symbology properties define the look of the track log when observing (on or on-transect), and not observing (off).
The default is a 1 point wide solid black line.

### gps-symbology
This property define the look of the gps points along the track log.
The default is a 6 point blue circle.
At version 1 the default symbol was the only option.

### totalizer
An optional object used to define the parameters for collecting and displaying a Mission Totalizer.
This is used to provide information on how long the user has been observing for a given set of conditions,
usually this is just the transect id.
In this case, the totalizer show how long the user has been observing on a current transect.
The totalizer has the following properties

* fields
* fontsize (o)
* includeon (o)
* includeoff (o)
* includetotal (o)
* units (o)

#### fields
A required array of field names
when any of the fields change, a different total is displayed.
There must be at least one field (string) in the array which matches the name of one of the attributes in the mission

#### fontsize
An optional floating point value that indicate the size (in points) of the totalizer text.  The default is 14.0

#### includeon
An optional boolean value (true/false), that indicate is the total while "observing" is true should be displayed.
The default is  true

#### includeoff
An optional boolean value (true/false), that indicate if the total while "observing" is false should be displayed.
The default is  false

#### includetotal
A boolean value (true/false), that indicate if the total regardless of "observing" status should be displayed.
The default is false.

#### units
An optional element with a value of "kilometers" or "miles" or "minutes".
The default is "kilometers".


## features
A list of objects. Each object is a feature with the following properties

* name
* attributes (o)
* dialog (o)
* allow_off_transect_observations (o)
* locations
* symbology

### name
Each feature must have a unique name.
The name can be any sequence of characters, and must be enclosed in quotes
The name is used in the interface to let the user choose among different feature types
It should be short and descriptive.

### attributes
An optional list of attributes to collect for this feature.  If there are
A Feature with no attributes only collects a location (and the name of the feature)
See the mission attributes for additional details.

### dialog
Provides the look and feel of the attribute input form presented to the user.
Required if the feature has attributes.  There should be one element in the dialog
for each editable attribute.
See the [QuickDialog](https://github.com/escoz/QuickDialog) documentation for details.

### allow_off_transect_observations (v2)
An optional boolean value that defaults to false.  If true, then this feature can be observed while off transect (not observing)

### locations
A required list of locations.
A location is an object that describes the permitted techniques for specifying the location of an observation. A location is defined by the following properties:

* type
* allow (o)
* default (o)
* deadAhead (o)
* baseline (deprecated)
* direction (o)
* units (o)

#### type
Each location method must have a "type" property.
The type value must be one of `gps`, `mapTarget`, `mapTouch`, `angleDistance`.
Any location type containing the text "Touch" is a touch location, the others are non-touch locations.
Providing multiple locations with the same type is allowed but discouraged as the behavior is undefined.
`adhocTarget` is a deprecated synonym for `mapTarget`, and
`adhocTouch` is a deprecated synonym for `mapTouch`.  These types should not be
used in new protocol files, but may still exist in older files.

If a touch location method is allowed then a feature will be created when the
user taps the map without selecting an existing feature.
If one or more non-touch location methods are allowed, then an
_Add Feature_ button is added to the user interface.

The _Add Feature_ button has the following behavior if more than one non-touch location method is allowed:
* **Tap:**
If there is a location method with `"default":true`
use that location method to add a new feature.
If there is no location method with `"default":true` and
if the feature's preferred location method (see Long Press) is not set, then
set the feature's preferred method to the first of the following types to be allowed
`gps`, `adhocTarget`, `angleDistance`.
Use the user's preferred location method to add a new feature

* **Long Press:**
Provide the user with a selection list of all the allowed non-touch location methods.
If the user selects one then a feature is added using the selected location method, and the selected location method is set as the user's preference.

#### allow
A location method can have an optional  "allow" element with a value of either true or false.
The value of true is assumed if this element is absent.
If the value is false, this type of location method is not allowed.  This is equivalent to not providing the location method in the list.

#### default
A location method can have an optional default element with a value of either true or false.
A value of false is assumed if this element is absent.
Only one non-touch locations should have a true value, otherwise the behavior is undefined.

#### deadAhead
A location method of "type":"angleDistance" has the following requirements
An optional element "deadAhead" with a numeric value between 0.0 and 360.0
The numeric value provided is the angle measurement in degrees that means the feature is dead ahead
The default is 0.0

#### baseline (deprecated)
This property is a synonym for `deadAhead`.
This may be found in older protocol files.
It is deprecated and discouraged.
Use `deadAhead` instead.

#### direction
An optional element "direction" with a value of "cw" or "ccw"
Angles increase in the clockwise ("cw") or counter-clockwise ("ccw") direction
The default is "cw"

#### units
An optional element "units" with value of "feet" or "meters" or "yards"
Distance measurements to the feature are reported in these units
The default is "meters"

# FIXME: Clean up symbology

### symbology
This required property defines how the feature will be displayed on the map.
If the property is not provided, the default color and size defined below
will be used to draw a circle marker.
There are two choices for the symbology, either the simple object described here
or a more more descriptive esri symbology object described below.

### label
An optional object that defines how the feature will be labeled on the map

#### field
The label should have a `field` element
where `field` is a string which references one of the attributes for this feature
If the `field` is not provided, or can't be found in the feature attributes, no label is shown

#### color
The label may have an optional `color` element
The color is a string as specified above for the feature symbology.
The default if not provided, or malformed is "#FFFFFF" (white)

#### size
The label may have an optional `size` element
The `size` is an integer number for the size in points of the label
The default is 14 if not provided.

#### symbol
The `label` may have an optional `symbol` element
The symbol is a JSON object as described in the Text Symbol section of the ArcGIS ReST API (http://resources.arcgis.com/en/help/arcgis-rest-api/#/Symbol_Objects/02r3000000n5000000/)
If the JSON object is malformed or unrecognized, then it is ignored in deference to the field, color and size properties.
If the symbol is valid, then the `field`, `size` and `color` properties  of `label` are ignored.

## csv
An object that describes the format of the exported survey data in CSV files.
Currently the format of CSV files output by Park Observer is hard coded,
and this part of the protocol file is ignored by Park Observer.
However it is used by tools that convert the csv data to an esri file geodatabases.

The csv object has the following properties.  All are required.

* features
* gps_points
* track_logs

### features
An object that describes how to build the observer and feature point feature classes from the CSV
file containing the observed features. The features object has the following properties.
All are required.

 * feature_field_map
 * feature_field_names
 * feature_field_types
 * feature_key_indexes
 * header
 * obs_field_map
 * obs_field_names
 * obs_field_types
 * obs_key_indexes
 * obs_name

#### feature_field_map
A list of integer column indices from the csv header, starting with zero, for the columns containing the data for the observed feature tables.

#### feature_field_names
A list of the string field names from the csv header that will create the observed feature tables.

#### feature_field_types
A list of the string field types for each column listed in the 'feature_field_names' property.

#### feature_key_indexes
A list of 3 integer column indices, starting with zero, for the columns containing the time, x and y coordinates of the feature.

#### header
The header of the CSV file; a list of the column names in order.

#### obs_field_map
A list of integer column indices from the csv header, starting with zero, for the columns containing the data for the observer table.

#### obs_field_names
A list of the field names from the csv header that will create the observed feature table.

#### obs_field_types
A list of the field types for each column listed in the 'obs_field_names' property.

#### obs_key_indexes
A list of 3 integer column indices, starting with zero, for the columns containing the time, x and y coordinates of the observer.

#### obs_name
The name of the table in the esri geodatabase that will contain the data for the observer of the features.

### gps_points
An object that describes how to build the GPS point feature class from the CSV file containing the GPS points. The gps_points object has the following properties.
All are required.

 * field_names
 * field_types
 * key_indexes
 * name

#### field_names
A list of the field names in the header of the CSV file in order.

#### field_types
A list of the field types in the columns of the CSV file in order.

#### key_indexes
A list of 3 integer column indices, starting with zero, for the columns containing the time, x and y coordinates of the point.

#### name
The name of the csv file, and the table in the esri geodatabase.



### track_logs
An object that describes how to build the GPS point feature class from the CSV file containing the tracklogs and mission properties. The track_logs object has the following properties.
All are required.

 * end_key_indexes
 * field_names
 * field_types
 * name
 * start_key_indexes

#### end_key_indexes
A list of 3 integer column indices, starting with zero, for the columns containing the time, x and y coordinates of the first point in the tracklog.

#### field_names
A list of the field names in the header of the CSV file in order.

#### field_types
A list of the field types in the columns of the CSV file in order.

#### name
The name of the csv file, and the table in the esri geodatabase.

#### start_key_indexes
A list of 3 integer column indices, starting with zero, for the columns containing the time, x and y coordinates of the last point in the tracklog.


# FIXME: Clean up symbology

## Symbology
Symbology determines how the points and lines appear when drawn on the map.
The symbology in version 1 and 2 is very different.  Version 2 does not
recognize version 1 symbology properties, and visa versa.

is required for the lines and points to appear on the map.
In version 1, if the symbology properties is missing or malformed, default symbology
will be provided.  If the symbology property is missing, nothing will be drawn.
Either version one or version two type symbols.

Note: I consider it a bug that nothing is drawn if no symbology propoerty
is provided for features and mission points.  They need to have symbology to be
drawn on the map, and selected for editing.  It is concievable that the users
would not want to see the gps points, and tracklogs.

### Version 1 Symbology
Provides a solid line, or a circle marker with the size and color specified

If the size or color properties of the symbology are missing or malformed,
default symbology will be provided.  If the symbology property is missing,
or is not an object, nothing will be drawn.

Note: I consider it a bug that nothing is drawn if no symbology propoerty
is provided for features and mission points.  They need to have symbology to be
drawn on the map and selected for editing.  It is conceivable that the user
would not want to see the gps points, and tracklogs, but not feature or mission points.

#### size
Optional.  Defaults to 1.0 for lines, and 8.0 for points
#### color
Optional. Hex string, Defaults to black if not provided or malformed

### Version 2 Symbology
The symbology properties are specified by the JSON format for ESRI Renderers
as defined in http://resources.arcgis.com/en/help/rest/apiref/renderer.html

Not all fields in the ESRI rest API are required.
In many cases the defaults are obvious and the field can be omitted.
For example, `"label": ""` or `"angle": 0` could be omitted.
I have not tested every property, so when it doubt provide a value.
The `type` property is required and must be one of `simple`, `uniqueValue`, `classBreak`.
_TODO: test which fields are required, and document the defaults for optional fields_

If the symbology property is not present or malformed,
then a 12 point green circle is used for observation points, a 6 point blue circle for gps points,
a 3 point solid red line for the tracklog while observing, and a 1.5 point gray line for the track logging while not observing.

If you wish to not draw the track logs or gps points, then you need to provide valid symbology
with either 0 size, or no color.

## Symbols
https://developers.arcgis.com/documentation/common-data-types/symbol-objects.htm

## Simple Marker Symbol Defaults:
minimal simple marker symbol is:
```
{
  "type": "esriSMS"
}
```
With the following defaults (as of 100.7.0)
```
style: esriSMSCircle
color:  [211, 211, 211, 255] // Light Gray (82% white); Opaque
size: 8.0
angle: 0.0
xoffset: 0.0
yoffset: 0.0
```
With a minimal outline, it is:
```
{
  "type": "esriSMS",
  "outline": {}
}
```
With the following defaults (as of 100.7.0)
```
style: esriSMSCircle
color:  [211, 211, 211, 255] // Light Gray (82% white); Opaque
size: 8.0
angle: 0.0
xoffset: 0.0
yoffset: 0.0
outline.width: 1.0
outline.color: [211, 211, 211, 255]
outline.style: esriSLSSolid
```

Properties not settable in JSON
 * angleAlignment: AGSMarkerSymbolAngleAlignmentScreen
 * leaderOffsetX: 0.0
 * leaderOffsetY: 0.0
 * outline.style: esriSLSSolid

## Picture Marker Symbol Defaults:
minimal picture marker symbol is:
```
{
"type": "esriPMS"
}
```
But this is is useless, as there is no image to display.
Suggest that you use the contentType and imageData properties to provide a base64 encoded image.  If you use a URL, it must be a
full network URL, and the network must be available when running the app, or the image will not display.

With the following defaults (as of 100.7.0)
```

AGSPictureMarkerSymbol properties
url: nil
imageData: nil
contentType: nil
width: 0.0
height: 0.0
angle: 0.0
xoffset: 0.0
yoffset: 0.0
```
Properties not settable in JSON
angleAlignment: AGSMarkerSymbolAngleAlignmentScreen
leaderOffsetX: 0.0
leaderOffsetY: 0.0
opacity: 1.0

## Simple Line Symbol Defaults:
minimal text symbol is:
```
{
  "type": "esriSLS"
}
```
With the following defaults (as of 100.7.0)
```
style: esriSLSSolid
color: [211, 211, 211, 255] // Light Gray (82% white); Opaque
width: 1.0
```
Properties not settable in JSON
 * antialias: false
 * markerPlacement: AGSSimpleLineSymbolMarkerPlacementEnd
 * markerStyle: AGSSimpleLineSymbolMarkerStyleNone

## Text Symbol defaults:
minimal text symbol is:
```
{
  "type": "esriTS"
}
```
With the following defaults (as of 100.7.0)

```
color:  [0, 0, 0, 255] // opaque black
backgroundColor: [0, 0, 0, 0] // transparent black
borderLineSize: 0.0
borderLineColor: [0, 0, 0, 0] 
haloSize: 0.0
haloColor: [0, 0, 0, 0]
verticalAlignment: middle
horizontalAlignment: center
angle: 0.0
xoffset: 0.0
yoffset: 0.0
kerning: false
font.family: ""
font.size: 8.0
font.style: normal
font.weight: normal
font.decoration: none
text: ""
```

Properties not settable in JSON
* angleAlignment: AGSMarkerSymbolAngleAlignmentScreen
* leaderOffsetX: 0.0
* leaderOffsetY: 0.0
* outline.style: esriSLSSolid

JSON Properties not supported in SDK
 * rightToLeft

## Renderers
https://developers.arcgis.com/documentation/common-data-types/renderer-objects.htm

## Simple renderer defaults:
minimal text symbol is:
```
{
"type": "simple"
}
```
With the following defaults (as of 100.7.0).  This is useless, as it has no symbol.

```
symbol: nil
label: ""
description: ""
rotationType: geographic
rotationExpression: ""
```

Properties not settable in JSON
sceneProperties

With the following, you get a "AGSUnsupportedSymbol", which will not display.  You need to provide a minimal (or more) symbol from above.
The symbol type should match the geometry of the objects in the layer.
```
{
  "type": "simple",
  "symbol": {}
}
```
## Unique value renderer defaults:
minimal valid (although useless) unique value renderer is:
```
{
  "type": "uniqueValue"
}
```

This has the following defaults
```
field1: null
field2: null
field3: null
fieldDelimiter: not used
defaultSymbol: null
defaultLabel: ""
rotationType: geographic
rotationExpression: ""
uniqueValueInfos count: 0
```

A more useful minimal example is:
```
{
  "type": "uniqueValue",
  "field1": "name",
  "defaultSymbol": {"type":"esriSMS", "size": 5},
  "uniqueValueInfos": [{
    "value": "bob",
    "symbol": {"type":"esriSMS", "size": 10}
  },{
    "value": "BOB",
    "symbol": {"type":"esriSMS", "size": 20}
  }]
}
```

The defaults in this case are:

```
type: uniqueValue
field1: "name"
field2: null
field3: null
fieldDelimiter: not used
defaultSymbol: <AGSSimpleMarkerSymbol>
defaultLabel: ""
rotationType: geographic
rotationExpression: ""
uniqueValue #1
  value: [bob]
  label: ""
  description: "" 
  symbol: <AGSSimpleMarkerSymbol>
uniqueValue #2
  value: [BOB]
  label: ""
  description: ""
  symbol: <AGSSimpleMarkerSymbol>
```
Note that `uniqueValueInfos.value` is a list that would presumably have 1,2, or 3
values for the 1,2, or 3 field names provided.  However the REST API does not specify
how to provide multiple values.  If a 2nd or 3rd field is provided, then anything in `value` is ignored,
and an empty list is returned.  Providing a list to `value` generates an error, and 
properties `value1` .. `value3` are also ignored.

At this time, it is only safe to provide a unique value renderer on 1 field.

## Class breaks renderer defaults:
minimal valid (although useless) class breaks renderer is:
```
{
  "type": "classBreaks"
}
```

This has the following defaults
```
field: null
classificationMethod: esriClassifyManual
normalizationType: esriNormalizeNone
normalizationField: null
normalizationTotal: nan
defaultSymbol: null
defaultLabel: null
backgroundFillSymbol: null
minValue: nan
rotationType: geographic
rotationExpression: null
classBreakInfos: empty list
```
While not defined on https://developers.arcgis.com/documentation/common-data-types/renderer-objects.htm the classification methods are
* esriClassifyDefinedInterval
* esriClassifyEqualInterval
* esriClassifyGeometricalInterval
* esriClassifyNaturalBreaks
* esriClassifyQuantile 
* esriClassifyStandardDeviation
* esriClassifyManual

A more useful minimal example is:
```
{
  "type": "classBreaks",
  "field": "age",
  "minValue" : 0,
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
type: simple
field: age
classificationMethod: esriClassifyManual
normalizationType: esriNormalizeNone
normalizationField: null
normalizationTotal: nan
defaultSymbol: <AGSSimpleMarkerSymbol>
defaultLabel: null
backgroundFillSymbol: null
minValue: 0.0
rotationType: geographic
rotationExpression: 
classBreak #1
  classMinValue: nan
  classMaxValue: 25.0
  label: 
  description: 
  symbol: <AGSSimpleMarkerSymbol>
classBreak #2
  classMinValue: nan
  classMaxValue: 100.0
  label: null
  description: null
  symbol: <AGSSimpleMarkerSymbol>
```

## Label Definition Defaults
https://developers.arcgis.com/documentation/common-data-types/labeling-objects.htm

The AGSLabelDefinition object has no properties to inspect.
There is no way to be sure of which properties are optional except by testing.
A guess can be made based on the defaults for the other objects above.
