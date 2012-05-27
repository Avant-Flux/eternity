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
Positioning is calculated relative to another element, instead of to viewport coordinates (static)
or world coordinates (dynamic)


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
							
							
