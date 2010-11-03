# encoding: utf-8

require_relative 'composite'
require_relative 'button'

module Fidgit
  class MenuPane < Composite
    # An item within the menu.
    class Item < Button
      DEFAULT_BORDER_COLOR = Gosu::Color.rgba(0, 0, 0, 0)
      attr_reader :value, :shortcut

      # @param (see Button#initialize)
      #
      # @option (see Button#initialize)
      # @param [any] value Value if the user picks this item
      # @option options [Boolean] :enabled (true)
      # @option options [String] :shortcut ('')
      def initialize(parent, value, options = {})
        options = {
          enabled: true,
          border_color: DEFAULT_BORDER_COLOR,
        }.merge! options

        @value = value
        @enabled = [true, false].include?(options[:enabled]) ? options[:enabled] : true
        @shortcut = options[:shortcut] || ''

        super(parent, options)
      end

      def draw_foreground
        super
        unless @shortcut.empty?
          font.draw_rel("#{@shortcut}", rect.right - padding_x, y + ((height - font_size) / 2).floor, z, 1, 0, 1, 1, color)
        end

        nil
      end

      protected
      def layout
        super
        rect.width += font.text_width("  #{@shortcut}") unless @shortcut.empty?
        nil
      end
    end

    class Separator < Item
      DEFAULT_LINE_HEIGHT = 1

      # @param (see Item#initialize)
      #
      # @option (see Item#initialize)
      def initialize(parent, options = {})
        options = {
          enabled: false,
          line_height: DEFAULT_LINE_HEIGHT,
        }.merge! options

        @line_height = options[:line_height]

        super parent, options
      end

      protected
      def layout
        super
        rect.height = @line_height
        nil
      end
    end

    DEFAULT_BACKGROUND_COLOR = Gosu::Color.rgb(50, 50, 50)

    def index(value); @items.index find(value); end
    def size; @items.size; end
    def [](index); @items[index]; end

    # @option (see Composite#initialize)
    def initialize(options = {}, &block)
      options = {
        background_color: DEFAULT_BACKGROUND_COLOR.dup,
        z: Float::INFINITY,
      }.merge! options

      super(nil, options)

      @items = pack :vertical, spacing: 0, padding: 0
    end

    def find(value)
      @items.find {|c| c.value == value }
    end

    def add_separator(options = {})
      options[:z] = z

      Separator.new(@items, options)
    end

    def add_item(value, options = {})
      options[:z] = z
      item = Item.new(@items, value, options)

      item.subscribe :left_mouse_button, method(:item_selected)
      item.subscribe :right_mouse_button, method(:item_selected)

      item
    end

    def item_selected(sender, x, y)
      publish(:selected, sender.value)

      $window.game_state_manager.current_game_state.hide_menu

      nil
    end

    protected
    def layout
      super
      if @items
        max_width = @items.each.to_a.map {|c| c.width }.max || 0
        @items.each {|c| c.rect.width = max_width }
      end

      nil
    end
  end
end