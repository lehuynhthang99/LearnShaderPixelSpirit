Shader "Unlit/026-The_emperatris"
{
    Properties
    {
        // _MainTex ("Texture", 2D) = "white" {}
        [Vector2] _Resolution("Resolution", Vector) = (400,400,0,0)
        
        [Space(12)]
        _NumberOfVertices("NumberOfVertices", Integer) = 5
        _NumberOfShape("NumberOfShape", Integer) = 5

        [Space(12)]
        _StrokeWidth("StrokeWidth", Float) = 0.02
        _EmptyStrokeWidth("EmptyStrokeWidth", Float) = 0.02
        
        [Space(12)]
        _RemoveStrokeWidth("RemoveStrokeWidth", Float) = 0.02
        _RemoveEmptyStrokeWidth("RemoveEmptyStrokeWidth", Float) = 0.02
        

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

            float _NumberOfVertices;
            float _NumberOfShape;

            float _StrokeWidth;
            float _EmptyStrokeWidth;
            
            float _RemoveStrokeWidth;
            float _RemoveEmptyStrokeWidth;

            float _EffectRotation;

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
                float2 flipScaleUV = float2(scaleUV.x, (-1) * scaleUV.y);

                half4 resultColor = (half4)0.0;

                float finalFactor = 0;
                
                float totalSizeOfOneShape = _StrokeWidth + _EmptyStrokeWidth;
                float totalSize = totalSizeOfOneShape * _NumberOfShape;
                float scalar = 1.0 / (totalSizeOfOneShape);

                float polySDF = PolygonSDF(flipScaleUV, _NumberOfVertices);

                finalFactor += Fill(polySDF, totalSize) * Fill( frac(polySDF * scalar), _StrokeWidth * scalar);

                float flipPolySDF = PolygonSDF(scaleUV, _NumberOfVertices);
                totalSizeOfOneShape = _RemoveStrokeWidth + _RemoveEmptyStrokeWidth;
                _NumberOfShape -= 1;
                totalSize = totalSizeOfOneShape * _NumberOfShape;
                scalar = 1.0 / (totalSizeOfOneShape);

                finalFactor -= Fill(flipPolySDF, totalSize) * Fill( frac(flipPolySDF * scalar), _RemoveStrokeWidth * scalar);



                resultColor = finalFactor;
                resultColor.a = 1.0;

                return resultColor;
            }
            ENDHLSL
        }
    }
}
