#Import "<std>"
#Import "<mojo>"
#Import "shaders/test02_color.glsl"

Using std..
Using mojo..

'In this example, the shader takes the canvas.Color through the attribute "a_Color".
'A color cycling is performed in the canvas.Color, not in the shader.

Class MyWindow Extends Window
	
	Field img :Image
	Field testShader :Shader

	Method New()
		Super.New( "Shader test",1024,600,WindowFlags.Resizable  )
		
		Local testShader := New Shader( "test02", LoadString("asset::test02_color.glsl"), "" )
		img = New Image( 512, 512, TextureFlags.FilterMipmap, testShader )
		img.Handle = New Vec2f( 0.5 )
	End

	Method OnRender( canvas:Canvas ) Override
		App.RequestRender()
		
		Local flash := Abs( Sin(Millisecs()/500.0) )	'Negative values won't look right, so we use Abs() to remove them
		
		canvas.Color = New Color( flash, flash , flash ) 
		canvas.DrawImage( img, Width/2, Height/2 )
	End
	
End

Function Main()
	New AppInstance
	New MyWindow
	App.Run()
End
