FROM ruby

LABEL Name=rubybase Version=0.0.1

RUN apt update && apt install -fy curl build-essential openssl libssl-dev sqlite3 tmux
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - &&  apt-get install -y nodejs
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && apt update && apt install yarn

EXPOSE 3000


