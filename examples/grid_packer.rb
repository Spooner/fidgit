require_relative 'helpers/example_window'

class ExampleState < GuiState
  BORDER_COLOR = Gosu::Color.rgb(255, 0, 0)
  NUM_COLUMNS = 5
  NUM_CELLS = 48

  def setup
    pack :grid, num_columns: NUM_COLUMNS do
      NUM_CELLS.times do |i|
        label "Cell #{i}", font_size: rand(10) + 20, border_color: BORDER_COLOR
      end
    end
  end
end

ExampleWindow.new.show