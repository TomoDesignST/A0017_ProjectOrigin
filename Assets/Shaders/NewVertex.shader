// Upgrade NOTE: replaced tex2D unity_Lightmap with UNITY_SAMPLE_TEX2D

// Made with Amplify Shader Editor v1.9.8.1
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "NewVertex"
{
	Properties
	{
		_MainTex("Texture Sample 0", 2D) = "white" {}
		_MainTex2("uv3", 2D) = "white" {}
		_MainTex1("Normal", 2D) = "bump" {}
		_Smin("Smin", Range( 0 , 1)) = 0
		_Smax("Smax", Range( 0 , 1)) = 0
		_Albedo("Albedo", Range( 0 , 50)) = 0
		_UV3("UV3", Range( 0 , 50)) = 0
		_Saturation("Saturation", Range( 0 , 1)) = 0
		_Value("Value", Range( 0 , 1)) = 0
		_Cmin("Cmin", Range( 0 , 1)) = 0
		_Cmax("Cmax", Range( 0 , 1)) = 0
		_Contrast("Contrast", Range( 1 , 10)) = 0
		_Color0("Color 0", Color) = (0,0,0,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] _texcoord3( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Transparent+0" }
		Cull Back
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
			float2 uv_texcoord;
			float4 vertexColor : COLOR;
			float2 uv3_texcoord3;
			float2 vertexToFrag10_g2;
		};

		uniform sampler2D _MainTex1;
		uniform float4 _MainTex1_ST;
		uniform float4 _Color0;
		uniform float _Saturation;
		uniform float _Value;
		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform float _Albedo;
		uniform sampler2D _MainTex2;
		uniform float4 _MainTex2_ST;
		uniform float _UV3;
		uniform float _Smin;
		uniform float _Smax;
		uniform float _Contrast;
		uniform float _Cmin;
		uniform float _Cmax;


		float3 HSVToRGB( float3 c )
		{
			float4 K = float4( 1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0 );
			float3 p = abs( frac( c.xxx + K.xyz ) * 6.0 - K.www );
			return c.z * lerp( K.xxx, saturate( p - K.xxx ), c.y );
		}


		float3 RGBToHSV(float3 c)
		{
			float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
			float4 p = lerp( float4( c.bg, K.wz ), float4( c.gb, K.xy ), step( c.b, c.g ) );
			float4 q = lerp( float4( p.xyw, c.r ), float4( c.r, p.yzx ), step( p.x, c.r ) );
			float d = q.x - min( q.w, q.y );
			float e = 1.0e-10;
			return float3( abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
		}

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
			float2 uv_MainTex1 = i.uv_texcoord * _MainTex1_ST.xy + _MainTex1_ST.zw;
			o.Normal = UnpackNormal( tex2D( _MainTex1, uv_MainTex1 ) );
			float3 hsvTorgb22 = RGBToHSV( i.vertexColor.rgb );
			float clampResult47 = clamp( ( _Value * ( 0.5 + hsvTorgb22.z ) ) , 0.0 , 1.0 );
			float3 hsvTorgb23 = HSVToRGB( float3(hsvTorgb22.x,( hsvTorgb22.y * _Saturation ),clampResult47) );
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float4 tex2DNode2 = tex2D( _MainTex, uv_MainTex );
			float2 uv2_MainTex2 = i.uv3_texcoord3 * _MainTex2_ST.xy + _MainTex2_ST.zw;
			float4 clampResult44 = clamp( ( ( tex2DNode2.a * tex2D( _MainTex2, uv2_MainTex2 ) ) * _UV3 ) , float4( 0,0,0,0 ) , float4( 1,1,1,0 ) );
			o.Albedo = ( _Color0 * ( float4( hsvTorgb23 , 0.0 ) * ( tex2DNode2 * _Albedo * clampResult44 ) ) ).rgb;
			o.Smoothness = (_Smin + (tex2DNode2.a - 0.0) * (_Smax - _Smin) / (1.0 - 0.0));
			float4 tex2DNode7_g2 = UNITY_SAMPLE_TEX2D( unity_Lightmap, i.vertexToFrag10_g2 );
			float3 decodeLightMap6_g2 = DecodeLightmap(tex2DNode7_g2);
			float4 temp_cast_5 = (_Cmin).xxxx;
			float4 temp_cast_6 = (_Cmax).xxxx;
			o.Occlusion = (temp_cast_5 + (CalculateContrast(_Contrast,float4( ( decodeLightMap6_g2 * ( 1.0 ) ) , 0.0 )) - float4( 0,0,0,0 )) * (temp_cast_6 - temp_cast_5) / (float4( 1,1,1,1 ) - float4( 0,0,0,0 ))).r;
			o.Alpha = 1;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard keepalpha fullforwardshadows vertex:vertexDataFunc 

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
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float4 customPack1 : TEXCOORD1;
				float2 customPack2 : TEXCOORD2;
				float3 worldPos : TEXCOORD3;
				float4 tSpace0 : TEXCOORD4;
				float4 tSpace1 : TEXCOORD5;
				float4 tSpace2 : TEXCOORD6;
				half4 color : COLOR0;
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
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				o.customPack1.zw = customInputData.uv3_texcoord3;
				o.customPack1.zw = v.texcoord2;
				o.customPack2.xy = customInputData.vertexToFrag10_g2;
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				o.color = v.color;
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
				surfIN.uv_texcoord = IN.customPack1.xy;
				surfIN.uv3_texcoord3 = IN.customPack1.zw;
				surfIN.vertexToFrag10_g2 = IN.customPack2.xy;
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.vertexColor = IN.color;
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
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
Node;AmplifyShaderEditor.VertexColorNode;20;-576,-512;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;2;-768,-352;Inherit;True;Property;_MainTex;Texture Sample 0;0;0;Create;False;0;0;0;False;0;False;-1;None;bba0cb3012e73684a9aff487976e039f;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.SamplerNode;41;-880,-144;Inherit;True;Property;_MainTex2;uv3;1;0;Create;False;0;0;0;False;0;False;-1;None;9665987b1e8c8d24d93b98102da7d5df;True;2;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.RGBToHSVNode;22;-304,-528;Inherit;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;42;-592,-64;Inherit;False;Property;_UV3;UV3;8;0;Create;True;0;0;0;False;0;False;0;8.1;0;50;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;39;-416,-624;Inherit;False;Property;_Value;Value;10;0;Create;True;0;0;0;False;0;False;0;0.04126087;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;46;-96,-576;Inherit;False;2;2;0;FLOAT;0.5;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;45;-416,-176;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;24;-464,-384;Inherit;False;Property;_Saturation;Saturation;9;0;Create;True;0;0;0;False;0;False;0;0.01;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;40;16,-656;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;43;-224,-192;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;25;-80,-416;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;47;160,-640;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;6;-64,-256;Inherit;False;Property;_Albedo;Albedo;7;0;Create;True;0;0;0;False;0;False;0;50;0;50;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;44;80,-144;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,1,1,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;26;-560,208;Inherit;True;FetchLightmapValue;5;;2;43de3d4ae59f645418fdd020d1b8e78e;1,23,1;0;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;27;-560,432;Inherit;False;Property;_Contrast;Contrast;13;0;Create;True;0;0;0;False;0;False;0;10;1;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.HSVToRGBNode;23;272,-480;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;15;304,-272;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleContrastOpNode;28;-256,224;Inherit;False;2;1;COLOR;0,0,0,0;False;0;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;29;-544,544;Inherit;False;Property;_Cmin;Cmin;11;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;30;-544,624;Inherit;False;Property;_Cmax;Cmax;12;0;Create;True;0;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;3;-592,32;Inherit;False;Property;_Smin;Smin;3;0;Create;True;0;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-592,112;Inherit;False;Property;_Smax;Smax;4;0;Create;True;0;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;33;656,-496;Inherit;False;Property;_Color0;Color 0;14;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.6226414,0.61655,0.5678176,0;True;True;0;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;21;512,-288;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TFHCRemapNode;31;-32,288;Inherit;False;5;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,1,1,1;False;3;COLOR;0,0,0,0;False;4;COLOR;1,1,1,1;False;1;COLOR;0
Node;AmplifyShaderEditor.TFHCRemapNode;4;-96,0;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;34;928,-304;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;36;560,-144;Inherit;True;Property;_MainTex1;Normal;2;0;Create;False;0;0;0;False;0;False;-1;None;0a5416533852111428567eb353c9c1e8;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1152,-224;Float;False;True;-1;2;AmplifyShaderEditor.MaterialInspector;0;0;Standard;NewVertex;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Translucent;0.5;True;True;0;False;Opaque;;Transparent;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;0;5;False;;10;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;True;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;17;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;16;FLOAT4;0,0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;22;0;20;0
WireConnection;46;1;22;3
WireConnection;45;0;2;4
WireConnection;45;1;41;0
WireConnection;40;0;39;0
WireConnection;40;1;46;0
WireConnection;43;0;45;0
WireConnection;43;1;42;0
WireConnection;25;0;22;2
WireConnection;25;1;24;0
WireConnection;47;0;40;0
WireConnection;44;0;43;0
WireConnection;23;0;22;1
WireConnection;23;1;25;0
WireConnection;23;2;47;0
WireConnection;15;0;2;0
WireConnection;15;1;6;0
WireConnection;15;2;44;0
WireConnection;28;1;26;0
WireConnection;28;0;27;0
WireConnection;21;0;23;0
WireConnection;21;1;15;0
WireConnection;31;0;28;0
WireConnection;31;3;29;0
WireConnection;31;4;30;0
WireConnection;4;0;2;4
WireConnection;4;3;3;0
WireConnection;4;4;5;0
WireConnection;34;0;33;0
WireConnection;34;1;21;0
WireConnection;0;0;34;0
WireConnection;0;1;36;0
WireConnection;0;4;4;0
WireConnection;0;5;31;0
ASEEND*/
//CHKSM=C076F345D36FFA8BD737CA0AD727FD41A57F9F32