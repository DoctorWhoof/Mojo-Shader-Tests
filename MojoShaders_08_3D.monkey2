#Import "<std>"
#Import "<mojo>"
#Import "<mojo3d>"
#Import "shaders/material-unlit.glsl"
#Import "testMaterial"

Using std..
Using mojo..
Using mojo3d..

Class MyWindow Extends Window

	Field img :Image
	Field testShader :Shader

	Field scene:Scene
	Field cube:Model
	Field camera:Camera
	Field light:Light

	Method New()
		Super.New( "Shader test",1024,600,WindowFlags.Resizable  )
		scene = Scene.GetCurrent()
		scene.ClearColor = Color.DarkGrey

		Local testShader := New Shader( "test07", LoadString("asset::material-unlit.glsl"), "" )

		img = New Image( 512, 512, TextureFlags.FilterMipmap, testShader )
		img.Handle = New Vec2f( 0.5 )

		Local mat := New TestMaterial( testShader )
'		Local mat := New PbrMaterial( Color.Red )

		cube = Model.CreateBox( New Boxf(-1,-1,-1,1,1,1), 1, 1, 1, mat  )
		
		camera = New Camera
		camera.Move( 0, 5, -5 )
		camera.PointAt( cube )
		camera.FOV = 45
		
		light=New Light
		light.Rotate( 30, 60, 0 )
	End

	Method OnRender( canvas:Canvas ) Override
		App.RequestRender()
		cube.Rotate( 0, .5, 0 )
		scene.Render( canvas, camera )
	End
End


Function Main()
	New AppInstance
	New MyWindow
	App.Run()
End


'********************************* Materials *********************************
'
'
'Class TestMaterial Extends Material
'	
'	Property ColorTexture:Texture()	
'		Return Uniforms.GetTexture( "ColorTexture" )
'	Setter( texture:Texture )
'		Uniforms.SetTexture( "ColorTexture",texture )
'	End
'	
'	Property ColorFactor:Color()
'		Return Uniforms.GetColor( "ColorFactor" )
'	Setter( color:Color )
'		Uniforms.SetColor( "ColorFactor",color )
'	End
'	
'	Method New( shader:Shader )	
'		Super.New( shader )
'		BlendMode=BlendMode.Alpha
'		CullMode=CullMode.None
'		ColorTexture=Texture.ColorTexture( Color.White )
'		ColorFactor = Color.White
'	End
'	
'	Method New( material:TestMaterial )
'		Super.New( material )
'	End
'
'	Method Copy:TestMaterial() Override
'		Return New TestMaterial( Self )
'	End
'	
'End
