module Jekyll
  class CollapsibleTagBlock < Liquid::Block

    def render(context)
      contents = super

      output = '<button class="toggle-collapsible">Toggle solution</button>'
      output += '<div class="collapsible-content">'
      output += contents
      output += '</div>'

      # pipe param through liquid to make additional replacements possible
      output = Liquid::Template.parse(output).render context

      # return output
      output
    end

  end
end

Liquid::Template.register_tag('collapsible', Jekyll::CollapsibleTagBlock)