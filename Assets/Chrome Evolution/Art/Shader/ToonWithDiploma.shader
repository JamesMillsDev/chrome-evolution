// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Chrome Evo/ToonWithDiploma"
{
	Properties
	{
		_MainTexture("Main Texture", 2D) = "white" {}
		_Tint("Tint", Color) = (1,1,1,1)
		_BaseCellSharpeness("Base Cell Sharpeness", Range( 0.01 , 1)) = 0.01
		_BaseCellOffset("Base Cell Offset", Range( -1 , 1)) = 0
		_ShadowContribution("Shadow Contribution", Range( 0 , 1)) = 0.5
		_IndirectDiffuseContribution("Indirect Diffuse Contribution", Range( 0 , 1)) = 1
		[NoScaleOffset]_Highlight("Highlight", 2D) = "white" {}
		_HighlightTint("Highlight Tint", Color) = (1,1,1,1)
		_HighlightCellOffset("Highlight Cell Offset", Range( -1 , -0.5)) = -0.95
		_HighlightCellSharpness("Highlight Cell Sharpness", Range( 0.001 , 1)) = 0.01
		_IndirectSpecularContribution("Indirect Specular Contribution", Range( 0 , 1)) = 1
		[Toggle(_STATICHIGHLIGHTS_ON)] _StaticHighlights("Static Highlights", Float) = 0
		[NoScaleOffset][Normal]_NormalMap("NormalMap", 2D) = "bump" {}
		_NormalScale("Normal Scale", Range( 0 , 1)) = 1
		_RimColor("Rim Color", Color) = (1,1,1,0)
		_RimPower("Rim Power", Range( 0 , 1)) = 0.4
		_RimOffset("RimOffset", Range( 0 , 1)) = 0.6
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
			float CustomOutlineWidth113 = tex2DNode1.a;
			float outlineVar = ( CustomOutlineWidth113 * _OutlineWidth );
			v.vertex.xyz *= ( 1 + outlineVar);
		}
		inline half4 LightingOutline( SurfaceOutput s, half3 lightDir, half atten ) { return half4 ( 0,0,0, s.Alpha); }
		void outlineSurf( Input i, inout SurfaceOutput o )
		{
			float3 temp_cast_0 = (1.0).xxx;
			float3 lerpResult48 = lerp( temp_cast_0 , float3(0,0,0) , _IndirectDiffuseContribution);
			float3 IndirectDiffuse59 = lerpResult48;
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
			float3 BaseColor7 = ( ( ( IndirectDiffuse59 * ase_lightColor.a * temp_output_34_0 ) + ( ase_lightColor.rgb * lerpResult36 ) ) * (( tex2DNode1 * _Tint )).rgb );
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
			float3 indirectNormal78 = Normals16;
			float2 uv_Highlight70 = i.uv_texcoord;
			float4 temp_output_71_0 = ( _HighlightTint * tex2D( _Highlight, uv_Highlight70 ) );
			float Smoothness73 = (temp_output_71_0).a;
			Unity_GlossyEnvironmentData g78 = UnityGlossyEnvironmentSetup( Smoothness73, data.worldViewDir, indirectNormal78, float3(0,0,0));
			float3 indirectSpecular78 = UnityGI_IndirectSpecular( data, 1.0, indirectNormal78, g78 );
			float3 lerpResult81 = lerp( temp_cast_1 , indirectSpecular78 , _IndirectSpecularContribution);
			float3 IndirectSpecular82 = lerpResult81;
			float3 HighlightColor89 = (temp_output_71_0).rgb;
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float3 LightFalloff87 = ( ase_lightColor.rgb * ase_lightAtten );
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float3 normalizeResult4_g1 = normalize( ( ase_worldViewDir + ase_worldlightDir ) );
			float dotResult92 = dot( normalizeResult4_g1 , Normals16 );
			float dotResult21 = dot( Normals16 , ase_worldlightDir );
			float NDotL22 = dotResult21;
			#ifdef _STATICHIGHLIGHTS_ON
				float staticSwitch93 = NDotL22;
			#else
				float staticSwitch93 = dotResult92;
			#endif
			float CellShading103 = saturate( ( ( staticSwitch93 + _HighlightCellOffset ) / ( ( 1.0 - Smoothness73 ) * _HighlightCellSharpness ) ) );
			float3 Highlights111 = ( IndirectSpecular82 * HighlightColor89 * LightFalloff87 * pow( Smoothness73 , 1.5 ) * CellShading103 );
			float3 temp_cast_2 = (1.0).xxx;
			UnityGI gi46 = gi;
			float3 diffNorm46 = Normals16;
			gi46 = UnityGI_Base( data, 1, diffNorm46 );
			float3 indirectDiffuse46 = gi46.indirect.diffuse + diffNorm46 * 0.0001;
			float3 lerpResult48 = lerp( temp_cast_2 , indirectDiffuse46 , _IndirectDiffuseContribution);
			float3 IndirectDiffuse59 = lerpResult48;
			float temp_output_34_0 = ( 1.0 - ( ( 1.0 - ase_lightAtten ) * _WorldSpaceLightPos0.w ) );
			float lerpResult36 = lerp( temp_output_34_0 , ( saturate( ( ( NDotL22 + _BaseCellOffset ) / _BaseCellSharpeness ) ) * ase_lightAtten ) , _ShadowContribution);
			float3 BaseColor7 = ( ( ( IndirectDiffuse59 * ase_lightColor.a * temp_output_34_0 ) + ( ase_lightColor.rgb * lerpResult36 ) ) * (( tex2DNode1 * _Tint )).rgb );
			float dotResult119 = dot( Normals16 , ase_worldViewDir );
			float3 RimColor134 = ( ( saturate( NDotL22 ) * pow( ( 1.0 - saturate( ( dotResult119 + _RimOffset ) ) ) , _RimPower ) ) * HighlightColor89 * LightFalloff87 * (_RimColor).rgb );
			float3 FinalLighting65 = ( Highlights111 + BaseColor7 + RimColor134 );
			c.rgb = FinalLighting65;
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
			float3 IndirectDiffuse59 = lerpResult48;
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
			float3 BaseColor7 = ( ( ( IndirectDiffuse59 * ase_lightColor.a * temp_output_34_0 ) + ( ase_lightColor.rgb * lerpResult36 ) ) * (( tex2DNode1 * _Tint )).rgb );
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
0;73;1920;928;1366.199;1074.009;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;12;-1728,672;Inherit;False;1249;271;;5;16;15;14;13;11;Normals;0.7669993,0.4009434,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;13;-1696,736;Inherit;False;Property;_NormalScale;Normal Scale;13;0;Create;True;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;11;-1408,736;Inherit;True;Property;_NormalMap;NormalMap;12;2;[NoScaleOffset];[Normal];Create;True;0;0;False;0;False;-1;None;None;True;0;False;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldNormalVector;14;-1088,736;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NormalizeNode;15;-864,736;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;16;-704,736;Inherit;False;Normals;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;19;-1728,992;Inherit;False;769;317;Normals Dot World Light Dir;4;18;20;21;22;N Dot L;0.7686275,0.4,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;18;-1696,1056;Inherit;False;16;Normals;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;68;-2944,-1600;Inherit;False;1958.43;753.8112;;28;103;102;101;99;100;98;97;95;93;96;94;92;91;90;89;88;71;70;69;74;105;104;106;107;109;108;110;111;Highlights;0.3160377,0.3184829,1,1;0;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;20;-1696,1152;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;21;-1408,1056;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;69;-2832,-1552;Inherit;False;Property;_HighlightTint;Highlight Tint;7;0;Create;True;0;0;False;0;False;1,1,1,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;70;-2912,-1376;Inherit;True;Property;_Highlight;Highlight;6;1;[NoScaleOffset];Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;74;-2368,-1536;Inherit;False;454;142;;2;73;72;Spec/Smooth;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;2;-2944,-256;Inherit;False;2786.464;887.6531;Comment;28;7;43;6;42;38;36;39;37;26;24;23;25;35;27;29;30;31;32;33;34;28;4;10;5;3;1;61;113;Base Color;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;22;-1216,1056;Inherit;False;NDotL;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;71;-2544,-1376;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;23;-2816,-192;Inherit;False;22;NDotL;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;24;-2928,-64;Inherit;False;Property;_BaseCellOffset;Base Cell Offset;3;0;Create;True;0;0;False;0;False;0;0;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;72;-2336,-1488;Inherit;False;False;False;False;True;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;45;-2944,-800;Inherit;False;1006;501;;6;48;46;47;49;44;59;Indirect Diffuse;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;27;-2592,-80;Inherit;False;Property;_BaseCellSharpeness;Base Cell Sharpeness;2;0;Create;True;0;0;False;0;False;0.01;0.01;0.01;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;30;-2512,32;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;91;-2816,-1056;Inherit;False;16;Normals;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;116;-2944,1344;Inherit;False;1978.7;487.4105;;18;128;126;123;127;125;124;120;117;121;119;118;122;130;129;131;132;133;134;Rim Color;1,0,0,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;25;-2608,-192;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;73;-2112,-1488;Inherit;False;Smoothness;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;90;-2880,-1136;Inherit;False;Blinn-Phong Half Vector;-1;;1;91a149ac9d615be429126c95e20753ce;0;0;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;44;-2880,-576;Inherit;False;16;Normals;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;92;-2608,-1104;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;31;-2288,128;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;117;-2912,1472;Inherit;False;16;Normals;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;118;-2912,1568;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceLightPos;33;-2544,224;Inherit;False;0;3;FLOAT4;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;47;-2608,-688;Inherit;False;Constant;_DefaultDiffuseLight;Default Diffuse Light;8;0;Create;True;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;94;-2656,-960;Inherit;False;22;NDotL;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;97;-2048,-1008;Inherit;False;73;Smoothness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.IndirectDiffuseLighting;46;-2640,-576;Inherit;False;World;1;0;FLOAT3;0,0,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;49;-2672,-464;Inherit;False;Property;_IndirectDiffuseContribution;Indirect Diffuse Contribution;5;0;Create;True;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;26;-2288,-192;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;119;-2688,1472;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;120;-2720,1632;Inherit;False;Property;_RimOffset;RimOffset;16;0;Create;True;0;0;False;0;False;0.6;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;28;-2160,-192;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;99;-1968,-928;Inherit;False;Property;_HighlightCellSharpness;Highlight Cell Sharpness;9;0;Create;True;0;0;False;0;False;0.01;0;0.001;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;93;-2384,-1120;Inherit;False;Property;_StaticHighlights;Static Highlights;11;0;Create;True;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;32;-2096,128;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;75;-2944,-2048;Inherit;False;940.7;405.6;;7;79;80;82;77;76;81;78;Indirect Specular;1,1,1,1;0;0
Node;AmplifyShaderEditor.LerpOp;48;-2304,-592;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;95;-2416,-992;Inherit;False;Property;_HighlightCellOffset;Highlight Cell Offset;8;0;Create;True;0;0;False;0;False;-0.95;0;-1;-0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;98;-1840,-1008;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;121;-2400,1472;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;77;-2912,-1808;Inherit;False;73;Smoothness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;34;-1952,128;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;35;-2080,272;Inherit;False;Property;_ShadowContribution;Shadow Contribution;4;0;Create;True;0;0;False;0;False;0.5;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;96;-2048,-1120;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;83;-1984,-2048;Inherit;False;621;406;;4;84;85;86;87;Light Falloff;1,1,0,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;29;-1968,-192;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;59;-2128,-608;Inherit;False;IndirectDiffuse;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;76;-2896,-1888;Inherit;False;16;Normals;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;100;-1648,-976;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;79;-2688,-1728;Inherit;False;Property;_IndirectSpecularContribution;Indirect Specular Contribution;10;0;Create;True;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;80;-2608,-1984;Inherit;False;Constant;_DefaultSpecular;Default Specular;14;0;Create;True;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;122;-2272,1472;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;-1472,176;Inherit;True;Property;_MainTexture;Main Texture;0;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LightColorNode;84;-1968,-2000;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.LightAttenuation;85;-1968,-1840;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;36;-1664,128;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.IndirectSpecularLight;78;-2656,-1872;Inherit;False;World;3;0;FLOAT3;0,0,1;False;1;FLOAT;0.5;False;2;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;3;-1392,400;Inherit;False;Property;_Tint;Tint;1;0;Create;True;0;0;False;0;False;1,1,1,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;101;-1504,-1120;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;61;-1552,-192;Inherit;False;59;IndirectDiffuse;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LightColorNode;37;-1760,-192;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.GetLocalVarNode;126;-2128,1392;Inherit;False;22;NDotL;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;124;-2256,1568;Inherit;False;Property;_RimPower;Rim Power;15;0;Create;True;0;0;False;0;False;0.4;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;123;-2112,1472;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;5;-880,288;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;102;-1360,-1120;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;81;-2368,-1904;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;86;-1728,-1920;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode;88;-2336,-1376;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;38;-1296,64;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;39;-1296,-160;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;129;-1824,1648;Inherit;False;Property;_RimColor;Rim Color;14;0;Create;True;0;0;False;0;False;1,1,1,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;127;-1936,1392;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;103;-1200,-1136;Inherit;False;CellShading;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;125;-1952,1472;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;6;-736,288;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;82;-2208,-1904;Inherit;False;IndirectSpecular;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;89;-2112,-1376;Inherit;False;HighlightColor;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;107;-1872,-1296;Inherit;False;73;Smoothness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;42;-1136,-48;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;87;-1568,-1920;Inherit;False;LightFalloff;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;105;-1712,-1456;Inherit;False;89;HighlightColor;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;108;-1696,-1200;Inherit;False;103;CellShading;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;106;-1696,-1376;Inherit;False;87;LightFalloff;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PowerNode;109;-1664,-1296;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;51;-2944,672;Inherit;False;1180.5;395.1999;;9;56;55;54;53;52;50;57;114;115;Outline;1,0.6650944,0.6650944,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;132;-1600,1568;Inherit;False;87;LightFalloff;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode;130;-1616,1648;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;104;-1728,-1536;Inherit;False;82;IndirectSpecular;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;128;-1552,1392;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;43;-544,112;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;131;-1616,1488;Inherit;False;89;HighlightColor;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;110;-1440,-1424;Inherit;False;5;5;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;113;-944,176;Inherit;False;CustomOutlineWidth;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;7;-368,96;Inherit;False;BaseColor;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;133;-1344,1504;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;50;-2912,832;Inherit;False;Property;_OutlineColor;Outline Color;17;0;Create;True;0;0;False;0;False;0.5294118,0.5294118,0.5294118,0;0.5294118,0.5294118,0.5294118,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;53;-2656,736;Inherit;False;7;BaseColor;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;114;-2576,912;Inherit;False;113;CustomOutlineWidth;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;111;-1280,-1424;Inherit;False;Highlights;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;55;-2624,992;Inherit;False;Property;_OutlineWidth;Outline Width;18;0;Create;True;0;0;False;0;False;0.02;0.02;0;0.2;0;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;52;-2656,832;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;134;-1200,1504;Inherit;False;RimColor;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;62;-1904,-800;Inherit;False;693;504;;5;64;63;65;112;135;Final Lighting;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;135;-1856,-448;Inherit;False;134;RimColor;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;63;-1856,-576;Inherit;False;7;BaseColor;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;115;-2336,928;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;54;-2400,768;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;112;-1856,-688;Inherit;False;111;Highlights;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OutlineNode;56;-2208,832;Inherit;False;1;True;None;0;0;Front;3;0;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;10;-1040,416;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;64;-1616,-592;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;67;-720,-832;Inherit;False;545;547;;5;8;9;0;58;66;Main Node;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;65;-1456,-608;Inherit;False;FinalLighting;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;4;-816,432;Inherit;False;MainAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;57;-1968,832;Inherit;False;Outline;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;58;-656,-400;Inherit;False;57;Outline;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;66;-656,-496;Inherit;False;65;FinalLighting;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;9;-672,-784;Inherit;False;7;BaseColor;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;8;-656,-592;Inherit;False;4;MainAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;-432,-768;Float;False;True;-1;6;ASEMaterialInspector;0;0;CustomLighting;Chrome Evo/ToonWithDiploma;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;True;Transparent;;AlphaTest;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;True;0;4;10;25;True;0.5;True;2;5;False;-1;10;False;-1;2;5;False;-1;10;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;24;-1;-1;19;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;11;5;13;0
WireConnection;14;0;11;0
WireConnection;15;0;14;0
WireConnection;16;0;15;0
WireConnection;21;0;18;0
WireConnection;21;1;20;0
WireConnection;22;0;21;0
WireConnection;71;0;69;0
WireConnection;71;1;70;0
WireConnection;72;0;71;0
WireConnection;25;0;23;0
WireConnection;25;1;24;0
WireConnection;73;0;72;0
WireConnection;92;0;90;0
WireConnection;92;1;91;0
WireConnection;31;0;30;0
WireConnection;46;0;44;0
WireConnection;26;0;25;0
WireConnection;26;1;27;0
WireConnection;119;0;117;0
WireConnection;119;1;118;0
WireConnection;28;0;26;0
WireConnection;93;1;92;0
WireConnection;93;0;94;0
WireConnection;32;0;31;0
WireConnection;32;1;33;2
WireConnection;48;0;47;0
WireConnection;48;1;46;0
WireConnection;48;2;49;0
WireConnection;98;0;97;0
WireConnection;121;0;119;0
WireConnection;121;1;120;0
WireConnection;34;0;32;0
WireConnection;96;0;93;0
WireConnection;96;1;95;0
WireConnection;29;0;28;0
WireConnection;29;1;30;0
WireConnection;59;0;48;0
WireConnection;100;0;98;0
WireConnection;100;1;99;0
WireConnection;122;0;121;0
WireConnection;36;0;34;0
WireConnection;36;1;29;0
WireConnection;36;2;35;0
WireConnection;78;0;76;0
WireConnection;78;1;77;0
WireConnection;101;0;96;0
WireConnection;101;1;100;0
WireConnection;123;0;122;0
WireConnection;5;0;1;0
WireConnection;5;1;3;0
WireConnection;102;0;101;0
WireConnection;81;0;80;0
WireConnection;81;1;78;0
WireConnection;81;2;79;0
WireConnection;86;0;84;1
WireConnection;86;1;85;0
WireConnection;88;0;71;0
WireConnection;38;0;37;1
WireConnection;38;1;36;0
WireConnection;39;0;61;0
WireConnection;39;1;37;2
WireConnection;39;2;34;0
WireConnection;127;0;126;0
WireConnection;103;0;102;0
WireConnection;125;0;123;0
WireConnection;125;1;124;0
WireConnection;6;0;5;0
WireConnection;82;0;81;0
WireConnection;89;0;88;0
WireConnection;42;0;39;0
WireConnection;42;1;38;0
WireConnection;87;0;86;0
WireConnection;109;0;107;0
WireConnection;130;0;129;0
WireConnection;128;0;127;0
WireConnection;128;1;125;0
WireConnection;43;0;42;0
WireConnection;43;1;6;0
WireConnection;110;0;104;0
WireConnection;110;1;105;0
WireConnection;110;2;106;0
WireConnection;110;3;109;0
WireConnection;110;4;108;0
WireConnection;113;0;1;4
WireConnection;7;0;43;0
WireConnection;133;0;128;0
WireConnection;133;1;131;0
WireConnection;133;2;132;0
WireConnection;133;3;130;0
WireConnection;111;0;110;0
WireConnection;52;0;50;0
WireConnection;134;0;133;0
WireConnection;115;0;114;0
WireConnection;115;1;55;0
WireConnection;54;0;53;0
WireConnection;54;1;52;0
WireConnection;56;0;54;0
WireConnection;56;1;115;0
WireConnection;10;0;1;4
WireConnection;10;1;3;4
WireConnection;64;0;112;0
WireConnection;64;1;63;0
WireConnection;64;2;135;0
WireConnection;65;0;64;0
WireConnection;4;0;10;0
WireConnection;57;0;56;0
WireConnection;0;0;9;0
WireConnection;0;9;8;0
WireConnection;0;13;66;0
WireConnection;0;11;58;0
ASEEND*/
//CHKSM=8D311DBA517D9688C6838AADB388A72D1FD28614