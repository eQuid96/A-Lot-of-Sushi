// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "AcquarioShader"
{
	Properties
	{
		_Color0("Color 0", Color) = (0,0.63305,1,0)
		_Texture1("Texture 1", 2D) = "white" {}
		_1texstrenght("1 tex strenght", Float) = 0
		_Texture2("Texture 2", 2D) = "white" {}
		_2texstrenght("2 tex strenght", Float) = 0
		_Texture3("Texture 3", 2D) = "white" {}
		_3textstrenght("3 text strenght", Float) = 0
		_Texture4("Texture 4", 2D) = "bump" {}
		_mainalphastrenght("main alpha strenght", Float) = 0
		_Normalstrenght("Normal strenght", Float) = 1
		_Smooth("Smooth", Range( 0 , 1)) = 0
		_Color1("Color 1", Color) = (0,0.8721261,1,0)

	}

	SubShader
	{
		LOD 0

		
		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Transparent" "Queue"="Transparent" }
		
		Cull Off
		HLSLINCLUDE
		#pragma target 3.0
		ENDHLSL

		
		Pass
		{
			Name "Forward"
			Tags { "LightMode"="UniversalForward" }
			
			Blend SrcAlpha OneMinusSrcAlpha , One OneMinusSrcAlpha
			ZWrite Off
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA
			

			HLSLPROGRAM
			#define _RECEIVE_SHADOWS_OFF 1
			#pragma multi_compile_instancing
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define _EMISSION
			#define ASE_SRP_VERSION 70108
			#define REQUIRE_OPAQUE_TEXTURE 1

			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x

			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
			#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
			#pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
			#pragma multi_compile _ _SHADOWS_SOFT
			#pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
			
			#pragma multi_compile _ DIRLIGHTMAP_COMBINED
			#pragma multi_compile _ LIGHTMAP_ON

			#pragma vertex vert
			#pragma fragment frag


			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			
			

			sampler2D _Texture1;
			sampler2D _Texture2;
			sampler2D _Texture3;
			sampler2D _Texture4;
			CBUFFER_START( UnityPerMaterial )
			float4 _Color0;
			float _1texstrenght;
			float4 _Texture1_ST;
			float4 _Texture2_ST;
			float _2texstrenght;
			float4 _Texture3_ST;
			float _3textstrenght;
			float4 _Color1;
			float _Normalstrenght;
			float4 _Texture4_ST;
			float _Smooth;
			float _mainalphastrenght;
			CBUFFER_END


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_tangent : TANGENT;
				float4 texcoord1 : TEXCOORD1;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float4 lightmapUVOrVertexSH : TEXCOORD0;
				half4 fogFactorAndVertexLight : TEXCOORD1;
				float4 shadowCoord : TEXCOORD2;
				float4 tSpace0 : TEXCOORD3;
				float4 tSpace1 : TEXCOORD4;
				float4 tSpace2 : TEXCOORD5;
				float4 ase_texcoord7 : TEXCOORD7;
				float4 ase_texcoord8 : TEXCOORD8;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			inline float4 ASE_ComputeGrabScreenPos( float4 pos )
			{
				#if UNITY_UV_STARTS_AT_TOP
				float scale = -1.0;
				#else
				float scale = 1.0;
				#endif
				float4 o = pos;
				o.y = pos.w * 0.5f;
				o.y = ( pos.y - o.y ) * _ProjectionParams.x * scale + o.y;
				return o;
			}
			

			VertexOutput vert ( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord8 = screenPos;
				
				o.ase_texcoord7.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord7.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = defaultVertexValue;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif
				v.ase_normal = v.ase_normal;

				float3 lwWNormal = TransformObjectToWorldNormal(v.ase_normal);
				float3 lwWorldPos = TransformObjectToWorld(v.vertex.xyz);
				float3 lwWTangent = TransformObjectToWorldDir(v.ase_tangent.xyz);
				float3 lwWBinormal = normalize(cross(lwWNormal, lwWTangent) * v.ase_tangent.w);
				o.tSpace0 = float4(lwWTangent.x, lwWBinormal.x, lwWNormal.x, lwWorldPos.x);
				o.tSpace1 = float4(lwWTangent.y, lwWBinormal.y, lwWNormal.y, lwWorldPos.y);
				o.tSpace2 = float4(lwWTangent.z, lwWBinormal.z, lwWNormal.z, lwWorldPos.z);

				VertexPositionInputs vertexInput = GetVertexPositionInputs(v.vertex.xyz);
				
				OUTPUT_LIGHTMAP_UV( v.texcoord1, unity_LightmapST, o.lightmapUVOrVertexSH.xy );
				OUTPUT_SH(lwWNormal, o.lightmapUVOrVertexSH.xyz );

				half3 vertexLight = VertexLighting(vertexInput.positionWS, lwWNormal);
				#ifdef ASE_FOG
					half fogFactor = ComputeFogFactor( vertexInput.positionCS.z );
				#else
					half fogFactor = 0;
				#endif
				o.fogFactorAndVertexLight = half4(fogFactor, vertexLight);
				o.clipPos = vertexInput.positionCS;

				#ifdef _MAIN_LIGHT_SHADOWS
					o.shadowCoord = GetShadowCoord(vertexInput);
				#endif
				return o;
			}

			half4 frag ( VertexOutput IN  ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);

				float3 WorldSpaceNormal = normalize(float3(IN.tSpace0.z,IN.tSpace1.z,IN.tSpace2.z));
				float3 WorldSpaceTangent = float3(IN.tSpace0.x,IN.tSpace1.x,IN.tSpace2.x);
				float3 WorldSpaceBiTangent = float3(IN.tSpace0.y,IN.tSpace1.y,IN.tSpace2.y);
				float3 WorldSpacePosition = float3(IN.tSpace0.w,IN.tSpace1.w,IN.tSpace2.w);
				float3 WorldSpaceViewDirection = _WorldSpaceCameraPos.xyz  - WorldSpacePosition;
	
				#if SHADER_HINT_NICE_QUALITY
					WorldSpaceViewDirection = SafeNormalize( WorldSpaceViewDirection );
				#endif

				float2 uv0_Texture1 = IN.ase_texcoord7.xy * _Texture1_ST.xy + _Texture1_ST.zw;
				float2 panner23 = ( 1.0 * _Time.y * float2( 0.2,0.1 ) + uv0_Texture1);
				float2 uv0_Texture2 = IN.ase_texcoord7.xy * _Texture2_ST.xy + _Texture2_ST.zw;
				float2 panner19 = ( 1.0 * _Time.y * float2( 0.0001,0.0003 ) + uv0_Texture2);
				float mulTime21 = _TimeParameters.y * 0.1;
				float cos20 = cos( mulTime21 );
				float sin20 = sin( mulTime21 );
				float2 rotator20 = mul( panner19 - float2( 0.5,0.5 ) , float2x2( cos20 , -sin20 , sin20 , cos20 )) + float2( 0.5,0.5 );
				float2 uv0_Texture3 = IN.ase_texcoord7.xy * _Texture3_ST.xy + _Texture3_ST.zw;
				float2 panner18 = ( 1.0 * _Time.y * float2( 0,-0.0005 ) + uv0_Texture3);
				float cos26 = cos( -0.1 * _Time.y );
				float sin26 = sin( -0.1 * _Time.y );
				float2 rotator26 = mul( panner18 - float2( 0.5,0.5 ) , float2x2( cos26 , -sin26 , sin26 , cos26 )) + float2( 0.5,0.5 );
				float2 temp_cast_0 = (0.2).xx;
				float2 uv060 = IN.ase_texcoord7.xy * float2( 1,1 ) + temp_cast_0;
				float4 temp_output_14_0 = ( ( _1texstrenght * tex2D( _Texture1, panner23 ) ) + ( tex2D( _Texture2, rotator20 ) * _2texstrenght ) + ( tex2D( _Texture3, rotator26 ) * _3textstrenght ) + ( ( 1.0 - uv060.y ) * 0.1 ) );
				
				float4 screenPos = IN.ase_texcoord8;
				float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( screenPos );
				float4 ase_grabScreenPosNorm = ase_grabScreenPos / ase_grabScreenPos.w;
				float2 uv0_Texture4 = IN.ase_texcoord7.xy * _Texture4_ST.xy + _Texture4_ST.zw;
				float2 panner46 = ( 1.0 * _Time.y * float2( 0,0.001 ) + uv0_Texture4);
				float4 fetchOpaqueVal31 = float4( SHADERGRAPH_SAMPLE_SCENE_COLOR( ( ase_grabScreenPosNorm + float4( UnpackNormalScale( tex2D( _Texture4, panner46 ), _Normalstrenght ) , 0.0 ) ).xy ), 1.0 );
				
				float3 Albedo = ( _Color0 + ( ( 1.0 - temp_output_14_0 ) * _Color1 ) ).rgb;
				float3 Normal = float3(0, 0, 1);
				float3 Emission = fetchOpaqueVal31.rgb;
				float3 Specular = 0.5;
				float Metallic = 0;
				float Smoothness = _Smooth;
				float Occlusion = 1;
				float Alpha = ( ( temp_output_14_0 * _mainalphastrenght ) * float4( 0.3679245,0.3679245,0.3679245,0 ) ).r;
				float AlphaClipThreshold = 0.5;
				float3 BakedGI = 0;

				InputData inputData;
				inputData.positionWS = WorldSpacePosition;

				#ifdef _NORMALMAP
					inputData.normalWS = normalize(TransformTangentToWorld(Normal, half3x3(WorldSpaceTangent, WorldSpaceBiTangent, WorldSpaceNormal)));
				#else
					#if !SHADER_HINT_NICE_QUALITY
						inputData.normalWS = WorldSpaceNormal;
					#else
						inputData.normalWS = normalize(WorldSpaceNormal);
					#endif
				#endif

				inputData.viewDirectionWS = WorldSpaceViewDirection;
				inputData.shadowCoord = IN.shadowCoord;

				#ifdef ASE_FOG
					inputData.fogCoord = IN.fogFactorAndVertexLight.x;
				#endif

				inputData.vertexLighting = IN.fogFactorAndVertexLight.yzw;
				inputData.bakedGI = SAMPLE_GI( IN.lightmapUVOrVertexSH.xy, IN.lightmapUVOrVertexSH.xyz, inputData.normalWS );
				#ifdef _ASE_BAKEDGI
					inputData.bakedGI = BakedGI;
				#endif
				half4 color = UniversalFragmentPBR(
					inputData, 
					Albedo, 
					Metallic, 
					Specular, 
					Smoothness, 
					Occlusion, 
					Emission, 
					Alpha);

				#ifdef ASE_FOG
					#ifdef TERRAIN_SPLAT_ADDPASS
						color.rgb = MixFogColor(color.rgb, half3( 0, 0, 0 ), IN.fogFactorAndVertexLight.x );
					#else
						color.rgb = MixFog(color.rgb, IN.fogFactorAndVertexLight.x);
					#endif
				#endif
				
				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif
				
				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif

				return color;
			}

			ENDHLSL
		}

		
		Pass
		{
			
			Name "DepthOnly"
			Tags { "LightMode"="DepthOnly" }

			ZWrite On
			ColorMask 0

			HLSLPROGRAM
			#define _RECEIVE_SHADOWS_OFF 1
			#pragma multi_compile_instancing
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define _EMISSION
			#define ASE_SRP_VERSION 70108

			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x

			#pragma vertex vert
			#pragma fragment frag


			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			

			sampler2D _Texture1;
			sampler2D _Texture2;
			sampler2D _Texture3;
			CBUFFER_START( UnityPerMaterial )
			float4 _Color0;
			float _1texstrenght;
			float4 _Texture1_ST;
			float4 _Texture2_ST;
			float _2texstrenght;
			float4 _Texture3_ST;
			float _3textstrenght;
			float4 _Color1;
			float _Normalstrenght;
			float4 _Texture4_ST;
			float _Smooth;
			float _mainalphastrenght;
			CBUFFER_END


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			
			VertexOutput vert( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				o.ase_texcoord.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = defaultVertexValue;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;

				o.clipPos = TransformObjectToHClip(v.vertex.xyz);
				return o;
			}

			half4 frag(VertexOutput IN  ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				float2 uv0_Texture1 = IN.ase_texcoord.xy * _Texture1_ST.xy + _Texture1_ST.zw;
				float2 panner23 = ( 1.0 * _Time.y * float2( 0.2,0.1 ) + uv0_Texture1);
				float2 uv0_Texture2 = IN.ase_texcoord.xy * _Texture2_ST.xy + _Texture2_ST.zw;
				float2 panner19 = ( 1.0 * _Time.y * float2( 0.0001,0.0003 ) + uv0_Texture2);
				float mulTime21 = _TimeParameters.y * 0.1;
				float cos20 = cos( mulTime21 );
				float sin20 = sin( mulTime21 );
				float2 rotator20 = mul( panner19 - float2( 0.5,0.5 ) , float2x2( cos20 , -sin20 , sin20 , cos20 )) + float2( 0.5,0.5 );
				float2 uv0_Texture3 = IN.ase_texcoord.xy * _Texture3_ST.xy + _Texture3_ST.zw;
				float2 panner18 = ( 1.0 * _Time.y * float2( 0,-0.0005 ) + uv0_Texture3);
				float cos26 = cos( -0.1 * _Time.y );
				float sin26 = sin( -0.1 * _Time.y );
				float2 rotator26 = mul( panner18 - float2( 0.5,0.5 ) , float2x2( cos26 , -sin26 , sin26 , cos26 )) + float2( 0.5,0.5 );
				float2 temp_cast_0 = (0.2).xx;
				float2 uv060 = IN.ase_texcoord.xy * float2( 1,1 ) + temp_cast_0;
				float4 temp_output_14_0 = ( ( _1texstrenght * tex2D( _Texture1, panner23 ) ) + ( tex2D( _Texture2, rotator20 ) * _2texstrenght ) + ( tex2D( _Texture3, rotator26 ) * _3textstrenght ) + ( ( 1.0 - uv060.y ) * 0.1 ) );
				
				float Alpha = ( ( temp_output_14_0 * _mainalphastrenght ) * float4( 0.3679245,0.3679245,0.3679245,0 ) ).r;
				float AlphaClipThreshold = 0.5;

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif
				return 0;
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "Meta"
			Tags { "LightMode"="Meta" }

			Cull Off

			HLSLPROGRAM
			#define _RECEIVE_SHADOWS_OFF 1
			#pragma multi_compile_instancing
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define _EMISSION
			#define ASE_SRP_VERSION 70108
			#define REQUIRE_OPAQUE_TEXTURE 1

			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x

			#pragma vertex vert
			#pragma fragment frag


			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			

			sampler2D _Texture1;
			sampler2D _Texture2;
			sampler2D _Texture3;
			sampler2D _Texture4;
			CBUFFER_START( UnityPerMaterial )
			float4 _Color0;
			float _1texstrenght;
			float4 _Texture1_ST;
			float4 _Texture2_ST;
			float _2texstrenght;
			float4 _Texture3_ST;
			float _3textstrenght;
			float4 _Color1;
			float _Normalstrenght;
			float4 _Texture4_ST;
			float _Smooth;
			float _mainalphastrenght;
			CBUFFER_END


			#pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			inline float4 ASE_ComputeGrabScreenPos( float4 pos )
			{
				#if UNITY_UV_STARTS_AT_TOP
				float scale = -1.0;
				#else
				float scale = 1.0;
				#endif
				float4 o = pos;
				o.y = pos.w * 0.5f;
				o.y = ( pos.y - o.y ) * _ProjectionParams.x * scale + o.y;
				return o;
			}
			

			VertexOutput vert( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord1 = screenPos;
				
				o.ase_texcoord.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord.zw = 0;
				
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = defaultVertexValue;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;

				o.clipPos = MetaVertexPosition( v.vertex, v.texcoord1.xy, v.texcoord1.xy, unity_LightmapST, unity_DynamicLightmapST );
				return o;
			}

			half4 frag(VertexOutput IN  ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				float2 uv0_Texture1 = IN.ase_texcoord.xy * _Texture1_ST.xy + _Texture1_ST.zw;
				float2 panner23 = ( 1.0 * _Time.y * float2( 0.2,0.1 ) + uv0_Texture1);
				float2 uv0_Texture2 = IN.ase_texcoord.xy * _Texture2_ST.xy + _Texture2_ST.zw;
				float2 panner19 = ( 1.0 * _Time.y * float2( 0.0001,0.0003 ) + uv0_Texture2);
				float mulTime21 = _TimeParameters.y * 0.1;
				float cos20 = cos( mulTime21 );
				float sin20 = sin( mulTime21 );
				float2 rotator20 = mul( panner19 - float2( 0.5,0.5 ) , float2x2( cos20 , -sin20 , sin20 , cos20 )) + float2( 0.5,0.5 );
				float2 uv0_Texture3 = IN.ase_texcoord.xy * _Texture3_ST.xy + _Texture3_ST.zw;
				float2 panner18 = ( 1.0 * _Time.y * float2( 0,-0.0005 ) + uv0_Texture3);
				float cos26 = cos( -0.1 * _Time.y );
				float sin26 = sin( -0.1 * _Time.y );
				float2 rotator26 = mul( panner18 - float2( 0.5,0.5 ) , float2x2( cos26 , -sin26 , sin26 , cos26 )) + float2( 0.5,0.5 );
				float2 temp_cast_0 = (0.2).xx;
				float2 uv060 = IN.ase_texcoord.xy * float2( 1,1 ) + temp_cast_0;
				float4 temp_output_14_0 = ( ( _1texstrenght * tex2D( _Texture1, panner23 ) ) + ( tex2D( _Texture2, rotator20 ) * _2texstrenght ) + ( tex2D( _Texture3, rotator26 ) * _3textstrenght ) + ( ( 1.0 - uv060.y ) * 0.1 ) );
				
				float4 screenPos = IN.ase_texcoord1;
				float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( screenPos );
				float4 ase_grabScreenPosNorm = ase_grabScreenPos / ase_grabScreenPos.w;
				float2 uv0_Texture4 = IN.ase_texcoord.xy * _Texture4_ST.xy + _Texture4_ST.zw;
				float2 panner46 = ( 1.0 * _Time.y * float2( 0,0.001 ) + uv0_Texture4);
				float4 fetchOpaqueVal31 = float4( SHADERGRAPH_SAMPLE_SCENE_COLOR( ( ase_grabScreenPosNorm + float4( UnpackNormalScale( tex2D( _Texture4, panner46 ), _Normalstrenght ) , 0.0 ) ).xy ), 1.0 );
				
				
				float3 Albedo = ( _Color0 + ( ( 1.0 - temp_output_14_0 ) * _Color1 ) ).rgb;
				float3 Emission = fetchOpaqueVal31.rgb;
				float Alpha = ( ( temp_output_14_0 * _mainalphastrenght ) * float4( 0.3679245,0.3679245,0.3679245,0 ) ).r;
				float AlphaClipThreshold = 0.5;

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				MetaInput metaInput = (MetaInput)0;
				metaInput.Albedo = Albedo;
				metaInput.Emission = Emission;
				
				return MetaFragment(metaInput);
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "Universal2D"
			Tags { "LightMode"="Universal2D" }

			Blend SrcAlpha OneMinusSrcAlpha , One OneMinusSrcAlpha
			ZWrite Off
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA

			HLSLPROGRAM
			#define _RECEIVE_SHADOWS_OFF 1
			#pragma multi_compile_instancing
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define _EMISSION
			#define ASE_SRP_VERSION 70108

			#pragma enable_d3d11_debug_symbols
			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x

			#pragma vertex vert
			#pragma fragment frag


			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			
			

			sampler2D _Texture1;
			sampler2D _Texture2;
			sampler2D _Texture3;
			CBUFFER_START( UnityPerMaterial )
			float4 _Color0;
			float _1texstrenght;
			float4 _Texture1_ST;
			float4 _Texture2_ST;
			float _2texstrenght;
			float4 _Texture3_ST;
			float _3textstrenght;
			float4 _Color1;
			float _Normalstrenght;
			float4 _Texture4_ST;
			float _Smooth;
			float _mainalphastrenght;
			CBUFFER_END


			#pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float4 ase_texcoord : TEXCOORD0;
			};

			
			VertexOutput vert( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;

				o.ase_texcoord.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord.zw = 0;
				
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = defaultVertexValue;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;

				VertexPositionInputs vertexInput = GetVertexPositionInputs( v.vertex.xyz );
				o.clipPos = vertexInput.positionCS;
				return o;
			}

			half4 frag(VertexOutput IN  ) : SV_TARGET
			{
				float2 uv0_Texture1 = IN.ase_texcoord.xy * _Texture1_ST.xy + _Texture1_ST.zw;
				float2 panner23 = ( 1.0 * _Time.y * float2( 0.2,0.1 ) + uv0_Texture1);
				float2 uv0_Texture2 = IN.ase_texcoord.xy * _Texture2_ST.xy + _Texture2_ST.zw;
				float2 panner19 = ( 1.0 * _Time.y * float2( 0.0001,0.0003 ) + uv0_Texture2);
				float mulTime21 = _TimeParameters.y * 0.1;
				float cos20 = cos( mulTime21 );
				float sin20 = sin( mulTime21 );
				float2 rotator20 = mul( panner19 - float2( 0.5,0.5 ) , float2x2( cos20 , -sin20 , sin20 , cos20 )) + float2( 0.5,0.5 );
				float2 uv0_Texture3 = IN.ase_texcoord.xy * _Texture3_ST.xy + _Texture3_ST.zw;
				float2 panner18 = ( 1.0 * _Time.y * float2( 0,-0.0005 ) + uv0_Texture3);
				float cos26 = cos( -0.1 * _Time.y );
				float sin26 = sin( -0.1 * _Time.y );
				float2 rotator26 = mul( panner18 - float2( 0.5,0.5 ) , float2x2( cos26 , -sin26 , sin26 , cos26 )) + float2( 0.5,0.5 );
				float2 temp_cast_0 = (0.2).xx;
				float2 uv060 = IN.ase_texcoord.xy * float2( 1,1 ) + temp_cast_0;
				float4 temp_output_14_0 = ( ( _1texstrenght * tex2D( _Texture1, panner23 ) ) + ( tex2D( _Texture2, rotator20 ) * _2texstrenght ) + ( tex2D( _Texture3, rotator26 ) * _3textstrenght ) + ( ( 1.0 - uv060.y ) * 0.1 ) );
				
				
				float3 Albedo = ( _Color0 + ( ( 1.0 - temp_output_14_0 ) * _Color1 ) ).rgb;
				float Alpha = ( ( temp_output_14_0 * _mainalphastrenght ) * float4( 0.3679245,0.3679245,0.3679245,0 ) ).r;
				float AlphaClipThreshold = 0.5;

				half4 color = half4( Albedo, Alpha );

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				return color;
			}
			ENDHLSL
		}
		
	}
	CustomEditor "UnityEditor.ShaderGraph.PBRMasterGUI"
	Fallback "Hidden/InternalErrorShader"
	
}
/*ASEBEGIN
Version=17700
402;542;991;730;1552.941;-729.8062;1;True;False
Node;AmplifyShaderEditor.TexturePropertyNode;17;-2000.758,697.2179;Inherit;True;Property;_Texture3;Texture 3;5;0;Create;True;0;0;False;0;9fbef4b79ca3b784ba023cb1331520d5;9fbef4b79ca3b784ba023cb1331520d5;False;white;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.TexturePropertyNode;9;-2118.4,419.995;Inherit;True;Property;_Texture2;Texture 2;3;0;Create;True;0;0;False;0;e28dc97a9541e3642a48c0e3886688c5;e28dc97a9541e3642a48c0e3886688c5;False;white;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;16;-1726.413,786.2056;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;11;-1844.053,508.9826;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;7;-2189.356,129.9871;Inherit;True;Property;_Texture1;Texture 1;1;0;Create;True;0;0;False;0;61c0b9c0523734e0e91bc6043c72a490;61c0b9c0523734e0e91bc6043c72a490;False;white;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.PannerNode;18;-1531.941,816.4706;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,-0.0005;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;12;-1833.08,211.3296;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;67;-1213.939,1113.063;Inherit;False;Constant;_Float2;Float 2;13;0;Create;True;0;0;False;0;0.2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;19;-1606.026,506.6152;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0.0001,0.0003;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;21;-1601.105,655.2574;Inherit;False;1;0;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;23;-1496.68,240.9073;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0.2,0.1;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RotatorNode;26;-1363.601,815.6365;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;-0.1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RotatorNode;20;-1395.908,509.0392;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;0.01;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;60;-1060.866,1005.377;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;10;-1166.367,412.4501;Inherit;True;Property;_TextureSample1;Texture Sample 1;2;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;62;-992.3392,1194.063;Inherit;False;Constant;_Float0;Float 0;13;0;Create;True;0;0;False;0;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;54;-1025.693,902.3763;Inherit;False;Property;_3textstrenght;3 text strenght;6;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;69;-876.605,926.0275;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;8;-1173.356,168.4592;Inherit;True;Property;_TextureSample0;Texture Sample 0;2;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;56;-1029.095,614.8013;Inherit;False;Property;_2texstrenght;2 tex strenght;4;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;15;-1175.586,703.3847;Inherit;True;Property;_TextureSample2;Texture Sample 2;2;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;58;-1021.095,91.80125;Inherit;False;Property;_1texstrenght;1 tex strenght;2;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;61;-723.4572,886.7648;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;57;-829.0955,191.8013;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;27;-815.1633,653.8521;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0.6132076;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;55;-872.0955,510.8013;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;14;-649.5072,364.095;Inherit;True;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;50;-290.9172,933.8198;Inherit;False;Property;_Color1;Color 1;12;0;Create;True;0;0;False;0;0,0.8721261,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;49;-304.9172,650.8198;Inherit;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;25;-418.0869,493.8375;Inherit;False;Property;_mainalphastrenght;main alpha strenght;8;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;6;-174.6765,-289.2094;Inherit;False;Property;_Color0;Color 0;0;0;Create;True;0;0;False;0;0,0.63305,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;24;-257.8747,342.1364;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;51;31.08292,746.8198;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;30;-1099.319,-222.2604;Inherit;True;Property;_TextureSample3;Texture Sample 3;2;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.79;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;28;-1782.333,-222.8011;Inherit;True;Property;_Texture4;Texture 4;7;0;Create;True;0;0;False;0;24e31ecbf813d9e49bf7a1e0d4034916;dd2fd2df93418444c8e280f1d34deeb5;True;bump;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;59;102.6381,348.2823;Inherit;False;2;2;0;COLOR;1,1,1,0;False;1;COLOR;0.3679245,0.3679245,0.3679245,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GrabScreenPosition;32;-946.879,-467.1764;Inherit;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;46;-1300.914,-142.2353;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0.001;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;45;-1260.261,-28.0946;Inherit;False;Property;_Normalstrenght;Normal strenght;9;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;29;-1558.531,-141.4585;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenColorNode;31;-395.0511,-85.02953;Inherit;False;Global;_GrabScreen0;Grab Screen 0;6;0;Create;True;0;0;False;0;Object;-1;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;52;129.315,-56.55377;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;47;-245.9003,61.61002;Inherit;False;Property;_Metallic;Metallic;10;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;48;-241.9003,138.61;Inherit;False;Property;_Smooth;Smooth;11;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;33;-555.7742,-125.5092;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;41;117,-1;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;2;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;ShadowCaster;0;1;ShadowCaster;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;42;117,-1;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;2;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;DepthOnly;0;2;DepthOnly;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;False;False;True;False;False;False;False;0;False;-1;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;43;117,-1;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;2;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;Meta;0;3;Meta;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;False;True;2;False;-1;False;False;False;False;False;True;1;LightMode=Meta;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;44;117,-1;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;2;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;Universal2D;0;4;Universal2D;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;True;1;5;False;-1;10;False;-1;1;1;False;-1;10;False;-1;False;False;False;True;True;True;True;True;0;False;-1;False;True;2;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=Universal2D;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;40;379.4121,55.83317;Float;False;True;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;2;AcquarioShader;94348b07e5e8bab40bd6c8a1e3df54cd;True;Forward;0;0;Forward;12;False;False;False;True;2;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;2;0;True;1;5;False;-1;10;False;-1;1;1;False;-1;10;False;-1;False;False;False;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;2;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=UniversalForward;False;0;Hidden/InternalErrorShader;0;0;Standard;12;Workflow;1;Surface;1;  Blend;0;Two Sided;0;Cast Shadows;0;Receive Shadows;0;GPU Instancing;1;LOD CrossFade;1;Built-in Fog;1;Meta Pass;1;Override Baked GI;0;Vertex Position,InvertActionOnDeselection;1;0;5;True;False;True;True;True;False;;0
WireConnection;16;2;17;0
WireConnection;11;2;9;0
WireConnection;18;0;16;0
WireConnection;12;2;7;0
WireConnection;19;0;11;0
WireConnection;23;0;12;0
WireConnection;26;0;18;0
WireConnection;20;0;19;0
WireConnection;20;2;21;0
WireConnection;60;1;67;0
WireConnection;10;0;9;0
WireConnection;10;1;20;0
WireConnection;69;0;60;2
WireConnection;8;0;7;0
WireConnection;8;1;23;0
WireConnection;15;0;17;0
WireConnection;15;1;26;0
WireConnection;61;0;69;0
WireConnection;61;1;62;0
WireConnection;57;0;58;0
WireConnection;57;1;8;0
WireConnection;27;0;15;0
WireConnection;27;1;54;0
WireConnection;55;0;10;0
WireConnection;55;1;56;0
WireConnection;14;0;57;0
WireConnection;14;1;55;0
WireConnection;14;2;27;0
WireConnection;14;3;61;0
WireConnection;49;0;14;0
WireConnection;24;0;14;0
WireConnection;24;1;25;0
WireConnection;51;0;49;0
WireConnection;51;1;50;0
WireConnection;30;0;28;0
WireConnection;30;1;46;0
WireConnection;30;5;45;0
WireConnection;59;0;24;0
WireConnection;46;0;29;0
WireConnection;29;2;28;0
WireConnection;31;0;33;0
WireConnection;52;0;6;0
WireConnection;52;1;51;0
WireConnection;33;0;32;0
WireConnection;33;1;30;0
WireConnection;40;0;52;0
WireConnection;40;2;31;0
WireConnection;40;4;48;0
WireConnection;40;6;59;0
ASEEND*/
//CHKSM=EE3A1BE76346844B5A136736C633A1BD251BFAAA