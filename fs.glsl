#version 300 es
precision mediump float;
in vec3 glPosition;
uniform float reflection;
uniform float fb; // вперёд назад
uniform float rl; // вправо влево
uniform float ud; // вверх вниз
uniform float y;  // вправо влево
uniform float x;  // вверх вниз

out vec4 FragColor;


#define EPSILON 0.001
#define BIG 1000000.0

const int DIFFUSE = 1;
const int REFLECTION = 2;
const int REFRACTION = 3;
const int DIFFUSE_REFLECTION = 1;
const int MIRROR_REFLECTION = 2;

struct SLight{
    vec3 Position;
};
struct SMaterial{
    //diffuse color
    vec3 Color;
    // ambient, diffuse and specular coeffs
    vec4 LightCoeffs;
    // 0 - non-reflection, 1 - mirror
    float ReflectionCoef;
    float RefractionCoef;
    int MaterialType;
};
struct SSphere{
    vec3 Center;
    float Radius;
    int MaterialIdx;
};
struct STriangle{
    vec3 v1;
    vec3 v2;
    vec3 v3;
    int MaterialIdx;
};
struct SIntersection{
    float Time;
    vec3 Point;
    vec3 Normal;
    vec3 Color;
    // ambient, diffuse and specular coeffs
    vec4 LightCoeffs;
    // 0 - non-reflection, 1 - mirror
    float ReflectionCoef;
    float RefractionCoef;
    int MaterialType;
};
struct SCamera{
    vec3 Position;
    vec3 View;
    vec3 Up;
    vec3 Side;
    // отношение сторон выходного изображения
    vec2 Scale;
};
struct SRay{
    vec3 Origin;
    vec3 Direction;
};
struct STracingRay{
    SRay ray;
    float contribution;
    int depth;
};
struct stack{
    STracingRay data[50];
    int last;
};
stack st;
SLight light;
SMaterial materials[9];
STriangle triangles[12];
SSphere spheres[2];
void createStack(){
    stack st;
    st.last=-1;
}
void pushRay(STracingRay ad){
    st.last++;
    st.data[st.last]=ad;
}
bool stackisEmpty(){
    if(st.last==-1) return true;
    return false;
}
STracingRay popRay(){
    return st.data[st.last--];
}
void initializeDefaultLightMaterials(){
    //** LIGHT **//
    light.Position = vec3(1.0, 2.0, 1.0);
    /** MATERIALS **/
    vec4 lightCoefs = vec4(0.4,0.9,0.0,512.0);
    materials[0].Color = vec3(0.5, .3, 0.3); // цвет зелёный
    materials[0].LightCoeffs = vec4(lightCoefs);
    materials[0].ReflectionCoef = 0.7;
    materials[0].RefractionCoef = 1.0;
    materials[0].MaterialType = 2;

    materials[1].Color = vec3(0.0, 0.0, 1.0);
    materials[1].LightCoeffs = vec4(lightCoefs);
    materials[1].ReflectionCoef = 0.5;
    materials[1].RefractionCoef = 1.0;
    materials[1].MaterialType = 2;

    materials[2].Color = vec3(.9, .9, 0.0); // зеркало
    materials[2].LightCoeffs = vec4(lightCoefs);
    materials[2].ReflectionCoef = 0.9;
    materials[2].RefractionCoef = 0.0;
    materials[2].MaterialType = 1;
    
    materials[3].Color = vec3(0.0, 1.0, 1.0);
    materials[3].LightCoeffs = vec4(lightCoefs);
    materials[3].ReflectionCoef = reflection;
    materials[3].RefractionCoef = 0.0;
    materials[3].MaterialType = 2;

    materials[4].Color = vec3(1.0, 0.0, 1.0);
    materials[4].LightCoeffs = vec4(lightCoefs);
    materials[4].ReflectionCoef = 0.0;
    materials[4].RefractionCoef = 1.0;
    materials[4].MaterialType = DIFFUSE;

    materials[5].Color = vec3(.3, .8, 0.1);
    materials[5].LightCoeffs = vec4(lightCoefs);
    materials[5].ReflectionCoef = 0.0;
    materials[5].RefractionCoef = 1.0;
    materials[5].MaterialType = DIFFUSE;

    materials[6].Color = vec3(0.3, 0.6, .4);
    materials[6].LightCoeffs = vec4(lightCoefs);
    materials[6].ReflectionCoef = 0.0;
    materials[6].RefractionCoef = 1.0;
    materials[6].MaterialType = DIFFUSE;

    materials[7].Color = vec3(0.4, 0.3, .6);
    materials[7].LightCoeffs = vec4(lightCoefs);
    materials[7].ReflectionCoef = 0.0;
    materials[7].RefractionCoef = 1.0;
    materials[7].MaterialType = DIFFUSE;

    materials[8].Color = vec3(0.4, 0.3, .6);
    materials[8].LightCoeffs = vec4(lightCoefs);
    materials[8].ReflectionCoef = .4;
    materials[8].RefractionCoef = 1.0;
    materials[8].MaterialType = 2;
}
vec3 Phong (SCamera uCamera, SIntersection intersect, SLight currLight, float shadow){
    vec3 light = normalize ( currLight.Position - intersect.Point );
    float diffuse = max(dot(light, intersect.Normal), 0.0);
    vec3 view = normalize(uCamera.Position - intersect.Point);
    vec3 reflected= reflect( -view, intersect.Normal );
    float specular = pow(max(dot(reflected, light), 0.0), intersect.LightCoeffs.w);
    return intersect.LightCoeffs.x * intersect.Color + intersect.LightCoeffs.y * diffuse * intersect.Color * shadow +intersect.LightCoeffs.z * specular;
}
void initializeDefaultScene(){
    /** TRIANGLES **/
    /* left wall */
    triangles[0].v1 = vec3(-5.0,-5.0,-5.0);     //0.5
    triangles[0].v2 = vec3(-5.0, 5.0, 5.0);
    triangles[0].v3 = vec3(-5.0, 5.0,-5.0);
    triangles[0].MaterialIdx = 2;
    triangles[1].v1 = vec3(-5.0,-5.0,-5.0);     //1
    triangles[1].v2 = vec3(-5.0,-5.0, 5.0);
    triangles[1].v3 = vec3(-5.0, 5.0, 5.0);
    triangles[1].MaterialIdx = 2;
    /* back wall */
    triangles[2].v1 = vec3(-5.0,-5.0, 5.0);     //1.5
    triangles[2].v2 = vec3( 5.0,-5.0, 5.0);
    triangles[2].v3 = vec3(-5.0, 5.0, 5.0);
    triangles[2].MaterialIdx = 3;
    triangles[3].v1 = vec3( 5.0, 5.0, 5.0);     //2
    triangles[3].v2 = vec3(-5.0, 5.0, 5.0);
    triangles[3].v3 = vec3( 5.0,-5.0, 5.0);
    triangles[3].MaterialIdx = 3;
    
    triangles[4].v1 = vec3( 5.0, 5.0, 5.0);     //2.5
    triangles[4].v2 = vec3( 5.0,-5.0, 5.0);
    triangles[4].v3 = vec3( 5.0, -5.0, -5.0);
    triangles[4].MaterialIdx = 4;
    triangles[5].v1 = vec3(5.0,-5.0, -5.0);     //3
    triangles[5].v2 = vec3(5.0, 5.0, -5.0);
    triangles[5].v3 = vec3(5.0, 5.0,  5.0);
    triangles[5].MaterialIdx = 4;
    /* back wall */
    triangles[6].v1 = vec3( 5.0, 5.0, 5.0);     //3.5
    triangles[6].v2 = vec3( 5.0, 5.0,-5.0);
    triangles[6].v3 = vec3(-5.0, 5.0, 5.0);
    triangles[6].MaterialIdx = 5;
    triangles[7].v1 = vec3(-5.0, 5.0, 5.0);     //4
    triangles[7].v2 = vec3( 5.0, 5.0, -5.0);
    triangles[7].v3 = vec3( -5.0, 5.0, -5.0);
    triangles[7].MaterialIdx = 5;

    triangles[8].v1 = vec3(5.0,-5.0,-5.0);     //4.5
    triangles[8].v2 = vec3(5.0, -5.0, 5.0);
    triangles[8].v3 = vec3(-5.0, -5.0,5.0);
    triangles[8].MaterialIdx = 6;
    triangles[9].v1 = vec3(-5.0,-5.0,5.0);     //5
    triangles[9].v2 = vec3(-5.0,-5.0, -5.0);
    triangles[9].v3 = vec3(5.0, -5.0, -5.0);
    triangles[9].MaterialIdx = 6;
    // /* back wall */
    triangles[10].v1 = vec3( 5.0, 5.0, -5.0);     //5.5
    triangles[10].v2 = vec3( 5.0,-5.0,-5.0);
    triangles[10].v3 = vec3(-5.0, 5.0, -5.0);
    triangles[10].MaterialIdx = 7;
    triangles[11].v1 = vec3( -5.0, 5.0, -5.0);     //6
    triangles[11].v2 = vec3(5.0, -5.0, -5.0);
    triangles[11].v3 = vec3( -5.0,-5.0, -5.0);
    triangles[11].MaterialIdx = 7;

    /* Самостоятельно добавьте треугольники так, чтобы получился куб */
    /** SPHERES **/
    spheres[0].Center = vec3(1.0,-1.0,-2.0);
    spheres[0].Radius = .5;
    spheres[0].MaterialIdx = 8;
    spheres[1].Center = vec3(2.0,1.0,2.0);
    spheres[1].Radius = 1.0;
    spheres[1].MaterialIdx = 0;
}
SRay GenerateRay ( SCamera uCamera ){
    vec2 coords = glPosition.xy * uCamera.Scale;
    vec3 direction = uCamera.View + uCamera.Side * coords.x + uCamera.Up * coords.y;
    return SRay ( uCamera.Position, normalize(direction) );
}
SCamera initializeDefaultCamera(){
    SCamera camera;
    //** CAMERA **//
    camera.Position = vec3(rl, ud, fb);
    camera.View = vec3(0.0, 0.0, 1.0 );
    camera.Up = vec3(0.0, 1.0, 0.0);
    camera.Side = vec3(1.0, 0.0, 0.0);
    camera.Scale = vec2(1.0, 1.0);
    return camera;
}
bool IntersectSphere (SSphere sphere, SRay ray, float start, float final, out float time ){
    ray.Origin = ray.Origin - sphere.Center;
    float A = dot ( ray.Direction, ray.Direction );
    float B = dot ( ray.Direction, ray.Origin );
    float C = dot ( ray.Origin, ray.Origin ) - sphere.Radius * sphere.Radius;
    float D = B * B - A * C;
    if ( D > 0.0 ){
        D = sqrt ( D );
        //time = min ( max ( 0.0, ( -B - D ) / A ), ( -B + D ) / A );
        float t1 = ( -B - D ) / A;
        float t2 = ( -B + D ) / A;
        if((t1 < 0.0) && (t2 < 0.0)){
            return false;
        }
        if(min(t1, t2) < 0.0){
            time = max(t1,t2);
            return true;
        }

        time = min(t1, t2);

        return true;
    }
    return false;
}
bool IntersectTriangle (SRay ray, vec3 v1, vec3 v2, vec3 v3, out float time ){
    // Compute the intersection of ray with a triangle using geometric solution
    // Input: // points v0, v1, v2 are the triangle's vertices
    // rayOrig and rayDir are the ray's origin (point) and the ray's direction
    // Return: // return true is the ray intersects the triangle, false otherwise
    // bool intersectTriangle(point v0, point v1, point v2, point rayOrig, vector rayDir) {
    // compute plane's normal vector
    time = -1.0;
    vec3 A = v2 - v1;
    vec3 B = v3 - v1;
    // no need to normalize vector
    vec3 N = cross(A, B);
    // N
    // // Step 1: finding P

    // // check if ray and plane are parallel ?
    float NdotRayDirection = dot(N, ray.Direction);
    if (abs(NdotRayDirection) < 0.001)
        return false;
    // they are parallel so they don't intersect !
    // compute d parameter using equation 2
    float d = dot(N, v1);
    // compute t (equation 3)
    float t = -(dot(N, ray.Origin) - d) / NdotRayDirection;
    // check if the triangle is in behind the ray
    if (t < 0.0)
        return false;
    // the triangle is behind
    // compute the intersection point using equation 1
    vec3 P = ray.Origin + t * ray.Direction;
    // // Step 2: inside-outside test //
    vec3 C;
    // vector perpendicular to triangle's plane
    // edge 0
    vec3 edge1 = v2 - v1;
    vec3 VP1 = P - v1;
    C = cross(edge1, VP1);
    if (dot(N, C) < 0.0)
        return false;
    // P is on the right side
    // edge 1
    vec3 edge2 = v3 - v2;
    vec3 VP2 = P - v2;
    C = cross(edge2, VP2);
    if (dot(N, C) < 0.0)
        return false;
    // P is on the right side
    // edge 2
    vec3 edge3 = v1 - v3;
    vec3 VP3 = P - v3;
    C = cross(edge3, VP3);
    if (dot(N, C) < 0.0)
        return false;
    // P is on the right side;
    time = t;
        return true;
    // this ray hits the triangle
}
bool Raytrace( SRay ray, SSphere spheres[2], STriangle triangles[12], SMaterial materials[9], float start, float final,inout SIntersection intersect ){
	bool result = false;
	float test = start;
	intersect.Time = final;
	//calculate intersect with spheres
	for(int i = 0; i < 2; i++)
	{
		SSphere sphere = spheres[i];
		if( IntersectSphere (sphere, ray, start, final, test ) && test < intersect.Time )
		{
			intersect.Time = test;
			intersect.Point = ray.Origin + ray.Direction * test;
			intersect.Normal = normalize ( intersect.Point - sphere.Center );
			intersect.Color = materials[sphere.MaterialIdx].Color;
			intersect.LightCoeffs =  materials[sphere.MaterialIdx].LightCoeffs;
			intersect.ReflectionCoef = materials[sphere.MaterialIdx].ReflectionCoef;
			intersect.RefractionCoef =  materials[sphere.MaterialIdx].RefractionCoef;
			intersect.MaterialType = materials[sphere.MaterialIdx].MaterialType;
			result = true;
		}
	}
	//calculate intersect with triangles
	for(int i = 0; i < 12; i++)
	{
		STriangle triangle = triangles[i];
		if(IntersectTriangle(ray, triangle.v1, triangle.v2, triangle.v3, test) && test < intersect.Time)
		{
			intersect.Time = test;
			intersect.Point = ray.Origin + ray.Direction * test;
			intersect.Normal =
			normalize(cross(triangle.v1 - triangle.v2, triangle.v3 - triangle.v2));
			intersect.Color = materials[triangle.MaterialIdx].Color;
			intersect.LightCoeffs =  materials[triangle.MaterialIdx].LightCoeffs;
			intersect.ReflectionCoef = materials[triangle.MaterialIdx].ReflectionCoef;
			intersect.RefractionCoef =  materials[triangle.MaterialIdx].RefractionCoef;
			intersect.MaterialType = materials[triangle.MaterialIdx].MaterialType;
			result = true;
		}
	}
	return result;
}
float Shadow(SLight currLight, SIntersection intersect){
	// Point is lighted
	float shadowing = 1.0;
	// Vector to the light source
	vec3 direction = normalize(currLight.Position - intersect.Point);
	// Distance to the light source
	float distanceLight = distance(currLight.Position, intersect.Point);
	// Generation shadow ray for this light source
	SRay shadowRay = SRay(intersect.Point + direction * 0.001, direction);
	// ...test intersection this ray with each scene object
	SIntersection shadowIntersect;
	shadowIntersect.Time = 1000000.0;
	// trace ray from shadow ray begining to light source position
	if(Raytrace(shadowRay, spheres, triangles, materials, 0.0, distanceLight, shadowIntersect))
	{
		// this light source is invisible in the intercection point
		shadowing = 0.0;
	}
	return shadowing;
}
void main(void) {
    SCamera uCamera = initializeDefaultCamera();
    initializeDefaultLightMaterials();
    SRay ray = GenerateRay( uCamera);
    vec3 resultColor = vec3(0,0,0);
    initializeDefaultScene();
    createStack();
    STracingRay trRay = STracingRay(ray, 1.0, 0);
    pushRay(trRay);
    while(!stackisEmpty()){
        STracingRay trRay = popRay();
        ray = trRay.ray;
        SIntersection intersect;
        intersect.Time = BIG;
        float start = 0.0;
        float final = BIG;
        if (Raytrace(ray, spheres, triangles, materials, start, final, intersect))
        {

            switch(intersect.MaterialType)
            {
                case DIFFUSE_REFLECTION:
                {
                    float shadowing = Shadow(light, intersect);
                    resultColor += trRay.contribution * Phong (uCamera, intersect, light, shadowing );
                    break;
                }
                case MIRROR_REFLECTION:
                {
                    float contribution;
                    if(intersect.ReflectionCoef < 1.0)
                    {
                        contribution = trRay.contribution * (1.0 - intersect.ReflectionCoef);
                        float shadowing = Shadow(light, intersect);
                        resultColor += contribution * Phong(uCamera, intersect, light, shadowing);
                    }
                    vec3 reflectDirection = reflect(ray.Direction, intersect.Normal);
                    // creare reflection ray
                    contribution = trRay.contribution * intersect.ReflectionCoef;
                    STracingRay reflectRay = STracingRay(
                    SRay(intersect.Point + reflectDirection * EPSILON,
                    reflectDirection),
                    contribution, trRay.depth + 1);
                    pushRay(reflectRay);
                    break;
                    // default:{
                    //     FragColor = vec4 (resultColor, 1.0);
                    //     break;
                    // }
                } // switch 
                    

            } // if (Raytrace(ray, start, final, intersect))
        } // while(!isEmpty())
    }
    FragColor = vec4 (resultColor, 1.0);

}