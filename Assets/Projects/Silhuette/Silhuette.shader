﻿// Tutorial: https://en.wikibooks.org/wiki/Cg_Programming/Unity/Silhouette_Enhancement
Shader "Ellioman/Silhouette"
{
	// What variables do we want sent in to the shader?
	Properties
	{
		_Color ("Color", Color) = (1, 1, 1, 0.5)
		_SilhuettePower ("Silhuette Power", Range(0, 3)) = 0.5
	}
	
	SubShader
	{
		// Draw after all opaque geometry has been drawn
		Tags
		{
			"Queue" = "Transparent"
		}
		
		Pass
		{
			// Don't occlude other objects
			ZWrite Off
			
			// Standard alpha blending
			Blend SrcAlpha OneMinusSrcAlpha
			
			CGPROGRAM 
				// Pragmas
				#pragma vertex vertexShader
				#pragma fragment fragmentShader
				
				// Helper functions
				#include "UnityCG.cginc"
				
				// User Defined Variables
				uniform float4 _Color;
				uniform float _SilhuettePower;
				
				// Base Input Structs
				struct VSInput
				{
					float4 vertex : POSITION;
					float3 normal : NORMAL;
				};
				struct VSOutput
				{
					float4 pos : SV_POSITION;
					float3 normal : TEXCOORD;
					float3 viewDir : TEXCOORD1;
				};
				
				// The Vertex Shader 
				VSOutput vertexShader(VSInput IN) 
				{
				// The direction to the viewer can be computed in the vertex shader as the vector
					// from the vertex position in world space to the camera position in world space
					VSOutput OUT;
					OUT.viewDir = normalize(_WorldSpaceCameraPos - mul(_Object2World, IN.vertex).xyz);
					OUT.normal = normalize(mul(float4(IN.normal, 0.0), _Object2World).xyz);
					OUT.pos = mul(UNITY_MATRIX_MVP, IN.vertex);
					return OUT;
				}
				
				// The Fragment Shader 
				float4 fragmentShader(VSOutput IN) : COLOR
				{
					float3 normalDirection = normalize(IN.normal);
					float3 viewDirection = normalize(IN.viewDir);
					float dotResults = pow(dot(viewDirection, normalDirection), _SilhuettePower);
					float newOpacity = min(1.0, _Color.a / abs(dotResults));
					return float4(_Color.rgb, newOpacity);
				}
			
			ENDCG
		}
	}
}