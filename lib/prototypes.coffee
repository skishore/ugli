if not String.prototype.strip?
  String.prototype.strip = ->
    String(this).replace /^\s+|\s+$/g, ''
