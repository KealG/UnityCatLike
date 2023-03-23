using UnityEngine;

public class GPUGraph : MonoBehaviour {
	
	[SerializeField, Range(10, 200)]
	int resolution = 10;

	[SerializeField]
	FunctionLibrary.FunctionName function;

	public enum TransitionMode { Cycle, Random }

	[SerializeField]
	TransitionMode transitionMode;

	[SerializeField, Min(0f)]
	float functionDuration = 1f, transitionDuration = 1f;

	Transform[] points;

	float duration;

	bool transitioning;

	FunctionLibrary.FunctionName transitionFunction;

	//GPU Buffer
	ComputeBuffer positionsBuffer;

	[SerializeField]
	ComputeShader computeShader;
    static readonly int positionsId = Shader.PropertyToID("_Positions"),
        resolutionId = Shader.PropertyToID("_Resolution"),
        stepId = Shader.PropertyToID("_Step"),
        timeId = Shader.PropertyToID("_Time");

    [SerializeField]
    Material material;

    [SerializeField]
    Mesh mesh;


    private void Awake()
    {
		positionsBuffer = new ComputeBuffer(resolution * resolution, 3 * 4);
    }

    private void OnDisable()
    {
        positionsBuffer?.Release();
        positionsBuffer = null;
    }

    void UpdateFunctionOnGPU()
    {
        float step = 2f / resolution;
        computeShader.SetInt(resolutionId, resolution);
        computeShader.SetFloat(stepId, step);
        computeShader.SetFloat(timeId, Time.time);
		int kernelIndex = computeShader.FindKernel("FunctionKernel");
        computeShader.SetBuffer(kernelIndex, positionsId, positionsBuffer);

        int groups = Mathf.CeilToInt(resolution / 8f);
        computeShader.Dispatch(kernelIndex, groups, groups, 1);
    }

    void Update () {
        duration += Time.deltaTime;
        if (transitioning)
        {
            if (duration >= transitionDuration)
            {
                duration -= transitionDuration;
                transitioning = false;
            }
        }
        else if (duration >= functionDuration)
        {
            duration -= functionDuration;
            transitioning = true;
            transitionFunction = function;
            PickNextFunction();
        }

        UpdateFunctionOnGPU();

        material.SetBuffer(positionsId, positionsBuffer);
        material.SetFloat(stepId, 2f / resolution);
        var bounds = new Bounds(Vector3.zero, Vector3.one * (2f + 2f / resolution));
		Debug.Log(positionsBuffer.count);
        Graphics.DrawMeshInstancedProcedural(mesh, 0, material, bounds, positionsBuffer.count);
    }

	void PickNextFunction () {
		function = transitionMode == TransitionMode.Cycle ?
			FunctionLibrary.GetNextFunctionName(function) :
			FunctionLibrary.GetRandomFunctionNameOtherThan(function);
	}		
}