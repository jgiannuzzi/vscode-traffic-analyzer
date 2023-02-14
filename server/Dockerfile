FROM debian:stable

RUN apt-get update \
 && apt-get install --no-install-recommends -y \
      apt-transport-https \
      ca-certificates \
      curl \
      git \
      gpg \
      jq \
      libnss3-tools \
      locales-all \
      openssh-server \
      sudo \
 && service ssh start \
 && perl -i -pe 's/^#?((?!Kerberos|GSSAPI)\w*Authentication)\s.*/\1 no/; s/^(PubkeyAuthentication) no/\1 yes/; s/^#?(AddressFamily)\s.*/\1 inet/' /etc/ssh/sshd_config \
 && rm -rf /var/lib/apt/lists/*

RUN adduser --gecos 0 --disabled-password vscode \
 && echo 'vscode ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/vscode

RUN arch=$(uname -m | sed 's/x86_64/x64/;s/aarch64/arm64/') \
 && curl -sSL https://update.code.visualstudio.com/latest/server-linux-${arch}/stable | tar xzf - \
 && commit=$(jq -r .commit < vscode-server-linux-${arch}/product.json) \
 && mkdir -p ~vscode/.vscode-server/bin \
 && mv vscode-server-linux-${arch} ~vscode/.vscode-server/bin/${commit} \
 && chown -R vscode:vscode ~vscode/.vscode-server

COPY entrypoint.sh /usr/local/bin/
ENTRYPOINT ["entrypoint.sh"]

CMD ["sshd"]
