
//@renderpasses 0,1,2
varying vec2 v_TexCoord0;
varying vec4 v_Color;

//@vertex
attribute vec4 a_Position;
attribute vec2 a_TexCoord0;
attribute vec4 a_Color;

uniform mat4 r_ModelViewProjectionMatrix;
uniform vec4 m_ImageColor;

void main(){
    v_TexCoord0 = a_TexCoord0;
    v_Color = m_ImageColor * a_Color;
    gl_Position=r_ModelViewProjectionMatrix * a_Position;
}

//@fragment
uniform sampler2D m_ImageTexture0;
uniform sampler2D m_Scanlines;
uniform sampler2D m_Shadowmask;

uniform vec2 m_Resolution;

uniform float m_Mix;
uniform float m_BlurX;
uniform float m_BlurY;
uniform float m_Brightness;
uniform float m_Gamma;

uniform float m_Bleed;
uniform float m_BleedSize;
uniform float m_Glow;
uniform float m_GlowSize;
uniform float m_ScanlineIntensity;
uniform float m_ShadowMaskIntensity;

//blur code by Jam3 (https://github.com/Jam3/glsl-fast-gaussian-blur)
vec4 blur(sampler2D image, vec2 uv, vec2 resolution, vec2 direction) {
  vec4 color = vec4(0.0);
  vec2 off1 = vec2(1.3333333333333333) * direction;
  color += texture2D(image, uv) * 0.29411764705882354;
  color += texture2D(image, uv + (off1 / resolution)) * 0.35294117647058826;
  color += texture2D(image, uv - (off1 / resolution)) * 0.35294117647058826;
  return color; 
}

vec3 gamma( vec3 value, float g ) {
  return pow( value, vec3( 1.0 / g ) );
}

vec4 gamma( vec4 value, float g ) {
  return vec4( gamma( value.rgb, g ), value.a );
}

vec4 bleed( vec4 sourceColor, sampler2D image, vec2 uv, vec2 resolution, vec2 direction ){
	vec4 colorL = texture2D( image, uv + (direction / resolution) );
	vec4 colorR = texture2D( image, uv - (direction / resolution) );
	vec4 maxL = max( sourceColor, colorL );
	vec4 maxR = max( sourceColor, colorR );
	return mix( maxL, maxR, 0.5);
}

vec4 edgeglow(sampler2D image, vec2 uv, vec2 resolution, float size ) {
	vec4 color = texture2D( image, uv );
	vec4 color1 = bleed( color, image, uv, resolution, vec2( size, 0 ) );
	vec4 color2 = bleed( color, image, uv, resolution, vec2( size * 0.5, 0 ) );
	vec4 color3 = bleed( color, image, uv, resolution, vec2( 0, size * 0.5 ) );
	vec4 effect = max( mix( color1, color2, 0.5 ), color3 );
	return ( effect - color ) * m_Bleed;
}

void main(){

	vec4 scanColor = mix( vec4(1.0, 1.0, 1.0, 1.0), texture2D( m_Scanlines, v_TexCoord0 * m_Resolution ), m_ScanlineIntensity );
	vec4 maskColor = mix( vec4(1.0, 1.0, 1.0, 1.0), texture2D( m_Shadowmask, v_TexCoord0 * m_Resolution ), m_ShadowMaskIntensity );

	vec4 glow = blur( m_ImageTexture0, v_TexCoord0, m_Resolution, vec2( m_GlowSize, 0.0 ) ) * m_Glow;
	glow += edgeglow( m_ImageTexture0, v_TexCoord0, m_Resolution, m_BleedSize );

	vec4 color = texture2D( m_ImageTexture0, v_TexCoord0 );
	
	vec4 colorBlur = blur( m_ImageTexture0, v_TexCoord0, m_Resolution, vec2( m_BlurX, 0 ) );
	colorBlur = mix( color, blur( m_ImageTexture0, v_TexCoord0, m_Resolution, vec2( 0, m_BlurY ) ), 0.5 );

	vec4 colorWithEffects = gamma( ( ( colorBlur * v_Color * scanColor * maskColor ) + glow ) * m_Brightness, m_Gamma );

	gl_FragColor = mix( color, colorWithEffects, m_Mix );
}

