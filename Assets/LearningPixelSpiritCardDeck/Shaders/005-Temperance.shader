Shader "Unlit/005-Temperance"
{
    Properties
    {
        // _MainTex ("Texture", 2D) = "white" {}
        [Vector2] _Resolution("Resolution", Vector) = (400,400,0,0)
        _StartPoint1("StartPoint1", Float) = -0.4
        _StartPoint2("StartPoint2", Float) = -0.2
        _StartPoint3("StartPoint3", Float) = 0.3
        _Width("Width", Float) = 0.2
        _Amplitude("Amplitude", Float) = 0.2
        _Frequency("Frequency", Float) = 0.2

    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
            #include "/CustomLib/PixelSpiritLib.hlsl"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            // sampler2D _MainTex;
            // float4 _MainTex_ST;
            
            float2 _Resolution;
            float _StartPoint1;
            float _StartPoint2;
            float _StartPoint3;
            float _Width;
            float _Amplitude;
            float _Frequency;


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                // o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv = v.uv;
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                // sample the texture
                // fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog

                //uv will now from [-1;1] instead of [0;1]
                float2 scaleUV = (i.uv - 0.5) * 2;
                scaleUV = GetUVKeepingAspectRatio(scaleUV, _Resolution);

                half4 resultColor = (half4)0.0;

                float cosYValue = _Amplitude * cos(_Frequency * scaleUV.y * PI);
                resultColor += Stroke(scaleUV.x + cosYValue, _StartPoint1, _Width);
                resultColor += Stroke(scaleUV.x + cosYValue, _StartPoint2, _Width);
                resultColor += Stroke(scaleUV.x + cosYValue, _StartPoint3, _Width);

                resultColor.a = 1.0;

                return resultColor;
            }
            ENDHLSL
        }
    }
}
