
//@renderpasses 0

varying vec4 v_Color;

//@vertex
attribute vec4 a_Position;
attribute vec4 a_Color;

uniform mat4 r_ModelViewProjectionMatrix;
uniform vec4 m_ImageColor;

void main(){
	v_Color=m_ImageColor * a_Color;
	gl_Position=r_ModelViewProjectionMatrix * a_Position;
}

//@fragment
void main() {
	gl_FragColor = vec4( 1.0, 1.0, 1.0, 1.0 ) * v_Color ;
}
