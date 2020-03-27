FROM ruby:2.7.0

RUN apt-get update && apt-get install -y --no-install-recommends chromium unzip
RUN curl https://chromedriver.storage.googleapis.com/80.0.3987.106/chromedriver_linux64.zip -o /tmp/chromedriver_linux64.zip && \
    unzip /tmp/chromedriver_linux64.zip -d /tmp && \
    mv /tmp/chromedriver /usr/local/bin/chromedriver && \
    chown root:root /usr/local/bin/chromedriver && \
    chmod 0755 /usr/local/bin/chromedriver && \
    apt-get remove -y unzip && \
    apt-get clean

CMD ["bundle", "exec", "ruby", "main.rb"]
WORKDIR /usr/src/app
COPY Gemfile* /usr/src/app/
RUN bundle install
COPY . .

ENV CHROME_BIN /usr/bin/chromium
