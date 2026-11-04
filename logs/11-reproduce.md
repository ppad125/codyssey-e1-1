# 11. 재현성 검증 (clone 후 README 절차 실행)

[← README로 돌아가기](../README.md)

평가자와 같은 조건을 만들기 위해 새 폴더에 저장소를 clone하고, README의 재현 절차를 그대로 실행했습니다.

## 1. 새 폴더에 clone

```console
$ mkdir clone_test
$ cd clone_test
$ git clone https://github.com/ppad125/codyssey-e1-1.git
Cloning into 'codyssey-e1-1'...
remote: Enumerating objects: 40, done.
remote: Counting objects: 100% (40/40), done.
remote: Compressing objects: 100% (30/30), done.
remote: Total 40 (delta 7), reused 37 (delta 4), pack-reused 0 (from 0)
Receiving objects: 100% (40/40), 248.13 KiB | 8.86 MiB/s, done.
Resolving deltas: 100% (7/7), done.
$ cd codyssey-e1-1
```

- 공개 저장소라 HTTPS 주소로 로그인 없이 받을 수 있었습니다.

## 2. 커스텀 이미지 빌드 + 포트 매핑

```console
$ docker build -t my-web:1.0 .
[+] Building 0.4s (7/7) FINISHED                                     docker:desktop-linux
 => [internal] load build definition from Dockerfile                                 0.0s
 => [internal] load metadata for docker.io/library/nginx:alpine                      0.2s
 => CACHED [1/2] FROM docker.io/library/nginx:alpine@sha256:785835ea65db...          0.0s
 => [2/2] COPY app/ /usr/share/nginx/html/                                           0.0s
 => exporting to image                                                               0.1s
 => => naming to docker.io/library/my-web:1.0                                        0.0s
$ docker run -d -p 8080:80 --name web-8080 my-web:1.0
d16787bcb6a3a452a38dc767b1d96fca3daacb07190b6b69dfd371e71f701c32
$ curl http://localhost:8080
<!doctype html>
<html lang="ko">
<head>
  <meta charset="utf-8">
  <title>My E1-1 Web</title>
</head>
<body>
  <h1>Hello, Codyssey!</h1>
  <p>Version: v2</p>
</body>
</html>
```

- 저장소에는 바인드 마운트 실습에서 수정한 `Version: v2`가 커밋되어 있어 v2가 출력되었습니다.

## 3. 바인드 마운트

```console
$ docker run -d -p 8082:80 --name web-bind -v "$(pwd)/app:/usr/share/nginx/html" nginx:alpine
0a00c1edfbf2861188fc035b89414fd967495d455185189cd1cc842b47da8872
$ curl http://localhost:8082
...
  <h1>Hello, Codyssey!</h1>
  <p>Version: v2</p>
...
```

## 4. 볼륨 영속성

```console
$ docker volume create mydata
mydata
$ docker run -d --name vol-test -v mydata:/data ubuntu:24.04 sleep infinity
330eff8f4378b31e9af41e3156bbb984d5a0aca14e9f1b01f673ae7c81324ee3
$ docker exec vol-test bash -c "echo hello-volume > /data/hello.txt"
$ docker rm -f vol-test
vol-test
$ docker run --rm -v mydata:/data ubuntu:24.04 cat /data/hello.txt   # → hello-volume
hello-volume
cat: '#': No such file or directory
cat: ''$'\342\206\222': No such file or directory
cat: hello-volume: No such file or directory
```

- 컨테이너 삭제 후에도 `hello-volume`이 출력되어 데이터 유지를 확인했습니다.
- 다만 당시 README의 줄 끝 주석 `# → hello-volume`이 zsh에서 주석으로 처리되지 않고 `cat`의 인자로 전달되어 오류 3줄이 함께 출력되었습니다.
- 이 문제를 README 트러블슈팅 [8-5](../README.md#8-5-재현-절차의-줄-끝-주석이-명령-인자로-처리됨-문서--zsh)에 정리하고, 재현 절차의 코드블록에서 주석을 모두 제거했습니다.

## 5. 보너스: Docker Compose

```console
$ WEB_PORT=9090 APP_ENV=prod docker compose up -d
[+] up 3/3
 ✔ Network codyssey-e1-1_default    Created
 ✔ Container codyssey-e1-1-web-1    Started
 ✔ Container codyssey-e1-1-client-1 Started
$ docker compose logs client
client-1  |   <p>Version: v2</p>
$ docker compose down
[+] down 3/3
 ✔ Container codyssey-e1-1-client-1 Removed
 ✔ Container codyssey-e1-1-web-1    Removed
 ✔ Network codyssey-e1-1_default    Removed
```

- clone한 폴더 이름(`codyssey-e1-1`)이 Compose 프로젝트 이름이 되어 컨테이너 이름이 `codyssey-e1-1-web-1`로 붙었습니다.

## 6. 정리

```console
$ docker rm -f web-8080 web-bind
web-8080
web-bind
$ docker volume rm mydata
mydata
```

## 검증 결과

| 단계 | 결과 |
|---|---|
| clone (HTTPS) | 성공 |
| 이미지 빌드 + 8080 접속 | 성공 |
| 바인드 마운트 8082 | 성공 |
| 볼륨 영속성 | 성공 (README 주석 문제 발견 → 수정) |
| Compose (9090, prod) | 성공 |
| 정리 | 성공 |
