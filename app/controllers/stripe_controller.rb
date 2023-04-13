class StripeController < ApplicationController
  protect_from_forgery except: :webhook

  def webhook
    webhook_secret = ENV["STRIPE_WEBHOOK_SIGNING_KEY"]
    if webhook_secret.present?
      sig_header = request.env["HTTP_STRIPE_SIGNATURE"]
      payload = request.body.read

      begin
        @event = Stripe::Webhook.construct_event(payload, sig_header, webhook_secret)

        event_data = get_event_data
        metadata = get_metadata
        case @event.type
        when "payment_intent.succeeded"
          order = Order.find_by(id: metadata.order_id)
          if order.status = "pending"
            order.status = :confirmed
            order.stripe_charge_id = event_data.latest_charge
            order.save
          end
        when "payment_intent.payment_failed"
          order = Order.find_by(id: metadata.order_id)
          order.status = :failed
          order.save
        end

      rescue JSON::ParserError => e
        render status: 400, body: e.message and return
      rescue Stripe::SignatureVerificationError => e
        puts "Webhook signature verification failed."
        render status: 400, body: e.message and return
      end
    end
    render status: 200, body: "" and return
  end

  private

    def get_event_data
      @event.data.object
    end
    def get_metadata
      get_event_data.metadata
    end
end