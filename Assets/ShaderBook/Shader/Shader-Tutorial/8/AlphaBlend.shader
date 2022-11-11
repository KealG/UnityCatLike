Shader "Unity Shaders Book/8/AlphaBlend"
{
    Properties
    {
        _AlphaScale("Alpha Scale", Range(0,1)) = 1
        _Color("Main Tint", Color) = (1,1,1,1)
        _MainTex("Main Tex", 2D) = "white"{}        
    }

    SubShader
    {
        Tags
        {
            "Queue" = "Transparent"
            "IgnoreProjector" = "True"
            "RenderType" = "Transparent"            
        }

        pass
        {
            Tags 
            {
                "LightMode" = "ForwardBase"                
            }
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc"

            fixed4 _Color;
            fixed _AlphaScale;
            sampler2D _MainTex;
            float4 _MainTex_ST;

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldNormal: TEXCOORD0;
                float3 worldPos: TEXCOORD1;
                float2 uv: TEXCOORD2;
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = UnityObjectToWorldDir(v.vertex).xyz;
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o; 
            }

            fixed4 frag(v2f i) : SV_TARGET
            {
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

                fixed4 texColor = tex2D(_MainTex, i.uv);
                
                //alpha Test
                // clip(texColor.a - _CutOff);
                
                //Equal to
                // if((texColor.a - _CutOff < 0.0))
                // {
                //     discard;
                // }

                fixed3 albedo = texColor.rgb * _Color.rgb;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo;
                fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(worldNormal, worldLightDir));
                
                return fixed4(ambient + diffuse, saturate(texColor.a * _AlphaScale));
            }
            ENDCG
        }
    }

    Fallback "Transparent/VertexLit"
}