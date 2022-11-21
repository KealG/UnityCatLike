using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Runtime.InteropServices;
public static class ReinterpretExtensions
{
    [StructLayout(LayoutKind.Explicit)]
    struct IntFloat
    {

        public int intValue;

        public float floatValue;
    }

    public static float ReinterpretAsFloat(this int value)
    {
        IntFloat converter = default;
        converter.intValue = value;
        return converter.floatValue;
    }
}

