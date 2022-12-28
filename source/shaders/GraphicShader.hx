package shaders;

import flixel.*;
import openfl.display.*;
import openfl.utils.ByteArray;
import sys.io.File;
import sys.FileSystem;

using StringTools;

class Shaders
{
	public static var shaders:Map<String, GraphicShader> = new Map<String, GraphicShader>();

	public static function getShader(id:String, ?path:String = null):GraphicShader
	{
		if (shaders.exists(id))
			return shaders.get(id);
		else
		{
			var theShader:GraphicShader = new GraphicShader(path);
			shaders.set(id, theShader);
			return shaders.get(id); //hopefully this works.
		}
	}
}

class GraphicShader extends Shader
{
	public var shaderBitmap:ShaderInput<BitmapData>;

	var glFragmentHeader:String = "
		varying float openfl_Alphav;
		varying vec4 openfl_ColorMultiplierv;
		varying vec4 openfl_ColorOffsetv;
		varying vec2 openfl_TextureCoordv;

		uniform bool openfl_HasColorTransform;
		uniform vec2 openfl_TextureSize;
		uniform sampler2D bitmap;";

	var glFragmentBody:String = "
		vec4 color = texture2D (bitmap, openfl_TextureCoordv);

		if (color.a == 0.0) {

			gl_FragColor = vec4 (0.0, 0.0, 0.0, 0.0);

		} else if (openfl_HasColorTransform) {

			color = vec4 (color.rgb / color.a, color.a);

			mat4 colorMultiplier = mat4 (0);
			colorMultiplier[0][0] = openfl_ColorMultiplierv.x;
			colorMultiplier[1][1] = openfl_ColorMultiplierv.y;
			colorMultiplier[2][2] = openfl_ColorMultiplierv.z;
			colorMultiplier[3][3] = 1.0; // openfl_ColorMultiplierv.w;

			color = clamp (openfl_ColorOffsetv + (color * colorMultiplier), 0.0, 1.0);

			if (color.a > 0.0) {

				gl_FragColor = vec4 (color.rgb * color.a * openfl_Alphav, color.a * openfl_Alphav);

			} else {

				gl_FragColor = vec4 (0.0, 0.0, 0.0, 0.0);

			}

		} else {

			gl_FragColor = color * openfl_Alphav;

		}";

	public var fragmentSource:String = '';

	public function new(shaderPath:String = null)
	{
		super(null);

		if (shaderPath != null)
		{
			var shaderFile:String = File.getContent(shaderPath);

			if (shaderFile != null && shaderFile != "")
			{
				fragmentSource = shaderFile;

				if (fragmentSource != "")
					this.glFragmentSource = fragmentSource;
				else
					this.glFragmentSource = "
					#pragma header
					void main(void) {
						#pragma body
					}";

				__initGL();
			}
		}
	}

	override public function __initGL()
	{		
		setShaderFrag();

		__isGenerated = true;
		super.__initGL();

		if (data.bitmap != null)
			shaderBitmap = data.bitmap;
	}

	public function setShaderFrag(fragmentSource:String = null)
	{
		if (fragmentSource != null) {
			fragmentSource = StringTools.replace(this.glFragmentSource, '#pragma header', glFragmentHeader);
			fragmentSource = StringTools.replace(this.glFragmentSource, '#pragma body', glFragmentBody);
		}
	}
}