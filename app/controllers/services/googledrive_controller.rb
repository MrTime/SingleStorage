require 'google/api_client'

class Services::GoogledriveController < ApplicationController
  def new
    authorize_uri = api_client.authorization.authorization_uri.to_s
    redirect_to authorize_uri
  end

  def auth_finish
    begin
      api_client.authorization.code = params[:code]
      api_client.authorization.fetch_access_token!

      @account = GoogledriveAccount.create(access_token: api_client.authorization.access_token, 
                                           refresh_token: api_client.authorization.refresh_token,
                                           expires_in: api_client.authorization.expires_in,
                                           issued_at: api_client.authorization.issued_at,
                                           user: current_user)

      redirect_to accounts_path
    rescue DropboxOAuth2Flow::BadRequestError => e
      render :text => "Error in OAuth 2 flow: Bad request: #{e}"
    rescue DropboxOAuth2Flow::BadStateError => e
      logger.info("Error in OAuth 2 flow: No CSRF token in session: #{e}")
      redirect_to(:action => 'auth_start')
    rescue DropboxOAuth2Flow::CsrfError => e
      logger.info("Error in OAuth 2 flow: CSRF mismatch: #{e}")
      render :text => "CSRF error"
    rescue DropboxOAuth2Flow::NotApprovedError => e
      render :text => "Not approved?  Why not, bro?"
    rescue DropboxOAuth2Flow::ProviderError => e
      logger.info "Error in OAuth 2 flow: Error redirect from Dropbox: #{e}"
      render :text => "Strange error."
    rescue DropboxError => e
      logger.info "Error getting OAuth 2 access token: #{e}"
      render :text => "Error communicating with Dropbox servers."
    end
  end

  private

  def api_client
    return @client unless @client.nil?
    @client = Google::APIClient.new
    @client.authorization.client_id = Rails.application.secrets.googledrive['client_id']
    @client.authorization.client_secret = Rails.application.secrets.googledrive['client_secret']
    @client.authorization.scope = ['https://www.googleapis.com/auth/drive',
                                    'https://www.googleapis.com/auth/userinfo.email',
                                    'https://www.googleapis.com/auth/userinfo.profile']
    @client.authorization.redirect_uri = url_for(:action => 'auth_finish')
    @client
  end
end
