using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class OnCameraRenderProcess : PostEffectsBase
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

    private void OnEnable()
    {
        var c = this.GetComponent<Camera>();
        if (c == null)
        {
            return;
        }
        c.depthTextureMode |= DepthTextureMode.Depth;
        c.depthTextureMode |= DepthTextureMode.DepthNormals;
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (Material != null)
        {
            //RenderTexture curBuff = RenderTexture.GetTemporary(source.descriptor);
            Graphics.Blit(source, destination, Material, 0);
            //Graphics.Blit(curBuff, destination, Material, 1);
            //Graphics.Blit(curBuff, destination, Material, 0);
            //RenderTexture.ReleaseTemporary(curBuff);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}
