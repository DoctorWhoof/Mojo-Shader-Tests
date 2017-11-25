
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

uniform vec2 m_Curve;
uniform float m_Border;
uniform float m_BorderFade;

uniform int m_FilterX;
uniform int m_FilterY;

uniform sampler2D m_Shadowmask;
uniform vec2 m_ShadowMaskSize;
uniform float m_ShadowMaskIntensity;

uniform float m_ScanlineIntensity;
uniform float m_ScanlineMinPower;
uniform float m_ScanlineMaxPower;

uniform float m_Glow;
uniform float m_GlowSize;
uniform float m_BlurX;
uniform float m_BlurY;

uniform float m_Mix;
uniform float m_Brightness;
uniform float m_Contrast;
uniform float m_Saturation;

//luma code by hughsk (https://github.com/hughsk/glsl-luma)
float luma( vec3 color) {
  return dot( color, vec3(0.299, 0.587, 0.114 ) );
}

//saturation code from Cesium (https://github.com/AnalyticalGraphicsInc/cesium)
vec3 saturation( vec3 rgb, float value ){
    const vec3 W = vec3(0.2125, 0.7154, 0.0721);
    vec3 intensity = vec3(dot(rgb, W));
    return mix(intensity, rgb, value);
}

//https://gist.github.com/aferriss/9be46b6350a08148da02559278daa244
//use like: vec3 col = finalLevels(someTex.rgb, 34.0/255.0, 1.5, 235.0/255.0);
vec3 gammaCorrect(vec3 color, float gamma){
    return pow(color, vec3(1.0/gamma));
}
vec3 levelRange(vec3 color, float minInput, float maxInput){
    return min(max(color - vec3(minInput), vec3(0.0)) / (vec3(maxInput) - vec3(minInput)), vec3(1.0));
}
vec3 finalLevels(vec3 color, float minInput, float gamma, float maxInput){
    return gammaCorrect(levelRange(color, minInput, maxInput), gamma);
}

//contrast code by Alain Galvan (http://alaingalvan.tumblr.com/post/79864187609/glsl-color-correction-shaders)
vec3 brightnessContrast( vec3 value, float brightness, float contrast){
    return  ( (value - 0.5) * contrast + 0.5 ) * brightness;
}


//*********************** All the rest coded by me! Look ma, I know shaders now! *********************** 


vec3 glow( sampler2D image, vec2 uv, float glowRadius, vec2 res ){
	vec3 result = vec3( 0.0, 0.0, 0.0 );
	vec2 pixSize = vec2( 1.0/m_Resolution.x, 1.0/m_Resolution.y );

	float glowRadiusUV = glowRadius * pixSize.x;
	int samples = int(glowRadius)*2;
	int halfsamples = samples/2;

	for( int x=-halfsamples; x<=halfsamples; x++ ){
		for( int y=-halfsamples; y<=halfsamples; y++ ){
			float posX = float(x)/float(halfsamples);
			float posY = float(y)/float(halfsamples);
			float xoffset = posX*glowRadius*pixSize.x;
			float yoffset = posY*glowRadius*pixSize.y;
			float fade = 1.0 - (abs(posX)*abs(posY));
			result += ( texture2D( image, vec2( uv.x + xoffset, uv.y + yoffset ) ).rgb * fade );
		}
	}
	return result;
}

vec3 nearest( sampler2D image, vec2 uv, vec2 res ){
	vec2 pixSize = vec2( 1.0/res.x, 1.0/res.y );
	vec2 pixHalf = vec2( pixSize.x/2.0, pixSize.y/2.0 );
	vec2 nearPix = vec2( floor(uv.x/pixSize.x)/res.x, floor(uv.y/pixSize.y)/res.y );
	return texture2D( image, vec2( nearPix.x + pixHalf.x, nearPix.y + pixHalf.y ) ).rgb;
}

vec3 nearestY( sampler2D image, vec2 uv, vec2 res ){
	float pixSize = 1.0/res.y;
	float pixHalf = pixSize/2.0;
	float nearPix = floor(uv.y/pixSize)/res.y;
	return texture2D( image, vec2( uv.x, nearPix + pixHalf ) ).rgb;
}

vec3 nearestX( sampler2D image, vec2 uv, vec2 res ){
	float pixSize = 1.0/res.x;
	float pixHalf = pixSize/2.0;
	float nearPix = floor(uv.x/pixSize)/res.x;
	return texture2D( image, vec2( nearPix + pixHalf, uv.y ) ).rgb;
}


float scanline( float y, float res, float power ){
	res = ( 3.14159 * res );
 	return pow( abs( sin(y*res) ), power );
}



void main(){

#if MX2_RENDERPASS==0

	vec3 cleanColor = nearest( m_ImageTexture0, v_UV , m_Resolution );

	int m_FilterX = 1;
	int m_FilterY = 0;
	
	float curveX = sin( v_UV.y * 3.14159 ) * ( 1.0 - v_UV.x - 0.5 ) * m_Curve.x;
	float curveY = sin( v_UV.x * 3.14159 ) * ( 1.0 - v_UV.y - 0.5 ) * m_Curve.y;
	vec2 curvedUV = vec2( v_UV.x + curveX, v_UV.y + curveY );

	vec3 color;
	if( m_FilterY==1 && m_FilterX==1 ){
		color = texture2D( m_ImageTexture0, curvedUV ).rgb;
	} else if( m_FilterY==1 && m_FilterX==0 ){
		color = nearestX( m_ImageTexture0, curvedUV, m_Resolution );
	} else if( m_FilterY==0 && m_FilterX==1 ){
		color = nearestY( m_ImageTexture0, curvedUV, m_Resolution );
	} else {
		color = nearest( m_ImageTexture0, curvedUV, m_Resolution );
	}
	
	vec3 glowColor = glow( m_ImageTexture0, curvedUV, m_GlowSize, m_Resolution ) * ( m_Glow * 0.01 );
	glowColor = finalLevels( glowColor, 0.0, 1.5, 0.25 );
	
	vec3 maskColor = mix( vec3( 1.0, 1.0, 1.0 ), texture2D( m_Shadowmask, ( curvedUV * m_Resolution ) / m_ShadowMaskSize ).rgb, m_ShadowMaskIntensity );
	float beamGap = ( ( 1.0 - ( luma(color) ) ) + m_ScanlineMinPower ) * m_ScanlineMaxPower;
	float scan = mix( 1.0, scanline( curvedUV.y, m_Resolution.y, beamGap ), m_ScanlineIntensity );

	color *= scan;
	color *= maskColor;
	color = max( color, glowColor * 1.5 );
	color += glowColor;
	
	color = brightnessContrast( color, m_Brightness, m_Contrast );
	color = saturation( color, m_Saturation );
	
	float opposite = 1.0 - m_Border;	
	if( curvedUV.x < m_Border ){
		float dist = clamp( ( m_Border - curvedUV.x )/ m_BorderFade, 0.0, 1.0 );
		color *= 1.0 - dist;
	}
	
	if( curvedUV.x > opposite ){
		float dist = clamp( ( curvedUV.x - opposite )/ m_BorderFade, 0.0, 1.0 );
		color *= 1.0 - dist;
	}
	
	if( curvedUV.y < m_Border ){
		float dist = clamp( ( m_Border - curvedUV.y )/ m_BorderFade, 0.0, 1.0 );
		color *= 1.0 - dist;
	}
	
	if( curvedUV.y > opposite ){
		float dist = clamp( ( curvedUV.y - opposite )/ m_BorderFade, 0.0, 1.0 );
		color *= 1.0 - dist;
	}
	
	gl_FragColor.rgb = mix( cleanColor, color, m_Mix );
	gl_FragColor.a = 1.0;
	
#else

	gl_FragColor=vec4( 0.0, 0.0, 0.0, 1.0 );
	
#endif

}

