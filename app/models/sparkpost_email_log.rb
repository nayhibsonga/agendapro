class SparkpostEmailLog < ActiveRecord::Base
  def self.update_logs
    where(pending_process: true).order(:created_at).each do |sparkpost_email_log|

      puts "SparkpostEmailLog id: #{sparkpost_email_log.id}"

      json = eval(sparkpost_email_log.raw_message)["_json"]

      # json = params["_json"]

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
            puts puts "EmailBlacklist email: #{message_event["rcpt_to"]} created"
          end
          if message_event["rcpt_meta"].present? && message_event["rcpt_meta"]["booking_ids"].present?
            message_event["rcpt_meta"]["booking_ids"].each do |booking_id|
              log = BookingEmailLog.find_or_initialize_by(transmission_id: message_event["transmission_id"], booking_id: booking_id)
              log.assign_attributes(status: SparkpostStatus.find_by_event_type(message_event["type"]).status, recipient: message_event["rcpt_to"], timestamp: DateTime.strptime(message_event["timestamp"],'%s'), subject: message_event["subject"], progress: SparkpostStatus.find_by_event_type(message_event["type"]).progress, details: message_event["reason"])
              if log.save
                puts "BookingEmailLog id: #{log.id} created"
              end
            end
          elsif message_event["rcpt_meta"].present? && message_event["rcpt_meta"]["campaign_id"].present? && Email::Sending.find_by(id: message_event["rcpt_meta"]["campaign_id"]) && Email::Content.find_by(id: Email::Sending.find_by(id: message_event["rcpt_meta"]["campaign_id"], sendable_type: 'Email::Content').sendable_id) && Client.find_by(email: message_event["rcpt_to"], company_id: Email::Content.find_by(id: Email::Sending.find_by(id: message_event["rcpt_meta"]["campaign_id"], sendable_type: 'Email::Content').sendable_id).company.id) && SparkpostStatus.find_by_event_type(message_event["type"]).present?
            log = ClientEmailLog.find_or_initialize_by(transmission_id: message_event["transmission_id"], campaign_id: message_event["rcpt_meta"]["campaign_id"], client_id: Client.find_by(email: message_event["rcpt_to"], company_id: Email::Content.find_by(id: Email::Sending.find_by(id: message_event["rcpt_meta"]["campaign_id"], sendable_type: 'Email::Content').sendable_id).company.id).id)
            log.assign_attributes(status: SparkpostStatus.find_by_event_type(message_event["type"]).status, recipient: message_event["rcpt_to"], timestamp: DateTime.strptime(message_event["timestamp"],'%s'), subject: message_event["subject"], progress: SparkpostStatus.find_by_event_type(message_event["type"]).progress, details: message_event["reason"])
            if log.save
              puts "ClientEmailLog id: #{log.id} created"
            end
          end
        elsif track_event.present? && track_event["rcpt_meta"].present?
          if track_event["rcpt_meta"]["booking_ids"].present?
            track_event["rcpt_meta"]["booking_ids"].each do |booking_id|
              log = BookingEmailLog.find_by(transmission_id: track_event["transmission_id"], booking_id: booking_id)
              if log.present? && track_event["type"] == "open"
                log.update(opens: log.opens + 1)
                puts "BookingEmailLog id: #{log.id} processed"
              elsif log.present? && track_event["type"] == "click"
                log.update(clicks: log.clicks + 1)
                puts "BookingEmailLog id: #{log.id} processed"
              end

            end
          elsif track_event["rcpt_meta"]["campaign_id"].present? && Email::Sending.find_by(id: track_event["rcpt_meta"]["campaign_id"]) && Email::Content.find_by(id: Email::Sending.find_by(id: track_event["rcpt_meta"]["campaign_id"], sendable_type: 'Email::Content').sendable_id) && Client.find_by(email: track_event["rcpt_to"], company_id: Email::Content.find_by(id: Email::Sending.find_by(id: track_event["rcpt_meta"]["campaign_id"], sendable_type: 'Email::Content').sendable_id).company.id)
            log = ClientEmailLog.find_by(transmission_id: track_event["transmission_id"], campaign_id: track_event["rcpt_meta"]["campaign_id"], client_id: Client.find_by(email: track_event["rcpt_to"], company_id: Email::Content.find_by(id: Email::Sending.find_by(id: track_event["rcpt_meta"]["campaign_id"], sendable_type: 'Email::Content').sendable_id).company.id).id)
            if log.present? && track_event["type"] == "open"
              log.update(opens: log.opens + 1)
              puts "ClientEmailLog id: #{log.id} processed"
            elsif log.present? && track_event["type"] == "click"
              log.update(clicks: log.clicks + 1)
              puts "ClientEmailLog id: #{log.id} processed"
            end


          end
        end
      end

      puts "SparkpostEmailLog id: #{sparkpost_email_log.id} OK"

      sparkpost_email_log.update(pending_process: false)
    end
  end

  def process_log
    sparkpost_email_log = self

    if sparkpost_email_log.pending_process

      puts "SparkpostEmailLog id: #{sparkpost_email_log.id}"

      json = eval(sparkpost_email_log.raw_message)["_json"]

      # json = params["_json"]

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
            puts puts "EmailBlacklist email: #{message_event["rcpt_to"]} created"
          end
          if message_event["rcpt_meta"].present? && message_event["rcpt_meta"]["booking_ids"].present?
            message_event["rcpt_meta"]["booking_ids"].each do |booking_id|
              log = BookingEmailLog.find_or_initialize_by(transmission_id: message_event["transmission_id"], booking_id: booking_id)
              log.assign_attributes(status: SparkpostStatus.find_by_event_type(message_event["type"]).status, recipient: message_event["rcpt_to"], timestamp: DateTime.strptime(message_event["timestamp"],'%s'), subject: message_event["subject"], progress: SparkpostStatus.find_by_event_type(message_event["type"]).progress, details: message_event["reason"])
              if log.save
                puts "BookingEmailLog id: #{log.id} created"
              end
            end
          elsif message_event["rcpt_meta"].present? && message_event["rcpt_meta"]["campaign_id"].present? && Email::Sending.find_by(id: message_event["rcpt_meta"]["campaign_id"]) && Email::Content.find_by(id: Email::Sending.find_by(id: message_event["rcpt_meta"]["campaign_id"], sendable_type: 'Email::Content').sendable_id) && Client.find_by(email: message_event["rcpt_to"], company_id: Email::Content.find_by(id: Email::Sending.find_by(id: message_event["rcpt_meta"]["campaign_id"], sendable_type: 'Email::Content').sendable_id).company.id) && SparkpostStatus.find_by_event_type(message_event["type"]).present?
            log = ClientEmailLog.find_or_initialize_by(transmission_id: message_event["transmission_id"], campaign_id: message_event["rcpt_meta"]["campaign_id"], client_id: Client.find_by(email: message_event["rcpt_to"], company_id: Email::Content.find_by(id: Email::Sending.find_by(id: message_event["rcpt_meta"]["campaign_id"], sendable_type: 'Email::Content').sendable_id).company.id).id)
            log.assign_attributes(status: SparkpostStatus.find_by_event_type(message_event["type"]).status, recipient: message_event["rcpt_to"], timestamp: DateTime.strptime(message_event["timestamp"],'%s'), subject: message_event["subject"], progress: SparkpostStatus.find_by_event_type(message_event["type"]).progress, details: message_event["reason"])
            if log.save
              puts "ClientEmailLog id: #{log.id} created"
            end
          end
        elsif track_event.present? && track_event["rcpt_meta"].present?
          if track_event["rcpt_meta"]["booking_ids"].present?
            track_event["rcpt_meta"]["booking_ids"].each do |booking_id|
              log = BookingEmailLog.find_by(transmission_id: track_event["transmission_id"], booking_id: booking_id)
              if log.present? && track_event["type"] == "open"
                log.update(opens: log.opens + 1)
                puts "BookingEmailLog id: #{log.id} processed"
              elsif log.present? && track_event["type"] == "click"
                log.update(clicks: log.clicks + 1)
                puts "BookingEmailLog id: #{log.id} processed"
              end

            end
          elsif track_event["rcpt_meta"]["campaign_id"].present? && Email::Sending.find_by(id: track_event["rcpt_meta"]["campaign_id"]) && Email::Content.find_by(id: Email::Sending.find_by(id: track_event["rcpt_meta"]["campaign_id"], sendable_type: 'Email::Content').sendable_id) && Client.find_by(email: track_event["rcpt_to"], company_id: Email::Content.find_by(id: Email::Sending.find_by(id: track_event["rcpt_meta"]["campaign_id"], sendable_type: 'Email::Content').sendable_id).company.id)
            log = ClientEmailLog.find_by(transmission_id: track_event["transmission_id"], campaign_id: track_event["rcpt_meta"]["campaign_id"], client_id: Client.find_by(email: track_event["rcpt_to"], company_id: Email::Content.find_by(id: Email::Sending.find_by(id: track_event["rcpt_meta"]["campaign_id"], sendable_type: 'Email::Content').sendable_id).company.id).id)
            if log.present? && track_event["type"] == "open"
              log.update(opens: log.opens + 1)
              puts "ClientEmailLog id: #{log.id} processed"
            elsif log.present? && track_event["type"] == "click"
              log.update(clicks: log.clicks + 1)
              puts "ClientEmailLog id: #{log.id} processed"
            end


          end
        end
      end

      puts "SparkpostEmailLog id: #{sparkpost_email_log.id} OK"

      sparkpost_email_log.update(pending_process: false)
    end
  end
end
