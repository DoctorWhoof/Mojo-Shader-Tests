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
'	Field zoom := 8.0

	Field effects:= True
	Field mix := 1.0
	Field brightness := 0.5
	Field gamma := 0.9
	Field blurX := 0
	Field blurY := 0

	Field scanlines := 0.75
	Field mask := 0.25
	
	Field glowGain := 1.25
	Field glowSize := 0.25
	Field edgeBleed := 0.5
	Field bleedSize := 0.25

	Method New()
		Super.New( "Shader test",2880,1800,WindowFlags.Resizable | WindowFlags.HighDPI  )
		ClearColor = Color.Black

		Local tex := Texture.Load( "asset::frame.png", TextureFlags.None )
		Local texScan := Texture.Load( "asset::scanline16px.png", TextureFlags.FilterMipmap | TextureFlags.WrapST )
		Local texMask := Texture.Load( "asset::shadowMask16px.png", TextureFlags.FilterMipmap | TextureFlags.WrapST )
		
		Local testShader := New Shader( "test07", LoadString("asset::test07_CRT.glsl"), "" )

		img = New Image( tex,testShader )
		img.Handle = New Vec2f( 0.5 )

		img.Material.SetTexture( "Scanlines", texScan )
		img.Material.SetTexture( "Shadowmask", texMask )
		
		img.Material.SetVec2f( "Resolution", New Vec2f( tex.Width, tex.Height ) )

		img.Material.SetFloat( "Mix", mix )
		img.Material.SetFloat( "Brightness", brightness )
		img.Material.SetFloat( "Gamma", gamma )
		img.Material.SetFloat( "BlurX", blurX )
		img.Material.SetFloat( "BlurY", blurY )
		
		img.Material.SetFloat( "Glow", glowGain )
		img.Material.SetFloat( "GlowSize", glowSize )
		img.Material.SetFloat( "Bleed", edgeBleed )
		img.Material.SetFloat( "BleedSize", bleedSize )
		img.Material.SetFloat( "ScanlineIntensity", scanlines )
		img.Material.SetFloat( "ShadowMaskIntensity", mask )
		
		imgClean = New Image( tex )
		imgClean.Handle = New Vec2f( 0.5 )
	End

	Method OnRender( canvas:Canvas ) Override
		App.RequestRender()
		
		If Keyboard.KeyHit( Key.Space )
			If mix > 0.5 mix = 0.0 Else mix = 1.0
			img.Material.SetFloat( "Mix", mix )
		End

		If Keyboard.KeyHit( Key.Equals )
			mix += 0.1
			mix = Clamp( mix, 0.0, 1.0 )
			img.Material.SetFloat( "Mix", mix )
		Elseif Keyboard.KeyHit( Key.Minus )
			mix -= 0.1
			mix = Clamp( mix, 0.0, 1.0 )
			img.Material.SetFloat( "Mix", mix )	
		End
		
		scale = New Vec2f( Width/img.Width, Height/img.Height)
'		canvas.DrawImage( imgClean, Width*.15, Height/2, 0, 2, 2 )
		canvas.DrawImage( img, Width/2, Height/2, 0, scale.y, scale.y )
		canvas.DrawText( App.FPS + " fps;  Mix: " + mix, 5, 5 )
	End

End

Function Main()
	New AppInstance
	New MyWindow
	App.Run()
End