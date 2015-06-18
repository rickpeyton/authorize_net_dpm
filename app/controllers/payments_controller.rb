class PaymentsController < ApplicationController

  layout 'authorize_net'
  helper :authorize_net
  protect_from_forgery :except => :relay_response
  NGROK = "http://84df53b0.ngrok.io"

  # GET
  # Displays a payment form.
  def payment
    @amount = 10.00
    @sim_transaction = AuthorizeNet::SIM::Transaction.new(
      AUTHORIZE_NET_CONFIG['api_login_id'],
      AUTHORIZE_NET_CONFIG['api_transaction_key'],
      @amount, :relay_url => NGROK + "/payments/relay_response",
      :transaction_type => "AUTH_ONLY"
    )
  end

  # POST
  # Returns relay response when Authorize.Net POSTs to us.
  def relay_response
    sim_response = AuthorizeNet::SIM::Response.new(params)
    binding.pry
    if sim_response.success?(
      AUTHORIZE_NET_CONFIG['api_login_id'],
      AUTHORIZE_NET_CONFIG['merchant_hash_value']
    )
      render :text => sim_response.direct_post_reply(
        payments_receipt_url(:only_path => false),
        :include => true
      )
    else
      render
    end
  end

  # GET
  # Displays a receipt.
  def receipt
    @auth_code = params[:x_auth_code]
  end

end
