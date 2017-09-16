
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
uniform float m_Time;

float random (vec2 coords) {
	return fract(sin(dot( coords, vec2(12.9898,78.233)))*43758.5453123 * fract(m_Time) );
}

void main() {
	vec2 scaledCoords = v_Coords * 20.0; // Scale the coordinate system by 10
	vec2 intCoords = floor(scaledCoords);  // get the integer coords

	gl_FragColor = vec4( vec3( random( intCoords ) ), 1.0 ) * v_Color;
}
