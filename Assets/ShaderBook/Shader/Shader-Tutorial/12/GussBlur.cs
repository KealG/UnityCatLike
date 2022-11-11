using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GussBlur : PostEffectsBase
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

    //property
    [Range(1, 4)]
    public int iterations = 1;

    [Range(0.2f, 3.0f)]
    public float blurSpread = 0.6f;

    [Range(1, 8)]
    public int downSample = 2;

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (Material != null)
        {
            int rtW = source.width / downSample;
            int rtH = source.height / downSample;
            RenderTexture buffer = RenderTexture.GetTemporary(rtW, rtH, 0);
            buffer.filterMode = FilterMode.Bilinear;
            Graphics.Blit(source, buffer);

            for (int i = 0; i < iterations; i++)
            {
                Material.SetFloat("_BlurSize", 1.0f + i * blurSpread);
                RenderTexture curIterBuff = RenderTexture.GetTemporary(rtW, rtH, 0);
                Graphics.Blit(buffer, curIterBuff, Material, 0);
                RenderTexture.ReleaseTemporary(buffer);
                buffer = curIterBuff;
                curIterBuff = RenderTexture.GetTemporary(rtW, rtH, 0);
                Graphics.Blit(buffer, curIterBuff, Material, 1);
                RenderTexture.ReleaseTemporary(buffer);
                buffer = curIterBuff;
            }            
            Graphics.Blit(buffer, destination);
            RenderTexture.ReleaseTemporary(buffer);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}
