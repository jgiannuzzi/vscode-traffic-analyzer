FROM kasmweb/core-ubuntu-focal:1.12.0
USER root

ENV HOME /home/kasm-default-profile
ENV STARTUPDIR /dockerstartup
ENV INST_SCRIPTS $STARTUPDIR/install
WORKDIR $HOME

######### Customize Container Here ###########

RUN apt-get update \
 && apt-get install --no-install-recommends -y \
      apt-transport-https \
      firefox \
      jq \
      sudo \
 && rm -rf /var/lib/apt/lists/*

RUN mkdir /etc/apt/keyrings \
 && curl -sSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor --output /etc/apt/keyrings/packages.microsoft.gpg \
 && echo "deb [signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list \
 && apt-get update \
 && apt-get install -y code \
 && rm -rf /var/lib/apt/lists/* \
 && sed -i -e 's,\(/usr/share/code/code\),\1 --no-sandbox,' /usr/share/applications/code*.desktop

RUN echo 'vscode ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/vscode \
 && chmod 600 /etc/sudoers.d/vscode \
 && usermod -l vscode -d /home/vscode -m kasm-user \
 && groupmod -n vscode kasm-user \
 && sed -i -e 's,kasm_user,vscode,g' $STARTUPDIR/vnc_startup.sh \
 && sed -i -e 's,^\(openssl.*\)$,[ ! -f ${HOME}/.vnc/self.pem ] \&\& \1,' $STARTUPDIR/vnc_startup.sh \
 && cp /etc/skel/.??* $HOME/ \
 && ln -s /usr/share/applications/code.desktop $HOME/Desktop/ \
 && chown 1000:1000 $HOME/Desktop/code.desktop

COPY custom_startup.sh $STARTUPDIR

ENV KASM_SVC_AUDIO=0 \
    KASM_SVC_AUDIO_INPUT=0 \
    KASM_SVC_UPLOADS=0 \
    KASM_SVC_GAMEPAD=0

######### End Customizations ###########

RUN chown 1000:0 $HOME
RUN $STARTUPDIR/set_user_permission.sh $HOME

ENV HOME /home/vscode
WORKDIR $HOME
RUN mkdir -p $HOME && chown -R 1000:0 $HOME

USER 1000
