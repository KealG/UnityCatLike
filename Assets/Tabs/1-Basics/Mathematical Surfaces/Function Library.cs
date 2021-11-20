using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace BasicChapter
{
    public static class FunctionLibrary
    {
        public static float Wave(float x, float t) 
        {
            return Mathf.Sin(Mathf.PI * (x + t));
        }

        public static float MultiWave(float x, float t)
        {
            float y = Mathf.Sin(Mathf.PI * (x + 0.5f * t));
            y += Mathf.Sin(2f * Mathf.PI * Mathf.Pow((x + t), 1)) * 0.5f;
            return y * (2f / 3f);
        }

    }
}

