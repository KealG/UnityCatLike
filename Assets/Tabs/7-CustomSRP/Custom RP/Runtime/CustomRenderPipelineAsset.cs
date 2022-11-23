using System;
using UnityEngine;
using UnityEngine.Rendering;

[CreateAssetMenu(menuName = "Rendering/Custom Render Pipeline")]
public partial class CustomRenderPipelineAsset : RenderPipelineAsset {

	[SerializeField]
	bool useDynamicBatching = true, useGPUInstancing = true, useSRPBatcher = true, useLightsPerObject = false;

    [SerializeField]
    ShadowSettings shadows = default;

    [SerializeField]
    PostFXSettings postFXSettings = default;

    [SerializeField]
    bool allowHDR = true;

    [System.Serializable]
    public struct CameraBufferSettings
    {

        public bool allowHDR;

        public bool copyDepth;

        public bool copyDepthReflections;

        public bool copyColor, copyColorReflection;

        [Range(0.1f, 2f)]
        public float renderScale;

        public BicubicRescalingMode bicubicRescaling;

        public enum BicubicRescalingMode { Off, UpOnly, UpAndDown }

        [Serializable]
        public struct FXAA
        {

            public bool enabled;

            [Range(0.0312f, 0.0833f)]
            public float fixedThreshold;
        }

        public FXAA fxaa;
    }

    [SerializeField]
    CameraBufferSettings cameraBuffer = new CameraBufferSettings
    {
        allowHDR = true,
        renderScale = 1f,
        fxaa = new CameraBufferSettings.FXAA
        {
            fixedThreshold = 0.0833f
        }
    };

    public enum ColorLUTResolution { _16 = 16, _32 = 32, _64 = 64 }

    [SerializeField]
    ColorLUTResolution colorLUTResolution = ColorLUTResolution._32;

    [SerializeField]
    Shader cameraRendererShader = default;
    protected override RenderPipeline CreatePipeline () {
		return new CustomRenderPipeline(
            cameraBuffer, useDynamicBatching, useGPUInstancing, useSRPBatcher, useLightsPerObject, shadows, postFXSettings, (int)colorLUTResolution,
            cameraRendererShader
        );
	}
}