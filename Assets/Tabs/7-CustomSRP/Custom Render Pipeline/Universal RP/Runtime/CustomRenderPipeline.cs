using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class CustomRenderPipeline : RenderPipeline
{
    CameraRender renderer = new CameraRender();

    protected override void Render(ScriptableRenderContext _context, Camera[] _cameras)
    {
        foreach (Camera camera in _cameras)
        {
            renderer.Render(_context, camera);
        }
    }    
}
