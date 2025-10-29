// Upgrade NOTE: replaced tex2D unity_Lightmap with UNITY_SAMPLE_TEX2D

// Made with Amplify Shader Editor v1.9.8.1
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "NewGlass"
{
	Properties
	{
		_Color0("Color 0", Color) = (0.3314483,0.3490566,0.2886852,0)
		_S("S", Range( 0 , 1)) = 0
		_O("O", Range( 0 , 1)) = 0
		_Cmin("Cmin", Range( 0 , 1)) = 0
		_Cmax("Cmax", Range( 0 , 1)) = 0
		_Contrast("Contrast", Range( 1 , 5)) = 0
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" }
		Cull Back
		Blend One Zero , One OneMinusSrcAlpha
		
		AlphaToMask On
		CGINCLUDE
		#include "UnityCG.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#define ASE_VERSION 19801
		#pragma multi_compile _ LIGHTMAP_ON
		#pragma multi_compile _ DYNAMICLIGHTMAP_ON
		#pragma multi_compile _ DIRLIGHTMAP_COMBINED
		struct Input
		{
			float2 vertexToFrag10_g2;
		};

		uniform float4 _Color0;
		uniform float _S;
		uniform float _Contrast;
		uniform float _Cmin;
		uniform float _Cmax;
		uniform float _O;


		float4 CalculateContrast( float contrastValue, float4 colorTarget )
		{
			float t = 0.5 * ( 1.0 - contrastValue );
			return mul( float4x4( contrastValue,0,0,t, 0,contrastValue,0,t, 0,0,contrastValue,t, 0,0,0,1 ), colorTarget );
		}

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			o.vertexToFrag10_g2 = ( ( v.texcoord1.xy * (unity_LightmapST).xy ) + (unity_LightmapST).zw );
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			o.Albedo = _Color0.rgb;
			o.Smoothness = _S;
			float4 tex2DNode7_g2 = UNITY_SAMPLE_TEX2D( unity_Lightmap, i.vertexToFrag10_g2 );
			float3 decodeLightMap6_g2 = DecodeLightmap(tex2DNode7_g2);
			float4 temp_cast_3 = (_Cmin).xxxx;
			float4 temp_cast_4 = (_Cmax).xxxx;
			o.Occlusion = (temp_cast_3 + (CalculateContrast(_Contrast,float4( ( decodeLightMap6_g2 * ( 1.0 ) ) , 0.0 )) - float4( 0,0,0,0 )) * (temp_cast_4 - temp_cast_3) / (float4( 1,1,1,1 ) - float4( 0,0,0,0 ))).r;
			o.Alpha = _O;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard keepalpha fullforwardshadows vertex:vertexDataFunc  alpha

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			AlphaToMask Off
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			sampler3D _DitherMaskLOD;
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				vertexDataFunc( v, customInputData );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.customPack1.xy = customInputData.vertexToFrag10_g2;
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.vertexToFrag10_g2 = IN.customPack1.xy;
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				half alphaRef = tex3D( _DitherMaskLOD, float3( vpos.xy * 0.25, o.Alpha * 0.9375 ) ).a;
				clip( alphaRef - 0.01 );
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "AmplifyShaderEditor.MaterialInspector"
}
/*ASEBEGIN
Version=19801
Node;AmplifyShaderEditor.FunctionNode;6;-720,496;Inherit;True;FetchLightmapValue;2;;2;43de3d4ae59f645418fdd020d1b8e78e;1,23,1;0;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;7;-720,720;Inherit;False;Property;_Contrast;Contrast;8;0;Create;True;0;0;0;False;0;False;0;5;1;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleContrastOpNode;8;-416,512;Inherit;False;2;1;COLOR;0,0,0,0;False;0;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;9;-704,832;Inherit;False;Property;_Cmin;Cmin;6;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;10;-704,912;Inherit;False;Property;_Cmax;Cmax;7;0;Create;True;0;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;2;-384,-96;Inherit;False;Property;_Color0;Color 0;1;0;Create;True;0;0;0;False;0;False;0.3314483,0.3490566,0.2886852,0;0.3512519,0.3773585,0.3721954,0;True;True;0;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.TFHCRemapNode;11;-208,352;Inherit;False;5;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,1,1,1;False;3;COLOR;0,0,0,0;False;4;COLOR;1,1,1,1;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;4;-400,112;Inherit;False;Property;_S;S;4;0;Create;True;0;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;12;-384,208;Inherit;False;Property;_O;O;5;0;Create;True;0;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;160,0;Float;False;True;-1;2;AmplifyShaderEditor.MaterialInspector;0;0;Standard;NewGlass;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Custom;0.5;True;True;0;True;Custom;Transparent;Transparent;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;0;1;False;;10;False;;3;1;False;;10;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;0;-1;-1;-1;0;True;0;0;False;;-1;0;False;;0;1;alpha;0;False;0.1;False;;0;False;;False;17;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;16;FLOAT4;0,0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;8;1;6;0
WireConnection;8;0;7;0
WireConnection;11;0;8;0
WireConnection;11;3;9;0
WireConnection;11;4;10;0
WireConnection;0;0;2;0
WireConnection;0;4;4;0
WireConnection;0;5;11;0
WireConnection;0;9;12;0
ASEEND*/
//CHKSM=C0E8CBB1CC06EE4B7F994D2975695C5DDAA01656