# 03. Docker 설치 점검 및 기본 운영

[← README로 돌아가기](../README.md)

Docker 버전과 데몬 동작을 점검하고, 이미지·컨테이너 기본 명령과 attach/exec 차이를 실습했습니다.
같은 PC에서 사용 중인 다른 프로젝트의 컨테이너·이미지가 함께 출력된 부분은 생략(발췌)했습니다.

## 1. 설치 및 데몬 점검

```console
$ docker --version
Docker version 29.8.2, build 7fc2dff

$ docker info                            # Server 정보가 나오면 데몬 정상 동작 (발췌)
Client:
 Version:    29.8.2
 Context:    desktop-linux
 ...
Server:
 Containers: 8
  Running: 7
  Paused: 0
  Stopped: 1
 Images: 12
 Server Version: 29.8.2
 Storage Driver: overlayfs
 ...
 Kernel Version: 7.0.14-linuxkit
 Operating System: Docker Desktop
 OSType: linux
 Architecture: aarch64
 CPUs: 10
 Total Memory: 7.748GiB
 ...
```

## 2. 이미지 다운로드 · hello-world 실행

```console
$ docker pull hello-world
Using default tag: latest
latest: Pulling from library/hello-world
58dee6a49ef1: Pull complete
c3bdf82c34d1: Download complete
Digest: sha256:c567b231f65614688711a75f31518a064258a51d442117a3e771a3a8fdba78ef
Status: Downloaded newer image for hello-world:latest
docker.io/library/hello-world:latest

$ docker images                          # (발췌)
IMAGE                 ID             DISK USAGE   CONTENT SIZE
hello-world:latest    c567b231f656       22.6kB         10.3kB

$ docker run hello-world

Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    (arm64v8)
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.
...

$ docker ps -a                           # (발췌) 종료된 컨테이너까지 표시
CONTAINER ID   IMAGE         COMMAND    CREATED              STATUS                          NAMES
db3863921591   hello-world   "/hello"   About a minute ago   Exited (0) About a minute ago   blissful_maxwell
```

- hello-world는 메시지를 출력하고 바로 종료되어 `docker ps`에는 없고 `docker ps -a`에만 `Exited (0)`으로 보였습니다.
- `--name`을 지정하지 않아 `blissful_maxwell`이라는 랜덤 이름이 붙었습니다.

## 3. ubuntu 컨테이너 진입 후 명령 실행

```console
$ docker run -it --name my-ubuntu ubuntu:24.04 bash
Unable to find image 'ubuntu:24.04' locally
24.04: Pulling from library/ubuntu
e2d2bb84d022: Pull complete
2238dc1b4376: Download complete
Digest: sha256:fe81560990fae86dc4743202b2cb4d3df98d0bcf949173cecef15ce1127ef852
Status: Downloaded newer image for ubuntu:24.04
root@5034415970f6:/# ls
bin  boot  dev  etc  home  lib  media  mnt  opt  proc  root  run  sbin  srv  sys  tmp  usr  var
root@5034415970f6:/# echo "Hello from container"
Hello from container
root@5034415970f6:/# cat /etc/os-release
PRETTY_NAME="Ubuntu 24.04.5 LTS"
NAME="Ubuntu"
VERSION_ID="24.04"
VERSION="24.04.5 LTS (Noble Numbat)"
VERSION_CODENAME=noble
ID=ubuntu
ID_LIKE=debian
...
root@5034415970f6:/# exit
exit

$ docker ps -a --filter name=my-ubuntu
CONTAINER ID   IMAGE          COMMAND   CREATED         STATUS                          PORTS     NAMES
5034415970f6   ubuntu:24.04   "bash"    2 minutes ago   Exited (0) About a minute ago             my-ubuntu
```

- 프롬프트가 `root@5034415970f6`(컨테이너 ID)로 바뀌어 맥과 격리된 우분투 환경에 들어간 것을 확인했습니다.
- 메인 프로세스인 `bash`를 `exit`로 종료하자 컨테이너도 `Exited (0)`으로 종료되었습니다.

## 4. attach vs exec 차이 관찰

```console
$ docker start my-ubuntu                 # 종료된 컨테이너 다시 시작
my-ubuntu
$ docker ps --filter name=my-ubuntu
CONTAINER ID   IMAGE          COMMAND   CREATED       STATUS         PORTS     NAMES
5034415970f6   ubuntu:24.04   "bash"    2 hours ago   Up 8 seconds             my-ubuntu

$ docker exec -it my-ubuntu bash         # exec: 새 bash를 추가로 실행해 접속
root@5034415970f6:/# echo  "I am a guest (exec)"
I am a guest (exec)
root@5034415970f6:/# exit
exit
$ docker ps                              # exec 종료 후에도 컨테이너 유지
CONTAINER ID   IMAGE          COMMAND   CREATED       STATUS              PORTS     NAMES
5034415970f6   ubuntu:24.04   "bash"    2 hours ago   Up About a minute             my-ubuntu

$ docker attach my-ubuntu                # attach: 메인 프로세스(bash)에 연결
root@5034415970f6:/# echo "I am the owner (attach)"
I am the owner (attach)
root@5034415970f6:/# exit
exit
$ docker ps                              # attach 후 exit → 컨테이너 종료
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
```

| | `docker exec` | `docker attach` |
|---|---|---|
| 연결 대상 | 새 프로세스를 추가로 실행 | 메인 프로세스(bash)에 연결 |
| `exit` 후 | 컨테이너 유지 (`Up`) | 컨테이너 종료 |

## 5. 백그라운드 실행 · 로그 · 리소스 · 중지

```console
$ docker run -d --name my-logger ubuntu:24.04 bash -c "while true; do echo tick \$(date +%T); sleep 2; done"
4ff8760d6a6baa6e2bd8b5379eb17b33cfdba37250fcc28aed8d03378f2730d7
$ docker ps
CONTAINER ID   IMAGE          COMMAND                   CREATED          STATUS          PORTS     NAMES
4ff8760d6a6b   ubuntu:24.04   "bash -c 'while true…"   34 seconds ago   Up 34 seconds             my-logger

$ docker logs my-logger                  # 로그 확인 (발췌)
tick 12:48:07
tick 12:48:09
tick 12:48:11
...
tick 12:49:11
tick 12:49:13

$ docker stats --no-stream my-logger     # 리소스 확인
CONTAINER ID   NAME        CPU %     MEM USAGE / LIMIT     MEM %     NET I/O         BLOCK I/O     PIDS
4ff8760d6a6b   my-logger   0.47%     6.398MiB / 7.748GiB   0.08%     1.75kB / 126B   4.44MB / 0B   2

$ docker stop my-logger                  # 중지
my-logger
$ docker ps
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
```

- `-d`로 백그라운드 실행하자 컨테이너 ID만 출력되고 바로 맥 프롬프트로 돌아왔습니다.
- 로그 시간이 맥보다 9시간 느린 것은 컨테이너의 시간대가 UTC이기 때문입니다.
- PIDS 2는 메인 `bash`와 반복 중인 `sleep` 프로세스입니다.
