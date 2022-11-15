using System.Collections;
using System.Collections.Generic;
using System.Security.Cryptography;
using UnityEngine;
using UnityEngine.Networking.Types;

public class EdgeDetectedWithDepthNormalByObjMesh : PostEffectsBase
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

    private Mesh m_Mesh;
    public Transform m_targetTrs;

    [Range(0.0f, 1.0f)]
    public float edgesOnly = 0.0f;

    public Color edgeColor = Color.black;

    public Color backgroundColor = Color.white;

    public float sampleDistance = 1.0f;

    public float sensitivityDepth = 1.0f;

    public float sensitivityNormals = 1.0f;

    private RenderTexture m_LastRT;

    private void OnEnable()
    {
        GetComponent<Camera>().depthTextureMode |= DepthTextureMode.DepthNormals;
        m_Mesh = m_targetTrs.GetComponent<MeshFilter>()?.sharedMesh;
        
    }

    private void Update()
    {
        //Material.SetFloat("_EdgeOnly", edgesOnly);
        //Material.SetColor("_EdgeColor", edgeColor);
        //Material.SetColor("_BackgroundColor", backgroundColor);
        //Material.SetFloat("_SampleDistance", sampleDistance);
        //Material.SetVector("_Sensitivity", new Vector4(sensitivityNormals, sensitivityDepth, 0.0f, 0.0f));
        //Material.SetTexture("_MainTex", m_LastRT);
        //Graphics.DrawMesh(m_Mesh, m_targetTrs.position, m_targetTrs.rotation, Material, 0);
    }

    [ImageEffectOpaque]
    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (Material != null && m_Mesh != null)
        {
            Material.SetFloat("_EdgeOnly", edgesOnly);
            Material.SetColor("_EdgeColor", edgeColor);
            Material.SetColor("_BackgroundColor", backgroundColor);
            Material.SetFloat("_SampleDistance", sampleDistance);
            Material.SetVector("_Sensitivity", new Vector4(sensitivityNormals, sensitivityDepth, 0.0f, 0.0f));
            Graphics.Blit(source, destination,Material);
            //m_LastRT = destination;
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}
