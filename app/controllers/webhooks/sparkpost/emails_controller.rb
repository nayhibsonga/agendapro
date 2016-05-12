module Webhooks
  class Sparkpost::EmailsController < WebhooksController
    before_filter :check_auth_token

    def check_auth_token

    end

    def consume_raw
      SparkpostEmailLog.create(raw_message: params.inspect)

      json = params["_json"].to_json

      json.each do |event|
        message_event = event["msys"]["message_event"]
        track_event = event["msys"]["track_event"]
        unsubscribe_event = event["msys"]["unsubscribe_event"]
        gen_event = event["msys"]["gen_event"]
        relay_event = event["msys"]["relay_event"]

        if message_event.present?
          if message_event["rcpt_meta"]["booking_ids"].present?
            message_event["rcpt_meta"]["booking_ids"].each do |booking_id|
              log = BookingEmailLog.find_or_initialize_by(transmission_id: message_event["transmission_id"], booking_id: booking_id)
              log.assign_attributes(status: message_event["type"], email: message_event["rcpt_to"], timestamp: DateTime.strptime("1318996912",'%s'))
            end
          elsif message_event["rcpt_meta"]["campaign_id"].present? && Email::Content.find_by(id: message_event["rcpt_meta"]["campaign_id"]) && Client.find_by(email: message_event["rcpt_to"], company_id: Email::Content.find_by(id: message_event["rcpt_meta"]["campaign_id"]).company.id)
            log = ClientEmailLog.find_or_initialize_by(transmission_id: message_event["transmission_id"], campaign_id: message_event["rcpt_meta"]["campaign_id"], client_id: Client.find_by(email: message_event["rcpt_to"], company_id: Email::Content.find_by(id: message_event["rcpt_meta"]["campaign_id"]).company.id).id)
            log.assign_attributes(status: message_event["type"], email: message_event["rcpt_to"], timestamp: DateTime.strptime("1318996912",'%s'))
          end
        elsif track_event.present?
          if message_event["rcpt_meta"]["booking_ids"].present?
            message_event["rcpt_meta"]["booking_ids"].each do |booking_id|
              log = BookingEmailLog.find_by(transmission_id: message_event["transmission_id"], booking_id: booking_id)
              if log && message_event["type"] == "open"
                log.update(opens: log.opens + 1)
              elsif log && message_event["type"] == "click"
                log.update(clicks: log.clicks + 1)
              end
            end
          elsif message_event["rcpt_meta"]["campaign_id"].present? && Email::Content.find_by(id: message_event["rcpt_meta"]["campaign_id"]) && Client.find_by(email: message_event["rcpt_to"], company_id: Email::Content.find_by(id: message_event["rcpt_meta"]["campaign_id"]).company.id)
            log = ClientEmailLog.find_by(transmission_id: message_event["transmission_id"], campaign_id: message_event["rcpt_meta"]["campaign_id"], client_id: Client.find_by(email: message_event["rcpt_to"], company_id: Email::Content.find_by(id: message_event["rcpt_meta"]["campaign_id"]).company.id).id)
            if log && message_event["type"] == "open"
              log.update(opens: log.opens + 1)
            elsif message_event["type"] == "click"
              log && log.update(clicks: log.clicks + 1)
            end
          end
        # elsif gen_event.present?
        #   if message_event["rcpt_meta"]["booking_ids"].present?
        #     message_event["rcpt_meta"]["booking_ids"].each do |booking_id|

        #     end
        #   elsif message_event["rcpt_meta"]["campaign_id"].present?

        #   end
        # elsif unsubscribe_event.present?
        #   if message_event["rcpt_meta"]["booking_ids"].present?
        #     message_event["rcpt_meta"]["booking_ids"].each do |booking_id|

        #     end
        #   elsif message_event["rcpt_meta"]["campaign_id"].present?

        #   end
        # elsif relay_event.present?
        #   if message_event["rcpt_meta"]["booking_ids"].present?
        #     message_event["rcpt_meta"]["booking_ids"].each do |booking_id|

        #     end
        #   elsif message_event["rcpt_meta"]["campaign_id"].present?

        #   end
        end
      end
    end
  end
end
