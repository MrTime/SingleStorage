require 'dropbox_sdk'
require 'securerandom'

class Services::DropboxController < ApplicationController
  def new
    authorize_url = get_web_auth().start()

    redirect_to authorize_url
  end

  def auth_finish
    begin
      access_token, user_id, url_state = get_web_auth.finish(params)

      @account = DropboxAccount.new(access_token: access_token, user: current_user)
      @account.fetch_info

      if @account.save
        redirect_to accounts_path
      else
        redirect_to accounts_path, flash: {error: @account.errors.full_messages.join(',') }
      end
    rescue DropboxOAuth2Flow::BadRequestError => e
      render :text => "Error in OAuth 2 flow: Bad request: #{e}"
    rescue DropboxOAuth2Flow::BadStateError => e
      logger.info("Error in OAuth 2 flow: No CSRF token in session: #{e}")
      redirect_to new_account_path
    rescue DropboxOAuth2Flow::CsrfError => e
      logger.info("Error in OAuth 2 flow: CSRF mismatch: #{e}")
      redirect_to new_account_path, flash: { error: "CSRF error" }
    rescue DropboxOAuth2Flow::NotApprovedError => e
      redirect_to new_account_path, flash: { error: t('accounts.new.canceled') }
    rescue DropboxOAuth2Flow::ProviderError => e
      logger.info "Error in OAuth 2 flow: Error redirect from Dropbox: #{e}"
      redirect_to new_account_path, flash: { error: "Strange error." }
    rescue DropboxError => e
      logger.info "Error getting OAuth 2 access token: #{e}"
      redirect_to new_account_path, flash: { error: "Error communicating with Dropbox servers." }
    end
  end

  private

  def get_web_auth()
    redirect_uri = url_for(:action => 'auth_finish')
    DropboxOAuth2Flow.new(Rails.application.secrets.dropbox['app_key'], Rails.application.secrets.dropbox['app_secret'], redirect_uri, session, :dropbox_auth_csrf_token)
  end
end
