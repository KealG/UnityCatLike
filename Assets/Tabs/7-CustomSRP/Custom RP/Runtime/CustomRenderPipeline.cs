using UnityEngine;
using UnityEngine.Rendering;
using static CustomRenderPipelineAsset;

public partial class CustomRenderPipeline : RenderPipeline {

    CameraRenderer renderer;

    bool useDynamicBatching, useGPUInstancing, useLightsPerObject;

    ShadowSettings shadowSettings;

    PostFXSettings postFXSettings;

    bool allowHDR;

    int colorLUTResolution;

    CameraBufferSettings cameraBufferSettings;

    public CustomRenderPipeline (
        CameraBufferSettings cameraBufferSettings, bool useDynamicBatching, bool useGPUInstancing, bool useSRPBatcher, bool useLightsPerObject,
        ShadowSettings shadowSettings,
        PostFXSettings postFXSettings, int colorLUTResolution, Shader cameraRendererShader
    ) {
        this.colorLUTResolution = colorLUTResolution;
        this.cameraBufferSettings = cameraBufferSettings;
        this.postFXSettings = postFXSettings;
        this.useDynamicBatching = useDynamicBatching;
		this.useGPUInstancing = useGPUInstancing;
		GraphicsSettings.useScriptableRenderPipelineBatching = useSRPBatcher;
		GraphicsSettings.lightsUseLinearIntensity = true;
        this.shadowSettings = shadowSettings;
        this.useLightsPerObject = useLightsPerObject;
        renderer = new CameraRenderer(cameraRendererShader);
        InitializeForEditor();
    }

	protected override void Render (
		ScriptableRenderContext context, Camera[] cameras
	) {
		foreach (Camera camera in cameras) {
			renderer.Render(
				context, camera, cameraBufferSettings, useDynamicBatching, useLightsPerObject, useGPUInstancing,
                shadowSettings, postFXSettings, colorLUTResolution
            );
		}
	}
}