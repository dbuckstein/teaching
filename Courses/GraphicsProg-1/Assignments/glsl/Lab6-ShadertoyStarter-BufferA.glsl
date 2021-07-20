/*
This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/ or send a letter to Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
*/
// GLSL STARTER CODE BY DANIEL S. BUCKSTEIN
//  -> BUFFER A TAB (scene)

//------------------------------------------------------------
// RENDERING FUNCTIONS

// calcColor: calculate the color of current pixel
//	  vp:  input viewport info
//	  ray: input ray info
color4 calcColor(in sViewport vp, in sRay ray)
{
    // test inputs
    //return color4(ray.direction.xyz == vp.viewportPoint.xyz); // pass
    //return color4(lengthSq(vp.viewportPoint.xy) >= 0.25); // pass
    //return color4(vp.uv, 0.0, 0.0);
    //return color4(vp.ndc, 0.0, 0.0);
    return asPoint(sBasis(vp.viewportPoint.xy, -vp.viewportPoint.z));
}


//------------------------------------------------------------
// SHADERTOY MAIN

// mainImage: process the current pixel (exactly one call per pixel)
//    fragColor: output final color for current pixel
//    fragCoord: input location of current pixel in image (in pixels)
void mainImage(out color4 fragColor, in sCoord fragCoord)
{
    // viewing plane (viewport) inputs
    const sBasis eyePosition = sBasis(0.0);
    const sScalar viewportHeight = 2.0, focalLength = 1.5;
    
    // viewport info
    sViewport vp;

    // ray
    sRay ray;
    
    // render
    initViewport(vp, viewportHeight, focalLength, fragCoord, iResolution.xy);
    initRayPersp(ray, eyePosition, vp.viewportPoint.xyz);
    fragColor += calcColor(vp, ray);
}
