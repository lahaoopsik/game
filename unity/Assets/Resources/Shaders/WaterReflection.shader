Shader "SunnyValley/WaterReflection" {
 Properties {[PerRendererData] _MainTex("Sprite",2D)="white"{} }
 SubShader {Tags{"Queue"="Transparent" "RenderType"="Transparent"} Cull Off ZWrite Off Blend SrcAlpha OneMinusSrcAlpha
 Pass {CGPROGRAM
 #pragma vertex vert
 #pragma fragment frag
 #include "UnityCG.cginc"
 sampler2D _MainTex,_ValleyTerrainMap;float4 _MainTex_TexelSize,_ValleyMapSize,_ReflectAnchor,_ValleyAmbient;
 struct a{float4 vertex:POSITION;float2 uv:TEXCOORD0;};struct v{float4 pos:SV_POSITION;float2 uv:TEXCOORD0;float2 world:TEXCOORD1;};
 v vert(a i){v o;o.pos=UnityObjectToClipPos(i.vertex);o.uv=i.uv;o.world=mul(unity_ObjectToWorld,i.vertex).xy;return o;}
 fixed4 frag(v i):SV_Target{float2 p=i.world*float2(100,-100);p.y-=16;float2 mapUV=(floor(p/48)+.5)/_ValleyMapSize.zw;mapUV.y=1-mapUV.y;clip(tex2D(_ValleyTerrainMap,mapUV).r-.5);float2 uv=i.uv;float row=floor(p.y/4);uv.x+=floor(sin(row*.8+floor(_Time.y*7)*.3)*2)*_MainTex_TexelSize.x*2;fixed4 c=tex2D(_MainTex,uv);float fade=saturate(1-abs(i.world.y-_ReflectAnchor.y)/max(.1,_ReflectAnchor.z));c.rgb=lerp(c.rgb*_ValleyAmbient.rgb,float3(.19,.38,.52),.35);c.a*=fade*.32*(.8+.2*sin(row+_Time.y));return c;}
 ENDCG}
 }
}
