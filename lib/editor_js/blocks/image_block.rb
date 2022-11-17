# frozen_string_literal: true

module EditorJs
  module Blocks
    # image block
    class ImageBlock < Base
      def schema
        YAML.safe_load(<<~YAML)
          type: object
          additionalProperties: true
          properties:
            caption:
              type: string
            file:
              type: object
              additionalProperties: true
              properties:
                url:
                  type: string
            stretched:
              type: boolean
            withBackground:
              type: boolean
            withBorder:
              type: boolean
          required:
          - file
        YAML
      end

      def render(_options = {})
        content_tag :div, class: css_name do
          url = data['file']['url']
          caption = data['caption']
          withBorder = data['withBorder']
          withBackground = data['withBackground']
          stretched = data['stretched']

          html_class = "#{css_name}__picture"
          html_class += " #{css_name}__picture--stretched" if stretched
          html_class += " #{css_name}__picture--with-background" if withBackground
          html_class += " #{css_name}__picture--with-border" if withBorder

          html_str = content_tag :div, class: html_class do
            content_tag :img, '', src: url
          end
          html_str << content_tag(:div, caption.html_safe, class: "#{css_name}__caption").html_safe
        end
      end

      def sanitize!
        %w[caption url].each do |key|
          str = Sanitize.fragment(data[key], remove_contents: true).strip
          str.gsub!('&amp;', '&') if key == 'url'
          data[key] = str
        end
      end

      def plain
        decode_html data['caption'].strip
      end
    end
  end
end
