FROM ruby

LABEL Name=rubybase Version=0.0.1 maintainer="Luiz <luiz@siffra.com.br>"

# Set Environment Variables
ENV DEBIAN_FRONTEND noninteractive

#
#--------------------------------------------------------------------------
# Locales
#--------------------------------------------------------------------------
#
RUN apt-get update \
    && apt-get install -fy tzdata locales \
    && rm -rf /var/lib/apt/lists/*

RUN localedef -i pt_BR -c -f UTF-8 -A /usr/share/locale/locale.alias pt_BR.UTF-8
ENV LANGUAGE=pt_BR.UTF-8
ENV LC_ALL=pt_BR.UTF-8
ENV LC_CTYPE=pt_BR.UTF-8
ENV LANG=pt_BR.UTF-8

ENV TZ=America/Sao_Paulo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# always run apt update when start and after add new source list, then clean up at end.
RUN set -xe; \
    apt-get update -yqq && \
    apt-get install -yqq \
    apt-utils \
    sudo \
    libperl-dev \
    tmux \
    xclip \
    curl \
    git \
    git-flow \
    tmux \
    zsh \
    sudo \
    lsb-release \
    neofetch \
    zsh-syntax-highlighting \
    powerline \
    fonts-powerline \
    build-essential openssl libssl-dev sqlite3 exa


RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - &&  apt-get install -y nodejs
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && apt update && apt install yarn

ENV PUID 1000
ENV PGID 1000
ENV DOCKER_USER=ruby

USER ${DOCKER_USER}
ARG GIT_GLOBAL_USER_EMAIL="luiz@siffra.com.br"
ARG GIT_GLOBAL_USER_NAME="Luiz Benevenuto"
RUN git config --global user.email ${GIT_GLOBAL_USER_EMAIL}
RUN git config --global user.name ${GIT_GLOBAL_USER_NAME}

USER root
ENV PASSWORD=123
RUN usermod --shell /bin/zsh root && usermod --shell /bin/zsh --password $(openssl passwd -1 ${PASSWORD}) ${DOCKER_USER}
RUN echo "${DOCKER_USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/${DOCKER_USER}

COPY .p10k.zsh    /root/.p10k.zsh
COPY .aliases     /root/.aliases
COPY .tmux.conf   /root/.tmux.conf
COPY .p10k.zsh    /home/${DOCKER_USER}/.p10k.zsh
COPY .aliases     /home/${DOCKER_USER}/.aliases
COPY .tmux.conf   /home/${DOCKER_USER}/.tmux.conf

RUN sed -i 's/\r//' /root/.aliases && \
    sed -i 's/\r//' /home/${DOCKER_USER}/.aliases && \
    chown ${DOCKER_USER}:${DOCKER_USER} /home/${DOCKER_USER}/.aliases && \
    echo "" >> ~/.bashrc && \
    echo "# Load Custom Aliases" >> ~/.bashrc && \
    echo "source ~/.aliases" >> ~/.bashrc && \
    echo "" >> ~/.bashrc

USER ${DOCKER_USER}

RUN echo "" >> ~/.bashrc && \
    echo "# Load Custom Aliases" >> ~/.bashrc && \
    echo "source ~/.aliases" >> ~/.bashrc && \
    echo "" >> ~/.bashrc

##############################################################################################################################
USER ${DOCKER_USER}

RUN sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
RUN git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

RUN echo 'ZSH_DISABLE_COMPFIX=true' >> ~/.zshrc
RUN echo 'UPDATE_ZSH_DAYS=1' >> ~/.zshrc
RUN echo 'HIST_STAMPS="dd.mm.yyyy"' >> ~/.zshrc
RUN echo 'DISABLE_UPDATE_PROMPT=true' >> ~/.zshrc

RUN git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k && \
    sed --follow-symlinks -i -r -e "s/^(ZSH_THEME=).*/\1\"powerlevel10k\/powerlevel10k\"/" ~/.zshrc

RUN echo 'source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh' >> ~/.zshrc
RUN sed --follow-symlinks -i -e "s/\(source \$ZSH\/oh-my-zsh.sh\)/plugins\+\=\(git-flow docker zsh_reload zsh-autosuggestions docker-compose gitignore helm perl kubectl cpanm common-aliases nvm npm yarn node composer laravel5 redis-cli supervisor ubuntu sudo debian command-not-found\)\n\1/" ~/.zshrc

RUN echo "" >> ~/.zshrc && \
    echo "# Load Custom Aliases" >> ~/.zshrc && \
    echo "source ~/.aliases" >> ~/.zshrc && \
    echo "" >> ~/.zshrc

RUN echo "\n" >> ~/.zshrc && \
    echo '# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.' >> ~/.zshrc && \
    echo "\n" >> ~/.zshrc && \
    echo '[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh' >> ~/.zshrc

RUN yarn global add @quasar/cli && yarn global add @quasar/icongenie
RUN echo "" >> ~/.zshrc && echo "export PATH=\"$(yarn global bin):$PATH\"" >> ~/.zshrc

#
#--------------------------------------------------------------------------
# Final Touch
#--------------------------------------------------------------------------
#

USER root

# Clean up
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    rm /var/log/lastlog /var/log/faillog

USER ${DOCKER_USER}

# start zsh
CMD [ "zsh" ]
