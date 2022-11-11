using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MotionBlurWithDepthTex : PostEffectsBase
{
    public Shader m_Shader;
    private Material m_Material;
    public Material Material
    {
        get
        {
            m_Material = this.CheckShaderAndCreateMaterial(m_Shader, m_Material);
            return m_Material;
        }
    }

    [Range(0f, 1f)]
    public float blurSize = 0.5f;

    private Camera m_Camera;
    public Camera camera { get 
        {
            if (m_Camera == null)
            {
                m_Camera = GetComponent<Camera>();
            }
            return m_Camera; 
        } 
    }

    private Matrix4x4 previousViewProjectionMatrix;

    private void OnEnable()
    {
        camera.depthTextureMode |= DepthTextureMode.Depth;
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (Material != null)
        {
            Material.SetFloat("_BlurSize", blurSize);
            Material.SetMatrix("_PreviousViewProjectionMatrix", previousViewProjectionMatrix);
            Matrix4x4 currentMt = camera.projectionMatrix * camera.worldToCameraMatrix;
            Matrix4x4 currentMtInverse = currentMt.inverse;
            Material.SetMatrix("_CurrentViewProjectionInverseMatrix", currentMtInverse);
            previousViewProjectionMatrix = currentMt;
            Graphics.Blit(source, destination, Material);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}
