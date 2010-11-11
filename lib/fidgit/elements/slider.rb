# encoding: utf-8

require_relative 'container'

module Fidgit
  class Slider < Composite
    # @private
    class Handle < Element
      DEFAULT_BACKGROUND_COLOR = Gosu::Color.rgb(0, 0, 100)
      DEFAULT_BORDER_COLOR = Gosu::Color.rgba(0, 0, 0, 0)

      handles :begin_drag
      handles :end_drag
      handles :update_drag

      def drag?(button); button == :left; end

      # @param (see Element#initialize)
      #
      # @option (see Element#initialize)
      def initialize(parent, options = {}, &block)
        options = {
          background_color: DEFAULT_BACKGROUND_COLOR,
          border_color: DEFAULT_BORDER_COLOR,
        }.merge! options

        super parent, options

        subscribe :begin_drag do |sender, x, y|
          # Store position of the handle when it starts to drag.
          @drag_start_pos = [x - self.x, y - self.y]
        end

        subscribe :update_drag do |sender, x, y|
          parent.handle_dragged_to x - @drag_start_pos[0], y - @drag_start_pos[1]
        end

        subscribe :end_drag do
          @drag_start_pos = nil
        end
      end
    end

    handles :changed

    DEFAULT_BACKGROUND_COLOR = Gosu::Color.rgba(0, 0, 0, 0)
    DEFAULT_BORDER_COLOR = Gosu::Color.rgba(100, 100, 100, 255)
    DEFAULT_GROOVE_COLOR = Gosu::Color.rgb(200, 200, 200)
    DEFAULT_HANDLE_COLOR = Gosu::Color.rgb(0, 100, 0)

    attr_reader :value, :range

    # @param (see Composite#initialize)
    #
    # @option (see Composite#initialize)
    # @option options [Range] :range (0.0..1.0)
    # @option options [Range] :value (minimum of :range)
    def initialize(parent, options = {}, &block)
      options = {
        range: 0.0..1.0,
        height: 25,
        background_color: DEFAULT_BACKGROUND_COLOR,
        border_color: DEFAULT_BORDER_COLOR,
        groove_color: DEFAULT_GROOVE_COLOR,
        handle_color: DEFAULT_HANDLE_COLOR,
        groove_thickness: 5,
      }.merge! options

      @range = options[:range].dup
      @groove_color = options[:groove_color].dup
      @groove_thickness = options[:groove_thickness]
      @continuous = @range.min.is_a?(Float) or @range.max.is_a?(Float)

      super(parent, options)

      @handle = Handle.new(self, width: (height / 2 - padding_x), height: height - padding_y * 2,
                           background_color: options[:handle_color])

      self.value = options.has_key?(:value) ? options[:value] : @range.min
    end

    def value=(value)
      @value = @continuous ? value.to_f : value.round
      @value = [[@value, @range.min].max, @range.max].min
      @handle.x = x + padding_x + ((width - @handle.width) * (@value - @range.min) / (@range.max - @range.min).to_f)
      publish :changed, @value

      @value
    end

    def tip
      tip = super
      tip.empty? ? @value.to_s : "#{tip}: #{@value}"
    end

    def left_mouse_button(sender, x, y)
      # In this case, x should be the centre of the handle after it has moved.
      self.value = ((x - (@handle.width / 2) - self.x) / (width - @handle.width)) * (@range.max - @range.min) + @range.min
      @mouse_down = true

      nil
    end

    def handle_dragged_to(x, y)
      # In this case, x is the left-hand side fo the handle.
      self.value = ((x - self.x) / (width - @handle.width)) * (@range.max - @range.min) + @range.min
    end

    protected
    # Prevent standard packing layout change.
    def layout
      nil
    end

    protected
    def draw_background
      super
      # Draw a groove for the handle to move along.
      draw_rect x + (@handle.width / 2), y + (height - @groove_thickness) / 2, width - @handle.width, @groove_thickness, z, @groove_color
      nil
    end

    protected
    # Use block as an event handler.
    def post_init_block(&block)
      subscribe :changed, &block
    end
  end
end