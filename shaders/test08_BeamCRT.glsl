
//@renderpasses 0,1,2
varying vec2 v_UV;
varying vec4 v_Color;

//@vertex
attribute vec4 a_Position;
attribute vec2 a_TexCoord0;
attribute vec4 a_Color;

uniform mat4 r_ModelViewProjectionMatrix;
uniform vec4 m_ImageColor;

void main(){
    v_UV = a_TexCoord0;
    v_Color = m_ImageColor * a_Color;
    gl_Position=r_ModelViewProjectionMatrix * a_Position;
}

//@fragment
uniform sampler2D m_ImageTexture0;
uniform sampler2D m_Shadowmask;

uniform vec2 m_Resolution;

uniform float m_Mix;
uniform float m_Brightness;
uniform float m_Gamma;
uniform float m_Saturation;

uniform float m_BlurX;
uniform float m_BlurY;
uniform float m_Glow;
uniform float m_GlowSize;
uniform float m_ScanlineIntensity;
uniform float m_ShadowMaskIntensity;

//blur code by Jam3 (https://github.com/Jam3/glsl-fast-gaussian-blur)
//luma code by hughsk (https://github.com/hughsk/glsl-luma)

vec4 blur(sampler2D image, vec2 uv, vec2 resolution, vec2 direction) {
  vec4 color = vec4(0.0);
  vec2 off1 = vec2(1.411764705882353) * direction;
  vec2 off2 = vec2(3.2941176470588234) * direction;
  vec2 off3 = vec2(5.176470588235294) * direction;
  color += texture2D(image, uv) * 0.1964825501511404;
  color += texture2D(image, uv + (off1 / resolution)) * 0.2969069646728344;
  color += texture2D(image, uv - (off1 / resolution)) * 0.2969069646728344;
  color += texture2D(image, uv + (off2 / resolution)) * 0.09447039785044732;
  color += texture2D(image, uv - (off2 / resolution)) * 0.09447039785044732;
  color += texture2D(image, uv + (off3 / resolution)) * 0.010381362401148057;
  color += texture2D(image, uv - (off3 / resolution)) * 0.010381362401148057;
  return color;
}

vec3 gamma( vec3 value, float g ) {
  return pow( value, vec3( 1.0 / g ) );
}

vec4 gamma( vec4 value, float g ) {
  return vec4( gamma( value.rgb, g ), value.a );
}

float luma( vec4 color) {
  return dot(color.rgb, vec3(0.299, 0.587, 0.114));
}

vec3 saturation( vec3 rgb, float value ){
    const vec3 W = vec3(0.2125, 0.7154, 0.0721);
    vec3 intensity = vec3(dot(rgb, W));
    return mix(intensity, rgb, value);
}

//To do: extend horizontal "reach" of the smoothstep function if y=middle of the pixel

void main(){
	vec4 color = texture2D( m_ImageTexture0, v_UV );
	vec4 maskColor = mix( vec4(1.0, 1.0, 1.0, 1.0), texture2D( m_Shadowmask, v_UV * m_Resolution ), m_ShadowMaskIntensity );

	vec2 pixSize = vec2( 1.0/m_Resolution.x, 1.0/m_Resolution.y );
	vec2 seg = vec2( fract( v_UV.x / pixSize.x ), fract(v_UV.y / pixSize.y ) ) ;

	vec4 sourceColor = texture2D( m_ImageTexture0, vec2( v_UV.x - pixSize.x, v_UV.y ) );
	vec4 colorBlur = mix( sourceColor, color, smoothstep( 0.0, 1.0, seg.x ) );

	float beamWidth = 0.5 + ( luma( colorBlur ) * 4.0 ) ;
	float scanline = ( 1.0 - pow( seg.y, beamWidth ) ) * ( 1.0 - pow( 1.0-seg.y, beamWidth ) ) * 2.0;

	vec4 glowX = blur( m_ImageTexture0, v_UV, m_Resolution, vec2( m_GlowSize, 0 ) );
	vec4 glowY = blur( m_ImageTexture0, v_UV, m_Resolution, vec2( 0.0, m_GlowSize ) );
	// vec4 glow = gamma( mix( glowX, glowY, 0.5 ), 0.5 );// * m_Glow;

	vec4 colorFinal = gamma( ( colorBlur * scanline * maskColor ) * m_Brightness, m_Gamma );
	colorFinal = vec4( saturation( colorFinal.rgb, m_Saturation ), 1.0 );
	colorFinal = mix( colorFinal, colorBlur, 1.0 - m_ScanlineIntensity );

	// colorFinal = mix( colorFinal, mix( glowX, glowY, 0.5 ), 0.5 );

	gl_FragColor = mix( color, colorFinal, m_Mix );


}

