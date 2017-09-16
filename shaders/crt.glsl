
//Simple black/white shader effect

uniform sampler2D ColorTexture;
uniform float aspectRatio;
uniform float EffectLevel;
uniform float BorderLevel;

//uniform float ldist;
//uniform float EffectLevel;
//uniform float SinOffset;

void shader(){

	//convert clip position to valid tex coords
	vec2 texcoords=(b3d_ClipPosition.st/b3d_ClipPosition.w)*0.5+0.5;
	
	//read source color
	//vec3 color=texture2D( ColorTexture,texcoords).rgb;
//	BorderLevel*=0.1;
	float bl = BorderLevel*0.1;
	float x = texcoords.x*(1.0+bl)-bl/2.0;
	float y = texcoords.y*(1.0+bl)-bl/2.0;
	
	float x2 = (x-0.5)*(1.0+  0.5*EffectLevel  *((y-(aspectRatio/2.0))*(y-(aspectRatio/2.0))))+0.5;
	float y2 = (y-aspectRatio/2.0)*(1.0+  0.25*EffectLevel  *((x-0.5)*(x-0.5)))+aspectRatio/2.0;
	
	vec2 v2 = vec2(
					//(x-0.5)*(1.0+  0.5*EffectLevel  *((y-(aspectRatio/2.0))*(y-(aspectRatio/2.0))))+0.5,
					//(y-aspectRatio/2.0)*(1.0+  0.25*EffectLevel  *((x-0.5)*(x-0.5)))+aspectRatio/2.0
					//float(int(x2*768.0))/768.0+0.5/768.0,
					//float(int(y2*680.0))/680.0+0.5/680.0
					x2,
					y2
					);
	vec3 color=texture2D(ColorTexture, v2).rgb;
	if(2.0*abs(v2.x-0.5) > 1.0) color *= 0.0;// vec3(0.0, 0.0, 0.0);
	else if(2.0*abs(v2.y-aspectRatio/2.0) > aspectRatio) color *= 0.0;//vec3(0.0, 0.0, 0.0);
	
	//calculate b/w color
	//vec3 result=vec3( (color.r+color.g+color.b)/3.0 );
	
	//mix based on effect level
	//color=mix( color,result,EffectLevel );
	
	vec3 tempColor = color;
//	float scanline = sin((y2*240.0+0.5)*2.0*3.1415)     *0.75+0.25+0.1;   if(scanline < 0.0) scanline = 0.0;
//	if(scanline < 0) scanline = 0;
//	tempColor = mix(color, vec3(0.0,0.0,0.0), scanline*0.5);
	
	//ldist = 1.0;//34;
	float cr = sin((x2*256.0)                *2.0*3.1415) * 0.5+0.5+0.1;   //if(cr < 0.0) cr = 0.0;
	float cg = sin((x2*256.0+0.33*1.5*3.1415)*2.0*3.1415) * 0.5+0.5+0.1;   //if(cg < 0.0) cg = 0.0;
	float cb = sin((x2*256.0+0.66*1.5*3.1415)*2.0*3.1415) * 0.5+0.5+0.1;   //if(cb < 0.0) cb = 0.0;
	
	tempColor = vec3(tempColor.r*cr, tempColor.g*cg, tempColor.b*cb);
	color = mix(color, tempColor, 0.5);

	//color = vec3( (color.r + color.r*cr)*0.5,
	//              (color.g + color.g*cg)*0.5,
	//              (color.b + color.b*cb)*0.5
	//            );
//	color = mix(color, vec3(color.r*cr, color.g*cg, color.b*cb), 0.75);

	//write output
	b3d_FragColor=vec4(color, 1.0);
//	b3d_FragColor=vec4( 0.0, 0.5, 0.5, 1.0 );
}

