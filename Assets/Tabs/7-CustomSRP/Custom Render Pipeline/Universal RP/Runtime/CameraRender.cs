
using System;
using UnityEngine;
using UnityEngine.Rendering;

public class CameraRender
{
    ScriptableRenderContext context;
    Camera camera;

    const string bufferName = "Render Camera";
    CommandBuffer buffer = new CommandBuffer(){ name = bufferName};
    public void Render(ScriptableRenderContext _context, Camera _camera)
    {
        this.context = _context;
        this.camera = _camera;

        SetUp();
        DrawVisibleGemetry();
        Submit();
    }

    private void SetUp()
    {
        this.context.SetupCameraProperties(this.camera);
        buffer.ClearRenderTarget(true, true, Color.clear);

        buffer.BeginSample(bufferName);        
        ExecuteBuffer();        
    }

    private void DrawVisibleGemetry()
    {
        this.context.DrawSkybox(this.camera);
    }

    private void Submit()
    {
        buffer.EndSample(bufferName);
        ExecuteBuffer();
        this.context.Submit();
    }

    private void ExecuteBuffer()
    {
        context.ExecuteCommandBuffer(buffer);
        buffer.Clear();
    }
}