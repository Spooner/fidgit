# encoding: utf-8

require_relative 'packer'

module Fidgit
  # A vertically aligned element packing container.

  class GridPacker < Packer
    DEFAULT_CELL_BORDER_COLOR = Gosu::Color.rgba(0, 0, 0, 0)
    DEFAULT_CELL_BACKGROUND_COLOR = Gosu::Color.rgba(0, 0, 0, 0)

    # @return [Integer]
    attr_reader :num_rows
    # @return [Integer]
    attr_reader :num_columns

    # @note Currently only supports +num_columns+ mode (not +num_rows+).
    #
    # @param (see Packer#initialize)
    #
    # @option (see Packer#initialize)
    # @option options [Integer] :num_columns Maximum number of columns to use (incompatible with :num_rows)
    # @option options [Integer] :num_rows Maximum number of rows to use (incompatible with :num_columns)
    def initialize(parent, options = {})
      options = {
        cell_border_color: DEFAULT_CELL_BORDER_COLOR,
        cell_background_color: DEFAULT_CELL_BACKGROUND_COLOR,
      }.merge! options

      @num_columns = options[:num_columns]
      @num_rows = options[:num_rows]
      raise ArgumentError, "options :num_rows and :num_columns are not compatible" if @num_rows and @num_columns

      @cell_border_color = options[:cell_border_color].dup
      @cell_background_color = options[:cell_background_color].dup

      @type = @num_rows ? :fixed_rows : :fixed_columns

      super parent, options
    end

    protected
    # Rearrange the cells based on changes to the number of rows/columns or adding/removing elements.
    def rearrange
      # Calculate the number of the dynamic dimension.
      case @type
      when :fixed_rows
        @num_columns = (size / @num_rows.to_f).ceil
      when :fixed_columns
        @num_rows = (size / @num_columns.to_f).ceil
      end

      # Create an array containing all the rows.
      @rows = case @type
      when :fixed_rows
        # Rearrange the list, arranged by columns, into rows.
        rows = Array.new(@num_rows) { [] }
        @children.each_with_index do |child, i|
          rows[i % @num_rows].push child
        end
        rows
      when :fixed_columns
        @children.each_slice(@num_columns).to_a
      end

      nil
    end

    protected
    def layout
      rearrange

      @widths = Array.new(@num_columns)
      @heights = Array.new(@num_rows)

      # Calculate the maximum size of each cell.
      @rows.each_with_index do |row, row_num|
        row.each_with_index do |element, column_num|
          @widths[column_num] = [element.width, @widths[column_num] || 0].max || 0
          @heights[row_num] = [element.height, @heights[row_num] || 0].max || 0
        end
      end

      # Actually place all the elements into the grid positions.
      total_height = padding_y
      @rows.each_with_index do |row, row_num|
        total_width = padding_x

        row.each_with_index do |element, column_num|
          element.x = x + total_width
          total_width += @widths[column_num]
          total_width += spacing_x unless column_num == @num_columns - 1

          element.y = y + total_height
        end

        rect.width = total_width + padding_x if row_num == 0

        total_height += @heights[row_num] unless row.empty?
        total_height += spacing_y unless row_num == num_rows - 1
      end

      rect.height = total_height + padding_y

      nil
    end

    protected
    def draw_background
      super

      # Draw the cell backgrounds.
      unless @cell_background_color.transparent?
        current_x = x + padding_x
          @widths.each_with_index do |width, column_num|
          current_y = y + padding_y
          @heights.each_with_index do |height, row_num|
            draw_rect current_x, current_y, width, height, z, @cell_background_color if @rows[row_num][column_num]
            current_y += height + spacing_y
          end
          current_x += width + spacing_x
        end
      end

      nil
    end

    protected
    def draw_border
      super

      # Draw the cell borders.
      unless @cell_border_color.transparent?
        current_x = x + padding_x
        @widths.each_with_index do |width, column_num|
          current_y = y + padding_y
          @heights.each_with_index do |height, row_num|
            draw_frame current_x, current_y, width, height, z, @cell_border_color if @rows[row_num][column_num]
            current_y += height + spacing_y
          end
          current_x += width + spacing_x
        end
      end

      nil
    end
  end
end