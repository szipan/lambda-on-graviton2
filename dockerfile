FROM --platform=linux/arm64/v8 amazonlinux:latest

# Add the Amazon Corretto repository
RUN rpm --import https://yum.corretto.aws/corretto.key
RUN curl -L -o /etc/yum.repos.d/corretto.repo https://yum.corretto.aws/corretto.repo

# Update the packages and install Amazon Corretto 18, Maven and Zip
RUN yum -y update
RUN yum install -y java-18-amazon-corretto-devel maven zip

# Set Java 18 as the default
RUN update-alternatives --set java "/usr/lib/jvm/java-18-amazon-corretto/bin/java"
RUN update-alternatives --set javac "/usr/lib/jvm/java-18-amazon-corretto/bin/javac"

# Copy the software folder to the image and build the function
COPY HelloWorldFunction HelloWorldFunction
WORKDIR /HelloWorldFunction
RUN mvn clean package

# Package everything together into a custom runtime archive
WORKDIR /
COPY bootstrap bootstrap
RUN chmod 755 bootstrap
RUN cp /HelloWorldFunction/target/function.jar function.jar
RUN zip -r runtime.zip \
    bootstrap \
    function.jar \