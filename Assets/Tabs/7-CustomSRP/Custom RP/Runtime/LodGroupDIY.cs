using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

[RequireComponent(typeof(LODGroup))]
public class LodGroupDIY : MonoBehaviour
{    
    public float fadeDuration;

    private void OnGUI()
    {
        LODGroup.crossFadeAnimationDuration = fadeDuration;
    }       
}
