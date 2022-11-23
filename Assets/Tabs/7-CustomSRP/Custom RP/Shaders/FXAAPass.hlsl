#ifndef CUSTOM_FXAA_PASS_INCLUDED
#define CUSTOM_FXAA_PASS_INCLUDED

float4 _FXAAConfig;

struct LumaNeighborhood {
	float m, n, e, s, w;
	float highest, lowest, range;
};

float GetLuma (float2 uv, float uOffset = 0.0, float vOffset = 0.0) {
	// return sqrt(Luminance(GetSource(uv)));
	//直接采样返回绿色通道的值，因为人眼对绿色最为敏感，这是一种性能优化的手段	
	uv += float2(uOffset, vOffset) * GetSourceTexelSize().xy;
	#if defined(FXAA_ALPHA_CONTAINS_LUMA)
		return GetSource(uv).a;
	#else
		return GetSource(uv).g;
	#endif
}

LumaNeighborhood GetLumaNeighborhood (float2 uv) {
	LumaNeighborhood luma;
	luma.m = GetLuma(uv);
	luma.n = GetLuma(uv, 0.0, 1.0);
	luma.e = GetLuma(uv, 1.0, 0.0);
	luma.s = GetLuma(uv, 0.0, -1.0);
	luma.w = GetLuma(uv, -1.0, 0.0);
	luma.highest = max(max(max(max(luma.m, luma.n), luma.e), luma.s), luma.w);
	luma.lowest = min(min(min(min(luma.m, luma.n), luma.e), luma.s), luma.w);
	luma.range = luma.highest - luma.lowest;
	return luma;
}

bool CanSkipFXAA (LumaNeighborhood luma) {
	return luma.range < _FXAAConfig.x;
}


float4 FXAAPassFragment (Varyings input) : SV_TARGET {
	LumaNeighborhood luma = GetLumaNeighborhood(input.screenUV);
	if (CanSkipFXAA(luma)) {
		return 0.0;
	}	
	return luma.m;
}

#endif