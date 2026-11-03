# E1-1. 내 컴퓨터에 개발자용 '작업실' 꾸미기

## 1. 프로젝트 개요
터미널, Docker, Git을 직접 세팅하고 사용해 보며 개발 환경을 구성했습니다.
nginx 기반 커스텀 이미지를 만들어 포트 매핑으로 접속하고,
바인드 마운트와 볼륨으로 "변경 반영"과 "데이터 영속성"을 검증했습니다.

## 2. 실행 환경

| 항목 | 내용 |
|---|---|
| OS | macOS (27.2) |
| Shell | zsh 5.9 (arm64-apple-darwin26.0) |
| Terminal | macOS 터미널 (Terminal.app), VSCode 통합 터미널 |
| Docker | Docker Desktop / Docker version 29.8.2, build 7fc2dff |
| Docker Compose | v5.6.0 |
| Git | 2.54.0 (Apple Git-157) |

## 3. 수행 체크리스트
- [x] 터미널 기본 조작 (위치 확인, 숨김 포함 목록, 이동, 생성, 복사, 이동/이름변경, 삭제, 내용 확인, 빈 파일)
- [x] 권한 변경 실습 (파일 1개, 디렉토리 1개 / 변경 전·후 비교)
- [x] Docker 설치 점검 (`docker --version`, `docker info`)
- [x] Docker 기본 운영 (pull, images, run, ps, ps -a, logs, stats, stop)
- [x] hello-world 실행, ubuntu 컨테이너 진입, attach/exec 차이 관찰
- [x] Dockerfile 커스텀 이미지 빌드·실행 (`my-web:1.0`)
- [x] 포트 매핑 접속 2회 (8080, 8081)
- [x] 바인드 마운트 반영 (8082, v1 → v2)
- [x] Docker 볼륨 영속성 (컨테이너 삭제 전·후)
- [x] Git 설정 (user.name, user.email, init.defaultBranch)
- [x] GitHub 연동 및 push, VSCode GitHub 로그인
- [x] 보너스: Docker Compose (단일, 멀티, up/down/ps/logs, 환경 변수), SSH 키

## 4. 터미널 조작 로그
작업 폴더를 만들고 파일 생성·복사·이동·이름 변경·삭제와 절대/상대 경로 실습을 터미널로 수행했습니다.
`ls`와 `ls -la`를 비교해 숨김 파일(`.secret`)을 확인했습니다.

📄 전체 로그: [logs/01-terminal.md](logs/01-terminal.md)

## 5. 권한 실습
파일(`run.sh`)은 644 → 755로 바꿔 `permission denied`에서 실행 성공으로,
디렉토리(`secret_dir`)는 600으로 바꿔 `cd`가 거부되는 것을 확인했습니다.

📄 전체 로그: [logs/02-permissions.md](logs/02-permissions.md)

## 6. Docker 설치 점검 및 기본 운영
`docker --version`, `docker info`로 설치와 데몬 동작을 확인하고, hello-world·ubuntu 컨테이너 실행,
logs·stats·stop, attach와 exec의 차이를 실습했습니다.

📄 전체 로그: [logs/03-docker-basic.md](logs/03-docker-basic.md)

## 7. Dockerfile 커스텀 이미지
`nginx:alpine`을 베이스로 LABEL·ENV·COPY를 적용해 커스텀 이미지 `my-web:1.0`을 빌드했습니다.

📄 전체 로그: [logs/04-dockerfile.md](logs/04-dockerfile.md) · 설정: [Dockerfile](Dockerfile)

## 8. 포트 매핑
같은 이미지로 컨테이너 2개를 만들어 `-p 8080:80`, `-p 8081:80`으로 각각 접속했습니다.

| `localhost:8080` | `localhost:8081` |
|---|---|
| ![port 8080](docs/screenshots/port-8080.png) | ![port 8081](docs/screenshots/port-8081.png) |

📄 전체 로그: [logs/05-port-mapping.md](logs/05-port-mapping.md)

## 9. 바인드 마운트
맥의 `app/` 폴더를 연결한 8082 컨테이너는 파일 수정(v1 → v2)이 즉시 반영되었고,
이미지에 COPY한 8080은 v1 그대로였습니다.

![bind mount v2](docs/screenshots/bind-mount-v2.png)

📄 전체 로그: [logs/06-bind-mount.md](logs/06-bind-mount.md)

## 10. Docker 볼륨 영속성
볼륨 `mydata`에 데이터를 저장한 컨테이너를 삭제한 뒤, 새 컨테이너에서도 데이터가 유지되는 것을 확인했습니다.

📄 전체 로그: [logs/07-volume.md](logs/07-volume.md)

## 11. Git 설정 및 GitHub 연동
사용자 정보와 기본 브랜치(main)를 설정하고, GitHub에 push한 뒤 VSCode에서 GitHub 계정과
저장소 연동을 확인했습니다.

![vscode github](docs/screenshots/vscode-github.png)

📄 전체 로그: [logs/08-git.md](logs/08-git.md)

## 12. 보너스: Docker Compose · SSH 키
Compose로 웹 서버와 보조 서비스를 함께 실행해 서비스 이름으로 통신을 확인하고,
환경 변수로 포트(9090)와 모드(prod)를 바꿨습니다. SSH 키를 등록해 SSH 방식으로 push했습니다.

📄 전체 로그: [logs/09-bonus.md](logs/09-bonus.md) · 설정: [docker-compose.yml](docker-compose.yml)

## 13. 트러블슈팅

## 14. 개념 정리 (과제 목표)

## 15. 재현 방법