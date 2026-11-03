# 07. Docker 볼륨 영속성

[← README로 돌아가기](../README.md)

Docker 볼륨 `mydata`를 만들어 컨테이너에 연결하고, 컨테이너를 삭제한 뒤에도 데이터가 남아 있는지 확인했습니다.

## 1. 볼륨 생성 및 연결

```console
$ docker volume create mydata
mydata
$ docker volume ls                       # (다른 프로젝트 볼륨 포함)
DRIVER    VOLUME NAME
local     02c9a35b1819c2aabe42ca498eb37480899761e03e647ba2bc2359de84ef77d2
local     336d0d58a9aa5ae653a7ea3bc71ff96c40856b66b4d3e9b88de11a5c8534b342
local     c3f474630d98a2601075d3909cfc37c97f9384fc2a68f8c2915806a2dbf95162
local     firecrawl_fdb-cluster-file
local     firecrawl_fdb-data
local     mydata

$ docker run -d --name vol-test -v mydata:/data ubuntu:24.04 sleep infinity
2552bb5174a9d31c2a6a2b133ca54b25574a48671b664ca92010b01c5b7ea11d
```

- `-v 볼륨이름:컨테이너경로`로 볼륨 `mydata`를 컨테이너의 `/data`에 연결했습니다.
- `sleep infinity`는 컨테이너가 종료되지 않도록 계속 실행되는 메인 프로세스입니다.

## 2. 데이터 저장 (삭제 전)

```console
$ docker exec vol-test bash -c "echo hello-volume > /data/hello.txt"
$ docker exec vol-test cat /data/hello.txt
hello-volume
```

## 3. 컨테이너 삭제

```console
$ docker rm -f vol-test
vol-test
$ docker ps -a --filter name=vol-test    # 컨테이너가 없음
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
```

## 4. 새 컨테이너에서 확인 (삭제 후)

```console
$ docker run -d --name vol-test2 -v mydata:/data ubuntu:24.04 sleep infinity
39646cf0729c584c156bf1a737d7b4b33d0841dc83a046d045ec0b45727571e1
$ docker exec vol-test2 cat /data/hello.txt
hello-volume
```

| 시점 | 컨테이너 | `/data/hello.txt` |
|---|---|---|
| 삭제 전 | vol-test | `hello-volume` |
| 삭제 후 | vol-test2 (새 컨테이너) | `hello-volume` (유지) |

- 데이터가 컨테이너가 아니라 볼륨에 저장되어, 컨테이너를 삭제해도 남아 있었습니다.
