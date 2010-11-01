require_relative 'helpers/example_window'

class ExampleState < GuiState
  def setup
    pack :vertical do
      my_label = label 'No color picked'

      color_picker width: 100 do
        subscribe :changed do |sender, color|
          my_label.text = color.to_s
        end

        my_label.text = color.to_s
      end
    end
  end
end

ExampleWindow.new.show