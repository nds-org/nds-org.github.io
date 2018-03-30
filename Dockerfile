FROM jekyll/jekyll

COPY Gemfile .
RUN bundle
COPY . .

ENTRYPOINT [ "jekyll" ]
CMD [ "serve" ]
