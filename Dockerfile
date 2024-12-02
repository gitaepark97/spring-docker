## Size: 788.91MB
## Time: 31.9s
#FROM amazoncorretto:21
#WORKDIR /app
#COPY . .
#RUN ./gradlew clean build
#COPY ./build/libs/*.jar app.jar
#ENTRYPOINT ["java", "-jar", "app.jar"]

## Size: 611.161MB
## Time: 31.8s
#FROM amazoncorretto:21-alpine3.18
#WORKDIR /app
#COPY . .
#RUN ./gradlew clean build
#COPY ./build/libs/*.jar app.jar
#ENTRYPOINT ["java", "-jar", "app.jar"]

## Size: 336.19MB
## Time: 22.3s
## 첫 번째 스테이지: 애플리케이션 빌드
#FROM gradle:8.5-jdk21 AS build
#COPY . /app
#WORKDIR /app
#RUN gradle clean build
#
## 두 번째 스테이지: 최종 이미지 생성
#FROM amazoncorretto:21-alpine3.18
#WORKDIR /app
#COPY --from=build /app/build/libs/*.jar app.jar
#ENTRYPOINT ["java", "-jar", "app.jar"]

## Size: 128.89MB
## Time: 22.7s
# 첫 번째 스테이지: JRE 생성
FROM amazoncorretto:21-alpine3.18 as builder-jre
RUN apk add --no-cache binutils
RUN $JAVA_HOME/bin/jlink \
         --module-path "$JAVA_HOME/jmods" \
         --verbose \
         --add-modules ALL-MODULE-PATH \
         --strip-debug \
         --no-man-pages \
         --no-header-files \
         --compress=2 \
         --output /jre

# 두 번째 스테이지: 애플리케이션 빌드
FROM gradle:8.5-jdk21 AS build
COPY . /app
WORKDIR /app
RUN gradle clean build

# 세 번째 스테이지: 최종 이미지 생성
FROM alpine:3.18.4
ENV JAVA_HOME=/jre
ENV PATH="$JAVA_HOME/bin:$PATH"
COPY --from=builder-jre /jre $JAVA_HOME
WORKDIR /app
COPY --from=build /app/build/libs/*.jar app.jar
ENTRYPOINT ["java", "-jar", "app.jar"]