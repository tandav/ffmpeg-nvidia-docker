import requests
import subprocess
import dataclasses
import json


@dataclasses.dataclass
class BuildResult:
    tag: str
    returncode: int


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
    tag_prefix: str = 'tandav/ffmpeg',
    latest: bool = False,
) -> str:
    if latest:
        tag = f'{tag_prefix}:latest'
    else:
        tag = f'{tag_prefix}:cuda{base_image_tag}'
    cmd = ['docker', 'build', '--build-arg', f'BASE_IMAGE=nvidia/cuda:{base_image_tag}', '-t', tag, '.']
    print('building tag', tag)
    p = subprocess.run(cmd, env={'DOCKER_BUILDKIT': '1', 'BUILDKIT_PROGRESS': 'plain'})
    return BuildResult(tag=tag, returncode=p.returncode)


def push(tag: str) -> None:
    cmd = ['docker', 'push', tag]
    print('pushing tag', tag)
    subprocess.check_call(cmd)


def main():
    results = {}
    for i, base_image_tag in enumerate(base_image_tags()):
        result = build(base_image_tag)
        push(result.tag)
        results[base_image_tag] = result
        if i == 0:
            result = build(base_image_tag, latest=True)
            push(result.tag)
            results['latest'] = result
    
    with open('results.json', 'w') as f:
        json.dump({k: dataclasses.asdict(v) for k, v in results.items()}, f, indent=4)


if __name__ == '__main__':
    main()
