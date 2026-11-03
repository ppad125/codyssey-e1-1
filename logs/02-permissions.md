# 02. 권한 실습

[← README로 돌아가기](../README.md)

파일 1개(`run.sh`)와 디렉토리 1개(`secret_dir`)의 권한을 바꾸고, 변경 전·후를 비교했습니다.
모든 명령은 `~/Codyssey/e1-1/practice`에서 실행했습니다.

## 1. 실습 대상 생성 및 변경 전 권한 확인

```console
$ echo 'echo run!' > run.sh              # 실행하면 "run!"을 출력하는 스크립트
$ mkdir secret_dir
$ ls -l run.sh
-rw-r--r--  1 ahrkdy  staff  10 11월  2 17:04 run.sh
$ ls -ld secret_dir                      # -d: 폴더 안이 아니라 폴더 자체의 정보
drwxr-xr-x  2 ahrkdy  staff  64 11월  2 17:04 secret_dir
```

- 새 파일은 `644`(`rw-r--r--`), 새 폴더는 `755`(`rwxr-xr-x`)로 생성되었습니다. (umask `022` 적용)

## 2. 파일 권한 변경: 644 → 755

```console
$ ./run.sh                               # 변경 전: 실행 권한(x) 없음
zsh: permission denied: ./run.sh
$ chmod 755 run.sh
$ ls -l run.sh                           # 변경 후
-rwxr-xr-x  1 ahrkdy  staff  10 11월  2 17:04 run.sh
$ ./run.sh                               # 실행 성공
run!
```

| | 권한 | `./run.sh` |
|---|---|---|
| 변경 전 | `-rw-r--r--` (644) | `permission denied` |
| 변경 후 | `-rwxr-xr-x` (755) | `run!` 출력 |

## 3. 디렉토리 권한 변경: 755 → 700 → 600 → 755

```console
$ chmod 700 secret_dir                   # 소유자만 접근
$ ls -ld secret_dir
drwx------  2 ahrkdy  staff  64 11월  2 17:04 secret_dir
$ chmod 600 secret_dir                   # 소유자의 x(들어가기) 권한도 제거
$ ls -ld secret_dir
drw-------  2 ahrkdy  staff  64 11월  2 17:04 secret_dir
$ cd secret_dir                          # x가 없어 들어갈 수 없음
cd: permission denied: secret_dir
$ chmod 755 secret_dir                   # 원래대로 복구
$ ls -ld secret_dir
drwxr-xr-x  2 ahrkdy  staff  64 11월  2 17:04 secret_dir
$ cd secret_dir                          # 다시 들어갈 수 있음
$ pwd
/Users/ahrkdy/Codyssey/e1-1/practice/secret_dir
$ cd ..
```

| 권한 | 표기 | `cd secret_dir` |
|---|---|---|
| 755 | `drwxr-xr-x` | 가능 |
| 700 | `drwx------` | 가능 (소유자만) |
| 600 | `drw-------` | `permission denied` |

- 디렉토리에서 `x`는 "안으로 들어가기" 권한이라, `600`에서는 소유자도 `cd`할 수 없었습니다.
