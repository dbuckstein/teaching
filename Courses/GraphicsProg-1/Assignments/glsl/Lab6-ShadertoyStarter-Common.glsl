/*
This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/ or send a letter to Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
*/
// GLSL STARTER CODE BY DANIEL S. BUCKSTEIN
//  -> COMMON TAB (shared with all other tabs)

//------------------------------------------------------------
// TYPE ALIASES & UTILITY FUNCTIONS

// sScalar: alias for a 1D scalar (non-vector)
#define sScalar float

// sCoord: alias for a 2D coordinate
#define sCoord vec2

// sDCoord: alias for a 2D displacement or measurement
#define sDCoord vec2

// sBasis: alias for a 3D basis vector
#define sBasis vec3

// sPoint: alias for a point/coordinate/location in space
#define sPoint vec4

// sVector: alias for a vector/displacement/change in space
#define sVector vec4


// color3: alias for a 3D vector representing RGB color
// 	(this is non-spatial so neither a point nor vector)
#define color3 vec3

// color4: alias for RGBA color, which is non-spatial
// 	(this is non-spatial so neither a point nor vector)
#define color4 vec4


// asPoint: promote a 3D vector into a 4D vector 
//	representing a point in space (w=1)
//    v: input 3D vector to be converted
sPoint asPoint(in sBasis v)
{
    return sPoint(v, 1.0);
}

// asVector: promote a 3D vector into a 4D vector 
//	representing a vector through space (w=0)
//    v: input 3D vector to be converted
sVector asVector(in sBasis v)
{
    return sVector(v, 0.0);
}


// lengthSq: calculate the squared length of a vector type
//    x: input whose squared length to calculate
sScalar lengthSq(sScalar x)
{
    return (x * x);
    //return dot(x, x); // for consistency with others
}
sScalar lengthSq(sDCoord x)
{
    return dot(x, x);
}
sScalar lengthSq(sBasis x)
{
    return dot(x, x);
}
sScalar lengthSq(sVector x)
{
    return dot(x, x);
}


//------------------------------------------------------------
// VIEWPORT INFO

// sViewport: info about viewport
//    viewportPoint: location on the viewing plane 
//							x = horizontal position
//							y = vertical position
//							z = plane depth (negative focal length)
//	  pixelCoord:    position of pixel in image
//							x = [0, width)	-> [left, right)
//							y = [0, height)	-> [bottom, top)
//	  resolution:    resolution of viewport
//							x = image width in pixels
//							y = image height in pixels
//    resolutionInv: resolution reciprocal
//							x = reciprocal of image width
//							y = reciprocal of image height
//	  size:       	 in-scene dimensions of viewport
//							x = viewport width in scene units
//							y = viewport height in scene units
//	  ndc: 			 normalized device coordinate
//							x = [-1, +1) -> [left, right)
//							y = [-1, +1) -> [bottom, top)
// 	  uv: 			 screen-space (UV) coordinate
//							x = [0, 1) -> [left, right)
//							y = [0, 1) -> [bottom, top)
//	  aspectRatio:   aspect ratio of viewport
//	  focalLength:   distance to viewing plane
struct sViewport
{
    sPoint viewportPoint;
	sCoord pixelCoord;
	sDCoord resolution;
	sDCoord resolutionInv;
	sDCoord size;
	sCoord ndc;
	sCoord uv;
	sScalar aspectRatio;
	sScalar focalLength;
};

// initViewport: calculate the viewing plane (viewport) coordinate
//    vp: 		      output viewport info structure
//    viewportHeight: input height of viewing plane
//    focalLength:    input distance between viewer and viewing plane
//    fragCoord:      input coordinate of current fragment (in pixels)
//    resolution:     input resolution of screen (in pixels)
void initViewport(out sViewport vp,
                  in sScalar viewportHeight, in sScalar focalLength,
                  in sCoord fragCoord, in sDCoord resolution)
{
    vp.pixelCoord = fragCoord;
    vp.resolution = resolution;
    vp.resolutionInv = 1.0 / vp.resolution;
    vp.aspectRatio = vp.resolution.x * vp.resolutionInv.y;
    vp.focalLength = focalLength;
    vp.uv = vp.pixelCoord * vp.resolutionInv;
    vp.ndc = vp.uv * 2.0 - 1.0;
    vp.size = sDCoord(vp.aspectRatio, 1.0) * viewportHeight;
    vp.viewportPoint = asPoint(sBasis(vp.ndc * vp.size * 0.5, -vp.focalLength));
}


//------------------------------------------------------------
// RAY INFO

// sRay: ray data structure
//	  origin: origin point in scene
//    direction: direction vector in scene
struct sRay
{
    sPoint origin;
    sVector direction;
};

// initRayPersp: initialize perspective ray
//    ray: 		   output ray
//    eyePosition: position of viewer in scene
//    viewport:    input viewing plane offset
void initRayPersp(out sRay ray,
             	  in sBasis eyePosition, in sBasis viewport)
{
    // ray origin relative to viewer is the origin
    // w = 1 because it represents a point; can ignore when using
    ray.origin = asPoint(eyePosition);

    // ray direction relative to origin is based on viewing plane coordinate
    // w = 0 because it represents a direction; can ignore when using
    ray.direction = asVector(viewport - eyePosition);
}

// initRayOrtho: initialize orthographic ray
//    ray: 		   output ray
//    eyePosition: position of viewer in scene
//    viewport:    input viewing plane offset
void initRayOrtho(out sRay ray,
             	  in sBasis eyePosition, in sBasis viewport)
{
    // offset eye position to point on plane at the same depth
    initRayPersp(ray, eyePosition + sBasis(viewport.xy, 0.0), viewport);
}


//------------------------------------------------------------
/*
// GLSL FRAGMENT SHADER STRUCTURE WITH COMMON TAB
//  -> This is (likely) how Shadertoy compiles buffer tabs:

// latest version or whichever is used
#version 300 es

// **CONTENTS OF COMMON TAB PASTED HERE**

// PROGRAM UNIFORMS (see 'Shader Inputs' dropdown)

// **CONTENTS OF BUFFER TAB PASTED HERE**

// FRAGMENT SHADER INPUTS (more on this later)

// FRAGMENT SHADER OUTPUTS (framebuffer render target(s))
//out vec4 rtFragColor; // no specific target
layout (location = 0) out vec4 rtFragColor; // default

void main()
{
    // Call 'mainImage' in actual shader main, which is 
	// 	our prototyping interface for ease of use.
	//		rtFragColor:  shader output passed by reference,
	//			full vec4 read in 'mainImage' as 'fragColor'
	//		gl_FragCoord: GLSL's built-in pixel coordinate,
	//			vec2 part read in 'mainImage' as 'fragCoord'
    mainImage(rtFragColor, gl_FragCoord.xy);
}
*/
