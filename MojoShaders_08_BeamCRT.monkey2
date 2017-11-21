#Import "<std>"
#Import "<mojo>"
#Import "<mojo3d>"
#Import "shaders/test08_BeamCRT.glsl"

#Import "images/"

Using std..
Using mojo..

'A CRT shader"

Class MyWindow Extends Window

	Field img :Image
	Field scale :Vec2f
	Field zoom := 8.0

	Field effects:= True
	Field mix := 1.0
	Field brightness := 0.9
	Field saturation := 1.5
	Field gamma := 1.5
	Field blurX := 0
	Field blurY := 0

	Field scanlines := 0.5
	Field mask := 0.35
	
	Field glowGain := 0.1
	Field glowSize := 0.25

	Method New()
		Super.New( "Shader test",2880,1800, WindowFlags.Resizable | WindowFlags.HighDPI  )
		ClearColor = Color.Black
		
		Local testShader := New Shader( "test08", LoadString("asset::test08_BeamCRT.glsl"), "" )
		img = Image.Load( "asset::frame.png", testShader, TextureFlags.None )
		img.Handle = New Vec2f(0.5)
		
		Local texMask := Texture.Load( "asset::shadowMask16px.png", TextureFlags.FilterMipmap | TextureFlags.WrapST )

		img.Material.SetTexture( "Shadowmask", texMask )
		img.Material.SetVec2f( "Resolution", New Vec2f( img.Width, img.Height ) )

		img.Material.SetFloat( "Mix", mix )
		img.Material.SetFloat( "Brightness", brightness )
		img.Material.SetFloat( "Saturation", saturation )
		img.Material.SetFloat( "Gamma", gamma )
		img.Material.SetFloat( "BlurX", blurX )
		img.Material.SetFloat( "BlurY", blurY )
		
		img.Material.SetFloat( "Glow", glowGain )
		img.Material.SetFloat( "GlowSize", glowSize )
		img.Material.SetFloat( "ScanlineIntensity", scanlines )
		img.Material.SetFloat( "ShadowMaskIntensity", mask )
	End

	Method OnRender( canvas:Canvas ) Override
		App.RequestRender()
		
		If Keyboard.KeyHit( Key.Space )
			If mix > 0.5 mix = 0.0 Else mix = 1.0
			img.Material.SetFloat( "Mix", mix )
		End
'
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
		canvas.DrawImage( img, Width/2, Height/2, 0, scale.Y, scale.Y )
		canvas.DrawText( App.FPS + " fps;  Mix: " + mix, 5, 5 )
	End

End

Function Main()
	New AppInstance
	New MyWindow
	App.Run()
End
