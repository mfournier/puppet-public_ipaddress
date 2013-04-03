require 'timeout'
require 'open-uri'

module Facter::Util::PublicIpaddress
  def self.cache
    '/var/tmp/public_ip.fact.cache'
  end
  
  def self.can_connect? (url, wait_sec=2)
    Timeout::timeout(wait_sec) { open(url) }
    return true
    rescue Timeout::Error
      return false
    rescue
      return false
  end
  
  def self.get_ip (url, wait_sec=2, html=false)
    if can_connect? wait_sec=wait_sec, url=url
      response = open(url).read
      value = html ? response[/.*: ([^<]+)<.*/, 1] : response
      return unless response =~ /^(?:[0-9]{1,3}\.){3}[0-9]{1,3}$/
      update_cache(value) if value
      value
    end
  end
  
  def self.update_cache (value)
    if value
      File.open(cache, 'w') do |f|
        f.write(value)
      end
    end
  end
  
  def self.get_cache
    if File.exists?(cache)
      File.read(cache)
    end
  end
end
