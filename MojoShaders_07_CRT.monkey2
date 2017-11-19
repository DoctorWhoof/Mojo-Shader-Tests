#Import "<std>"
#Import "<mojo>"
#Import "<mojo3d>"
#Import "shaders/test07_CRT.glsl"

#Import "images/"

Using std..
Using mojo..

'A CRT shader"

Class MyWindow Extends Window

	Field img :Image
	Field imgClean :Image
	Field scale :Vec2f
	Field zoom := 8.0

	Method New()
		Super.New( "Shader test",2880,1800,WindowFlags.Resizable  )
		ClearColor = Color.Black

		Local tex := Texture.Load( "asset::frame.png", TextureFlags.None )
		Local texBlur := Texture.Load( "asset::frame.png", TextureFlags.FilterMipmap )
		Local texScan := Texture.Load( "asset::scanline16px.png", TextureFlags.FilterMipmap | TextureFlags.WrapST )
		Local texMask := Texture.Load( "asset::shadowMask16px.png", TextureFlags.FilterMipmap | TextureFlags.WrapST )
		
		Local testShader := New Shader( "test07", LoadString("asset::test07_CRT.glsl"), "" )

		img = New Image( tex.Width * zoom, tex.Height * zoom,, testShader )
		img.Handle = New Vec2f( 0.5 )
		
		scale = New Vec2f( img.Width/tex.Width, img.Height/tex.Height )
		
		img.Material.SetTexture( "SharpTexture", tex )
		img.Material.SetTexture( "BlurTexture", texBlur )
		img.Material.SetTexture( "Scanlines", texScan )
		img.Material.SetTexture( "Shadowmask", texMask )
		img.Material.SetVec2f( "Resolution", New Vec2f( tex.Width, tex.Height ) )
		img.Material.SetFloat( "ColorBleed", 1.1 )
		img.Material.SetFloat( "GlowGain", 0.15 )
		img.Material.SetFloat( "GlowSize", 0.5 )
		img.Material.SetFloat( "ScanlineIntensity", 0.25 )
		img.Material.SetFloat( "ShadowMaskIntensity", 0.25 )
		
		imgClean = New Image( tex )
		imgClean.Handle = New Vec2f( 0.5 )	
	End

	Method OnRender( canvas:Canvas ) Override
		App.RequestRender()
		canvas.DrawImage( imgClean, Width*.15, Height/2, 0, 2, 2 )', 0, scale.X, scale.Y )
		canvas.DrawImage( img, Width*.6, Height/2 )
		canvas.DrawText( App.FPS, 5, 5 )
	End

End

Function Main()
	New AppInstance
	New MyWindow
	App.Run()
End
