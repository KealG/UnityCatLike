using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(MeshFilter), typeof(MeshRenderer))]
[DisallowMultipleComponent]
public class ProcedualMesh : MonoBehaviour
{
    [Header("面片尺寸")]
    public Vector2 size;
    [Header("面片中心点")]
    public Vector3 centerPos;
    [Header("段数")]
    public Vector2 segment;
    private void Awake()
    {
           
    }

    private void Start()
    {
        //1.程序化生成一片矩形网格，并记录地图数据
        GenerateGridMesh();
    }
    
    private void GenerateGridMesh()
    {
        int xSum = Mathf.FloorToInt(segment.x);
        int ySum = Mathf.FloorToInt(segment.y);
        int gridSum = xSum * ySum;

        Vector3 relativeStartPos = new Vector3(centerPos.x - (size.x / 2), centerPos.y, centerPos.z - (size.y / 2));
        float segmentXLength = size.x / segment.x;
        float segmentYLength = size.y / segment.y;
        //Complute Vertexes
        int vertexedNum = (xSum + 1) * (ySum + 1);
        Vector3[] vertexes = new Vector3[vertexedNum];
        for (int i = 0; i < xSum; i++)
        {
            for (int j = 0; j < ySum; j++)
            {
                //赋值
                vertexes[i + j] = new Vector3(relativeStartPos.x + xSum * segmentXLength, centerPos.y , centerPos.z + ySum * segmentYLength);
            }
        }

        //Complute tri index

    }

}
