FROM openjdk:8

# Apache Ant
ENV ANT_VERSION=1.7.1
ENV ANT_HOME=/opt/ant

# Download and extract apache ant to opt folder
RUN wget --no-check-certificate --no-cookies http://archive.apache.org/dist/ant/binaries/apache-ant-${ANT_VERSION}-bin.tar.gz \
    && wget --no-check-certificate --no-cookies http://archive.apache.org/dist/ant/binaries/apache-ant-${ANT_VERSION}-bin.tar.gz.sha1 \
    && echo "$(cat apache-ant-${ANT_VERSION}-bin.tar.gz.sha1) apache-ant-${ANT_VERSION}-bin.tar.gz" | sha1sum -c \
    && tar -zvxf apache-ant-${ANT_VERSION}-bin.tar.gz -C /opt/ \
    && ln -s /opt/apache-ant-${ANT_VERSION} /opt/ant \
    && rm -f apache-ant-${ANT_VERSION}-bin.tar.gz \
    && rm -f apache-ant-${ANT_VERSION}-bin.tar.gz.sha1

# Add executables to path
RUN update-alternatives --install "/usr/bin/ant" "ant" "/opt/ant/bin/ant" 1 && \
    update-alternatives --set "ant" "/opt/ant/bin/ant" 

# Install perl and cpan for required perl modules
WORKDIR /shared
RUN apt-get update
RUN apt-get install -y build-essential libz-dev libexpat1-dev libdbd-mysql-perl
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
RUN cpan PerlIO::gzip
RUN cpan XML::Twig
RUN cpan XML::Parser

# Download ensembl
WORKDIR /lib/perl/ensembl/97
#RUN wget ftp://ftp.ensembl.org/pub/ensembl-api.tar.gz
#RUN tar zxf ensembl-api.tar.gz
COPY lib/97 /lib/perl/ensembl/97/

# Bioperl
#RUN wget https://cpan.metacpan.org/authors/id/C/CJ/CJFIELDS/BioPerl-1.6.924.tar.gz
#RUN tar zxf BioPerl-1.6.924.tar.gz
#RUN mv BioPerl-1.6.924 bioperl-live

# Copy nextprot perl parsers
COPY lib/perl/nextprot-perl-parsers/ /src/perl/nextprot-perl-parsers

# Download nextprot loader
COPY lib/java/com.genebio.nextprot.dataloader.jar /work/build/jars/

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
ENV ENSEMBL_API_ROOT=/lib/perl/ensembl
ENV ENSEMBL_LIB=/lib/perl/ensembl/97
ENV NEXTPROT_PERL_PARSE_LIB=/lib/perl
ENV PERL5LIB=$ENSEMBL_LIB/bioperl-live/lib:$ENSEMBL_LIB/ensembl/modules:$ENSEMBL_LIB/ensembl-compara/modules:$ENSEMBL_LIB/ensembl-variation/modules:$ENSEMBL_LIB/ensembl-funcgen/modules:/lib/perl/lib/perl5/



# COPY intermediary files
COPY int/5000.txt /tmp/
COPY int/5000to10000.txt /tmp/
COPY int/10000to15000.txt /tmp/

COPY tasks/task1.sh /app/nextprot-loaders/tools.integration/
RUN chmod +x task1.sh
COPY tasks/task2.sh /app/nextprot-loaders/tools.integration/
RUN chmod +x task2.sh
COPY tasks/task3.sh /app/nextprot-loaders/tools.integration/
RUN chmod +x task3.sh
COPY tasks/task4.sh /app/nextprot-loaders/tools.integration/
RUN chmod +x task4.sh
