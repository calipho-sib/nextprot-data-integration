FROM frekele/java:jdk8

# Apache Ant
ENV ANT_VERSION 1.10.3
ENV ANT_HOME=/opt/ant

# Download and extract apache ant to opt folder
RUN wget --no-check-certificate --no-cookies http://archive.apache.org/dist/ant/binaries/apache-ant-${ANT_VERSION}-bin.tar.gz \
    && wget --no-check-certificate --no-cookies http://archive.apache.org/dist/ant/binaries/apache-ant-${ANT_VERSION}-bin.tar.gz.sha512 \
    && echo "$(cat apache-ant-${ANT_VERSION}-bin.tar.gz.sha512) apache-ant-${ANT_VERSION}-bin.tar.gz" | sha512sum -c \
    && tar -zvxf apache-ant-${ANT_VERSION}-bin.tar.gz -C /opt/ \
    && ln -s /opt/apache-ant-${ANT_VERSION} /opt/ant \
    && rm -f apache-ant-${ANT_VERSION}-bin.tar.gz \
    && rm -f apache-ant-${ANT_VERSION}-bin.tar.gz.sha512

# Add executables to path
RUN update-alternatives --install "/usr/bin/ant" "ant" "/opt/ant/bin/ant" 1 && \
    update-alternatives --set "ant" "/opt/ant/bin/ant" 

# Install perl and cpan for required perl modules
WORKDIR /shared
RUN apt-get update
RUN apt-get install -y build-essential git maven
ADD http://www.cpan.org/src/5.0/perl-5.22.1.tar.gz /shared
RUN tar -xzf perl-5.22.1.tar.gz

WORKDIR /shared/perl-5.22.1
RUN ./Configure -des -Dprefix=/opt/perl-5.22.1/localperl

RUN make
RUN make install

# Build module
RUN apt-get -y install libmodule-build-perl

# Install DBI and DBD::Mysql
RUN cpan -f DBI::DBD

# Download ensembl
WORKDIR /lib/perl/ensembl
RUN wget ftp://ftp.ensembl.org/pub/ensembl-api.tar.gz
RUN tar zxf ensembl-api.tar.gz

# Bioperl
RUN wget https://cpan.metacpan.org/authors/id/C/CJ/CJFIELDS/BioPerl-1.6.924.tar.gz
RUN tar zxf BioPerl-1.6.924.tar.gz

# Copy nextprot perl parsers
COPY lib/perl/nextprot-perl-parsers/ /src/perl/nextprot-perl-parsers

# Download nextprot loader
COPY lib/java/com.genebio.nextprot.dataloader-1.0-20160915.125409-41-jar-with-dependencies.jar /lib/java/

# Copy nextprot loader tools.integration perl scripts
COPY lib/nextprot-loaders/ /app/nextprot-loaders/

#Copy the properties files
RUN mkdir /app/properties
RUN mkdir /app/properties/config
COPY properties/dataload.properties /app/properties
COPY properties/np1.properties /app/properties/config

# Add ensembl to env
ENV PROP_FILE=/app/properties/dataload.properties

# Add all env variables
RUN mkdir /log
ENV NP1_LOG_DIR=/log

# Install perl parsers
WORKDIR /app/nextprot-loaders/tools.integration
RUN ant -lib lib/ -propertyfile $PROP_FILE install-perl > $NP1_LOG_DIR/install-perl_$(date "+%Y%m%d")-$(hostname).log

# Perl libs in ENV
ENV ENSEMBL_LIB=/lib/perl/ensembl
ENV NEXTPROT_PERL_PARSE_LIB=/lib/perl
ENV PERL5LIB=$ENSEMBLE_LIB/BioPerl-1.6.924:$ENSEMBL_LIB/ensembl/modules:$ENSEMBL_LIB/ensembl-compara/modules:$ENSEMBL_LIB/ensembl-variation/modules:$ENSEMBL_LIB/ensembl-funcgen/modules:/lib/perl/lib/perl5/