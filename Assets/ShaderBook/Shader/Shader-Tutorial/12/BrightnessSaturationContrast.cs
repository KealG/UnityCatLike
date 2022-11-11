using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BrightnessSaturationContrast : PostEffectsBase
{
    public Shader m_briSatConShader;
    private Material m_briSatConMaterial;
    public Material briSatConMaterial { 
        get 
        {
            m_briSatConMaterial = this.CheckShaderAndCreateMaterial(m_briSatConShader, m_briSatConMaterial);
            return m_briSatConMaterial; 
        } 
    }

    //property
    [Range(0.0f, 3.0f)]
    public float brightness = 1.0f;
    [Range(0.0f, 3.0f)]
    public float saturation = 1.0f;
    [Range(0.0f, 3.0f)]
    public float contrast = 1.0f;

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (briSatConMaterial != null)
        {
            briSatConMaterial.SetFloat("_Brightness", brightness);
            briSatConMaterial.SetFloat("_Saturation", saturation);
            briSatConMaterial.SetFloat("_Contrast", contrast);
            Graphics.Blit(source, destination, briSatConMaterial);
        }
        else
        {
            Graphics.Blit (source, destination);
        }
    }
}
