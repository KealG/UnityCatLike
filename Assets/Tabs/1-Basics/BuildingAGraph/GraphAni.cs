using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GraphAni : MonoBehaviour
{
    [SerializeField]
    Transform pointerPrefab;

    [SerializeField, Range(10,100)]
    int resolution;

    Transform[] points;


    private void Awake()
    {
        points = new Transform[resolution];
        float step = 2f /resolution;
        Vector3 scale = Vector3.one * step;
        Vector3 postion = Vector3.zero;

        for (int i = 0;  ++i< resolution;)
        {
            Transform point = points[i] = Instantiate(pointerPrefab);
            postion.x = (i + 0.5f) * step - 1;
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
        if (points != null && points.Length > 0)
        {
            for (int i = 0; i < points.Length; i++)
            {
                var curPoint = points[i];
                if (curPoint != null)
                {
                    var curLocalPos = curPoint.localPosition;
                    curLocalPos.y = Mathf.Sin(Mathf.PI * (curLocalPos.x + Time.time));//  * curLocalPos.x * curLocalPos.x;//Mathf.Pow(, 3f);
                    curPoint.localPosition = curLocalPos;
                }
            }            
        }        
    }
}
