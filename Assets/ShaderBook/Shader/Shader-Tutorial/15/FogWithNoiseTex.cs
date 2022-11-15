using System.Collections;
using System.Collections.Generic;
using System.Security.Cryptography;
using UnityEngine;

public class FogWithNoiseTex : PostEffectsBase
{
    public Shader m_Shader;
    private Material m_Material;
    public Material Material { 
        get 
        {
            m_Material = this.CheckShaderAndCreateMaterial(m_Shader, m_Material);
            return m_Material; 
        } 
    }

    private Camera m_Camera;
    public Camera Camera
    {
        get
        {
            if (m_Camera == null)
            {
                m_Camera = GetComponent<Camera>();
            }
            return m_Camera;
        }
    }

    private Transform m_CameraTrs;
    public Transform cameraTrs
    {
        get
        {            
            return Camera?.transform;
        }
    }
    [Range(0.1f, 3.0f)]
    public float fogDensity = 1.0f;

    public Color fogColor = Color.white;

    public float fogStart = 0.0f;
    public float fogEnd = 2.0f;

    public Texture noiseTexture;

    [Range(-0.5f, 0.5f)]
    public float fogXSpeed = 0.1f;

    [Range(-0.5f, 0.5f)]
    public float fogYSpeed = 0.1f;

    [Range(0.0f, 3.0f)]
    public float noiseAmount = 1.0f;


    private void OnEnable()
    {
        Camera.depthTextureMode |= DepthTextureMode.Depth;        
    }


    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (Material != null)
        {
            Matrix4x4 frustumCorners = Matrix4x4.identity;

            float fov = Camera.fieldOfView;
            float near = Camera.nearClipPlane;
            float aspect = Camera.aspect;

            float halfHeight = near * Mathf.Tan(fov * 0.5f * Mathf.Deg2Rad);
            Vector3 toRight = cameraTrs.right * halfHeight * aspect;
            Vector3 toTop = cameraTrs.up * halfHeight;

            Vector3 topLeft = cameraTrs.forward * near + toTop - toRight;
            float scale = topLeft.magnitude / near;

            topLeft.Normalize();
            topLeft *= scale;

            Vector3 topRight = cameraTrs.forward * near + toRight + toTop;
            topRight.Normalize();
            topRight *= scale;

            Vector3 bottomLeft = cameraTrs.forward * near - toTop - toRight;
            bottomLeft.Normalize();
            bottomLeft *= scale;

            Vector3 bottomRight = cameraTrs.forward * near + toRight - toTop;
            bottomRight.Normalize();
            bottomRight *= scale;

            frustumCorners.SetRow(0, bottomLeft);
            frustumCorners.SetRow(1, bottomRight);
            frustumCorners.SetRow(2, topRight);
            frustumCorners.SetRow(3, topLeft);

            Material.SetMatrix("_FrustumCornersRay", frustumCorners);

            Material.SetFloat("_FogDensity", fogDensity);
            Material.SetColor("_FogColor", fogColor);
            Material.SetFloat("_FogStart", fogStart);
            Material.SetFloat("_FogEnd", fogEnd);

            Material.SetTexture("_NoiseTex", noiseTexture);
            Material.SetFloat("_FogXSpeed", fogXSpeed);
            Material.SetFloat("_FogYSpeed", fogYSpeed);
            Material.SetFloat("_NoiseAmount", noiseAmount);

            Graphics.Blit(source, destination, Material);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}
