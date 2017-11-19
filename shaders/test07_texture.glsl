
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
uniform sampler2D m_SharpTexture;
uniform sampler2D m_BlurTexture;
uniform sampler2D m_Scanlines;

uniform vec2 m_Resolution;
uniform float m_ColorBleed;
uniform float m_GlowSize;
uniform float m_GlowGain;
uniform float m_ScanlineFade;

void main(){
	//Scanline texture, mixed with white for fading
	vec4 scanColor = mix( texture2D( m_Scanlines,v_TexCoord0 * m_Resolution ), vec4(1.0, 1.0, 1.0, 1.0), m_ScanlineFade );
	
	//blur offset distance
	vec2 blurOffset = vec2( m_GlowSize / m_Resolution.x, m_GlowSize / m_Resolution.y );
	
	//blur in four directions based on offset
	vec2 leftCoord = vec2( v_TexCoord0.x - blurOffset.x, v_TexCoord0.y );
	vec2 rightCoord = vec2( v_TexCoord0.x + blurOffset.x, v_TexCoord0.y );
	vec2 topCoord = vec2( v_TexCoord0.x, v_TexCoord0.y + blurOffset.y );
	vec2 bottomCoord = vec2( v_TexCoord0.x, v_TexCoord0.y - blurOffset.y );
	
	//blur colors are mixed for final glow color using BlurTexture
	vec4 glowX = mix( texture2D( m_BlurTexture,rightCoord ), texture2D( m_BlurTexture,leftCoord ), 0.5 );
	vec4 glowY = mix( texture2D( m_BlurTexture,topCoord ), texture2D( m_BlurTexture,bottomCoord ), 0.5 );
	vec4 glow = mix( glowX, glowY, 0.5 );
	
	//final color mixing
	vec4 color = texture2D( m_SharpTexture,v_TexCoord0 );
	vec4 colorWithGlow = mix( max( color, glow ), color, 1-m_ColorBleed );
	colorWithGlow += ( glow * m_GlowGain );
	
	gl_FragColor= ( colorWithGlow * v_Color ) * scanColor;
}

