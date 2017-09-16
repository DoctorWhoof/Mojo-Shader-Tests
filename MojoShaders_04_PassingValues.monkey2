#Import "<std>"
#Import "<mojo>"
#Import "shaders/test04_plot.glsl"

Using std..
Using mojo..

'Here we get a little fancier! The shader shows the use of a function "plot"
'But the most important: we pass a value "Time" to the shader on every frame using "Image.Material.SetFloat"'

Class MyWindow Extends Window
	
	Field img :Image
	Field testShader :Shader
	
	Field thickness:Float = 0.005

	Method New()
		Super.New( "Shader test",1024,600,WindowFlags.Resizable  )
		
		Local testShader := New Shader( "test04", LoadString("asset::test04_plot.glsl"), "" )
		img = New Image( 512, 512, TextureFlags.FilterMipmap, testShader )
		img.Handle = New Vec2f( 0.5 )
		
		img.Material.SetFloat( "Thickness", thickness)
	End

	Method OnRender( canvas:Canvas ) Override
		App.RequestRender()
		
		'Here we pass this value to the shader, as "m_Time"!
		Local time := Millisecs()/5000.0 
		img.Material.SetFloat( "Time", time)
		
		canvas.DrawText( "m_Thickness = " + thickness, 10, 10 )
		canvas.DrawText( "m_Time = " + time, 10, 30 )
		canvas.DrawImage( img, Width/2, Height/2 )
	End
	
End

Function Main()
	New AppInstance
	New MyWindow
	App.Run()
End



