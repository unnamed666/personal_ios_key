precision mediump float;
varying mediump vec2 v_texCoord;
varying mediump vec4 v_color;

uniform sampler2D u_texture0;

void main()
{
    vec2 textureCoordinate = v_texCoord;
    float gridCol = texture2D(u_texture0, textureCoordinate).r;
    gl_FragColor = v_color * gridCol;
}
