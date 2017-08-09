use Mix.Config

config :logger,
  backends: [:console, LoggerNsq.Backend]
  #handle_sasl_reports: true

config :logger, LoggerNsq.Backend,
  metadata: [:application, :file, :line, :user_id],
  nsqds: ["127.0.0.1:4150"],
  nsq_default_topic: "foo"
