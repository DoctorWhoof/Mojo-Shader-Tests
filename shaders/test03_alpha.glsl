
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
	float alpha = v_Coords.x * v_Coords.y;
	vec4 premult = v_Color * alpha;
	gl_FragColor = vec4( premult.x, premult.y, premult.z, alpha);
}
