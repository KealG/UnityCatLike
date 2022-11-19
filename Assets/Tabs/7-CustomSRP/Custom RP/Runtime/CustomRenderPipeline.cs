using UnityEngine;
using UnityEngine.Rendering;

public partial class CustomRenderPipeline : RenderPipeline {

	CameraRenderer renderer = new CameraRenderer();

	bool useDynamicBatching, useGPUInstancing, useLightsPerObject;

    ShadowSettings shadowSettings;

    PostFXSettings postFXSettings;

    bool allowHDR;

    public CustomRenderPipeline (
        bool allowHDR, bool useDynamicBatching, bool useGPUInstancing, bool useSRPBatcher, bool useLightsPerObject,
        ShadowSettings shadowSettings,
        PostFXSettings postFXSettings
    ) {
        this.allowHDR = allowHDR;
        this.postFXSettings = postFXSettings;
        this.useDynamicBatching = useDynamicBatching;
		this.useGPUInstancing = useGPUInstancing;
		GraphicsSettings.useScriptableRenderPipelineBatching = useSRPBatcher;
		GraphicsSettings.lightsUseLinearIntensity = true;
        this.shadowSettings = shadowSettings;
        this.useLightsPerObject = useLightsPerObject;
        InitializeForEditor();
    }

	protected override void Render (
		ScriptableRenderContext context, Camera[] cameras
	) {
		foreach (Camera camera in cameras) {
			renderer.Render(
				context, camera, allowHDR, useDynamicBatching, useLightsPerObject, useGPUInstancing,
                shadowSettings, postFXSettings
            );
		}
	}
}