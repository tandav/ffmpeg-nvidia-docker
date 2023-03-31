import requests
import subprocess
import json


def dockerhub_image_tags(image: str) -> list[str]:
    """get all tags of an image on dockerhub"""
    tags = []
    url = f'https://hub.docker.com/v2/repositories/{image}/tags'
    r = requests.get(url, params={'page_size': 100, 'page': 1}).json()
    while True:
        tags += r['results']
        url = r['next']
        if url is None:
            break
        print(url)
        r = requests.get(url).json()
    return tags


def base_image_tags() -> list[str]:
    """get all tags of base images"""
    image = 'nvidia/cuda'
    tags = dockerhub_image_tags(image)
    tags = [tag['name'] for tag in tags if 'cudnn8-devel-ubuntu22.04' in tag['name']]
    return tags


def build(
    base_image_tag: str,
    image: str,
) -> int:
    cmd = ['docker', 'build', '--build-arg', f'BASE_IMAGE=nvidia/cuda:{base_image_tag}', '-t', image, '.']
    print('building image, cmd:', cmd)
    p = subprocess.run(cmd, env={'DOCKER_BUILDKIT': '1', 'BUILDKIT_PROGRESS': 'plain'})
    return p.returncode


def tag_and_push(image: str, tag: str) -> None:
    print('tag and push', f'{image}:{tag}')
    subprocess.check_call(['docker', 'tag', image, f'{image}:{tag}'])
    subprocess.check_call(['docker', 'push', f'{image}:{tag}'])


def main():
    IMAGE = 'tandav/ffmpeg-nvidia'

    results = {}
    for i, base_image_tag in enumerate(base_image_tags()):
        results[base_image_tag] = build(base_image_tag, IMAGE)
        tag_and_push(IMAGE, f'cuda{base_image_tag}')
        if i == 0:
            tag_and_push(IMAGE, 'latest')
    
    with open('results.json', 'w') as f:
        json.dump(results, f, indent=4)


if __name__ == '__main__':
    main()
