# encoding: utf-8

require_relative 'element'

module Fidgit
  class Label < Element
    DEFAULT_BACKGROUND_COLOR = Gosu::Color.rgba(0, 0, 0, 0)
    DEFAULT_BORDER_COLOR = Gosu::Color.rgba(0, 0, 0, 0)
    DEFAULT_COLOR = Gosu::Color.rgb(255, 255, 255)

    attr_reader :color, :background_color, :border_color, :text, :icon

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
    #
    # @option (see Element#initialize)
    # @option options [Gui::Icon, Gosu::Image, nil] :icon (nil)
    # @option options [String] :text ('')
    def initialize(parent, options = {}, &block)
      options = {
        text: '',
        color: DEFAULT_COLOR,
        background_color: DEFAULT_BACKGROUND_COLOR,
        border_color: DEFAULT_BORDER_COLOR
      }.merge! options

      @text = options[:text].dup
      @icon = options[:icon]
      @color = options[:color].dup

      super(parent, options)
    end

    def draw_foreground
      current_x = x + padding_x
      if @icon
        @icon.draw(current_x, y + padding_y, z)
        current_x += @icon.width + padding_x
      end

      unless @text.empty?
        font.draw(@text, current_x, y + padding_y, z, 1, 1, @color)
      end

      nil
    end

    protected
    def layout
      if @icon
        if @text.empty?
          rect.width = [@icon.width + padding_x * 2, width].max
          rect.height = [@icon.height + padding_y * 2, height].max
        else
          rect.width = [@icon.width + font.text_width(@text) + padding_x * 3, width].max
          rect.height = [[@icon.height, font_size].max + padding_y * 2, height].max
        end
      else
        if @text.empty?
          rect.width = [padding_x * 2, width].max
          rect.height = [padding_y * 2, height].max
        else
          rect.width = [font.text_width(@text) + padding_x * 2, width].max
          rect.height = [font_size + padding_y * 2, height].max
        end
      end

      nil
    end
  end
end