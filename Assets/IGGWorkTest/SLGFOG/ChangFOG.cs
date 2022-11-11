using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ChangFOG : MonoBehaviour
{
    Mesh m_Mesh;
    // Start is called before the first frame update
    void Start()
    {
        var curMSF = GetComponent<MeshFilter>();
        if (curMSF != null) m_Mesh = curMSF.sharedMesh;
        for (int i = 0; i < m_Mesh.vertices.Length; i++)
        {
            Debug.Log("index:" + i);
            Debug.Log(m_Mesh.vertices[i]);
        }        
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetMouseButtonDown(0))
        {
            RayCastTest();
        }        
    }

    private void RayCastTest()
    {
        var ray = Camera.main.ScreenPointToRay(Input.mousePosition);
        if (Physics.Raycast(ray, out RaycastHit hitInfo))
        {
            Debug.LogWarning("Click Screen Pos:" + Input.mousePosition);
            Debug.LogWarning("Click World Pos:" + hitInfo.point);
            if (m_Mesh != null)
            {
                //find target vertice area and change the vertice color
                Color[] colors = m_Mesh.colors;
                for (int i = 0; i < colors.Length; i++)
                {
                    colors[i] = new Color(colors[i].r, colors[i].g, colors[i].b, 0);
                }
                m_Mesh.colors = colors;
            }
        }        
    }
}
