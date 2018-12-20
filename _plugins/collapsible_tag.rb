module Jekyll
  class CollapsibleTagBlock < Liquid::Block

    def render(context)
      @text = super

      # pipe param through liquid to make additional replacements possible
      #text = Liquid::Template.parse(text).render context

      <<~COLLAPSIBLEBLOCK
      <div>
        <button class='toggle-collapsible'>Toggle solution</button>
        <div class="collapsible-content">
          #{@context.registers[:site].find_converter_instance(::Jekyll::Converters::Markdown).convert(@text)}
        </div>
      </div>
      COLLAPSIBLEBLOCK

    end

  end
end

Liquid::Template.register_tag('collapsible', Jekyll::CollapsibleTagBlock)