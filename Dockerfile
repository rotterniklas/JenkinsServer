FROM jenkins/jenkins:lts

COPY plugins.txt /usr/share/jenkins/ref/plugins.txt

ENV JENKINS_HOME /var/jenkins_home

# Skip setup wizard
ARG JAVA_OPTS
ENV JAVA_OPTS "-Djenkins.install.runSetupWizard=false ${JAVA_OPTS:-}"

# Install plugins
RUN xargs /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt

USER root

# Install Docker CLI and Go
RUN apt-get update && \
    apt-get install -y apt-transport-https ca-certificates curl gnupg2 software-properties-common wget git && \
    # Install Docker CLI
    curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - && \
    add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/debian \
    $(lsb_release -cs) \
    stable" && \
    apt-get update && \
    apt-get install -y docker-ce-cli && \
    # Install Go
    wget https://golang.org/dl/go1.21.6.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go1.21.6.linux-amd64.tar.gz && \
    rm go1.21.6.linux-amd64.tar.gz

# Set Go environment variables
ENV PATH="/usr/local/go/bin:${PATH}"
ENV GOPATH="/var/jenkins_home/go"
ENV PATH="${GOPATH}/bin:${PATH}"

# Add jenkins user to docker group
RUN groupadd -f docker && \
    usermod -aG docker jenkins

# Ensure proper directory permissions
RUN mkdir -p ${GOPATH}/src ${GOPATH}/bin ${GOPATH}/pkg && \
    chown -R jenkins:jenkins ${GOPATH}

# Switch back to jenkins user
USER jenkins