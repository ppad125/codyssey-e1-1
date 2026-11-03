# 01. 터미널 조작 로그

[← README로 돌아가기](../README.md)

작업 폴더를 만들고 파일 생성·복사·이동·이름 변경·삭제를 터미널로 수행했습니다.

## 1. 작업 폴더 생성 및 이동

```console
$ cd ~/Codyssey
$ pwd                                   # 현재 위치 확인
/Users/ahrkdy/Codyssey
$ mkdir e1-1                            # 디렉토리 생성
$ cd e1-1                               # 이동
$ pwd
/Users/ahrkdy/Codyssey/e1-1
```

## 2. 파일 생성 및 목록 확인 (숨김 파일 포함)

```console
$ mkdir -p practice/docs                # 중간 폴더까지 한 번에 생성
$ cd practice
$ touch empty.txt                       # 빈 파일 생성
$ touch .secret                         # 숨김 파일 생성 (이름이 . 으로 시작)
$ echo Hello Codyssey > hello.txt       # 내용이 있는 파일 생성
$ ls                                    # 숨김 파일은 보이지 않음
docs        empty.txt    hello.txt
$ ls -la                                # -a: 숨김 파일 포함, -l: 자세히
total 8
drwxr-xr-x  6 ahrkdy  staff  192 11월  2 16:55 .
drwxr-xr-x  3 ahrkdy  staff   96 11월  2 16:51 ..
-rw-r--r--  1 ahrkdy  staff    0 11월  2 16:51 .secret
drwxr-xr-x  2 ahrkdy  staff   64 11월  2 16:51 docs
-rw-r--r--  1 ahrkdy  staff    0 11월  2 16:51 empty.txt
-rw-r--r--  1 ahrkdy  staff   15 11월  2 16:55 hello.txt
$ cat hello.txt                         # 파일 내용 확인
Hello Codyssey
```

- `ls`에는 없던 `.secret`이 `ls -la`에서 보여 숨김 파일을 확인했습니다.
- `empty.txt`의 크기가 0이라 빈 파일이 생성된 것을 확인했습니다.

## 3. 복사 · 이동 · 이름 변경

```console
$ cp hello.txt copy.txt                 # 복사
$ ls
copy.txt    docs        empty.txt    hello.txt
$ mv copy.txt docs/re                   # 다른 폴더로 이동 (이름 re)
$ ls
docs        empty.txt    hello.txt
$ ls docs
re
$ mv docs/re docs/renamed.txt           # 같은 폴더 안에서 이름 변경
$ ls docs
renamed.txt
$ cat docs/renamed.txt
Hello Codyssey
```

- `mv`는 다른 폴더로 옮기면 이동, 같은 폴더 안에서 쓰면 이름 변경으로 동작했습니다.

## 4. 절대 경로 vs 상대 경로

```console
$ cd docs
$ pwd
/Users/ahrkdy/Codyssey/e1-1/practice/docs
$ cat renamed.txt                                   # 상대 경로 (현재 위치 기준)
Hello Codyssey
$ cat ~/Codyssey/e1-1/practice/docs/renamed.txt     # 절대 경로 (홈부터 전체)
Hello Codyssey
$ cat ../hello.txt                                  # 상대 경로 (.. = 상위 폴더)
Hello Codyssey
$ cd ..
$ pwd
/Users/ahrkdy/Codyssey/e1-1/practice
```

- 같은 `renamed.txt`를 상대 경로와 절대 경로로 각각 열어 같은 결과를 확인했습니다.
- `..`(상위 폴더)를 사용해 `docs` 안에서 상위 폴더의 `hello.txt`를 열었습니다.

## 5. 삭제

```console
$ rm docs/renamed.txt                   # 파일 삭제
$ ls docs                               # 출력 없음 = 비어 있음
$ ls -la
total 8
drwxr-xr-x  6 ahrkdy  staff  192 11월  2 16:57 .
drwxr-xr-x  3 ahrkdy  staff   96 11월  2 16:51 ..
-rw-r--r--  1 ahrkdy  staff    0 11월  2 16:51 .secret
drwxr-xr-x  2 ahrkdy  staff   64 11월  2 17:03 docs
-rw-r--r--  1 ahrkdy  staff    0 11월  2 16:51 empty.txt
-rw-r--r--  1 ahrkdy  staff   15 11월  2 16:55 hello.txt
```

## 실수와 수정 기록

### 따옴표를 닫지 않아 파일이 생성되지 않음

```console
$ echo "Hello Codyssey > hello.txt
dquote>
dquote> "
Hello Codyssey > hello.txt

$ ls
docs        empty.txt
```

- 닫는 따옴표가 없어 셸이 `dquote>` 상태로 입력을 기다렸고, `> hello.txt`까지 문자열로 처리되어 파일이 생성되지 않았습니다.
- `Ctrl + C`로 빠져나온 뒤, 따옴표 없이 `echo Hello Codyssey > hello.txt`로 다시 실행해 해결했습니다.
