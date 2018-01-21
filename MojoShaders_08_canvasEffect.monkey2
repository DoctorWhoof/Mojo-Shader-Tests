#Import "<std>"
#Import "<mojo>"
#Import "shaders/test08_canvasEffect.glsl"

Using std..
Using mojo..

Function Main()
	New AppInstance
	New MyWindow
	App.Run()
End


'*************************************** Custom window ***************************************


Class MyWindow Extends Window

	Field img :Image
	Field testShader :Shader
	Field textureCanvas: Canvas	
	
	Field res :Vec2i
	Field aspect: Float
	
	'Main shader paramters. Passed to the shader via the image.
	Field vignetteIntensity:= 0.5
	Field vignetteSpread := 0.2
	Field blurIntensity:= 6.0
	
	'keyboard controls
	Field bypass:= 0.0
	Field paused:= False

	Method New()
		'Create window, set window related parameters
		Super.New( "Shader test",1024,768,WindowFlags.Resizable | WindowFlags.HighDPI )
		res = New Vec2i( Width, Height )
		aspect = Float(res.x) / Float(res.y)
		Layout = "fill"
		
		'Our shader.
		Local fullScreenShader := New Shader( "test08", LoadString("asset::test08_canvasEffect.glsl"), "" )	
		'Image using the shader. Uses "Dynamic" flags because it is updated on every frame.
		img = New Image( res.X, res.Y, TextureFlags.FilterMipmap | TextureFlags.Dynamic, fullScreenShader )
		'Shader params
		img.Material.SetVec2f( "Resolution", New Vec2f( res.X, res.Y ) )
		img.Material.SetFloat( "Vignette", 1.0 - vignetteIntensity )
		img.Material.SetFloat( "VignetteSpread", vignetteSpread )
		img.Material.SetFloat( "Blur", blurIntensity )
		'The texture canvas the circles will be draw to
		textureCanvas = New Canvas( img )
		
		'Create a bunch of bouncing circles!
		For Local n := 1 To 50
			Local circle := New Circle( Rnd(100,Width-100), Rnd(0,Height-100) )
		Next
	End
	
	'Main drawing loop.
	Method OnRender( canvas:Canvas ) Override
		App.RequestRender()
		
		'bypass shader with spacebar
		If Keyboard.KeyHit( Key.Space )
			bypass = Abs( bypass - 1.0 )	
		End
		
		'pause with "P"
		If Keyboard.KeyHit( Key.P )
			paused = Not paused	
		End

		'Draw to texture canvas
		textureCanvas.Clear( Color.DarkGrey )
		img.Material.SetFloat( "Bypass", bypass )
		For Local circle := Eachin Circle.all
			If Not paused Then circle.Update( textureCanvas )
			circle.Render( textureCanvas )
		Next
		textureCanvas.Flush()
		
		'Draw To main canvas, preserving original aspect ratio while using all pixels available ("fill" layout)
		Local currentAspect := Float(Width)/Float(Height)
		If currentAspect <= aspect
			Local h :Int= Width / aspect
			canvas.DrawRect( 0, (Height - h)/2, Width, h , img )
			canvas.DrawText( "Effective Resolution: " + Width + "," + h, 10, Height - 20 )
		Else
			Local w :Int = Height * aspect
			canvas.DrawRect( (Width-w)/2, 0, w, Height, img )
			canvas.DrawText( "Effective Resolution: " + w + "," + Height, 10, Height - 20 )
		End
		
		'Draw extra info
		canvas.DrawText( "Hit spacebar to toggle shader on/off, 'P' to pause", 10, 10 )
	
		Local fps := "FPS:" + App.FPS
		canvas.DrawText( fps, Width-canvas.Font.TextWidth(fps)-10 , 10 )
	End
	
	'Required by letterbox Layout
	Method OnMeasure:Vec2i() Override
		Return res	
	End

End


'*************************************** Circle object ***************************************


Class Circle
	
	Global all := New Stack<Circle>
	Global gravity := 0.25
	Global maxSpeed := 2.0
	Global minLuma := 0.5
	
	Field pos :Vec2f
	Field oldPos := New Vec2f
	
	Field radius := Rnd(50.0) + 10.0
	Field color :Color
	Field speed := New Vec2f( Rnd(-maxSpeed, maxSpeed), 0 )
	
	
	Method New( x:Float, y:Float )
		pos = New Vec2f( x, y )
		Local r := Clamp<Float>( Rnd() + minLuma, 0.0, 1.0 )
		Local g := Clamp<Float>( Rnd() + minLuma, 0.0, 1.0 )
		Local b := Clamp<Float>( Rnd() + minLuma, 0.0, 1.0 )
		color = New Color( r, g, b, 1.0 )
		all.Add( Self )
	End
	
	Method Update( canvas:Canvas )
		oldPos = pos
		speed.Y += gravity
		pos += speed
		
		If pos.Y > canvas.Viewport.Height-radius
			pos.Y = oldPos.Y
			speed.Y *= -1.0
		End
		
		If pos.X>canvas.Viewport.Width-radius Or pos.X<radius
			pos.X = oldPos.X
			speed.X *= -1.0
		End
	End
	
	Method Render( canvas:Canvas )
		canvas.Color = color
		canvas.DrawCircle( pos.X, pos.Y , radius )	
	End
End
