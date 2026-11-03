# 04. Dockerfile 커스텀 이미지

[← README로 돌아가기](../README.md)

공식 `nginx:alpine` 이미지를 베이스로, 직접 작성한 웹페이지를 넣은 커스텀 이미지 `my-web:1.0`을 만들었습니다.
(방식 (A): 웹 서버 베이스 이미지 + 정적 콘텐츠 교체)

## 1. 웹페이지 작성 (`app/index.html`)

```console
$ cd ~/Codyssey/e1-1
$ mkdir app
$ nano app/index.html
$ cat app/index.html
<!doctype html>
<html lang="ko">
<head>
  <meta charset="utf-8">
  <title>My E1-1 Web</title>
</head>
<body>
  <h1>Hello, Codyssey!</h1>
  <p>Version: v1</p>
</body>
</html>
```

> 이후 바인드 마운트 실습에서 `Version: v1`을 `v2`로 수정했습니다. ([06-bind-mount.md](06-bind-mount.md))

## 2. Dockerfile 작성

```console
$ nano Dockerfile
$ cat Dockerfile
# 베이스 이미지: 공식 nginx 웹서버 (가벼운 alpine 리눅스 버전)
FROM nginx:alpine

# [커스텀 1] 이미지 정보 기록
LABEL org.opencontainers.image.title="my-e1-1-web"

# [커스텀 2] 환경 변수 설정
ENV APP_ENV=dev

# [커스텀 3] 기본 페이지를 내 웹페이지로 교체
COPY app/ /usr/share/nginx/html/

# 컨테이너가 사용하는 포트 표시
EXPOSE 80
```

| 커스텀 포인트 | 목적 |
|---|---|
| `LABEL` | 이미지 이름·용도를 기록해 관리하기 쉽게 함 |
| `ENV APP_ENV=dev` | 실행 환경(dev)을 코드와 분리해 설정 |
| `COPY app/ ...` | nginx 기본 환영 페이지를 직접 만든 페이지로 교체 |

## 3. 이미지 빌드

```console
$ docker build -t my-web:1.0 .
[+] Building 1.0s (7/7) FINISHED                                     docker:desktop-linux
 => [internal] load build definition from Dockerfile                                 0.0s
 => => transferring dockerfile: 438B                                                 0.0s
 => [internal] load metadata for docker.io/library/nginx:alpine                      0.9s
 => [internal] load .dockerignore                                                    0.0s
 => => transferring context: 2B                                                      0.0s
 => [internal] load build context                                                    0.0s
 => => transferring context: 59B                                                     0.0s
 => [1/2] FROM docker.io/library/nginx:alpine@sha256:785835ea65db...                 0.0s
 => CACHED [2/2] COPY app/ /usr/share/nginx/html/                                    0.0s
 => exporting to image                                                               0.0s
 => => naming to docker.io/library/my-web:1.0                                        0.0s
 => => unpacking to docker.io/library/my-web:1.0                                     0.0s

$ docker images my-web
IMAGE        ID             DISK USAGE   CONTENT SIZE   EXTRA
my-web:1.0   dd61c6790978       93.2MB         26.3MB
```

- Dockerfile의 `FROM`과 `COPY`가 `[1/2]`, `[2/2]` 단계로 실행되었습니다.
- 끝의 `.`은 현재 폴더를 빌드 재료(컨텍스트)로 사용한다는 뜻입니다.

## 실수와 수정 기록

### 이미지 태그의 콜론(`:`) 누락

```console
$ docker build -t my-web1.0 .
...
 => => naming to docker.io/library/my-web1.0:latest

$ docker rmi my-web1.0
Untagged: my-web1.0:latest
Deleted: sha256:b25a15eb6fa711fe5d806faf719c892b50fc96d3c22f8dfc3d53ca3b2423742f
```

- `:`가 빠져 `my-web1.0` 전체가 이름이 되고, 태그는 기본값 `latest`가 붙었습니다.
- 잘못 만든 이미지를 `docker rmi`로 지우고 `docker build -t my-web:1.0 .`로 다시 빌드했습니다.
