module Jekyll
  class CollapsibleTagBlock < Liquid::Block

    def render(context)
      @text = super

      <<~COLLAPSIBLEBLOCK
      <div>
        <button class='toggle-collapsible'>Toggle solution</button>
        <div class="collapsible-content">
          #{@text}
        </div>
      </div>
      COLLAPSIBLEBLOCK

      # pipe param through liquid to make additional replacements possible
      #content = Liquid::Template.parse(contents).render context

    end

  end
end

Liquid::Template.register_tag('collapsible', Jekyll::CollapsibleTagBlock)