Shader "Unity Shaders Book/13/EdgeDetectedWithDepthNormalByObjMesh"
{
    Properties
    {
        _MainTex ("Base (RGB)", 2D) = "white" {}
		_EdgeOnly ("Edge Only", Float) = 1.0
		_EdgeColor ("Edge Color", Color) = (0, 0, 0, 1)
		_BackgroundColor ("Background Color", Color) = (1, 1, 1, 1)
		_SampleDistance ("Sample Distance", Float) = 1.0
		_Sensitivity ("Sensitivity", Vector) = (1, 1, 1, 1)
    }
    SubShader
    {
        CGINCLUDE
		
		#include "UnityCG.cginc"
		
		sampler2D _CameraDepthNormalsTexture;
		
		sampler2D _MainTex;
		half4 _MainTex_TexelSize;
		fixed _EdgeOnly;
		fixed4 _EdgeColor;
		fixed4 _BackgroundColor;
		float _SampleDistance;
		half4 _Sensitivity;
		
		struct a2v
		{
			float4 vertex : POSITION;
			float2 texcoord : TEXCOORD0;
		};

		struct v2f {
			float4 pos : SV_POSITION;
			half2 uv[5]: TEXCOORD0;
		};
		  
		v2f vert(a2v v) {
			//当传入的是后处理中的单个模型的mesh顶点时，uv乱了，模型的01uv采样不了全局的ScreenTex，所以不能针对整张屏幕的Tex采样局部的模型
			v2f o;
			o.pos = UnityObjectToClipPos(v.vertex);
			
			half2 uv = v.texcoord;
			o.uv[0] = uv;
			
			#if UNITY_UV_STARTS_AT_TOP
			if (_MainTex_TexelSize.y < 0)
				uv.y = 1 - uv.y;
			#endif
			
			o.uv[1] = uv + _MainTex_TexelSize.xy * half2(1,1) * _SampleDistance;
			o.uv[2] = uv + _MainTex_TexelSize.xy * half2(-1,-1) * _SampleDistance;
			o.uv[3] = uv + _MainTex_TexelSize.xy * half2(-1,1) * _SampleDistance;
			o.uv[4] = uv + _MainTex_TexelSize.xy * half2(1,-1) * _SampleDistance;
					 
			return o;
		}
		
		half CheckSame(half4 center, half4 sample) {
			half2 centerNormal = center.xy;
			float centerDepth = DecodeFloatRG(center.zw);
			half2 sampleNormal = sample.xy;
			float sampleDepth = DecodeFloatRG(sample.zw);
			
			// difference in normals
			// do not bother decoding normals - there's no need here
			//? 如何不解码xy值得到真实法线方向值，那么该值是否能通过相减确定其“变化程度”？
			half2 diffNormal = abs(centerNormal - sampleNormal) * _Sensitivity.x;
			int isSameNormal = (diffNormal.x + diffNormal.y) < 0.1;
			// difference in depth
			float diffDepth = abs(centerDepth - sampleDepth) * _Sensitivity.y;
			// scale the required threshold by the distance
			int isSameDepth = diffDepth < 0.1 * centerDepth;
			
			// return:
			// 1 - if normals and depth are similar enough
			// 0 - otherwise
			return isSameNormal * isSameDepth ? 1.0 : 0.0;
		}
		
		fixed4 fragRobertsCrossDepthAndNormal(v2f i) : SV_Target {
			half4 sample1 = tex2D(_CameraDepthNormalsTexture, i.uv[1]);
			half4 sample2 = tex2D(_CameraDepthNormalsTexture, i.uv[2]);
			half4 sample3 = tex2D(_CameraDepthNormalsTexture, i.uv[3]);
			half4 sample4 = tex2D(_CameraDepthNormalsTexture, i.uv[4]);
			
			half edge = 1.0;
			
			edge *= CheckSame(sample1, sample2);
			edge *= CheckSame(sample3, sample4);
			
			//如果差异过大则返回边线值，否则返回当前RT值
			fixed4 withEdgeColor = lerp(_EdgeColor, tex2D(_MainTex, i.uv[0]), edge);
			//如果差异过大则返回边线值，否则返回背景值
			fixed4 onlyEdgeColor = lerp(_EdgeColor, _BackgroundColor, edge);
			
			//如果只显示边界值为1则返回onlyEdgeColor，否则withEdgeColor
			return lerp(withEdgeColor, onlyEdgeColor, _EdgeOnly);			
			// return fixed4(1,1,1,1);
		}
		
		ENDCG
        
		Pass {

			ZTest Always Cull Off ZWrite Off
			     	
			CGPROGRAM  
			
			#pragma vertex vert  
			#pragma fragment fragRobertsCrossDepthAndNormal  
			  
			ENDCG  
		}    
    }

    Fallback Off
}
