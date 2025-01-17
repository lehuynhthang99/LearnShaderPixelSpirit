Shader "Unlit/028-The_devil"
{
    Properties
    {
        // _MainTex ("Texture", 2D) = "white" {}
        [Vector2] _Resolution("Resolution", Vector) = (400,400,0,0)
        
        [Space(12)]
        _StrokeWidth("StrokeWidth", Float) = 0.02

        [Space(12)]
        _CircleStartStroke("CircleStartStroke", Float) = 0.02

        [Space(12)]
        _StarVertices("StarVertices", Integer) = 5
        _StarAngleDegree("StarAngleDegree", Float) = 0.1
        _StarOutsideSize("StarOutsideSize", Float) = 0.1

        [Space(12)]
        _StarInsideStartStroke("StarInsideStartStroke", Float) = 0.1
        _StarInsideStrokeWidth("StarInsideStrokeWidth", Float) = 0.1

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

            float _StrokeWidth;
            float _CircleStartStroke;

            float _StarVertices;
            float _StarAngleDegree;
            float _StarInsideStartStroke;
            float _StarInsideStrokeWidth;
            float _StarOutsideSize;

            
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
                float finalFactor = 0;

                float starSDF = StarSDF(scaleUV, _StarVertices, radians(_StarAngleDegree));
                float circleSDF = CircleSDF(scaleUV);

                finalFactor = Stroke(circleSDF, _CircleStartStroke, _StrokeWidth);

                finalFactor *= 1 - Fill(starSDF, _StarOutsideSize);
                finalFactor += Stroke(starSDF, _StarInsideStartStroke, _StarInsideStrokeWidth);

                resultColor = finalFactor;
                resultColor.a = 1.0;

                return resultColor;
            }
            ENDHLSL
        }
    }
}
