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