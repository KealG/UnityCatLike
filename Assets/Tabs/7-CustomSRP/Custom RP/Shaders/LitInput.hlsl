#ifndef CUSTOM_LIT_INPUT_INCLUDED
#define CUSTOM_LIT_INPUT_INCLUDED

TEXTURE2D(_BaseMap);
TEXTURE2D(_EmissionMap);
TEXTURE2D(_MaskMap);
TEXTURE2D(_DetailMap);
SAMPLER(sampler_DetailMap);

SAMPLER(sampler_BaseMap);

#define INPUT_PROP(name) UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, name)

UNITY_INSTANCING_BUFFER_START(UnityPerMaterial)
	UNITY_DEFINE_INSTANCED_PROP(float4, _BaseMap_ST)
	UNITY_DEFINE_INSTANCED_PROP(float4, _BaseColor)
	UNITY_DEFINE_INSTANCED_PROP(float4, _EmissionColor)
	UNITY_DEFINE_INSTANCED_PROP(float, _Cutoff)
	UNITY_DEFINE_INSTANCED_PROP(float, _Metallic)
	UNITY_DEFINE_INSTANCED_PROP(float, _Occlusion)
	UNITY_DEFINE_INSTANCED_PROP(float, _Smoothness)
	UNITY_DEFINE_INSTANCED_PROP(float, _Fresnel)
	UNITY_DEFINE_INSTANCED_PROP(float4, _DetailMap_ST)
UNITY_INSTANCING_BUFFER_END(UnityPerMaterial)

float4 GetMask (float2 baseUV) {
	return SAMPLE_TEXTURE2D(_MaskMap, sampler_BaseMap, baseUV);
}

float2 TransformBaseUV (float2 baseUV) {
	float4 baseST = INPUT_PROP(_BaseMap_ST);
	return baseUV * baseST.xy + baseST.zw;
}

float2 TransformDetailUV (float2 detailUV) {
	float4 detailST = INPUT_PROP(_DetailMap_ST);
	return detailUV * detailST.xy + detailST.zw;
}

float4 GetDetail (float2 detailUV) {
	float4 map = SAMPLE_TEXTURE2D(_DetailMap, sampler_DetailMap, detailUV);
	return map;
}

float4 GetBase (float2 baseUV, float2 detailUV = 0.0) {
	float4 map = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, baseUV);
	float4 color = INPUT_PROP(_BaseMap_ST);

	float4 detail = GetDetail(detailUV);
	map += detail;
	return map * color;
}

float GetCutoff (float2 baseUV) {
	return INPUT_PROP(_Cutoff);
}

float GetMetallic (float2 baseUV) {
	float metallic = INPUT_PROP(_Metallic);
	metallic *= GetMask(baseUV).r;
	return metallic;
}

float GetSmoothness (float2 baseUV) {
	float smoothness = INPUT_PROP(_Smoothness);
	smoothness *= GetMask(baseUV).a;
	return smoothness;
}

float3 GetEmission (float2 baseUV) {
	float4 map = SAMPLE_TEXTURE2D(_EmissionMap, sampler_BaseMap, baseUV);
	float4 color = INPUT_PROP(_EmissionColor);
	return map.rgb * color.rgb;
}

float GetFresnel (float2 baseUV) {
	return INPUT_PROP(_Fresnel);
}

float GetOcclusion (float2 baseUV) {
	float strength = INPUT_PROP(_Occlusion);
	float occlusion = GetMask(baseUV).g;
	occlusion = lerp(occlusion, 1.0, strength);
	return occlusion;
}

#endif