# frozen_string_literal: true

module EditorJs
  module Blocks
    # table block
    class TableBlock < Base
      def schema
        YAML.safe_load(<<~YAML)
          type: object
          additionalProperties: false
          properties:
            withHeadings:
              type: boolean
            content:
              type: array
              items:
                type: array
                items:
                  type: string
        YAML
      end

      def render(_options = {})
        content_tag(:div, class: css_name) do
          content_tag(:table) do
            data['content'].map.with_index do |row, index|
              content_tag(:tr) do
                row.map do |col|
                  content_tag (data['withHeadings'] && index == 0 ? :th : :td), col.html_safe
                end.join.html_safe
              end
            end.join.html_safe
          end
        end
      end

      def safe_tags
        {
          'b' => nil,
          'i' => nil,
          'u' => ['class'],
          'del' => ['class'],
          'a' => ['href'],
          'mark' => ['class'],
          'code' => ['class'],
          'br' => nil
        }
      end

      def sanitize!
        data['content'] = data['content'].map do |row|
          (row || []).map do |cell_value|
            Sanitize.fragment(
              cell_value,
              elements: safe_tags.keys,
              attributes: safe_tags.select { |_k, v| v },
              remove_contents: false
            )
          end
        end
      end

      def plain
        str = data['content'].flatten.join(', ')
        decode_html Sanitize.fragment(str).gsub(/(, )+/, ', ').strip
      end
    end
  end
end
