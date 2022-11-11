Shader "Unity Shaders Book/9/Shadow"
{
    Properties
    {        
        _Diffuse ("Diffuse Color", Color) = (1,1,1,1)
        _Specular ("Specular Color", Color) = (1,1,1,1)
        _Gloss ("Gloss", Range(8.0, 256)) = 12
    }
    SubShader
    {
        Tags { "RenderType"= "Opaque" }        

        Pass
        {
            Tags 
            {
                //Pass for ambient light& first pixel light(Directional light)
                "LightMode" = "ForwardBase"
            }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // Apparently need to add this declaration
            #pragma multi_compile_fwdbase

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
                float3 worldPos : TEXCOORD1;                
                float4 pos : SV_POSITION;   
                SHADOW_COORDS(2)                      
            };
            
            float3 _Diffuse;
            float3 _Specular;
            float _Gloss;

            v2f vert (a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);                
                o.worldNormal = UnityObjectToWorldNormal(v.normal);   
                o.worldPos = UnityObjectToWorldDir(v.vertex);
                // Pass shadow coordinates to pixel shader
                TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                fixed3 halfDir = normalize(worldViewDir + worldLightDir); 
                //Get the ambient term
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                
                //Get the diffuse term
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * max(0, dot(worldNormal, worldLightDir));

                //Get the specular term
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss);

                //Get the attenuation of direction light
                fixed atten = 1.0;
                
                //Use shadow coordinates to sample shadow map
                fixed shadow = SHADOW_ATTENUATION(i);
                // sample the texture
                fixed4 col = fixed4(ambient + (diffuse + specular) * atten * shadow , 1.0);                                
                return col;
            }
            ENDCG
        }

        Pass
        {
            //pass for other pixel lights
            Tags
            {
                "LightMode" = "ForwardAdd"
            }

            Blend One One
            CGPROGRAM

            //Apparently need to add this delcaration
            #pragma multi_compile_fwdadd
            #include "Lighting.cginc"
            #include "AutoLight.cginc"
            #pragma vertex vert
            #pragma fragment frag
            
            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;                              
            };

            struct v2f
            {                
                float3 worldNormal : TEXCOORD1;
                float3 worldPos : TEXCOORD2;
                float4 vertex : SV_POSITION;                
            };
                        
            float3 _Diffuse;
            float3 _Specular;
            float _Gloss;

            v2f vert (a2v v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);                
                o.worldNormal = UnityObjectToWorldNormal(v.normal);   
                o.worldPos = UnityObjectToWorldDir(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {                        
                fixed3 worldNormal = normalize(i.worldNormal);
                #ifdef USING_DIRECTIONAL_LIGHT
					fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
				#else
					fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz - i.worldPos.xyz);
				#endif

                // fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                fixed3 halfDir = normalize(worldViewDir + worldLightDir); 
                //Get the ambient term
                // fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                
                //Get the diffuse term
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * max(0, dot(worldNormal, worldLightDir));                

                //Get the specular term
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss);

                //Get the attenuation of direction light                
                #ifdef USING_DIRECTIONAL_LIGHT
					fixed atten = 1.0;
				#else
					#if defined (POINT)
				        float3 lightCoord = mul(unity_WorldToLight, float4(i.worldPos, 1)).xyz;
				        fixed atten = tex2D(_LightTexture0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
				    #elif defined (SPOT)
				        float4 lightCoord = mul(unity_WorldToLight, float4(i.worldPos, 1));
				        fixed atten = (lightCoord.z > 0) * tex2D(_LightTexture0, lightCoord.xy / lightCoord.w + 0.5).w * tex2D(_LightTextureB0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
				    #else
				        fixed atten = 1.0;
				    #endif
				#endif
                
                // sample the texture
                fixed4 col = fixed4((diffuse + specular) * atten , 1.0);                                
                return col;
            }

            ENDCG
        }
    }
    FallBack "Specular"
}
