require_relative 'helpers/example_window'

Fidgit.default_font_size = 15

class ExampleState < GuiState
  def setup
    container.background_color = Gosu::Color.rgb(50, 50, 50)
    pack :vertical  do
      full_base_directory = ''
      restricted_base_directory = File.expand_path(File.join(__FILE__, '..', '..'))
      directory = File.join(restricted_base_directory, 'media', 'images')

      my_label = label "No file loaded"
      button(text: "Load...(limited path access)") do
        FileDialog.new(:open, base_directory: restricted_base_directory, directory: directory, pattern: "*.png") do |result, file|
          case result
            when :open
              my_label.text = "Loaded #{file}"
            when :cancel
              my_label.text = "Loading cancelled"
          end
        end
      end

      button(text: "Save...(unrestricted path access)") do
        FileDialog.new(:save, base_directory: full_base_directory, directory: directory, pattern: "*.png") do |result, file|
          case result
            when :save
              my_label.text = "Saved #{file}"
            when :cancel
              my_label.text = "Save cancelled"
          end
        end
      end

    end
  end
end

ExampleWindow.new.show