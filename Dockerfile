# 内容巡查线（content-patrol）
# 构建阶段：先按钉版安装基座 rcp-core，再构建本服务。
FROM maven:3.9-eclipse-temurin-17 AS build
ARG CORE_REF=v1.0.0
RUN apt-get update && apt-get install -y --no-install-recommends git \
 && rm -rf /var/lib/apt/lists/*
WORKDIR /build
RUN git clone --depth 1 --branch ${CORE_REF} https://github.com/lifeipkg/rcp-core.git /build/rcp-core \
 && mvn -B -q -f /build/rcp-core/pom.xml install -DskipTests
COPY pom.xml .
RUN mvn -B -q dependency:go-offline || true
COPY src ./src
RUN mvn -B -q package -DskipTests

FROM eclipse-temurin:17-jre
WORKDIR /app
RUN groupadd -r risk && useradd -r -g risk risk
COPY --from=build /build/target/content-patrol-1.0.0.jar app.jar
USER risk
EXPOSE 8081
ENTRYPOINT ["java", "-XX:MaxRAMPercentage=75.0", "-jar", "app.jar"]
