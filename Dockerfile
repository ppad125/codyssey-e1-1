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
