Shader "Unity Shaders Book/11/Billboard"
{
    Properties
    {
        _MainTex ("Main Tex", 2D) = "white" {}
		_Color ("Color Tint", Color) = (1, 1, 1, 1)
		_VerticalBillboarding ("Vertical Restraints", Range(0, 1)) = 1 
    }
    SubShader
    {
        // Need to disable batching because of the vertex animation
		Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "DisableBatching"="True"}

        Pass
        {
            Tags{"LightMode" = "ForwardBase"}
            ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha
			Cull Off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _Color;
			fixed _VerticalBillboarding;

            struct a2v
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
			    float2 uv : TEXCOORD0;
            };            

            v2f vert (a2v v)
            {
                v2f o;        
                // Suppose the center in object space is fixed
				float3 center = float3(0, 0, 0);
				float3 viewer = UnityWorldToObjectDir(float4(_WorldSpaceCameraPos, 1.0));

                float3 normalDir = viewer - center;
                
                normalDir.y =normalDir.y * floor(_VerticalBillboarding);
                normalDir = normalize(normalDir);
                //防止法线方向与模型空间的Z轴平行导致叉积出错
                //float3 upDir = abs(normalDir.y) > 0.999 ? float3(0, 0, 1) : float3(0, 1, 0);
                float3 upDir = float3(0, 1, 0);
				float3 rightDir = normalize(cross(upDir, normalDir));
                upDir = normalize(cross(normalDir, rightDir));


                // Use the three vectors to rotate the quad
				float3 centerOffs = v.vertex.xyz - center;
				float3 localPos = center + rightDir * centerOffs.x + upDir * centerOffs.y + normalDir * centerOffs.z;
              
				o.pos = UnityObjectToClipPos(float4(localPos, 1));
				o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);
                
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 c = tex2D(_MainTex, i.uv);
				c.rgb *= _Color.rgb;

                return c;
            }
            ENDCG
        }
    }
}
