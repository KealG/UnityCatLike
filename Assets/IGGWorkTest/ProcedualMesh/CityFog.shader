Shader "Unlit/CityFog"
{
    Properties
    {
        _MainTex("MainTexture", 2D) = "white" {}
        _Mask("MaskTexture", 2D) = "white" {}
        [HDR][MainColor]_FogColor("FogColor", Color) = (1,1,1,1)
        [Enum(UnLockProgress1, 1, UnLockProgress2, 2, UnLockProgress3, 3, UnLockProgress4, 4, UnLockProgress5, 5)]
        _UnLockProgress("TestProgress", Float) = 1.0
        _MoveDir("MoveDir", Vector) = (1, 1, 1, 1)
        _MoveSpeedX("MoveSpeedX", Float) = 1.0
        _MoveSpeedY("MoveSpeedY", Float) = 1.0
            //        _MinCameraIDWDis("MinCameraIDWDis", Float) = 1.0
            //        _MaxCameraIDWDis("MaxCameraIDWDis", Float) = 1.0
            //        _CameraScaleUVRate("CameraScaleUVRate", Float) = 1.0
        _SwitchUVDetailDis("SwitchUVDetailDis", Float) = 1.0
        _FarUVRate("FarUVRate", Float) = 1.0
        _CloserUVRate("CloserUVRate", Float) = 1.0
    }
        SubShader
        {
            Tags { "RenderType" = "Opaque" "Queue" = "Transparent"}
            Blend SrcAlpha OneMinusSrcAlpha
            LOD 100

            Pass
            {
                CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                // make fog work
                #pragma multi_compile_fog

                #include "UnityCG.cginc"

                struct appdata
                {
                    float4 vertex : POSITION;
                    float2 uv : TEXCOORD0;
                };

                struct v2f
                {
                    float2 uv : TEXCOORD0;
                    UNITY_FOG_COORDS(1)
                    float4 vertex : SV_POSITION;
                    float distance2Camera : TEXCOORD1;
                };

                sampler2D _MainTex;
                float4 _MainTex_ST;
                float4 _FogColor;
                // float _MinCameraIDWDis;
                // float _MaxCameraIDWDis;

                v2f vert(appdata v)
                {
                    v2f o;
                    o.vertex = UnityObjectToClipPos(v.vertex);
                    // o.distance2Camera = (1 - max(abs(-UnityObjectToViewPos(v.vertex).z) - _ProjectionParams.y, 0) / clamp(max(_MaxCameraIDWDis - _MinCameraIDWDis, 1), 1, max(_ProjectionParams.z - _ProjectionParams.y, 1)));
                    o.distance2Camera = max(abs(-UnityObjectToViewPos(v.vertex).z) - _ProjectionParams.y, 0);
                    o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                    UNITY_TRANSFER_FOG(o,o.vertex);
                    return o;
                }

                sampler2D _Mask;
                fixed _UnLockProgress;
                fixed _CameraScaleUVRate;
                fixed _MoveSpeedX;
                fixed _MoveSpeedY;
                fixed2 _MoveDir;
                float _SwitchUVDetailDis;
                float _FarUVRate;
                float _CloserUVRate;

                fixed4 frag(v2f i) : SV_Target
                {
                    //sample the mask
                    fixed4 maskSign = tex2D(_Mask, i.uv);

                //sample the reversal mask
                fixed2 reversalUV = i.uv * (1, -1);
                fixed4 reversalMaskSign = tex2D(_Mask, reversalUV);

                //mask                
                float p1Value = maskSign.x * step(1, _UnLockProgress) * step(_UnLockProgress, 1.9);
                float p2Value = maskSign.y * step(2, _UnLockProgress) * step(_UnLockProgress, 2.9);
                float p3Value = maskSign.z * step(3, _UnLockProgress) * step(_UnLockProgress, 3.9);
                float p4Value = maskSign.z * maskSign.y * reversalMaskSign.y * step(4, _UnLockProgress) * step(_UnLockProgress, 4.9);
                float p5Value = maskSign.z * reversalMaskSign.z * step(5, _UnLockProgress) * step(_UnLockProgress, 5.9);
                float targetAlpha = max(max(max(p3Value, max(p1Value, p2Value)), p4Value), p5Value);

                //anim
                float changeRate = _Time.y * _MoveDir;
                i.uv.x += changeRate * _MoveSpeedX;
                i.uv.y += changeRate * _MoveSpeedY;
                // sample the texture
                fixed4 oriCol = tex2D(_MainTex, i.uv * max(_FarUVRate,  1));

                // change the CameraDis
                oriCol *= tex2D(_MainTex, i.uv * max(_CloserUVRate * step(i.distance2Camera, _SwitchUVDetailDis), 1));

                // change the color
                oriCol *= _FogColor;

                // apply the alpha
                oriCol.w = targetAlpha;

                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, oriCol);
                return oriCol;
            }
            ENDCG
        }
    }
}
