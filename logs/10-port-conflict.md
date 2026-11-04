# 10. 포트 충돌 진단 및 해결

[← README로 돌아가기](../README.md)

다른 프로그램이 이미 사용 중인 포트로 컨테이너를 실행해 충돌을 일부러 만들고,
**충돌 확인 → 원인 프로세스 진단 → 포트 해제 → 재실행** 순서로 해결했습니다.

## 1. 포트 점유 (원인 만들기)

```console
$ python3 -m http.server 8090 &          # 파이썬 웹서버로 8090 포트 점유 (백그라운드)
[1] 51466
Serving HTTP on :: port 8090 (http://[::]:8090/) ...
```

## 2. 충돌 발생

```console
$ docker run -d -p 8090:80 --name web-conflict my-web:1.0
86b74708d2789cd93f6830de04ac5f2f80a3695c6c83f7b216e3191b7903b59f
docker: Error response from daemon: ports are not available: exposing port TCP 0.0.0.0:8090 -> 127.0.0.1:0: listen tcp 0.0.0.0:8090: bind: address already in use
```

- `address already in use`: 호스트의 8090 포트를 이미 다른 프로세스가 사용 중이라 연결할 수 없었습니다.
- 컨테이너 ID가 먼저 출력된 것처럼, 컨테이너는 **생성은 되었지만 시작에 실패**한 상태로 남았습니다.

## 3. 진단: 포트를 사용 중인 프로세스 찾기

```console
$ lsof -nP -iTCP:8090 -sTCP:LISTEN       # 8090 포트에서 대기(LISTEN) 중인 프로세스
COMMAND   PID   USER   FD   TYPE            DEVICE SIZE/OFF NODE NAME
Python  51466 ahrkdy    5u  IPv6 0xadfbe06a1fdf133      0t0  TCP *:8090 (LISTEN)

$ docker ps --filter publish=8090        # 8090을 사용하는 컨테이너가 있는지
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
```

| 확인 항목 | 결과 | 판단 |
|---|---|---|
| `lsof` | `Python`, PID `51466`이 8090에서 LISTEN | 원인 프로세스 확인 |
| `docker ps --filter publish=8090` | 결과 없음 | 다른 컨테이너가 원인이 아님 |

## 4. 해결: 포트 해제 후 재실행

```console
$ kill 51466                             # 원인 프로세스 종료
[1]  + terminated  python3 -m http.server 8090
$ lsof -nP -iTCP:8090 -sTCP:LISTEN       # 출력 없음 = 포트가 비어 있음

$ docker rm web-conflict                 # 시작에 실패한 채 남은 컨테이너 삭제
web-conflict
$ docker run -d -p 8090:80 --name web-conflict my-web:1.0
ec96fe96c1c60db716b36bec7bef290bbf61339dc3de1984ed5e97a73dd766f5
$ curl http://localhost:8090
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

## 5. 정리

```console
$ docker rm -f web-conflict              # 실습 컨테이너 중지 + 삭제
web-conflict
```

## 진단 절차 요약

1. **증상 확인**: `docker run` 오류 메시지에서 `address already in use` / `port is already allocated` 확인
2. **원인 찾기**: `lsof -nP -iTCP:<포트> -sTCP:LISTEN`으로 포트를 점유한 프로세스(COMMAND, PID) 확인
3. **컨테이너 여부 확인**: `docker ps --filter publish=<포트>`로 다른 컨테이너가 원인인지 확인
4. **해결 (둘 중 선택)**
   - 포트 해제: 종료해도 되는 프로세스라면 `kill <PID>` (컨테이너라면 `docker stop <이름>`)
   - 대체 포트: 종료하면 안 되는 프로세스라면 `-p 8091:80`처럼 호스트 포트만 변경
5. **잔여 컨테이너 정리**: 시작에 실패한 컨테이너는 `docker rm`으로 지운 뒤 다시 실행
6. **재확인**: `lsof` 출력이 비었는지, `curl`로 접속되는지 확인
