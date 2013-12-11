require 'savon'
require 'json'

class WSItimSession
  attr_reader :host, :port, :context_root, :protocol, :ssl_verify, :definitive_url, :authenticate
  attr_accessor :connection_to_host_timeout

  def initialize(host, port, context, protocol="http", ssl_verify=:none)
    @host = host
    @port = port
    @context_root = context
    @protocol = protocol
    @ssl_verify = ssl_verify
    @connection_valid = false
    @connection_to_host_timeout = 5
    @definitive_url = "#{@protocol}://#{@host}:#{@port}/#{@context_root}/services/WSSessionService?WSDL"
    @authenticate = false

    dowloadWSDL

  end

  def to_s
    "#{@definitive_url} -> SSL VERIFY: #{@ssl_verify}"
  end

  def dowloadWSDL
    begin
      @client = Savon.client(wsdl: "#{@definitive_url}",open_timeout: @connection_to_host_timeout, read_timeout: @connection_to_host_timeout, ssl_verify_mode: @ssl_verify)
      #Call only to verify the connection
      @client.operations
      @connection_valid = true
    rescue Exception => e
      @connection_valid = false
      p "[WSItimSession::dowloadWSDL][ERROR] - #{e.message}"
    end
  end

  def is_connection_valid?
    @connection_valid
  end

  def is_authenticate_session?
    @authenticate
  end

  def login(username, password)
    begin
      if(@connection_valid)
        response = @client.call(:login, message: {username: username, password: password})
        if response.success?
          @session_id = response.body[:login_response][:login_return][:session_id]
          @client_session = response.body[:login_response][:login_return][:client_session]
          @enforce_challenge = response.body[:login_response][:login_return][:enforce_challenge_response]
          @locale = response.body[:login_response][:login_return][:locale]
          @authenticate = true
          return true
        end
      end
    rescue Exception => e
      p "[WSItimSession::login][ERROR] - #{e.message}"
    end

    false

  end

  def logout
    if(@connection_valid && @authenticate)
      @session_id = nil
      @client_session = nil
      @enforce_challenge = nil
      @locale = nil
      @authenticate = false
    end
  end

  def get_itim_version
    if(@connection_valid)
      response = @client.call(:get_itim_version)
      if response.success?
        return response.body[:get_itim_version_response][:get_itim_version_return]
      end
    end

    false
  end

  def get_itim_version_info(useJson = false)
    if(@connection_valid)
      response = @client.call(:get_itim_version_info)
      if response.success?
        itim_version_info = response.body[:get_itim_version_info_response][:get_itim_version_info_return]
        if(useJson)
          return itim_version_info.to_json
        end
        return itim_version_info
      end
    end

    false
  end

end