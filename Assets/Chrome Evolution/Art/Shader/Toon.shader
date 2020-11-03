// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Chrome Evo/Toon"
{
	Properties
	{
		_MainTexture("Main Texture", 2D) = "white" {}
		_Tint("Tint", Color) = (1,1,1,1)
		_BaseCellSharpeness("Base Cell Sharpeness", Range( 0.01 , 1)) = 0.01
		_BaseCellOffset("Base Cell Offset", Range( -1 , 1)) = 0
		_IndirectDiffuseContribution("Indirect Diffuse Contribution", Range( 0 , 1)) = 1
		_ShadowContribution("Shadow Contribution", Range( 0 , 1)) = 0.5
		[NoScaleOffset]_Highlight("Highlight", 2D) = "white" {}
		[HDR]_HighlightTint("Highlight Tint", Color) = (1,1,1,1)
		_HighlightCellOffset("Highlight Cell Offset", Range( -1 , -0.5)) = -0.95
		_HighlightCellSharpness("Highlight Cell Sharpness", Range( 0.001 , 1)) = 0.01
		_IndirectSpecularContribution("Indirect Specular Contribution", Range( 0 , 1)) = 1
		[Toggle(_STATICHIGHLIGHTS_ON)] _StaticHighLights("Static HighLights", Float) = 0
		[NoScaleOffset][Normal]_NormalMap("NormalMap", 2D) = "bump" {}
		_NormalScale("Normal Scale", Range( 0 , 1)) = 1
		[HDR]_RimColor("Rim Color", Color) = (1,1,1,0)
		_RimPower("Rim Power", Range( 0.01 , 1)) = 0.4
		_RimOffset("Rim Offset", Range( 0 , 1)) = 0.6
		_OutlineColor("Outline Color", Color) = (0.5294118,0.5294118,0.5294118,0)
		_OutlineWidth("Outline Width", Range( 0 , 0.2)) = 0.02
		_TessValue( "Max Tessellation", Range( 1, 32 ) ) = 4
		_TessMin( "Tess Min Distance", Float ) = 10
		_TessMax( "Tess Max Distance", Float ) = 25
		_TessPhongStrength( "Phong Tess Strength", Range( 0, 1 ) ) = 0.5
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ }
		Cull Front
		CGPROGRAM
		#include "Tessellation.cginc"
		#pragma target 4.6
		#pragma surface outlineSurf Outline nofog  keepalpha noshadow noambient novertexlights nolightmap nodynlightmap nodirlightmap nometa noforwardadd vertex:outlineVertexDataFunc tessellate:tessFunction tessphong:_TessPhongStrength 
		
		void outlineVertexDataFunc( inout appdata_full v )
		{
			float2 uv_MainTexture = v.texcoord * _MainTexture_ST.xy + _MainTexture_ST.zw;
			float4 tex2DNode1 = tex2Dlod( _MainTexture, float4( uv_MainTexture, 0, 0.0) );
			float OutlineCustomWidth129 = tex2DNode1.a;
			float outlineVar = ( OutlineCustomWidth129 * _OutlineWidth );
			v.vertex.xyz += ( v.normal * outlineVar );
		}
		inline half4 LightingOutline( SurfaceOutput s, half3 lightDir, half atten ) { return half4 ( 0,0,0, s.Alpha); }
		void outlineSurf( Input i, inout SurfaceOutput o )
		{
			float3 temp_cast_0 = (1.0).xxx;
			float3 lerpResult48 = lerp( temp_cast_0 , float3(0,0,0) , _IndirectDiffuseContribution);
			float3 IndirectDiffuse101 = lerpResult48;
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float temp_output_34_0 = ( 1.0 - ( ( 1.0 - 1 ) * _WorldSpaceLightPos0.w ) );
			float2 uv_NormalMap11 = i.uv_texcoord;
			float3 normalizeResult15 = normalize( (WorldNormalVector( i , UnpackScaleNormal( tex2D( _NormalMap, uv_NormalMap11 ), _NormalScale ) )) );
			float3 Normals16 = normalizeResult15;
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult21 = dot( Normals16 , ase_worldlightDir );
			float NDotL22 = dotResult21;
			float lerpResult36 = lerp( temp_output_34_0 , ( saturate( ( ( NDotL22 + _BaseCellOffset ) / _BaseCellSharpeness ) ) * 1 ) , _ShadowContribution);
			float2 uv_MainTexture = i.uv_texcoord * _MainTexture_ST.xy + _MainTexture_ST.zw;
			float4 tex2DNode1 = tex2D( _MainTexture, uv_MainTexture );
			float3 BaseColor7 = ( ( ( IndirectDiffuse101 * ase_lightColor.a * temp_output_34_0 ) + ( ase_lightColor.rgb * lerpResult36 ) ) * (( tex2DNode1 * _Tint )).rgb );
			o.Emission = ( BaseColor7 * (_OutlineColor).rgb );
			o.Normal = float3(0,0,-1);
		}
		ENDCG
		

		Tags{ "RenderType" = "Transparent"  "Queue" = "AlphaTest+0" "IgnoreProjector" = "True" }
		Cull Back
		Blend SrcAlpha OneMinusSrcAlpha , SrcAlpha OneMinusSrcAlpha
		
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityStandardUtils.cginc"
		#include "UnityCG.cginc"
		#include "Tessellation.cginc"
		#include "Lighting.cginc"
		#pragma target 4.6
		#pragma shader_feature_local _STATICHIGHLIGHTS_ON
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float3 worldNormal;
			INTERNAL_DATA
			float2 uv_texcoord;
			float3 worldPos;
		};

		struct SurfaceOutputCustomLightingCustom
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			half Alpha;
			Input SurfInput;
			UnityGIInput GIData;
		};

		uniform float _IndirectDiffuseContribution;
		uniform sampler2D _NormalMap;
		uniform float _NormalScale;
		uniform float _BaseCellOffset;
		uniform float _BaseCellSharpeness;
		uniform float _ShadowContribution;
		uniform sampler2D _MainTexture;
		uniform float4 _MainTexture_ST;
		uniform float4 _Tint;
		SamplerState sampler_MainTexture;
		uniform float4 _HighlightTint;
		uniform sampler2D _Highlight;
		uniform float _IndirectSpecularContribution;
		uniform float _HighlightCellOffset;
		uniform float _HighlightCellSharpness;
		uniform float _RimOffset;
		uniform float _RimPower;
		uniform float4 _RimColor;
		uniform float _TessValue;
		uniform float _TessMin;
		uniform float _TessMax;
		uniform float _TessPhongStrength;
		uniform float4 _OutlineColor;
		uniform float _OutlineWidth;

		float4 tessFunction( appdata_full v0, appdata_full v1, appdata_full v2 )
		{
			return UnityDistanceBasedTess( v0.vertex, v1.vertex, v2.vertex, _TessMin, _TessMax, _TessValue );
		}

		void vertexDataFunc( inout appdata_full v )
		{
			float3 Outline57 = 0;
			v.vertex.xyz += Outline57;
			v.vertex.w = 1;
		}

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			#ifdef UNITY_PASS_FORWARDBASE
			float ase_lightAtten = data.atten;
			if( _LightColor0.a == 0)
			ase_lightAtten = 0;
			#else
			float3 ase_lightAttenRGB = gi.light.color / ( ( _LightColor0.rgb ) + 0.000001 );
			float ase_lightAtten = max( max( ase_lightAttenRGB.r, ase_lightAttenRGB.g ), ase_lightAttenRGB.b );
			#endif
			#if defined(HANDLE_SHADOWS_BLENDING_IN_GI)
			half bakedAtten = UnitySampleBakedOcclusion(data.lightmapUV.xy, data.worldPos);
			float zDist = dot(_WorldSpaceCameraPos - data.worldPos, UNITY_MATRIX_V[2].xyz);
			float fadeDist = UnityComputeShadowFadeDistance(data.worldPos, zDist);
			ase_lightAtten = UnityMixRealtimeAndBakedShadows(data.atten, bakedAtten, UnityComputeShadowFade(fadeDist));
			#endif
			float2 uv_MainTexture = i.uv_texcoord * _MainTexture_ST.xy + _MainTexture_ST.zw;
			float4 tex2DNode1 = tex2D( _MainTexture, uv_MainTexture );
			float MainAlpha4 = ( tex2DNode1.a * _Tint.a );
			float3 temp_cast_1 = (1.0).xxx;
			float2 uv_NormalMap11 = i.uv_texcoord;
			float3 normalizeResult15 = normalize( (WorldNormalVector( i , UnpackScaleNormal( tex2D( _NormalMap, uv_NormalMap11 ), _NormalScale ) )) );
			float3 Normals16 = normalizeResult15;
			float3 indirectNormal79 = Normals16;
			float2 uv_Highlight60 = i.uv_texcoord;
			float4 temp_output_64_0 = ( _HighlightTint * tex2D( _Highlight, uv_Highlight60 ) );
			float Smoothness95 = (temp_output_64_0).a;
			Unity_GlossyEnvironmentData g79 = UnityGlossyEnvironmentSetup( Smoothness95, data.worldViewDir, indirectNormal79, float3(0,0,0));
			float3 indirectSpecular79 = UnityGI_IndirectSpecular( data, 1.0, indirectNormal79, g79 );
			float3 lerpResult84 = lerp( temp_cast_1 , indirectSpecular79 , _IndirectSpecularContribution);
			float3 IndirectSpecular99 = lerpResult84;
			float3 HighlightColor81 = (temp_output_64_0).rgb;
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float3 LightFalloff104 = ( ase_lightColor.rgb * ase_lightAtten );
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float3 normalizeResult4_g3 = normalize( ( ase_worldViewDir + ase_worldlightDir ) );
			float dotResult68 = dot( normalizeResult4_g3 , Normals16 );
			float dotResult21 = dot( Normals16 , ase_worldlightDir );
			float NDotL22 = dotResult21;
			#ifdef _STATICHIGHLIGHTS_ON
				float staticSwitch70 = NDotL22;
			#else
				float staticSwitch70 = dotResult68;
			#endif
			float3 Highlights88 = ( IndirectSpecular99 * HighlightColor81 * LightFalloff104 * pow( Smoothness95 , 1.5 ) * saturate( ( ( staticSwitch70 + _HighlightCellOffset ) / ( ( 1.0 - Smoothness95 ) * _HighlightCellSharpness ) ) ) );
			float3 temp_cast_2 = (1.0).xxx;
			UnityGI gi46 = gi;
			float3 diffNorm46 = Normals16;
			gi46 = UnityGI_Base( data, 1, diffNorm46 );
			float3 indirectDiffuse46 = gi46.indirect.diffuse + diffNorm46 * 0.0001;
			float3 lerpResult48 = lerp( temp_cast_2 , indirectDiffuse46 , _IndirectDiffuseContribution);
			float3 IndirectDiffuse101 = lerpResult48;
			float temp_output_34_0 = ( 1.0 - ( ( 1.0 - ase_lightAtten ) * _WorldSpaceLightPos0.w ) );
			float lerpResult36 = lerp( temp_output_34_0 , ( saturate( ( ( NDotL22 + _BaseCellOffset ) / _BaseCellSharpeness ) ) * ase_lightAtten ) , _ShadowContribution);
			float3 BaseColor7 = ( ( ( IndirectDiffuse101 * ase_lightColor.a * temp_output_34_0 ) + ( ase_lightColor.rgb * lerpResult36 ) ) * (( tex2DNode1 * _Tint )).rgb );
			float dotResult113 = dot( Normals16 , ase_worldViewDir );
			float3 RimColor127 = ( ( saturate( NDotL22 ) * pow( ( 1.0 - saturate( ( dotResult113 + _RimOffset ) ) ) , _RimPower ) ) * HighlightColor81 * LightFalloff104 * (_RimColor).rgb );
			float3 CustomLighting93 = ( Highlights88 + BaseColor7 + RimColor127 );
			c.rgb = CustomLighting93;
			c.a = MainAlpha4;
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
			o.Normal = float3(0,0,1);
			float3 temp_cast_0 = (1.0).xxx;
			float3 lerpResult48 = lerp( temp_cast_0 , float3(0,0,0) , _IndirectDiffuseContribution);
			float3 IndirectDiffuse101 = lerpResult48;
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float temp_output_34_0 = ( 1.0 - ( ( 1.0 - 1 ) * _WorldSpaceLightPos0.w ) );
			float2 uv_NormalMap11 = i.uv_texcoord;
			float3 normalizeResult15 = normalize( (WorldNormalVector( i , UnpackScaleNormal( tex2D( _NormalMap, uv_NormalMap11 ), _NormalScale ) )) );
			float3 Normals16 = normalizeResult15;
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult21 = dot( Normals16 , ase_worldlightDir );
			float NDotL22 = dotResult21;
			float lerpResult36 = lerp( temp_output_34_0 , ( saturate( ( ( NDotL22 + _BaseCellOffset ) / _BaseCellSharpeness ) ) * 1 ) , _ShadowContribution);
			float2 uv_MainTexture = i.uv_texcoord * _MainTexture_ST.xy + _MainTexture_ST.zw;
			float4 tex2DNode1 = tex2D( _MainTexture, uv_MainTexture );
			float3 BaseColor7 = ( ( ( IndirectDiffuse101 * ase_lightColor.a * temp_output_34_0 ) + ( ase_lightColor.rgb * lerpResult36 ) ) * (( tex2DNode1 * _Tint )).rgb );
			o.Albedo = BaseColor7;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows vertex:vertexDataFunc tessellate:tessFunction tessphong:_TessPhongStrength 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 4.6
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
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
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
				vertexDataFunc( v );
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
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				SurfaceOutputCustomLightingCustom o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputCustomLightingCustom, o )
				surf( surfIN, o );
				UnityGI gi;
				UNITY_INITIALIZE_OUTPUT( UnityGI, gi );
				o.Alpha = LightingStandardCustomLighting( o, worldViewDir, gi ).a;
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
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18600
-1920;0;1920;1019;2358.837;655.4752;1.779183;True;False
Node;AmplifyShaderEditor.CommentaryNode;12;-1699.113,164.0291;Inherit;False;1249;271;;5;16;15;14;13;11;Normals;0.7669993,0.4009434,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;13;-1667.113,228.0292;Inherit;False;Property;_NormalScale;Normal Scale;13;0;Create;True;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;11;-1379.113,228.0292;Inherit;True;Property;_NormalMap;NormalMap;12;2;[NoScaleOffset];[Normal];Create;True;0;0;False;0;False;-1;None;None;True;0;False;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldNormalVector;14;-1059.113,228.0292;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NormalizeNode;15;-835.113,228.0292;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;16;-675.1129,228.0292;Inherit;False;Normals;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;19;-1696.177,489.9003;Inherit;False;769;317;Normals Dot World Light Dir;4;18;20;21;22;N Dot L;0.7686275,0.4,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;18;-1664.177,553.9002;Inherit;False;16;Normals;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;20;-1664.177,649.9002;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;21;-1376.177,553.9002;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;59;-2942.247,-2106.663;Inherit;False;2437.724;728.9581;;25;86;100;88;97;96;83;72;69;64;61;60;66;63;65;68;85;78;77;76;71;70;87;81;75;62;Highlights;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;22;-1184.177,553.9002;Inherit;False;NDotL;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;2;-2940.05,-776.0681;Inherit;False;2786.464;887.6531;Comment;28;7;43;6;42;38;36;39;37;26;24;23;25;35;27;29;30;31;32;33;34;28;4;10;5;3;1;102;129;Base Color;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;24;-2923.451,-592.6971;Inherit;False;Property;_BaseCellOffset;Base Cell Offset;3;0;Create;True;0;0;False;0;False;0;0;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;45;-2943.492,-1329.115;Inherit;False;1044;485;;6;48;49;47;46;44;101;Indirect Diffuse;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;60;-2901.861,-1874.665;Inherit;True;Property;_Highlight;Highlight;6;1;[NoScaleOffset];Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;23;-2811.451,-720.6971;Inherit;False;22;NDotL;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;61;-2829.332,-2057.663;Float;False;Property;_HighlightTint;Highlight Tint;7;1;[HDR];Create;True;0;0;False;0;False;1,1,1,1;1,1,1,1;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;27;-2587.451,-608.6971;Inherit;False;Property;_BaseCellSharpeness;Base Cell Sharpeness;2;0;Create;True;0;0;False;0;False;0.01;0.01;0.01;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;64;-2499.61,-1858.197;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;109;-2928,896;Inherit;False;2016.676;503.3453;Comment;18;127;126;110;122;123;125;124;121;120;119;118;117;116;115;114;113;112;111;Rim Color;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;44;-2891.492,-1106.115;Inherit;False;16;Normals;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;25;-2603.451,-720.6971;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;62;-2357.369,-2044.895;Inherit;False;609;160;Comment;2;67;95;Spec/Smooth;1,1,1,1;0;0
Node;AmplifyShaderEditor.LightAttenuation;30;-2507.451,-496.6972;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;67;-2307.369,-1994.895;Inherit;False;False;False;False;True;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;26;-2283.451,-720.6971;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;110;-2880,992;Inherit;False;16;Normals;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;49;-2672.99,-998.1214;Inherit;False;Property;_IndirectDiffuseContribution;Indirect Diffuse Contribution;4;0;Create;True;0;0;False;0;False;1;0.175;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;47;-2608.99,-1222.122;Inherit;False;Constant;_DefaultDiffuseLight;Default Diffuse Light;8;0;Create;True;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightPos;33;-2539.451,-304.6972;Inherit;False;0;3;FLOAT4;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.IndirectDiffuseLighting;46;-2640.99,-1106.121;Inherit;False;World;1;0;FLOAT3;0,0,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;31;-2283.451,-400.6972;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;111;-2832,1104;Float;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;63;-2897.684,-1550.706;Inherit;False;16;Normals;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;32;-2091.451,-400.6972;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;65;-2941.247,-1663.809;Inherit;False;Blinn-Phong Half Vector;-1;;3;91a149ac9d615be429126c95e20753ce;0;0;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;95;-2032.412,-1994.464;Inherit;False;Smoothness;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;48;-2304.99,-1126.122;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;73;-2940.063,-2496.596;Inherit;False;1293.455;354.9327;;7;98;74;84;80;79;82;99;Indirect Specular;1,1,1,1;0;0
Node;AmplifyShaderEditor.SaturateNode;28;-2155.451,-720.6971;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;113;-2528,1040;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;112;-2592,1152;Float;False;Property;_RimOffset;Rim Offset;16;0;Create;True;0;0;False;0;False;0.6;0.6;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;114;-2304,1040;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;34;-1947.451,-400.6972;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;105;-1546.4,-2490.861;Inherit;False;623.7496;320.0745;;4;104;108;107;106;Light Falloff;1,0.9722607,0.3915094,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;96;-2197.594,-1755.496;Inherit;False;95;Smoothness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;74;-2890.063,-2375.956;Inherit;False;16;Normals;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;101;-2124.422,-1087.795;Inherit;False;IndirectDiffuse;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;68;-2675.027,-1617.366;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;29;-1963.451,-720.6971;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;66;-2728.318,-1459.578;Inherit;False;22;NDotL;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;98;-2724.354,-2310.611;Inherit;False;95;Smoothness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;35;-2075.451,-256.6972;Inherit;False;Property;_ShadowContribution;Shadow Contribution;5;0;Create;True;0;0;False;0;False;0.5;0.697;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;80;-2439.367,-2446.596;Float;False;Constant;_Float5;Float 5;20;0;Create;True;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.IndirectSpecularLight;79;-2465.996,-2359.372;Inherit;False;World;3;0;FLOAT3;0,0,0;False;1;FLOAT;0.5;False;2;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StaticSwitch;70;-2459.695,-1670.681;Float;False;Property;_StaticHighLights;Static HighLights;11;0;Create;True;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;71;-2481.035,-1484.548;Float;False;Property;_HighlightCellOffset;Highlight Cell Offset;8;0;Create;True;0;0;False;0;False;-0.95;-0.95;-1;-0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;3;-1387.451,-128.6971;Inherit;False;Property;_Tint;Tint;1;0;Create;True;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;82;-2533.169,-2246.265;Float;False;Property;_IndirectSpecularContribution;Indirect Specular Contribution;10;0;Create;True;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;37;-1713.451,-709.6971;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.SamplerNode;1;-1467.451,-352.6972;Inherit;True;Property;_MainTexture;Main Texture;0;0;Create;True;0;0;False;0;False;-1;None;fee5b841ca463114c8419de7e92cdb35;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LightAttenuation;107;-1529.097,-2280.451;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;115;-2144,1040;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;106;-1498.586,-2421.706;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;72;-2142.293,-1470.9;Float;False;Property;_HighlightCellSharpness;Highlight Cell Sharpness;9;0;Create;True;0;0;False;0;False;0.01;0.01;0.001;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;69;-1964.583,-1738.954;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;36;-1659.451,-400.6972;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;102;-1500.883,-700.3703;Inherit;False;101;IndirectDiffuse;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;39;-1291.451,-688.6971;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;117;-2016,944;Inherit;False;22;NDotL;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;75;-1691.91,-1900.62;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;76;-2153.26,-1644.461;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;38;-1291.451,-464.6972;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;108;-1275.967,-2350.514;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;116;-1968,1040;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;5;-875.451,-240.6971;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;84;-2115.304,-2393.75;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;118;-2080,1168;Float;False;Property;_RimPower;Rim Power;15;0;Create;True;0;0;False;0;False;0.4;0.4;0.01;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;77;-1727.345,-1489.996;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;120;-1776,1040;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;78;-1502.022,-1649.154;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;119;-1792,960;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;121;-1760,1200;Float;False;Property;_RimColor;Rim Color;14;1;[HDR];Create;True;0;0;False;0;False;1,1,1,0;1,1,1,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;99;-1939.155,-2395.109;Inherit;False;IndirectSpecular;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode;6;-731.451,-243.6971;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;104;-1116.529,-2358.058;Inherit;False;LightFalloff;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;97;-1806.594,-1780.496;Inherit;False;95;Smoothness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;42;-1131.451,-576.6971;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;81;-1379.341,-1933.195;Float;False;HighlightColor;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;125;-1488,976;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;100;-1105.86,-1995.733;Inherit;False;99;IndirectSpecular;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;122;-1504,1152;Inherit;False;104;LightFalloff;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;43;-539.4509,-416.6972;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;123;-1504,1072;Inherit;False;81;HighlightColor;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PowerNode;86;-1423.172,-1783.75;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;83;-1276.268,-1843.877;Inherit;False;104;LightFalloff;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode;124;-1504,1248;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;51;-2929.643,172.3672;Inherit;False;1180.5;395.1999;;9;56;55;54;53;52;50;57;130;131;Outline;1,0.6650944,0.6650944,1;0;0
Node;AmplifyShaderEditor.SaturateNode;85;-1341.137,-1648.441;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;126;-1264.986,1066.963;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;87;-877.0255,-1936.263;Inherit;False;5;5;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;50;-2897.643,332.3672;Inherit;False;Property;_OutlineColor;Outline Color;17;0;Create;True;0;0;False;0;False;0.5294118,0.5294118,0.5294118,0;0,0,0,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;7;-356.7656,-420.1841;Inherit;False;BaseColor;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;129;-1143.177,-260.5522;Inherit;False;OutlineCustomWidth;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;88;-703.8978,-1941.929;Inherit;False;Highlights;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;53;-2641.644,236.3672;Inherit;False;7;BaseColor;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;90;-1859.099,-1324.069;Inherit;False;672.548;329.1574;;5;93;89;91;92;128;Final Lighting;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;127;-1120.529,1066.404;Inherit;False;RimColor;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;55;-2549.644,490.3671;Inherit;False;Property;_OutlineWidth;Outline Width;18;0;Create;True;0;0;False;0;False;0.02;0.0075;0;0.2;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;130;-2521.177,404.4478;Inherit;False;129;OutlineCustomWidth;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;52;-2641.644,332.3672;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;128;-1810.972,-1095.979;Inherit;False;127;RimColor;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;54;-2385.644,268.3672;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;131;-2278.177,416.4478;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;91;-1816.128,-1202.88;Inherit;False;7;BaseColor;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;92;-1822.715,-1287.261;Inherit;False;88;Highlights;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OutlineNode;56;-2112,272;Inherit;False;0;True;None;0;0;Front;3;0;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;89;-1560.436,-1217.373;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;10;-1035.451,-112.6971;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;4;-811.451,-96.69715;Inherit;False;MainAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;93;-1379.541,-1221.342;Inherit;False;CustomLighting;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;103;201.4948,-2379.825;Inherit;False;568.8065;542.0792;;5;9;8;94;58;0;Master;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;57;-1920,272;Inherit;False;Outline;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;94;251.4948,-2045.946;Inherit;False;93;CustomLighting;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;8;276.7329,-2127.389;Inherit;False;4;MainAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;9;269.355,-2326.796;Inherit;False;7;BaseColor;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;58;269.8409,-1953.745;Inherit;False;57;Outline;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;515.3013,-2329.824;Float;False;True;-1;6;ASEMaterialInspector;0;0;CustomLighting;Chrome Evo/Toon;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;True;Transparent;;AlphaTest;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;True;0;4;10;25;True;0.5;True;2;5;False;-1;10;False;-1;2;5;False;-1;10;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;24;-1;-1;19;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;11;5;13;0
WireConnection;14;0;11;0
WireConnection;15;0;14;0
WireConnection;16;0;15;0
WireConnection;21;0;18;0
WireConnection;21;1;20;0
WireConnection;22;0;21;0
WireConnection;64;0;61;0
WireConnection;64;1;60;0
WireConnection;25;0;23;0
WireConnection;25;1;24;0
WireConnection;67;0;64;0
WireConnection;26;0;25;0
WireConnection;26;1;27;0
WireConnection;46;0;44;0
WireConnection;31;0;30;0
WireConnection;32;0;31;0
WireConnection;32;1;33;2
WireConnection;95;0;67;0
WireConnection;48;0;47;0
WireConnection;48;1;46;0
WireConnection;48;2;49;0
WireConnection;28;0;26;0
WireConnection;113;0;110;0
WireConnection;113;1;111;0
WireConnection;114;0;113;0
WireConnection;114;1;112;0
WireConnection;34;0;32;0
WireConnection;101;0;48;0
WireConnection;68;0;65;0
WireConnection;68;1;63;0
WireConnection;29;0;28;0
WireConnection;29;1;30;0
WireConnection;79;0;74;0
WireConnection;79;1;98;0
WireConnection;70;1;68;0
WireConnection;70;0;66;0
WireConnection;115;0;114;0
WireConnection;69;0;96;0
WireConnection;36;0;34;0
WireConnection;36;1;29;0
WireConnection;36;2;35;0
WireConnection;39;0;102;0
WireConnection;39;1;37;2
WireConnection;39;2;34;0
WireConnection;75;0;64;0
WireConnection;76;0;70;0
WireConnection;76;1;71;0
WireConnection;38;0;37;1
WireConnection;38;1;36;0
WireConnection;108;0;106;1
WireConnection;108;1;107;0
WireConnection;116;0;115;0
WireConnection;5;0;1;0
WireConnection;5;1;3;0
WireConnection;84;0;80;0
WireConnection;84;1;79;0
WireConnection;84;2;82;0
WireConnection;77;0;69;0
WireConnection;77;1;72;0
WireConnection;120;0;116;0
WireConnection;120;1;118;0
WireConnection;78;0;76;0
WireConnection;78;1;77;0
WireConnection;119;0;117;0
WireConnection;99;0;84;0
WireConnection;6;0;5;0
WireConnection;104;0;108;0
WireConnection;42;0;39;0
WireConnection;42;1;38;0
WireConnection;81;0;75;0
WireConnection;125;0;119;0
WireConnection;125;1;120;0
WireConnection;43;0;42;0
WireConnection;43;1;6;0
WireConnection;86;0;97;0
WireConnection;124;0;121;0
WireConnection;85;0;78;0
WireConnection;126;0;125;0
WireConnection;126;1;123;0
WireConnection;126;2;122;0
WireConnection;126;3;124;0
WireConnection;87;0;100;0
WireConnection;87;1;81;0
WireConnection;87;2;83;0
WireConnection;87;3;86;0
WireConnection;87;4;85;0
WireConnection;7;0;43;0
WireConnection;129;0;1;4
WireConnection;88;0;87;0
WireConnection;127;0;126;0
WireConnection;52;0;50;0
WireConnection;54;0;53;0
WireConnection;54;1;52;0
WireConnection;131;0;130;0
WireConnection;131;1;55;0
WireConnection;56;0;54;0
WireConnection;56;1;131;0
WireConnection;89;0;92;0
WireConnection;89;1;91;0
WireConnection;89;2;128;0
WireConnection;10;0;1;4
WireConnection;10;1;3;4
WireConnection;4;0;10;0
WireConnection;93;0;89;0
WireConnection;57;0;56;0
WireConnection;0;0;9;0
WireConnection;0;9;8;0
WireConnection;0;13;94;0
WireConnection;0;11;58;0
ASEEND*/
//CHKSM=4A5D35444DF5BE1C1F9439229883B6BAAF3B06B5