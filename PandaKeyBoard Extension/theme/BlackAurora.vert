attribute vec2 a_texCoord;
attribute vec4 a_position;
uniform mat4 modelViewProjection;

varying mediump vec2 v_texCoord;
varying mediump vec4 v_color;

uniform float CC_Time;

const float u_scale = 0.2;

const vec4 color2 = vec4(0., 254./255., 227./255., 1.);

const float M_PI = 3.1415926535897932384;

const float WAVE_SPEED = 0.5;

vec2 polarCoordToCartesianCoord(float radius, float rad)
{
    vec2 result;
    result.x = radius * cos(rad);
    result.y = radius * sin(rad);
    
    return result;
}

void main() {
    
    v_texCoord = a_texCoord;
    
    float glow = 1.0;

    mat4 CC_MVPMatrix = modelViewProjection;
    {
        float g = a_position.x;
        g = smoothstep(0., 400. * (1. + a_texCoord.y * 5.) * u_scale, g);
        g = 1. - g;
        
        glow += g * 0.7 * (sin(CC_Time) + 1.) * 0.5;
    }
    
    // Simulate Touch
    {
        float g = abs(sin(CC_Time*0.5)*0.6+0.3 - a_texCoord.x);
        g = smoothstep(0., (1. + a_texCoord.y) * 0.1, g); // was 250   // was 187
        g = 1. - g;

        glow += g * 7.;
    }
    
//    glow = min(glow, 3.);   // was 2.5
    
//    glow += a_texCoord.x;
    
    vec4 pos = a_position;
    pos.yz = polarCoordToCartesianCoord(150. * u_scale + cos(CC_Time * WAVE_SPEED + a_texCoord.x * 4.) * 60., (a_texCoord.y-0.5) * M_PI + CC_Time * WAVE_SPEED + a_texCoord.x*2. + sin(a_texCoord.x + CC_Time) * 0.3);
    
    pos.z += (sin(a_texCoord.x * 2. + CC_Time * WAVE_SPEED * 2.) - 1.) * 30.;
    
//    pos = a_position;
    
    gl_Position = CC_MVPMatrix * pos;
    
    float dl = (120. / (gl_Position.z - 1000.));
    dl = dl * 0.5 + 0.5;
    float l = 0.4 * (1. + glow * 3.);
    l *= dl;
    
    v_color = color2 * l;
}
