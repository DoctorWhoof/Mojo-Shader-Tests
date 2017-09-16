#Import "<std>"
#Import "<mojo>"
#Import "shaders/test05_step.glsl"

Using std..
Using mojo..

'The shader now demonstrates the use of two functions, "step" and "smoothstep"

Class MyWindow Extends Window
	
	Field img :Image
	Field testShader :Shader

	Field style:Int = 0

	Method New()
		Super.New( "Shader test",1024,600,WindowFlags.Resizable  )
		
		Local testShader := New Shader( "test05", LoadString("asset::test05_step.glsl"), "" )
		img = New Image( 512, 512, TextureFlags.FilterMipmap, testShader )
		img.Handle = New Vec2f( 0.5 )
	End

	Method OnRender( canvas:Canvas ) Override
		App.RequestRender()
		canvas.DrawImage( img, Width/2, Height/2 )
	End
	
End

Function Main()
	New AppInstance
	New MyWindow
	App.Run()
End



