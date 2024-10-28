module Rails
  class Application
    class Configuration < ::Rails::Engine::Configuration
      # https://github.com/rails/rails/blob/a801911a03a33af79aec0063ae76805bdabd938d/railties/lib/rails/application/configuration.rb#L504
      def secret_key_base
        p "--------------------------------------------------------"
        p "generate_local_secret?: #{generate_local_secret?}"
        p "--------------------------------------------------------"
        @secret_key_base || begin
          self.secret_key_base = if generate_local_secret?
            generate_local_secret
          else
            ENV["SECRET_KEY_BASE"] || Rails.application.credentials.secret_key_base
          end
        end
      end

      # https://github.com/rails/rails/blob/a801911a03a33af79aec0063ae76805bdabd938d/railties/lib/rails/application/configuration.rb#L514
      def secret_key_base=(new_secret_key_base)
        if new_secret_key_base.nil? && generate_local_secret?
          @secret_key_base = generate_local_secret
        elsif new_secret_key_base.is_a?(String) && new_secret_key_base.present?
          @secret_key_base = new_secret_key_base
        elsif new_secret_key_base
          p "--------------------------------------------------------"
          p "secret_key_base="
          p "new_secret_key_base: #{new_secret_key_base}"
          p "new_secret_key_base.class: #{new_secret_key_base.class}"
          p "--------------------------------------------------------"
          raise ArgumentError, "`secret_key_base` for #{Rails.env} environment must be a type of String`"
        else
          raise ArgumentError, "Missing `secret_key_base` for '#{Rails.env}' environment, set this string with `bin/rails credentials:edit`"
        end
      end

      private

      # https://github.com/rails/rails/blob/a801911a03a33af79aec0063ae76805bdabd938d/railties/lib/rails/application/configuration.rb#L632
      def generate_local_secret
        key_file = root.join("tmp/local_secret.txt")

        p "--------------------------------------------------------"
        p "generate_local_secret"
        p "File.exist?(key_file): #{File.exist?(key_file)}"
        p "--------------------------------------------------------"

        unless File.exist?(key_file)
          random_key = SecureRandom.hex(64)
          FileUtils.mkdir_p(key_file.dirname)
          File.binwrite(key_file, random_key)
        end

        File.binread(key_file)
      end
    end
  end
end
