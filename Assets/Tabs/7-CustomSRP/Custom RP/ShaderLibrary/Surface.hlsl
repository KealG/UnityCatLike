#ifndef CUSTOM_SURFACE_INCLUDED
#define CUSTOM_SURFACE_INCLUDED

struct Surface {
	float3 normal;
	float3 interpolatedNormal;
	float3 viewDirection;
	float3 color;
	float alpha;
	float metallic;
	float smoothness;
	//WorldPosition
	float3 position;
	//ViewSpace depth
	float depth;
	float fresnelStrength;
	float dither;
	float occlusion;
};

#endif