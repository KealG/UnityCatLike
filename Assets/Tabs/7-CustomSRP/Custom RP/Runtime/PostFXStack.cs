using Unity.Mathematics;
using UnityEngine;
using UnityEngine.Networking.Types;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public partial class PostFXStack
{

    const string bufferName = "Post FX";

    CommandBuffer buffer = new CommandBuffer
    {
        name = bufferName
    };

    ScriptableRenderContext context;

    Camera camera;

    PostFXSettings settings;

    public bool IsActive => settings != null;

    enum Pass
    {
        BloomHorizontal,
        BloomVertical,
        BloomCombine,
        BloomPrefilter,
        BloomPrefilterFireflies,
        Copy
    }

    const int maxBloomPyramidLevels = 16;

    int bloomPyramidId;

    int fxSourceId = Shader.PropertyToID("_PostFXSource"),
    fxSource2Id = Shader.PropertyToID("_PostFXSource2"),
    bloomBucibicUpsamplingId = Shader.PropertyToID("_BloomBicubicUpsampling"),
    bloomPrefilterId = Shader.PropertyToID("_BloomPrefilter"),
    bloomThresholdId = Shader.PropertyToID("_BloomThreshold"),
    bloomIntensityId = Shader.PropertyToID("_BloomIntensity");

    bool useHDR;

    public PostFXStack()
    {
        bloomPyramidId = Shader.PropertyToID("_BloomPyramid0");
        for (int i = 1; i < maxBloomPyramidLevels * 2; i++)
        {
            Shader.PropertyToID("_BloomPyramid" + i);
        }
    }

    void DoBloom(int sourceId)
    {
        buffer.BeginSample("Bloom");
        PostFXSettings.BloomSettings bloom = settings.Bloom;
        int width = camera.pixelWidth / 2, height = camera.pixelHeight / 2;
        if (
            bloom.maxIterations == 0 ||
            height < bloom.downscaleLimit * 2 || width < bloom.downscaleLimit * 2
        )
        {
            Draw(sourceId, BuiltinRenderTextureType.CameraTarget, Pass.Copy);
            buffer.EndSample("Bloom");
            return;
        }

        Vector4 threshold;
        threshold.x = Mathf.GammaToLinearSpace(bloom.threshold);
        threshold.y = threshold.x * bloom.thresholdKnee;
        threshold.z = 2f * threshold.y;
        threshold.w = 0.25f / (threshold.y + 0.00001f);
        threshold.y -= threshold.x;
        buffer.SetGlobalVector(bloomThresholdId, threshold);

        RenderTextureFormat format = useHDR ? RenderTextureFormat.DefaultHDR : RenderTextureFormat.Default;
        buffer.GetTemporaryRT(
            bloomPrefilterId, width, height, 0, FilterMode.Bilinear, format
        );
        //模糊后的图层与原图混合
        Draw(sourceId, bloomPrefilterId, bloom.fadeFireflies ?
                Pass.BloomPrefilterFireflies : Pass.BloomPrefilter);
        width /= 2;
        height /= 2;

        int fromId = bloomPrefilterId, toId = bloomPyramidId + 1;

        int i;
        for (i = 0; i < math.min( bloom.maxIterations, maxBloomPyramidLevels); i++)
        {
            if (height < bloom.downscaleLimit || width < bloom.downscaleLimit)
            {
                break;
            }
            int midId = toId - 1;
            buffer.GetTemporaryRT(
                midId, width, height, 0, FilterMode.Bilinear, format
            );
            buffer.GetTemporaryRT(
                toId, width, height, 0, FilterMode.Bilinear, format
            );
            Draw(fromId, midId, Pass.BloomHorizontal);
            Draw(midId, toId, Pass.BloomVertical);            
            fromId = toId;
            toId += 2;
            width /= 2;
            height /= 2;
        }
        buffer.ReleaseTemporaryRT(bloomPrefilterId);

        //Draw(fromId, BuiltinRenderTextureType.CameraTarget, Pass.Copy);
        buffer.ReleaseTemporaryRT(fromId - 1);
        toId -= 5;

        buffer.SetGlobalFloat(bloomBucibicUpsamplingId, bloom.bicubicUpsampling ? 1f : 0f);
        buffer.SetGlobalFloat(bloomIntensityId, 1f);
        if (i > 1)
        {
            for (i -= 1; i > 0; i--)
            {
                buffer.SetGlobalTexture(fxSource2Id, toId + 1);
                Draw(fromId, toId, Pass.BloomCombine);
                buffer.ReleaseTemporaryRT(fromId);
                buffer.ReleaseTemporaryRT(toId + 1);
                fromId = toId;
                toId -= 2;
            }
        }
        else
        {
            buffer.ReleaseTemporaryRT(bloomPyramidId);
        }
        buffer.SetGlobalFloat(bloomIntensityId, bloom.intensity);
        buffer.SetGlobalTexture(fxSource2Id, sourceId);
        Draw(fromId, BuiltinRenderTextureType.CameraTarget, Pass.BloomCombine);
        buffer.ReleaseTemporaryRT(fromId);

        buffer.EndSample("Bloom");
    }


    public void Setup(
        ScriptableRenderContext context, Camera camera, PostFXSettings settings,
        bool useHDR
    )
    {
        this.useHDR = useHDR;
        this.context = context;
        this.camera = camera;
        this.settings = camera.cameraType <= CameraType.SceneView ? settings : null;        
        ApplySceneViewState();
    }

    public void Render(int sourceId)
    {
        //buffer.Blit(sourceId, BuiltinRenderTextureType.CameraTarget);

        //Draw(sourceId, BuiltinRenderTextureType.CameraTarget, Pass.Copy);

        DoBloom(sourceId);
        context.ExecuteCommandBuffer(buffer);
        buffer.Clear();
    }


    void Draw(
        RenderTargetIdentifier from, RenderTargetIdentifier to, Pass pass
    )
    {
        buffer.SetGlobalTexture(fxSourceId, from);
        buffer.SetRenderTarget(
            to, RenderBufferLoadAction.DontCare, RenderBufferStoreAction.Store
        );

        buffer.DrawProcedural(
            Matrix4x4.identity, settings.Material, (int)pass,
            MeshTopology.Triangles, 3
        );
    }
}