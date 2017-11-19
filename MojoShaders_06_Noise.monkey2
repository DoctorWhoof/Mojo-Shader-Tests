#Import "<std>"
#Import "<mojo>"
#Import "shaders/test06_noise.glsl"

Using std..
Using mojo..

'A simple noise function"

Class MyWindow Extends Window

	Field img :Image
	Field testShader :Shader

	Field style:Int = 0

	Method New()
		Super.New( "Shader test",1024,1024,WindowFlags.Resizable  )

		Local testShader := New Shader( "test06", LoadString("asset::test06_noise.glsl"), "" )

		img = New Image( 512, 512, TextureFlags.FilterMipmap, testShader )
		img.Handle = New Vec2f( 0.5 )
	End

	Method OnRender( canvas:Canvas ) Override
		App.RequestRender()
		img.Material.SetFloat( "Time", Millisecs()/10000000.0 )
		canvas.DrawImage( img, Width/2, Height/2, 0, App.ActiveWindow.Width / 512.0, App.ActiveWindow.Height / 512.0  )
	End

End

Function Main()
	New AppInstance
	New MyWindow
	App.Run()
End
