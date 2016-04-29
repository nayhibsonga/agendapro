module Webhooks
  class Sparkpost::EmailsController < WebhooksController
    before_filter :check_auth_token

    def check_auth_token

    end

    def consume_raw
      SparkpostEmailLog.create(raw_message: params.inspect)
    end
  end
end
