class PaymentsController < ApplicationController

  layout 'authorize_net'
  helper :authorize_net
  protect_from_forgery :except => :relay_response

  # Available transaction_type(s)
    # AUTHORIZE_AND_CAPTURE = "AUTH_CAPTURE"
    # AUTHORIZE_ONLY = "AUTH_ONLY"
    # CAPTURE_ONLY = "CAPTURE_ONLY"
    # CREDIT = "CREDIT"
    # PRIOR_AUTHORIZATION_AND_CAPTURE = "PRIOR_AUTH_CAPTURE"
    # VOID = "VOID"

  # Test Card Numbers
    # American Express Test Card 370000000000002
    # Discover Test Card 6011000000000012
    # JCB 3088000000000017
    # Diners Club/ Carte Blanche 38000000000006
    # MasterCard 5424000000000015
    # Visa Test Card 4007000000027 or 4012888818888

  NGROK = "http://8a8be456.ngrok.io"

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
    @hidden_fields = hidden_fields
  end

  # POST
  # Returns relay response when Authorize.Net POSTs to us.
  def relay_response
    sim_response = AuthorizeNet::SIM::Response.new(params)
    if sim_response.success?(
      AUTHORIZE_NET_CONFIG['api_login_id'],
      AUTHORIZE_NET_CONFIG['merchant_hash_value']
    )

      OrderTransaction.create(
        action: "authorization",
        amount: sim_response.fields[:amount],
        success: true,
        authorization: sim_response.authorization_code,
        transaction_number: sim_response.transaction_id,
        params: params,
        message: sim_response.fields[:response_reason_text]
      )

      capture = AuthorizeNet::AIM::Transaction.new(
        AUTHORIZE_NET_CONFIG['api_login_id'],
        AUTHORIZE_NET_CONFIG['api_transaction_key'],
        :gateway => :sandbox
      )

      capture.prior_auth_capture(sim_response.transaction_id)

      render :text => sim_response.direct_post_reply(
        payments_receipt_url(:only_path => false),
        :include => true
      )


    else

      OrderTransaction.create(
        action: "authorization",
        amount: sim_response.fields[:amount],
        success: false,
        authorization: nil,
        transaction_number: sim_response.transaction_id,
        params: params,
        message: sim_response.fields[:response_reason_text] + " CODE: " + sim_response.fields[:response_reason_code]
      )

      render
    end
  end

  # GET
  # Displays a receipt.
  def receipt
    @auth_code = params[:x_auth_code]
  end

  def hidden_fields
    {
      x_invoice_num: "ORDER_NUMBER",
      x_description: "AO Proof of concept authorization",
      x_first_name: "John",
      x_last_name: "Doe",
      x_address: "2427 1st Avenue North",
      x_city: "Birmingham",
      x_state: "AL",
      x_zip: "35203",
      x_phone: "205-538-0240",
      x_email: "rick@motionmobs.com",
      x_cust_id: "USER_ID",
      x_ship_to_first_name: "",
      x_ship_to_last_name: "",
      x_ship_to_company: "",
      x_ship_to_address: "",
      x_ship_to_city: "",
      x_ship_to_state: "",
      x_ship_to_zip: "",
      x_po_num: "ORDER_NUMBER"
    }
  end

end
