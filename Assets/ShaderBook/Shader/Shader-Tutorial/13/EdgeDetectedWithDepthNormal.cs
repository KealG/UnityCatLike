using System.Collections;
using System.Collections.Generic;
using System.Security.Cryptography;
using UnityEngine;
using static UnityEngine.Rendering.DebugUI.Table;

public class EdgeDetectedWithDepthNormal : PostEffectsBase
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

    [Range(0.0f, 1.0f)]
    public float edgesOnly = 0.0f;

    public Color edgeColor = Color.black;

    public Color backgroundColor = Color.white;

    public float sampleDistance = 1.0f;

    public float sensitivityDepth = 1.0f;

    public float sensitivityNormals = 1.0f;


    private void OnEnable()
    {
        GetComponent<Camera>().depthTextureMode |= DepthTextureMode.None;        
    }


    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (Material != null)
        {
            Material.SetFloat("_EdgeOnly", edgesOnly);
            Material.SetColor("_EdgeColor", edgeColor);
            Material.SetColor("_BackgroundColor", backgroundColor);
            Material.SetFloat("_SampleDistance", sampleDistance);
            Material.SetVector("_Sensitivity", new Vector4(sensitivityNormals, sensitivityDepth, 0.0f, 0.0f));

            Graphics.Blit(source, destination, Material);

            Graphics.Blit(source, destination, Material);            
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}
