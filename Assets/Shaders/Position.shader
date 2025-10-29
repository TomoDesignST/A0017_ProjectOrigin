// Upgrade NOTE: replaced tex2D unity_Lightmap with UNITY_SAMPLE_TEX2D

// Made with Amplify Shader Editor v1.9.8.1
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Position"
{
	Properties
	{
		_MainTex("Texture Sample 0", 2D) = "white" {}
		_Smin("Smin", Range( 0 , 1)) = 0
		_Cmin("Cmin", Range( 0 , 1)) = 0
		_Smax("Smax", Range( 0 , 1)) = 0
		_Cmax("Cmax", Range( 0 , 1)) = 0
		_Contrast("Contrast", Range( 1 , 5)) = 0
		_Saturation("Saturation", Range( 0 , 1)) = 0
		_M("M", Range( 0 , 1)) = 0
		_Value("Value", Range( 0 , 1)) = 0
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
			float4 vertexColor : COLOR;
			float2 uv_texcoord;
			float3 worldPos;
			float2 vertexToFrag10_g1;
		};

		uniform float _Saturation;
		uniform float _Value;
		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform float _M;
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

		struct Gradient
		{
			int type;
			int colorsLength;
			int alphasLength;
			float4 colors[8];
			float2 alphas[8];
		};


		Gradient NewGradient(int type, int colorsLength, int alphasLength, 
		float4 colors0, float4 colors1, float4 colors2, float4 colors3, float4 colors4, float4 colors5, float4 colors6, float4 colors7,
		float2 alphas0, float2 alphas1, float2 alphas2, float2 alphas3, float2 alphas4, float2 alphas5, float2 alphas6, float2 alphas7)
		{
			Gradient g;
			g.type = type;
			g.colorsLength = colorsLength;
			g.alphasLength = alphasLength;
			g.colors[ 0 ] = colors0;
			g.colors[ 1 ] = colors1;
			g.colors[ 2 ] = colors2;
			g.colors[ 3 ] = colors3;
			g.colors[ 4 ] = colors4;
			g.colors[ 5 ] = colors5;
			g.colors[ 6 ] = colors6;
			g.colors[ 7 ] = colors7;
			g.alphas[ 0 ] = alphas0;
			g.alphas[ 1 ] = alphas1;
			g.alphas[ 2 ] = alphas2;
			g.alphas[ 3 ] = alphas3;
			g.alphas[ 4 ] = alphas4;
			g.alphas[ 5 ] = alphas5;
			g.alphas[ 6 ] = alphas6;
			g.alphas[ 7 ] = alphas7;
			return g;
		}


		float4 SampleGradient( Gradient gradient, float time )
		{
			float3 color = gradient.colors[0].rgb;
			UNITY_UNROLL
			for (int c = 1; c < 8; c++)
			{
			float colorPos = saturate((time - gradient.colors[c-1].w) / ( 0.00001 + (gradient.colors[c].w - gradient.colors[c-1].w)) * step(c, (float)gradient.colorsLength-1));
			color = lerp(color, gradient.colors[c].rgb, lerp(colorPos, step(0.01, colorPos), gradient.type));
			}
			#ifndef UNITY_COLORSPACE_GAMMA
			color = half3(GammaToLinearSpaceExact(color.r), GammaToLinearSpaceExact(color.g), GammaToLinearSpaceExact(color.b));
			#endif
			float alpha = gradient.alphas[0].x;
			UNITY_UNROLL
			for (int a = 1; a < 8; a++)
			{
			float alphaPos = saturate((time - gradient.alphas[a-1].y) / ( 0.00001 + (gradient.alphas[a].y - gradient.alphas[a-1].y)) * step(a, (float)gradient.alphasLength-1));
			alpha = lerp(alpha, gradient.alphas[a].x, lerp(alphaPos, step(0.01, alphaPos), gradient.type));
			}
			return float4(color, alpha);
		}


		float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }

		float snoise( float2 v )
		{
			const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
			float2 i = floor( v + dot( v, C.yy ) );
			float2 x0 = v - i + dot( i, C.xx );
			float2 i1;
			i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
			float4 x12 = x0.xyxy + C.xxzz;
			x12.xy -= i1;
			i = mod2D289( i );
			float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
			float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
			m = m * m;
			m = m * m;
			float3 x = 2.0 * frac( p * C.www ) - 1.0;
			float3 h = abs( x ) - 0.5;
			float3 ox = floor( x + 0.5 );
			float3 a0 = x - ox;
			m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
			float3 g;
			g.x = a0.x * x0.x + h.x * x0.y;
			g.yz = a0.yz * x12.xz + h.yz * x12.yw;
			return 130.0 * dot( m, g );
		}


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
			float3 hsvTorgb42 = RGBToHSV( i.vertexColor.rgb );
			float clampResult47 = clamp( ( _Value * ( 0.0 + hsvTorgb42.z ) ) , 0.0 , 1.0 );
			float3 hsvTorgb50 = HSVToRGB( float3(hsvTorgb42.x,( hsvTorgb42.y * _Saturation ),clampResult47) );
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float4 tex2DNode2 = tex2D( _MainTex, uv_MainTex );
			Gradient gradient16 = NewGradient( 0, 3, 2, float4( 0.8018868, 0.7993651, 0.7993651, 0 ), float4( 0.8463782, 0.8463782, 0.8463782, 0.4088197 ), float4( 1, 1, 1, 1 ), 0, 0, 0, 0, 0, float2( 1, 0 ), float2( 1, 1 ), 0, 0, 0, 0, 0, 0 );
			float3 ase_positionWS = i.worldPos;
			float2 temp_cast_2 = (tex2DNode2.a).xx;
			float simplePerlin2D25 = snoise( temp_cast_2 );
			simplePerlin2D25 = simplePerlin2D25*0.5 + 0.5;
			float4 lerpResult41 = lerp( float4( 1,1,1,0 ) , SampleGradient( gradient16, ase_positionWS.y ) , simplePerlin2D25);
			float4 lerpResult24 = lerp( float4( 0.5283019,0.5216566,0.5216566,0 ) , ( float4( hsvTorgb50 , 0.0 ) * tex2DNode2 ) , lerpResult41);
			o.Albedo = lerpResult24.rgb;
			o.Metallic = _M;
			o.Smoothness = (_Smin + (tex2DNode2.a - 0.0) * (_Smax - _Smin) / (1.0 - 0.0));
			float4 tex2DNode7_g1 = UNITY_SAMPLE_TEX2D( unity_Lightmap, i.vertexToFrag10_g1 );
			float3 decodeLightMap6_g1 = DecodeLightmap(tex2DNode7_g1);
			float4 temp_cast_6 = (_Cmin).xxxx;
			float4 temp_cast_7 = (_Cmax).xxxx;
			o.Occlusion = (temp_cast_6 + (CalculateContrast(_Contrast,float4( ( decodeLightMap6_g1 * ( 1.0 ) ) , 0.0 )) - float4( 0,0,0,0 )) * (temp_cast_7 - temp_cast_6) / (float4( 1,1,1,1 ) - float4( 0,0,0,0 ))).r;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "AmplifyShaderEditor.MaterialInspector"
}
/*ASEBEGIN
Version=19801
Node;AmplifyShaderEditor.VertexColorNode;49;-624,-1024;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RGBToHSVNode;42;-432,-1024;Inherit;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;43;-544,-1120;Inherit;False;Property;_Value;Value;10;0;Create;True;0;0;0;False;0;False;0;0.286;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;44;-224,-1072;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;45;-112,-1152;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;48;-528,-848;Inherit;False;Property;_Saturation;Saturation;8;0;Create;True;0;0;0;False;0;False;0;0.153;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;15;-576,-688;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GradientNode;16;-576,-512;Inherit;False;0;3;2;0.8018868,0.7993651,0.7993651,0;0.8463782,0.8463782,0.8463782,0.4088197;1,1,1,1;1,0;1,1;0;1;OBJECT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;46;-208,-912;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;47;32,-1136;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;2;-583,-300.5;Inherit;True;Property;_MainTex;Texture Sample 0;0;0;Create;False;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.FunctionNode;7;-543,190.4996;Inherit;True;FetchLightmapValue;1;;1;43de3d4ae59f645418fdd020d1b8e78e;1,23,1;0;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;10;-544,408.4996;Inherit;False;Property;_Contrast;Contrast;7;0;Create;True;0;0;0;False;0;False;0;2.52;1;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.GradientSampleNode;17;-172.0131,-436.1913;Inherit;True;2;0;OBJECT;;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NoiseGeneratorNode;25;-142.6541,-728.7754;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.HSVToRGBNode;50;144,-944;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleContrastOpNode;9;-237,195.4996;Inherit;False;2;1;COLOR;0,0,0,0;False;0;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;3;-571,-20.50003;Inherit;False;Property;_Smin;Smin;3;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-572,58.5;Inherit;False;Property;_Smax;Smax;5;0;Create;True;0;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;13;-531.3333,516.4994;Inherit;False;Property;_Cmin;Cmin;4;0;Create;True;0;0;0;False;0;False;0;0.158;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;14;-532.3333,595.4994;Inherit;False;Property;_Cmax;Cmax;6;0;Create;True;0;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;41;172.3459,-581.7762;Inherit;True;3;0;COLOR;1,1,1,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;51;272,-272;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;6;-586,-105.5;Inherit;False;Property;_M;M;9;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;4;-239,-87.50006;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;12;38.66669,327.4993;Inherit;False;5;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,1,1,1;False;3;COLOR;0,0,0,0;False;4;COLOR;1,1,1,1;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;24;470.3145,-291.6736;Inherit;False;3;0;COLOR;0.5283019,0.5216566,0.5216566,0;False;1;COLOR;1,1,1,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;709.98,-258.6889;Float;False;True;-1;2;AmplifyShaderEditor.MaterialInspector;0;0;Standard;Position;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;0;0;False;;0;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;17;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;16;FLOAT4;0,0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;42;0;49;0
WireConnection;44;1;42;3
WireConnection;45;0;43;0
WireConnection;45;1;44;0
WireConnection;46;0;42;2
WireConnection;46;1;48;0
WireConnection;47;0;45;0
WireConnection;17;0;16;0
WireConnection;17;1;15;2
WireConnection;25;0;2;4
WireConnection;50;0;42;1
WireConnection;50;1;46;0
WireConnection;50;2;47;0
WireConnection;9;1;7;0
WireConnection;9;0;10;0
WireConnection;41;1;17;0
WireConnection;41;2;25;0
WireConnection;51;0;50;0
WireConnection;51;1;2;0
WireConnection;4;0;2;4
WireConnection;4;3;3;0
WireConnection;4;4;5;0
WireConnection;12;0;9;0
WireConnection;12;3;13;0
WireConnection;12;4;14;0
WireConnection;24;1;51;0
WireConnection;24;2;41;0
WireConnection;0;0;24;0
WireConnection;0;3;6;0
WireConnection;0;4;4;0
WireConnection;0;5;12;0
ASEEND*/
//CHKSM=2A573118171462305391031D6D41842D472E3676