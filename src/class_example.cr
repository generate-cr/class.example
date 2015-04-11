require "generate/runner"
require "generate/view"
require "./class_example/*"

module ClassExample
  class Runner < Generate::Runner
    def views
      [
       DirsView,
       SrcView,
       SpecView,
      ]
    end

    def config
      @_config ||= Config.new(raw_config[:path])
    end
  end

  struct Config
    property path

    def initialize(@path)
    end
  end

  struct View < Generate::FileView
    def full_path
      path
    end
  end

  struct DirsView < Generate::View
    def render_with_log
      ["src", "spec"].each do |dir|
        Dir.mkdir_p("#{dir}/#{config.dir}")
        logger.info "Directory #{dir}/#{config.dir}"
      end
    end
  end

  generate_template SrcView, View, "class.example", "example.cr.ecr", "src/#{config.path}.cr"
  #generate_template SpecView, View, "class.example", "example_spec.cr.ecr", "spec/#{config.path}_spec.cr"

  class RunnerFactory < Generate::RunnerFactory
    getter raw_config

    def initialize
      @raw_config = {} of Symbol => String
    end

    def parse_opts(opts)
      initialize

      opts.banner = "USAGE: generate-cr class NAME"

      opts.unknown_args do |before_double_dash, rest|
        raw_config[:path] = before_double_dash[0]
      end
    end

    def build(raw_config)
      Runner.new(raw_config)
    end

    def default_config
      {} of Symbol => String
    end
  end

  Generate::Registry.add_runner("class", RunnerFactory.new)
end
