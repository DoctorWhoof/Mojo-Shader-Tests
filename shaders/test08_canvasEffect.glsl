
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


vec3 blur( sampler2D image, vec2 uv, float glowRadius, vec2 res, int samples ){
	vec3 result = vec3( 0.0, 0.0, 0.0 );
	vec2 pixSize = vec2( 1.0/res.x, 1.0/res.y );									//Dimensions for each virtual pixel
	float glowRadiusUV = glowRadius * pixSize.x;
	
	//int samples = int(glowRadius)*2;
	int halfsamples = samples/2;
	float sampleCount;

	for( int x=-halfsamples; x<=halfsamples; x++ ){
		for( int y=-halfsamples; y<=halfsamples; y++ ){
			float posX = float(x)/float(halfsamples);
			float posY = float(y)/float(halfsamples);
			float xoffset = posX*glowRadius*pixSize.x;
			float yoffset = posY*glowRadius*pixSize.y;
			float fade = 1.0 - (abs(posX)*abs(posY));
			result += ( texture2D( image, vec2( uv.x + xoffset, uv.y + yoffset ) ).rgb * fade );
			sampleCount += 1.0;
		}
	}
	return result * (1.0/sampleCount*1.5);
}


float gradient( float y, float size, float power ){
	size = ( 3.14159 * size );
 	return pow( abs( sin(y*size) ), power );
}

void main(){
#if MX2_RENDERPASS==0

	if( m_Bypass < 0.5 ){
		
		float maskVignette =  gradient( v_UV.x, 1.0, m_VignetteSpread ) * gradient( v_UV.y, 1.0, m_VignetteSpread );
		float maskBlur =  gradient( v_UV.x, 1.0, 1.0 ) * gradient( v_UV.y, 1.0, 1.0 );
		float border = smoothstep( 0.35, 0.4, maskVignette );
	
		vec3 blurColor = blur( m_ImageTexture0, v_UV, (1.0-maskBlur)*m_Blur, m_Resolution/2.0, 8 );
	
		gl_FragColor= vec4( blurColor * border * maskVignette, 1.0 );
		
	} else {
	
		vec3 color = texture2D( m_ImageTexture0, vec2( v_UV.x, v_UV.y) ).rgb;
		gl_FragColor=vec4( color, 1.0 );
		
	}
#else
	gl_FragColor=vec4( 0.0, 0.0, 0.0, 1.0 );
#endif

}

