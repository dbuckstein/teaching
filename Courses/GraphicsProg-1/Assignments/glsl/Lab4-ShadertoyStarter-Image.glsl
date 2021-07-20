/*
This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/ or send a letter to Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
*/
// GLSL STARTER CODE BY DANIEL S. BUCKSTEIN

// asPoint: promote a 3D vector into a 4D vector representing a point (w=1)
//    point: input 3D vector
vec4 asPoint(in vec3 point)
{
    return vec4(point, 1.0);
}

// asOffset: promote a 3D vector into a 4D vector representing an offset (w=0)
//    point: input 3D vector
vec4 asOffset(in vec3 offset)
{
    return vec4(offset, 0.0);
}

// calcViewport: calculate the viewing plane (viewport) coordinate
//    viewport:       output viewing plane coordinate
//    ndc:            output normalized device coordinate
//    uv:             output screen-space coordinate
//    aspect:         output aspect ratio of screen
//    resolutionInv:  output reciprocal of resolution
//    viewportHeight: input height of viewing plane
//    fragCoord:      input coordinate of current fragment (in pixels)
//    resolution:     input resolution of screen (in pixels)
void calcViewport(out vec3 viewport, out vec2 ndc, out vec2 uv,
                  out float aspect, out vec2 resolutionInv,
                  in float viewportHeight, in float focalLength,
                  in vec2 fragCoord, in vec2 resolution)
{
    // inverse (reciprocal) resolution = 1 / resolution
    resolutionInv = 1.0 / resolution;
    
    // aspect ratio = screen width / screen height
    aspect = resolution.x * resolutionInv.y;

    // uv = screen-space coordinate = [0, 1) = coord / resolution
    uv = fragCoord * resolutionInv;

    // ndc = normalized device coordinate = [-1, +1) = uv*2 - 1
    ndc = uv * 2.0 - 1.0;

    // viewport: x = [-aspect*h/2, +aspect*h/2), y = [-h/2, +h/2), z = -f
    viewport = vec3(ndc * vec2(aspect, 1.0) * (viewportHeight * 0.5), -focalLength);
}

// calcRay: calculate the ray direction and origin for the current pixel
//    rayDirection: output direction of ray from origin
//    rayOrigin:    output origin point of ray
//    viewport:     input viewing plane coordinate (use above function to calculate)
//    focalLength:  input distance to viewing plane
void calcRay(out vec4 rayDirection, out vec4 rayOrigin,
             in vec3 eyePosition, in vec3 viewport)
{
    // ray origin relative to viewer is the origin
    // w = 1 because it represents a point; can ignore when using
    rayOrigin = asPoint(eyePosition);

    // ray direction relative to origin is based on viewing plane coordinate
    // w = 0 because it represents a direction; can ignore when using
    rayDirection = asOffset(viewport - eyePosition);
}

// calcColor: calculate the color of a pixel given a ray
//    rayDirection: input ray direction
//    rayOrigin:    input ray origin
vec4 calcColor(in vec4 rayDirection, in vec4 rayOrigin)
{
    // DUMMY RESULT: OUTPUT RAY DIRECTION AS-IS
    //  -> what does the ray look like as color?
    //return rayDirection;
	
	// BACKGROUND
	const vec3 warm = vec3(0.8, 0.4, 0.2), cool = vec3(0.2, 0.4, 0.8);
	return vec4(mix(warm, cool, rayDirection.y), 1.0);
}

// mainImage: process the current pixel (exactly one call per pixel)
//    fragColor: output final color for current pixel
//    fragCoord: input location of current pixel in image (in pixels)
void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    // viewing plane (viewport) info
    vec3 viewport;
    vec2 ndc, uv, resolutionInv;
    float aspect;
    const float viewportHeight = 2.0, focalLength = 1.0;

    // ray
    vec4 rayDirection, rayOrigin;

    // setup
    fragColor = vec4(0.0);
    
    calcViewport(viewport, ndc, uv, aspect, resolutionInv,
    	             viewportHeight, focalLength,
    	             fragCoord, iResolution.xy);
    calcRay(rayDirection, rayOrigin, vec3(0.0), viewport);
    
    fragColor += calcColor(rayDirection, rayOrigin);
}
