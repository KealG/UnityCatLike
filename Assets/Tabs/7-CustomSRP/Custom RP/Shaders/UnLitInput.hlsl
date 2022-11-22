#ifndef CUSTOM_LIT_INPUT_INCLUDED
#define CUSTOM_LIT_INPUT_INCLUDED

TEXTURE2D(_BaseMap);
SAMPLER(sampler_BaseMap);

#define INPUT_PROP(name) UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, name)

UNITY_INSTANCING_BUFFER_START(UnityPerMaterial)
	UNITY_DEFINE_INSTANCED_PROP(float4, _BaseMap_ST)
	UNITY_DEFINE_INSTANCED_PROP(float4, _BaseColor)
	UNITY_DEFINE_INSTANCED_PROP(float, _Cutoff)	
	UNITY_DEFINE_INSTANCED_PROP(float, _ZWrite)
	UNITY_DEFINE_INSTANCED_PROP(float, _NearFadeDistance)
	UNITY_DEFINE_INSTANCED_PROP(float, _NearFadeRange)
UNITY_INSTANCING_BUFFER_END(UnityPerMaterial)

struct InputConfig {
	Fragment fragment;
	float4 color;
	float2 baseUV;
	float2 detailUV;
	bool useMask;
	bool useDetail;
	float3 flipbookUVB;
	bool flipbookBlending;
	bool nearFade;
};

InputConfig GetInputConfig (float4 positionSS, float2 baseUV, float2 detailUV = 0.0) {
	InputConfig c;
	c.color = 1.0;
	c.baseUV = baseUV;
	c.detailUV = detailUV;
	c.useMask = false;
	//额外的R：反射率 B：平滑度 信息贴图
	c.useDetail = false;
	
	c.flipbookUVB = 0.0;
	c.flipbookBlending = false;
	c.fragment = GetFragment(positionSS);
	c.nearFade = false;
	return c;
}

float2 TransformBaseUV (float2 baseUV) {
	float4 baseST = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _BaseMap_ST);
	return baseUV * baseST.xy + baseST.zw;
}

float4 GetBase (InputConfig c) {
	float4 map = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, c.baseUV);
	if (c.flipbookBlending) {
		map = lerp(
			map, SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, c.flipbookUVB.xy),
			c.flipbookUVB.z
		);
	}
	float4 color = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _BaseColor);
	if (c.nearFade) {
		float nearAttenuation = (c.fragment.depth - INPUT_PROP(_NearFadeDistance)) /
			INPUT_PROP(_NearFadeRange);
		map.a *= saturate(nearAttenuation);
	}
	return map * color * c.color;
}

float GetCutoff (InputConfig c) {
	return UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _Cutoff);
}

float GetMetallic (InputConfig c) {
	return 0.0;
}

float GetSmoothness (InputConfig c) {
	return 0.0;
}

float3 GetEmission (InputConfig c) {
	return GetBase(c).rgb;
}

float GetFresnel (InputConfig c) {
	return 0.0;
}

float GetFinalAlpha (float alpha) {
	return INPUT_PROP(_ZWrite) ? 1.0 : alpha;
}

#endif