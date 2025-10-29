// Upgrade NOTE: replaced tex2D unity_Lightmap with UNITY_SAMPLE_TEX2D

// Made with Amplify Shader Editor v1.9.8.1
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Colour"
{
	Properties
	{
		_TextureSample0("Texture Sample 0", 2D) = "white" {}
		_Smin("Smin", Range( 0 , 1)) = 0
		_Cmin("Cmin", Range( 0 , 1)) = 0
		_Smax("Smax", Range( 0 , 1)) = 0
		_Cmax("Cmax", Range( 0 , 1)) = 0
		_Contrast("Contrast", Range( 1 , 5)) = 0
		_M("M", Range( 0 , 1)) = 0
		_Color0("Color 0", Color) = (0,0,0,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGPROGRAM
		#include "UnityCG.cginc"
		#pragma target 3.0
		#define ASE_VERSION 19801
		#pragma multi_compile _ LIGHTMAP_ON
		#pragma multi_compile _ DYNAMICLIGHTMAP_ON
		#pragma multi_compile _ DIRLIGHTMAP_COMBINED
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows vertex:vertexDataFunc 
		struct Input
		{
			float2 uv_texcoord;
			float2 vertexToFrag10_g1;
		};

		uniform float4 _Color0;
		uniform sampler2D _TextureSample0;
		uniform float4 _TextureSample0_ST;
		uniform float _M;
		uniform float _Smin;
		uniform float _Smax;
		uniform float _Contrast;
		uniform float _Cmin;
		uniform float _Cmax;


		float4 CalculateContrast( float contrastValue, float4 colorTarget )
		{
			float t = 0.5 * ( 1.0 - contrastValue );
			return mul( float4x4( contrastValue,0,0,t, 0,contrastValue,0,t, 0,0,contrastValue,t, 0,0,0,1 ), colorTarget );
		}

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			o.vertexToFrag10_g1 = ( ( v.texcoord1.xy * (unity_LightmapST).xy ) + (unity_LightmapST).zw );
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_TextureSample0 = i.uv_texcoord * _TextureSample0_ST.xy + _TextureSample0_ST.zw;
			float4 tex2DNode2 = tex2D( _TextureSample0, uv_TextureSample0 );
			o.Albedo = ( _Color0 * tex2DNode2 ).rgb;
			o.Metallic = _M;
			o.Smoothness = (_Smin + (tex2DNode2.a - 0.0) * (_Smax - _Smin) / (1.0 - 0.0));
			float4 tex2DNode7_g1 = UNITY_SAMPLE_TEX2D( unity_Lightmap, i.vertexToFrag10_g1 );
			float3 decodeLightMap6_g1 = DecodeLightmap(tex2DNode7_g1);
			float4 temp_cast_3 = (_Cmin).xxxx;
			float4 temp_cast_4 = (_Cmax).xxxx;
			o.Occlusion = (temp_cast_3 + (CalculateContrast(_Contrast,float4( ( decodeLightMap6_g1 * ( 1.0 ) ) , 0.0 )) - float4( 0,0,0,0 )) * (temp_cast_4 - temp_cast_3) / (float4( 1,1,1,1 ) - float4( 0,0,0,0 ))).r;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "AmplifyShaderEditor.MaterialInspector"
}
/*ASEBEGIN
Version=19801
Node;AmplifyShaderEditor.FunctionNode;7;-543,190.4996;Inherit;True;FetchLightmapValue;1;;1;43de3d4ae59f645418fdd020d1b8e78e;1,23,1;0;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;10;-544,408.4996;Inherit;False;Property;_Contrast;Contrast;7;0;Create;True;0;0;0;False;0;False;0;4.92;1;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleContrastOpNode;9;-237,195.4996;Inherit;False;2;1;COLOR;0,0,0,0;False;0;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;3;-571,-20.50003;Inherit;False;Property;_Smin;Smin;3;0;Create;True;0;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-572,58.5;Inherit;False;Property;_Smax;Smax;5;0;Create;True;0;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;13;-531.3333,516.4994;Inherit;False;Property;_Cmin;Cmin;4;0;Create;True;0;0;0;False;0;False;0;0.008;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;14;-532.3333,595.4994;Inherit;False;Property;_Cmax;Cmax;6;0;Create;True;0;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;2;-583,-300.5;Inherit;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.ColorNode;15;-96,-448;Inherit;False;Property;_Color0;Color 0;9;0;Create;True;0;0;0;False;0;False;0,0,0,0;1,1,1,0;True;True;0;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.RangedFloatNode;6;-586,-105.5;Inherit;False;Property;_M;M;8;0;Create;True;0;0;0;False;0;False;0;0.09;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;4;-239,-87.50006;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;12;38.66669,327.4993;Inherit;False;5;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,1,1,1;False;3;COLOR;0,0,0,0;False;4;COLOR;1,1,1,1;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;16;160,-288;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;451,-222;Float;False;True;-1;2;AmplifyShaderEditor.MaterialInspector;0;0;Standard;Colour;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;0;0;False;;0;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;17;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;16;FLOAT4;0,0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;9;1;7;0
WireConnection;9;0;10;0
WireConnection;4;0;2;4
WireConnection;4;3;3;0
WireConnection;4;4;5;0
WireConnection;12;0;9;0
WireConnection;12;3;13;0
WireConnection;12;4;14;0
WireConnection;16;0;15;0
WireConnection;16;1;2;0
WireConnection;0;0;16;0
WireConnection;0;3;6;0
WireConnection;0;4;4;0
WireConnection;0;5;12;0
ASEEND*/
//CHKSM=DF345BA86001AAEE9F30625E2192B137A2F4AAFE