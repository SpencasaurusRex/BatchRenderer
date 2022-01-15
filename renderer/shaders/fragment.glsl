#version 330 core
out vec4 FragColor;
in vec4 vertexColor;
in vec2 vertexUV;
uniform sampler2D texture;
uniform float time;
uniform float blend;

void main()
{
	FragColor = texture(texture, vertexUV)
}