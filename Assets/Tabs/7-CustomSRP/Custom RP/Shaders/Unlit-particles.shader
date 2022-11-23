﻿Shader "Custom RP/Particles/Unlit" {
	
	Properties {
		[HDR]_BaseMap("Texture", 2D) = "white" {}

		//particles
		[Toggle(_VERTEX_COLORS)] _VertexColors ("Vertex Colors", Float) = 0
		[Toggle(_FLIPBOOK_BLENDING)] _FlipbookBlending ("Flipbook Blending", Float) = 0

		_BaseColor("Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_Cutoff ("Alpha Cutoff", Range(0.0, 1.0)) = 0.5
		[Toggle(_CLIPPING)] _Clipping ("Alpha Clipping", Float) = 0

		[Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend ("Src Blend", Float) = 1
		[Enum(UnityEngine.Rendering.BlendMode)] _DstBlend ("Dst Blend", Float) = 0
		[Enum(Off, 0, On, 1)] _ZWrite ("Z Write", Float) = 1
		[Toggle(_RECEIVE_SHADOWS)] _ReceiveShadows ("Receive Shadows", Float) = 1

		[Toggle(_NEAR_FADE)] _NearFade ("Near Fade", Float) = 0
		_NearFadeDistance ("Near Fade Distance", Range(0.0, 10.0)) = 1
		_NearFadeRange ("Near Fade Range", Range(0.01, 10.0)) = 1

		[Toggle(_SOFT_PARTICLES)] _SoftParticles ("Soft Particles", Float) = 0
		_SoftParticlesDistance ("Soft Particles Distance", Range(0.0, 10.0)) = 0
		_SoftParticlesRange ("Soft Particles Range", Range(0.01, 10.0)) = 1

		[Toggle(_DISTORTION)] _Distortion ("Distortion", Float) = 0
		[NoScaleOffset] _DistortionMap("Distortion Vectors", 2D) = "bumb" {}
		_DistortionStrength("Distortion Strength", Range(0.0, 0.2)) = 0.1

		_DistortionBlend("Distortion Blend", Range(0.0, 1.0)) = 1
	}
	
	SubShader {
		HLSLINCLUDE
		#include "../ShaderLibrary/Common.hlsl"
		#include "UnlitInput.hlsl"
		ENDHLSL
		
		Pass {
			Blend [_SrcBlend] [_DstBlend]
			ZWrite [_ZWrite]

			HLSLPROGRAM
			#pragma target 3.5
			#pragma shader_feature _CLIPPING
			#pragma shader_feature _VERTEX_COLORS
			#pragma shader_feature _FLIPBOOK_BLENDING
			#pragma shader_feature _NEAR_FADE
			#pragma shader_feature _SOFT_PARTICLES
			#pragma shader_feature _DISTORTION
			
			#pragma multi_compile_instancing
			#pragma vertex UnlitPassVertex
			#pragma fragment UnlitPassFragment
			#include "UnlitPass.hlsl"
			ENDHLSL
		}

		Pass {
			Tags {
				"LightMode" = "ShadowCaster"
			}

			ColorMask 0

			HLSLPROGRAM
			#pragma target 3.5
			// #pragma shader_feature _CLIPPING
			#pragma shader_feature _ _SHADOWS_CLIP _SHADOWS_DITHER
			#pragma multi_compile_instancing
			#pragma vertex ShadowCasterPassVertex
			#pragma fragment ShadowCasterPassFragment
			#include "ShadowCasterPass.hlsl"
			ENDHLSL
		}		

		// Pass {
		// 	//Meta 
		// 	Tags {
		// 		"LightMode" = "Meta"
		// 	}

		// 	Cull Off

		// 	HLSLPROGRAM
		// 	#pragma target 3.5
		// 	#pragma vertex MetaPassVertex
		// 	#pragma fragment MetaPassFragment
		// 	#include "MetaPass.hlsl"
		// 	ENDHLSL
		// }
	}

	CustomEditor "CustomShaderGUICatLike"
}