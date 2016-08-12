(function(){
  function preservedPattern(i) {
    return "____preserved_" + i + "____";
  }

  function wrapConversion(f) {
    return function(data) {
      var preserved = [];

      // preserve Redmine macro
      data = data.replace(/\{\{.*?\}\}/g, function(match) {
        preserved.push(decodeEntities(match));
        return preservedPattern(preserved.length);
      });

      // convert
      arguments[0] = data;
      data = f.apply(this, arguments);

      // restore
      for (var i = 0; i < preserved.length; i++) {
        data = data.replace(preservedPattern(i + 1), preserved[i]);
      }

      return data;
    };
  }

  var element = document.createElement('div');
  function decodeEntities(html) {
    element.innerHTML = html;
    html = element.textContent;
    element.textContent = '';
    return html;
  }

  function onText(text, node) {
    return (node.parent.name == "a") ?
      text : text.replace(/(^|\s)https?:\/\/\S*/g, decodeEntities);
  }

  CKEDITOR.plugins.add('redmine', {
    afterInit: function(editor) {
      var processor = editor.dataProcessor;

      processor.toHtml = wrapConversion(processor.toHtml);
      processor.toDataFormat = wrapConversion(processor.toDataFormat);
      processor.htmlFilter.addRules({text: onText}, 11);
      processor.dataFilter.addRules({text: onText}, 11);
    }
  });

  CKEDITOR.on('dialogDefinition', function(e) {
    if (e.data.name == 'table') {
      var width = e.data.definition.getContents('info').get('txtWidth');
      width['default'] = "100%";
    }
  });
})();
