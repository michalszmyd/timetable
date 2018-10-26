require 'jwt'

class JwtService
  SECRET    = Rails.application.secrets.jwt[:secret]
  ALGORITHM = 'HS256'.freeze

  def self.encode(payload:)
    JWT.encode(payload, SECRET, ALGORITHM)
  end

  def self.decode(token:)
    JWT.decode(token, SECRET, true, algorithm: ALGORITHM).first
  end
end
