using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MotionBlurEffect : PostEffectsBase
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
    [Range(0, 9)]
    public float blurAmount = 0.5f;

    private RenderTexture accumulationTexture;

    private void OnDisable()
    {
        DestroyImmediate(accumulationTexture);
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (Material != null)
        {
            if (accumulationTexture == null || 
                accumulationTexture.width != source.width ||
                accumulationTexture.height != source.height)
            {
                DestroyImmediate(accumulationTexture);
                accumulationTexture = new RenderTexture(source.width, source.height, 0);
                accumulationTexture.hideFlags = HideFlags.HideAndDontSave;
                Graphics.Blit(source, accumulationTexture);
            }

            accumulationTexture.MarkRestoreExpected();
            Material.SetFloat("_BlurAmount", 1.0f - blurAmount);

            Graphics.Blit(source, accumulationTexture, Material);
            Graphics.Blit(accumulationTexture, destination);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}
