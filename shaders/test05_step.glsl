
//@renderpasses 0
varying vec2 v_Coords;
varying vec4 v_Color;

//@vertex
attribute vec4 a_Position;
attribute vec2 a_TexCoord0;
attribute vec4 a_Color;

uniform mat4 r_ModelViewProjectionMatrix;
uniform vec4 m_ImageColor;

void main(){
	v_Coords = a_TexCoord0;
	v_Color = m_ImageColor * a_Color;
	gl_Position=r_ModelViewProjectionMatrix * a_Position;
}

//@fragment
void main() {

	vec4 color;
	// smoothstep( start, end, current )
	float v1 = smoothstep( 0.25, 0.75, v_Coords.x);

	// smoothstep( threshold, current )
	float v2 = step( 0.5, v_Coords.x);

	if( v_Coords.y > 0.5 ){
		color = vec4( v1, v1, v1, 1.0 );
	} else {
		color = vec4( v2, v2, v2, 1.0 );
	}
	gl_FragColor = color * v_Color;
}
