using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GraphAni : MonoBehaviour
{
    [SerializeField]
    Transform pointerPrefab;

    [SerializeField, Range(10,100)]
    int resolution;

    private void Awake()
    {
        float step = 2f /resolution;
        Vector3 scale = Vector3.one / 5f * step;
        Vector3 postion = Vector3.zero;
        for (int i = 0;  ++i< resolution;)
        {
            var pointer = Instantiate(pointerPrefab);
            postion.x = (i + 0.5f) * step - 1;
            postion.y = postion.x * postion.x;
            pointer.localPosition = postion;            
            pointer.localScale = scale;
            pointer.SetParent(transform, false);
        }
    }

    void Start()
    {
        
    }

    
    void Update()
    {
        
    }
}
