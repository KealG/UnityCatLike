using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EdgeTest : PostEffectsBase
{
    public Shader m_edgeShader;
    private Material m_edgeMaterial;
    public Material EdgeMaterial { 
        get 
        {
            m_edgeMaterial = this.CheckShaderAndCreateMaterial(m_edgeShader, m_edgeMaterial);
            return m_edgeMaterial; 
        } 
    }

    //property
    [Range(0.0f, 1.0f)]
    public float edgeOnly = 0.0f;
    
    public Color edgeColor = Color.white;
    
    public Color backgroundColor = Color.white;

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (EdgeMaterial != null)
        {
            EdgeMaterial.SetFloat("_EdgeOnly", edgeOnly);
            EdgeMaterial.SetColor("_EdgeColor", edgeColor);
            EdgeMaterial.SetColor("_BackgroundColor", backgroundColor);
            Graphics.Blit(source, destination, EdgeMaterial);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}
