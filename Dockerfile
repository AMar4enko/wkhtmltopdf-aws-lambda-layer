FROM amazonlinux:2

RUN yum install -y \
    rpmdevtools \
    wget \
    yum-utils

WORKDIR /tmp

# Download wkhtmltopdf and its dependencies. Then extract all rpm files.
ENV WKHTMLTOPDF_BIN="wkhtmltopdf.rpm"
RUN wget -O $WKHTMLTOPDF_BIN https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6-1/wkhtmltox-0.12.6-1.centos7.$(arch).rpm \
    && yum install -y --downloadonly --downloaddir=/tmp $WKHTMLTOPDF_BIN \
    && yumdownloader --archlist=$(arch) \
    bzip2-libs \
    expat \
    libuuid \
    && rpmdev-extract *rpm

WORKDIR /layer

# Copy wkhtmltopdf binary and dependency libraries for packaging
RUN mkdir -p {bin,lib} \
    && cp /tmp/wkhtml*/usr/local/bin/* bin \
    && cp /tmp/*/usr/lib64/* lib || :

RUN cp /usr/lib64/libssl.so* lib \
    && cp /usr/lib64/libcrypto.so* lib \
    && cp /usr/lib64/libexpat.so* lib \
    && cp lib/libjpeg.so.62.3.0 lib/libjpeg.so.62 \
    && cp lib/libpng15.so.15.13.0 lib/libpng15.so.15 \
    && cp lib/libXrender.so.1.3.0 lib/libXrender.so.1 \
    && cp lib/libfontconfig.so.1.11.1 lib/libfontconfig.so.1 \
    && cp lib/libfreetype.so.6.14.0 lib/libfreetype.so.6 \
    && cp lib/libXext.so.6.4.0 lib/libXext.so.6 \
    && cp lib/libXau.so.6.0.0 lib/libXau.so.6 || :

# Zip files
ENV LAYER_ZIP="layer.zip"
RUN zip -r $LAYER_ZIP bin lib \
    && mv $LAYER_ZIP /