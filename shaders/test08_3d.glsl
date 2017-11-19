
//@renderpasses 0
varying vec4 v_Color;
varying vec2 v_TexCoord0;

//@vertex
attribute vec4 a_Position;
attribute vec2 a_TexCoord0;
attribute vec4 a_Color;

uniform mat4 r_ModelViewProjectionMatrix;

void main(){
	v_TexCoord0 = a_TexCoord0;
	v_Color = a_Color;
	gl_Position=r_ModelViewProjectionMatrix * a_Position;
}

//@fragment
uniform sampler2D m_ColorTexture;
uniform vec4 m_ColorFactor;
uniform float m_Time;

void main(){
	// vec3 color=pow( texture2D( m_ColorTexture,v_TexCoord0 ).rgb,vec3( 2.2 ) ) * m_ColorFactor.rgb;
	vec4 color = vec4( 1.0, 0.0, 0.0, 1.0 ) * v_Color;
	float alpha=texture2D( m_ColorTexture, v_TexCoord0 ).a * m_ColorFactor.a;

	gl_FragColor=vec4( color * alpha );
}
