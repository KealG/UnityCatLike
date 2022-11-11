Shader "Unity Shaders Book/11/BriSatAndCon"
{
    Properties
    {
        _MainTex ("Base (RGB)", 2D) = "white" {}
		_Brightness ("Brightness", Float) = 1
		_Saturation("Saturation", Float) = 1
		_Contrast("Contrast", Float) = 1
    }
    SubShader
    {        
        ZTest Always Cull Off ZWrite Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag                        

            #include "UnityCG.cginc"
            sampler2D _MainTex;  
			half _Brightness;
			half _Saturation;
			half _Contrast;         

            struct v2f
            {
                float2 uv : TEXCOORD0;                
                float4 pos : SV_POSITION;
            };            

            v2f vert (appdata_img v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;                
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 renderTex = tex2D(_MainTex, i.uv); 

                // Apply brightness
				fixed3 finalColor = renderTex.rgb * _Brightness;

                // Apply saturation
				fixed luminance = 0.2125 * renderTex.r + 0.7154 * renderTex.g + 0.0721 * renderTex.b;
				fixed3 luminanceColor = fixed3(luminance, luminance, luminance);
				finalColor = lerp(luminanceColor, finalColor, _Saturation);
				
				// Apply contrast
				fixed3 avgColor = fixed3(0.5, 0.5, 0.5);
				finalColor = lerp(avgColor, finalColor, _Contrast);                
                fixed4 col = fixed4(finalColor, renderTex.a);

                return col;
            }
            ENDCG
        }
    }

    Fallback Off
}
