## App usage

First install RabbitMQ, Ruby, Elixir.


run RabbitMQ server:

rabbitmq-server

launch apps:

cd ruby_chat
bundle install

ruby run_chat.rb

bundle exec rspec

cd ..
cd elixir_chat
mix deps.get
mix run

to run specs:
### ruby app:
bundle exec rspec 
### elixir_app:
mix test