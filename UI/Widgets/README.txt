Widget Style Property Guidelines

=============================
========== GENERAL ==========
=============================
This file contains guidelines for the programming interface based on Ruby hash parameters.
Interface guidelines for the CSS-like style markup will be detailed elsewhere.

In general, widget styling properties should try to adopt the box model style from HTML/CSS.
This means that any overlapping properties will tend to use names from CSS.  Still, if properties
are sufficiently different, it is completely acceptable to brake from established convention.
The aim is not to re-implement HTML/CSS, but the concept of relativistic positioning seen there,
which should be easility understandable from a graphic design standpoint.

There are no inline elements in this style, as there is no natural flow.  This is because this
system is designed to allow for placing of interface widgets, which are mostly graphical data
(ie, images).  In contrast, text layout forms the basis of HTML.

Style Notes within this doc:
Visual		Detail		Explanation
=====		5x =		Section headers
---			3x -		Headers for properties
			\n\n		End of section break
=============================
=============================

===== Position Types =====
--- Static --- (DEFAULT VALUE)
Elements are positioned relative to the viewport.  This is useful for standard HUD-style UI design.
They are positioned according to "normal flow," a concept taken from HTML/CSS

--- Dynamic ---
Elements are placed in-scene, and thus change position on screen as the camera moves.

--- Relative ---
NOTE:	This should be depreciated, as all elements have a relative component
		The only real positioning difference is world vs screen coordinates.
Positioning is calculated relative to another element, instead of to viewport coordinates (static)
or world coordinates (dynamic)

===== Coordinate systems =====
--- Screen coordinates ---
Units:	Px
Axis:	Same as Gosu
		Should be origin in top-left
		X - Pos is right
		Y - Pos is down

--- World coordinates ---
Units:	Meters
Axis:	Specifics defined by physics constants
		Based on trimetric projection
		Right-hand system
		X - To the right
		Y - Into the screen
		Z - Up the screen

===== Relative Placement =====
--- Screen Coordinates ---

	Elements relative to only the screen, should be set such that the relative parameter
	points to a Gosu::Window reference.

--- World Coordinates ---

	Top-level elements (those not relative to any GameObject) should be set relative to nil.
	They will be placed as if they were an Entity, but without any sort of collision object.
	
	If you want to attach a sensor, you should create an GameObject with a sensor object attached,
	and then position the widget relative to that GameObject.


===== Position Control =====
Based on HTML/CSS box model.  Positive values are towards the center of the box, negative is away.

--- top ---

--- bottom ---

--- left ---

--- right ---

--- z_index ---
default value:	0

===== Dimentions =====
--- width ---
default value:	0

--- width_units ---
default value:	px
px, em, percent

--- height ---
default value:	0

--- height_units ---
default value:	px
px, em, percent

===== Alignment of Content =====
--- align ---
default value: left
left, right, center

===== Padding =====
--- padding_top ---

--- padding_bottom ---

--- padding_left ---

--- padding_right ---

===== Borders =====
--- border_top ---

--- border_bottom ---

--- border_left ---

--- border_right ---

===== Color =====
--- color ---
Sets color of text

--- background_color ---






:z_index => 0,
							:relative => window,
							:align => :left,
							
							:position => :static # static, dynamic, relative
							
							:width => 1,
							:width_units => :px,
							:height => 1,
							:height_units => :px,
							
							
