#Import "<std>"
#Import "<mojo>"
#Import "<mojo3d>"
#Import "shaders/test07_CRT.glsl"

#Import "images/"

Using std..
Using mojo..

'A fancy schmancy CRT shader"
'To do: Test SetInt in a separate example. Not working? Bug?

Class MyWindow Extends Window

	Field img :Image
	Field scale :Vec2f
	Field integerScaling:= True
	
	Field mix := 1.0
	Field brightness := 0.8
	Field contrast := 1.2
	Field saturation := 1.05
	
	Field border := 0.02
	Field borderFade := 0.0075
	Field curve := New Vec2f( 0.015, 0.015 )

	Field filterX := 1
	Field filterY := 0	'not working yet!

	Field scanlines := 0.3
	Field scanlineMinPower := 0.5
	Field scanlineMaxPower := 1.0
	
	Field mask := 0.5
	Field maskSize := 1.0
	
	Field glow := 0.3
	Field glowSize := 2.0

	Method New()
		Super.New( "Shader test",2048,1536, WindowFlags.Resizable | WindowFlags.HighDPI  )
		ClearColor = Color.Black
		
		Local testShader := New Shader( "test07", LoadString("asset::test07_CRT.glsl"), "" )
		img = Image.Load( "asset::pixelGrid.png", testShader, TextureFlags.FilterMipmap )
		img.Handle = New Vec2f(0.5)
		
		Local texMask := Texture.Load( "asset::shadowMaskBright32px.png", TextureFlags.FilterMipmap | TextureFlags.WrapST )

		img.Material.SetTexture( "Shadowmask", texMask )
		img.Material.SetVec2f( "Resolution", New Vec2f( img.Width, img.Height ) )
		
		img.Material.SetVec2f( "Curve", New Vec2f( curve.x, curve.y ) )

		img.Material.SetFloat( "Mix", mix )
		img.Material.SetFloat( "Brightness", brightness )
		img.Material.SetFloat( "Contrast", contrast )
		img.Material.SetFloat( "Saturation", saturation )
		
		img.Material.SetFloat( "Border", border )
		img.Material.SetFloat( "BorderFade", borderFade )
		
		img.Material.SetInt( "FilterX", filterX )
		img.Material.SetInt( "FilterY", filterY )
		
		img.Material.SetVec2f( "ShadowMaskSize", New Vec2f( maskSize ) )
		img.Material.SetFloat( "Glow", glow )
		img.Material.SetFloat( "GlowSize", glowSize )
		
		img.Material.SetFloat( "ScanlineIntensity", scanlines )
		img.Material.SetFloat( "ScanlineMinPower", scanlineMinPower )
		img.Material.SetFloat( "ScanlineMaxPower", scanlineMaxPower )
		img.Material.SetFloat( "ShadowMaskIntensity", mask )
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

		If integerScaling
			scale = New Vec2f( Floor( Width/img.Width), Floor(Height/img.Height) )
		Else
			scale = New Vec2f( Width/img.Width, Height/img.Height)
		End
		
		canvas.DrawImage( img, Width/2, Height/2, 0, scale.Y, scale.Y )
		canvas.Color = Color.Black
		
		Local  text := App.FPS + " fps;  Mix: " + mix + "      (Hit spacebar to toggle)"
		canvas.DrawRect(10,10,canvas.Font.TextWidth(text), canvas.Font.Height )
		canvas.Color = Color.White
		canvas.DrawText( text, 10, 10 )
	End

End

Function Main()
	New AppInstance
	New MyWindow
	App.Run()
End

