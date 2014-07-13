require 'google/api_client'

class Services::GoogledriveController < ApplicationController
  def new
    authorize_uri = api_client.authorization.authorization_uri.to_s
    redirect_to authorize_uri
  end

  def auth_finish
    if params[:code]
      api_client.authorization.code = params[:code]
      api_client.authorization.fetch_access_token!

      @account = GoogledriveAccount.new(access_token: api_client.authorization.access_token, 
                                           refresh_token: api_client.authorization.refresh_token,
                                           expires_in: api_client.authorization.expires_in,
                                           issued_at: api_client.authorization.issued_at,
                                           user: current_user)
      @account.fetch_info

      if @account.save
        redirect_to accounts_path
      else
        redirect_to accounts_path, flash: {error: @account.errors.full_messages.join(',') }
      end
    elsif params[:error]
      redirect_to new_account_path, flash: { error: t('accounts.new.canceled') }
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
