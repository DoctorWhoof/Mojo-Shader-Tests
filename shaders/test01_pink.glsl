
//@renderpasses 0

//@vertex
attribute vec4 a_Position;
uniform mat4 r_ModelViewProjectionMatrix;

void main(){
	gl_Position = r_ModelViewProjectionMatrix * a_Position;
}

//@fragment
void main() {
	gl_FragColor = vec4( 1.0, 0.0, 1.0, 1.0 );
}
