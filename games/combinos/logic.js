var RawBlockData = combinos.RawBlockData;
// This file adds a few basic functions as globals or prototypes.

function assert(clause, message) {
  if (!clause) {
    throw new Error(message);
  }
}

// Returns true if this array equals the other, element-by-element.
arraysEqual = function(first, second) {
  return !(first < second) && !(second < first);
}

function extend(child, parent) {
  for (var key in parent) {
    if (parent.hasOwnProperty(key)) {
      child[key] = parent[key];
    }
  }
  function ctor() {
    this.constructor = child;
  }
  ctor.prototype = parent.prototype;
  child.prototype = new ctor();
  child.prototype.__super__ = parent.prototype;
}

var Action = function() {
"use strict";

var Action = {
  NUMACTIONS: 8,

  LEFT: 0,
  RIGHT: 1,
  DOWN: 2,
  ROTATE_CW: 3,
  ROTATE_CCW: 4,
  DROP: 5,
  HOLD: 6,
  START: 7,
}

Action.labels = [
  'Left',
  'Right',
  'Down',
  'Rotate CW',
  'Rotate CCW',
  'Drop',
  'Hold',
  'Start',
];

Action.repeats = [true, true, true, false, false, false, false, false];

Action.doesActionRepeat = function(action) {
  assert(
      0 <= action && action < Action.NUMACTIONS,
      "Invalid action: " + action);
  return this.repeats[action];
}

return Action;
}();

var Key = (function() {
"use strict";

var Key = {
  keyNames: {
    8: 'Backspace',
    9: 'Tab',
    13: 'Enter',
    16: 'Shift',
    17: 'Ctrl',
    18: 'Alt',
    19: 'Pause/break',
    20: 'Caps lock',
    27: 'Escape',
    32: 'Space',
    33: 'Page up',
    34: 'Page down',
    35: 'End',
    36: 'Home',
    37: 'Left',
    38: 'Up',
    39: 'Right',
    40: 'Down',
    45: 'Insert',
    46: 'Delert',
    48: '0',
    49: '1',
    50: '2',
    51: '3',
    52: '4',
    53: '5',
    54: '6',
    55: '7',
    56: '8',
    57: '9',
    65: 'A',
    66: 'B',
    67: 'C',
    68: 'D',
    69: 'E',
    70: 'F',
    71: 'G',
    72: 'H',
    73: 'I',
    74: 'J',
    75: 'K',
    76: 'L',
    77: 'M',
    78: 'N',
    79: 'O',
    80: 'P',
    81: 'Q',
    82: 'R',
    83: 'S',
    84: 'T',
    85: 'U',
    86: 'V',
    87: 'W',
    88: 'X',
    89: 'Y',
    90: 'Z',
    91: 'Left meta',
    92: 'Right meta',
    93: 'Select',
    96: 'Numpad 0',
    97: 'Numpad 1',
    98: 'Numpad 2',
    99: 'Numpad 3',
    100: 'Numpad 4',
    101: 'Numpad 5',
    102: 'Numpad 6',
    103: 'Numpad 7',
    104: 'Numpad 8',
    105: 'Numpad 9',
    106: 'Multiply',
    107: '+',
    109: '-',
    110: 'Decimal point',
    111: '/',
    112: 'F1',
    113: 'F2',
    114: 'F3',
    115: 'F4',
    116: 'F5',
    117: 'F6',
    118: 'F7',
    119: 'F8',
    120: 'F9',
    121: 'F10',
    122: 'F11',
    123: 'F12',
    144: 'Num-lock',
    145: 'Scroll-lock',
    186: ';',
    187: '=',
    188: ',',
    189: '-',
    190: '.',
    191: '/',
    192: '`',
    219: '[',
    220: '\\',
    221: ']',
    222: "'",
  },

  // Key bindings are objects mapping keys to the actions that they perform.
  defaultKeyBindings: {
    38: Action.ROTATE_CW,
    39: Action.RIGHT,
    40: Action.DOWN,
    37: Action.LEFT,
    32: Action.DROP,
    16: Action.HOLD,
    13: Action.START,
    18: Action.ROTATE_CCW,
    80: Action.START,
    90: Action.ROTATE_CCW,
    88: Action.ROTATE_CW,
    67: Action.HOLD,
  },

  loadKeyBindings: function() {
    if ($.cookie) {
      $.cookie.json = true;
      var savedKeyBindings = $.cookie('savedKeyBindings');
      return (savedKeyBindings ? savedKeyBindings : this.defaultKeyBindings);
    }
    return this.defaultKeyBindings;
  },

  saveKeyBindings: function(keyBindings) {
    if ($.cookie) {
      $.cookie.json = true;
      $.cookie('savedKeyBindings', keyBindings);
    }
  },
};

return Key;
})();

var Options = function() {
"use strict";

var Options = function(board, target) {
  this.board = board;
  this.elements = this.build(target);
}

Options.prototype.build = function(target) {
  var that = this;
  var result = {target: target};

  target.attr('tabindex', 2);

  // Construct a modal structure within the target.
  target.addClass('modal fade');
  var dialog = $('<div>').addClass('modal-dialog');
  var content = $('<div>').addClass('modal-content');
  var header = $('<div>').addClass('modal-header')
    .append($('<h4>').text('Edit key bindings'));
  var body = $('<div>').addClass('modal-body');
  var footer = $('<div>').addClass('modal-footer');

  // Create the key-bindings form with a tag input for each action.
  result.form = $('<form>').addClass('form-horizontal');
  body.append(result.form);

  // Create buttons required to hide the modal.
  footer.append(
    $('<a>').addClass('btn btn-danger btn-sm restore-defaults-button')
        .text('Restore defaults')
        .click(function(e) { that.show(true); }),
    $('<a>').addClass('btn btn-primary btn-sm').text('Apply')
        .click(function(e) { that.hide(true); }),
    $('<a>').addClass('btn btn-default btn-sm').text('Cancel')
        .click(function(e) { that.hide(false); })
  );
  target.append(dialog.append(content.append(header, body, footer)));

  // Add in the button required to show the form.
  target.after(
    $('<a>').addClass('btn btn-primary btn-sm').text('Edit key bindings')
        .click(function(e) { that.show(false); })
  );

  target.on('hidden.bs.modal', function () { that.board.target.focus(); });
  return result;
}

Options.prototype.show = function(restore) {
  if (restore) {
    this.keyBindings = $.extend({}, Key.defaultKeyBindings);
  } else {
    this.keyBindings = $.extend({}, this.board.repeater.keyBindings);
  }
  this.keyElements = {};

  this.elements.form.empty();
  for (var i = 0; i < Action.NUMACTIONS; i++) {
    this.elements.form.append(this.buildAction(i));
  }

  if (!restore) {
    this.elements.target.modal('show');
  }
}

Options.prototype.hide = function(save) {
  if (save) {
    Key.saveKeyBindings(this.keyBindings);
    this.board.repeater.setKeyBindings(this.keyBindings);
  }
  this.elements.target.modal('hide');
}

Options.prototype.buildAction = function(action) {
  var that = this;

  var result = $('<div>').addClass('form-group');
  var label = $('<label>')
    .addClass('col-sm-4 control-label')
    .text(Action.labels[action] + ':');
  // Create the keys tag input element.
  var tagInput = $('<div>').addClass('col-sm-8 keys-list');
  var button = $('<a>')
    .addClass('btn btn-primary btn-sm')
    .data('action', action)
    .text('+');
  button.click(function(e) { that.waitForKey(e, button); });
  tagInput.append(button);
  // Build a tag box for each key assigned to this action.
  var keys = [];
  for (var key in this.keyBindings) {
    if (this.keyBindings[key] === action) {
      keys.push(key);
    }
  }
  keys.sort();
  for (var i = 0; i < keys.length; i++) {
    tagInput.append(this.buildKey(action, keys[i]));
  }
  // Return the final action input.
  result.append(label, tagInput);
  return result;
}

Options.prototype.buildKey = function(action, key) {
  if (this.keyElements.hasOwnProperty(key)) {
    this.keyElements[key].remove();
  }
  var that = this;
  var result = $('<a>')
    .addClass('btn btn-default btn-sm')
    .data('key', key)
    .click(function() {
      delete that.keyBindings[key];
      this.remove();
    })
    .text(Key.keyNames[key] || 'Keycode ' + key)
    .append($('<span>').addClass('close-button').html('&times;'));
  this.keyBindings[key] = action;
  this.keyElements[key] = result;
  return result;
}

Options.prototype.signalReady = function(button) {
  button.removeClass('btn-info').addClass('btn-default').text('+');
  this.waitingButton = undefined;
  this.elements.target.unbind('keydown');
}

Options.prototype.signalWait = function(button) {
  var that = this;
  button.removeClass('btn-default').addClass('btn-info').text('Press a key...');
  this.waitingButton = button;
  this.elements.target.keydown(function(e) { that.getKey(e, button); });
}

Options.prototype.waitForKey = function(e, button) {
  var repeat = button === this.waitingButton;
  if (this.waitingButton) {
    this.signalReady(this.waitingButton);
  }
  if (!repeat) {
    this.signalWait(button);
  }
}

Options.prototype.getKey = function(e, button) {
  this.signalReady(button);
  var key = this.keyCode(e);
  if (key !== 27) {
    // We don't allow the user to assign escape to a button.
    this.addKey(button, key);
  }
  e.preventDefault();
}

Options.prototype.keyCode = function(e) {
  e = e || window.event;
  e.bubbles = false;
  return e.keyCode;
}

Options.prototype.addKey = function(button, key) {
  var children = button.parent().children();
  for (var i = 1; i < children.length; i++) {
    var existingKey = parseInt($(children[i]).data('key'), 10);
    if (existingKey === key) {
      // TODO(skishore): Flash this element.
      return;
    } else if (existingKey > key) {
      break;
    }
  }
  var action = parseInt(button.data('action'), 10);
  $(children[i - 1]).after(this.buildKey(action, key));
}

return Options;
}();

var Color = (function() {
"use strict";

var Color = {
  BLACK: '#000000',
  WHITE: '#FFFFFF',
  BORDER: '#44FF44',
  LAMBDA: 0.36,
  MAX: 29,

  HEXREGEX: /\#([0-9a-f][0-9a-f])([0-9a-f][0-9a-f])([0-9a-f][0-9a-f])/i,

  initialize: function(colorCode) {
    this.body_colors = [];
    this.edge_colors = [];
    // Push color 0, which is always black.
    this.pushColor(this.BLACK);
    // Push colors for squares that are on the board.
    for (var i = 0; i < this.MAX; i++) {
      this.pushColor(colorCode(i));
    }
    // Push lighter colors for squares in currently active blocks.
    for (var i = 0; i < this.MAX; i++) {
      this.pushColor(this.mix(colorCode(i), this.WHITE, Color.LAMBDA));
    }
    // Create a CSS stylesheet with rules for combinos-square-i for each i.
    var rules = [];
    for (var i = 0; i <= 2*this.MAX; i++) {
      rules.push(
        '.combinos .square-' + i + ' {\n' +
        '  background-color: ' + this.body_colors[i] + ';\n' +
        '  border-color: ' + this.edge_colors[i] + ';\n' +
        '}');
    }
    for (var i = 2*this.MAX + 1; i <= 3*this.MAX; i++) {
      var color = this.body_colors[i - Color.MAX];
      rules.push(
        '.combinos .square-' + i + ' {\n' +
        '  background: repeating-linear-gradient(45deg, black, black 1.4px, ' +
        color + ' 1.4px, ' + color + ' 2.8px, black 2.8px, black 4.2px);\n' +
        '  border-color: ' + this.edge_colors[0] + ';\n' +
        '}');
    }
    this.addStyle(rules.join('\n'));
  },

  pushColor: function(color) {
    this.body_colors.push(color);
    this.edge_colors.push(this.lighten(color));
  },

  addStyle: function(rules) {
    var style = document.createElement('style');
    style.type = 'text/css';
    style.innerHTML = rules;
    document.getElementsByTagName('head')[0].appendChild(style);
  },

  mix: function(color1, color2, l) {
    var rgb1 = this.fromString(color1);
    var rgb2 = this.fromString(color2);

    var new_rgb = new Array(3);
    for (var i = 0; i < 3; i++) {
      new_rgb[i] = (1 - l)*rgb1[i] + l*rgb2[i];
      new_rgb[i] = Math.floor(Math.max(Math.min(new_rgb[i], 255), 0));
    }
    return this.toString(new_rgb);
  },

  fromString: function(hex6) {
    var m = this.HEXREGEX.exec(hex6);
    if (m === null) {
      throw new Error("Invalid hex6 color string: " + hex6);
    }
    return [parseInt(m[1], 16), parseInt(m[2], 16), parseInt(m[3], 16)];
  },

  toString: function(rgb) {
    var result = '#';
    for (var i = 0; i < 3; i++) {
      result += ('00' + rgb[i].toString(16)).substr(-2);
    }
    return result;
  },

  lighten: function(color) {
    return Color.mix(color, Color.WHITE, Color.LAMBDA);
  },

  tint: function(color) {
    return Color.mix(Color.WHITE, color, Color.LAMBDA);
  },

  colorCode: function(index) {
    return Color.mix(Color.rainbowCode(index), Color.WHITE, 0.8*Color.LAMBDA);
  },

  rainbowCode: function(index) {
    switch(index) {
      case 0: return '#FFFFFF';
      case 1: return '#DDDDDD';
      case 2: return '#CCCCCC';
      case 3: return '#FFFF00';
      case 4: return '#BBBBBB';
      case 5: return '#87CEEB';
      case 6: return '#FA8072';
      case 7: return '#DDA0DD';
      case 8: return '#FFD700';
      case 9: return '#DA70D6';
      case 10: return '#98FB98';
      case 11: return '#AAAAAA';
      case 12: return '#4169E1';
      case 13: return '#FF0000';
      case 14: return '#0000FF';
      case 15: return '#B21111';
      case 16: return '#8B0011';
      case 17: return '#00008B';
      case 18: return '#FF00FF';
      case 19: return '#800080';
      case 20: return '#D284BC';
      case 21: return '#FF8C00';
      case 22: return '#20B2AA';
      case 23: return '#B8860B';
      case 24: return '#FF4500';
      case 25: return '#48D1CC';
      case 26: return '#9966CC';
      case 27: return '#FFA500';
      case 28: return '#00FF00';
      default: return '#000000';
    }
  },
};

return Color;
})();

var Constants = (function() {
"use strict";

var Constants = {};

// Board size constants.
// HIDDENROWS = Block.MAXBLOCKSIZE - 1;
Constants.HIDDENROWS = 10 - 1;
Constants.VISIBLEROWS = 24;
Constants.ROWS = Constants.HIDDENROWS + Constants.VISIBLEROWS;
Constants.COLS = 12;

// Screen size constants.
Constants.SQUAREWIDTH = 12;

// Game states.
Constants.PLAYING = 0;
Constants.PAUSED = 1;
Constants.GAMEOVER = 2;

// Game engine constants.
Constants.FRAMERATE = 48;
Constants.FRAMEDELAY = Math.floor(1000/Constants.FRAMERATE);
Constants.MAXFRAME = 3628800;
Constants.PAUSE = 3;
Constants.REPEAT = 0;

// Block movement constants, some of which are imported by Block.
Constants.GRAVITY = 3*Constants.FRAMERATE/4;
Constants.SHOVEAWAYS = 2;
Constants.LOCALSTICKFRAMES = Constants.FRAMERATE/2;
Constants.GLOBALSTICKFRAMES = 2*Constants.FRAMERATE;

// Block overlap codes, in order of priority.
Constants.LEFTEDGE = 0;
Constants.RIGHTEDGE = 1;
Constants.TOPEDGE = 2;
Constants.BOTTOMEDGE = 3;
Constants.OVERLAP = 4;
Constants.OK = 5;

// Preview size and animation speed.
Constants.PREVIEW = 5;
Constants.PREVIEWFRAMES = 3;

// Difficulty curve constants.
Constants.LEVELINTERVAL = 60;
Constants.MINR = 0.1;
Constants.MAXR = 0.9;
Constants.HALFRSCORE = 480;

// Points given for each number of rows cleared.
Constants.POINTS = [0, 1, 3, 7, 15, 31, 63, 79, 87, 91, 93];

return Constants;
})();

var Point = (function() {
"use strict";

var Point = function(x, y) {
  this.x = x;
  this.y = y;
}

return Point;
})();

var Block = (function() {
"use strict";

var Block = function(type) {
  if (type === undefined) {
    assert(!Block.loaded, 'new Block called without a type!');
    return;
  }

  // These properties are mutable.
  this.x = Block.prototypes[type].x;
  this.y = Block.prototypes[type].y;
  this.angle = 0;
  this.shoveaways = Constants.SHOVEAWAYS;
  this.localStickFrames = Constants.LOCALSTICKFRAMES;
  this.globalStickFrames = Constants.GLOBALSTICKFRAMES;
  this.rowsFree = 0;

  // These properties should be immutable.
  this.squares = Block.prototypes[type].squares;
  this.color = Block.prototypes[type].color;
  this.rotates = Block.prototypes[type].rotates;
  this.height = Block.prototypes[type].height;
  this.type = type;

  // Move the block to its starting position with just one row visible.
  this.x += Math.floor(Constants.COLS/2);
  this.y += Block.MAXBLOCKSIZE - this.height;
}

Block.MAXBLOCKSIZE = 10;
Block.LEVELS = RawBlockData.LEVELS;
Block.TYPES = RawBlockData.TYPES;
assert(Block.LEVELS === Block.TYPES.length, 'Unexpected number of block types');

Block.prototype.calculateHeight = function() {
  var lowest = this.squares[0].y;
  var highest = this.squares[0].y;

  for (var i = 1; i < this.squares.length; i++) {
    if (this.squares[i].y < lowest) {
      lowest = this.squares[i].y;
    } else if (this.squares[i].y > highest) {
      highest = this.squares[i].y;
    }
  }

  return highest - lowest + 1;
};

Block.prototype.checkIfRotates = function() {
  var lowest = new Point(this.squares[0].x, this.squares[0].y);
  var highest = new Point(this.squares[0].x, this.squares[0].y);

  for (var i = 1; i < this.squares.length; i++) {
    if (this.squares[i].x < lowest.x) {
      lowest.x = this.squares[i].x;
    } else if (this.squares[i].x > highest.x) {
      highest.x = this.squares[i].x;
    }
    if (this.squares[i].y < lowest.y) {
      lowest.y = this.squares[i].y;
    } else if (this.squares[i].y > highest.y) {
      highest.y = this.squares[i].y;
    }
  }

  if (highest.x - lowest.x !== highest.y - lowest.y) {
    return true;
  }

  var rotated = new Point(0, 0);
  for (i = 0; i < this.squares.length; i++) {
    rotated.x = lowest.x + highest.y - this.squares[i].y;
    rotated.y = lowest.y + this.squares[i].x - lowest.x;
    var found = false;
    for (var j = 0; j < this.squares.length; j++) {
      found = found ||
              (rotated.x === this.squares[j].x &&
               rotated.y === this.squares[j].y);
    }
    if (!found) {
      return true;
    }
  }

  return false;
}

Block.loaded = function() {
  Block.prototypes = [];

  for (var i = 0; i < Block.TYPES[Block.LEVELS - 1]; i++) {
    var data = RawBlockData.DATA[i];
    var block = new Block();
    block.x = data[0];
    block.y = data[1];
    block.angle = 0;
    var numSquares = data[2];
    assert(data.length === 2*numSquares + 4,
        'Unexpected block (index ' + i + '): ' + data);
    block.squares = [];
    for (var j = 0; j < numSquares; j++) {
      block.squares.push(new Point(data[2*j + 3], data[2*j + 4]));
    }
    // The color 0 is reserved for empty (black) squares.
    block.color = data[2*numSquares + 3] + 1;
    block.height = block.calculateHeight();
    block.rotates = block.checkIfRotates();
    Block.prototypes.push(block);
  }

  assert(Block.prototypes.length === Block.TYPES[Block.LEVELS - 1],
      'Unexpected number of blocks');
  return true;
}();

Block.prototype.getOffsets = function() {
  var result = [];

  if (this.angle % 2 === 0) {
    for (var i = 0; i < this.squares.length; i++) {
      var x = this.x + (1 - (this.angle % 4))*this.squares[i].x;
      var y = this.y + (1 - (this.angle % 4))*this.squares[i].y;
      result.push(new Point(x, y));
    }
  } else {
    for (var i = 0; i < this.squares.length; i++) {
      var x = this.x - (2 - (this.angle % 4))*this.squares[i].y;
      var y = this.y + (2 - (this.angle % 4))*this.squares[i].x;
      result.push(new Point(x, y));
    }
  }
  return result;
}

return Block;
})();

var KeyRepeater = (function() {
"use strict";

var KeyRepeater = function(pause, repeat, target) {
  this.pause = pause;
  this.repeat = repeat;

  this.setKeyBindings(Key.loadKeyBindings());

  target.attr('tabIndex', 1);
  target.keydown(this.keydown_handler());
  target.keyup(this.keyup_handler());
}

KeyRepeater.prototype.setKeyBindings = function(keyBindings) {
  this.keyBindings = keyBindings;
  this.isKeyDown = {};
  this.keyFireFrames = {};
  for (var key in this.keyBindings) {
    this.isKeyDown[key] = false;
    this.keyFireFrames[key] = -1;
  }
  this.keys = [];
}

KeyRepeater.prototype.keyCode = function(e) {
  e = e || window.event;
  e.bubbles = false;
  return e.keyCode;
}

KeyRepeater.prototype.keydown_handler = function() {
  var repeater = this;
  return function(e) {
    var key = repeater.keyCode(e);
    if (repeater.keyBindings.hasOwnProperty(key)) {
      repeater.isKeyDown[key] = true;
      e.preventDefault();
    }
  };
}

KeyRepeater.prototype.keyup_handler = function() {
  var repeater = this;
  return function(e) {
    var key = repeater.keyCode(e);
    if (repeater.keyBindings.hasOwnProperty(key)) {
      repeater.isKeyDown[key] = false;
      if (repeater.keyFireFrames[key] < 0) {
        repeater.keys.push(key);
      }
      repeater.keyFireFrames[key] = -1;
      e.preventDefault();
    }
  };
}

// Returns a list of Actions that were issued this time step.
KeyRepeater.prototype.query = function(e) {
  for (var key in this.keyBindings) {
    if (this.isKeyDown[key]) {
      if (this.keyFireFrames[key] < 0) {
        this.keys.push(key);
        this.keyFireFrames[key] = this.pause;
      } else if (this.keyFireFrames[key] === 0) {
        if (Action.doesActionRepeat(this.keyBindings[key])) {
          this.keys.push(key);
        }
        this.keyFireFrames[key] = this.repeat;
      } else {
        this.keyFireFrames[key]--;
      }
    }
  }
  var result = this.getActionsForKeys(this.keys);
  this.keys.length = 0;
  return result;
}

// Converts a list of keys into a list of distinct actions.
KeyRepeater.prototype.getActionsForKeys = function(keys) {
  var actions = [];
  var actionsSet = {};
  for (var i = 0; i < keys.length; i++) {
    var action = this.keyBindings[keys[i]];
    if (!actionsSet.hasOwnProperty(action)) {
      actions.push(action);
      actionsSet[action] = 1;
    }
  }
  return actions;
}

return KeyRepeater;
})();

var Graphics = (function() {
"use strict";

var Graphics = function(target) {
  this.squareWidth = Constants.SQUAREWIDTH;
  this.smallWidth = Math.ceil(this.squareWidth/2);
  this.border = this.squareWidth;
  this.sideboard = 7*this.smallWidth;
  this.width = Constants.COLS*this.squareWidth + this.sideboard + 2*this.border;
  this.height = Constants.VISIBLEROWS*this.squareWidth + 2*this.border;

  this.elements = this.build(target);
  assert(this.width === target.outerWidth(), 'Error: width mismatch');
  // HACK(skishore): In a Bootstrap environment, some kind of before/after
  // pseudo-element screws up the height computation.
  //assert(this.height === target.outerHeight(), 'Error: height mismatch');
  target.height(this.height - 2*(Math.floor(this.border/2) - 1));
}

// Returns a dictionary of jQuery elements that comprise the graphics.
Graphics.prototype.build = function(target) {
  var result = {};
  target.css('padding', Math.floor(this.border/2) - 1);

  var border = $('<div>').addClass('border')
  border.css('padding', Math.ceil(this.border/2) - 1);
  target.append(border);

  var outer = this.squareWidth/4;
  var inner = this.squareWidth/8;
  var buffer = outer + inner;
  var overlay_wrapper = $('<div>').addClass('overlay-wrapper').css({
    'margin': Math.ceil(this.border/2) - 1,
    'padding-top': this.squareWidth*(Constants.VISIBLEROWS/2 - 1) - buffer,
  });
  border.append(overlay_wrapper);

  result.overlay = $('<div>').addClass('overlay');
  overlay_wrapper.append(result.overlay);

  var css = {'font-size': this.squareWidth, 'width': 3*this.width/4};
  result.line1 = $('<div>').addClass('text-box').css(css)
      .css({'padding-top': outer, 'padding-bottom': inner}).text('line1');
  result.line2 = $('<div>').addClass('text-box').css(css)
      .css({'padding-top': inner, 'padding-bottom': outer}).text('line2');
  overlay_wrapper.append(result.line1, result.line2);

  var board = $('<div>').addClass('board').css({
    'height': this.squareWidth*Constants.VISIBLEROWS,
    'width': this.squareWidth*Constants.COLS,
  });
  border.append(board);

  result.board = [];
  var hiddenRows = Constants.ROWS - Constants.VISIBLEROWS;
  for (var i = 0; i < Constants.VISIBLEROWS*Constants.COLS; i++) {
    var square = $('<div>').addClass('square square-0').css({
      "height": this.squareWidth,
      "width": this.squareWidth,
    })
    board.append(square);
    result.board.push(square);
  }

  var sideboard = $('<div>').addClass('sideboard').css({
    'height': this.squareWidth*Constants.VISIBLEROWS,
    'width': this.sideboard,
  });
  border.append(sideboard);

  var padding = this.squareWidth/4;
  result.preview = $('<div>').addClass('preview').css({
    'height': 5*this.squareWidth/2*(Constants.PREVIEW + 2) - padding,
    'padding-top': padding,
  });
  sideboard.append(result.preview);

  result.hold = $('<div>').addClass('hold').css({
    'height': 4*this.squareWidth,
    'margin-left': 3*this.squareWidth/4,
    'margin-right': this.squareWidth/4,
  });
  sideboard.append(result.hold);

  result.hold_overlay = $('<div>').addClass('hold-overlay');
  result.hold.append(result.hold_overlay);

  result.score = $('<div>').addClass('score').css({
    'font-size': this.squareWidth,
    'bottom': 0,
    'right': this.squareWidth/4,
  }).text(0);
  sideboard.append(result.score);

  return result;
}

Graphics.prototype.resetDelta = function() {
  this.drawUI(this.state);
  this.delta.board = {};
}

Graphics.prototype.getSquareIndex = function(i, j) {
  assert(i >= 0 && i < Constants.ROWS && j >= 0 && j < Constants.COLS,
      'Invalid board square: (' + i + ', ' + j + ')');
  return Constants.COLS*(i - Constants.HIDDENROWS) + j;
}

Graphics.prototype.drawFreeBlock = function(target, type, x, y, w) {
  if (type >= 0) {
    var block = Block.prototypes[type];
    var light = Color.body_colors[block.color + Color.MAX];
    var dark = Color.mix(light, Color.BLACK, 0.4*Color.LAMBDA);

    var offsets = block.getOffsets();
    for (var i = 0; i < offsets.length; i++) {
      var offset = offsets[i];
      target.append($('<div>').addClass('free-square').css({
        'background-color': ((offset.x + offset.y) % 2 ? dark : light),
        'left': x + w*offset.x,
        'top': y + w*offset.y,
        'height': w,
        'width': w,
      }));
    }
  }
}

Graphics.prototype.updatePreview = function() {
  // We should never be ahead of the board in the index of the current block.
  assert(this.state.blockIndex <= this.delta.blockIndex, "Invalid blockIndex!");
  // Pop blocks that were pulled from the preview queue from state and the UI.
  while (this.state.blockIndex < this.delta.blockIndex) {
    this.state.blockIndex += 1;
    var type = this.state.preview.shift();
    this.elements.preview.children().eq('0').remove();
    if (type !== undefined) {
      // Add the block's missing height to the preview offset and scroll it.
      this.state.previewFrame = Constants.PREVIEWFRAMES;
      this.state.previewOffset +=
          Block.prototypes[type].height*this.smallWidth + this.squareWidth;
    }
  }
  // Push new blocks in the preview queue to state and to the UI.
  while (this.state.preview.length < this.delta.preview.length) {
    var type = this.delta.preview[this.state.preview.length];
    this.state.preview.push(type);
    var block = $('<div>').addClass('preview-block').css({
      'height': Block.prototypes[type].height*this.smallWidth,
      'margin-bottom': this.squareWidth,
    });
    var xOffset = 2*this.smallWidth + 3*this.squareWidth/4;
    this.drawFreeBlock(block, type, xOffset, 0, this.smallWidth);
    this.elements.preview.append(block);
  }
  assert(
      arraysEqual(this.state.preview, this.delta.preview),
      "Previews mismatched!");
}

Graphics.prototype.updatePreviewFrame = function() {
  this.state.previewOffset *=
      (this.state.previewFrame - 1)/this.state.previewFrame;
  this.elements.preview.children().eq('0').css(
      'margin-top', this.state.previewOffset);
  this.state.previewFrame -= 1;
}

Graphics.prototype.updateHeld = function() {
  var opacity = (this.delta.held ? 0.2*Color.LAMBDA : 0);
  this.elements.hold.css('opacity', 1 - 8*opacity);
  this.elements.hold_overlay.css('opacity', opacity);
  this.state.held = this.delta.held;
}

Graphics.prototype.updateHeldBlockType = function() {
  this.elements.hold.find('.free-square').remove();
  this.drawFreeBlock(
      this.elements.hold, this.delta.heldBlockType,
      2*this.smallWidth - 1, 3*this.smallWidth/4, this.smallWidth);
  this.state.heldBlockType = this.delta.heldBlockType;
}

Graphics.prototype.updateOverlay = function() {
  if (this.delta.state === Constants.PLAYING) {
    this.elements.overlay.css('background-color', 'transparent');
    this.drawText();
  } else if (this.delta.state === Constants.PAUSED) {
    this.elements.overlay.css('background-color', 'black');
    this.elements.overlay.css('opacity', 1);
    var resume = (this.delta.pauseReason === 'focus' ? 'Click' : 'Press START');
    this.drawText('-- PAUSED --', resume + ' to resume');
  } else {
    this.elements.overlay.css('background-color', 'red');
    this.elements.overlay.css('opacity', 1.2*Color.LAMBDA);
    this.drawText('-- You FAILED --', 'Press START to try again');
  }
  this.state.state = this.delta.state;
  this.state.pauseReason = this.delta.pauseReason;
}

Graphics.prototype.drawText = function(line1, line2) {
  if (!line1 && !line2) {
    this.elements.line1.hide();
    this.elements.line2.hide();
  } else {
    this.elements.line1.show().text(line1);
    this.elements.line2.show().text(line2);
  }
}

//////////////////////////////////////////////////////////////////////////////
// Public interface begins here!
//////////////////////////////////////////////////////////////////////////////

Graphics.prototype.reset = function(board) {
  // We set blockIndex to -Constants.PREVIEW so that we delete all blocks that
  // are currently queued up in the preview.
  this.state = {
    board: [],
    blockIndex: -Constants.PREVIEW,
    preview: [],
    previewFrame: 0,
    previewOffset: 0,
  };
  this.delta = {board: {}};

  // We set each cell in the board to -1 so that they will all be marked dirty
  // and redrawn during the call to flip().
  for (var i = 0; i < Constants.VISIBLEROWS*Constants.COLS; i++) {
    this.state.board.push(-1);
    var x = Math.floor(i/Constants.COLS) + Constants.HIDDENROWS;
    var y = i % Constants.COLS;
    this.delta.board[i] = board.data[x][y];
  }

  this.drawBlock(board.block);
  this.drawUI(board);
  this.flip();
}

Graphics.prototype.drawBoardSquare = function(i, j, color) {
  var k = this.getSquareIndex(i, j);
  if (k >= 0) {
    this.delta.board[k] = color;
  }
}

Graphics.prototype.drawBlock = function(block) {
  var offsets = block.getOffsets();
  var color = block.color + Color.MAX;
  var shadow = color + Color.MAX;
  for (var i = 0; i < offsets.length; i++) {
    var offset = offsets[i];
    this.drawBoardSquare(offset.y + block.rowsFree, offset.x, shadow);
  }
  for (var i = 0; i < offsets.length; i++) {
    var offset = offsets[i];
    this.drawBoardSquare(offset.y, offset.x, color);
  }
}

Graphics.prototype.eraseBlock = function(block) {
  var offsets = block.getOffsets();
  for (var i = 0; i < offsets.length; i++) {
    var offset = offsets[i];
    this.drawBoardSquare(offset.y + block.rowsFree, offset.x, 0);
  }
  for (var i = 0; i < offsets.length; i++) {
    var offset = offsets[i];
    this.drawBoardSquare(offset.y, offset.x, 0);
  }
}

Graphics.prototype.drawUI = function(board) {
  this.delta.blockIndex = board.blockIndex;
  this.delta.preview = board.preview;
  this.delta.held = board.held;
  this.delta.heldBlockType = board.heldBlockType;
  this.delta.score = board.score;
  this.delta.state = board.state;
  this.delta.pauseReason = board.pauseReason;
}

Graphics.prototype.flip = function() {
  for (var k in this.delta.board) {
    var color = this.delta.board[k];
    if (this.state.board[k] !== color) {
      var square = this.elements.board[k];
      square.attr('class', 'square square-' + color);
      this.state.board[k] = color;
    }
  }
  if (this.state.blockIndex !== this.delta.blockIndex ||
      this.state.preview.length !== this.delta.preview.length) {
    this.updatePreview();
  }
  if (this.state.previewFrame > 0 && this.state.state === Constants.PLAYING) {
    // We only scroll the preview if the game is in motion.
    this.updatePreviewFrame();
  }
  if (this.state.held !== this.delta.held) {
    this.updateHeld();
  }
  if (this.state.heldBlockType !== this.delta.heldBlockType) {
    this.updateHeldBlockType();
  }
  if (this.state.score !== this.delta.score) {
    this.elements.score.text(this.delta.score);
    this.state.score = this.delta.score;
  }
  if (this.state.state !== this.delta.state) {
    this.updateOverlay();
  }
  this.resetDelta();
}

return Graphics;
})();

var Physics = (function() {
"use strict";

var Physics = {};

// Move the block on the board. This method never modifies data or keys.
Physics.moveBlock = function(block, data, keys) {
  var shift = 0;
  var drop = 0;
  var turn = 0;
  var moved = false;

  for (var i = 0; i < keys.length; i++) {
    var key = keys[i];
    if (key === Action.RIGHT) {
      shift++;
    } else if (key === Action.LEFT) {
      shift--;
    } else if (key === Action.DOWN) {
      drop += 1;
    } else if (key === Action.ROTATE_CW && block.rotates) {
      turn = 1;
    } else if (key === Action.ROTATE_CCW && block.rotates) {
      turn = -1;
    }
  }

  if (shift !== 0) {
    block.x += shift;
    if (this.checkBlock(block, data) === Constants.OK) {
      moved = true;
    } else {
      block.x -= shift;
    }
  }

  if (turn !== 0) {
    block.angle = (block.angle + turn + 4) % 4;
    var trans = new Point(0, 0);
    while (this.checkBlock(block, data) === Constants.LEFTEDGE) {
      block.x++;
      trans.x++;
    }
    while (this.checkBlock(block, data) === Constants.RIGHTEDGE) {
      block.x--;
      trans.x--;
    }
    while (this.checkBlock(block, data) === Constants.TOPEDGE) {
      block.y++;
      trans.y++;
    }
    if (this.checkBlock(block, data) === Constants.OK) {
      moved = true;
    } else if (block.shoveaways > 0 && this.shoveaway(block, data, shift)) {
      block.shoveaways--;
      moved = true;
    } else {
      block.x -= trans.x;
      block.y -= trans.y;
      block.angle = (block.angle - turn + 4) % 4;
    }
  }

  if (moved) {
    block.rowsFree = this.calculateRowsFree(block, data);
    block.localStickFrames = Constants.LOCALSTICKFRAMES;
  }

  if (block.rowsFree > 0) {
    block.localStickFrames = Constants.LOCALSTICKFRAMES;
    block.globalStickFrames = Constants.GLOBALSTICKFRAMES;
    // Drop the block if gravity is on or if a DOWN key were pressed.
    drop = Math.min(drop, block.rowsFree);
    block.y += drop;
    block.rowsFree -= drop;
  } else {
    block.globalStickFrames--;
    if (!moved) {
      block.localStickFrames--;
    }
  }
}

// Tries to shove the block away from obstructing squares and the bottom edge.
// Returns true and leaves the block in its new position on success.
// Leaves the block's position unmodified on failure.
Physics.shoveaway = function(block, data, hint) {
  // In the absence of a hint, prefer to shove left over shoving right.
  hint = (hint > 0 ? 1 : -1);

  for (var i = 0; i < 4; i++) {
    for (var j = 0; j < 3; j++) {
      if (this.checkBlock(block, data) === Constants.OK) {
        return true;
      }
      block.x += (j === 1 ? -2*hint : hint);
    }
    if (i === 0) {
      block.y++;
    } else if (i === 1) {
      block.y -= 2;
    } else {
      block.y--;
    }
  }

  block.y += 3;
  return false;
}

// Places the block onto the board and removes rows from the board.
// Returns the number of points scored by the placement.
Physics.placeBlock = function(block, data) {
  var offsets = block.getOffsets();
  for (var i = 0; i < offsets.length; i++) {
    var offset = offsets[i];
    data[offset.y][offset.x] = block.color;
  }
  return Constants.POINTS[this.removeRows(data)];
}

// Modifies data and returns the number of rows cleared from it.
Physics.removeRows = function(data) {
  var numRowsCleared = 0;

  for (var i = Constants.ROWS - 1; i >= 0; i--) {
    var isRowFull = true;
    for (var j = 0; j < Constants.COLS; j++) {
      if (data[i][j] === 0) {
        isRowFull = false;
      }
    }

    if (isRowFull) {
      for (j = 0; j < Constants.COLS; j++) {
        data[i][j] = 0;
      }
      numRowsCleared++;
    } else if (numRowsCleared > 0) {
      for (j = 0; j < Constants.COLS; j++) {
        data[i + numRowsCleared][j] = data[i][j];
        data[i][j] = 0;
      }
    }
  }

  return numRowsCleared;
}

// Returns the number of rows that the given block could drop on this board.
// Mutates block in the middle of the function but restores it by the end.
Physics.calculateRowsFree = function(block, data) {
  var result = 0;
  while (this.checkBlock(block, data) === Constants.OK) {
    result++;
    block.y++;
  }
  block.y -= result;
  return result - 1;
}

// Returns OK if the block is in a valid position. Otherwise, returns the
// code for the highest-priority placement rule that the block breaks.
Physics.checkBlock = function(block, data) {
  var offsets = block.getOffsets();
  var status = Constants.OK;

  for (var i = 0; i < offsets.length; i++) {
    if (offsets[i].x < 0) {
      status = Math.min(Constants.LEFTEDGE, status);
    } else if (offsets[i].x >= Constants.COLS) {
      status = Math.min(Constants.RIGHTEDGE, status);
    } else if (offsets[i].y < 0) {
      status = Math.min(Constants.TOPEDGE, status);
    } else if (offsets[i].y >= Constants.ROWS) {
      status = Math.min(Constants.BOTTOMEDGE, status);
    } else if (data[offsets[i].y][offsets[i].x] !== 0) {
      status = Math.min(Constants.OVERLAP, status);
    }
  }

  return status;
}

return Physics;
})();

var Board = (function() {
"use strict";

var Board = function(target) {
  this.target = target;
  this.graphics = new Graphics(target);
  this.repeater = new KeyRepeater(Constants.PAUSE, Constants.REPEAT, target);
  this.setFocusHandlers(target);

  this.data = [];
  for (var i = 0; i < Constants.ROWS; i++) {
    var row = [];
    for (var j = 0; j < Constants.COLS; j++) {
      row.push(0);
    }
    this.data.push(row);
  }

  this.reset();

  this.afterTime = (new Date).getTime();
  this.sleepTime = Constants.FRAMEDELAY;
  setTimeout(this.gameLoop.bind(this), this.sleepTime);
}

Board.prototype.setFocusHandlers = function(target) {
  target.focus(this.gainFocus.bind(this));
  target.focusout(this.loseFocus.bind(this));
  $(window).blur(this.loseFocus.bind(this));
  target.focus();
}

Board.prototype.loseFocus = function(e) {
  if (this.state === Constants.PLAYING) {
    this.state = Constants.PAUSED;
    this.pauseReason = 'focus';
  }
}

Board.prototype.gainFocus = function(e) {
  if (this.state === Constants.PAUSED && this.pauseReason === 'focus') {
    this.state = Constants.PLAYING;
  }
}

Board.prototype.reset = function() {
  for (var i = 0; i < Constants.ROWS; i++) {
    for (var j = 0; j < Constants.COLS; j++) {
      this.data[i][j] = 0;
    }
  }

  this.frame = 0;
  this.held = false;
  this.heldBlockType = -1;
  this.score = 0;
  this.state = Constants.PLAYING;

  this.preview = [];
  for (var i = 0; i < Constants.PREVIEW; i++) {
    this.maybeAddToPreview();
  }
  this.blockIndex = 0;
  this.block = this.nextBlock();

  this.graphics.reset(this);
}

Board.prototype.gameLoop = function() {
  this.beforeTime = (new Date).getTime();
  var extraTime = (this.beforeTime - this.afterTime) - this.sleepTime;

  var frames = Math.floor(extraTime/Constants.FRAMEDELAY) + 1;
  for (var i = 0; i < frames; i++) {
    this.tick();
  }
  this.graphics.drawUI(this);
  this.graphics.flip();

  this.afterTime = (new Date).getTime();
  var sleepTime =
      Constants.FRAMEDELAY - (this.afterTime - this.beforeTime) - extraTime;
  setTimeout(this.gameLoop.bind(this), sleepTime);
}

Board.prototype.tick = function() {
  var keys = this.getKeys();

  if (keys.indexOf(Action.START) >= 0) {
    if (this.state === Constants.PLAYING) {
      this.state = Constants.PAUSED;
      this.pauseReason = 'manual';
    } else if (this.state === Constants.PAUSED) {
      this.state = Constants.PLAYING;
    } else {
      this.reset();
    }
    return;
  }

  if (this.state === Constants.PLAYING) {
    this.frame = (this.frame + 1) % Constants.MAXFRAME;
    this.graphics.eraseBlock(this.block);
    this.update(keys);
    this.graphics.drawBlock(this.block);
  }
}

Board.prototype.getKeys = function() {
  var keys = this.repeater.query();
  if (this.block.localStickFrames <= 0 || this.block.globalStickFrames <= 0) {
    keys.push(Action.DROP);
  } else if (this.frame % Constants.GRAVITY === 0) {
    keys.push(Action.DOWN);
  }
  return keys;
}

Board.prototype.update = function(keys) {
  if (!this.held && keys.indexOf(Action.HOLD) >= 0) {
    this.block = this.nextBlock(this.block);
  } else if (keys.indexOf(Action.DROP) >= 0) {
    this.block.y += this.block.rowsFree;
    this.score += Physics.placeBlock(this.block, this.data);
    this.redraw();
    this.block = this.nextBlock();
  } else {
    Physics.moveBlock(this.block, this.data, keys);
  }
  if (this.block.rowsFree < 0) {
    this.state = Constants.GAMEOVER;
  }
}

Board.prototype.redraw = function() {
  for (var i = 0; i < Constants.ROWS; i++) {
    for (var j = 0; j < Constants.COLS; j++) {
      this.graphics.drawBoardSquare(i, j, this.data[i][j]);
    }
  }
}

Board.prototype.nextBlock = function(swap) {
  var type = -1;
  if (swap) {
    type = this.heldBlockType;
    this.heldBlockType = swap.type;
  }
  if (type < 0) {
    this.blockIndex += 1;
    this.maybeAddToPreview();
    type = this.preview.shift();
  }

  this.held = (swap ? true : false);
  var result = new Block(type);
  result.rowsFree = Physics.calculateRowsFree(result, this.data);
  return result;
}

Board.prototype.maybeAddToPreview = function() {
  this.preview.push(this.playTetrisGod(this.score));
}

Board.prototype.playTetrisGod = function(score) {
  return Math.floor(Block.TYPES[this.difficultyLevel(score)]*Math.random());
}

Board.prototype.difficultyLevel = function(score) {
  if (Block.LEVELS === 1) {
    return 0;
  }
  // Calculate the ratio r between the probability of different levels.
  var p = this.random();
  var x = 2.0*(score - Constants.HALFRSCORE)/Constants.HALFRSCORE;
  var r = (Constants.MAXR - Constants.MINR)*this.sigmoid(x) + Constants.MINR;
  // Run through difficulty levels and compare p to a sigmoid for each level.
  for (var i = 1; i < Block.LEVELS ; i++) {
    var x = 2.0*(score - i*Constants.LEVELINTERVAL)/Constants.LEVELINTERVAL;
    if (p > Math.pow(r, i)*this.sigmoid(x)) {
      return i - 1;
    }
  }
  return Block.LEVELS - 1;
}

Board.prototype.sigmoid = function(x) {
  return (x/Math.sqrt(1 + x*x) + 1)/2;
}

Board.prototype.random = function() {
  return Math.random();
}

return Board;
})();

var ClientBoard = (function() {
"use strict";

var ClientBoard = function(target, view, send) {
  this.__super__.constructor.bind(this)(target);

  $.extend(this, view);
  this.preview = [view.blockType];
  this.preview.push.apply(this.preview, view.preview);
  this.blockIndex = 0;
  this.block = this.nextBlock();
  this.graphics.reset(this);

  this.send = send;
}

extend(ClientBoard, Board);

ClientBoard.prototype.loseFocus = function(e) {
  // A client board doesn't auto-pause on losing focus.
}

ClientBoard.prototype.gainFocus = function(e) {
  // A client board doesn't unpause on gaining focus.
}

ClientBoard.prototype.reset = function() {
  // The only variable that's not reset from the server view is the
  // frame number.
  this.frame = 0;
  this.moves = [];
}

ClientBoard.prototype.tick = function() {
  var keys = this.getKeys();

  if (this.state === Constants.PLAYING &&
      this.block !== null &&
      this.preview.length > 0) {
    this.maybeSaveMove(keys);
    var blockIndex = this.blockIndex;

    this.frame = (this.frame + 1) % Constants.MAXFRAME;
    this.graphics.eraseBlock(this.block);
    this.update(keys);
    this.graphics.drawBlock(this.block);

    if (this.blockIndex > blockIndex) {
      this.send({type: 'move', moves: this.moves});
      this.moves.length = 0;
    }
  }
}

ClientBoard.prototype.maybeSaveMove = function(keys) {
  var move = [];
  for (var i = 0; i < keys.length; i++) {
    if (keys[i] !== Action.START) {
      move.push(keys[i]);
    }
  }
  if (move.length > 0) {
    this.moves.push(move);
  }
}

ClientBoard.prototype.nextBlock = function(swap) {
  if (this.preview.length > 0) {
    return this.__super__.nextBlock.bind(this)(swap);
  }
  return null;
}

ClientBoard.prototype.maybeAddToPreview = function() {
  // A client board never adds pieces to the preview based on local state.
  // Instead, the server sends a state update with a new preview that replaces
  // the old one.
}

ClientBoard.prototype.deserialize = function(view) {
  // Pull preview data out of the view and update the current state. Note
  // that we could have pulled blocks from the preview since the server sent
  // it, so we have to shift this blocks first.
  this.preview = view.preview.slice();
  for (var i = view.blockIndex; i < this.blockIndex; i++) {
    this.preview.shift();
  }
}

return ClientBoard;
})();

var OpponentBoard = (function() {
"use strict";

var OpponentBoard = function(target, view) {
  this.graphics = new Graphics(target);
  this.deserialize(view);
}

OpponentBoard.prototype.deserialize = function(view) {
  $.extend(this, view);
  this.blockIndex = 0;
  this.block = new Block(view.blockType);
  this.block.rowsFree = Physics.calculateRowsFree(this.block, this.data);
  this.graphics.reset(this);
}

return OpponentBoard;
})();

var ServerBoard = (function() {
"use strict";

var ServerBoard = function(seed) {
  this.data = [];
  for (var i = 0; i < Constants.ROWS; i++) {
    var row = [];
    for (var j = 0; j < Constants.COLS; j++) {
      row.push(0);
    }
    this.data.push(row);
  }
  this.reset(seed);
}

extend(ServerBoard, Board);

ServerBoard.prototype.reset = function(seed) {
  this.rng = new MersenneTwister(seed);

  for (var i = 0; i < Constants.ROWS; i++) {
    for (var j = 0; j < Constants.COLS; j++) {
      this.data[i][j] = 0;
    }
  }

  this.frame = 0;
  this.held = false;
  this.heldBlockType = -1;
  this.score = 0;
  this.state = Constants.PLAYING;

  this.preview = [];
  for (var i = 0; i < Constants.PREVIEW; i++) {
    this.maybeAddToPreview();
  }
  this.blockIndex = 0;
  this.block = this.nextBlock();
}

ServerBoard.prototype.redraw = function() {
  // The server board doesn't need to be drawn.
}

ServerBoard.prototype.serialize = function() {
  return {
    data: this.data,
    blockType: this.block.type,
    // The rest of the fields here are the precisely fields that are read
    // by a call to Graphics.drawUI.
    blockIndex: this.blockIndex,
    preview: this.preview,
    held: this.held,
    heldBlockType: this.heldBlockType,
    score: this.score,
    state: this.state,
    pauseReason: this.pauseReason,
  }
}

ServerBoard.prototype.random = function() {
  return this.rng.random();
}

return ServerBoard;
})();

this.combinos.ClientBoard = ClientBoard;
this.combinos.OpponentBoard = OpponentBoard;
this.combinos.ServerBoard = ServerBoard;

if (Meteor.isClient) {
  Color.initialize(Color.colorCode);
}
