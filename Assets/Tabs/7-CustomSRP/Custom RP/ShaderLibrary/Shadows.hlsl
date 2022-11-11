#ifndef CUSTOM_SHADOWS_INCLUDED
#define CUSTOM_SHADOWS_INCLUDED

#define MAX_SHADOWED_DIRECTIONAL_LIGHT_COUNT 4
#define MAX_CASCADE_COUNT 4

TEXTURE2D_SHADOW(_DirectionalShadowAtlas);
#define SHADOW_SAMPLER sampler_linear_clamp_compare
SAMPLER_CMP(SHADOW_SAMPLER);

CBUFFER_START(_CustomShadows)
    int _CascadeCount;
	float4 _CascadeCullingSpheres[MAX_CASCADE_COUNT];
	float4x4 _DirectionalShadowMatrices[MAX_SHADOWED_DIRECTIONAL_LIGHT_COUNT * MAX_CASCADE_COUNT];
    //阴影采样的最大距离InViewSpace
    float4 _ShadowDistanceFade;
    float4 _CascadeData[MAX_CASCADE_COUNT];
CBUFFER_END

struct DirectionalShadowData {
	float strength;
	int tileIndex;
};

float SampleDirectionalShadowAtlas (float3 positionSTS) {
	return SAMPLE_TEXTURE2D_SHADOW(
		_DirectionalShadowAtlas, SHADOW_SAMPLER, positionSTS
	);
}

//返回阴影衰减函数
float GetDirectionalShadowAttenuation (DirectionalShadowData data, Surface surfaceWS) {
    if (data.strength <= 0.0) {
		return 1.0;
	}
	float3 positionSTS = mul(
		_DirectionalShadowMatrices[data.tileIndex],
		float4(surfaceWS.position, 1.0)
	).xyz;
	float shadow = SampleDirectionalShadowAtlas(positionSTS);
	return  lerp(1.0, shadow, data.strength);
}

struct ShadowData {
	int cascadeIndex;
    float strength;
};

float FadedShadowStrength (float distance, float scale, float fade) {
	return saturate((1.0 - distance * scale) * fade);
}


ShadowData GetShadowData (Surface surfaceWS) {
	ShadowData data;
    //对超出边界的阴影进行平滑处理
    data.strength =  FadedShadowStrength(
		surfaceWS.depth, _CascadeData[i].x, _ShadowDistanceFade.y
	);
    int i;
	for (i = 0; i < _CascadeCount; i++) {
		float4 sphere = _CascadeCullingSpheres[i];
        //片段像素点对应的世界坐标与不同级联剔除球体中心的几何距离
		float distanceSqr = DistanceSquared(surfaceWS.position, sphere.xyz);
		if (distanceSqr < sphere.w) 
        {
            //对最大边界的级联采样进行平滑处理
            if (i == _CascadeCount - 1) {
				data.strength *= FadedShadowStrength(
					distanceSqr, 1.0 / sphere.w, _ShadowDistanceFade.z
				);
			}
			break;
		}
	}

    if (i == _CascadeCount) {
		data.strength = 0.0;
	}

	data.cascadeIndex = i;
	return data;
}

#endif