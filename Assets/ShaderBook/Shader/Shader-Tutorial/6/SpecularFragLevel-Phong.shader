// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "lit/SpecularFragLevel"
{
    Properties
    {
        _Diffuse("Diffuse", Color) = (1, 1, 1, 1)
        _Specular("Specular", Color) = (1, 1, 1, 1)
        _Gloss("Gloss", Range(8.0, 256)) = 20
    }
    SubShader
    {                
        Pass
        {
			Tags { "LightMode" = "ForwardBase" }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
                        
			#include "Lighting.cginc"	
            #include "UnityCG.cginc"
			
			fixed4 _Diffuse;
            fixed4 _Specular;
            float _Gloss;

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float3 worldNormal : TEXCOORD0;
                float4 pos : SV_POSITION;                
                float3 worldPos : TEXCOORD1;
            };           

            v2f vert (a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld ,v.vertex);
                //Transform the normal form object space to world space
                fixed3 worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));

                o.worldNormal = worldNormal;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //Get ambient term
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
                //diffuse
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(i.worldNormal, worldLight));

                fixed3 reflectDir = normalize(reflect(-worldLight, i.worldNormal));
                
                fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(viewDir, reflectDir)), _Gloss);
                fixed3 color = ambient + diffuse + specular;
                return fixed4(color, 1.0);
            }
            
            ENDCG
        }
    }
}
