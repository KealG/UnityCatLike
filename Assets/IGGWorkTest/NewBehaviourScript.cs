using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class NewBehaviourScript : MonoBehaviour
{
    [SerializeField]
    public MeshRenderer mr;

    private Material mat;
    // Start is called before the first frame update
    void Start()
    {
        mat = mr.sharedMaterial;
        mat.name = "test";
        
    }

    // Update is called once per frame
    void Update()
    {

    }
}
