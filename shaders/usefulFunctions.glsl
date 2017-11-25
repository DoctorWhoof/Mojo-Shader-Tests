//blur code by Jam3 (https://github.com/Jam3/glsl-fast-gaussian-blur)
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
	vec2 pixSize = vec2( 1.0/m_Resolution.x, 1.0/m_Resolution.y );									//Dimensions for each virtual pixel

	float glowRadiusUV = glowRadius * pixSize.x;
	int samples = int(glowRadius)*2;
	int halfsamples = samples/2;

	for( int x=-halfsamples; x<=halfsamples; x++ ){
		for( int y=-halfsamples; y<=halfsamples; y++ ){
			float posX = float(x)/float(halfsamples);
			float posY = float(y)/float(halfsamples);
			float xoffset = posX*glowRadius*pixSize.x;
			float yoffset = posY*glowRadius*pixSize.y;
			// float fade = 1.0 - ( distance( vec2(0.0,0.0), vec2( xoffset, yoffset ) ) / glowRadiusUV );
			float fade = 1.0 - (abs(posX)*abs(posY));
			result += ( texture2D( image, vec2( uv.x + xoffset, uv.y + yoffset ) ).rgb * fade );
		}
	}
	return result;
}

vec3 nearest( sampler2D image, vec2 uv, vec2 res ){
	vec2 pixSize = vec2( 1.0/res.x, 1.0/res.y );													//Dimensions for each virtual pixel
	vec2 pixHalf = vec2( pixSize.x/2.0, pixSize.y/2.0 );											//Half a pixel's dimensions
	vec2 nearPix = vec2( floor(uv.x/pixSize.x)/res.x, floor(uv.y/pixSize.y)/res.y );
	return texture2D( image, vec2( nearPix.x + pixHalf.x, nearPix.y + pixHalf.y ) ).rgb;
}

vec3 nearestY( sampler2D image, vec2 uv, vec2 res ){
	float pixSize = 1.0/res.y;									//Dimensions for each virtual pixel
	float pixHalf = pixSize/2.0;										//Half a pixel's dimensions
	float nearPix = floor(uv.y/pixSize)/res.y;
	return texture2D( image, vec2( uv.x, nearPix + pixHalf ) ).rgb;
}

vec3 nearestX( sampler2D image, vec2 uv, vec2 res ){
	float pixSize = 1.0/res.x;									//Dimensions for each virtual pixel
	float pixHalf = pixSize/2.0;										//Half a pixel's dimensions
	float nearPix = floor(uv.x/pixSize)/res.x;
	return texture2D( image, vec2( nearPix + pixHalf, uv.y ) ).rgb;
}


float scanline( float y, float res, float power ){
	res = ( 3.14159 * res );
 	return pow( abs( sin(y*res) ), power );
}

// Experimental. Returns a curve that smoothly rises to a value as x increases, then smoothly decreases.
//Centered around the duration (like a scanline on a pixel...)

// float y( float x ) {
//   float easeLength = 0.5;
//   float duration = 1.0;
//   float p1 = (1.0-duration)*0.5;
//   float p2 = p1 + duration;
//   float e1 = p1-easeLength;
//   return smoothstep( e1, e1+easeLength, x ) - smoothstep( p2, p2+easeLength, x );
// }