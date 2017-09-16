#Import "<std>"
#Import "<mojo>"
#Import "shaders/test03_alpha.glsl"

Using std..
Using mojo..

'In this example, the shader users the canvas color, but adds its own opacity based on the image corners.
'It also demonstrates how to "pre-multiply" colors by the alpha, so that transparency looks correct.

Class MyWindow Extends Window
	
	Field img :Image
	Field pix :Pixmap
	Field testShader :Shader

	Method New()
		Super.New( "Shader test",1024,600,WindowFlags.Resizable  )
		
		Local testShader := New Shader( "test03", LoadString("asset::test03_alpha.glsl"), "" )
		img = New Image( 512, 512, TextureFlags.FilterMipmap, testShader )
		img.Handle = New Vec2f( 0.5 )
	End

	Method OnRender( canvas:Canvas ) Override
		App.RequestRender()
		canvas.Color = Color.Green
		canvas.DrawImage( img, Width/2, Height/2 )
	End
	
End

Function Main()
	New AppInstance
	New MyWindow
	App.Run()
End

