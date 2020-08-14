FROM centos:latest

RUN yum -y update && \
    yum -y upgrade && \
    yum install -y epel-release && \
    yum install -y gcc gcc-c++ python-devel kernel-devel unixODBC-devel readline-devel libgfortran.x86_64 && \
    yum install -y make wget which openssl-devel libpng-devel bzip2-devel libffi-devel sqlite-devel

# Install Python 3.7
WORKDIR /usr/src
RUN wget https://www.python.org/ftp/python/3.7.3/Python-3.7.3.tgz && \
    tar xzf Python-3.7.3.tgz && \
    cd Python-3.7.3 && \
    ./configure --enable-optimizations && \
    make altinstall

RUN yum remove -y java-1.7.0-openjdk-devel.x86_64 java-1.8.0-openjdk.x86_64 java-1.8.0-openjdk-headless.x86_64 && \
    yum clean all && \
    rm /usr/src/Python-3.7.3.tgz

# Install pipenv
RUN pip3.7 install --upgrade pip && \
    pip3.7 install pipenv certifi && \
    pip3.7 install awscli

ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:/usr/local/lib
ENV LC_ALL en_US.utf-8
ENV LANG en_US.utf-8

# Install Teradata drivers
ARG AWS_ACCESS_KEY_ID
ARG AWS_SECRET_ACCESS_KEY
ENV AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
ENV AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
ENV AWS_DEFAULT_REGION=us-east-1

RUN mkdir /install/ && \
    cd /install/ && \
    aws s3 cp s3://prd2321-marketing-datascience/teradata_drivers . --recursive && \
    cd /install/TeraGSS && rpm -i TeraGSS_linux_x64-16.00.00.01-1.noarch.rpm && \
    cd /install/tdicu1600 && sh setup_wrapper.sh -r tdicu1600-16.00.00.00-1.noarch.rpm -s && \
    cd /install/tdodbc1600 && sh setup_wrapper.sh -r tdodbc1600-16.00.00.02-1.noarch.rpm -s && \
    rpm -qa --queryformat '%10{size} - %-25{name} \t %{version}\n' | sort -n

ENV AWS_ACCESS_KEY_ID=
ENV AWS_SECRET_ACCESS_KEY=

# Install dependencies
RUN mkdir /ltv && \
    mkdir /ltv/src/ && \
    mkdir /ltv/tests/

WORKDIR /ltv
COPY Pipfile Pipfile
COPY Pipfile.lock Pipfile.lock
RUN pipenv install
COPY pyproject.toml pyproject.toml
COPY pytest.ini pytest.ini

# Copy code
COPY src /ltv/src
COPY tests /ltv/tests

ENV ODBC_VERSION 16.00
ENV ODBCINI /opt/teradata/client/$ODBC_VERSION/odbc_64/odbc.ini
ENV ODBCINSTINI /opt/teradata/client/$ODBC_VERSION/odbc_64/odbcinst.ini
ENV LD_LIBRARY_PATH /opt/teradata/client/$ODBC_VERSION/odbc_64/lib:/opt/teradata/client/$ODBC_VERSION/tdicu/lib64:$LD_LIBRARY_PATH
ENV NLSPATH /opt/teradata/client/$ODBC_VERSION/odbc_64/msg/tdodbc.cat

WORKDIR /ltv/
ENTRYPOINT pipenv run python src/cust_status.py
