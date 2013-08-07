require "json"

class CookieAdapter

  EXPIRES = Time.now + 31536000 # One year from now

  def initialize(context)
    @cookies = context.send(:cookies)
    @request = context.send(:request)
    @response = context.send(:response)
  end

  def [](key)
    hash[key]
  end

  def []=(key, value)
    set_cookie(hash.merge(key => value))
  end

  def delete(key)
    set_cookie(hash.tap { |h| h.delete(key) })
  end

  def keys
    hash.keys
  end

  def hostname
    if @request.host == 'localhost'
      return false
    else
      return @request.host
    end
  end

  private

  def set_cookie(value)
    @response.set_cookie 'split', {
      :value => JSON.generate(value),
      :expires => EXPIRES,
      :path => '/',
      :domain => hostname,
      :httponly => true
    }
  end

  def hash
    if @cookies[:split]
      begin
        JSON.parse(@cookies[:split])
      rescue JSON::ParserError
        {}
      end
    else
      {}
    end
  end

end
