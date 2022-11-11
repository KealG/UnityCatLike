Shader "Unity Shaders Book/10/Fresnal"
{
    Properties
    {
        _CubeMap ("Fresnal CubeMap", Cube) = "_SkyBox" {}
        _Color ("Color Tint", Color) = (1, 1, 1, 1)                
        _FresnalScale ("Fresnal Scale", Range(0,1)) = 0.5        
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag                        

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            //Compute the shadow varible in the file
            #include "AutoLight.cginc"

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;                
            };

            struct v2f
            {                                
                float3 worldNormal : TEXCOORD0;
                float3 worldViewDir : TEXCOORD1;
                float3 worldRefl : TEXCOORD2;
                SHADOW_COORDS(3)
                float3 worldPos : TEXCOORD4;
                float4 pos : SV_POSITION;
            };

            fixed4 _Color;            
            fixed _FresnalScale;
            samplerCUBE _CubeMap;

            v2f vert (a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);

                o.worldNormal = UnityObjectToWorldNormal(v.normal);

                o.worldPos = UnityObjectToWorldDir(v.vertex);
                
                o.worldViewDir = UnityWorldSpaceViewDir(o.worldPos);

                o.worldRefl = reflect(-normalize(o.worldViewDir), o.worldNormal);

                TRANSFER_SHADOW(o);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                fixed3 worldViewDir = normalize(i.worldViewDir);
                 
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                fixed3 diffuse = _LightColor0.rgb * _Color.rgb * max(0, dot(worldNormal, worldLightDir));

                fixed3 Reflection = texCUBE(_CubeMap, i.worldRefl).rgb;

                fixed fresnal = _FresnalScale + (1 - _FresnalScale) * pow(1 - dot(worldViewDir, worldNormal), 5);
                UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
                
                fixed3 col = ambient + lerp(diffuse, Reflection, saturate(fresnal)) * atten;
                                
                return fixed4(col, 1.0);
            }
            ENDCG
        }
    }
}
