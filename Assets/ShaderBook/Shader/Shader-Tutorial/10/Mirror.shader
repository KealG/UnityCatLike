Shader "Unity Shaders Book/10/Mirror"
{
    Properties
    {
        _MainTex ("Main Tex", 2D) = "white" {}       
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag                        

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            //Compute the shadow varible in the file
            #include "AutoLight.cginc"

            sampler2D _MainTex;
            
            struct a2v
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;                              
            };

            struct v2f
            {                                
                float2 uv : TEXCOORD0;            
                float4 pos : SV_POSITION;
            };

            fixed4 _Color;
            fixed4 _ReflectColor;
            fixed _ReflectAmount;
            samplerCUBE _CubeMap;

            v2f vert (a2v v)
            {
                v2f o;

                o.pos = UnityObjectToClipPos(v.vertex);

                o.uv = v.texcoord;

                o.uv.x = 1 - o.uv.x;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {                
                return tex2D(_MainTex, i.uv);
            }
            ENDCG
        }
    }
}
