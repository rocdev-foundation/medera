FROM elixir:1.3.4
RUN mkdir -p /app
WORKDIR /app
CMD ["iex", "-S", "mix"]
COPY . /app
RUN mix local.hex --force && \
    mix deps.get && \
    mix compile