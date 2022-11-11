Shader "Unity Shaders Book/13/ShowDepthNormalTex"
{
    Properties
    {
        
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }        

        //该Pass展示深度纹理
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
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

           sampler2D _CameraDepthTexture;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;                
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv);
                float linerDepth = Linear01Depth(depth);                
                fixed4 col = float4(linerDepth, linerDepth, linerDepth, 1);                                
                return col;
            }
            ENDCG
        }

        //该Pass展示法线纹理
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
                float2 uv : TEXCOORD0;                
                float4 vertex : SV_POSITION;
            };

            sampler2D _CameraDepthNormalsTexture;
            
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;                
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float4 value = tex2D(_CameraDepthNormalsTexture, i.uv);
                fixed3 viewSpaceNormalDir =  DecodeViewNormalStereo(value);
                fixed3 dirMap = viewSpaceNormalDir * 0.5 + 0.5;                                            
                return fixed4(dirMap, 1.0);
            }
            ENDCG
        }
    }
    Fallback Off
}
