Shader "Unity Shaders Book/10/GlassRefraction"
{
    Properties
    {
        _MainTex ("Main Tex", 2D) = "white" {}
        _BumpMap ("Normal Map", 2D) = "bump" {}
        _CubeMap ("Environment CubeMap", Cube) = "_SkyBox" {}                
        _Distortion ("Distortion", Range(0, 100)) = 10        
        _RefractAmount ("Refraction Ratio", Range(0,1)) = 0.5     
    }
    SubShader
    {
        Tags { "Queue" = "Transparent" "RenderType" = "Opaque" }
        
        GrabPass { "_RefractionTex" }    

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
            sampler2D _BumpMap;
            samplerCUBE _CubeMap;
            sampler2D _RefractionTex;
            float4 _MainTex_ST;
            float4 _BumpMap_ST;
            float4 _RefractionTex_ST;
            float4 _RefractionTex_TexelSize;
            float _Distortion;
            fixed _RefractAmount;

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;    
                float4 tangent : TANGENT;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f
            {                                
                float4 scrPos : TEXCOORD0;                
                float4 TtoW0 : TEXCOORD1;                
                float4 TtoW1 : TEXCOORD2;                
                float4 TtoW2 : TEXCOORD3;                
                float4 uv : TEXCOORD4;
                float4 pos : SV_POSITION;
            };          

            v2f vert (a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);

                o.scrPos = ComputeGrabScreenPos(o.pos);

                o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.uv.zw = TRANSFORM_TEX(v.texcoord, _BumpMap);

                float3 worldPos = UnityObjectToWorldDir(v.vertex);
                fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
                fixed3 worldTangent = UnityObjectToWorldDir(v.tangent);
                fixed3 worldBinTangent = cross(worldNormal, worldTangent) * v.tangent.w;

                o.TtoW0 = float4(worldTangent.x, worldBinTangent.x, worldNormal.x, worldPos.x);             
                o.TtoW1 = float4(worldTangent.y, worldBinTangent.y, worldNormal.y, worldPos.y);
                o.TtoW2 = float4(worldTangent.z, worldBinTangent.z, worldNormal.z, worldPos.z);                

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 worldPos = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);
                fixed3 worldViewDir = UnityWorldSpaceViewDir(worldPos);

                // Get the normal in tangent space
				fixed3 bump = UnpackNormal(tex2D(_BumpMap, i.uv.zw));	

                // Compute the offset in tangent space
				float2 offset = bump.xy * _Distortion * _RefractionTex_TexelSize.xy;
                //偏移量关联了相机远近的因数
                i.scrPos.xy = (offset * i.scrPos.z) + i.scrPos.xy;
                fixed3 refrCol = tex2D(_RefractionTex, i.scrPos.xy / i.scrPos.w).rgb;

                // Convert the normal to world space
				bump = normalize(half3(dot(i.TtoW0.xyz, bump), dot(i.TtoW1.xyz, bump), dot(i.TtoW2.xyz, bump)));
                fixed3 reflDir = reflect(-worldViewDir, bump);
                fixed3 texColor = tex2D(_MainTex, i.uv.xy);
                fixed3 reflCol = texCUBE(_CubeMap, reflDir).rgb * texColor;

                fixed3 col = reflCol * (1 - _RefractAmount) + refrCol * _RefractAmount;
                                
                return fixed4(col, 1.0);
            }
            ENDCG
        }
    }
}
