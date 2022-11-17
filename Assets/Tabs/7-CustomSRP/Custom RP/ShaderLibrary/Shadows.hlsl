#ifndef CUSTOM_SHADOWS_INCLUDED
#define CUSTOM_SHADOWS_INCLUDED

#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Shadow/ShadowSamplingTent.hlsl"

#if defined(_DIRECTIONAL_PCF3)
	#define DIRECTIONAL_FILTER_SAMPLES 4
	#define DIRECTIONAL_FILTER_SETUP SampleShadow_ComputeSamples_Tent_3x3
#elif defined(_DIRECTIONAL_PCF5)
	#define DIRECTIONAL_FILTER_SAMPLES 9
	#define DIRECTIONAL_FILTER_SETUP SampleShadow_ComputeSamples_Tent_5x5
#elif defined(_DIRECTIONAL_PCF7)
	#define DIRECTIONAL_FILTER_SAMPLES 16
	#define DIRECTIONAL_FILTER_SETUP SampleShadow_ComputeSamples_Tent_7x7
#endif

#define MAX_SHADOWED_DIRECTIONAL_LIGHT_COUNT 4
#define MAX_CASCADE_COUNT 4

TEXTURE2D_SHADOW(_DirectionalShadowAtlas);
#define SHADOW_SAMPLER sampler_linear_clamp_compare
SAMPLER_CMP(SHADOW_SAMPLER);

CBUFFER_START(_CustomShadows)
    int _CascadeCount;
	float4 _CascadeCullingSpheres[MAX_CASCADE_COUNT];
	float4x4 _DirectionalShadowMatrices[MAX_SHADOWED_DIRECTIONAL_LIGHT_COUNT * MAX_CASCADE_COUNT];
    float4 _ShadowAtlasSize;
    //阴影采样的最大距离InViewSpace
    float4 _ShadowDistanceFade;
    float4 _CascadeData[MAX_CASCADE_COUNT];
CBUFFER_END

struct DirectionalShadowData {
	float strength;
	int tileIndex;
    float normalBias;
	int shadowMaskChannel;
};

struct OtherShadowData {
	float strength;
	int shadowMaskChannel;
};

float SampleDirectionalShadowAtlas (float3 positionSTS) {
	return SAMPLE_TEXTURE2D_SHADOW(
		_DirectionalShadowAtlas, SHADOW_SAMPLER, positionSTS
	);
}

struct ShadowMask {
	bool always;
	bool distance;
	float4 shadows;
};

struct ShadowData {
	int cascadeIndex;
    float strength;
    //用于级联之间的混合值
    float cascadeBlend;
	//Apply Shadow mask
	ShadowMask shadowMask;
};

float FilterDirectionalShadow (float3 positionSTS) {
	#if defined(DIRECTIONAL_FILTER_SETUP)
		float weights[DIRECTIONAL_FILTER_SAMPLES];
		float2 positions[DIRECTIONAL_FILTER_SAMPLES];
		float4 size = _ShadowAtlasSize.yyxx;
		DIRECTIONAL_FILTER_SETUP(size, positionSTS.xy, weights, positions);
		float shadow = 0;
		for (int i = 0; i < DIRECTIONAL_FILTER_SAMPLES; i++) {
			shadow += weights[i] * SampleDirectionalShadowAtlas(
				float3(positions[i].xy, positionSTS.z)
			);
		}
		return shadow;
	#else
		return SampleDirectionalShadowAtlas(positionSTS);
	#endif
}

float GetCascadedShadow (
	DirectionalShadowData directional, ShadowData global, Surface surfaceWS
) {
	float3 normalBias = surfaceWS.interpolatedNormal *
		(directional.normalBias * _CascadeData[global.cascadeIndex].y);
	float3 positionSTS = mul(
		_DirectionalShadowMatrices[directional.tileIndex],
		float4(surfaceWS.position + normalBias, 1.0)
	).xyz;
	float shadow = FilterDirectionalShadow(positionSTS);
	if (global.cascadeBlend < 1.0) {
		normalBias = surfaceWS.interpolatedNormal *
			(directional.normalBias * _CascadeData[global.cascadeIndex + 1].y);
		positionSTS = mul(
			_DirectionalShadowMatrices[directional.tileIndex + 1],
			float4(surfaceWS.position + normalBias, 1.0)
		).xyz;
		shadow = lerp(
			FilterDirectionalShadow(positionSTS), shadow, global.cascadeBlend
		);
	}
	return shadow;
}

//获取烘培ShadowMap+LP遮挡+LPPV遮挡数据
float GetBakedShadow (ShadowMask mask, int channel) {
	float shadow = 1.0;
	if (mask.distance || mask.always) {
		if (channel >= 0) {
			//由默认取R通道改为取C#传递过来的信号通道
			shadow = mask.shadows[channel];
		}		
	}
	return shadow;
}

float GetBakedShadow (ShadowMask mask, int channel, float strength) {
	if (mask.distance || mask.always) 
	{
		return lerp(1.0, GetBakedShadow(mask, channel), strength);
	}
	return 1.0;
}

float MixBakedAndRealtimeShadows (
	ShadowData global, float realTimeShadow, int shadowMaskChannel, float strength
) {
	float resultShadow;
	float baked = GetBakedShadow(global.shadowMask, shadowMaskChannel);
	if (global.shadowMask.always) {
		realTimeShadow = lerp(1.0, realTimeShadow, global.strength);
		resultShadow = min(baked, realTimeShadow);
		return lerp(1.0, resultShadow, strength);
	}
	if (global.shadowMask.distance) 
	{		
		resultShadow = lerp(baked, realTimeShadow, global.strength);
		return lerp(1.0, resultShadow, strength);
	}	
	else
	{
		resultShadow = realTimeShadow;
		return lerp(1.0, resultShadow, strength * global.strength);
	}	
}

//返回阴影衰减函数
float GetDirectionalShadowAttenuation (DirectionalShadowData directional, ShadowData global, Surface surfaceWS) {
#if !defined(_RECEIVE_SHADOWS)
	return 1.0;
#endif    
    float shadow;
	if (directional.strength * global.strength <= 0.0) {
		shadow = GetBakedShadow(global.shadowMask, directional.shadowMaskChannel, abs(directional.strength));
	}
	else {
		shadow = GetCascadedShadow(directional, global, surfaceWS);
		shadow = MixBakedAndRealtimeShadows(global, shadow, directional.shadowMaskChannel, directional.strength);
	}
	return  shadow;
}

float GetOtherShadowAttenuation (OtherShadowData other, ShadowData global, Surface surfaceWS) {
	#if !defined(_RECEIVE_SHADOWS)
		return 1.0;
	#endif
	
	float shadow;
	if (other.strength > 0.0) {
		shadow = GetBakedShadow(
			global.shadowMask, other.shadowMaskChannel, other.strength
		);
	}
	else {
		shadow = 1.0;
	}
	return shadow;
}


float FadedShadowStrength (float distance, float scale, float fade) {
	return saturate((1.0 - distance * scale) * fade);
}


ShadowData GetShadowData (Surface surfaceWS) {
	ShadowData data;
	data.shadowMask.distance = false;
	data.shadowMask.shadows = 1.0;
	data.shadowMask.always = false;
    data.cascadeBlend = 1.0;	
    //对超出边界的阴影进行平滑处理
    data.strength =  FadedShadowStrength(
		surfaceWS.depth, _ShadowDistanceFade.x, _ShadowDistanceFade.y
	);
    int i;
	for (i = 0; i < _CascadeCount; i++) {
		float4 sphere = _CascadeCullingSpheres[i];
        //片段像素点对应的世界坐标与不同级联剔除球体中心的几何距离
		float distanceSqr = DistanceSquared(surfaceWS.position, sphere.xyz);
		if (distanceSqr < sphere.w) 
        {
            float fade = FadedShadowStrength(
				distanceSqr, _CascadeData[i].x, _ShadowDistanceFade.z
			);
            //对最大边界的级联采样进行平滑处理
            if (i == _CascadeCount - 1) {
				data.strength *= fade;
			}
            //对非最大边界的级联采样进行混合处理
            else {
				data.cascadeBlend = fade;
			}
			break;
		}
	}

    if (i == _CascadeCount) {
		data.strength = 0.0;
	}
#if defined(_CASCADE_BLEND_DITHER)
    //当使用抖动混合时，如果我们不在最后一个级联中，如果混合值小于抖动值，则跳转到下一个级联
    else if (data.cascadeBlend < surfaceWS.dither) {
        i += 1;
    }
#endif

#if !defined(_CASCADE_BLEND_SOFT)
    //当未使用PCF软阴影时，将混合值设置为默认值
	data.cascadeBlend = 1.0;
#endif

	data.cascadeIndex = i;
	return data;
}

#endif