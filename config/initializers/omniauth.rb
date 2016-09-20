module OmniAuth::Strategies

  class FacebookMarketplace < Facebook
    def name 
      :facebook_marketplace
    end 
  end

  class GoogleOauth2Marketplace < GoogleOauth2
    def name 
      :google_oauth2_marketplace
    end 
  end

end