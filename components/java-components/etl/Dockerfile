# Apache Ant
FROM frekele/java:jdk8

# Apache Maven installation
ARG MAVEN_VERSION=3.6.3
ARG USER_HOME_DIR="/root"
ARG BASE_URL=https://apache.osuosl.org/maven/maven-3/${MAVEN_VERSION}/binaries

RUN mkdir -p /usr/share/maven /usr/share/maven/ref \
 && curl -fsSL -o /tmp/apache-maven.tar.gz ${BASE_URL}/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
 && tar -xzf /tmp/apache-maven.tar.gz -C /usr/share/maven --strip-components=1 \
 && rm -f /tmp/apache-maven.tar.gz \
 && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn

ENV MAVEN_HOME /usr/share/maven
ENV MAVEN_CONFIG "$USER_HOME_DIR/.m2"


#Copy the pom.xml
COPY pom.xml /root


#Copy the ETL java component and nextprot commons, ideally should be downlowded from a repo
COPY ./lib/nextprot-commons.jar /root
COPY ./lib/nextprot-experiments-1.0-SNAPSHOT.jar /root

#Install commons locally
RUN mvn install:install-file    -Dfile=./nextprot-commons.jar    -DgroupId=org.nextprot    -DartifactId=nextprot-commons    -Dversion=3.24.0    -Dpackaging=jar
