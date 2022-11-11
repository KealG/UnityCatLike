Shader "Unlit/DebugShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
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

			struct v2f 
			{
				float4 pos : SV_POSITION;
				fixed4 color : COLOR0;	
			};

			//OutPut is in Clip Space
            v2f vert (appdata_full v)
            {              
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);

            	// 可视化法线方向
				//o.color = fixed4(v.normal * 0.5 + fixed3(0.5, 0.5, 0.5), 1.0);

            	//切线方向
            	o.color = fixed4(v.tangent.xyz * 0.5 + fixed3(0.5, 0.5, 0.5), 1.0);

            	//副切线方向
            	/*fixed3 binormal = cross(v.normal, v.tangent.xyz) * v.tangent.w;
            	o.color = fixed4(binormal * 0.5 + fixed3(0.5, 0.5, 0.5), 1.0);*/

            	//第一组纹理坐标
            	//o.color = fixed4(v.texcoord.xy, 0.0, 1.0);

            	//第二组纹理坐标
            	//o.color = fixed4(v.texcoord1.xy, 0.0, 1.0);

            	//第一组纹理坐标的小数部分
            	/*o.color = frac(v.texcoord);
            	if(any(saturate(v.texcoord)- v.texcoord))
            		o.color.b = 0.5;
            	o.color.b = 1.0;*/

            	//第二组纹理坐标的小数部分
            	/*o.color = frac(v.texcoord1);
            	if(any(saturate(v.texcoord1)- v.texcoord1))
            		o.color.b = 0.5;
            	o.color.b = 1.0;*/

            	//o.color = v.color;
                return o;
            }

			//InPut is in Screen Space
            fixed4 frag (v2f i) : SV_Target
            {                
                return i.color;
            }

            ENDCG
        }
    }
}
