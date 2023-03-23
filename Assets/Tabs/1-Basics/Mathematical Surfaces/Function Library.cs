using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace BasicChapter
{
    public static class CustomFunctionLibrary
    {
        public delegate float m_FuncPtr(float x, float z, float t);

        public enum FuncName
        {
            Wave,
            MultiWave,
            Ripple
        }
        static m_FuncPtr[] functions = { Wave, MultiWave, Ripple };
        public static float Wave(float x, float z, float t) 
        {
            return Mathf.Sin(Mathf.PI * (x + z + t));
        }

        public static float MultiWave(float x, float z, float t)
        {
            float y = Mathf.Sin(Mathf.PI * (x + 0.5f * t));
            y += Mathf.Sin(2f * Mathf.PI * Mathf.Pow((z + t), 1)) * 0.5f;
            return y * (2f / 3f);
        }

        public static float Ripple(float x, float z, float t)
        {
            float d = Mathf.Abs(x);
            float y = Mathf.Sin(Mathf.PI * (4f * d - t));
            return y / (1 + 10f / d);
        }

        public static m_FuncPtr GetFunction(FuncName name)
        {            
            return functions.Length > (int)name ? functions[(int)name] : null;
        }

    }
}

