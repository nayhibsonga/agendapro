module Webhooks
  class Sparkpost::EmailsController < WebhooksController
    http_basic_authenticate_with name: "sparkpost_webhook", password: "8j1fm7b6h5ovdxhltpy0por3l5nkwxh4yi2d"

    def consume_raw
      SparkpostEmailLog.create(raw_message: params.inspect)

      json = params["_json"]

      json.each do |event|
        message_event = event["msys"]["message_event"]
        track_event = event["msys"]["track_event"]
        unsubscribe_event = event["msys"]["unsubscribe_event"]
        gen_event = event["msys"]["gen_event"]
        relay_event = event["msys"]["relay_event"]

        if message_event.present? && SparkpostStatus.find_by_event_type(message_event["type"]).present?
          sparkpost_status = SparkpostStatus.find_by_event_type(message_event["type"])
          if sparkpost_status.blacklist
            EmailBlacklist.create(email: message_event["rcpt_to"], sender: message_event["subject"], status: message_event["type"])
          end
          if message_event["rcpt_meta"].present? && message_event["rcpt_meta"]["booking_ids"].present?
            message_event["rcpt_meta"]["booking_ids"].each do |booking_id|
              log = BookingEmailLog.find_or_initialize_by(transmission_id: message_event["transmission_id"], booking_id: booking_id)
              log.assign_attributes(status: SparkpostStatus.find_by_event_type(message_event["type"]).status, recipient: message_event["rcpt_to"], timestamp: DateTime.strptime(message_event["timestamp"],'%s'), subject: message_event["subject"], progress: SparkpostStatus.find_by_event_type(message_event["type"]).progress, details: message_event["reason"])
              log.save
            end
          elsif message_event["rcpt_meta"].present? && message_event["rcpt_meta"]["campaign_id"].present? && Email::Sending.find_by(id: message_event["rcpt_meta"]["campaign_id"]) && Email::Content.find_by(id: Email::Sending.find_by(id: message_event["rcpt_meta"]["campaign_id"], sendable_type: 'Email::Content').sendable_id) && Client.find_by(email: message_event["rcpt_to"], company_id: Email::Content.find_by(id: Email::Sending.find_by(id: message_event["rcpt_meta"]["campaign_id"], sendable_type: 'Email::Content').sendable_id).company.id) && SparkpostStatus.find_by_event_type(message_event["type"]).present?
            log = ClientEmailLog.find_or_initialize_by(transmission_id: message_event["transmission_id"], campaign_id: message_event["rcpt_meta"]["campaign_id"], client_id: Client.find_by(email: message_event["rcpt_to"], company_id: Email::Content.find_by(id: Email::Sending.find_by(id: message_event["rcpt_meta"]["campaign_id"], sendable_type: 'Email::Content').sendable_id).company.id).id)
            log.assign_attributes(status: SparkpostStatus.find_by_event_type(message_event["type"]).status, recipient: message_event["rcpt_to"], timestamp: DateTime.strptime(message_event["timestamp"],'%s'), subject: message_event["subject"], progress: SparkpostStatus.find_by_event_type(message_event["type"]).progress, details: message_event["reason"])
            log.save
          end
        elsif track_event.present? && track_event["rcpt_meta"].present?
          if track_event["rcpt_meta"]["booking_ids"].present?
            track_event["rcpt_meta"]["booking_ids"].each do |booking_id|
              log = BookingEmailLog.find_by(transmission_id: track_event["transmission_id"], booking_id: booking_id)
              if log.present? && track_event["type"] == "open"
                log.update(opens: log.opens + 1)
              elsif log.present? && track_event["type"] == "click"
                log.update(clicks: log.clicks + 1)
              end
            end
          elsif track_event["rcpt_meta"]["campaign_id"].present? && Email::Sending.find_by(id: track_event["rcpt_meta"]["campaign_id"]) && Email::Content.find_by(id: Email::Sending.find_by(id: track_event["rcpt_meta"]["campaign_id"], sendable_type: 'Email::Content').sendable_id) && Client.find_by(email: track_event["rcpt_to"], company_id: Email::Content.find_by(id: Email::Sending.find_by(id: track_event["rcpt_meta"]["campaign_id"], sendable_type: 'Email::Content').sendable_id).company.id)
            log = ClientEmailLog.find_by(transmission_id: track_event["transmission_id"], campaign_id: track_event["rcpt_meta"]["campaign_id"], client_id: Client.find_by(email: track_event["rcpt_to"], company_id: Email::Content.find_by(id: Email::Sending.find_by(id: track_event["rcpt_meta"]["campaign_id"], sendable_type: 'Email::Content').sendable_id).company.id).id)
            if log.present? && track_event["type"] == "open"
              log.update(opens: log.opens + 1)
            elsif log.present? && track_event["type"] == "click"
              log.update(clicks: log.clicks + 1)
            end
          end
        end
      end
    end
  end
end
