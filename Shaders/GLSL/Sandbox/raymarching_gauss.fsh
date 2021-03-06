#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 resolution;
uniform vec2 mouse;
uniform float time;

float sphericalGaussian(vec3 ip, vec3 n, float eta, float mu) {
	// eta: max radius, mu: prove height
	return mu * exp(eta * (dot(ip, n) - 1.0));
}

float density(vec3 p) {
	vec3 ip = normalize(p);
	float r = dot(p, ip);
	
	float g = 0.0;
	/*
	g += sphericalGaussian(ip, vec3(0.0, 1.0, 0.0), 5.0, 1.0);
	g += sphericalGaussian(ip, vec3(0.0, 1.0, 0.0), 0.2, 0.25);
	g += sphericalGaussian(ip, vec3(0.0, 1.0, 0.0), 100.0, 0.5);
	*/
	
	g += sphericalGaussian(ip, vec3(0.0, 1.0, 0.0), 1.0 + (1.0 + sin(time)) * 10.0, 1.0);
	g += sphericalGaussian(ip, normalize(vec3(sin(time), cos(time*2.3), 0.2)), 1.0 + (1.0 + sin(time * 2.1)) * 3.0, 0.75);
	g += sphericalGaussian(ip, normalize(vec3(-sin(time*1.7), cos(time*5.1), -0.2)), 0.1 + (1.0 + sin(time * 0.8)) * 2.0, 0.5);
	
	return 1.0 / (1.0 + pow(r / g, 2.0)); // density
	//return r - g; // distance
}

vec3 normal(vec3 p) {
	//const float EPS = 0.01;
	const vec3 ESP = vec3(0.01, 0.0, 0.0);
	vec3 norm;
	norm.x = density(p - ESP) - density(p + ESP);
	norm.y = density(p - ESP.zxy) - density(p + ESP.zxy);
	norm.z = density(p - ESP.yzx) - density(p + ESP.yzx);
	return normalize(norm);
}

void main(void) {
	vec2 screen = (gl_FragCoord.xy * 2.0 - resolution) / resolution.yy;
	
	vec3 rgb = vec3(0.0);
	
	/*
	float d = density(vec3(screen, 0.0));
	rgb = vec3(d, (d > 0.5)? 0.25:0.0, abs(d));
	*/
	
	vec3 dir = normalize(vec3(screen, -4.0));
	vec3 p = vec3(0.0, 0.0, 8.0) + dir * 6.0;
	vec3 pp = p;
	
	const float THRESHOULD = 0.5;
	const float STEP = 0.2;
	for(int i = 0; i < 16; i++) {
		p += dir * STEP;
		float d = density(p);
		if(d > THRESHOULD) {
			/*
			// simple substep
			p = pp;
			for(int j = 0; j < 8; j++) {
				p += dir * STEP * 0.125;
				d = density(p);
				if(d > THRESHOULD) break;
			}
			*/
			
			// midpoint
			vec3 np = p;
			for(int j = 0; j < 8; j++) {
				if(abs(d - THRESHOULD) < 0.0001) break;
				p = (pp + np) * 0.5;
				d = density(p);
				if(d > THRESHOULD) {
					np = p;
				} else {
					pp = p;
				}
			}
			
			//rgb = normal(p) * 0.5 + 0.5;
			rgb = vec3(max(dot(normal(p), vec3(0.577)), 0.0) * 0.8 + 0.2);
			break;
		}
		pp = p;
	}
	
	gl_FragColor = vec4(rgb, 1.0);
	//gl_FragColor = max(vec4(screen, 0.0, 1.0), vec4(0.0, -screen, 1.0));
}
