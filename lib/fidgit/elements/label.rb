# encoding: utf-8

require_relative 'element'

module Fidgit
  class Label < Element
    attr_accessor :color, :background_color, :border_color
    attr_reader :text, :icon

    def text=(value)
      @text = value
      recalc
      nil
    end

    def icon=(value)
      @icon = value
      recalc
      nil
    end

    # @param (see Element#initialize)
    # @param [String] text The string to display in the label.
    #
    # @option (see Element#initialize)
    # @option options [Fidgit::Thumbnail, Gosu::Image, nil] :icon (nil)
    def initialize(text, options = {})
      options = {
        color: default(:color),
        background_color: default(:background_color),
        border_color: default(:border_color),
      }.merge! options

      @text = text.dup
      @icon = options[:icon]
      @color = options[:color].dup

      super(options)
    end

    def draw_foreground
      current_x = x + padding_left
      if @icon
        @icon.draw(current_x, y + padding_top, z)
        current_x += @icon.width + padding_left
      end

      unless @text.empty?
        font.draw(@text, current_x, y + padding_top, z, 1, 1, @color)
      end

      nil
    end

    protected
    def layout
      if @icon
        if @text.empty?
          rect.width = [@icon.width + padding_left + padding_right, width].max
          rect.height = [@icon.height + padding_top + padding_bottom, height].max
        else
          rect.width = [@icon.width + font.text_width(@text) + padding_left + padding_right, width].max
          rect.height = [[@icon.height, font_size].max + padding_top + padding_bottom, height].max
        end
      else
        if @text.empty?
          rect.width = [padding_left + padding_right, width].max
          rect.height = [padding_top + padding_bottom, height].max
        else
          rect.width = [font.text_width(@text) + padding_left + padding_right, width].max
          rect.height = [font_size + padding_top + padding_bottom, height].max
        end
      end

      nil
    end
  end
end