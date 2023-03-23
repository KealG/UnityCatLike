using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using BasicChapter;

public class GraphAni : MonoBehaviour
{
    [SerializeField]
    Transform pointerPrefab;

    [SerializeField, Range(10,100)]
    int resolution;

    Transform[] points;

    [SerializeField]
    FunctionLibrary.FunctionName function;

    private void Awake()
    {
        points = new Transform[resolution * resolution];
        float step = 2f /resolution;
        Vector3 scale = Vector3.one * step;
        Vector3 postion = Vector3.zero;

        for (int i = 0, x = 0, z = 0;  i< points.Length; i++, x++)
        {
            if (x == resolution)
            {
                x = 0;
                z += 1;
            }
            Transform point = points[i] = Instantiate(pointerPrefab);
            postion.x = (x + 0.5f) * step - 1;
            postion.z = (z + 0.5f) * step - 1;
            postion.y = postion.x * postion.x;
            point.localPosition = postion;            
            point.localScale = scale;
            point.SetParent(transform, false);             
        }
    }

    void Start()
    {
        
    }

    
    void Update()
    {
        FunctionLibrary.Function f = FunctionLibrary.GetFunction(function);
        if (points != null && points.Length > 0)
        {
            for (int i = 0; i < points.Length; i++)
            {
                var curPoint = points[i];
                if (curPoint != null)
                {                    
                    var curLocalPos = curPoint.localPosition;
                    curLocalPos.y = f != null ? f(curLocalPos.x, curLocalPos.z, Time.time).y: curLocalPos.y;
                    curPoint.localPosition = curLocalPos;
                    //if (function == 0)
                    //{
                    //    curLocalPos.y = FunctionLibrary.Wave(curLocalPos.x, Time.time);//Mathf.Sin(Mathf.PI * (curLocalPos.x + Time.time));//  * curLocalPos.x * curLocalPos.x;//Mathf.Pow(, 3f);
                    //}
                    //else
                    //{
                    //    curLocalPos.y = FunctionLibrary.MultiWave(curLocalPos.x, Time.time);//Mathf.Sin(Mathf.PI * (curLocalPos.x + Time.time));//  * curLocalPos.x * curLocalPos.x;//Mathf.Pow(, 3f);
                    //}                                        
                }
            }            
        }        
    }
}
