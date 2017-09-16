
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
//We obtain these two values from Mojo!
uniform float m_Time;
uniform float m_Thickness;

//And here's a function example
float plot( float y, float dotsize ){
	if( v_Coords.y > (y - (dotsize) ) ){
		if( v_Coords.y < (y + (dotsize) ) ){
			return 1.0;
		} else {
			return 0.0;
		}
	}
}

void main() {
	float y = pow( v_Coords.x, m_Time );
	float pvalue = plot(y,m_Thickness);
	float premultValue = (1.0-pvalue)*y;
	gl_FragColor = vec4( pvalue + premultValue, premultValue, premultValue, y+pvalue ) * v_Color ;
}
