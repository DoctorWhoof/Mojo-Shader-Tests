
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
uniform vec2 m_Resolution;
uniform float m_Bypass;
uniform float m_Vignette;
uniform float m_VignetteSpread;
uniform float m_Blur;
uniform float m_BlurSpread;
uniform float m_BlurSamples;	//ints not working with mojo? using float for now.


vec3 blur( sampler2D image, vec2 uv, float radius, vec2 res, int samples ){
	vec3 result = vec3( 0.0, 0.0, 0.0 );
	
	vec2 pixSize = vec2( 1.0/res.x, 1.0/res.y );									//Dimensions for each virtual pixel

	if( samples > 1 ) {
		float sampleCount = 0.0;
		float sampleStep = 1.0/float(samples-1);
		for( float x = -0.5; x <= 0.5; x+=sampleStep ){
			for( float y = -0.5; y <= 0.5; y+=sampleStep ){
				vec2 offset = vec2( x*pixSize.x*radius, y*pixSize.y*radius );
				result += ( texture2D( image, vec2( uv.x + offset.x, uv.y + offset.y ) ).rgb );
				sampleCount += 1.0;
			}
		}
		result *= (1.0/sampleCount);
	} else {
		result = texture2D( image, vec2( uv.x, uv.y ) ).rgb;	
	}
	return result;
}


float gradient( float y, float size, float power ){
	size = ( 3.14159 * size );
 	return pow( abs( sin(y*size) ), power );
}

void main(){
#if MX2_RENDERPASS==0

	if( m_Bypass < 0.5 ){
		
		float maskVignette =  gradient( v_UV.x, 1.0, m_VignetteSpread ) * gradient( v_UV.y, 1.0, m_VignetteSpread );
		float maskBlur =  1.0 - gradient( v_UV.x, 1.0, m_BlurSpread ) * gradient( v_UV.y, 1.0, m_BlurSpread );
		float border = smoothstep( 0.35, 0.4, maskVignette );
	
		int samples = 2 + int( abs(maskBlur * (m_BlurSamples-2) ) );	//2 is the minimum, m_BlurSamples is the maximum
		vec3 blurColor = blur( m_ImageTexture0, v_UV, maskBlur*m_Blur+0.25, m_Resolution, samples );
	
		gl_FragColor= vec4( blurColor * border * maskVignette, 1.0 );
		
	} else {
	
		vec3 color = texture2D( m_ImageTexture0, vec2( v_UV.x, v_UV.y) ).rgb;
		gl_FragColor=vec4( color, 1.0 );
		
	}
#else
	gl_FragColor=vec4( 0.0, 0.0, 0.0, 1.0 );
#endif

}

