#version 450
//#version 300 es
/*
This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/ or send a letter to Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
*/

#ifdef GL_ES
precision highp float;
#endif	// GL_ES


layout (location = 0) out vec4 rtFragColor;

layout (binding = 0) uniform ubLightData{
	vec4 data;
};

void main()
{
	rtFragColor = vec4(1.0);
}