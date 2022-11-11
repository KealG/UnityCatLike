Shader "Unity Shaders Book/7/NormalMapTangentSpace"
{
    Properties
    {
        _Color ("Color Tint", Color) = (1, 1, 1, 1)
        _MainTex("Main Tex", 2D) = "white" {}
        _BumpMap("Normal Map", 2D) = "bump" {}
        _BumpScale("Bump Scale", Float) = 1.0
        _Specular("Specular", Color) = (1, 1, 1, 1)
        _Gloss("Gloss", Range(8.0, 256)) = 20
    }
    SubShader
    {
        Pass
        {
            Tags { "RenderType" = "ForwardBase"}
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc"
            #include "UnityCG.cginc"

            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            float _BumpScale;
            fixed4 _Specular;
            float _Gloss;
            
            struct a2f
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 uv : TEXCOORD0;
                float3 lightDirInTangentSpace : TEXCOORD1;
                float3 viewDirInTangentSpace : TEXCOORD2;
            };

            v2f vert (a2f v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.uv.zw = TRANSFORM_TEX(v.texcoord, _BumpMap);

                //binormal
                float3 binormal = cross( normalize(v.normal), normalize(v.tangent.xyz)) * v.tangent.w;

                //Construct a matrix which transform vectors from object space to tangent space
                float3x3 rotation = float3x3(v.tangent.xyz, binormal, v.normal);

                //Also can use the built-in matrix
                //TANGENT_SPACE_ROTATION

                o.lightDirInTangentSpace = mul(rotation, ObjSpaceLightDir(v.vertex)).xyz;
                o.viewDirInTangentSpace = mul(rotation, ObjSpaceViewDir(v.vertex)).xyz;
                
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 tangentLightDir = normalize(i.lightDirInTangentSpace);
                fixed3 tangentViewDir = normalize(i.viewDirInTangentSpace);

                // get the normal dir in color value[0,1]
                fixed4 packedNormal = tex2D(_BumpMap, i.uv.zw);
                //get the real normal dir
                fixed3 tangentNormal;
                tangentNormal.xy = (packedNormal.xy * 2 - 1) * _BumpScale;
                tangentNormal.z = sqrt(1.0 - dot(tangentNormal.xy, tangentNormal.xy));

                //tangentNormal.xyz =normalize((packedNormal.xyz * 2 - 1));
                
                fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
                //1.环境光
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
                //2.漫反射
                fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(tangentNormal, tangentLightDir));
                fixed3 halfDir = normalize(tangentLightDir + tangentViewDir);
                //3.高光
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(tangentNormal, halfDir)), _Gloss);
                //return fixed4(0,0,packedNormal.z,1);
                return fixed4(ambient + diffuse + specular, 1.0);
            }
            ENDCG
        }
    }
}
