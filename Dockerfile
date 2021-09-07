FROM python:3.6.9-buster

RUN set -ex; \
	\
	wget -O get-pip.py 'https://bootstrap.pypa.io/get-pip.py'; \
	\
	python3 get-pip.py --disable-pip-version-check --no-cache-dir "pip==20.1" \
	; \
	pip --version; \
	\
	find /usr/local -depth \
		\( \
			\( -type d -a \( -name test -o -name tests \) \) \
			-o \
			\( -type f -a \( -name '*.pyc' -o -name '*.pyo' \) \) \
		\) -exec rm -rf '{}' +; \
	rm -f get-pip.py

# Install gcloud
RUN echo "deb http://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
    apt-get update -y && apt-get install google-cloud-sdk vim -y

# Install Argo
RUN curl -Lo /usr/bin/argo https://storage.googleapis.com/amperon-static-web/argo-linux-amd64-3.1.6 && chmod a+x /usr/bin/argo
RUN argo version

# Python packages
WORKDIR /app
RUN pip3 install setuptools

COPY requirements.txt requirements.txt
RUN pip3 install -r requirements.txt

# setup dask
RUN mkdir -p /dask
