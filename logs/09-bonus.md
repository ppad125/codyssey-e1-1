# 09. 보너스: Docker Compose · SSH 키

[← README로 돌아가기](../README.md)

## B1. Compose 기초: 단일 서비스

`docker run -d -p 8080:80 my-web:1.0` 명령을 `docker-compose.yml` 파일로 옮겨 실행했습니다.

```yaml
services:
  web:
    build: .
    image: my-web:1.0
    ports:
      - "8080:80"
```

```console
$ docker compose up -d
[+] up 2/2
 ✔ Network e1-1_default Created
 ✔ Container e1-1-web-1 Started
$ docker compose ps
NAME         IMAGE        COMMAND                   SERVICE   CREATED         STATUS         PORTS
e1-1-web-1   my-web:1.0   "/docker-entrypoint.…"   web       6 seconds ago   Up 6 seconds   0.0.0.0:8080->80/tcp, [::]:8080->80/tcp
$ curl http://localhost:8080
...
  <h1>Hello, Codyssey!</h1>
  <p>Version: v1</p>
...
```

- Compose가 전용 네트워크(`e1-1_default`)를 자동으로 만들고, 컨테이너 이름을 `폴더명-서비스명-번호`로 붙였습니다.

## B2. 멀티 컨테이너 + 컨테이너 간 통신

보조 서비스 `client`를 추가해, 서비스 이름 `web`만으로 웹 서버에 접속하는지 확인했습니다.

```yaml
  client:
    image: alpine:3.20
    depends_on:
      - web
    command: sh -c "while true; do wget -qO- http://web | grep Version; sleep 5; done"
```

```console
$ docker compose up -d
[+] up 6/6
 ✔ Image alpine:3.20       Pulled
 ✔ Container e1-1-web-1    Running
 ✔ Container e1-1-client-1 Started
$ docker compose ps
NAME            IMAGE         COMMAND                   SERVICE   CREATED          STATUS          PORTS
e1-1-client-1   alpine:3.20   "sh -c 'while true; …"   client    1 second ago     Up 1 second
e1-1-web-1      my-web:1.0    "/docker-entrypoint.…"   web       10 minutes ago   Up 10 minutes   0.0.0.0:8080->80/tcp, [::]:8080->80/tcp
$ docker compose logs client
client-1  |   <p>Version: v1</p>
client-1  |   <p>Version: v1</p>
```

- 같은 Compose 네트워크 안에서는 IP 대신 서비스 이름(`web`)으로 접속할 수 있었습니다. (서비스 디스커버리)

### 실수와 수정: `wget` 옵션 오타

```console
$ docker compose logs client
client-1  | wget: unrecognized option: 0
client-1  | BusyBox v1.36.1 (2025-11-23 14:32:18 UTC) multi-call binary.
...
```

- `-qO-`의 대문자 `O`를 숫자 `0`으로 입력해 오류가 났습니다.
- 파일을 수정하고 `docker compose up -d`를 다시 실행하자 `client`만 새로 만들어지며 정상 동작했습니다.

## B3 · B4. 운영 명령 + 환경 변수로 포트·모드 변경

포트와 실행 모드를 환경 변수로 바꿀 수 있도록 `web` 서비스를 수정했습니다. (최종 `docker-compose.yml`)

```yaml
services:
  web:
    build: .
    image: my-web:1.0
    ports:
      - "${WEB_PORT:-8080}:80"
    environment:
      APP_ENV: ${APP_ENV:-dev}

  client:
    image: alpine:3.20
    depends_on:
      - web
    command: sh -c "while true; do wget -qO- http://web | grep Version; sleep 5; done"
```

```console
$ docker compose down
[+] down 3/3
 ✔ Container e1-1-client-1 Removed
 ✔ Container e1-1-web-1    Removed
 ✔ Network e1-1_default    Removed

$ WEB_PORT=9090 APP_ENV=prod docker compose up -d
[+] up 3/3
 ✔ Network e1-1_default    Created
 ✔ Container e1-1-web-1    Started
 ✔ Container e1-1-client-1 Started
$ docker compose ps
NAME            IMAGE         COMMAND                   SERVICE   CREATED          STATUS          PORTS
e1-1-client-1   alpine:3.20   "sh -c 'while true; …"   client    31 seconds ago   Up 31 seconds
e1-1-web-1      my-web:1.0    "/docker-entrypoint.…"   web       31 seconds ago   Up 31 seconds   0.0.0.0:9090->80/tcp, [::]:9090->80/tcp
$ curl http://localhost:9090
...
  <h1>Hello, Codyssey!</h1>
  <p>Version: v1</p>
...
$ docker compose exec web printenv APP_ENV
prod

$ docker compose down
[+] down 3/3
 ✔ Container e1-1-client-1 Removed
 ✔ Container e1-1-web-1    Removed
 ✔ Network e1-1_default    Removed
$ docker compose ps -a
NAME      IMAGE     COMMAND   SERVICE   CREATED   STATUS    PORTS
```

- 파일을 수정하지 않고 실행할 때 값만 넣어 포트(8080 → 9090)와 모드(dev → prod)를 바꿨습니다. (설정과 코드의 분리)
- `up`, `ps`, `logs`, `down`으로 실행·상태 확인·로그·정리를 수행했습니다.

## B5. GitHub SSH 키 설정

```console
$ ls -la ~/.ssh                          # 기존 키가 없는 것을 먼저 확인
total 16
drwx------   5 ahrkdy  staff   160 10월 31 22:04 .
drwxr-x---+ 82 ahrkdy  staff  2624 11월  3 13:45 ..
drwx------   4 ahrkdy  staff   128 11월  2 02:25 agent
-rw-r--r--   1 ahrkdy  staff   210 10월 19 18:32 config
-rw-r--r--   1 ahrkdy  staff   191 11월  2 02:25 known_hosts

$ ssh-keygen -t ed25519 -C "ppad125-codyssey"
Generating public/private ed25519 key pair.
Enter file in which to save the key (/Users/ahrkdy/.ssh/id_ed25519):
Enter passphrase for "/Users/ahrkdy/.ssh/id_ed25519" (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /Users/ahrkdy/.ssh/id_ed25519
Your public key has been saved in /Users/ahrkdy/.ssh/id_ed25519.pub

$ ssh-add --apple-use-keychain ~/.ssh/id_ed25519
Identity added: /Users/ahrkdy/.ssh/id_ed25519 (ppad125-codyssey)
$ pbcopy < ~/.ssh/id_ed25519.pub         # 공개키만 복사해 GitHub Settings > SSH keys에 등록

$ ssh -T git@github.com
The authenticity of host 'github.com (20.200.245.247)' can't be established.
ED25519 key fingerprint is: SHA256:+DiY3wvvV6TuJJhbpZisF/zLDA0zPMSvHdkr4UvCOqU
This key is not known by any other names.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added 'github.com' (ED25519) to the list of known hosts.
Hi ppad125! You've successfully authenticated, but GitHub does not provide shell access.

$ git remote set-url origin git@github.com:ppad125/codyssey-e1-1.git
$ git remote -v
origin	git@github.com:ppad125/codyssey-e1-1.git (fetch)
origin	git@github.com:ppad125/codyssey-e1-1.git (push)

$ git push                               # SSH로 push
...
To github.com:ppad125/codyssey-e1-1.git
   34a4cdb..18cd4c7  main -> main
```

- 개인키(`id_ed25519`)는 맥에만 두고, 공개키(`id_ed25519.pub`)만 GitHub에 등록했습니다.
- GitHub가 보여준 지문이 GitHub 공식 지문과 같은 것을 확인한 뒤 `yes`로 접속했습니다.
- 원격 주소를 HTTPS에서 SSH로 바꾼 뒤, 로그인 없이 키 인증으로 push했습니다.
