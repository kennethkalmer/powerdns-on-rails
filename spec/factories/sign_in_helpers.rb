module SignInHelpers
  def tokenize_as( token )
    @request.session[:token_id] = token ? token.id : nil
  end
end
