# frozen_string_literal: true

require 'erubi'
require 'erubi/capture_block'

module Recipes
  class Renderer
    def initialize(output_path:, templates_path:)
      @output_path = output_path
      @templates_path = templates_path

      @output_buffer = ::String.new
    end

    def render(path, data = {})
      unless path.end_with? '.html.erb'
        path = "#{path}.html.erb"
      end

      template = ::Erubi::CaptureBlockEngine.new(
        ::File.read("#{templates_path}/#{path}"),
      )

      context = Context.new data
      context.instance_eval(template.src)
    end

    def render_with_layout(path, output:, **data)
      result = render('layout') do
        render(path, data)
      end

      ::File.write(
        "#{output_path}/#{output}",
        result,
      )
    end

    protected

    attr_reader :output_path,
                :templates_path
  end
end
