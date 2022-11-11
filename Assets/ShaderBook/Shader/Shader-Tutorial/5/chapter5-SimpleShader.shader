// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unity Shaders Book/Chapter 5/Simple Shader"
{
    Properties
    {
        [HDR]_Color("Color Tint", Color) = (1.0, 1.0, 1.0, 1.0)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
			#include"UnityCG.cginc"
            #pragma vertex vert
            #pragma fragment frag
                      
			struct a2v 
			{
				float4 vertex : POSITION;
				float4 normal : NORMAL;
				float4 texcoord : TEXCOORD0;
			};

			struct v2f 
			{
				float4 pos : SV_POSITION;
				float3 color : COLOR0;	
			};

			//OutPut is in Clip Space
            v2f vert (a2v v)
            {              
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.color = v.normal * 0.5 + fixed3(0.5, 0.5, 0.5);                   
                return o;
            }

			//InPut is in Screen Space
            fixed4 frag (v2f i) : SV_Target
            {                
                fixed4 col = fixed4(i.color, 1.0);                                
                return col;
            }

            ENDCG
        }
    }
}
