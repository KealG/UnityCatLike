Shader "Custom/SimpleGuideFog"
{
    Properties
    {        
        _MainTex ("MainTexture", 2D) = "white" {}
        _Mask1("MaskTexture1", 2D) = "white" {}   
        _Mask2("MaskTexture2", 2D) = "white" {}           
        _FogColor("_FogColor", Color) = (0.26344, 0.28478, 0.30189, 0.46667)
        _TintColor("_TintColor", Color) = (0.16825, 0.1765, 0.17925, 0.75294)
        _TintColor2("_TintColor2", Color) = (0.06942, 0.07144, 0.07547, 0.69804)
        _Intensity("_Intensity", Vector) = (0.6, 0.6, 0.9, 0.9)
        _MoveDir("MoveDir", Vector) = (0.0267, 0.0234, 0.0437, 0.0467)
        _MoveDir2("MoveDir", Vector) = (0.0363, 0.0337, 0.0234, 0.0363)
        _Speed("Speed", Vector) = (0.73, 0.67, 0.47, 0.53)
        _Tile("Tile", Vector) = (8, 7, 16.13, 15.37)
        _Progress("Progress", Range(0, 1)) = 0
        _Step("_Step", Int) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue" = "Transparent"}
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 uv : TEXCOORD0;
                float4 tex1 : TEXCOORD1;
                float4 tex2 : TEXCOORD2;
                
            };

            sampler2D _MainTex;
            sampler2D _Mask1;
            sampler2D _Mask2;

            float4 _MoveDir;
            float4 _MoveDir2;
            float4 _Speed;
            float4 _FogColor;
            float4 _TintColor;
            float4 _TintColor2;
            half4 _Intensity;
            half4 _Tile;
            float _Progress;
            float _Step;

            uniform float3 scale = (0.333, 0.333, 0.333);
            uniform float3 globalFogColor = (0.38824, 0.6549, 0.83137);

            v2f vert (appdata v)
            {
                v2f o;

                float4 dir1 = frac(_Time.y * _MoveDir * _Speed.xxyy);
                float3 worldPos = mul(unity_ObjectToWorld, v.vertex);
                float4 tex1 = dir1 + worldPos.xzxz / _Tile.xxyy;

                float4 dir2 = frac(_Time.y * _MoveDir2 * _Speed.zzww);
                float4 tex2 = dir2 + worldPos.xzxz / _Tile.zzww;

                o.tex1 = tex1;
                o.tex2 = tex2;
                o.vertex = UnityWorldToClipPos(worldPos);   
                o.uv.xy = v.uv;
                o.uv.z = (o.vertex.y / o.vertex.w) * 0.5 + 0.5;
                o.uv.w = clamp(o.vertex.z * unity_FogParams.z + unity_FogParams.w,0,1);
                return o;
            }

            half4 frag (v2f i) : SV_Target
            { 
                half4 texCol1 = tex2D(_MainTex, i.tex1.xy);
                half4 texCol2 = tex2D(_MainTex, i.tex1.zw);
                half4 texCol3 = tex2D(_MainTex, i.tex2.xy);
                half4 texCol4 = tex2D(_MainTex, i.tex2.zw);

                half4 texCombineCol1 = (texCol1 + texCol2) * 0.5;
                half4 texCombineCol2 = (texCol3 + texCol4) * 0.5;

                float param1 = dot(texCombineCol1.xyz, scale) + _Intensity.x;
                float param2 = dot(texCombineCol2.xyz, scale) + _Intensity.z;

                float2 param = float2(param1, param2) * _Intensity.yw;

                half4 col1 = half4(texCombineCol1.xyz * _TintColor.xyz, texCombineCol1.w);
                half4 col2 = half4(texCombineCol2.xyz * _TintColor2.xyz, texCombineCol2.w);

                float paramX = param.x * _TintColor.w;
                float paramY = param.y * _TintColor2.w;

                half4 col = (1 - paramX) * paramY * col2 + paramX * col1;
                half4 mask = tex2D(_Mask1, i.uv.xy);
                half4 mask2 = tex2D(_Mask2, i.uv.xy);

                half4 condition = half4(step(1, _Step) * step(_Step, 1.9), step(2, _Step) * step(_Step, 2.9) , step(3, _Step) * step(_Step, 3.9), step(4, _Step) * step(_Step, 4.9));
                half4 maskVal = half4(mask.r, _Progress * (mask.g - mask.r) + mask.r, _Progress * (mask.b - mask.g) + mask.g, _Progress * (mask2.r - mask.b) + mask.b);
                
                half alpha = dot(condition, maskVal);

                half allFlag = step(5, _Step); 
                alpha = (1 - allFlag) * alpha + allFlag * (_Progress * (mask2.g - mask2.r) + mask2.r);
                col.a *= alpha;

                col.rgb += i.uv.z * i.uv.z * _FogColor.w * _FogColor.xyz;
                // col.rgb = clamp(i.uv.w,0,1) * (col.rgb -  globalFogColor) + globalFogColor;
                return col;
            }
            ENDCG
        }
    }
}
