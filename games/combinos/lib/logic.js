var RawBlockData = combinos.RawBlockData;
initialize_move_library = function() {
// Copyright (c) 2011 TJ Holowaychuk <tj@vision-media.ca>
// https://github.com/visionmedia/move.js
(function(){function require(path,parent,orig){var resolved=require.resolve(path);if(null==resolved){orig=orig||path;parent=parent||"root";var err=new Error('Failed to require "'+orig+'" from "'+parent+'"');err.path=orig;err.parent=parent;err.require=true;throw err}var module=require.modules[resolved];if(!module._resolving&&!module.exports){var mod={};mod.exports={};mod.client=mod.component=true;module._resolving=true;module.call(this,mod.exports,require.relative(resolved),mod);delete module._resolving;module.exports=mod.exports}return module.exports}require.modules={};require.aliases={};require.resolve=function(path){if(path.charAt(0)==="/")path=path.slice(1);var paths=[path,path+".js",path+".json",path+"/index.js",path+"/index.json"];for(var i=0;i<paths.length;i++){var path=paths[i];if(require.modules.hasOwnProperty(path))return path;if(require.aliases.hasOwnProperty(path))return require.aliases[path]}};require.normalize=function(curr,path){var segs=[];if("."!=path.charAt(0))return path;curr=curr.split("/");path=path.split("/");for(var i=0;i<path.length;++i){if(".."==path[i]){curr.pop()}else if("."!=path[i]&&""!=path[i]){segs.push(path[i])}}return curr.concat(segs).join("/")};require.register=function(path,definition){require.modules[path]=definition};require.alias=function(from,to){if(!require.modules.hasOwnProperty(from)){throw new Error('Failed to alias "'+from+'", it does not exist')}require.aliases[to]=from};require.relative=function(parent){var p=require.normalize(parent,"..");function lastIndexOf(arr,obj){var i=arr.length;while(i--){if(arr[i]===obj)return i}return-1}function localRequire(path){var resolved=localRequire.resolve(path);return require(resolved,parent,path)}localRequire.resolve=function(path){var c=path.charAt(0);if("/"==c)return path.slice(1);if("."==c)return require.normalize(p,path);var segs=parent.split("/");var i=lastIndexOf(segs,"deps")+1;if(!i)i=0;path=segs.slice(0,i+1).join("/")+"/deps/"+path;return path};localRequire.exists=function(path){return require.modules.hasOwnProperty(localRequire.resolve(path))};return localRequire};require.register("component-transform-property/index.js",function(exports,require,module){var styles=["webkitTransform","MozTransform","msTransform","OTransform","transform"];var el=document.createElement("p");var style;for(var i=0;i<styles.length;i++){style=styles[i];if(null!=el.style[style]){module.exports=style;break}}});require.register("component-has-translate3d/index.js",function(exports,require,module){var prop=require("transform-property");if(!prop||!window.getComputedStyle)return module.exports=false;var map={webkitTransform:"-webkit-transform",OTransform:"-o-transform",msTransform:"-ms-transform",MozTransform:"-moz-transform",transform:"transform"};var el=document.createElement("div");el.style[prop]="translate3d(1px,1px,1px)";document.body.insertBefore(el,null);var val=getComputedStyle(el).getPropertyValue(map[prop]);document.body.removeChild(el);module.exports=null!=val&&val.length&&"none"!=val});require.register("yields-has-transitions/index.js",function(exports,require,module){exports=module.exports=function(el){switch(arguments.length){case 0:return bool;case 1:return bool?transitions(el):bool}};function transitions(el,styl){if(el.transition)return true;styl=window.getComputedStyle(el);return!!parseFloat(styl.transitionDuration,10)}var styl=document.body.style;var bool="transition"in styl||"webkitTransition"in styl||"MozTransition"in styl||"msTransition"in styl});require.register("component-event/index.js",function(exports,require,module){exports.bind=function(el,type,fn,capture){if(el.addEventListener){el.addEventListener(type,fn,capture||false)}else{el.attachEvent("on"+type,fn)}return fn};exports.unbind=function(el,type,fn,capture){if(el.removeEventListener){el.removeEventListener(type,fn,capture||false)}else{el.detachEvent("on"+type,fn)}return fn}});require.register("ecarter-css-emitter/index.js",function(exports,require,module){var events=require("event");var watch=["transitionend","webkitTransitionEnd","oTransitionEnd","MSTransitionEnd","animationend","webkitAnimationEnd","oAnimationEnd","MSAnimationEnd"];module.exports=CssEmitter;function CssEmitter(element){if(!(this instanceof CssEmitter))return new CssEmitter(element);this.el=element}CssEmitter.prototype.bind=function(fn){for(var i=0;i<watch.length;i++){events.bind(this.el,watch[i],fn)}};CssEmitter.prototype.unbind=function(fn){for(var i=0;i<watch.length;i++){events.unbind(this.el,watch[i],fn)}}});require.register("component-once/index.js",function(exports,require,module){var n=0;var global=function(){return this}();module.exports=function(fn){var id=n++;var called;function once(){if(this==global){if(called)return;called=true;return fn.apply(this,arguments)}var key="__called_"+id+"__";if(this[key])return;this[key]=true;return fn.apply(this,arguments)}return once}});require.register("yields-after-transition/index.js",function(exports,require,module){var has=require("has-transitions"),emitter=require("css-emitter"),once=require("once");var supported=has();module.exports=after;function after(el,fn){if(!supported||!has(el))return fn();emitter(el).bind(fn);return fn}after.once=function(el,fn){var callback=once(fn);after(el,fn=function(){emitter(el).unbind(fn);callback()})}});require.register("component-indexof/index.js",function(exports,require,module){module.exports=function(arr,obj){if(arr.indexOf)return arr.indexOf(obj);for(var i=0;i<arr.length;++i){if(arr[i]===obj)return i}return-1}});require.register("component-emitter/index.js",function(exports,require,module){var index=require("indexof");module.exports=Emitter;function Emitter(obj){if(obj)return mixin(obj)}function mixin(obj){for(var key in Emitter.prototype){obj[key]=Emitter.prototype[key]}return obj}Emitter.prototype.on=Emitter.prototype.addEventListener=function(event,fn){this._callbacks=this._callbacks||{};(this._callbacks[event]=this._callbacks[event]||[]).push(fn);return this};Emitter.prototype.once=function(event,fn){var self=this;this._callbacks=this._callbacks||{};function on(){self.off(event,on);fn.apply(this,arguments)}fn._off=on;this.on(event,on);return this};Emitter.prototype.off=Emitter.prototype.removeListener=Emitter.prototype.removeAllListeners=Emitter.prototype.removeEventListener=function(event,fn){this._callbacks=this._callbacks||{};if(0==arguments.length){this._callbacks={};return this}var callbacks=this._callbacks[event];if(!callbacks)return this;if(1==arguments.length){delete this._callbacks[event];return this}var i=index(callbacks,fn._off||fn);if(~i)callbacks.splice(i,1);return this};Emitter.prototype.emit=function(event){this._callbacks=this._callbacks||{};var args=[].slice.call(arguments,1),callbacks=this._callbacks[event];if(callbacks){callbacks=callbacks.slice(0);for(var i=0,len=callbacks.length;i<len;++i){callbacks[i].apply(this,args)}}return this};Emitter.prototype.listeners=function(event){this._callbacks=this._callbacks||{};return this._callbacks[event]||[]};Emitter.prototype.hasListeners=function(event){return!!this.listeners(event).length}});require.register("yields-css-ease/index.js",function(exports,require,module){module.exports={"in":"ease-in",out:"ease-out","in-out":"ease-in-out",snap:"cubic-bezier(0,1,.5,1)",linear:"cubic-bezier(0.250, 0.250, 0.750, 0.750)","ease-in-quad":"cubic-bezier(0.550, 0.085, 0.680, 0.530)","ease-in-cubic":"cubic-bezier(0.550, 0.055, 0.675, 0.190)","ease-in-quart":"cubic-bezier(0.895, 0.030, 0.685, 0.220)","ease-in-quint":"cubic-bezier(0.755, 0.050, 0.855, 0.060)","ease-in-sine":"cubic-bezier(0.470, 0.000, 0.745, 0.715)","ease-in-expo":"cubic-bezier(0.950, 0.050, 0.795, 0.035)","ease-in-circ":"cubic-bezier(0.600, 0.040, 0.980, 0.335)","ease-in-back":"cubic-bezier(0.600, -0.280, 0.735, 0.045)","ease-out-quad":"cubic-bezier(0.250, 0.460, 0.450, 0.940)","ease-out-cubic":"cubic-bezier(0.215, 0.610, 0.355, 1.000)","ease-out-quart":"cubic-bezier(0.165, 0.840, 0.440, 1.000)","ease-out-quint":"cubic-bezier(0.230, 1.000, 0.320, 1.000)","ease-out-sine":"cubic-bezier(0.390, 0.575, 0.565, 1.000)","ease-out-expo":"cubic-bezier(0.190, 1.000, 0.220, 1.000)","ease-out-circ":"cubic-bezier(0.075, 0.820, 0.165, 1.000)","ease-out-back":"cubic-bezier(0.175, 0.885, 0.320, 1.275)","ease-out-quad":"cubic-bezier(0.455, 0.030, 0.515, 0.955)","ease-out-cubic":"cubic-bezier(0.645, 0.045, 0.355, 1.000)","ease-in-out-quart":"cubic-bezier(0.770, 0.000, 0.175, 1.000)","ease-in-out-quint":"cubic-bezier(0.860, 0.000, 0.070, 1.000)","ease-in-out-sine":"cubic-bezier(0.445, 0.050, 0.550, 0.950)","ease-in-out-expo":"cubic-bezier(1.000, 0.000, 0.000, 1.000)","ease-in-out-circ":"cubic-bezier(0.785, 0.135, 0.150, 0.860)","ease-in-out-back":"cubic-bezier(0.680, -0.550, 0.265, 1.550)"}});require.register("component-query/index.js",function(exports,require,module){function one(selector,el){return el.querySelector(selector)}exports=module.exports=function(selector,el){el=el||document;return one(selector,el)};exports.all=function(selector,el){el=el||document;return el.querySelectorAll(selector)};exports.engine=function(obj){if(!obj.one)throw new Error(".one callback required");if(!obj.all)throw new Error(".all callback required");one=obj.one;exports.all=obj.all;return exports}});require.register("move/index.js",function(exports,require,module){var after=require("after-transition");var has3d=require("has-translate3d");var Emitter=require("emitter");var ease=require("css-ease");var query=require("query");var translate=has3d?["translate3d(",", 0)"]:["translate(",")"];module.exports=Move;var style=window.getComputedStyle||window.currentStyle;Move.version="0.3.2";Move.ease=ease;Move.defaults={duration:500};Move.select=function(selector){if("string"!=typeof selector)return selector;return query(selector)};function Move(el){if(!(this instanceof Move))return new Move(el);if("string"==typeof el)el=query(el);if(!el)throw new TypeError("Move must be initialized with element or selector");this.el=el;this._props={};this._rotate=0;this._transitionProps=[];this._transforms=[];this.duration(Move.defaults.duration)}Emitter(Move.prototype);Move.prototype.transform=function(transform){this._transforms.push(transform);return this};Move.prototype.skew=function(x,y){return this.transform("skew("+x+"deg, "+(y||0)+"deg)")};Move.prototype.skewX=function(n){return this.transform("skewX("+n+"deg)")};Move.prototype.skewY=function(n){return this.transform("skewY("+n+"deg)")};Move.prototype.translate=Move.prototype.to=function(x,y){return this.transform(translate.join(""+x+"px, "+(y||0)+"px"))};Move.prototype.translateX=Move.prototype.x=function(n){return this.transform("translateX("+n+"px)")};Move.prototype.translateY=Move.prototype.y=function(n){return this.transform("translateY("+n+"px)")};Move.prototype.scale=function(x,y){return this.transform("scale("+x+", "+(y||x)+")")};Move.prototype.scaleX=function(n){return this.transform("scaleX("+n+")")};Move.prototype.scaleY=function(n){return this.transform("scaleY("+n+")")};Move.prototype.rotate=function(n){return this.transform("rotate("+n+"deg)")};Move.prototype.ease=function(fn){fn=ease[fn]||fn||"ease";return this.setVendorProperty("transition-timing-function",fn)};Move.prototype.animate=function(name,props){for(var i in props){if(props.hasOwnProperty(i)){this.setVendorProperty("animation-"+i,props[i])}}return this.setVendorProperty("animation-name",name)};Move.prototype.duration=function(n){n=this._duration="string"==typeof n?parseFloat(n)*1e3:n;return this.setVendorProperty("transition-duration",n+"ms")};Move.prototype.delay=function(n){n="string"==typeof n?parseFloat(n)*1e3:n;return this.setVendorProperty("transition-delay",n+"ms")};Move.prototype.setProperty=function(prop,val){this._props[prop]=val;return this};Move.prototype.setVendorProperty=function(prop,val){this.setProperty("-webkit-"+prop,val);this.setProperty("-moz-"+prop,val);this.setProperty("-ms-"+prop,val);this.setProperty("-o-"+prop,val);return this};Move.prototype.set=function(prop,val){this.transition(prop);this._props[prop]=val;return this};Move.prototype.add=function(prop,val){if(!style)return;var self=this;return this.on("start",function(){var curr=parseInt(self.current(prop),10);self.set(prop,curr+val+"px")})};Move.prototype.sub=function(prop,val){if(!style)return;var self=this;return this.on("start",function(){var curr=parseInt(self.current(prop),10);self.set(prop,curr-val+"px")})};Move.prototype.current=function(prop){return style(this.el).getPropertyValue(prop)};Move.prototype.transition=function(prop){if(!this._transitionProps.indexOf(prop))return this;this._transitionProps.push(prop);return this};Move.prototype.applyProperties=function(){for(var prop in this._props){this.el.style.setProperty(prop,this._props[prop])}return this};Move.prototype.move=Move.prototype.select=function(selector){this.el=Move.select(selector);return this};Move.prototype.then=function(fn){if(fn instanceof Move){this.on("end",function(){fn.end()})}else if("function"==typeof fn){this.on("end",fn)}else{var clone=new Move(this.el);clone._transforms=this._transforms.slice(0);this.then(clone);clone.parent=this;return clone}return this};Move.prototype.pop=function(){return this.parent};Move.prototype.reset=function(){this.el.style.webkitTransitionDuration=this.el.style.mozTransitionDuration=this.el.style.msTransitionDuration=this.el.style.oTransitionDuration=0;return this};Move.prototype.end=function(fn){var self=this;this.emit("start");if(this._transforms.length){this.setVendorProperty("transform",this._transforms.join(" "))}this.setVendorProperty("transition-properties",this._transitionProps.join(", "));this.applyProperties();if(fn)this.then(fn);after.once(this.el,function(){self.reset();self.emit("end")});return this}});require.alias("component-has-translate3d/index.js","move/deps/has-translate3d/index.js");require.alias("component-has-translate3d/index.js","has-translate3d/index.js");require.alias("component-transform-property/index.js","component-has-translate3d/deps/transform-property/index.js");require.alias("yields-after-transition/index.js","move/deps/after-transition/index.js");require.alias("yields-after-transition/index.js","move/deps/after-transition/index.js");require.alias("yields-after-transition/index.js","after-transition/index.js");require.alias("yields-has-transitions/index.js","yields-after-transition/deps/has-transitions/index.js");require.alias("yields-has-transitions/index.js","yields-after-transition/deps/has-transitions/index.js");require.alias("yields-has-transitions/index.js","yields-has-transitions/index.js");require.alias("ecarter-css-emitter/index.js","yields-after-transition/deps/css-emitter/index.js");require.alias("component-emitter/index.js","ecarter-css-emitter/deps/emitter/index.js");require.alias("component-indexof/index.js","component-emitter/deps/indexof/index.js");require.alias("component-event/index.js","ecarter-css-emitter/deps/event/index.js");require.alias("component-once/index.js","yields-after-transition/deps/once/index.js");require.alias("yields-after-transition/index.js","yields-after-transition/index.js");require.alias("component-emitter/index.js","move/deps/emitter/index.js");require.alias("component-emitter/index.js","emitter/index.js");require.alias("component-indexof/index.js","component-emitter/deps/indexof/index.js");require.alias("yields-css-ease/index.js","move/deps/css-ease/index.js");require.alias("yields-css-ease/index.js","move/deps/css-ease/index.js");require.alias("yields-css-ease/index.js","css-ease/index.js");require.alias("yields-css-ease/index.js","yields-css-ease/index.js");require.alias("component-query/index.js","move/deps/query/index.js");require.alias("component-query/index.js","query/index.js");window.move=require('move');if(typeof exports=="object"){module.exports=require("move")}else if(typeof define=="function"&&define.amd){define(function(){return require("move")})}else{this["move"]=require("move")}})();
}

if(!Array.prototype.map)Array.prototype.map=function(f,o){var n=this.length;var result=new Array(n);for(var i=0;i<n;i++){if(i in this){result[i]=f.call(o,this[i],i,this)}}return result};if(!Array.prototype.filter)Array.prototype.filter=function(f,o){var n=this.length;var result=new Array;for(var i=0;i<n;i++){if(i in this){var v=this[i];if(f.call(o,v,i,this))result.push(v)}}return result};if(!Array.prototype.forEach)Array.prototype.forEach=function(f,o){var n=this.length>>>0;for(var i=0;i<n;i++){if(i in this)f.call(o,this[i],i,this)}};if(!Array.prototype.reduce)Array.prototype.reduce=function(f,v){var len=this.length;if(!len&&arguments.length==1){throw new Error("reduce: empty array, no initial value")}var i=0;if(arguments.length<2){while(true){if(i in this){v=this[i++];break}if(++i>=len){throw new Error("reduce: no values, no initial value")}}}for(;i<len;i++){if(i in this){v=f(v,this[i],i,this)}}return v};var pv={};pv.version="3.3.1";pv.identity=function(x){return x};pv.index=function(){return this.index};pv.child=function(){return this.childIndex};pv.parent=function(){return this.parent.index};pv.extend=function(f){function g(){}g.prototype=f.prototype||f;return new g};pv.css=function(e,p){return window.getComputedStyle?window.getComputedStyle(e,null).getPropertyValue(p):e.currentStyle[p]};pv.error=function(e){typeof console=="undefined"?alert(e):console.error(e)};pv.listen=function(target,type,listener){listener=pv.listener(listener);return target.addEventListener?target.addEventListener(type,listener,false):target.attachEvent("on"+type,listener)};pv.listener=function(f){return f.$listener||(f.$listener=function(e){try{pv.event=e;return f.call(this,e)}finally{delete pv.event}})};pv.ancestor=function(a,e){while(e){if(e==a)return true;e=e.parentNode}return false};pv.id=function(){var id=1;return function(){return id++}}();pv.functor=function(v){return typeof v=="function"?v:function(){return v}};pv.Format={};pv.Format.re=function(s){return s.replace(/[\\\^\$\*\+\?\[\]\(\)\.\{\}]/g,"\\$&")};pv.Format.pad=function(c,n,s){var m=n-String(s).length;return m<1?s:new Array(m+1).join(c)+s};pv.Format.date=function(pattern){var pad=pv.Format.pad;function format(d){return pattern.replace(/%[a-zA-Z0-9]/g,function(s){switch(s){case"%a":return["Sun","Mon","Tue","Wed","Thu","Fri","Sat"][d.getDay()];case"%A":return["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"][d.getDay()];case"%h":case"%b":return["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"][d.getMonth()];case"%B":return["January","February","March","April","May","June","July","August","September","October","November","December"][d.getMonth()];case"%c":return d.toLocaleString();case"%C":return pad("0",2,Math.floor(d.getFullYear()/100)%100);case"%d":return pad("0",2,d.getDate());case"%x":case"%D":return pad("0",2,d.getMonth()+1)+"/"+pad("0",2,d.getDate())+"/"+pad("0",2,d.getFullYear()%100);case"%e":return pad(" ",2,d.getDate());case"%H":return pad("0",2,d.getHours());case"%I":{var h=d.getHours()%12;return h?pad("0",2,h):12}case"%m":return pad("0",2,d.getMonth()+1);case"%M":return pad("0",2,d.getMinutes());case"%n":return"\n";case"%p":return d.getHours()<12?"AM":"PM";case"%T":case"%X":case"%r":{var h=d.getHours()%12;return(h?pad("0",2,h):12)+":"+pad("0",2,d.getMinutes())+":"+pad("0",2,d.getSeconds())+" "+(d.getHours()<12?"AM":"PM")}case"%R":return pad("0",2,d.getHours())+":"+pad("0",2,d.getMinutes());case"%S":return pad("0",2,d.getSeconds());case"%Q":return pad("0",3,d.getMilliseconds());case"%t":return"	";case"%u":{var w=d.getDay();return w?w:1}case"%w":return d.getDay();case"%y":return pad("0",2,d.getFullYear()%100);case"%Y":return d.getFullYear();case"%%":return"%"}return s})}format.format=format;format.parse=function(s){var year=1970,month=0,date=1,hour=0,minute=0,second=0;var fields=[function(){}];var re=pv.Format.re(pattern).replace(/%[a-zA-Z0-9]/g,function(s){switch(s){case"%b":{fields.push(function(x){month={Jan:0,Feb:1,Mar:2,Apr:3,May:4,Jun:5,Jul:6,Aug:7,Sep:8,Oct:9,Nov:10,Dec:11}[x]});return"([A-Za-z]+)"}case"%h":case"%B":{fields.push(function(x){month={January:0,February:1,March:2,April:3,May:4,June:5,July:6,August:7,September:8,October:9,November:10,December:11}[x]});return"([A-Za-z]+)"}case"%e":case"%d":{fields.push(function(x){date=x});return"([0-9]+)"}case"%I":case"%H":{fields.push(function(x){hour=x});return"([0-9]+)"}case"%m":{fields.push(function(x){month=x-1});return"([0-9]+)"}case"%M":{fields.push(function(x){minute=x});return"([0-9]+)"}case"%p":{fields.push(function(x){if(hour==12){if(x=="am")hour=0}else if(x=="pm"){hour=Number(hour)+12}});return"(am|pm)"}case"%S":{fields.push(function(x){second=x});return"([0-9]+)"}case"%y":{fields.push(function(x){x=Number(x);year=x+(0<=x&&x<69?2e3:x>=69&&x<100?1900:0)});return"([0-9]+)"}case"%Y":{fields.push(function(x){year=x});return"([0-9]+)"}case"%%":{fields.push(function(){});return"%"}}return s});var match=s.match(re);if(match)match.forEach(function(m,i){fields[i](m)});return new Date(year,month,date,hour,minute,second)};return format};pv.Format.time=function(type){var pad=pv.Format.pad;function format(t){t=Number(t);switch(type){case"short":{if(t>=31536e6){return(t/31536e6).toFixed(1)+" years"}else if(t>=6048e5){return(t/6048e5).toFixed(1)+" weeks"}else if(t>=864e5){return(t/864e5).toFixed(1)+" days"}else if(t>=36e5){return(t/36e5).toFixed(1)+" hours"}else if(t>=6e4){return(t/6e4).toFixed(1)+" minutes"}return(t/1e3).toFixed(1)+" seconds"}case"long":{var a=[],s=t%6e4/1e3>>0,m=t%36e5/6e4>>0;a.push(pad("0",2,s));if(t>=36e5){var h=t%864e5/36e5>>0;a.push(pad("0",2,m));if(t>=864e5){a.push(pad("0",2,h));a.push(Math.floor(t/864e5).toFixed())}else{a.push(h.toFixed())}}else{a.push(m.toFixed())}return a.reverse().join(":")}}}format.format=format;format.parse=function(s){switch(type){case"short":{var re=/([0-9,.]+)\s*([a-z]+)/g,a,t=0;while(a=re.exec(s)){var f=parseFloat(a[0].replace(",","")),u=0;switch(a[2].toLowerCase()){case"year":case"years":u=31536e6;break;case"week":case"weeks":u=6048e5;break;case"day":case"days":u=864e5;break;case"hour":case"hours":u=36e5;break;case"minute":case"minutes":u=6e4;break;case"second":case"seconds":u=1e3;break}t+=f*u}return t}case"long":{var a=s.replace(",","").split(":").reverse(),t=0;if(a.length)t+=parseFloat(a[0])*1e3;if(a.length>1)t+=parseFloat(a[1])*6e4;if(a.length>2)t+=parseFloat(a[2])*36e5;if(a.length>3)t+=parseFloat(a[3])*864e5;return t}}};return format};pv.Format.number=function(){var mini=0,maxi=Infinity,mins=0,minf=0,maxf=0,maxk=1,padi="0",padf="0",padg=true,decimal=".",group=",",np="−",ns="";function format(x){if(Infinity>maxf)x=Math.round(x*maxk)/maxk;var s=String(Math.abs(x)).split(".");var i=s[0];if(i.length>maxi)i=i.substring(i.length-maxi);if(padg&&i.length<mini)i=new Array(mini-i.length+1).join(padi)+i;if(i.length>3)i=i.replace(/\B(?=(?:\d{3})+(?!\d))/g,group);if(!padg&&i.length<mins)i=new Array(mins-i.length+1).join(padi)+i;s[0]=x<0?np+i+ns:i;var f=s[1]||"";if(f.length<minf)s[1]=f+new Array(minf-f.length+1).join(padf);return s.join(decimal)}format.format=format;format.parse=function(x){var re=pv.Format.re;var s=String(x).replace(new RegExp("^("+re(padi)+")*"),"").replace(new RegExp("("+re(padf)+")*$"),"").split(decimal);var i=s[0].replace(new RegExp(re(group),"g"),"");if(i.length>maxi)i=i.substring(i.length-maxi);var f=s[1]?Number("0."+s[1]):0;if(Infinity>maxf)f=Math.round(f*maxk)/maxk;return Math.round(i)+f};format.integerDigits=function(min,max){if(arguments.length){mini=Number(min);maxi=arguments.length>1?Number(max):mini;mins=mini+Math.floor(mini/3)*group.length;return this}return[mini,maxi]};format.fractionDigits=function(min,max){if(arguments.length){minf=Number(min);maxf=arguments.length>1?Number(max):minf;maxk=Math.pow(10,maxf);return this}return[minf,maxf]};format.integerPad=function(x){if(arguments.length){padi=String(x);padg=/\d/.test(padi);return this}return padi};format.fractionPad=function(x){if(arguments.length){padf=String(x);return this}return padf};format.decimal=function(x){if(arguments.length){decimal=String(x);return this}return decimal};format.group=function(x){if(arguments.length){group=x?String(x):"";mins=mini+Math.floor(mini/3)*group.length;return this}return group};format.negativeAffix=function(x,y){if(arguments.length){np=String(x||"");ns=String(y||"");return this}return[np,ns]};return format};pv.map=function(array,f){var o={};return f?array.map(function(d,i){o.index=i;return f.call(o,d)}):array.slice()};pv.repeat=function(array,n){if(arguments.length==1)n=2;return pv.blend(pv.range(n).map(function(){return array}))};pv.cross=function(a,b){var array=[];for(var i=0,n=a.length,m=b.length;i<n;i++){for(var j=0,x=a[i];j<m;j++){array.push([x,b[j]])}}return array};pv.blend=function(arrays){return Array.prototype.concat.apply([],arrays)};pv.transpose=function(arrays){var n=arrays.length,m=pv.max(arrays,function(d){return d.length});if(m>n){arrays.length=m;for(var i=n;i<m;i++){arrays[i]=new Array(n)}for(var i=0;i<n;i++){for(var j=i+1;j<m;j++){var t=arrays[i][j];arrays[i][j]=arrays[j][i];arrays[j][i]=t}}}else{for(var i=0;i<m;i++){arrays[i].length=n}for(var i=0;i<n;i++){for(var j=0;j<i;j++){var t=arrays[i][j];arrays[i][j]=arrays[j][i];arrays[j][i]=t}}}arrays.length=m;for(var i=0;i<m;i++){arrays[i].length=n}return arrays};pv.normalize=function(array,f){var norm=pv.map(array,f),sum=pv.sum(norm);for(var i=0;i<norm.length;i++)norm[i]/=sum;return norm};pv.permute=function(array,indexes,f){if(!f)f=pv.identity;var p=new Array(indexes.length),o={};indexes.forEach(function(j,i){o.index=j;p[i]=f.call(o,array[j])});return p};pv.numerate=function(keys,f){if(!f)f=pv.identity;var map={},o={};keys.forEach(function(x,i){o.index=i;map[f.call(o,x)]=i});return map};pv.uniq=function(array,f){if(!f)f=pv.identity;var map={},keys=[],o={},y;array.forEach(function(x,i){o.index=i;y=f.call(o,x);if(!(y in map))map[y]=keys.push(y)});return keys};pv.naturalOrder=function(a,b){return a<b?-1:a>b?1:0};pv.reverseOrder=function(b,a){return a<b?-1:a>b?1:0};pv.search=function(array,value,f){if(!f)f=pv.identity;var low=0,high=array.length-1;while(low<=high){var mid=low+high>>1,midValue=f(array[mid]);if(midValue<value)low=mid+1;else if(midValue>value)high=mid-1;else return mid}return-low-1};pv.search.index=function(array,value,f){var i=pv.search(array,value,f);return i<0?-i-1:i};pv.range=function(start,stop,step){if(arguments.length==1){stop=start;start=0}if(step==undefined)step=1;if((stop-start)/step==Infinity)throw new Error("range must be finite");var array=[],i=0,j;stop-=(stop-start)*1e-10;if(step<0){while((j=start+step*i++)>stop){array.push(j)}}else{while((j=start+step*i++)<stop){array.push(j)}}return array};pv.random=function(start,stop,step){if(arguments.length==1){stop=start;start=0}if(step==undefined)step=1;return step?Math.floor(Math.random()*(stop-start)/step)*step+start:Math.random()*(stop-start)+start};pv.sum=function(array,f){var o={};return array.reduce(f?function(p,d,i){o.index=i;return p+f.call(o,d)}:function(p,d){return p+d},0)};pv.max=function(array,f){if(f==pv.index)return array.length-1;return Math.max.apply(null,f?pv.map(array,f):array)};pv.max.index=function(array,f){if(!array.length)return-1;if(f==pv.index)return array.length-1;if(!f)f=pv.identity;var maxi=0,maxx=-Infinity,o={};for(var i=0;i<array.length;i++){o.index=i;var x=f.call(o,array[i]);if(x>maxx){maxx=x;maxi=i}}return maxi};pv.min=function(array,f){if(f==pv.index)return 0;return Math.min.apply(null,f?pv.map(array,f):array)};pv.min.index=function(array,f){if(!array.length)return-1;if(f==pv.index)return 0;if(!f)f=pv.identity;var mini=0,minx=Infinity,o={};for(var i=0;i<array.length;i++){o.index=i;var x=f.call(o,array[i]);if(x<minx){minx=x;mini=i}}return mini};pv.mean=function(array,f){return pv.sum(array,f)/array.length};pv.median=function(array,f){if(f==pv.index)return(array.length-1)/2;array=pv.map(array,f).sort(pv.naturalOrder);if(array.length%2)return array[Math.floor(array.length/2)];var i=array.length/2;return(array[i-1]+array[i])/2};pv.variance=function(array,f){if(array.length<1)return NaN;if(array.length==1)return 0;var mean=pv.mean(array,f),sum=0,o={};if(!f)f=pv.identity;for(var i=0;i<array.length;i++){o.index=i;var d=f.call(o,array[i])-mean;sum+=d*d}return sum};pv.deviation=function(array,f){return Math.sqrt(pv.variance(array,f)/(array.length-1))};pv.log=function(x,b){return Math.log(x)/Math.log(b)};pv.logSymmetric=function(x,b){return x==0?0:x<0?-pv.log(-x,b):pv.log(x,b)};pv.logAdjusted=function(x,b){if(!isFinite(x))return x;var negative=x<0;if(x<b)x+=(b-x)/b;return negative?-pv.log(x,b):pv.log(x,b)};pv.logFloor=function(x,b){return x>0?Math.pow(b,Math.floor(pv.log(x,b))):-Math.pow(b,-Math.floor(-pv.log(-x,b)))};pv.logCeil=function(x,b){return x>0?Math.pow(b,Math.ceil(pv.log(x,b))):-Math.pow(b,-Math.ceil(-pv.log(-x,b)))};(function(){var radians=Math.PI/180,degrees=180/Math.PI;pv.radians=function(degrees){return radians*degrees};pv.degrees=function(radians){return degrees*radians}})();pv.keys=function(map){var array=[];for(var key in map){array.push(key)}return array};pv.entries=function(map){var array=[];for(var key in map){array.push({key:key,value:map[key]})}return array};pv.values=function(map){var array=[];for(var key in map){array.push(map[key])}return array};pv.dict=function(keys,f){var m={},o={};for(var i=0;i<keys.length;i++){if(i in keys){var k=keys[i];o.index=i;m[k]=f.call(o,k)}}return m};pv.dom=function(map){return new pv.Dom(map)};pv.Dom=function(map){this.$map=map};pv.Dom.prototype.$leaf=function(n){return typeof n!="object"};pv.Dom.prototype.leaf=function(f){if(arguments.length){this.$leaf=f;return this}return this.$leaf};pv.Dom.prototype.root=function(nodeName){var leaf=this.$leaf,root=recurse(this.$map);function recurse(map){var n=new pv.Dom.Node;for(var k in map){var v=map[k];n.appendChild(leaf(v)?new pv.Dom.Node(v):recurse(v)).nodeName=k}return n}root.nodeName=nodeName;return root};pv.Dom.prototype.nodes=function(){return this.root().nodes()};pv.Dom.Node=function(value){this.nodeValue=value;this.childNodes=[]};pv.Dom.Node.prototype.parentNode=null;pv.Dom.Node.prototype.firstChild=null;pv.Dom.Node.prototype.lastChild=null;pv.Dom.Node.prototype.previousSibling=null;pv.Dom.Node.prototype.nextSibling=null;pv.Dom.Node.prototype.removeChild=function(n){var i=this.childNodes.indexOf(n);if(i==-1)throw new Error("child not found");this.childNodes.splice(i,1);if(n.previousSibling)n.previousSibling.nextSibling=n.nextSibling;else this.firstChild=n.nextSibling;if(n.nextSibling)n.nextSibling.previousSibling=n.previousSibling;else this.lastChild=n.previousSibling;delete n.nextSibling;delete n.previousSibling;delete n.parentNode;return n};pv.Dom.Node.prototype.appendChild=function(n){if(n.parentNode)n.parentNode.removeChild(n);n.parentNode=this;n.previousSibling=this.lastChild;if(this.lastChild)this.lastChild.nextSibling=n;else this.firstChild=n;this.lastChild=n;this.childNodes.push(n);return n};pv.Dom.Node.prototype.insertBefore=function(n,r){if(!r)return this.appendChild(n);var i=this.childNodes.indexOf(r);if(i==-1)throw new Error("child not found");if(n.parentNode)n.parentNode.removeChild(n);n.parentNode=this;n.nextSibling=r;n.previousSibling=r.previousSibling;if(r.previousSibling){r.previousSibling.nextSibling=n}else{if(r==this.lastChild)this.lastChild=n;this.firstChild=n}this.childNodes.splice(i,0,n);return n};pv.Dom.Node.prototype.replaceChild=function(n,r){var i=this.childNodes.indexOf(r);if(i==-1)throw new Error("child not found");if(n.parentNode)n.parentNode.removeChild(n);n.parentNode=this;n.nextSibling=r.nextSibling;n.previousSibling=r.previousSibling;if(r.previousSibling)r.previousSibling.nextSibling=n;else this.firstChild=n;if(r.nextSibling)r.nextSibling.previousSibling=n;else this.lastChild=n;this.childNodes[i]=n;return r};pv.Dom.Node.prototype.visitBefore=function(f){function visit(n,i){f(n,i);for(var c=n.firstChild;c;c=c.nextSibling){visit(c,i+1)}}visit(this,0)};pv.Dom.Node.prototype.visitAfter=function(f){function visit(n,i){for(var c=n.firstChild;c;c=c.nextSibling){visit(c,i+1)}f(n,i)}visit(this,0)};pv.Dom.Node.prototype.sort=function(f){if(this.firstChild){this.childNodes.sort(f);var p=this.firstChild=this.childNodes[0],c;delete p.previousSibling;for(var i=1;i<this.childNodes.length;i++){p.sort(f);c=this.childNodes[i];c.previousSibling=p;p=p.nextSibling=c}this.lastChild=p;delete p.nextSibling;p.sort(f)}return this};pv.Dom.Node.prototype.reverse=function(){var childNodes=[];this.visitAfter(function(n){while(n.lastChild)childNodes.push(n.removeChild(n.lastChild));for(var c;c=childNodes.pop();)n.insertBefore(c,n.firstChild)});return this};pv.Dom.Node.prototype.nodes=function(){var array=[];function flatten(node){array.push(node);node.childNodes.forEach(flatten)}flatten(this,array);return array};pv.Dom.Node.prototype.toggle=function(recursive){if(recursive)return this.toggled?this.visitBefore(function(n){if(n.toggled)n.toggle()}):this.visitAfter(function(n){if(!n.toggled)n.toggle()});var n=this;if(n.toggled){for(var c;c=n.toggled.pop();)n.appendChild(c);delete n.toggled}else if(n.lastChild){n.toggled=[];while(n.lastChild)n.toggled.push(n.removeChild(n.lastChild))}};pv.nodes=function(values){var root=new pv.Dom.Node;for(var i=0;i<values.length;i++){root.appendChild(new pv.Dom.Node(values[i]))}return root.nodes()};pv.tree=function(array){return new pv.Tree(array)};pv.Tree=function(array){this.array=array};pv.Tree.prototype.keys=function(k){this.k=k;return this};pv.Tree.prototype.value=function(v){this.v=v;return this};pv.Tree.prototype.map=function(){var map={},o={};for(var i=0;i<this.array.length;i++){o.index=i;var value=this.array[i],keys=this.k.call(o,value),node=map;for(var j=0;j<keys.length-1;j++){node=node[keys[j]]||(node[keys[j]]={})}node[keys[j]]=this.v?this.v.call(o,value):value}return map};pv.nest=function(array){return new pv.Nest(array)};pv.Nest=function(array){this.array=array;this.keys=[]};pv.Nest.prototype.key=function(key){this.keys.push(key);return this};pv.Nest.prototype.sortKeys=function(order){this.keys[this.keys.length-1].order=order||pv.naturalOrder;return this};pv.Nest.prototype.sortValues=function(order){this.order=order||pv.naturalOrder;return this};pv.Nest.prototype.map=function(){var map={},values=[];for(var i,j=0;j<this.array.length;j++){var x=this.array[j];var m=map;for(i=0;i<this.keys.length-1;i++){var k=this.keys[i](x);if(!m[k])m[k]={};m=m[k]}k=this.keys[i](x);if(!m[k]){var a=[];values.push(a);m[k]=a}m[k].push(x)}if(this.order){for(var i=0;i<values.length;i++){values[i].sort(this.order)}}return map};pv.Nest.prototype.entries=function(){function entries(map){var array=[];for(var k in map){var v=map[k];array.push({key:k,values:v instanceof Array?v:entries(v)})}return array}function sort(array,i){var o=this.keys[i].order;if(o)array.sort(function(a,b){return o(a.key,b.key)});if(++i<this.keys.length){for(var j=0;j<array.length;j++){sort.call(this,array[j].values,i)}}return array}return sort.call(this,entries(this.map()),0)};pv.Nest.prototype.rollup=function(f){function rollup(map){for(var key in map){var value=map[key];if(value instanceof Array){map[key]=f(value)}else{rollup(value)}}return map}return rollup(this.map())};pv.flatten=function(map){return new pv.Flatten(map)};pv.Flatten=function(map){this.map=map;this.keys=[]};pv.Flatten.prototype.key=function(key,f){this.keys.push({name:key,value:f});delete this.$leaf;return this};pv.Flatten.prototype.leaf=function(f){this.keys.length=0;this.$leaf=f;return this};pv.Flatten.prototype.array=function(){var entries=[],stack=[],keys=this.keys,leaf=this.$leaf;if(leaf){function recurse(value,i){if(leaf(value)){entries.push({keys:stack.slice(),value:value})}else{for(var key in value){stack.push(key);recurse(value[key],i+1);stack.pop()}}}recurse(this.map,0);return entries}function visit(value,i){if(i<keys.length-1){for(var key in value){stack.push(key);visit(value[key],i+1);stack.pop()}}else{entries.push(stack.concat(value))}}visit(this.map,0);return entries.map(function(stack){var m={};for(var i=0;i<keys.length;i++){var k=keys[i],v=stack[i];m[k.name]=k.value?k.value.call(null,v):v}return m})};pv.vector=function(x,y){return new pv.Vector(x,y)};pv.Vector=function(x,y){this.x=x;this.y=y};pv.Vector.prototype.perp=function(){return new pv.Vector(-this.y,this.x)};pv.Vector.prototype.norm=function(){var l=this.length();return this.times(l?1/l:1)};pv.Vector.prototype.length=function(){return Math.sqrt(this.x*this.x+this.y*this.y)};pv.Vector.prototype.times=function(k){return new pv.Vector(this.x*k,this.y*k)};pv.Vector.prototype.plus=function(x,y){return arguments.length==1?new pv.Vector(this.x+x.x,this.y+x.y):new pv.Vector(this.x+x,this.y+y)};pv.Vector.prototype.minus=function(x,y){return arguments.length==1?new pv.Vector(this.x-x.x,this.y-x.y):new pv.Vector(this.x-x,this.y-y)};pv.Vector.prototype.dot=function(x,y){return arguments.length==1?this.x*x.x+this.y*x.y:this.x*x+this.y*y};pv.Transform=function(){};pv.Transform.prototype={k:1,x:0,y:0};pv.Transform.identity=new pv.Transform;pv.Transform.prototype.translate=function(x,y){var v=new pv.Transform;v.k=this.k;v.x=this.k*x+this.x;v.y=this.k*y+this.y;return v};pv.Transform.prototype.scale=function(k){var v=new pv.Transform;v.k=this.k*k;v.x=this.x;v.y=this.y;return v};pv.Transform.prototype.invert=function(){var v=new pv.Transform,k=1/this.k;v.k=k;v.x=-this.x*k;v.y=-this.y*k;return v};pv.Transform.prototype.times=function(m){var v=new pv.Transform;v.k=this.k*m.k;v.x=this.k*m.x+this.x;v.y=this.k*m.y+this.y;return v};pv.Scale=function(){};pv.Scale.interpolator=function(start,end){if(typeof start=="number"){return function(t){return t*(end-start)+start}}start=pv.color(start).rgb();end=pv.color(end).rgb();return function(t){var a=start.a*(1-t)+end.a*t;if(a<1e-5)a=0;return start.a==0?pv.rgb(end.r,end.g,end.b,a):end.a==0?pv.rgb(start.r,start.g,start.b,a):pv.rgb(Math.round(start.r*(1-t)+end.r*t),Math.round(start.g*(1-t)+end.g*t),Math.round(start.b*(1-t)+end.b*t),a)}};pv.Scale.quantitative=function(){var d=[0,1],l=[0,1],r=[0,1],i=[pv.identity],type=Number,n=false,f=pv.identity,g=pv.identity,tickFormat=String;function newDate(x){return new Date(x)}function scale(x){var j=pv.search(d,x);if(j<0)j=-j-2;j=Math.max(0,Math.min(i.length-1,j));return i[j]((f(x)-l[j])/(l[j+1]-l[j]))}scale.transform=function(forward,inverse){f=function(x){return n?-forward(-x):forward(x)};g=function(y){return n?-inverse(-y):inverse(y)};l=d.map(f);return this};scale.domain=function(array,min,max){if(arguments.length){var o;if(array instanceof Array){if(arguments.length<2)min=pv.identity;if(arguments.length<3)max=min;o=array.length&&min(array[0]);d=array.length?[pv.min(array,min),pv.max(array,max)]:[]}else{o=array;d=Array.prototype.slice.call(arguments).map(Number)}if(!d.length)d=[-Infinity,Infinity];else if(d.length==1)d=[d[0],d[0]];n=(d[0]||d[d.length-1])<0;l=d.map(f);type=o instanceof Date?newDate:Number;return this}return d.map(type)};scale.range=function(){if(arguments.length){r=Array.prototype.slice.call(arguments);if(!r.length)r=[-Infinity,Infinity];else if(r.length==1)r=[r[0],r[0]];i=[];for(var j=0;j<r.length-1;j++){i.push(pv.Scale.interpolator(r[j],r[j+1]))}return this}return r};scale.invert=function(y){var j=pv.search(r,y);if(j<0)j=-j-2;j=Math.max(0,Math.min(i.length-1,j));return type(g(l[j]+(y-r[j])/(r[j+1]-r[j])*(l[j+1]-l[j])))};scale.ticks=function(m){var start=d[0],end=d[d.length-1],reverse=end<start,min=reverse?end:start,max=reverse?start:end,span=max-min;if(!span||!isFinite(span)){if(type==newDate)tickFormat=pv.Format.date("%x");return[type(min)]}if(type==newDate){function floor(d,p){switch(p){case 31536e6:d.setMonth(0);case 2592e6:d.setDate(1);case 6048e5:if(p==6048e5)d.setDate(d.getDate()-d.getDay());case 864e5:d.setHours(0);case 36e5:d.setMinutes(0);case 6e4:d.setSeconds(0);case 1e3:d.setMilliseconds(0)}}var precision,format,increment,step=1;if(span>=3*31536e6){precision=31536e6;format="%Y";increment=function(d){d.setFullYear(d.getFullYear()+step)}}else if(span>=3*2592e6){precision=2592e6;format="%m/%Y";increment=function(d){d.setMonth(d.getMonth()+step)}}else if(span>=3*6048e5){precision=6048e5;format="%m/%d";increment=function(d){d.setDate(d.getDate()+7*step)}}else if(span>=3*864e5){precision=864e5;format="%m/%d";increment=function(d){d.setDate(d.getDate()+step)}}else if(span>=3*36e5){precision=36e5;format="%I:%M %p";increment=function(d){d.setHours(d.getHours()+step)}}else if(span>=3*6e4){precision=6e4;format="%I:%M %p";increment=function(d){d.setMinutes(d.getMinutes()+step)}}else if(span>=3*1e3){precision=1e3;format="%I:%M:%S";increment=function(d){d.setSeconds(d.getSeconds()+step)}}else{precision=1;format="%S.%Qs";increment=function(d){d.setTime(d.getTime()+step)}}tickFormat=pv.Format.date(format);var date=new Date(min),dates=[];floor(date,precision);var n=span/precision;if(n>10){switch(precision){case 36e5:{step=n>20?6:3;date.setHours(Math.floor(date.getHours()/step)*step);break}case 2592e6:{step=3;date.setMonth(Math.floor(date.getMonth()/step)*step);break}case 6e4:{step=n>30?15:n>15?10:5;date.setMinutes(Math.floor(date.getMinutes()/step)*step);break}case 1e3:{step=n>90?15:n>60?10:5;date.setSeconds(Math.floor(date.getSeconds()/step)*step);break}case 1:{step=n>1e3?250:n>200?100:n>100?50:n>50?25:5;date.setMilliseconds(Math.floor(date.getMilliseconds()/step)*step);break}default:{step=pv.logCeil(n/15,10);if(n/step<2)step/=5;else if(n/step<5)step/=2;date.setFullYear(Math.floor(date.getFullYear()/step)*step);break}}}while(true){increment(date);if(date>max)break;dates.push(new Date(date))}return reverse?dates.reverse():dates}if(!arguments.length)m=10;var step=pv.logFloor(span/m,10),err=m/(span/step);if(err<=.15)step*=10;else if(err<=.35)step*=5;else if(err<=.75)step*=2;var start=Math.ceil(min/step)*step,end=Math.floor(max/step)*step;tickFormat=pv.Format.number().fractionDigits(Math.max(0,-Math.floor(pv.log(step,10)+.01)));var ticks=pv.range(start,end+step,step);return reverse?ticks.reverse():ticks};scale.tickFormat=function(t){return tickFormat(t)};scale.nice=function(){if(d.length!=2)return this;var start=d[0],end=d[d.length-1],reverse=end<start,min=reverse?end:start,max=reverse?start:end,span=max-min;if(!span||!isFinite(span))return this;var step=Math.pow(10,Math.round(Math.log(span)/Math.log(10))-1);d=[Math.floor(min/step)*step,Math.ceil(max/step)*step];if(reverse)d.reverse();l=d.map(f);return this};scale.by=function(f){function by(){return scale(f.apply(this,arguments))}for(var method in scale)by[method]=scale[method];return by};scale.domain.apply(scale,arguments);return scale};pv.Scale.linear=function(){var scale=pv.Scale.quantitative();scale.domain.apply(scale,arguments);return scale};pv.Scale.log=function(){var scale=pv.Scale.quantitative(1,10),b,p,log=function(x){return Math.log(x)/p},pow=function(y){return Math.pow(b,y)};scale.ticks=function(){var d=scale.domain(),n=d[0]<0,i=Math.floor(n?-log(-d[0]):log(d[0])),j=Math.ceil(n?-log(-d[1]):log(d[1])),ticks=[];if(n){ticks.push(-pow(-i));for(;i++<j;)for(var k=b-1;k>0;k--)ticks.push(-pow(-i)*k)}else{for(;i<j;i++)for(var k=1;k<b;k++)ticks.push(pow(i)*k);ticks.push(pow(i))}for(i=0;ticks[i]<d[0];i++);for(j=ticks.length;ticks[j-1]>d[1];j--);return ticks.slice(i,j)};scale.tickFormat=function(t){return t.toPrecision(1)};scale.nice=function(){var d=scale.domain();return scale.domain(pv.logFloor(d[0],b),pv.logCeil(d[1],b))};scale.base=function(v){if(arguments.length){b=Number(v);p=Math.log(b);scale.transform(log,pow);return this}return b};scale.domain.apply(scale,arguments);return scale.base(10)};pv.Scale.root=function(){var scale=pv.Scale.quantitative();scale.power=function(v){if(arguments.length){var b=Number(v),p=1/b;scale.transform(function(x){return Math.pow(x,p)},function(y){return Math.pow(y,b)});return this}return b};scale.domain.apply(scale,arguments);return scale.power(2)};pv.Scale.ordinal=function(){var d=[],i={},r=[],band=0;function scale(x){if(!(x in i))i[x]=d.push(x)-1;return r[i[x]%r.length]}scale.domain=function(array,f){if(arguments.length){array=array instanceof Array?arguments.length>1?pv.map(array,f):array:Array.prototype.slice.call(arguments);d=[];var seen={};for(var j=0;j<array.length;j++){var o=array[j];if(!(o in seen)){seen[o]=true;d.push(o)}}i=pv.numerate(d);return this}return d};scale.range=function(array,f){if(arguments.length){r=array instanceof Array?arguments.length>1?pv.map(array,f):array:Array.prototype.slice.call(arguments);if(typeof r[0]=="string")r=r.map(pv.color);return this}return r};scale.split=function(min,max){var step=(max-min)/this.domain().length;r=pv.range(min+step/2,max,step);return this};scale.splitFlush=function(min,max){var n=this.domain().length,step=(max-min)/(n-1);r=n==1?[(min+max)/2]:pv.range(min,max+step/2,step);return this};scale.splitBanded=function(min,max,band){if(arguments.length<3)band=1;if(band<0){var n=this.domain().length,total=-band*n,remaining=max-min-total,padding=remaining/(n+1);r=pv.range(min+padding,max,padding-band);r.band=-band}else{var step=(max-min)/(this.domain().length+(1-band));r=pv.range(min+step*(1-band),max,step);r.band=step*band}return this};scale.by=function(f){function by(){return scale(f.apply(this,arguments))}for(var method in scale)by[method]=scale[method];return by};scale.domain.apply(scale,arguments);return scale};pv.Scale.quantile=function(){var n=-1,j=-1,q=[],d=[],y=pv.Scale.linear();function scale(x){return y(Math.max(0,Math.min(j,pv.search.index(q,x)-1))/j)}scale.quantiles=function(x){if(arguments.length){n=Number(x);if(n<0){q=[d[0]].concat(d);j=d.length-1}else{q=[];q[0]=d[0];for(var i=1;i<=n;i++){q[i]=d[~~(i*(d.length-1)/n)]}j=n-1}return this}return q};scale.domain=function(array,f){if(arguments.length){d=array instanceof Array?pv.map(array,f):Array.prototype.slice.call(arguments);d.sort(pv.naturalOrder);scale.quantiles(n);return this}return d};scale.range=function(){if(arguments.length){y.range.apply(y,arguments);return this}return y.range()};scale.by=function(f){function by(){return scale(f.apply(this,arguments))}for(var method in scale)by[method]=scale[method];return by};scale.domain.apply(scale,arguments);return scale};pv.histogram=function(data,f){var frequency=true;return{bins:function(ticks){var x=pv.map(data,f),bins=[];if(!arguments.length)ticks=pv.Scale.linear(x).ticks();for(var i=0;i<ticks.length-1;i++){var bin=bins[i]=[];bin.x=ticks[i];bin.dx=ticks[i+1]-ticks[i];bin.y=0}for(var i=0;i<x.length;i++){var j=pv.search.index(ticks,x[i])-1,bin=bins[Math.max(0,Math.min(bins.length-1,j))];bin.y++;bin.push(data[i])}if(!frequency)for(var i=0;i<bins.length;i++){bins[i].y/=x.length}return bins},frequency:function(x){if(arguments.length){frequency=Boolean(x);return this}return frequency}}};pv.color=function(format){if(format.rgb)return format.rgb();var m1=/([a-z]+)\((.*)\)/i.exec(format);if(m1){var m2=m1[2].split(","),a=1;switch(m1[1]){case"hsla":case"rgba":{a=parseFloat(m2[3]);if(!a)return pv.Color.transparent;break}}switch(m1[1]){case"hsla":case"hsl":{var h=parseFloat(m2[0]),s=parseFloat(m2[1])/100,l=parseFloat(m2[2])/100;return new pv.Color.Hsl(h,s,l,a).rgb()}case"rgba":case"rgb":{function parse(c){var f=parseFloat(c);return c[c.length-1]=="%"?Math.round(f*2.55):f}var r=parse(m2[0]),g=parse(m2[1]),b=parse(m2[2]);return pv.rgb(r,g,b,a)}}}var named=pv.Color.names[format];if(named)return named;if(format.charAt(0)=="#"){var r,g,b;if(format.length==4){r=format.charAt(1);r+=r;g=format.charAt(2);g+=g;b=format.charAt(3);b+=b}else if(format.length==7){r=format.substring(1,3);g=format.substring(3,5);b=format.substring(5,7)}return pv.rgb(parseInt(r,16),parseInt(g,16),parseInt(b,16),1)}return new pv.Color(format,1)};pv.Color=function(color,opacity){this.color=color;this.opacity=opacity};pv.Color.prototype.brighter=function(k){return this.rgb().brighter(k)};pv.Color.prototype.darker=function(k){return this.rgb().darker(k)};pv.rgb=function(r,g,b,a){return new pv.Color.Rgb(r,g,b,arguments.length==4?a:1)};pv.Color.Rgb=function(r,g,b,a){pv.Color.call(this,a?"rgb("+r+","+g+","+b+")":"none",a);this.r=r;this.g=g;
this.b=b;this.a=a};pv.Color.Rgb.prototype=pv.extend(pv.Color);pv.Color.Rgb.prototype.red=function(r){return pv.rgb(r,this.g,this.b,this.a)};pv.Color.Rgb.prototype.green=function(g){return pv.rgb(this.r,g,this.b,this.a)};pv.Color.Rgb.prototype.blue=function(b){return pv.rgb(this.r,this.g,b,this.a)};pv.Color.Rgb.prototype.alpha=function(a){return pv.rgb(this.r,this.g,this.b,a)};pv.Color.Rgb.prototype.rgb=function(){return this};pv.Color.Rgb.prototype.brighter=function(k){k=Math.pow(.7,arguments.length?k:1);var r=this.r,g=this.g,b=this.b,i=30;if(!r&&!g&&!b)return pv.rgb(i,i,i,this.a);if(r&&r<i)r=i;if(g&&g<i)g=i;if(b&&b<i)b=i;return pv.rgb(Math.min(255,Math.floor(r/k)),Math.min(255,Math.floor(g/k)),Math.min(255,Math.floor(b/k)),this.a)};pv.Color.Rgb.prototype.darker=function(k){k=Math.pow(.7,arguments.length?k:1);return pv.rgb(Math.max(0,Math.floor(k*this.r)),Math.max(0,Math.floor(k*this.g)),Math.max(0,Math.floor(k*this.b)),this.a)};pv.hsl=function(h,s,l,a){return new pv.Color.Hsl(h,s,l,arguments.length==4?a:1)};pv.Color.Hsl=function(h,s,l,a){pv.Color.call(this,"hsl("+h+","+s*100+"%,"+l*100+"%)",a);this.h=h;this.s=s;this.l=l;this.a=a};pv.Color.Hsl.prototype=pv.extend(pv.Color);pv.Color.Hsl.prototype.hue=function(h){return pv.hsl(h,this.s,this.l,this.a)};pv.Color.Hsl.prototype.saturation=function(s){return pv.hsl(this.h,s,this.l,this.a)};pv.Color.Hsl.prototype.lightness=function(l){return pv.hsl(this.h,this.s,l,this.a)};pv.Color.Hsl.prototype.alpha=function(a){return pv.hsl(this.h,this.s,this.l,a)};pv.Color.Hsl.prototype.rgb=function(){var h=this.h,s=this.s,l=this.l;h=h%360;if(h<0)h+=360;s=Math.max(0,Math.min(s,1));l=Math.max(0,Math.min(l,1));var m2=l<=.5?l*(1+s):l+s-l*s;var m1=2*l-m2;function v(h){if(h>360)h-=360;else if(h<0)h+=360;if(h<60)return m1+(m2-m1)*h/60;if(h<180)return m2;if(h<240)return m1+(m2-m1)*(240-h)/60;return m1}function vv(h){return Math.round(v(h)*255)}return pv.rgb(vv(h+120),vv(h),vv(h-120),this.a)};pv.Color.names={aliceblue:"#f0f8ff",antiquewhite:"#faebd7",aqua:"#00ffff",aquamarine:"#7fffd4",azure:"#f0ffff",beige:"#f5f5dc",bisque:"#ffe4c4",black:"#000000",blanchedalmond:"#ffebcd",blue:"#0000ff",blueviolet:"#8a2be2",brown:"#a52a2a",burlywood:"#deb887",cadetblue:"#5f9ea0",chartreuse:"#7fff00",chocolate:"#d2691e",coral:"#ff7f50",cornflowerblue:"#6495ed",cornsilk:"#fff8dc",crimson:"#dc143c",cyan:"#00ffff",darkblue:"#00008b",darkcyan:"#008b8b",darkgoldenrod:"#b8860b",darkgray:"#a9a9a9",darkgreen:"#006400",darkgrey:"#a9a9a9",darkkhaki:"#bdb76b",darkmagenta:"#8b008b",darkolivegreen:"#556b2f",darkorange:"#ff8c00",darkorchid:"#9932cc",darkred:"#8b0000",darksalmon:"#e9967a",darkseagreen:"#8fbc8f",darkslateblue:"#483d8b",darkslategray:"#2f4f4f",darkslategrey:"#2f4f4f",darkturquoise:"#00ced1",darkviolet:"#9400d3",deeppink:"#ff1493",deepskyblue:"#00bfff",dimgray:"#696969",dimgrey:"#696969",dodgerblue:"#1e90ff",firebrick:"#b22222",floralwhite:"#fffaf0",forestgreen:"#228b22",fuchsia:"#ff00ff",gainsboro:"#dcdcdc",ghostwhite:"#f8f8ff",gold:"#ffd700",goldenrod:"#daa520",gray:"#808080",green:"#008000",greenyellow:"#adff2f",grey:"#808080",honeydew:"#f0fff0",hotpink:"#ff69b4",indianred:"#cd5c5c",indigo:"#4b0082",ivory:"#fffff0",khaki:"#f0e68c",lavender:"#e6e6fa",lavenderblush:"#fff0f5",lawngreen:"#7cfc00",lemonchiffon:"#fffacd",lightblue:"#add8e6",lightcoral:"#f08080",lightcyan:"#e0ffff",lightgoldenrodyellow:"#fafad2",lightgray:"#d3d3d3",lightgreen:"#90ee90",lightgrey:"#d3d3d3",lightpink:"#ffb6c1",lightsalmon:"#ffa07a",lightseagreen:"#20b2aa",lightskyblue:"#87cefa",lightslategray:"#778899",lightslategrey:"#778899",lightsteelblue:"#b0c4de",lightyellow:"#ffffe0",lime:"#00ff00",limegreen:"#32cd32",linen:"#faf0e6",magenta:"#ff00ff",maroon:"#800000",mediumaquamarine:"#66cdaa",mediumblue:"#0000cd",mediumorchid:"#ba55d3",mediumpurple:"#9370db",mediumseagreen:"#3cb371",mediumslateblue:"#7b68ee",mediumspringgreen:"#00fa9a",mediumturquoise:"#48d1cc",mediumvioletred:"#c71585",midnightblue:"#191970",mintcream:"#f5fffa",mistyrose:"#ffe4e1",moccasin:"#ffe4b5",navajowhite:"#ffdead",navy:"#000080",oldlace:"#fdf5e6",olive:"#808000",olivedrab:"#6b8e23",orange:"#ffa500",orangered:"#ff4500",orchid:"#da70d6",palegoldenrod:"#eee8aa",palegreen:"#98fb98",paleturquoise:"#afeeee",palevioletred:"#db7093",papayawhip:"#ffefd5",peachpuff:"#ffdab9",peru:"#cd853f",pink:"#ffc0cb",plum:"#dda0dd",powderblue:"#b0e0e6",purple:"#800080",red:"#ff0000",rosybrown:"#bc8f8f",royalblue:"#4169e1",saddlebrown:"#8b4513",salmon:"#fa8072",sandybrown:"#f4a460",seagreen:"#2e8b57",seashell:"#fff5ee",sienna:"#a0522d",silver:"#c0c0c0",skyblue:"#87ceeb",slateblue:"#6a5acd",slategray:"#708090",slategrey:"#708090",snow:"#fffafa",springgreen:"#00ff7f",steelblue:"#4682b4",tan:"#d2b48c",teal:"#008080",thistle:"#d8bfd8",tomato:"#ff6347",turquoise:"#40e0d0",violet:"#ee82ee",wheat:"#f5deb3",white:"#ffffff",whitesmoke:"#f5f5f5",yellow:"#ffff00",yellowgreen:"#9acd32",transparent:pv.Color.transparent=pv.rgb(0,0,0,0)};(function(){var names=pv.Color.names;for(var name in names)names[name]=pv.color(names[name])})();pv.colors=function(){var scale=pv.Scale.ordinal();scale.range.apply(scale,arguments);return scale};pv.Colors={};pv.Colors.category10=function(){var scale=pv.colors("#1f77b4","#ff7f0e","#2ca02c","#d62728","#9467bd","#8c564b","#e377c2","#7f7f7f","#bcbd22","#17becf");scale.domain.apply(scale,arguments);return scale};pv.Colors.category20=function(){var scale=pv.colors("#1f77b4","#aec7e8","#ff7f0e","#ffbb78","#2ca02c","#98df8a","#d62728","#ff9896","#9467bd","#c5b0d5","#8c564b","#c49c94","#e377c2","#f7b6d2","#7f7f7f","#c7c7c7","#bcbd22","#dbdb8d","#17becf","#9edae5");scale.domain.apply(scale,arguments);return scale};pv.Colors.category19=function(){var scale=pv.colors("#9c9ede","#7375b5","#4a5584","#cedb9c","#b5cf6b","#8ca252","#637939","#e7cb94","#e7ba52","#bd9e39","#8c6d31","#e7969c","#d6616b","#ad494a","#843c39","#de9ed6","#ce6dbd","#a55194","#7b4173");scale.domain.apply(scale,arguments);return scale};pv.ramp=function(start,end){var scale=pv.Scale.linear();scale.range.apply(scale,arguments);return scale};pv.Scene=pv.SvgScene={svg:"http://www.w3.org/2000/svg",xmlns:"http://www.w3.org/2000/xmlns",xlink:"http://www.w3.org/1999/xlink",xhtml:"http://www.w3.org/1999/xhtml",scale:1,events:["DOMMouseScroll","mousewheel","mousedown","mouseup","mouseover","mouseout","mousemove","click","dblclick"],implicit:{svg:{"shape-rendering":"auto","pointer-events":"painted",x:0,y:0,dy:0,"text-anchor":"start",transform:"translate(0,0)",fill:"none","fill-opacity":1,stroke:"none","stroke-opacity":1,"stroke-width":1.5,"stroke-linejoin":"miter"},css:{font:"10px sans-serif"}}};pv.SvgScene.updateAll=function(scenes){if(scenes.length&&scenes[0].reverse&&scenes.type!="line"&&scenes.type!="area"){var reversed=pv.extend(scenes);for(var i=0,j=scenes.length-1;j>=0;i++,j--){reversed[i]=scenes[j]}scenes=reversed}this.removeSiblings(this[scenes.type](scenes))};pv.SvgScene.create=function(type){return document.createElementNS(this.svg,type)};pv.SvgScene.expect=function(e,type,attributes,style){if(e){if(e.tagName=="a")e=e.firstChild;if(e.tagName!=type){var n=this.create(type);e.parentNode.replaceChild(n,e);e=n}}else{e=this.create(type)}for(var name in attributes){var value=attributes[name];if(value==this.implicit.svg[name])value=null;if(value==null)e.removeAttribute(name);else e.setAttribute(name,value)}for(var name in style){var value=style[name];if(value==this.implicit.css[name])value=null;if(value==null)e.style.removeProperty(name);else e.style[name]=value}return e};pv.SvgScene.append=function(e,scenes,index){e.$scene={scenes:scenes,index:index};e=this.title(e,scenes[index]);if(!e.parentNode)scenes.$g.appendChild(e);return e.nextSibling};pv.SvgScene.title=function(e,s){var a=e.parentNode;if(a&&a.tagName!="a")a=null;if(s.title){if(!a){a=this.create("a");if(e.parentNode)e.parentNode.replaceChild(a,e);a.appendChild(e)}a.setAttributeNS(this.xlink,"title",s.title);return a}if(a)a.parentNode.replaceChild(e,a);return e};pv.SvgScene.dispatch=pv.listener(function(e){var t=e.target.$scene;if(t){var type=e.type;switch(type){case"DOMMouseScroll":{type="mousewheel";e.wheel=-480*e.detail;break}case"mousewheel":{e.wheel=(window.opera?12:1)*e.wheelDelta;break}}if(pv.Mark.dispatch(type,t.scenes,t.index))e.preventDefault()}});pv.SvgScene.removeSiblings=function(e){while(e){var n=e.nextSibling;e.parentNode.removeChild(e);e=n}};pv.SvgScene.undefined=function(){};pv.SvgScene.pathBasis=function(){var basis=[[1/6,2/3,1/6,0],[0,2/3,1/3,0],[0,1/3,2/3,0],[0,1/6,2/3,1/6]];function weight(w,p0,p1,p2,p3){return{x:w[0]*p0.left+w[1]*p1.left+w[2]*p2.left+w[3]*p3.left,y:w[0]*p0.top+w[1]*p1.top+w[2]*p2.top+w[3]*p3.top}}var convert=function(p0,p1,p2,p3){var b1=weight(basis[1],p0,p1,p2,p3),b2=weight(basis[2],p0,p1,p2,p3),b3=weight(basis[3],p0,p1,p2,p3);return"C"+b1.x+","+b1.y+","+b2.x+","+b2.y+","+b3.x+","+b3.y};convert.segment=function(p0,p1,p2,p3){var b0=weight(basis[0],p0,p1,p2,p3),b1=weight(basis[1],p0,p1,p2,p3),b2=weight(basis[2],p0,p1,p2,p3),b3=weight(basis[3],p0,p1,p2,p3);return"M"+b0.x+","+b0.y+"C"+b1.x+","+b1.y+","+b2.x+","+b2.y+","+b3.x+","+b3.y};return convert}();pv.SvgScene.curveBasis=function(points){if(points.length<=2)return"";var path="",p0=points[0],p1=p0,p2=p0,p3=points[1];path+=this.pathBasis(p0,p1,p2,p3);for(var i=2;i<points.length;i++){p0=p1;p1=p2;p2=p3;p3=points[i];path+=this.pathBasis(p0,p1,p2,p3)}path+=this.pathBasis(p1,p2,p3,p3);path+=this.pathBasis(p2,p3,p3,p3);return path};pv.SvgScene.curveBasisSegments=function(points){if(points.length<=2)return"";var paths=[],p0=points[0],p1=p0,p2=p0,p3=points[1],firstPath=this.pathBasis.segment(p0,p1,p2,p3);p0=p1;p1=p2;p2=p3;p3=points[2];paths.push(firstPath+this.pathBasis(p0,p1,p2,p3));for(var i=3;i<points.length;i++){p0=p1;p1=p2;p2=p3;p3=points[i];paths.push(this.pathBasis.segment(p0,p1,p2,p3))}paths.push(this.pathBasis.segment(p1,p2,p3,p3)+this.pathBasis(p2,p3,p3,p3));return paths};pv.SvgScene.curveHermite=function(points,tangents){if(tangents.length<1||points.length!=tangents.length&&points.length!=tangents.length+2)return"";var quad=points.length!=tangents.length,path="",p0=points[0],p=points[1],t0=tangents[0],t=t0,pi=1;if(quad){path+="Q"+(p.left-t0.x*2/3)+","+(p.top-t0.y*2/3)+","+p.left+","+p.top;p0=points[1];pi=2}if(tangents.length>1){t=tangents[1];p=points[pi];pi++;path+="C"+(p0.left+t0.x)+","+(p0.top+t0.y)+","+(p.left-t.x)+","+(p.top-t.y)+","+p.left+","+p.top;for(var i=2;i<tangents.length;i++,pi++){p=points[pi];t=tangents[i];path+="S"+(p.left-t.x)+","+(p.top-t.y)+","+p.left+","+p.top}}if(quad){var lp=points[pi];path+="Q"+(p.left+t.x*2/3)+","+(p.top+t.y*2/3)+","+lp.left+","+lp.top}return path};pv.SvgScene.curveHermiteSegments=function(points,tangents){if(tangents.length<1||points.length!=tangents.length&&points.length!=tangents.length+2)return[];var quad=points.length!=tangents.length,paths=[],p0=points[0],p=p0,t0=tangents[0],t=t0,pi=1;if(quad){p=points[1];paths.push("M"+p0.left+","+p0.top+"Q"+(p.left-t.x*2/3)+","+(p.top-t.y*2/3)+","+p.left+","+p.top);pi=2}for(var i=1;i<tangents.length;i++,pi++){p0=p;t0=t;p=points[pi];t=tangents[i];paths.push("M"+p0.left+","+p0.top+"C"+(p0.left+t0.x)+","+(p0.top+t0.y)+","+(p.left-t.x)+","+(p.top-t.y)+","+p.left+","+p.top)}if(quad){var lp=points[pi];paths.push("M"+p.left+","+p.top+"Q"+(p.left+t.x*2/3)+","+(p.top+t.y*2/3)+","+lp.left+","+lp.top)}return paths};pv.SvgScene.cardinalTangents=function(points,tension){var tangents=[],a=(1-tension)/2,p0=points[0],p1=points[1],p2=points[2];for(var i=3;i<points.length;i++){tangents.push({x:a*(p2.left-p0.left),y:a*(p2.top-p0.top)});p0=p1;p1=p2;p2=points[i]}tangents.push({x:a*(p2.left-p0.left),y:a*(p2.top-p0.top)});return tangents};pv.SvgScene.curveCardinal=function(points,tension){if(points.length<=2)return"";return this.curveHermite(points,this.cardinalTangents(points,tension))};pv.SvgScene.curveCardinalSegments=function(points,tension){if(points.length<=2)return"";return this.curveHermiteSegments(points,this.cardinalTangents(points,tension))};pv.SvgScene.monotoneTangents=function(points){var tangents=[],d=[],m=[],dx=[],k=0;for(k=0;k<points.length-1;k++){d[k]=(points[k+1].top-points[k].top)/(points[k+1].left-points[k].left)}m[0]=d[0];dx[0]=points[1].left-points[0].left;for(k=1;k<points.length-1;k++){m[k]=(d[k-1]+d[k])/2;dx[k]=(points[k+1].left-points[k-1].left)/2}m[k]=d[k-1];dx[k]=points[k].left-points[k-1].left;for(k=0;k<points.length-1;k++){if(d[k]==0){m[k]=0;m[k+1]=0}}for(k=0;k<points.length-1;k++){if(Math.abs(m[k])<1e-5||Math.abs(m[k+1])<1e-5)continue;var ak=m[k]/d[k],bk=m[k+1]/d[k],s=ak*ak+bk*bk;if(s>9){var tk=3/Math.sqrt(s);m[k]=tk*ak*d[k];m[k+1]=tk*bk*d[k]}}var len;for(var i=0;i<points.length;i++){len=1+m[i]*m[i];tangents.push({x:dx[i]/3/len,y:m[i]*dx[i]/3/len})}return tangents};pv.SvgScene.curveMonotone=function(points){if(points.length<=2)return"";return this.curveHermite(points,this.monotoneTangents(points))};pv.SvgScene.curveMonotoneSegments=function(points){if(points.length<=2)return"";return this.curveHermiteSegments(points,this.monotoneTangents(points))};pv.SvgScene.area=function(scenes){var e=scenes.$g.firstChild;if(!scenes.length)return e;var s=scenes[0];if(s.segmented)return this.areaSegment(scenes);if(!s.visible)return e;var fill=s.fillStyle,stroke=s.strokeStyle;if(!fill.opacity&&!stroke.opacity)return e;function path(i,j){var p1=[],p2=[];for(var k=j;i<=k;i++,j--){var si=scenes[i],sj=scenes[j],pi=si.left+","+si.top,pj=sj.left+sj.width+","+(sj.top+sj.height);if(i<k){var sk=scenes[i+1],sl=scenes[j-1];switch(s.interpolate){case"step-before":{pi+="V"+sk.top;pj+="H"+(sl.left+sl.width);break}case"step-after":{pi+="H"+sk.left;pj+="V"+(sl.top+sl.height);break}}}p1.push(pi);p2.push(pj)}return p1.concat(p2).join("L")}function pathCurve(i,j){var pointsT=[],pointsB=[],pathT,pathB;for(var k=j;i<=k;i++,j--){var sj=scenes[j];pointsT.push(scenes[i]);pointsB.push({left:sj.left+sj.width,top:sj.top+sj.height})}if(s.interpolate=="basis"){pathT=pv.SvgScene.curveBasis(pointsT);pathB=pv.SvgScene.curveBasis(pointsB)}else if(s.interpolate=="cardinal"){pathT=pv.SvgScene.curveCardinal(pointsT,s.tension);pathB=pv.SvgScene.curveCardinal(pointsB,s.tension)}else{pathT=pv.SvgScene.curveMonotone(pointsT);pathB=pv.SvgScene.curveMonotone(pointsB)}return pointsT[0].left+","+pointsT[0].top+pathT+"L"+pointsB[0].left+","+pointsB[0].top+pathB}var d=[],si,sj;for(var i=0;i<scenes.length;i++){si=scenes[i];if(!si.width&&!si.height)continue;for(var j=i+1;j<scenes.length;j++){sj=scenes[j];if(!sj.width&&!sj.height)break}if(i&&s.interpolate!="step-after")i--;if(j<scenes.length&&s.interpolate!="step-before")j++;d.push((j-i>2&&(s.interpolate=="basis"||s.interpolate=="cardinal"||s.interpolate=="monotone")?pathCurve:path)(i,j-1));i=j-1}if(!d.length)return e;e=this.expect(e,"path",{"shape-rendering":s.antialias?null:"crispEdges","pointer-events":s.events,cursor:s.cursor,d:"M"+d.join("ZM")+"Z",fill:fill.color,"fill-opacity":fill.opacity||null,stroke:stroke.color,"stroke-opacity":stroke.opacity||null,"stroke-width":stroke.opacity?s.lineWidth/this.scale:null});return this.append(e,scenes,0)};pv.SvgScene.areaSegment=function(scenes){var e=scenes.$g.firstChild,s=scenes[0],pathsT,pathsB;if(s.interpolate=="basis"||s.interpolate=="cardinal"||s.interpolate=="monotone"){var pointsT=[],pointsB=[];for(var i=0,n=scenes.length;i<n;i++){var sj=scenes[n-i-1];pointsT.push(scenes[i]);pointsB.push({left:sj.left+sj.width,top:sj.top+sj.height})}if(s.interpolate=="basis"){pathsT=this.curveBasisSegments(pointsT);pathsB=this.curveBasisSegments(pointsB)}else if(s.interpolate=="cardinal"){pathsT=this.curveCardinalSegments(pointsT,s.tension);pathsB=this.curveCardinalSegments(pointsB,s.tension)}else{pathsT=this.curveMonotoneSegments(pointsT);pathsB=this.curveMonotoneSegments(pointsB)}}for(var i=0,n=scenes.length-1;i<n;i++){var s1=scenes[i],s2=scenes[i+1];if(!s1.visible||!s2.visible)continue;var fill=s1.fillStyle,stroke=s1.strokeStyle;if(!fill.opacity&&!stroke.opacity)continue;var d;if(pathsT){var pathT=pathsT[i],pathB="L"+pathsB[n-i-1].substr(1);d=pathT+pathB+"Z"}else{var si=s1,sj=s2;switch(s1.interpolate){case"step-before":si=s2;break;case"step-after":sj=s1;break}d="M"+s1.left+","+si.top+"L"+s2.left+","+sj.top+"L"+(s2.left+s2.width)+","+(sj.top+sj.height)+"L"+(s1.left+s1.width)+","+(si.top+si.height)+"Z"}e=this.expect(e,"path",{"shape-rendering":s1.antialias?null:"crispEdges","pointer-events":s1.events,cursor:s1.cursor,d:d,fill:fill.color,"fill-opacity":fill.opacity||null,stroke:stroke.color,"stroke-opacity":stroke.opacity||null,"stroke-width":stroke.opacity?s1.lineWidth/this.scale:null});e=this.append(e,scenes,i)}return e};pv.SvgScene.bar=function(scenes){var e=scenes.$g.firstChild;for(var i=0;i<scenes.length;i++){var s=scenes[i];if(!s.visible)continue;var fill=s.fillStyle,stroke=s.strokeStyle;if(!fill.opacity&&!stroke.opacity)continue;e=this.expect(e,"rect",{"shape-rendering":s.antialias?null:"crispEdges","pointer-events":s.events,cursor:s.cursor,x:s.left,y:s.top,width:Math.max(1e-10,s.width),height:Math.max(1e-10,s.height),fill:fill.color,"fill-opacity":fill.opacity||null,stroke:stroke.color,"stroke-opacity":stroke.opacity||null,"stroke-width":stroke.opacity?s.lineWidth/this.scale:null});e=this.append(e,scenes,i)}return e};pv.SvgScene.dot=function(scenes){var e=scenes.$g.firstChild;for(var i=0;i<scenes.length;i++){var s=scenes[i];if(!s.visible)continue;var fill=s.fillStyle,stroke=s.strokeStyle;if(!fill.opacity&&!stroke.opacity)continue;var radius=s.radius,path=null;switch(s.shape){case"cross":{path="M"+-radius+","+-radius+"L"+radius+","+radius+"M"+radius+","+-radius+"L"+-radius+","+radius;break}case"triangle":{var h=radius,w=radius*1.1547;path="M0,"+h+"L"+w+","+-h+" "+-w+","+-h+"Z";break}case"diamond":{radius*=Math.SQRT2;path="M0,"+-radius+"L"+radius+",0"+" 0,"+radius+" "+-radius+",0"+"Z";break}case"square":{path="M"+-radius+","+-radius+"L"+radius+","+-radius+" "+radius+","+radius+" "+-radius+","+radius+"Z";break}case"tick":{path="M0,0L0,"+-s.size;break}case"bar":{path="M0,"+s.size/2+"L0,"+-(s.size/2);break}}var svg={"shape-rendering":s.antialias?null:"crispEdges","pointer-events":s.events,cursor:s.cursor,fill:fill.color,"fill-opacity":fill.opacity||null,stroke:stroke.color,"stroke-opacity":stroke.opacity||null,"stroke-width":stroke.opacity?s.lineWidth/this.scale:null};if(path){svg.transform="translate("+s.left+","+s.top+")";if(s.angle)svg.transform+=" rotate("+180*s.angle/Math.PI+")";svg.d=path;e=this.expect(e,"path",svg)}else{svg.cx=s.left;svg.cy=s.top;svg.r=radius;e=this.expect(e,"circle",svg)}e=this.append(e,scenes,i)}return e};pv.SvgScene.image=function(scenes){var e=scenes.$g.firstChild;for(var i=0;i<scenes.length;i++){var s=scenes[i];if(!s.visible)continue;e=this.fill(e,scenes,i);if(s.image){e=this.expect(e,"foreignObject",{cursor:s.cursor,x:s.left,y:s.top,width:s.width,height:s.height});var c=e.firstChild||e.appendChild(document.createElementNS(this.xhtml,"canvas"));c.$scene={scenes:scenes,index:i};c.style.width=s.width;c.style.height=s.height;c.width=s.imageWidth;c.height=s.imageHeight;c.getContext("2d").putImageData(s.image,0,0)}else{e=this.expect(e,"image",{preserveAspectRatio:"none",cursor:s.cursor,x:s.left,y:s.top,width:s.width,height:s.height});e.setAttributeNS(this.xlink,"href",s.url)}e=this.append(e,scenes,i);e=this.stroke(e,scenes,i)}return e};pv.SvgScene.label=function(scenes){var e=scenes.$g.firstChild;for(var i=0;i<scenes.length;i++){var s=scenes[i];if(!s.visible)continue;var fill=s.textStyle;if(!fill.opacity||!s.text)continue;var x=0,y=0,dy=0,anchor="start";switch(s.textBaseline){case"middle":dy=".35em";break;case"top":dy=".71em";y=s.textMargin;break;case"bottom":y="-"+s.textMargin;break}switch(s.textAlign){case"right":anchor="end";x="-"+s.textMargin;break;case"center":anchor="middle";break;case"left":x=s.textMargin;break}e=this.expect(e,"text",{"pointer-events":s.events,cursor:s.cursor,x:x,y:y,dy:dy,transform:"translate("+s.left+","+s.top+")"+(s.textAngle?" rotate("+180*s.textAngle/Math.PI+")":"")+(this.scale!=1?" scale("+1/this.scale+")":""),fill:fill.color,"fill-opacity":fill.opacity||null,"text-anchor":anchor},{font:s.font,"text-shadow":s.textShadow,"text-decoration":s.textDecoration});if(e.firstChild)e.firstChild.nodeValue=s.text;else e.appendChild(document.createTextNode(s.text));e=this.append(e,scenes,i)}return e};pv.SvgScene.line=function(scenes){var e=scenes.$g.firstChild;if(scenes.length<2)return e;var s=scenes[0];if(s.segmented)return this.lineSegment(scenes);if(!s.visible)return e;var fill=s.fillStyle,stroke=s.strokeStyle;if(!fill.opacity&&!stroke.opacity)return e;var d="M"+s.left+","+s.top;if(scenes.length>2&&(s.interpolate=="basis"||s.interpolate=="cardinal"||s.interpolate=="monotone")){switch(s.interpolate){case"basis":d+=this.curveBasis(scenes);break;case"cardinal":d+=this.curveCardinal(scenes,s.tension);break;case"monotone":d+=this.curveMonotone(scenes);break}}else{for(var i=1;i<scenes.length;i++){d+=this.pathSegment(scenes[i-1],scenes[i])}}e=this.expect(e,"path",{"shape-rendering":s.antialias?null:"crispEdges","pointer-events":s.events,cursor:s.cursor,d:d,fill:fill.color,"fill-opacity":fill.opacity||null,stroke:stroke.color,"stroke-opacity":stroke.opacity||null,"stroke-width":stroke.opacity?s.lineWidth/this.scale:null,"stroke-linejoin":s.lineJoin});return this.append(e,scenes,0)};pv.SvgScene.lineSegment=function(scenes){var e=scenes.$g.firstChild;var s=scenes[0];var paths;switch(s.interpolate){case"basis":paths=this.curveBasisSegments(scenes);break;case"cardinal":paths=this.curveCardinalSegments(scenes,s.tension);break;case"monotone":paths=this.curveMonotoneSegments(scenes);break}for(var i=0,n=scenes.length-1;i<n;i++){var s1=scenes[i],s2=scenes[i+1];if(!s1.visible||!s2.visible)continue;var stroke=s1.strokeStyle,fill=pv.Color.transparent;if(!stroke.opacity)continue;var d;if(s1.interpolate=="linear"&&s1.lineJoin=="miter"){fill=stroke;stroke=pv.Color.transparent;d=this.pathJoin(scenes[i-1],s1,s2,scenes[i+2])}else if(paths){d=paths[i]}else{d="M"+s1.left+","+s1.top+this.pathSegment(s1,s2)}e=this.expect(e,"path",{"shape-rendering":s1.antialias?null:"crispEdges","pointer-events":s1.events,cursor:s1.cursor,d:d,fill:fill.color,"fill-opacity":fill.opacity||null,stroke:stroke.color,"stroke-opacity":stroke.opacity||null,"stroke-width":stroke.opacity?s1.lineWidth/this.scale:null,"stroke-linejoin":s1.lineJoin});e=this.append(e,scenes,i)}return e};pv.SvgScene.pathSegment=function(s1,s2){var l=1;switch(s1.interpolate){case"polar-reverse":l=0;case"polar":{var dx=s2.left-s1.left,dy=s2.top-s1.top,e=1-s1.eccentricity,r=Math.sqrt(dx*dx+dy*dy)/(2*e);if(e<=0||e>1)break;return"A"+r+","+r+" 0 0,"+l+" "+s2.left+","+s2.top}case"step-before":return"V"+s2.top+"H"+s2.left;case"step-after":return"H"+s2.left+"V"+s2.top}return"L"+s2.left+","+s2.top};pv.SvgScene.lineIntersect=function(o1,d1,o2,d2){return o1.plus(d1.times(o2.minus(o1).dot(d2.perp())/d1.dot(d2.perp())))};pv.SvgScene.pathJoin=function(s0,s1,s2,s3){var p1=pv.vector(s1.left,s1.top),p2=pv.vector(s2.left,s2.top),p=p2.minus(p1),v=p.perp().norm(),w=v.times(s1.lineWidth/(2*this.scale)),a=p1.plus(w),b=p2.plus(w),c=p2.minus(w),d=p1.minus(w);if(s0&&s0.visible){var v1=p1.minus(s0.left,s0.top).perp().norm().plus(v);d=this.lineIntersect(p1,v1,d,p);a=this.lineIntersect(p1,v1,a,p)}if(s3&&s3.visible){var v2=pv.vector(s3.left,s3.top).minus(p2).perp().norm().plus(v);c=this.lineIntersect(p2,v2,c,p);b=this.lineIntersect(p2,v2,b,p)}return"M"+a.x+","+a.y+"L"+b.x+","+b.y+" "+c.x+","+c.y+" "+d.x+","+d.y};pv.SvgScene.panel=function(scenes){var g=scenes.$g,e=g&&g.firstChild;for(var i=0;i<scenes.length;i++){var s=scenes[i];if(!s.visible)continue;if(!scenes.parent){s.canvas.style.display="inline-block";if(g&&g.parentNode!=s.canvas){g=s.canvas.firstChild;e=g&&g.firstChild}if(!g){g=s.canvas.appendChild(this.create("svg"));g.setAttribute("font-size","10px");g.setAttribute("font-family","sans-serif");g.setAttribute("fill","none");g.setAttribute("stroke","none");g.setAttribute("stroke-width",1.5);for(var j=0;j<this.events.length;j++){g.addEventListener(this.events[j],this.dispatch,false)}e=g.firstChild}scenes.$g=g;g.setAttribute("width",s.width+s.left+s.right);g.setAttribute("height",s.height+s.top+s.bottom)}if(s.overflow=="hidden"){var id=pv.id().toString(36),c=this.expect(e,"g",{"clip-path":"url(#"+id+")"});if(!c.parentNode)g.appendChild(c);scenes.$g=g=c;e=c.firstChild;e=this.expect(e,"clipPath",{id:id});var r=e.firstChild||e.appendChild(this.create("rect"));r.setAttribute("x",s.left);r.setAttribute("y",s.top);r.setAttribute("width",s.width);r.setAttribute("height",s.height);if(!e.parentNode)g.appendChild(e);e=e.nextSibling}e=this.fill(e,scenes,i);var k=this.scale,t=s.transform,x=s.left+t.x,y=s.top+t.y;this.scale*=t.k;for(var j=0;j<s.children.length;j++){s.children[j].$g=e=this.expect(e,"g",{transform:"translate("+x+","+y+")"+(t.k!=1?" scale("+t.k+")":"")});this.updateAll(s.children[j]);if(!e.parentNode)g.appendChild(e);e=e.nextSibling}this.scale=k;e=this.stroke(e,scenes,i);if(s.overflow=="hidden"){scenes.$g=g=c.parentNode;e=c.nextSibling}}return e};pv.SvgScene.fill=function(e,scenes,i){var s=scenes[i],fill=s.fillStyle;if(fill.opacity||s.events=="all"){e=this.expect(e,"rect",{"shape-rendering":s.antialias?null:"crispEdges","pointer-events":s.events,cursor:s.cursor,x:s.left,y:s.top,width:s.width,height:s.height,fill:fill.color,"fill-opacity":fill.opacity,stroke:null});e=this.append(e,scenes,i)}return e};pv.SvgScene.stroke=function(e,scenes,i){var s=scenes[i],stroke=s.strokeStyle;if(stroke.opacity||s.events=="all"){e=this.expect(e,"rect",{"shape-rendering":s.antialias?null:"crispEdges","pointer-events":s.events=="all"?"stroke":s.events,cursor:s.cursor,x:s.left,y:s.top,width:Math.max(1e-10,s.width),height:Math.max(1e-10,s.height),fill:null,stroke:stroke.color,"stroke-opacity":stroke.opacity,"stroke-width":s.lineWidth/this.scale});e=this.append(e,scenes,i)}return e};pv.SvgScene.rule=function(scenes){var e=scenes.$g.firstChild;for(var i=0;i<scenes.length;i++){var s=scenes[i];if(!s.visible)continue;var stroke=s.strokeStyle;if(!stroke.opacity)continue;e=this.expect(e,"line",{"shape-rendering":s.antialias?null:"crispEdges","pointer-events":s.events,cursor:s.cursor,x1:s.left,y1:s.top,x2:s.left+s.width,y2:s.top+s.height,stroke:stroke.color,"stroke-opacity":stroke.opacity,"stroke-width":s.lineWidth/this.scale});e=this.append(e,scenes,i)}return e};pv.SvgScene.wedge=function(scenes){var e=scenes.$g.firstChild;for(var i=0;i<scenes.length;i++){var s=scenes[i];if(!s.visible)continue;var fill=s.fillStyle,stroke=s.strokeStyle;if(!fill.opacity&&!stroke.opacity)continue;var r1=s.innerRadius,r2=s.outerRadius,a=Math.abs(s.angle),p;if(a>=2*Math.PI){if(r1){p="M0,"+r2+"A"+r2+","+r2+" 0 1,1 0,"+-r2+"A"+r2+","+r2+" 0 1,1 0,"+r2+"M0,"+r1+"A"+r1+","+r1+" 0 1,1 0,"+-r1+"A"+r1+","+r1+" 0 1,1 0,"+r1+"Z"}else{p="M0,"+r2+"A"+r2+","+r2+" 0 1,1 0,"+-r2+"A"+r2+","+r2+" 0 1,1 0,"+r2+"Z"}}else{var sa=Math.min(s.startAngle,s.endAngle),ea=Math.max(s.startAngle,s.endAngle),c1=Math.cos(sa),c2=Math.cos(ea),s1=Math.sin(sa),s2=Math.sin(ea);if(r1){p="M"+r2*c1+","+r2*s1+"A"+r2+","+r2+" 0 "+(a<Math.PI?"0":"1")+",1 "+r2*c2+","+r2*s2+"L"+r1*c2+","+r1*s2+"A"+r1+","+r1+" 0 "+(a<Math.PI?"0":"1")+",0 "+r1*c1+","+r1*s1+"Z"}else{p="M"+r2*c1+","+r2*s1+"A"+r2+","+r2+" 0 "+(a<Math.PI?"0":"1")+",1 "+r2*c2+","+r2*s2+"L0,0Z"}}e=this.expect(e,"path",{"shape-rendering":s.antialias?null:"crispEdges","pointer-events":s.events,cursor:s.cursor,transform:"translate("+s.left+","+s.top+")",d:p,fill:fill.color,"fill-rule":"evenodd","fill-opacity":fill.opacity||null,stroke:stroke.color,"stroke-opacity":stroke.opacity||null,"stroke-width":stroke.opacity?s.lineWidth/this.scale:null});e=this.append(e,scenes,i)}return e};pv.Mark=function(){this.$properties=[];this.$handlers={}};pv.Mark.prototype.properties={};pv.Mark.cast={};pv.Mark.prototype.property=function(name,cast){if(!this.hasOwnProperty("properties")){this.properties=pv.extend(this.properties)}this.properties[name]=true;pv.Mark.prototype.propertyMethod(name,false,pv.Mark.cast[name]=cast);return this};pv.Mark.prototype.propertyMethod=function(name,def,cast){if(!cast)cast=pv.Mark.cast[name];this[name]=function(v){if(def&&this.scene){var defs=this.scene.defs;if(arguments.length){defs[name]={id:v==null?0:pv.id(),value:v!=null&&cast?cast(v):v};return this}return defs[name]?defs[name].value:null}if(arguments.length){var type=!def<<1|typeof v=="function";this.propertyValue(name,type&1&&cast?function(){var x=v.apply(this,arguments);return x!=null?cast(x):null}:v!=null&&cast?cast(v):v).type=type;return this}return this.instance()[name]}};pv.Mark.prototype.propertyValue=function(name,v){var properties=this.$properties,p={name:name,id:pv.id(),value:v};for(var i=0;i<properties.length;i++){if(properties[i].name==name){properties.splice(i,1);break}}properties.push(p);return p};pv.Mark.prototype.property("data").property("visible",Boolean).property("left",Number).property("right",Number).property("top",Number).property("bottom",Number).property("cursor",String).property("title",String).property("reverse",Boolean).property("antialias",Boolean).property("events",String);pv.Mark.prototype.childIndex=-1;pv.Mark.prototype.index=-1;pv.Mark.prototype.scale=1;pv.Mark.prototype.defaults=(new pv.Mark).data(function(d){return[d]}).visible(true).antialias(true).events("painted");pv.Mark.prototype.extend=function(proto){this.proto=proto;this.target=proto.target;return this};pv.Mark.prototype.add=function(type){return this.parent.add(type).extend(this)};pv.Mark.prototype.def=function(name,v){this.propertyMethod(name,true);return this[name](arguments.length>1?v:null)};pv.Mark.prototype.anchor=function(name){if(!name)name="center";return new pv.Anchor(this).name(name).data(function(){return this.scene.target.map(function(s){return s.data})}).visible(function(){return this.scene.target[this.index].visible}).left(function(){var s=this.scene.target[this.index],w=s.width||0;switch(this.name()){case"bottom":case"top":case"center":return s.left+w/2;case"left":return null}return s.left+w}).top(function(){var s=this.scene.target[this.index],h=s.height||0;switch(this.name()){case"left":case"right":case"center":return s.top+h/2;case"top":return null}return s.top+h}).right(function(){var s=this.scene.target[this.index];return this.name()=="left"?s.right+(s.width||0):null}).bottom(function(){var s=this.scene.target[this.index];return this.name()=="top"?s.bottom+(s.height||0):null}).textAlign(function(){switch(this.name()){case"bottom":case"top":case"center":return"center";case"right":return"right"}return"left"}).textBaseline(function(){switch(this.name()){case"right":case"left":case"center":return"middle";case"top":return"top"}return"bottom"})};pv.Mark.prototype.anchorTarget=function(){return this.target};pv.Mark.prototype.margin=function(n){return this.left(n).right(n).top(n).bottom(n)};pv.Mark.prototype.instance=function(defaultIndex){var scene=this.scene||this.parent.instance(-1).children[this.childIndex],index=!arguments.length||this.hasOwnProperty("index")?this.index:defaultIndex;return scene[index<0?scene.length-1:index]};pv.Mark.prototype.instances=function(source){var mark=this,index=[],scene;while(!(scene=mark.scene)){source=source.parent;index.push({index:source.index,childIndex:mark.childIndex});mark=mark.parent}while(index.length){var i=index.pop();scene=scene[i.index].children[i.childIndex]}if(this.hasOwnProperty("index")){var s=pv.extend(scene[this.index]);s.right=s.top=s.left=s.bottom=0;return[s]}return scene};pv.Mark.prototype.first=function(){return this.scene[0]};pv.Mark.prototype.last=function(){return this.scene[this.scene.length-1]};pv.Mark.prototype.sibling=function(){return this.index==0?null:this.scene[this.index-1]};pv.Mark.prototype.cousin=function(){var p=this.parent,s=p&&p.sibling();return s&&s.children?s.children[this.childIndex][this.index]:null};pv.Mark.prototype.render=function(){var parent=this.parent,stack=pv.Mark.stack;if(parent&&!this.root.scene){this.root.render();return}var indexes=[];for(var mark=this;mark.parent;mark=mark.parent){indexes.unshift(mark.childIndex)
}function render(mark,depth,scale){mark.scale=scale;if(depth<indexes.length){stack.unshift(null);if(mark.hasOwnProperty("index")){renderInstance(mark,depth,scale)}else{for(var i=0,n=mark.scene.length;i<n;i++){mark.index=i;renderInstance(mark,depth,scale)}delete mark.index}stack.shift()}else{mark.build();pv.Scene.scale=scale;pv.Scene.updateAll(mark.scene)}delete mark.scale}function renderInstance(mark,depth,scale){var s=mark.scene[mark.index],i;if(s.visible){var childIndex=indexes[depth],child=mark.children[childIndex];for(i=0;i<childIndex;i++){mark.children[i].scene=s.children[i]}stack[0]=s.data;if(child.scene){render(child,depth+1,scale*s.transform.k)}else{child.scene=s.children[childIndex];render(child,depth+1,scale*s.transform.k);delete child.scene}for(i=0;i<childIndex;i++){delete mark.children[i].scene}}}this.bind();while(parent&&!parent.hasOwnProperty("index"))parent=parent.parent;this.context(parent?parent.scene:undefined,parent?parent.index:-1,function(){render(this.root,0,1)})};pv.Mark.stack=[];pv.Mark.prototype.bind=function(){var seen={},types=[[],[],[],[]],data,visible;function bind(mark){do{var properties=mark.$properties;for(var i=properties.length-1;i>=0;i--){var p=properties[i];if(!(p.name in seen)){seen[p.name]=p;switch(p.name){case"data":data=p;break;case"visible":visible=p;break;default:types[p.type].push(p);break}}}}while(mark=mark.proto)}bind(this);bind(this.defaults);types[1].reverse();types[3].reverse();var mark=this;do for(var name in mark.properties){if(!(name in seen)){types[2].push(seen[name]={name:name,type:2,value:null})}}while(mark=mark.proto);var defs=types[0].concat(types[1]);for(var i=0;i<defs.length;i++){this.propertyMethod(defs[i].name,true)}this.binds={properties:seen,data:data,defs:defs,required:[visible],optional:pv.blend(types)}};pv.Mark.prototype.build=function(){var scene=this.scene,stack=pv.Mark.stack;if(!scene){scene=this.scene=[];scene.mark=this;scene.type=this.type;scene.childIndex=this.childIndex;if(this.parent){scene.parent=this.parent.scene;scene.parentIndex=this.parent.index}}if(this.target)scene.target=this.target.instances(scene);if(this.binds.defs.length){var defs=scene.defs;if(!defs)scene.defs=defs={};for(var i=0;i<this.binds.defs.length;i++){var p=this.binds.defs[i],d=defs[p.name];if(!d||p.id>d.id){defs[p.name]={id:0,value:p.type&1?p.value.apply(this,stack):p.value}}}}var data=this.binds.data;data=data.type&1?data.value.apply(this,stack):data.value;stack.unshift(null);scene.length=data.length;for(var i=0;i<data.length;i++){pv.Mark.prototype.index=this.index=i;var s=scene[i];if(!s)scene[i]=s={};s.data=stack[0]=data[i];this.buildInstance(s)}pv.Mark.prototype.index=-1;delete this.index;stack.shift();return this};pv.Mark.prototype.buildProperties=function(s,properties){for(var i=0,n=properties.length;i<n;i++){var p=properties[i],v=p.value;switch(p.type){case 0:case 1:v=this.scene.defs[p.name].value;break;case 3:v=v.apply(this,pv.Mark.stack);break}s[p.name]=v}};pv.Mark.prototype.buildInstance=function(s){this.buildProperties(s,this.binds.required);if(s.visible){this.buildProperties(s,this.binds.optional);this.buildImplied(s)}};pv.Mark.prototype.buildImplied=function(s){var l=s.left;var r=s.right;var t=s.top;var b=s.bottom;var p=this.properties;var w=p.width?s.width:0;var h=p.height?s.height:0;var width=this.parent?this.parent.width():w+l+r;if(w==null){w=width-(r=r||0)-(l=l||0)}else if(r==null){if(l==null){l=r=(width-w)/2}else{r=width-w-(l=l||0)}}else if(l==null){l=width-w-r}var height=this.parent?this.parent.height():h+t+b;if(h==null){h=height-(t=t||0)-(b=b||0)}else if(b==null){if(t==null){b=t=(height-h)/2}else{b=height-h-(t=t||0)}}else if(t==null){t=height-h-b}s.left=l;s.right=r;s.top=t;s.bottom=b;if(p.width)s.width=w;if(p.height)s.height=h;if(p.textStyle&&!s.textStyle)s.textStyle=pv.Color.transparent;if(p.fillStyle&&!s.fillStyle)s.fillStyle=pv.Color.transparent;if(p.strokeStyle&&!s.strokeStyle)s.strokeStyle=pv.Color.transparent};pv.Mark.prototype.mouse=function(){var x=pv.event.pageX||0,y=pv.event.pageY||0,n=this.root.canvas();do{x-=n.offsetLeft;y-=n.offsetTop}while(n=n.offsetParent);var t=pv.Transform.identity,p=this.properties.transform?this:this.parent,pz=[];do{pz.push(p)}while(p=p.parent);while(p=pz.pop())t=t.translate(p.left(),p.top()).times(p.transform());t=t.invert();return pv.vector(x*t.k+t.x,y*t.k+t.y)};pv.Mark.prototype.event=function(type,handler){this.$handlers[type]=pv.functor(handler);return this};pv.Mark.prototype.context=function(scene,index,f){var proto=pv.Mark.prototype,stack=pv.Mark.stack,oscene=pv.Mark.scene,oindex=proto.index;function apply(scene,index){pv.Mark.scene=scene;proto.index=index;if(!scene)return;var that=scene.mark,mark=that,ancestors=[];do{ancestors.push(mark);stack.push(scene[index].data);mark.index=index;mark.scene=scene;index=scene.parentIndex;scene=scene.parent}while(mark=mark.parent);for(var i=ancestors.length-1,k=1;i>0;i--){mark=ancestors[i];mark.scale=k;k*=mark.scene[mark.index].transform.k}if(that.children)for(var i=0,n=that.children.length;i<n;i++){mark=that.children[i];mark.scene=that.scene[that.index].children[i];mark.scale=k}}function clear(scene,index){if(!scene)return;var that=scene.mark,mark;if(that.children)for(var i=0,n=that.children.length;i<n;i++){mark=that.children[i];delete mark.scene;delete mark.scale}mark=that;do{stack.pop();if(mark.parent){delete mark.scene;delete mark.scale}delete mark.index}while(mark=mark.parent)}clear(oscene,oindex);apply(scene,index);try{f.apply(this,stack)}finally{clear(scene,index);apply(oscene,oindex)}};pv.Mark.dispatch=function(type,scene,index){var m=scene.mark,p=scene.parent,l=m.$handlers[type];if(!l)return p&&pv.Mark.dispatch(type,p,scene.parentIndex);m.context(scene,index,function(){m=l.apply(m,pv.Mark.stack);if(m&&m.render)m.render()});return true};pv.Anchor=function(target){pv.Mark.call(this);this.target=target;this.parent=target.parent};pv.Anchor.prototype=pv.extend(pv.Mark).property("name",String);pv.Anchor.prototype.extend=function(proto){this.proto=proto;return this};pv.Area=function(){pv.Mark.call(this)};pv.Area.prototype=pv.extend(pv.Mark).property("width",Number).property("height",Number).property("lineWidth",Number).property("strokeStyle",pv.color).property("fillStyle",pv.color).property("segmented",Boolean).property("interpolate",String).property("tension",Number);pv.Area.prototype.type="area";pv.Area.prototype.defaults=(new pv.Area).extend(pv.Mark.prototype.defaults).lineWidth(1.5).fillStyle(pv.Colors.category20().by(pv.parent)).interpolate("linear").tension(.7);pv.Area.prototype.buildImplied=function(s){if(s.height==null)s.height=0;if(s.width==null)s.width=0;pv.Mark.prototype.buildImplied.call(this,s)};pv.Area.fixed={lineWidth:1,lineJoin:1,strokeStyle:1,fillStyle:1,segmented:1,interpolate:1,tension:1};pv.Area.prototype.bind=function(){pv.Mark.prototype.bind.call(this);var binds=this.binds,required=binds.required,optional=binds.optional;for(var i=0,n=optional.length;i<n;i++){var p=optional[i];p.fixed=p.name in pv.Area.fixed;if(p.name=="segmented"){required.push(p);optional.splice(i,1);i--;n--}}this.binds.$required=required;this.binds.$optional=optional};pv.Area.prototype.buildInstance=function(s){var binds=this.binds;if(this.index){var fixed=binds.fixed;if(!fixed){fixed=binds.fixed=[];function f(p){return!p.fixed||(fixed.push(p),false)}binds.required=binds.required.filter(f);if(!this.scene[0].segmented)binds.optional=binds.optional.filter(f)}for(var i=0,n=fixed.length;i<n;i++){var p=fixed[i].name;s[p]=this.scene[0][p]}}else{binds.required=binds.$required;binds.optional=binds.$optional;binds.fixed=null}pv.Mark.prototype.buildInstance.call(this,s)};pv.Area.prototype.anchor=function(name){return pv.Mark.prototype.anchor.call(this,name).interpolate(function(){return this.scene.target[this.index].interpolate}).eccentricity(function(){return this.scene.target[this.index].eccentricity}).tension(function(){return this.scene.target[this.index].tension})};pv.Bar=function(){pv.Mark.call(this)};pv.Bar.prototype=pv.extend(pv.Mark).property("width",Number).property("height",Number).property("lineWidth",Number).property("strokeStyle",pv.color).property("fillStyle",pv.color);pv.Bar.prototype.type="bar";pv.Bar.prototype.defaults=(new pv.Bar).extend(pv.Mark.prototype.defaults).lineWidth(1.5).fillStyle(pv.Colors.category20().by(pv.parent));pv.Dot=function(){pv.Mark.call(this)};pv.Dot.prototype=pv.extend(pv.Mark).property("size",Number).property("radius",Number).property("shape",String).property("angle",Number).property("lineWidth",Number).property("strokeStyle",pv.color).property("fillStyle",pv.color);pv.Dot.prototype.type="dot";pv.Dot.prototype.defaults=(new pv.Dot).extend(pv.Mark.prototype.defaults).size(20).shape("circle").lineWidth(1.5).strokeStyle(pv.Colors.category10().by(pv.parent));pv.Dot.prototype.anchor=function(name){return pv.Mark.prototype.anchor.call(this,name).left(function(){var s=this.scene.target[this.index];switch(this.name()){case"bottom":case"top":case"center":return s.left;case"left":return null}return s.left+s.radius}).right(function(){var s=this.scene.target[this.index];return this.name()=="left"?s.right+s.radius:null}).top(function(){var s=this.scene.target[this.index];switch(this.name()){case"left":case"right":case"center":return s.top;case"top":return null}return s.top+s.radius}).bottom(function(){var s=this.scene.target[this.index];return this.name()=="top"?s.bottom+s.radius:null}).textAlign(function(){switch(this.name()){case"left":return"right";case"bottom":case"top":case"center":return"center"}return"left"}).textBaseline(function(){switch(this.name()){case"right":case"left":case"center":return"middle";case"bottom":return"top"}return"bottom"})};pv.Dot.prototype.buildImplied=function(s){if(s.radius==null)s.radius=Math.sqrt(s.size);else if(s.size==null)s.size=s.radius*s.radius;pv.Mark.prototype.buildImplied.call(this,s)};pv.Label=function(){pv.Mark.call(this)};pv.Label.prototype=pv.extend(pv.Mark).property("text",String).property("font",String).property("textAngle",Number).property("textStyle",pv.color).property("textAlign",String).property("textBaseline",String).property("textMargin",Number).property("textDecoration",String).property("textShadow",String);pv.Label.prototype.type="label";pv.Label.prototype.defaults=(new pv.Label).extend(pv.Mark.prototype.defaults).events("none").text(pv.identity).font("10px sans-serif").textAngle(0).textStyle("black").textAlign("left").textBaseline("bottom").textMargin(3);pv.Line=function(){pv.Mark.call(this)};pv.Line.prototype=pv.extend(pv.Mark).property("lineWidth",Number).property("lineJoin",String).property("strokeStyle",pv.color).property("fillStyle",pv.color).property("segmented",Boolean).property("interpolate",String).property("eccentricity",Number).property("tension",Number);pv.Line.prototype.type="line";pv.Line.prototype.defaults=(new pv.Line).extend(pv.Mark.prototype.defaults).lineJoin("miter").lineWidth(1.5).strokeStyle(pv.Colors.category10().by(pv.parent)).interpolate("linear").eccentricity(0).tension(.7);pv.Line.prototype.bind=pv.Area.prototype.bind;pv.Line.prototype.buildInstance=pv.Area.prototype.buildInstance;pv.Line.prototype.anchor=function(name){return pv.Area.prototype.anchor.call(this,name).textAlign(function(d){switch(this.name()){case"left":return"right";case"bottom":case"top":case"center":return"center";case"right":return"left"}}).textBaseline(function(d){switch(this.name()){case"right":case"left":case"center":return"middle";case"top":return"bottom";case"bottom":return"top"}})};pv.Rule=function(){pv.Mark.call(this)};pv.Rule.prototype=pv.extend(pv.Mark).property("width",Number).property("height",Number).property("lineWidth",Number).property("strokeStyle",pv.color);pv.Rule.prototype.type="rule";pv.Rule.prototype.defaults=(new pv.Rule).extend(pv.Mark.prototype.defaults).lineWidth(1).strokeStyle("black").antialias(false);pv.Rule.prototype.anchor=pv.Line.prototype.anchor;pv.Rule.prototype.buildImplied=function(s){var l=s.left,r=s.right,t=s.top,b=s.bottom;if(s.width!=null||l==null&&r==null||r!=null&&l!=null){s.height=0}else{s.width=0}pv.Mark.prototype.buildImplied.call(this,s)};pv.Panel=function(){pv.Bar.call(this);this.children=[];this.root=this;this.$dom=pv.$&&pv.$.s};pv.Panel.prototype=pv.extend(pv.Bar).property("transform").property("overflow",String).property("canvas",function(c){return typeof c=="string"?document.getElementById(c):c});pv.Panel.prototype.type="panel";pv.Panel.prototype.defaults=(new pv.Panel).extend(pv.Bar.prototype.defaults).fillStyle(null).overflow("visible");pv.Panel.prototype.anchor=function(name){var anchor=pv.Bar.prototype.anchor.call(this,name);anchor.parent=this;return anchor};pv.Panel.prototype.add=function(type){var child=new type;child.parent=this;child.root=this.root;child.childIndex=this.children.length;this.children.push(child);return child};pv.Panel.prototype.bind=function(){pv.Mark.prototype.bind.call(this);for(var i=0;i<this.children.length;i++){this.children[i].bind()}};pv.Panel.prototype.buildInstance=function(s){pv.Bar.prototype.buildInstance.call(this,s);if(!s.visible)return;if(!s.children)s.children=[];var scale=this.scale*s.transform.k,child,n=this.children.length;pv.Mark.prototype.index=-1;for(var i=0;i<n;i++){child=this.children[i];child.scene=s.children[i];child.scale=scale;child.build()}for(var i=0;i<n;i++){child=this.children[i];s.children[i]=child.scene;delete child.scene;delete child.scale}s.children.length=n};pv.Panel.prototype.buildImplied=function(s){if(!this.parent){var c=s.canvas;if(c){if(c.$panel!=this){c.$panel=this;while(c.lastChild)c.removeChild(c.lastChild)}var w,h;if(s.width==null){w=parseFloat(pv.css(c,"width"));s.width=w-s.left-s.right}if(s.height==null){h=parseFloat(pv.css(c,"height"));s.height=h-s.top-s.bottom}}else{var cache=this.$canvas||(this.$canvas=[]);if(!(c=cache[this.index])){c=cache[this.index]=document.createElement("span");if(this.$dom){this.$dom.parentNode.insertBefore(c,this.$dom)}else{var n=document.body;while(n.lastChild&&n.lastChild.tagName)n=n.lastChild;if(n!=document.body)n=n.parentNode;n.appendChild(c)}}}s.canvas=c}if(!s.transform)s.transform=pv.Transform.identity;pv.Mark.prototype.buildImplied.call(this,s)};pv.Image=function(){pv.Bar.call(this)};pv.Image.prototype=pv.extend(pv.Bar).property("url",String).property("imageWidth",Number).property("imageHeight",Number);pv.Image.prototype.type="image";pv.Image.prototype.defaults=(new pv.Image).extend(pv.Bar.prototype.defaults).fillStyle(null);pv.Image.prototype.image=function(f){this.$image=function(){var c=f.apply(this,arguments);return c==null?pv.Color.transparent:typeof c=="string"?pv.color(c):c};return this};pv.Image.prototype.bind=function(){pv.Bar.prototype.bind.call(this);var binds=this.binds,mark=this;do{binds.image=mark.$image}while(!binds.image&&(mark=mark.proto))};pv.Image.prototype.buildImplied=function(s){pv.Bar.prototype.buildImplied.call(this,s);if(!s.visible)return;if(s.imageWidth==null)s.imageWidth=s.width;if(s.imageHeight==null)s.imageHeight=s.height;if(s.url==null&&this.binds.image){var canvas=this.$canvas||(this.$canvas=document.createElement("canvas")),context=canvas.getContext("2d"),w=s.imageWidth,h=s.imageHeight,stack=pv.Mark.stack,data;canvas.width=w;canvas.height=h;data=(s.image=context.createImageData(w,h)).data;stack.unshift(null,null);for(var y=0,p=0;y<h;y++){stack[1]=y;for(var x=0;x<w;x++){stack[0]=x;var color=this.binds.image.apply(this,stack);data[p++]=color.r;data[p++]=color.g;data[p++]=color.b;data[p++]=255*color.a}}stack.splice(0,2)}};pv.Wedge=function(){pv.Mark.call(this)};pv.Wedge.prototype=pv.extend(pv.Mark).property("startAngle",Number).property("endAngle",Number).property("angle",Number).property("innerRadius",Number).property("outerRadius",Number).property("lineWidth",Number).property("strokeStyle",pv.color).property("fillStyle",pv.color);pv.Wedge.prototype.type="wedge";pv.Wedge.prototype.defaults=(new pv.Wedge).extend(pv.Mark.prototype.defaults).startAngle(function(){var s=this.sibling();return s?s.endAngle:-Math.PI/2}).innerRadius(0).lineWidth(1.5).strokeStyle(null).fillStyle(pv.Colors.category20().by(pv.index));pv.Wedge.prototype.midRadius=function(){return(this.innerRadius()+this.outerRadius())/2};pv.Wedge.prototype.midAngle=function(){return(this.startAngle()+this.endAngle())/2};pv.Wedge.prototype.anchor=function(name){function partial(s){return s.innerRadius||s.angle<2*Math.PI}function midRadius(s){return(s.innerRadius+s.outerRadius)/2}function midAngle(s){return(s.startAngle+s.endAngle)/2}return pv.Mark.prototype.anchor.call(this,name).left(function(){var s=this.scene.target[this.index];if(partial(s))switch(this.name()){case"outer":return s.left+s.outerRadius*Math.cos(midAngle(s));case"inner":return s.left+s.innerRadius*Math.cos(midAngle(s));case"start":return s.left+midRadius(s)*Math.cos(s.startAngle);case"center":return s.left+midRadius(s)*Math.cos(midAngle(s));case"end":return s.left+midRadius(s)*Math.cos(s.endAngle)}return s.left}).top(function(){var s=this.scene.target[this.index];if(partial(s))switch(this.name()){case"outer":return s.top+s.outerRadius*Math.sin(midAngle(s));case"inner":return s.top+s.innerRadius*Math.sin(midAngle(s));case"start":return s.top+midRadius(s)*Math.sin(s.startAngle);case"center":return s.top+midRadius(s)*Math.sin(midAngle(s));case"end":return s.top+midRadius(s)*Math.sin(s.endAngle)}return s.top}).textAlign(function(){var s=this.scene.target[this.index];if(partial(s))switch(this.name()){case"outer":return pv.Wedge.upright(midAngle(s))?"right":"left";case"inner":return pv.Wedge.upright(midAngle(s))?"left":"right"}return"center"}).textBaseline(function(){var s=this.scene.target[this.index];if(partial(s))switch(this.name()){case"start":return pv.Wedge.upright(s.startAngle)?"top":"bottom";case"end":return pv.Wedge.upright(s.endAngle)?"bottom":"top"}return"middle"}).textAngle(function(){var s=this.scene.target[this.index],a=0;if(partial(s))switch(this.name()){case"center":case"inner":case"outer":a=midAngle(s);break;case"start":a=s.startAngle;break;case"end":a=s.endAngle;break}return pv.Wedge.upright(a)?a:a+Math.PI})};pv.Wedge.upright=function(angle){angle=angle%(2*Math.PI);angle=angle<0?2*Math.PI+angle:angle;return angle<Math.PI/2||angle>=3*Math.PI/2};pv.Wedge.prototype.buildImplied=function(s){if(s.angle==null)s.angle=s.endAngle-s.startAngle;else if(s.endAngle==null)s.endAngle=s.startAngle+s.angle;pv.Mark.prototype.buildImplied.call(this,s)};pv.simulation=function(particles){return new pv.Simulation(particles)};pv.Simulation=function(particles){for(var i=0;i<particles.length;i++)this.particle(particles[i])};pv.Simulation.prototype.particle=function(p){p.next=this.particles;if(isNaN(p.px))p.px=p.x;if(isNaN(p.py))p.py=p.y;if(isNaN(p.fx))p.fx=0;if(isNaN(p.fy))p.fy=0;this.particles=p;return this};pv.Simulation.prototype.force=function(f){f.next=this.forces;this.forces=f;return this};pv.Simulation.prototype.constraint=function(c){c.next=this.constraints;this.constraints=c;return this};pv.Simulation.prototype.stabilize=function(n){var c;if(!arguments.length)n=3;for(var i=0;i<n;i++){var q=new pv.Quadtree(this.particles);for(c=this.constraints;c;c=c.next)c.apply(this.particles,q)}for(var p=this.particles;p;p=p.next){p.px=p.x;p.py=p.y}return this};pv.Simulation.prototype.step=function(){var p,f,c;for(p=this.particles;p;p=p.next){var px=p.px,py=p.py;p.px=p.x;p.py=p.y;p.x+=p.vx=p.x-px+p.fx;p.y+=p.vy=p.y-py+p.fy}var q=new pv.Quadtree(this.particles);for(c=this.constraints;c;c=c.next)c.apply(this.particles,q);for(p=this.particles;p;p=p.next)p.fx=p.fy=0;for(f=this.forces;f;f=f.next)f.apply(this.particles,q)};pv.Quadtree=function(particles){var p;var x1=Number.POSITIVE_INFINITY,y1=x1,x2=Number.NEGATIVE_INFINITY,y2=x2;for(p=particles;p;p=p.next){if(p.x<x1)x1=p.x;if(p.y<y1)y1=p.y;if(p.x>x2)x2=p.x;if(p.y>y2)y2=p.y}var dx=x2-x1,dy=y2-y1;if(dx>dy)y2=y1+dx;else x2=x1+dy;this.xMin=x1;this.yMin=y1;this.xMax=x2;this.yMax=y2;function insert(n,p,x1,y1,x2,y2){if(isNaN(p.x)||isNaN(p.y))return;if(n.leaf){if(n.p){if(Math.abs(n.p.x-p.x)+Math.abs(n.p.y-p.y)<.01){insertChild(n,p,x1,y1,x2,y2)}else{var v=n.p;n.p=null;insertChild(n,v,x1,y1,x2,y2);insertChild(n,p,x1,y1,x2,y2)}}else{n.p=p}}else{insertChild(n,p,x1,y1,x2,y2)}}function insertChild(n,p,x1,y1,x2,y2){var sx=(x1+x2)*.5,sy=(y1+y2)*.5,right=p.x>=sx,bottom=p.y>=sy;n.leaf=false;switch((bottom<<1)+right){case 0:n=n.c1||(n.c1=new pv.Quadtree.Node);break;case 1:n=n.c2||(n.c2=new pv.Quadtree.Node);break;case 2:n=n.c3||(n.c3=new pv.Quadtree.Node);break;case 3:n=n.c4||(n.c4=new pv.Quadtree.Node);break}if(right)x1=sx;else x2=sx;if(bottom)y1=sy;else y2=sy;insert(n,p,x1,y1,x2,y2)}this.root=new pv.Quadtree.Node;for(p=particles;p;p=p.next)insert(this.root,p,x1,y1,x2,y2)};pv.Quadtree.Node=function(){this.leaf=true;this.c1=null;this.c2=null;this.c3=null;this.c4=null;this.p=null};pv.Force={};pv.Force.charge=function(k){var min=2,min1=1/min,max=500,max1=1/max,theta=.9,force={};if(!arguments.length)k=-40;force.constant=function(x){if(arguments.length){k=Number(x);return force}return k};force.domain=function(a,b){if(arguments.length){min=Number(a);min1=1/min;max=Number(b);max1=1/max;return force}return[min,max]};force.theta=function(x){if(arguments.length){theta=Number(x);return force}return theta};function accumulate(n){var cx=0,cy=0;n.cn=0;function accumulateChild(c){accumulate(c);n.cn+=c.cn;cx+=c.cn*c.cx;cy+=c.cn*c.cy}if(!n.leaf){if(n.c1)accumulateChild(n.c1);if(n.c2)accumulateChild(n.c2);if(n.c3)accumulateChild(n.c3);if(n.c4)accumulateChild(n.c4)}if(n.p){n.cn+=k;cx+=k*n.p.x;cy+=k*n.p.y}n.cx=cx/n.cn;n.cy=cy/n.cn}function forces(n,p,x1,y1,x2,y2){var dx=n.cx-p.x,dy=n.cy-p.y,dn=1/Math.sqrt(dx*dx+dy*dy);if(n.leaf&&n.p!=p||(x2-x1)*dn<theta){if(dn<max1)return;if(dn>min1)dn=min1;var kc=n.cn*dn*dn*dn,fx=dx*kc,fy=dy*kc;p.fx+=fx;p.fy+=fy}else if(!n.leaf){var sx=(x1+x2)*.5,sy=(y1+y2)*.5;if(n.c1)forces(n.c1,p,x1,y1,sx,sy);if(n.c2)forces(n.c2,p,sx,y1,x2,sy);if(n.c3)forces(n.c3,p,x1,sy,sx,y2);if(n.c4)forces(n.c4,p,sx,sy,x2,y2);if(dn<max1)return;if(dn>min1)dn=min1;if(n.p&&n.p!=p){var kc=k*dn*dn*dn,fx=dx*kc,fy=dy*kc;p.fx+=fx;p.fy+=fy}}}force.apply=function(particles,q){accumulate(q.root);for(var p=particles;p;p=p.next){forces(q.root,p,q.xMin,q.yMin,q.xMax,q.yMax)}};return force};pv.Force.drag=function(k){var force={};if(!arguments.length)k=.1;force.constant=function(x){if(arguments.length){k=x;return force}return k};force.apply=function(particles){if(k)for(var p=particles;p;p=p.next){p.fx-=k*p.vx;p.fy-=k*p.vy}};return force};pv.Force.spring=function(k){var d=.1,l=20,links,kl,force={};if(!arguments.length)k=.1;force.links=function(x){if(arguments.length){links=x;kl=x.map(function(l){return 1/Math.sqrt(Math.max(l.sourceNode.linkDegree,l.targetNode.linkDegree))});return force}return links};force.constant=function(x){if(arguments.length){k=Number(x);return force}return k};force.damping=function(x){if(arguments.length){d=Number(x);return force}return d};force.length=function(x){if(arguments.length){l=Number(x);return force}return l};force.apply=function(particles){for(var i=0;i<links.length;i++){var a=links[i].sourceNode,b=links[i].targetNode,dx=a.x-b.x,dy=a.y-b.y,dn=Math.sqrt(dx*dx+dy*dy),dd=dn?1/dn:1,ks=k*kl[i],kd=d*kl[i],kk=(ks*(dn-l)+kd*(dx*(a.vx-b.vx)+dy*(a.vy-b.vy))*dd)*dd,fx=-kk*(dn?dx:.01*(.5-Math.random())),fy=-kk*(dn?dy:.01*(.5-Math.random()));a.fx+=fx;a.fy+=fy;b.fx-=fx;b.fy-=fy}};return force};pv.Constraint={};pv.Constraint.collision=function(radius){var n=1,r1,px1,py1,px2,py2,constraint={};if(!arguments.length)r1=10;constraint.repeat=function(x){if(arguments.length){n=Number(x);return constraint}return n};function constrain(n,p,x1,y1,x2,y2){if(!n.leaf){var sx=(x1+x2)*.5,sy=(y1+y2)*.5,top=sy>py1,bottom=sy<py2,left=sx>px1,right=sx<px2;if(top){if(n.c1&&left)constrain(n.c1,p,x1,y1,sx,sy);if(n.c2&&right)constrain(n.c2,p,sx,y1,x2,sy)}if(bottom){if(n.c3&&left)constrain(n.c3,p,x1,sy,sx,y2);if(n.c4&&right)constrain(n.c4,p,sx,sy,x2,y2)}}if(n.p&&n.p!=p){var dx=p.x-n.p.x,dy=p.y-n.p.y,l=Math.sqrt(dx*dx+dy*dy),d=r1+radius(n.p);if(l<d){var k=(l-d)/l*.5;dx*=k;dy*=k;p.x-=dx;p.y-=dy;n.p.x+=dx;n.p.y+=dy}}}constraint.apply=function(particles,q){var p,r,max=-Infinity;for(p=particles;p;p=p.next){r=radius(p);if(r>max)max=r}for(var i=0;i<n;i++){for(p=particles;p;p=p.next){r=(r1=radius(p))+max;px1=p.x-r;px2=p.x+r;py1=p.y-r;py2=p.y+r;constrain(q.root,p,q.xMin,q.yMin,q.xMax,q.yMax)}}};return constraint};pv.Constraint.position=function(f){var a=1,constraint={};if(!arguments.length)f=function(p){return p.fix};constraint.alpha=function(x){if(arguments.length){a=Number(x);return constraint}return a};constraint.apply=function(particles){for(var p=particles;p;p=p.next){var v=f(p);if(v){p.x+=(v.x-p.x)*a;p.y+=(v.y-p.y)*a;p.fx=p.fy=p.vx=p.vy=0}}};return constraint};pv.Constraint.bound=function(){var constraint={},x,y;constraint.x=function(min,max){if(arguments.length){x={min:Math.min(min,max),max:Math.max(min,max)};return this}return x};constraint.y=function(min,max){if(arguments.length){y={min:Math.min(min,max),max:Math.max(min,max)};return this}return y};constraint.apply=function(particles){if(x)for(var p=particles;p;p=p.next){p.x=p.x<x.min?x.min:p.x>x.max?x.max:p.x}if(y)for(var p=particles;p;p=p.next){p.y=p.y<y.min?y.min:p.y>y.max?y.max:p.y}};return constraint};pv.Layout=function(){pv.Panel.call(this)};pv.Layout.prototype=pv.extend(pv.Panel);pv.Layout.prototype.property=function(name,cast){if(!this.hasOwnProperty("properties")){this.properties=pv.extend(this.properties)}this.properties[name]=true;this.propertyMethod(name,false,pv.Mark.cast[name]=cast);return this};pv.Layout.Network=function(){pv.Layout.call(this);var that=this;this.$id=pv.id();(this.node=(new pv.Mark).data(function(){return that.nodes()}).strokeStyle("#1f77b4").fillStyle("#fff").left(function(n){return n.x}).top(function(n){return n.y})).parent=this;this.link=(new pv.Mark).extend(this.node).data(function(p){return[p.sourceNode,p.targetNode]}).fillStyle(null).lineWidth(function(d,p){return p.linkValue*1.5}).strokeStyle("rgba(0,0,0,.2)");this.link.add=function(type){return that.add(pv.Panel).data(function(){return that.links()}).add(type).extend(this)};(this.label=(new pv.Mark).extend(this.node).textMargin(7).textBaseline("middle").text(function(n){return n.nodeName||n.nodeValue}).textAngle(function(n){var a=n.midAngle;return pv.Wedge.upright(a)?a:a+Math.PI}).textAlign(function(n){return pv.Wedge.upright(n.midAngle)?"left":"right"})).parent=this};pv.Layout.Network.prototype=pv.extend(pv.Layout).property("nodes",function(v){return v.map(function(d,i){if(typeof d!="object")d={nodeValue:d};d.index=i;return d})}).property("links",function(v){return v.map(function(d){if(isNaN(d.linkValue))d.linkValue=isNaN(d.value)?1:d.value;return d})});pv.Layout.Network.prototype.reset=function(){this.$id=pv.id();return this};pv.Layout.Network.prototype.buildProperties=function(s,properties){if((s.$id||0)<this.$id){pv.Layout.prototype.buildProperties.call(this,s,properties)}};pv.Layout.Network.prototype.buildImplied=function(s){pv.Layout.prototype.buildImplied.call(this,s);if(s.$id>=this.$id)return true;s.$id=this.$id;s.nodes.forEach(function(d){d.linkDegree=0});s.links.forEach(function(d){var v=d.linkValue;(d.sourceNode||(d.sourceNode=s.nodes[d.source])).linkDegree+=v;(d.targetNode||(d.targetNode=s.nodes[d.target])).linkDegree+=v})};pv.Layout.Hierarchy=function(){pv.Layout.Network.call(this);this.link.strokeStyle("#ccc")};pv.Layout.Hierarchy.prototype=pv.extend(pv.Layout.Network);pv.Layout.Hierarchy.prototype.buildImplied=function(s){if(!s.links)s.links=pv.Layout.Hierarchy.links.call(this);pv.Layout.Network.prototype.buildImplied.call(this,s)};pv.Layout.Hierarchy.links=function(){return this.nodes().filter(function(n){return n.parentNode}).map(function(n){return{sourceNode:n,targetNode:n.parentNode,linkValue:1}})};pv.Layout.Hierarchy.NodeLink={buildImplied:function(s){var nodes=s.nodes,orient=s.orient,horizontal=/^(top|bottom)$/.test(orient),w=s.width,h=s.height;if(orient=="radial"){var ir=s.innerRadius,or=s.outerRadius;if(ir==null)ir=0;if(or==null)or=Math.min(w,h)/2}function radius(n){return n.parentNode?n.depth*(or-ir)+ir:0}function midAngle(n){return n.parentNode?(n.breadth-.25)*2*Math.PI:0}function x(n){switch(orient){case"left":return n.depth*w;case"right":return w-n.depth*w;case"top":return n.breadth*w;case"bottom":return w-n.breadth*w;case"radial":return w/2+radius(n)*Math.cos(n.midAngle)}}function y(n){switch(orient){case"left":return n.breadth*h;case"right":return h-n.breadth*h;case"top":return n.depth*h;case"bottom":return h-n.depth*h;case"radial":return h/2+radius(n)*Math.sin(n.midAngle)}}for(var i=0;i<nodes.length;i++){var n=nodes[i];n.midAngle=orient=="radial"?midAngle(n):horizontal?Math.PI/2:0;n.x=x(n);n.y=y(n);if(n.firstChild)n.midAngle+=Math.PI}}};pv.Layout.Hierarchy.Fill={constructor:function(){this.node.strokeStyle("#fff").fillStyle("#ccc").width(function(n){return n.dx}).height(function(n){return n.dy}).innerRadius(function(n){return n.innerRadius}).outerRadius(function(n){return n.outerRadius}).startAngle(function(n){return n.startAngle}).angle(function(n){return n.angle});this.label.textAlign("center").left(function(n){return n.x+n.dx/2}).top(function(n){return n.y+n.dy/2});delete this.link},buildImplied:function(s){var nodes=s.nodes,orient=s.orient,horizontal=/^(top|bottom)$/.test(orient),w=s.width,h=s.height,depth=-nodes[0].minDepth;if(orient=="radial"){var ir=s.innerRadius,or=s.outerRadius;if(ir==null)ir=0;if(ir)depth*=2;if(or==null)or=Math.min(w,h)/2}function scale(d,depth){return(d+depth)/(1+depth)}function x(n){switch(orient){case"left":return scale(n.minDepth,depth)*w;case"right":return(1-scale(n.maxDepth,depth))*w;case"top":return n.minBreadth*w;case"bottom":return(1-n.maxBreadth)*w;case"radial":return w/2}}function y(n){switch(orient){case"left":return n.minBreadth*h;case"right":return(1-n.maxBreadth)*h;case"top":return scale(n.minDepth,depth)*h;case"bottom":return(1-scale(n.maxDepth,depth))*h;case"radial":return h/2}}function dx(n){switch(orient){case"left":case"right":return(n.maxDepth-n.minDepth)/(1+depth)*w;case"top":case"bottom":return(n.maxBreadth-n.minBreadth)*w;case"radial":return n.parentNode?(n.innerRadius+n.outerRadius)*Math.cos(n.midAngle):0}}function dy(n){switch(orient){case"left":case"right":return(n.maxBreadth-n.minBreadth)*h;case"top":case"bottom":return(n.maxDepth-n.minDepth)/(1+depth)*h;case"radial":return n.parentNode?(n.innerRadius+n.outerRadius)*Math.sin(n.midAngle):0}}function innerRadius(n){return Math.max(0,scale(n.minDepth,depth/2))*(or-ir)+ir}function outerRadius(n){return scale(n.maxDepth,depth/2)*(or-ir)+ir}function startAngle(n){return(n.parentNode?n.minBreadth-.25:0)*2*Math.PI}function angle(n){return(n.parentNode?n.maxBreadth-n.minBreadth:1)*2*Math.PI}for(var i=0;i<nodes.length;i++){var n=nodes[i];n.x=x(n);n.y=y(n);if(orient=="radial"){n.innerRadius=innerRadius(n);n.outerRadius=outerRadius(n);n.startAngle=startAngle(n);n.angle=angle(n);n.midAngle=n.startAngle+n.angle/2}else{n.midAngle=horizontal?-Math.PI/2:0}n.dx=dx(n);n.dy=dy(n)}}};pv.Layout.Grid=function(){pv.Layout.call(this);var that=this;(this.cell=(new pv.Mark).data(function(){return that.scene[that.index].$grid}).width(function(){return that.width()/that.cols()}).height(function(){return that.height()/that.rows()}).left(function(){return this.width()*(this.index%that.cols())}).top(function(){return this.height()*Math.floor(this.index/that.cols())})).parent=this};pv.Layout.Grid.prototype=pv.extend(pv.Layout).property("rows").property("cols");pv.Layout.Grid.prototype.defaults=(new pv.Layout.Grid).extend(pv.Layout.prototype.defaults).rows(1).cols(1);pv.Layout.Grid.prototype.buildImplied=function(s){pv.Layout.prototype.buildImplied.call(this,s);var r=s.rows,c=s.cols;if(typeof c=="object")r=pv.transpose(c);if(typeof r=="object"){s.$grid=pv.blend(r);s.rows=r.length;s.cols=r[0]?r[0].length:0}else{s.$grid=pv.repeat([s.data],r*c)}};pv.Layout.Stack=function(){pv.Layout.call(this);var that=this,none=function(){return null},prop={t:none,l:none,r:none,b:none,w:none,h:none},values,buildImplied=that.buildImplied;
function proxy(name){return function(){return prop[name](this.parent.index,this.index)}}this.buildImplied=function(s){buildImplied.call(this,s);var data=s.layers,n=data.length,m,orient=s.orient,horizontal=/^(top|bottom)\b/.test(orient),h=this.parent[horizontal?"height":"width"](),x=[],y=[],dy=[];var stack=pv.Mark.stack,o={parent:{parent:this}};stack.unshift(null);values=[];for(var i=0;i<n;i++){dy[i]=[];y[i]=[];o.parent.index=i;stack[0]=data[i];values[i]=this.$values.apply(o.parent,stack);if(!i)m=values[i].length;stack.unshift(null);for(var j=0;j<m;j++){stack[0]=values[i][j];o.index=j;if(!i)x[j]=this.$x.apply(o,stack);dy[i][j]=this.$y.apply(o,stack)}stack.shift()}stack.shift();var index;switch(s.order){case"inside-out":{var max=dy.map(function(v){return pv.max.index(v)}),map=pv.range(n).sort(function(a,b){return max[a]-max[b]}),sums=dy.map(function(v){return pv.sum(v)}),top=0,bottom=0,tops=[],bottoms=[];for(var i=0;i<n;i++){var j=map[i];if(top<bottom){top+=sums[j];tops.push(j)}else{bottom+=sums[j];bottoms.push(j)}}index=bottoms.reverse().concat(tops);break}case"reverse":index=pv.range(n-1,-1,-1);break;default:index=pv.range(n);break}switch(s.offset){case"silohouette":{for(var j=0;j<m;j++){var o=0;for(var i=0;i<n;i++)o+=dy[i][j];y[index[0]][j]=(h-o)/2}break}case"wiggle":{var o=0;for(var i=0;i<n;i++)o+=dy[i][0];y[index[0]][0]=o=(h-o)/2;for(var j=1;j<m;j++){var s1=0,s2=0,dx=x[j]-x[j-1];for(var i=0;i<n;i++)s1+=dy[i][j];for(var i=0;i<n;i++){var s3=(dy[index[i]][j]-dy[index[i]][j-1])/(2*dx);for(var k=0;k<i;k++){s3+=(dy[index[k]][j]-dy[index[k]][j-1])/dx}s2+=s3*dy[index[i]][j]}y[index[0]][j]=o-=s1?s2/s1*dx:0}break}case"expand":{for(var j=0;j<m;j++){y[index[0]][j]=0;var k=0;for(var i=0;i<n;i++)k+=dy[i][j];if(k){k=h/k;for(var i=0;i<n;i++)dy[i][j]*=k}else{k=h/n;for(var i=0;i<n;i++)dy[i][j]=k}}break}default:{for(var j=0;j<m;j++)y[index[0]][j]=0;break}}for(var j=0;j<m;j++){var o=y[index[0]][j];for(var i=1;i<n;i++){o+=dy[index[i-1]][j];y[index[i]][j]=o}}var i=orient.indexOf("-"),pdy=horizontal?"h":"w",px=i<0?horizontal?"l":"b":orient.charAt(i+1),py=orient.charAt(0);for(var p in prop)prop[p]=none;prop[px]=function(i,j){return x[j]};prop[py]=function(i,j){return y[i][j]};prop[pdy]=function(i,j){return dy[i][j]}};this.layer=(new pv.Mark).data(function(){return values[this.parent.index]}).top(proxy("t")).left(proxy("l")).right(proxy("r")).bottom(proxy("b")).width(proxy("w")).height(proxy("h"));this.layer.add=function(type){return that.add(pv.Panel).data(function(){return that.layers()}).add(type).extend(this)}};pv.Layout.Stack.prototype=pv.extend(pv.Layout).property("orient",String).property("offset",String).property("order",String).property("layers");pv.Layout.Stack.prototype.defaults=(new pv.Layout.Stack).extend(pv.Layout.prototype.defaults).orient("bottom-left").offset("zero").layers([[]]);pv.Layout.Stack.prototype.$x=pv.Layout.Stack.prototype.$y=function(){return 0};pv.Layout.Stack.prototype.x=function(f){this.$x=pv.functor(f);return this};pv.Layout.Stack.prototype.y=function(f){this.$y=pv.functor(f);return this};pv.Layout.Stack.prototype.$values=pv.identity;pv.Layout.Stack.prototype.values=function(f){this.$values=pv.functor(f);return this};pv.Layout.Treemap=function(){pv.Layout.Hierarchy.call(this);this.node.strokeStyle("#fff").fillStyle("rgba(31, 119, 180, .25)").width(function(n){return n.dx}).height(function(n){return n.dy});this.label.visible(function(n){return!n.firstChild}).left(function(n){return n.x+n.dx/2}).top(function(n){return n.y+n.dy/2}).textAlign("center").textAngle(function(n){return n.dx>n.dy?0:-Math.PI/2});(this.leaf=(new pv.Mark).extend(this.node).fillStyle(null).strokeStyle(null).visible(function(n){return!n.firstChild})).parent=this;delete this.link};pv.Layout.Treemap.prototype=pv.extend(pv.Layout.Hierarchy).property("round",Boolean).property("paddingLeft",Number).property("paddingRight",Number).property("paddingTop",Number).property("paddingBottom",Number).property("mode",String).property("order",String);pv.Layout.Treemap.prototype.defaults=(new pv.Layout.Treemap).extend(pv.Layout.Hierarchy.prototype.defaults).mode("squarify").order("ascending");pv.Layout.Treemap.prototype.padding=function(n){return this.paddingLeft(n).paddingRight(n).paddingTop(n).paddingBottom(n)};pv.Layout.Treemap.prototype.$size=function(d){return Number(d.nodeValue)};pv.Layout.Treemap.prototype.size=function(f){this.$size=pv.functor(f);return this};pv.Layout.Treemap.prototype.buildImplied=function(s){if(pv.Layout.Hierarchy.prototype.buildImplied.call(this,s))return;var that=this,nodes=s.nodes,root=nodes[0],stack=pv.Mark.stack,left=s.paddingLeft,right=s.paddingRight,top=s.paddingTop,bottom=s.paddingBottom,size=function(n){return n.size},round=s.round?Math.round:Number,mode=s.mode;function slice(row,sum,horizontal,x,y,w,h){for(var i=0,d=0;i<row.length;i++){var n=row[i];if(horizontal){n.x=x+d;n.y=y;d+=n.dx=round(w*n.size/sum);n.dy=h}else{n.x=x;n.y=y+d;n.dx=w;d+=n.dy=round(h*n.size/sum)}}if(n){if(horizontal){n.dx+=w-d}else{n.dy+=h-d}}}function ratio(row,l){var rmax=-Infinity,rmin=Infinity,s=0;for(var i=0;i<row.length;i++){var r=row[i].size;if(r<rmin)rmin=r;if(r>rmax)rmax=r;s+=r}s=s*s;l=l*l;return Math.max(l*rmax/s,s/(l*rmin))}function layout(n,i){var x=n.x+left,y=n.y+top,w=n.dx-left-right,h=n.dy-top-bottom;if(mode!="squarify"){slice(n.childNodes,n.size,mode=="slice"?true:mode=="dice"?false:i&1,x,y,w,h);return}var row=[],mink=Infinity,l=Math.min(w,h),k=w*h/n.size;if(n.size<=0)return;n.visitBefore(function(n){n.size*=k});function position(row){var horizontal=w==l,sum=pv.sum(row,size),r=l?round(sum/l):0;slice(row,sum,horizontal,x,y,horizontal?w:r,horizontal?r:h);if(horizontal){y+=r;h-=r}else{x+=r;w-=r}l=Math.min(w,h);return horizontal}var children=n.childNodes.slice();while(children.length){var child=children[children.length-1];if(!child.size){children.pop();continue}row.push(child);var k=ratio(row,l);if(k<=mink){children.pop();mink=k}else{row.pop();position(row);row.length=0;mink=Infinity}}if(position(row))for(var i=0;i<row.length;i++){row[i].dy+=h}else for(var i=0;i<row.length;i++){row[i].dx+=w}}stack.unshift(null);root.visitAfter(function(n,i){n.depth=i;n.x=n.y=n.dx=n.dy=0;n.size=n.firstChild?pv.sum(n.childNodes,function(n){return n.size}):that.$size.apply(that,(stack[0]=n,stack))});stack.shift();switch(s.order){case"ascending":{root.sort(function(a,b){return a.size-b.size});break}case"descending":{root.sort(function(a,b){return b.size-a.size});break}case"reverse":root.reverse();break}root.x=0;root.y=0;root.dx=s.width;root.dy=s.height;root.visitBefore(layout)};pv.Layout.Tree=function(){pv.Layout.Hierarchy.call(this)};pv.Layout.Tree.prototype=pv.extend(pv.Layout.Hierarchy).property("group",Number).property("breadth",Number).property("depth",Number).property("orient",String);pv.Layout.Tree.prototype.defaults=(new pv.Layout.Tree).extend(pv.Layout.Hierarchy.prototype.defaults).group(1).breadth(15).depth(60).orient("top");pv.Layout.Tree.prototype.buildImplied=function(s){if(pv.Layout.Hierarchy.prototype.buildImplied.call(this,s))return;var nodes=s.nodes,orient=s.orient,depth=s.depth,breadth=s.breadth,group=s.group,w=s.width,h=s.height;function firstWalk(v){var l,r,a;if(!v.firstChild){if(l=v.previousSibling){v.prelim=l.prelim+distance(v.depth,true)}}else{l=v.firstChild;r=v.lastChild;a=l;for(var c=l;c;c=c.nextSibling){firstWalk(c);a=apportion(c,a)}executeShifts(v);var midpoint=.5*(l.prelim+r.prelim);if(l=v.previousSibling){v.prelim=l.prelim+distance(v.depth,true);v.mod=v.prelim-midpoint}else{v.prelim=midpoint}}}function secondWalk(v,m,depth){v.breadth=v.prelim+m;m+=v.mod;for(var c=v.firstChild;c;c=c.nextSibling){secondWalk(c,m,depth)}}function apportion(v,a){var w=v.previousSibling;if(w){var vip=v,vop=v,vim=w,vom=v.parentNode.firstChild,sip=vip.mod,sop=vop.mod,sim=vim.mod,som=vom.mod,nr=nextRight(vim),nl=nextLeft(vip);while(nr&&nl){vim=nr;vip=nl;vom=nextLeft(vom);vop=nextRight(vop);vop.ancestor=v;var shift=vim.prelim+sim-(vip.prelim+sip)+distance(vim.depth,false);if(shift>0){moveSubtree(ancestor(vim,v,a),v,shift);sip+=shift;sop+=shift}sim+=vim.mod;sip+=vip.mod;som+=vom.mod;sop+=vop.mod;nr=nextRight(vim);nl=nextLeft(vip)}if(nr&&!nextRight(vop)){vop.thread=nr;vop.mod+=sim-sop}if(nl&&!nextLeft(vom)){vom.thread=nl;vom.mod+=sip-som;a=v}}return a}function nextLeft(v){return v.firstChild||v.thread}function nextRight(v){return v.lastChild||v.thread}function moveSubtree(wm,wp,shift){var subtrees=wp.number-wm.number;wp.change-=shift/subtrees;wp.shift+=shift;wm.change+=shift/subtrees;wp.prelim+=shift;wp.mod+=shift}function executeShifts(v){var shift=0,change=0;for(var c=v.lastChild;c;c=c.previousSibling){c.prelim+=shift;c.mod+=shift;change+=c.change;shift+=c.shift+change}}function ancestor(vim,v,a){return vim.ancestor.parentNode==v.parentNode?vim.ancestor:a}function distance(depth,siblings){return(siblings?1:group+1)/(orient=="radial"?depth:1)}var root=nodes[0];root.visitAfter(function(v,i){v.ancestor=v;v.prelim=0;v.mod=0;v.change=0;v.shift=0;v.number=v.previousSibling?v.previousSibling.number+1:0;v.depth=i});firstWalk(root);secondWalk(root,-root.prelim,0);function midAngle(n){return orient=="radial"?n.breadth/depth:0}function x(n){switch(orient){case"left":return n.depth;case"right":return w-n.depth;case"top":case"bottom":return n.breadth+w/2;case"radial":return w/2+n.depth*Math.cos(midAngle(n))}}function y(n){switch(orient){case"left":case"right":return n.breadth+h/2;case"top":return n.depth;case"bottom":return h-n.depth;case"radial":return h/2+n.depth*Math.sin(midAngle(n))}}root.visitAfter(function(v){v.breadth*=breadth;v.depth*=depth;v.midAngle=midAngle(v);v.x=x(v);v.y=y(v);if(v.firstChild)v.midAngle+=Math.PI;delete v.breadth;delete v.depth;delete v.ancestor;delete v.prelim;delete v.mod;delete v.change;delete v.shift;delete v.number;delete v.thread})};pv.Layout.Indent=function(){pv.Layout.Hierarchy.call(this);this.link.interpolate("step-after")};pv.Layout.Indent.prototype=pv.extend(pv.Layout.Hierarchy).property("depth",Number).property("breadth",Number);pv.Layout.Indent.prototype.defaults=(new pv.Layout.Indent).extend(pv.Layout.Hierarchy.prototype.defaults).depth(15).breadth(15);pv.Layout.Indent.prototype.buildImplied=function(s){if(pv.Layout.Hierarchy.prototype.buildImplied.call(this,s))return;var nodes=s.nodes,bspace=s.breadth,dspace=s.depth,ax=0,ay=0;function position(n,breadth,depth){n.x=ax+depth++*dspace;n.y=ay+breadth++*bspace;n.midAngle=0;for(var c=n.firstChild;c;c=c.nextSibling){breadth=position(c,breadth,depth)}return breadth}position(nodes[0],1,1)};pv.Layout.Pack=function(){pv.Layout.Hierarchy.call(this);this.node.radius(function(n){return n.radius}).strokeStyle("rgb(31, 119, 180)").fillStyle("rgba(31, 119, 180, .25)");this.label.textAlign("center");delete this.link};pv.Layout.Pack.prototype=pv.extend(pv.Layout.Hierarchy).property("spacing",Number).property("order",String);pv.Layout.Pack.prototype.defaults=(new pv.Layout.Pack).extend(pv.Layout.Hierarchy.prototype.defaults).spacing(1).order("ascending");pv.Layout.Pack.prototype.$radius=function(){return 1};pv.Layout.Pack.prototype.size=function(f){this.$radius=typeof f=="function"?function(){return Math.sqrt(f.apply(this,arguments))}:(f=Math.sqrt(f),function(){return f});return this};pv.Layout.Pack.prototype.buildImplied=function(s){if(pv.Layout.Hierarchy.prototype.buildImplied.call(this,s))return;var that=this,nodes=s.nodes,root=nodes[0];function radii(nodes){var stack=pv.Mark.stack;stack.unshift(null);for(var i=0,n=nodes.length;i<n;i++){var c=nodes[i];if(!c.firstChild){c.radius=that.$radius.apply(that,(stack[0]=c,stack))}}stack.shift()}function packTree(n){var nodes=[];for(var c=n.firstChild;c;c=c.nextSibling){if(c.firstChild)c.radius=packTree(c);c.n=c.p=c;nodes.push(c)}switch(s.order){case"ascending":{nodes.sort(function(a,b){return a.radius-b.radius});break}case"descending":{nodes.sort(function(a,b){return b.radius-a.radius});break}case"reverse":nodes.reverse();break}return packCircle(nodes)}function packCircle(nodes){var xMin=Infinity,xMax=-Infinity,yMin=Infinity,yMax=-Infinity,a,b,c,j,k;function bound(n){xMin=Math.min(n.x-n.radius,xMin);xMax=Math.max(n.x+n.radius,xMax);yMin=Math.min(n.y-n.radius,yMin);yMax=Math.max(n.y+n.radius,yMax)}function insert(a,b){var c=a.n;a.n=b;b.p=a;b.n=c;c.p=b}function splice(a,b){a.n=b;b.p=a}function intersects(a,b){var dx=b.x-a.x,dy=b.y-a.y,dr=a.radius+b.radius;return dr*dr-dx*dx-dy*dy>.001}a=nodes[0];a.x=-a.radius;a.y=0;bound(a);if(nodes.length>1){b=nodes[1];b.x=b.radius;b.y=0;bound(b);if(nodes.length>2){c=nodes[2];place(a,b,c);bound(c);insert(a,c);a.p=c;insert(c,b);b=a.n;for(var i=3;i<nodes.length;i++){place(a,b,c=nodes[i]);var isect=0,s1=1,s2=1;for(j=b.n;j!=b;j=j.n,s1++){if(intersects(j,c)){isect=1;break}}if(isect==1){for(k=a.p;k!=j.p;k=k.p,s2++){if(intersects(k,c)){if(s2<s1){isect=-1;j=k}break}}}if(isect==0){insert(a,c);b=c;bound(c)}else if(isect>0){splice(a,j);b=j;i--}else if(isect<0){splice(j,b);a=j;i--}}}}var cx=(xMin+xMax)/2,cy=(yMin+yMax)/2,cr=0;for(var i=0;i<nodes.length;i++){var n=nodes[i];n.x-=cx;n.y-=cy;cr=Math.max(cr,n.radius+Math.sqrt(n.x*n.x+n.y*n.y))}return cr+s.spacing}function place(a,b,c){var da=b.radius+c.radius,db=a.radius+c.radius,dx=b.x-a.x,dy=b.y-a.y,dc=Math.sqrt(dx*dx+dy*dy),cos=(db*db+dc*dc-da*da)/(2*db*dc),theta=Math.acos(cos),x=cos*db,h=Math.sin(theta)*db;dx/=dc;dy/=dc;c.x=a.x+x*dx+h*dy;c.y=a.y+x*dy-h*dx}function transform(n,x,y,k){for(var c=n.firstChild;c;c=c.nextSibling){c.x+=n.x;c.y+=n.y;transform(c,x,y,k)}n.x=x+k*n.x;n.y=y+k*n.y;n.radius*=k}radii(nodes);root.x=0;root.y=0;root.radius=packTree(root);var w=this.width(),h=this.height(),k=1/Math.max(2*root.radius/w,2*root.radius/h);transform(root,w/2,h/2,k)};pv.Layout.Force=function(){pv.Layout.Network.call(this);this.link.lineWidth(function(d,p){return Math.sqrt(p.linkValue)*1.5});this.label.textAlign("center")};pv.Layout.Force.prototype=pv.extend(pv.Layout.Network).property("bound",Boolean).property("iterations",Number).property("dragConstant",Number).property("chargeConstant",Number).property("chargeMinDistance",Number).property("chargeMaxDistance",Number).property("chargeTheta",Number).property("springConstant",Number).property("springDamping",Number).property("springLength",Number);pv.Layout.Force.prototype.defaults=(new pv.Layout.Force).extend(pv.Layout.Network.prototype.defaults).dragConstant(.1).chargeConstant(-40).chargeMinDistance(2).chargeMaxDistance(500).chargeTheta(.9).springConstant(.1).springDamping(.3).springLength(20);pv.Layout.Force.prototype.buildImplied=function(s){if(pv.Layout.Network.prototype.buildImplied.call(this,s)){var f=s.$force;if(f){f.next=this.binds.$force;this.binds.$force=f}return}var that=this,nodes=s.nodes,links=s.links,k=s.iterations,w=s.width,h=s.height;for(var i=0,n;i<nodes.length;i++){n=nodes[i];if(isNaN(n.x))n.x=w/2+40*Math.random()-20;if(isNaN(n.y))n.y=h/2+40*Math.random()-20}var sim=pv.simulation(nodes);sim.force(pv.Force.drag(s.dragConstant));sim.force(pv.Force.charge(s.chargeConstant).domain(s.chargeMinDistance,s.chargeMaxDistance).theta(s.chargeTheta));sim.force(pv.Force.spring(s.springConstant).damping(s.springDamping).length(s.springLength).links(links));sim.constraint(pv.Constraint.position());if(s.bound){sim.constraint(pv.Constraint.bound().x(6,w-6).y(6,h-6))}function speed(n){return n.fix?1:n.vx*n.vx+n.vy*n.vy}if(k==null){sim.step();sim.step();var force=s.$force=this.binds.$force={next:this.binds.$force,nodes:nodes,min:1e-4*(links.length+1),sim:sim};if(!this.$timer)this.$timer=setInterval(function(){var render=false;for(var f=that.binds.$force;f;f=f.next){if(pv.max(f.nodes,speed)>f.min){f.sim.step();render=true}}if(render)that.render()},42)}else for(var i=0;i<k;i++){sim.step()}};pv.Layout.Cluster=function(){pv.Layout.Hierarchy.call(this);var interpolate,buildImplied=this.buildImplied;this.buildImplied=function(s){buildImplied.call(this,s);interpolate=/^(top|bottom)$/.test(s.orient)?"step-before":/^(left|right)$/.test(s.orient)?"step-after":"linear"};this.link.interpolate(function(){return interpolate})};pv.Layout.Cluster.prototype=pv.extend(pv.Layout.Hierarchy).property("group",Number).property("orient",String).property("innerRadius",Number).property("outerRadius",Number);pv.Layout.Cluster.prototype.defaults=(new pv.Layout.Cluster).extend(pv.Layout.Hierarchy.prototype.defaults).group(0).orient("top");pv.Layout.Cluster.prototype.buildImplied=function(s){if(pv.Layout.Hierarchy.prototype.buildImplied.call(this,s))return;var root=s.nodes[0],group=s.group,breadth,depth,leafCount=0,leafIndex=.5-group/2;var p=undefined;root.visitAfter(function(n){if(n.firstChild){n.depth=1+pv.max(n.childNodes,function(n){return n.depth})}else{if(group&&p!=n.parentNode){p=n.parentNode;leafCount+=group}leafCount++;n.depth=0}});breadth=1/leafCount;depth=1/root.depth;var p=undefined;root.visitAfter(function(n){if(n.firstChild){n.breadth=pv.mean(n.childNodes,function(n){return n.breadth})}else{if(group&&p!=n.parentNode){p=n.parentNode;leafIndex+=group}n.breadth=breadth*leafIndex++}n.depth=1-n.depth*depth});root.visitAfter(function(n){n.minBreadth=n.firstChild?n.firstChild.minBreadth:n.breadth-breadth/2;n.maxBreadth=n.firstChild?n.lastChild.maxBreadth:n.breadth+breadth/2});root.visitBefore(function(n){n.minDepth=n.parentNode?n.parentNode.maxDepth:0;n.maxDepth=n.parentNode?n.depth+root.depth:n.minDepth+2*root.depth});root.minDepth=-depth;pv.Layout.Hierarchy.NodeLink.buildImplied.call(this,s)};pv.Layout.Cluster.Fill=function(){pv.Layout.Cluster.call(this);pv.Layout.Hierarchy.Fill.constructor.call(this)};pv.Layout.Cluster.Fill.prototype=pv.extend(pv.Layout.Cluster);pv.Layout.Cluster.Fill.prototype.buildImplied=function(s){if(pv.Layout.Cluster.prototype.buildImplied.call(this,s))return;pv.Layout.Hierarchy.Fill.buildImplied.call(this,s)};pv.Layout.Partition=function(){pv.Layout.Hierarchy.call(this)};pv.Layout.Partition.prototype=pv.extend(pv.Layout.Hierarchy).property("order",String).property("orient",String).property("innerRadius",Number).property("outerRadius",Number);pv.Layout.Partition.prototype.defaults=(new pv.Layout.Partition).extend(pv.Layout.Hierarchy.prototype.defaults).orient("top");pv.Layout.Partition.prototype.$size=function(){return 1};pv.Layout.Partition.prototype.size=function(f){this.$size=f;return this};pv.Layout.Partition.prototype.buildImplied=function(s){if(pv.Layout.Hierarchy.prototype.buildImplied.call(this,s))return;var that=this,root=s.nodes[0],stack=pv.Mark.stack,maxDepth=0;stack.unshift(null);root.visitAfter(function(n,i){if(i>maxDepth)maxDepth=i;n.size=n.firstChild?pv.sum(n.childNodes,function(n){return n.size}):that.$size.apply(that,(stack[0]=n,stack))});stack.shift();switch(s.order){case"ascending":root.sort(function(a,b){return a.size-b.size});break;case"descending":root.sort(function(b,a){return a.size-b.size});break}var ds=1/maxDepth;root.minBreadth=0;root.breadth=.5;root.maxBreadth=1;root.visitBefore(function(n){var b=n.minBreadth,s=n.maxBreadth-b;for(var c=n.firstChild;c;c=c.nextSibling){c.minBreadth=b;c.maxBreadth=b+=c.size/n.size*s;c.breadth=(b+c.minBreadth)/2}});root.visitAfter(function(n,i){n.minDepth=(i-1)*ds;n.maxDepth=n.depth=i*ds});pv.Layout.Hierarchy.NodeLink.buildImplied.call(this,s)};pv.Layout.Partition.Fill=function(){pv.Layout.Partition.call(this);pv.Layout.Hierarchy.Fill.constructor.call(this)};pv.Layout.Partition.Fill.prototype=pv.extend(pv.Layout.Partition);pv.Layout.Partition.Fill.prototype.buildImplied=function(s){if(pv.Layout.Partition.prototype.buildImplied.call(this,s))return;pv.Layout.Hierarchy.Fill.buildImplied.call(this,s)};pv.Layout.Arc=function(){pv.Layout.Network.call(this);var interpolate,directed,reverse,buildImplied=this.buildImplied;this.buildImplied=function(s){buildImplied.call(this,s);directed=s.directed;interpolate=s.orient=="radial"?"linear":"polar";reverse=s.orient=="right"||s.orient=="top"};this.link.data(function(p){var s=p.sourceNode,t=p.targetNode;return reverse!=(directed||s.breadth<t.breadth)?[s,t]:[t,s]}).interpolate(function(){return interpolate})};pv.Layout.Arc.prototype=pv.extend(pv.Layout.Network).property("orient",String).property("directed",Boolean);pv.Layout.Arc.prototype.defaults=(new pv.Layout.Arc).extend(pv.Layout.Network.prototype.defaults).orient("bottom");pv.Layout.Arc.prototype.sort=function(f){this.$sort=f;return this};pv.Layout.Arc.prototype.buildImplied=function(s){if(pv.Layout.Network.prototype.buildImplied.call(this,s))return;var nodes=s.nodes,orient=s.orient,sort=this.$sort,index=pv.range(nodes.length),w=s.width,h=s.height,r=Math.min(w,h)/2;if(sort)index.sort(function(a,b){return sort(nodes[a],nodes[b])});function midAngle(b){switch(orient){case"top":return-Math.PI/2;case"bottom":return Math.PI/2;case"left":return Math.PI;case"right":return 0;case"radial":return(b-.25)*2*Math.PI}}function x(b){switch(orient){case"top":case"bottom":return b*w;case"left":return 0;case"right":return w;case"radial":return w/2+r*Math.cos(midAngle(b))}}function y(b){switch(orient){case"top":return 0;case"bottom":return h;case"left":case"right":return b*h;case"radial":return h/2+r*Math.sin(midAngle(b))}}for(var i=0;i<nodes.length;i++){var n=nodes[index[i]],b=n.breadth=(i+.5)/nodes.length;n.x=x(b);n.y=y(b);n.midAngle=midAngle(b)}};pv.Layout.Horizon=function(){pv.Layout.call(this);var that=this,bands,mode,size,fill,red,blue,buildImplied=this.buildImplied;this.buildImplied=function(s){buildImplied.call(this,s);bands=s.bands;mode=s.mode;size=Math.round((mode=="color"?.5:1)*s.height);fill=s.backgroundStyle;red=pv.ramp(fill,s.negativeStyle).domain(0,bands);blue=pv.ramp(fill,s.positiveStyle).domain(0,bands)};var bands=(new pv.Panel).data(function(){return pv.range(bands*2)}).overflow("hidden").height(function(){return size}).top(function(i){return mode=="color"?(i&1)*size:0}).fillStyle(function(i){return i?null:fill});this.band=(new pv.Mark).top(function(d,i){return mode=="mirror"&&i&1?(i+1>>1)*size:null}).bottom(function(d,i){return mode=="mirror"?i&1?null:(i+1>>1)*-size:(i&1||-1)*(i+1>>1)*size}).fillStyle(function(d,i){return(i&1?red:blue)((i>>1)+1)});this.band.add=function(type){return that.add(pv.Panel).extend(bands).add(type).extend(this)}};pv.Layout.Horizon.prototype=pv.extend(pv.Layout).property("bands",Number).property("mode",String).property("backgroundStyle",pv.color).property("positiveStyle",pv.color).property("negativeStyle",pv.color);pv.Layout.Horizon.prototype.defaults=(new pv.Layout.Horizon).extend(pv.Layout.prototype.defaults).bands(2).mode("offset").backgroundStyle("white").positiveStyle("#1f77b4").negativeStyle("#d62728");pv.Layout.Rollup=function(){pv.Layout.Network.call(this);var that=this,nodes,links,buildImplied=that.buildImplied;this.buildImplied=function(s){buildImplied.call(this,s);nodes=s.$rollup.nodes;links=s.$rollup.links};this.node.data(function(){return nodes}).size(function(d){return d.nodes.length*20});this.link.interpolate("polar").eccentricity(.8);this.link.add=function(type){return that.add(pv.Panel).data(function(){return links}).add(type).extend(this)}};pv.Layout.Rollup.prototype=pv.extend(pv.Layout.Network).property("directed",Boolean);pv.Layout.Rollup.prototype.x=function(f){this.$x=pv.functor(f);return this};pv.Layout.Rollup.prototype.y=function(f){this.$y=pv.functor(f);return this};pv.Layout.Rollup.prototype.buildImplied=function(s){if(pv.Layout.Network.prototype.buildImplied.call(this,s))return;var nodes=s.nodes,links=s.links,directed=s.directed,n=nodes.length,x=[],y=[],rnindex=0,rnodes={},rlinks={};function id(i){return x[i]+","+y[i]}var stack=pv.Mark.stack,o={parent:this};stack.unshift(null);for(var i=0;i<n;i++){o.index=i;stack[0]=nodes[i];x[i]=this.$x.apply(o,stack);y[i]=this.$y.apply(o,stack)}stack.shift();for(var i=0;i<nodes.length;i++){var nodeId=id(i),rn=rnodes[nodeId];if(!rn){rn=rnodes[nodeId]=pv.extend(nodes[i]);rn.index=rnindex++;rn.x=x[i];rn.y=y[i];rn.nodes=[]}rn.nodes.push(nodes[i])}for(var i=0;i<links.length;i++){var source=links[i].sourceNode,target=links[i].targetNode,rsource=rnodes[id(source.index)],rtarget=rnodes[id(target.index)],reverse=!directed&&rsource.index>rtarget.index,linkId=reverse?rtarget.index+","+rsource.index:rsource.index+","+rtarget.index,rl=rlinks[linkId];if(!rl){rl=rlinks[linkId]={sourceNode:rsource,targetNode:rtarget,linkValue:0,links:[]}}rl.links.push(links[i]);rl.linkValue+=links[i].linkValue}s.$rollup={nodes:pv.values(rnodes),links:pv.values(rlinks)}};pv.Layout.Matrix=function(){pv.Layout.Network.call(this);var that=this,n,dx,dy,labels,pairs,buildImplied=that.buildImplied;this.buildImplied=function(s){buildImplied.call(this,s);n=s.nodes.length;dx=s.width/n;dy=s.height/n;labels=s.$matrix.labels;pairs=s.$matrix.pairs};this.link.data(function(){return pairs}).left(function(){return dx*(this.index%n)}).top(function(){return dy*Math.floor(this.index/n)}).width(function(){return dx}).height(function(){return dy}).lineWidth(1.5).strokeStyle("#fff").fillStyle(function(l){return l.linkValue?"#555":"#eee"}).parent=this;delete this.link.add;this.label.data(function(){return labels}).left(function(){return this.index&1?dx*((this.index>>1)+.5):0}).top(function(){return this.index&1?0:dy*((this.index>>1)+.5)}).textMargin(4).textAlign(function(){return this.index&1?"left":"right"}).textAngle(function(){return this.index&1?-Math.PI/2:0});delete this.node};pv.Layout.Matrix.prototype=pv.extend(pv.Layout.Network).property("directed",Boolean);pv.Layout.Matrix.prototype.sort=function(f){this.$sort=f;return this};pv.Layout.Matrix.prototype.buildImplied=function(s){if(pv.Layout.Network.prototype.buildImplied.call(this,s))return;var nodes=s.nodes,links=s.links,sort=this.$sort,n=nodes.length,index=pv.range(n),labels=[],pairs=[],map={};s.$matrix={labels:labels,pairs:pairs};if(sort)index.sort(function(a,b){return sort(nodes[a],nodes[b])});for(var i=0;i<n;i++){for(var j=0;j<n;j++){var a=index[i],b=index[j],p={row:i,col:j,sourceNode:nodes[a],targetNode:nodes[b],linkValue:0};pairs.push(map[a+"."+b]=p)}}for(var i=0;i<n;i++){var a=index[i];labels.push(nodes[a],nodes[a])}for(var i=0;i<links.length;i++){var l=links[i],source=l.sourceNode.index,target=l.targetNode.index,value=l.linkValue;map[source+"."+target].linkValue+=value;if(!s.directed)map[target+"."+source].linkValue+=value}};pv.Layout.Bullet=function(){pv.Layout.call(this);var that=this,buildImplied=that.buildImplied,scale=that.x=pv.Scale.linear(),orient,horizontal,rangeColor,measureColor,x;this.buildImplied=function(s){buildImplied.call(this,x=s);orient=s.orient;horizontal=/^left|right$/.test(orient);rangeColor=pv.ramp("#bbb","#eee").domain(0,Math.max(1,x.ranges.length-1));measureColor=pv.ramp("steelblue","lightsteelblue").domain(0,Math.max(1,x.measures.length-1))};(this.range=new pv.Mark).data(function(){return x.ranges}).reverse(true).left(function(){return orient=="left"?0:null}).top(function(){return orient=="top"?0:null}).right(function(){return orient=="right"?0:null}).bottom(function(){return orient=="bottom"?0:null}).width(function(d){return horizontal?scale(d):null}).height(function(d){return horizontal?null:scale(d)}).fillStyle(function(){return rangeColor(this.index)}).antialias(false).parent=that;(this.measure=new pv.Mark).extend(this.range).data(function(){return x.measures}).left(function(){return orient=="left"?0:horizontal?null:this.parent.width()/3.25}).top(function(){return orient=="top"?0:horizontal?this.parent.height()/3.25:null}).right(function(){return orient=="right"?0:horizontal?null:this.parent.width()/3.25}).bottom(function(){return orient=="bottom"?0:horizontal?this.parent.height()/3.25:null}).fillStyle(function(){return measureColor(this.index)}).parent=that;(this.marker=new pv.Mark).data(function(){return x.markers}).left(function(d){return orient=="left"?scale(d):horizontal?null:this.parent.width()/2}).top(function(d){return orient=="top"?scale(d):horizontal?this.parent.height()/2:null}).right(function(d){return orient=="right"?scale(d):null}).bottom(function(d){return orient=="bottom"?scale(d):null}).strokeStyle("black").shape("bar").angle(function(){return horizontal?0:Math.PI/2}).parent=that;(this.tick=new pv.Mark).data(function(){return scale.ticks(7)}).left(function(d){return orient=="left"?scale(d):null}).top(function(d){return orient=="top"?scale(d):null}).right(function(d){return orient=="right"?scale(d):horizontal?null:-6}).bottom(function(d){return orient=="bottom"?scale(d):horizontal?-8:null}).height(function(){return horizontal?6:null}).width(function(){return horizontal?null:6}).parent=that};pv.Layout.Bullet.prototype=pv.extend(pv.Layout).property("orient",String).property("ranges").property("markers").property("measures").property("maximum",Number);pv.Layout.Bullet.prototype.defaults=(new pv.Layout.Bullet).extend(pv.Layout.prototype.defaults).orient("left").ranges([]).markers([]).measures([]);pv.Layout.Bullet.prototype.buildImplied=function(s){pv.Layout.prototype.buildImplied.call(this,s);var size=this.parent[/^left|right$/.test(s.orient)?"width":"height"]();s.maximum=s.maximum||pv.max([].concat(s.ranges,s.markers,s.measures));this.x.domain(0,s.maximum).range(0,size)};pv.Behavior={};pv.Behavior.drag=function(){var scene,index,p,v1,max;function mousedown(d){index=this.index;scene=this.scene;var m=this.mouse();v1=((p=d).fix=pv.vector(d.x,d.y)).minus(m);max={x:this.parent.width()-(d.dx||0),y:this.parent.height()-(d.dy||0)};scene.mark.context(scene,index,function(){this.render()});pv.Mark.dispatch("dragstart",scene,index)}function mousemove(){if(!scene)return;scene.mark.context(scene,index,function(){var m=this.mouse();p.x=p.fix.x=Math.max(0,Math.min(v1.x+m.x,max.x));p.y=p.fix.y=Math.max(0,Math.min(v1.y+m.y,max.y));this.render()});pv.Mark.dispatch("drag",scene,index)}function mouseup(){if(!scene)return;p.fix=null;scene.mark.context(scene,index,function(){this.render()});pv.Mark.dispatch("dragend",scene,index);scene=null}pv.listen(window,"mousemove",mousemove);pv.listen(window,"mouseup",mouseup);return mousedown};pv.Behavior.point=function(r){var unpoint,collapse=null,kx=1,ky=1,r2=arguments.length?r*r:900;function search(scene,index){var s=scene[index],point={cost:Infinity};for(var i=0,n=s.visible&&s.children.length;i<n;i++){var child=s.children[i],mark=child.mark,p;if(mark.type=="panel"){mark.scene=child;for(var j=0,m=child.length;j<m;j++){mark.index=j;p=search(child,j);if(p.cost<point.cost)point=p}delete mark.scene;delete mark.index}else if(mark.$handlers.point){var v=mark.mouse();for(var j=0,m=child.length;j<m;j++){var c=child[j],dx=v.x-c.left-(c.width||0)/2,dy=v.y-c.top-(c.height||0)/2,dd=kx*dx*dx+ky*dy*dy;if(dd<point.cost){point.distance=dx*dx+dy*dy;point.cost=dd;point.scene=child;point.index=j}}}}return point}function mousemove(){var point=search(this.scene,this.index);if(point.cost==Infinity||point.distance>r2)point=null;if(unpoint){if(point&&unpoint.scene==point.scene&&unpoint.index==point.index)return;pv.Mark.dispatch("unpoint",unpoint.scene,unpoint.index)}if(unpoint=point){pv.Mark.dispatch("point",point.scene,point.index);pv.listen(this.root.canvas(),"mouseout",mouseout)}}function mouseout(e){if(unpoint&&!pv.ancestor(this,e.relatedTarget)){pv.Mark.dispatch("unpoint",unpoint.scene,unpoint.index);unpoint=null}}mousemove.collapse=function(x){if(arguments.length){collapse=String(x);switch(collapse){case"y":kx=1;ky=0;break;case"x":kx=0;ky=1;break;default:kx=1;ky=1;break}return mousemove}return collapse};return mousemove};pv.Behavior.select=function(){var scene,index,r,m1;function mousedown(d){index=this.index;scene=this.scene;m1=this.mouse();r=d;r.x=m1.x;r.y=m1.y;r.dx=r.dy=0;pv.Mark.dispatch("selectstart",scene,index)}function mousemove(){if(!scene)return;scene.mark.context(scene,index,function(){var m2=this.mouse();r.x=Math.max(0,Math.min(m1.x,m2.x));r.y=Math.max(0,Math.min(m1.y,m2.y));r.dx=Math.min(this.width(),Math.max(m2.x,m1.x))-r.x;r.dy=Math.min(this.height(),Math.max(m2.y,m1.y))-r.y;this.render()});pv.Mark.dispatch("select",scene,index)}function mouseup(){if(!scene)return;pv.Mark.dispatch("selectend",scene,index);scene=null}pv.listen(window,"mousemove",mousemove);pv.listen(window,"mouseup",mouseup);return mousedown
};pv.Behavior.resize=function(side){var scene,index,r,m1;function mousedown(d){index=this.index;scene=this.scene;m1=this.mouse();r=d;switch(side){case"left":m1.x=r.x+r.dx;break;case"right":m1.x=r.x;break;case"top":m1.y=r.y+r.dy;break;case"bottom":m1.y=r.y;break}pv.Mark.dispatch("resizestart",scene,index)}function mousemove(){if(!scene)return;scene.mark.context(scene,index,function(){var m2=this.mouse();r.x=Math.max(0,Math.min(m1.x,m2.x));r.y=Math.max(0,Math.min(m1.y,m2.y));r.dx=Math.min(this.parent.width(),Math.max(m2.x,m1.x))-r.x;r.dy=Math.min(this.parent.height(),Math.max(m2.y,m1.y))-r.y;this.render()});pv.Mark.dispatch("resize",scene,index)}function mouseup(){if(!scene)return;pv.Mark.dispatch("resizeend",scene,index);scene=null}pv.listen(window,"mousemove",mousemove);pv.listen(window,"mouseup",mouseup);return mousedown};pv.Behavior.pan=function(){var scene,index,m1,v1,k,bound;function mousedown(){index=this.index;scene=this.scene;v1=pv.vector(pv.event.pageX,pv.event.pageY);m1=this.transform();k=1/(m1.k*this.scale);if(bound){bound={x:(1-m1.k)*this.width(),y:(1-m1.k)*this.height()}}}function mousemove(){if(!scene)return;scene.mark.context(scene,index,function(){var x=(pv.event.pageX-v1.x)*k,y=(pv.event.pageY-v1.y)*k,m=m1.translate(x,y);if(bound){m.x=Math.max(bound.x,Math.min(0,m.x));m.y=Math.max(bound.y,Math.min(0,m.y))}this.transform(m).render()});pv.Mark.dispatch("pan",scene,index)}function mouseup(){scene=null}mousedown.bound=function(x){if(arguments.length){bound=Boolean(x);return this}return Boolean(bound)};pv.listen(window,"mousemove",mousemove);pv.listen(window,"mouseup",mouseup);return mousedown};pv.Behavior.zoom=function(speed){var bound;if(!arguments.length)speed=1/48;function mousewheel(){var v=this.mouse(),k=pv.event.wheel*speed,m=this.transform().translate(v.x,v.y).scale(k<0?1e3/(1e3-k):(1e3+k)/1e3).translate(-v.x,-v.y);if(bound){m.k=Math.max(1,m.k);m.x=Math.max((1-m.k)*this.width(),Math.min(0,m.x));m.y=Math.max((1-m.k)*this.height(),Math.min(0,m.y))}this.transform(m).render();pv.Mark.dispatch("zoom",this.scene,this.index)}mousewheel.bound=function(x){if(arguments.length){bound=Boolean(x);return this}return Boolean(bound)};return mousewheel};pv.Geo=function(){};pv.Geo.projections={mercator:{project:function(latlng){return{x:latlng.lng/180,y:latlng.lat>85?1:latlng.lat<-85?-1:Math.log(Math.tan(Math.PI/4+pv.radians(latlng.lat)/2))/Math.PI}},invert:function(xy){return{lng:xy.x*180,lat:pv.degrees(2*Math.atan(Math.exp(xy.y*Math.PI))-Math.PI/2)}}},"gall-peters":{project:function(latlng){return{x:latlng.lng/180,y:Math.sin(pv.radians(latlng.lat))}},invert:function(xy){return{lng:xy.x*180,lat:pv.degrees(Math.asin(xy.y))}}},sinusoidal:{project:function(latlng){return{x:pv.radians(latlng.lng)*Math.cos(pv.radians(latlng.lat))/Math.PI,y:latlng.lat/90}},invert:function(xy){return{lng:pv.degrees(xy.x*Math.PI/Math.cos(xy.y*Math.PI/2)),lat:xy.y*90}}},aitoff:{project:function(latlng){var l=pv.radians(latlng.lng),f=pv.radians(latlng.lat),a=Math.acos(Math.cos(f)*Math.cos(l/2));return{x:2*(a?Math.cos(f)*Math.sin(l/2)*a/Math.sin(a):0)/Math.PI,y:2*(a?Math.sin(f)*a/Math.sin(a):0)/Math.PI}},invert:function(xy){var x=xy.x*Math.PI/2,y=xy.y*Math.PI/2;return{lng:pv.degrees(x/Math.cos(y)),lat:pv.degrees(y)}}},hammer:{project:function(latlng){var l=pv.radians(latlng.lng),f=pv.radians(latlng.lat),c=Math.sqrt(1+Math.cos(f)*Math.cos(l/2));return{x:2*Math.SQRT2*Math.cos(f)*Math.sin(l/2)/c/3,y:Math.SQRT2*Math.sin(f)/c/1.5}},invert:function(xy){var x=xy.x*3,y=xy.y*1.5,z=Math.sqrt(1-x*x/16-y*y/4);return{lng:pv.degrees(2*Math.atan2(z*x,2*(2*z*z-1))),lat:pv.degrees(Math.asin(z*y))}}},identity:{project:function(latlng){return{x:latlng.lng/180,y:latlng.lat/90}},invert:function(xy){return{lng:xy.x*180,lat:xy.y*90}}}};pv.Geo.scale=function(p){var rmin={x:0,y:0},rmax={x:1,y:1},d=[],j=pv.Geo.projections.identity,x=pv.Scale.linear(-1,1).range(0,1),y=pv.Scale.linear(-1,1).range(1,0),c={lng:0,lat:0},lastLatLng,lastPoint;function scale(latlng){if(!lastLatLng||latlng.lng!=lastLatLng.lng||latlng.lat!=lastLatLng.lat){lastLatLng=latlng;var p=project(latlng);lastPoint={x:x(p.x),y:y(p.y)}}return lastPoint}function project(latlng){var offset={lng:latlng.lng-c.lng,lat:latlng.lat};return j.project(offset)}function invert(xy){var latlng=j.invert(xy);latlng.lng+=c.lng;return latlng}scale.x=function(latlng){return scale(latlng).x};scale.y=function(latlng){return scale(latlng).y};scale.ticks={lng:function(m){var lat,lng;if(d.length>1){var s=pv.Scale.linear();if(m==undefined)m=10;lat=s.domain(d,function(d){return d.lat}).ticks(m);lng=s.domain(d,function(d){return d.lng}).ticks(m)}else{lat=pv.range(-80,81,10);lng=pv.range(-180,181,10)}return lng.map(function(lng){return lat.map(function(lat){return{lat:lat,lng:lng}})})},lat:function(m){return pv.transpose(scale.ticks.lng(m))}};scale.invert=function(p){return invert({x:x.invert(p.x),y:y.invert(p.y)})};scale.domain=function(array,f){if(arguments.length){d=array instanceof Array?arguments.length>1?pv.map(array,f):array:Array.prototype.slice.call(arguments);if(d.length>1){var lngs=d.map(function(c){return c.lng});var lats=d.map(function(c){return c.lat});c={lng:(pv.max(lngs)+pv.min(lngs))/2,lat:(pv.max(lats)+pv.min(lats))/2};var n=d.map(project);x.domain(n,function(p){return p.x});y.domain(n,function(p){return p.y})}else{c={lng:0,lat:0};x.domain(-1,1);y.domain(-1,1)}lastLatLng=null;return this}return d};scale.range=function(min,max){if(arguments.length){if(typeof min=="object"){rmin={x:Number(min.x),y:Number(min.y)};rmax={x:Number(max.x),y:Number(max.y)}}else{rmin={x:0,y:0};rmax={x:Number(min),y:Number(max)}}x.range(rmin.x,rmax.x);y.range(rmax.y,rmin.y);lastLatLng=null;return this}return[rmin,rmax]};scale.projection=function(p){if(arguments.length){j=typeof p=="string"?pv.Geo.projections[p]||pv.Geo.projections.identity:p;return this.domain(d)}return p};scale.by=function(f){function by(){return scale(f.apply(this,arguments))}for(var method in scale)by[method]=scale[method];return by};if(arguments.length)scale.projection(p);return scale};
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

// Returns true if this maybe-array equals the other maybe-array, where
// a maybe-array is either an array or undefined.
maybeArraysEqual = function(first, second) {
  if (!first !== !second) {
    return false;
  }
  return arraysEqual(first, second);
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
  child.__super__ = parent.prototype;
}

// Partial bind polyfill for older versions of Safari from:
// https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Function/bind
if (!Function.prototype.bind) {
  Function.prototype.bind = function (oThis) {
    if (typeof this !== "function") {
      // closest thing possible to the ECMAScript 5
      // internal IsCallable function
      throw new TypeError("Function.prototype.bind - what is trying to be bound is not callable");
    }

    var aArgs = Array.prototype.slice.call(arguments, 1),
        fToBind = this,
        fNOP = function () {},
        fBound = function () {
          return fToBind.apply(this instanceof fNOP && oThis
                 ? this
                 : oThis,
                 aArgs.concat(Array.prototype.slice.call(arguments)));
        };

    fNOP.prototype = this.prototype;
    fBound.prototype = new fNOP();

    return fBound;
  };
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

var Options = function(target, options) {
  this.target = target;

  options = options || {};
  options.key_bindings = options.key_bindings || Key.defaultKeyBindings;
  this.key_bindings = $.extend({}, options.key_bindings);
  this.key_elements = {};

  var form = $('<form>').addClass('form-horizontal');
  for (var i = 0; i < Action.NUMACTIONS; i++) {
    form.append(this.build_action(i));
  }
  form.append($('<div>').addClass('divider'));

  var animation_group = $('<div>').addClass('form-group');
  animation_group.append(this.build_bool_option(
      'Animate preview:', 'animate_preview', options.animate_preview));
  animation_group.append(this.build_bool_option(
      'Animate scores:', 'animate_scores', options.animate_scores));
  form.append(animation_group);

  target.addClass('combinos-options').attr('tabindex', 2).append(form);
}

Options.validate_options = function(options) {
  for (var key in options.key_bindings) {
    assert(key in Key.keyNames, 'Unexpected key: ' + key);
    var action = options.key_bindings[key];
    assert(parseInt(action) === action &&
           0 <= action && action < Action.NUMACTIONS,
           'Unexpected action: ' + action);
  }
  assert(options.animate_preview === !!options.animate_preview);
  assert(options.animate_scores === !!options.animate_scores);
}

Options.prototype.get_current_options = function() {
  return {
    'key_bindings': this.key_bindings,
    'animate_preview': this.get_bool_option('animate_preview'),
    'animate_scores': this.get_bool_option('animate_scores'),
  };
}

Options.prototype.get_bool_option = function(option) {
  var selector = '.bool-option.' + option + '>.active>input';
  return !!(parseInt(this.target.find(selector).val()));
}

Options.prototype.build_bool_option = function(label, option, value) {
  var cls = 'btn btn-default btn-white';
  return $('<div>').addClass('bool-option-group').append(
    $('<label>').addClass('col-sm-4 control-label').text(label),
    $('<div>').addClass('bool-option ' + option + ' btn-group btn-group-sm')
        .attr('data-toggle', 'buttons').append(
      $('<label>').addClass(cls + (value ? ' active' : '')).text('On')
          .append($('<input type="radio" value="1">')),
      $('<label>').addClass(cls + (value ? '' : ' active')).text('Off')
          .append($('<input type="radio" value="0">'))
    )
  )
}

Options.prototype.build_action = function(action) {
  var result = $('<div>').addClass('form-group');
  var label = $('<label>')
    .addClass('col-sm-4 control-label')
    .text(Action.labels[action] + ':');

  // Create the keys tag input element.
  var tag_input = $('<div>').addClass('col-sm-8 keys-list');
  var button = $('<a>')
    .addClass('btn btn-primary btn-sm')
    .data('action', action)
    .text('+');
  button.click(this.wait_for_key.bind(this, button));
  tag_input.append(button);

  // Build a tag box for each key assigned to this action.
  var keys = [];
  for (var key in this.key_bindings) {
    if (this.key_bindings[key] === action) {
      keys.push(key);
    }
  }
  keys.sort();
  for (var i = 0; i < keys.length; i++) {
    tag_input.append(this.build_key(action, keys[i]));
  }

  // Return the final action input.
  result.append(label, tag_input);
  return result;
}

Options.prototype.build_key = function(action, key) {
  var that = this;

  if (this.key_elements.hasOwnProperty(key)) {
    this.key_elements[key].remove();
  }
  var result = $('<a>')
    .addClass('btn btn-default btn-sm')
    .data('key', key)
    .click(function() {
      delete that.key_bindings[key];
      this.remove();
    })
    .text(Key.keyNames[key] || 'Keycode ' + key)
    .append($('<span>').addClass('close-button').html('&times;'));
  this.key_bindings[key] = action;
  this.key_elements[key] = result;
  return result;
}

Options.prototype.signal_ready = function(button) {
  button.removeClass('btn-info').addClass('btn-default').text('+');
  this.waiting_button = undefined;
  this.target.unbind('keydown');
}

Options.prototype.signal_wait = function(button) {
  button.removeClass('btn-default').addClass('btn-info').text('Press a key...');
  this.waitingButton = button;
  this.target.keydown(this.get_key.bind(this, button));
}

Options.prototype.wait_for_key = function(button, e) {
  var repeat = button === this.waiting_button;
  if (this.waiting_button) {
    this.signal_ready(this.waiting_button);
  }
  if (!repeat) {
    this.signal_wait(button);
  }
}

Options.prototype.get_key = function(button, e) {
  this.signal_ready(button);

  // Extract the key code from the event. Note that this behavior is slighlty
  // browser-dependent, so we have to check a few cases.
  e = e || window.event;
  e.bubbles = false;
  var key = e.keyCode;

  // We don't allow the user to assign escape to a button.
  if (key !== 27) {
    this.add_key(button, key);
  }
  e.preventDefault();
}

Options.prototype.add_key = function(button, key) {
  var children = button.parent().children();
  // Insert the new key into the tag input in the correct place.
  for (var i = 1; i < children.length; i++) {
    var existing_key = parseInt($(children[i]).data('key'), 10);
    if (existing_key === key) {
      // TODO(skishore): Flash this tag to show that it's already assigned.
      return;
    } else if (existing_key > key) {
      break;
    }
  }
  var action = parseInt(button.data('action'), 10);
  $(children[i - 1]).after(this.build_key(action, key));
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
  MAX_PER_LEVEL: 29,
  MAX: (6 + 2)*29,

  HEXREGEX: /\#([0-9a-f][0-9a-f])([0-9a-f][0-9a-f])([0-9a-f][0-9a-f])/i,

  initialize: function(colorCode) {
    // Add colors that encode attacks for battle mode.
    this.attack_colors = [];
    for (var i = 0; i <= Constants.ATTACKS; i++) {
      var lambda = (i + (i ? 1 : 0))/(Constants.ATTACKS + 1);
      this.attack_colors.push(this.mix('#8888ff', '#ff4444', lambda));
    }

    // Initialize the body and edge colors lists. There will 29 body and edge
    // colors to start with, plus a version of these at each of the attack
    // levels for multiplayer.
    this.body_colors = [];
    this.edge_colors = [];
    this.pushColor(this.BLACK);
    for (var i = 0; i < this.MAX_PER_LEVEL; i++) {
      this.pushColor(colorCode(i));
    }
    for (var j = 0; j <= Constants.ATTACKS; j++) {
      var lambda = 0.8 - 0.4*j/Constants.ATTACKS;
      for (var i = 0; i < this.MAX_PER_LEVEL; i++) {
        this.pushColor(Color.mix(
            this.attack_colors[j], this.body_colors[i + 1], lambda));
      }
    }
    // We now add a lighter version of each of these colors for active blocks.
    assert(this.body_colors.length === this.MAX + 1);
    for (var i = 0; i < this.MAX; i++) {
      var color = this.body_colors[i + 1];
      this.pushColor(this.mix(color, this.WHITE, Color.LAMBDA));
    }

    // Create a CSS stylesheet with rules for the following classes:
    //    .combinos .attack-i, 0 <= i < ATTACKS
    //    .combinos .square-i, 0 <= i <= 3*Color.MAX
    //    .combinos .free-square-i, 0 <= i <= 2*Color.MAX
    // Here, Color.MAX is always the maximum color that could appear as the
    // color of a block.
    var rules = [];
    for (var i = 0; i < Constants.ATTACKS; i++) {
      rules.push(
        '.combinos .attack-' + i + ' {\n' +
        '  color: ' + this.attack_colors[i + 1] + ';\n' +
        '}');
    }
    for (var i = 0; i <= 2*this.MAX; i++) {
      rules.push(
        '.combinos .square-' + i + ' {\n' +
        '  background-color: ' + this.body_colors[i] + ';\n' +
        '  border-color: ' + this.edge_colors[i] + ';\n' +
        '}');
      var free_color = this.body_colors[i + this.MAX];
      if (i > this.MAX) {
        free_color = this.mix(this.body_colors[i], this.BLACK, 0.4*this.LAMBDA);
      }
      rules.push(
        '.combinos .free-square-' + i + ' {\n' +
        '  background-color: ' + free_color + ';\n' +
        '}');
    }
    for (var i = 2*this.MAX + 1; i <= 3*this.MAX; i++) {
      var color = this.body_colors[i - Color.MAX];
      color = this.mix(color, this.BLACK, Color.LAMBDA/4);
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
// The user is waiting for the next multiplayer round to begin.
Constants.WAITING = 3;

// Game engine constants.
Constants.FRAMERATE = 48;
Constants.FRAMEDELAY = Math.floor(1000/Constants.FRAMERATE);
Constants.MAXFRAME = 3628800;
Constants.PAUSE = 3;
Constants.REPEAT = 0;

// Block movement constants, some of which are imported by Block.
Constants.GRAVITY = 2*Constants.FRAMERATE/3;
Constants.SHOVEAWAYS = 4;
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

// The maximum attack size in battle mode.
Constants.ATTACKS = 6;

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
  this.battle_color = Block.prototypes[type].battle_color;
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
  var max_color = 0;

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
    block.battle_color =
        block.color + Color.MAX_PER_LEVEL*Math.max(numSquares - 3, 1);
    block.height = block.calculateHeight();
    block.rotates = block.checkIfRotates();
    Block.prototypes.push(block);
    max_color = Math.max(max_color, block.battle_color);
  }

  assert(max_color === Color.MAX, 'Unexpected maximum color: ' + max_color);
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

var DifficultyCurve = (function() {
"use strict";

var DifficultyCurve = function(rng) {
  this.rng = rng || Math;
}

DifficultyCurve.prototype.generateBlockType = function(level) {
  var last = level && Block.TYPES[level - 1];
  return Math.floor((Block.TYPES[level] - last)*this.rng.random()) + last;
}

DifficultyCurve.cachedLevels = [];
DifficultyCurve.derandomizer = [];
for (var i = 0; i < Block.LEVELS; i++) {
  DifficultyCurve.derandomizer.push(0);
}

DifficultyCurve.getLevel = function(index) {
  if (index >= this.cachedLevels.length) {
    for (var i = 0; i < index + 1; i++) {
      var level = this.sample(this.distribution(this.cachedLevels.length));
      this.cachedLevels.push(level);
    }
  }
  return this.cachedLevels[index];
}

DifficultyCurve.sample = function(distribution) {
  var sum = this.sum(distribution);
  var max = -Infinity;
  var result = -1;
  for (var i = 0; i < distribution.length; i++) {
    this.derandomizer[i] += distribution[i]/sum;
    if (this.derandomizer[i] > max) {
      max = this.derandomizer[i];
      result = i;
    }
  }
  this.derandomizer[result] -= 1;
  return result;
}

DifficultyCurve.sum = function(array) {
  var result = 0;
  for (var i = 0; i < array.length; i++) {
    result += array[i];
  }
  return result;
}

DifficultyCurve.distribution = function(index) {
  var LEVEL_INTERVAL = 50;
  var MID_DISTRIBUTION = [11, 18, 12, 6, 2, 1, 1];
  var MID_SCORE = 20*LEVEL_INTERVAL;

  var result = [];
  var exponent = 0.8*(3*index/MID_SCORE - 1);
  for (var i = 0; i < Block.LEVELS; i++) {
    var r = (exponent > 0 ? Math.pow(i - 1, exponent) : 1);
    if (i < 2) {
      result.push(MID_DISTRIBUTION[i]);
    } else {
      var start = (i - 2)*LEVEL_INTERVAL;
      var x = (index - start)/(MID_SCORE - start);
      result.push(MID_DISTRIBUTION[i]*r*2*this.flatten(x));
    }
  }
  return result;
}

DifficultyCurve.flatten = function(x) {
  return (x < 0 ? 0 : x/(1 + x));
}

return DifficultyCurve;
})();

var DifficultyUI = (function() {
"use strict";

DifficultyUI = function(target) {
  target.attr('id', this.generateId());
  this.target = target;
  this.width = 1000;

  this.offset = Constants.PREVIEW + 1;
  this.interval = this.width/target.width();
  this.render(this.offset);
}

DifficultyUI.prototype.render = function(start) {
  this.target.empty().css('display', 'block');
  this.start = start;

  var end = start + this.width;
  var data = this.getData(start, end, this.interval);
  var xAxis = pv.Scale.linear(start, end).range(0, this.target.height());
  var yAxis = pv.Scale.linear(0, 1).range(0, this.target.width());

  var vis = new pv.Panel()
      .canvas(this.target.attr('id'))
      .width(this.target.width())
      .height(this.target.height());
  vis.add(pv.Layout.Stack)
      .orient('left-top')
      .layers(data)
      .x(function(point) {return xAxis(point.x);})
      .y(function(point) {return yAxis(point.y);})
      .layer.add(pv.Area);
  vis.render();

  this.mark = $('<div>').addClass('mark');
  this.target.append(this.mark);
  // State variables used to move the mark.
  this.height = this.target.height();
  this.mark_top = null;
}

DifficultyUI.counter = 0;

DifficultyUI.prototype.generateId = function() {
  DifficultyUI.counter += 1;
  return 'unique-difficulty-graph-id-' + (DifficultyUI.counter - 1);
}

DifficultyUI.prototype.getData = function(start, end, interval) {
  var distributions = pv.range(start, end, interval).map(function(index) {
    return DifficultyCurve.distribution(index);
  });
  distributions.push(DifficultyCurve.distribution(end));
  var indices = pv.range(distributions.length);
  var sums = indices.map(function(i) {
    return DifficultyCurve.sum(distributions[i]);
  });
  return pv.range(Block.LEVELS).map(function(level) {
    return indices.map(function(i) {
      return {x: start + i*interval, y: distributions[i][level]/sums[i]};
    });
  });
}

DifficultyUI.prototype.setBlockIndex = function(index) {
  var best_start = index - ((index - this.offset) % this.width);
  if (best_start !== this.start) {
    this.render(best_start);
  }
  var fraction = (index - this.start)/this.width;
  var mark_top = Math.floor(fraction*this.height - 1);
  if (mark_top !== this.mark_top) {
    this.mark.css('top', mark_top);
    this.mark_top = mark_top;
  }
}

return DifficultyUI;
})();

var Graphics = (function() {
"use strict";

var Graphics = function(squareWidth, target, settings) {
  this.squareWidth = squareWidth;
  this.target = target;
  this.settings = settings;
  this.multiplayer = !settings.singleplayer;
  this.color_attribute = (
      settings.game_type === 'battle' ? 'battle_color' : 'color');

  this.smallWidth = Math.ceil(this.squareWidth/2);
  this.border = this.smallWidth;
  this.sideboard = 6*this.smallWidth;
  var boardWidth = Constants.COLS*this.squareWidth;
  this.width = boardWidth + 2*this.sideboard + 4*this.border;
  this.height = Constants.VISIBLEROWS*this.squareWidth + 2*this.border;

  this.elements = this.build(target);
  assert(this.width === target.outerWidth(), 'Error: width mismatch');
  assert(this.height === target.outerHeight(), 'Error: height mismatch');
}

// Returns a dictionary of jQuery elements that comprise the graphics.
Graphics.prototype.build = function(target) {
  var result = {};
  target.css('padding', this.border);

  var overlay_wrapper = $('<div>').addClass('overlay-wrapper');
  result.overlay = $('<div>').addClass('overlay');
  if (this.multiplayer) {
    result.line = $('<div>').addClass('text-box');
  } else {
    result.line = $('<div>').addClass('text-box small-text-box').css({
      'font-size': this.squareWidth,
      'line-height': '' + Math.round(4*this.squareWidth/3) + 'px',
      'padding': '' + Math.round(this.squareWidth/6) + 'px 0',
    });
  }
  target.append(overlay_wrapper.append(result.overlay, result.line));

  var scoreboard = $('<div>').addClass('scoreboard').css({
    'height': this.squareWidth*Constants.VISIBLEROWS,
    'width': this.sideboard,
  });
  target.append(scoreboard);

  var level_section = this.scoreSection(scoreboard, 'Level');
  var difficulty_ui = $('<div>').addClass('difficulty-ui').css({
    'height': Math.floor(this.height/3),
    'margin-left': this.squareWidth/4,
    'margin-right': this.squareWidth/4,
  });
  level_section.append(difficulty_ui);
  result.difficulty_ui = new DifficultyUI(difficulty_ui);

  var score_section = this.scoreSection(scoreboard, 'Score');
  result.score = $('<div>').addClass('score').css({
    'font-size': this.squareWidth,
    'margin-left': this.squareWidth/4,
    'margin-right': this.squareWidth/4,
  }).text(0);
  score_section.append(result.score);

  var combo_section = this.scoreSection(scoreboard, 'Combo');
  result.combo = $('<div>')
      .addClass('combo')
      .css('font-size', 1.5*this.squareWidth)
      .text(0);
  combo_section.append(result.combo);
  result.combo.parent().addClass('dim');

  this.fixSectionHeights(scoreboard, '.score-section');

  var board = $('<div>').addClass('board').css({
    'height': this.squareWidth*Constants.VISIBLEROWS,
    'width': this.squareWidth*Constants.COLS,
  });
  target.append(this.verticalSpacer(), board, this.verticalSpacer());

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
  target.append(sideboard);

  var padding = this.squareWidth/4;
  var preview_wrapper =
      $('<div>').addClass('preview-wrapper')
                .height(3*this.squareWidth*(Constants.PREVIEW + 1));
  result.preview = $('<div>').addClass('preview');
  result.attacks = $('<div>').addClass('attacks');
  sideboard.append(preview_wrapper.append(result.preview, result.attacks));

  result.hold = $('<div>').addClass('hold').css({
    'height': 4*this.squareWidth,
    'margin-left': this.squareWidth/4,
    'margin-right': this.squareWidth/4,
  });
  sideboard.append(result.hold);

  result.hold_overlay = $('<div>').addClass('hold-overlay');
  result.hold.append(result.hold_overlay);

  preview_wrapper.css('padding-top',
      (sideboard.height() - preview_wrapper.height() - result.hold.height())/2);

  result.floating_score =
      $('<div>').addClass('floating-score')
                .css('font-size', 7*this.squareWidth/6);
  target.append(result.floating_score);

  return result;
}

Graphics.prototype.fixSectionHeights = function(container, selector) {
  var height = 0;
  var sections = container.find(selector);
  for (var i = 0; i < sections.length; i++) {
    height += $(sections[i]).height();
  }
  var margin = (container.height() - height)/(2*sections.length);
  sections.css('padding', '' + margin + 'px 0');
}

Graphics.prototype.scoreSection = function(scoreboard, title) {
  var section = $('<div>').addClass('score-section');
  section.append($('<div>').addClass('score-label').text(title).css({
    'font-size': this.squareWidth,
    'margin-bottom': this.squareWidth/4,
  }));
  scoreboard.append(section);
  return section;
}

Graphics.prototype.verticalSpacer = function() {
  return $('<div>')
      .addClass('vertical-spacer')
      .height(this.squareWidth*Constants.VISIBLEROWS)
      .width(this.border);
}

Graphics.prototype.getSquareIndex = function(i, j) {
  assert(i >= 0 && i < Constants.ROWS && j >= 0 && j < Constants.COLS,
      'Invalid board square: (' + i + ', ' + j + ')');
  return Constants.COLS*(i - Constants.HIDDENROWS) + j;
}

Graphics.prototype.drawFreeBlock = function(target, type, x, y, w) {
  if (type >= 0) {
    var block = Block.prototypes[type];
    var offsets = block.getOffsets();
    for (var i = 0; i < offsets.length; i++) {
      var offset = offsets[i];
      var color = block[this.color_attribute]
      color += ((offset.x + offset.y) % 2 ? 0 : Color.MAX);
      var cls = 'free-square free-square-' + color;
      target.append($('<div>').addClass(cls).css({
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
      // Animate the preview, accounting for both the block's height and the
      // margin that comes after it.
      var height = Block.prototypes[type].height*this.smallWidth;
      this.animatePreview(height + this.squareWidth);
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
    var xOffset = 2*this.smallWidth + this.squareWidth/4;
    this.drawFreeBlock(block, type, xOffset, 0, this.smallWidth);
    this.elements.preview.append(block);
  }
  assert(
      arraysEqual(this.state.preview, this.delta.preview),
      "Previews mismatched!");
}

Graphics.prototype.animatePreview = function(height) {
  if (!this.settings.options.animate_preview) {
    return;
  }
  var duration = 1000*Constants.PREVIEWFRAMES/Constants.FRAMERATE;
  var preview = this.elements.preview.get(0);
  move(preview).y(height).duration(0).end(
      move(preview).y(0).duration(duration).ease('linear').end());
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

Graphics.prototype.updateCombo = function() {
  this.elements.combo.text(this.delta.combo);
  if (this.delta.combo > 0) {
    this.elements.combo.parent().removeClass('dim');
  } else {
    this.elements.combo.parent().addClass('dim');
  }
  this.state.combo = this.delta.combo;
}

Graphics.prototype.updateOverlay = function() {
  if (this.multiplayer) {
    this.updateMultiplayerOverlay();
  } else if (this.delta.state === Constants.PLAYING) {
    this.elements.overlay.css('background-color', 'transparent');
    this.drawText();
  } else if (this.delta.state === Constants.PAUSED) {
    this.elements.overlay.css('background-color', 'black');
    this.elements.overlay.css('opacity', 1);
    var resume = (this.delta.pauseReason === 'focus' ? 'Click' : 'Press START');
    this.drawText('-- PAUSED --\n' + resume + ' to resume');
  } else if (this.delta.state === Constants.GAMEOVER) {
    this.elements.overlay.css('background-color', 'red');
    this.elements.overlay.css('opacity', 1.2*Color.LAMBDA);
    this.drawText('-- You FAILED --\nPress START to try again');
  }
  this.state.state = this.delta.state;
  this.state.pauseReason = this.delta.pauseReason;
}

Graphics.prototype.updateMultiplayerOverlay = function() {
  if (this.delta.state === Constants.PLAYING) {
    this.elements.overlay.css('background-color', 'transparent');
    this.drawText();
  } else {
    var pauseReason = this.delta.pauseReason;
    var last_state = (pauseReason ? pauseReason.last_state : '');
    var text = (pauseReason ? '' + pauseReason.text : '');
    if (this.delta.state === Constants.GAMEOVER ||
        last_state === Constants.GAMEOVER) {
      this.elements.overlay.css('background-color', '#800');
      this.elements.overlay.css('opacity', 1.8*Color.LAMBDA);
    } else if (last_state === Constants.PLAYING) {
      this.elements.overlay.css('background-color', '#444');
      this.elements.overlay.css('opacity', 1.8*Color.LAMBDA);
    } else {
      this.elements.overlay.css('background-color', 'black');
      this.elements.overlay.css('opacity', 1);
    }
    var factor = (text.length === 1 ? 24 : 1.5);
    this.elements.line.css('font-size', factor*this.squareWidth);
    this.drawText(text);
    if (this.settings.me && pauseReason && pauseReason.start_game_text) {
      this.elements.line.append(
        $('<a>').addClass('btn btn-default btn-sm')
                .click(this.startGame.bind(this))
                .text(pauseReason.start_game_text));
    }
  }
}

Graphics.prototype.drawText = function(text) {
  if (text) {
    this.elements.line.html(text.replace('\n', '<br>')).show();
  } else {
    this.elements.line.empty().hide();
  }
}

Graphics.prototype.startGame = function() {
  this.settings.send({type: 'start_late'});
}

Graphics.prototype.updateAttacks = function() {
  assert(this.delta.attacks, 'Updating attacks when attacks is undefined');
  this.state.attacks = this.state.attacks || [];
  while (!this.isPrefix(this.state.attacks, this.delta.attacks)) {
    this.state.attacks.shift();
    this.elements.attacks.children().eq('0').remove();
  }
  while (this.state.attacks.length < this.delta.attacks.length) {
    var type = this.delta.attacks[this.state.attacks.length];
    this.state.attacks.push(type);
    var symbol = '&#' + (9843 + type);
    var cls = 'preview-block attack-' + type;
    var block = $('<div>').addClass(cls).html(symbol).css(
      'margin-bottom', this.squareWidth);
    this.elements.attacks.append(block);
  }
  assert(
      arraysEqual(this.state.preview, this.delta.preview),
      "Previews mismatched!");
}

Graphics.prototype.isPrefix = function(list1, list2) {
  for (var i = 0; i < list1.length; i++) {
    if (list1[i] !== list2[i]) {
      return false;
    }
  }
  return true;
}

//////////////////////////////////////////////////////////////////////////////
// Public interface begins here!
//////////////////////////////////////////////////////////////////////////////

Graphics.prototype.reset = function(board) {
  this.state = {
    board: [],
    blockIndex: 0,
    preview: [],
  };
  this.delta = {board: {}};

  // We set each cell in the board to -1 so that they will all be marked dirty
  // and redrawn during the call to flip(). Additionally, we have to clear any
  // square class on the board already, since cell colors are changed by
  // removing the old class and adding the new one.
  for (var i = 0; i < Constants.VISIBLEROWS*Constants.COLS; i++) {
    this.state.board.push(-1);
    this.elements.board[i].attr('class', 'square');
    var x = Math.floor(i/Constants.COLS) + Constants.HIDDENROWS;
    var y = i % Constants.COLS;
    this.delta.board[i] = board.data[x][y];
  }

  // Empty the preview and the attacks.
  this.elements.preview.empty();
  this.elements.attacks.empty();

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

Graphics.prototype.drawFloatingScore = function(block, score) {
  if (!this.settings.options.animate_scores) {
    return;
  }
  var index = this.getSquareIndex(block.y, block.x);
  if (index >= 0) {
    var offset = this.target.offset();
    var position = this.elements.board[index].offset();
    var padding = this.squareWidth/3;

    var x = position.left - offset.left - padding;
    var y = position.top - offset.top - padding;
    var rise = 36;

    this.elements.floating_score.text('+' + score);
    var floating_score = this.elements.floating_score.get(0);
    move(floating_score)
      .x(x).y(y).set('opacity', 1).duration(0)
      .end(
        move(floating_score)
          .x(x).y(y - rise).duration(400).ease('linear')
          .end(
            move(floating_score)
              .set('opacity', 0).duration(20*score).ease('linear')
              .end()));
  }
}

Graphics.prototype.drawUI = function(board) {
  this.delta.blockIndex = board.blockIndex;
  this.delta.preview = board.preview;
  this.delta.held = board.held;
  this.delta.heldBlockType = board.heldBlockType;
  this.delta.combo = board.combo;
  this.delta.score = board.score;
  this.delta.state = board.state;
  this.delta.pauseReason = board.pauseReason;
  // Multiplayer-only values that are set to defaults for singleplayer games,
  // plus the level, which is affected by the multiplayer attackIndex.
  this.delta.attacks = board.attacks;
  this.delta.attackIndex = board.attackIndex || 0;
  this.delta.level = this.delta.attackIndex + this.delta.blockIndex;
}

Graphics.prototype.flip = function() {
  for (var k in this.delta.board) {
    var color = this.delta.board[k];
    var last = this.state.board[k];
    if (last !== color) {
      var square = this.elements.board[k];
      square.removeClass('square-' + last).addClass('square-' + color);
      this.state.board[k] = color;
    }
  }
  if (this.state.blockIndex !== this.delta.blockIndex ||
      this.state.preview.length !== this.delta.preview.length) {
    this.updatePreview();
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
  if (this.state.combo !== this.delta.combo) {
    this.updateCombo();
  }
  if (this.state.state !== this.delta.state) {
    this.updateOverlay();
  }
  if (this.state.level !== this.delta.level) {
    this.elements.difficulty_ui.setBlockIndex(this.delta.level);
    this.state.level = this.delta.level;
  }
  if (this.multiplayer) {
    if (!maybeArraysEqual(this.state.attacks, this.delta.attacks)) {
      this.updateAttacks();
    }
    if (this.state.attackIndex !== this.delta.attackIndex) {
      this.state.attackIndex = this.delta.attackIndex;
    }
  }
  // At this point, this.delta should equal this.state, except for board,
  // which is stored sparsely in this.delta but densely in this.state.
  this.delta.board = {};
}

return Graphics;
})();

var KeyRepeater = (function() {
"use strict";

var KeyRepeater = function(pause, repeat, target, keyBindings) {
  this.pause = pause;
  this.repeat = repeat;
  this.setKeyBindings(keyBindings);

  target.attr('tabIndex', 1);
  target.keydown(this.keydown_handler());
  target.keyup(this.keyup_handler());
}

KeyRepeater.prototype.setKeyBindings = function(keyBindings) {
  keyBindings = keyBindings || Key.loadKeyBindings();
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

// Places the block onto the board and removes full rows from the board.
// Returns the number of rows removed.
Physics.placeBlock = function(block, data) {
  var offsets = block.getOffsets();
  for (var i = 0; i < offsets.length; i++) {
    var offset = offsets[i];
    data[offset.y][offset.x] = block.color;
  }
  return this.removeRows(data);
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

var Board = function(rng) {
  this.data = [];
  for (var i = 0; i < Constants.ROWS; i++) {
    var row = [];
    for (var j = 0; j < Constants.COLS; j++) {
      row.push(0);
    }
    this.data.push(row);
  }
  this.reset(rng);
}

Board.prototype.reset = function(rng) {
  this.curve = new DifficultyCurve(rng);

  for (var i = 0; i < Constants.ROWS; i++) {
    for (var j = 0; j < Constants.COLS; j++) {
      this.data[i][j] = 0;
    }
  }

  this.frame = 0;
  this.held = false;
  this.heldBlockType = -1;
  this.combo = 0;
  this.score = 0;
  this.state = Constants.PLAYING;

  this.blockIndex = 0;
  this.preview = [];
  for (var i = 0; i < Constants.PREVIEW; i++) {
    this.maybeAddToPreview();
  }
  this.block = this.nextBlock();
}

Board.prototype.update = function(keys) {
  if (!this.held && keys.indexOf(Action.HOLD) >= 0) {
    this.block = this.nextBlock(this.block);
  } else if (keys.indexOf(Action.DROP) >= 0) {
    this.block.y += this.block.rowsFree;
    this.updateScore(Physics.placeBlock(this.block, this.data));
    this.maybeRedraw();
    this.block = this.nextBlock();
  } else {
    Physics.moveBlock(this.block, this.data, keys);
  }
  if (this.block.rowsFree < 0) {
    this.state = Constants.GAMEOVER;
  }
}

Board.prototype.updateScore = function(rows) {
  if (rows > 0) {
    this.combo += 1;
    this.score += rows*rows + (this.combo - 1);
  } else {
    this.combo = 0;
  }
}

Board.prototype.maybeRedraw = function() {
  // The base Board class doesn't need to be drawn.
}

Board.prototype.nextBlock = function(swap) {
  var type = -1;
  if (swap) {
    type = this.heldBlockType;
    this.heldBlockType = swap.type;
  }
  if (type < 0) {
    this.maybeAddToPreview();
    type = this.preview.shift();
  }

  this.held = (swap ? true : false);
  var result = new Block(type);
  result.rowsFree = Physics.calculateRowsFree(result, this.data);
  if (this.settings && this.settings.game_type === 'battle') {
    result.color = result.battle_color;
  }
  return result;
}

Board.prototype.maybeAddToPreview = function() {
  this.blockIndex += 1;
  var level = DifficultyCurve.getLevel(this.blockIndex);
  this.preview.push(this.curve.generateBlockType(level));
}

return Board;
})();

var LocalBoard = (function() {
"use strict";

var LocalBoard = function(target, settings) {
  this.target = target;
  this.settings = settings || {singleplayer: true, options: {}};
  var key_bindings = this.settings.options.key_bindings;

  this.graphics = new Graphics(Constants.SQUAREWIDTH, target, this.settings);
  this.repeater = new KeyRepeater(
      Constants.PAUSE, Constants.REPEAT, target, key_bindings);

  LocalBoard.__super__.constructor.bind(this)();

  this.afterTime = (new Date).getTime();
  this.sleepTime = Constants.FRAMEDELAY;
  setTimeout(this.gameLoop.bind(this), this.sleepTime);
}

extend(LocalBoard, Board);

LocalBoard.prototype.reset = function() {
  LocalBoard.__super__.reset.bind(this)();
  this.graphics.reset(this);
}

LocalBoard.prototype.gameLoop = function() {
  if (!$.contains(window.document, this.target[0])) {
    return;
  }

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

LocalBoard.prototype.tick = function() {
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

LocalBoard.prototype.updateScore = function(rows) {
  var old_score = this.score;
  LocalBoard.__super__.updateScore.bind(this)(rows);
  if (this.score > old_score) {
    this.graphics.drawFloatingScore(this.block, this.score - old_score);
  }
}

LocalBoard.prototype.getKeys = function() {
  var keys = this.repeater.query();
  if (this.block.localStickFrames <= 0 || this.block.globalStickFrames <= 0) {
    keys.push(Action.DROP);
  } else if (this.frame % Constants.GRAVITY === 0) {
    keys.push(Action.DOWN);
  }
  return keys;
}

LocalBoard.prototype.maybeRedraw = function() {
  for (var i = 0; i < Constants.ROWS; i++) {
    for (var j = 0; j < Constants.COLS; j++) {
      this.graphics.drawBoardSquare(i, j, this.data[i][j]);
    }
  }
}

return LocalBoard;
})();

var ClientBoard = (function() {
"use strict";

var ClientBoard = function(target, view, settings) {
  ClientBoard.__super__.constructor.bind(this)(target, settings);
  this.resetForView(view);
  this.settings = settings;
}

extend(ClientBoard, LocalBoard);

ClientBoard.prototype.reset = function() {
  this.frame = 0;
}

ClientBoard.prototype.resetForView = function(view) {
  OpponentBoard.prototype.deserialize.bind(this)(view);
  this.preview = this.preview.slice();

  // Set up the state needed to stay in sync with the server.
  this.serverSyncIndex = this.syncIndex;
  this.move = [];
  this.moveQueue = [];
}

ClientBoard.prototype.tick = function() {
  var keys = this.getKeys();

  if (keys.indexOf(Action.START) >= 0 && this.settings.singleplayer) {
    if (this.state === Constants.PLAYING) {
      this.state = Constants.PAUSED;
      this.pauseReason = 'manual';
    } else if (this.state === Constants.PAUSED) {
      this.state = Constants.PLAYING;
    } else if (this.state === Constants.GAMEOVER) {
      this.settings.send({type: 'start', game_index: this.gameIndex});
    }
  }

  if (this.state === Constants.PLAYING &&
      this.block !== null &&
      this.preview.length > 0) {
    this.maybeSaveMove(keys);
    var syncIndex = this.syncIndex;

    this.frame = (this.frame + 1) % Constants.MAXFRAME;
    this.graphics.eraseBlock(this.block);
    this.update(keys);
    this.graphics.drawBlock(this.block);

    if (this.syncIndex > syncIndex) {
      assert(this.syncIndex === syncIndex + 1, 'Skipped a sync index!');
      this.moveQueue.push({syncIndex: this.syncIndex, move: this.move});
      this.settings.send({
        type: 'move',
        game_index: this.gameIndex,
        move_queue: this.moveQueue,
      });
      this.move = [];
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
    this.move.push(move);
  }
}

ClientBoard.prototype.nextBlock = function(swap) {
  this.syncIndex += 1;
  return ClientBoard.__super__.nextBlock.bind(this)(swap);
}

ClientBoard.prototype.maybeAddToPreview = function() {
  // A client board never adds pieces to the preview based on local state.
  // Instead, the server sends a state update with a new preview that replaces
  // the old one.
  this.blockIndex += 1;
}

ClientBoard.prototype.updateSettings = function(settings) {
  this.settings = this.graphics.settings = settings;
  this.repeater.setKeyBindings(settings.options.key_bindings);
}

ClientBoard.prototype.deserialize = function(view) {
  if (this.gameIndex !== view.gameIndex || this.syncIndex < view.syncIndex) {
    this.resetForView(view);
  } else {
    // Pull preview data out of the view and update the current state. Note
    // that we could have pulled blocks from the preview since the server sent
    // it, so we have to shift this blocks first.
    this.preview = view.preview.slice();
    for (var i = view.blockIndex; i < this.blockIndex; i++) {
      this.preview.shift();
    }
    while (this.serverSyncIndex < view.syncIndex) {
      this.serverSyncIndex += 1;
      this.moveQueue.pop();
    }
    // Pull attack data out of the view and update the current state.
    this.attacks = view.attacks;
    this.attackIndex = view.attackIndex;
  }
}

return ClientBoard;
})();

var OpponentBoard = (function() {
"use strict";

var OpponentBoard = function(target, view, settings, scale) {
  this.target = target;
  this.settings = settings;
  var squareWidth = Math.round(scale*Constants.SQUAREWIDTH);
  this.graphics = new Graphics(squareWidth, target, settings);
  this.deserialize(view);
}

OpponentBoard.prototype.deserialize = function(view) {
  if (this.gameIndex === view.gameIndex && this.syncIndex === view.syncIndex) {
    // Even if the opponent has made a move, if they've been attacked, we have
    // to update their UI. We check the two conditions that can occur:
    if (!maybeArraysEqual(this.attacks, view.attacks) ||
        this.attackIndex !== view.attackIndex) {
      $.extend(this, view);
      this.graphics.drawUI(this);
      this.graphics.flip();
    }
    return;
  }
  $.extend(this, view);
  // Delete the blockType property and construct a block of that type instead.
  delete this.blockType;
  this.block = new Block(view.blockType);
  this.block.rowsFree = Physics.calculateRowsFree(this.block, this.data);
  this.graphics.reset(this);
}

OpponentBoard.prototype.set_scale = function(scale) {
  this.target.empty();
  var squareWidth = Math.round(scale*Constants.SQUAREWIDTH);
  this.graphics = new Graphics(squareWidth, this.target, this.settings);
  this.graphics.reset(this);
}

return OpponentBoard;
})();

var ServerBoard = (function() {
"use strict";

var ServerBoard = function(settings, seed) {
  this.settings = settings;
  this.gameIndex = -1;
  ServerBoard.__super__.constructor.bind(this)(seed);
}

extend(ServerBoard, Board);

ServerBoard.prototype.reset = function(seed) {
  if (this.settings.game_type === 'battle') {
    this.attacks = [];
    this.attackIndex = 0;
  }
  ServerBoard.__super__.reset.bind(this)(new MersenneTwister(seed));
  this.pauseReason = undefined;
  this.forceClientUpdate();
}

ServerBoard.prototype.nextBlock = function(swap) {
  this.syncIndex += 1;
  return ServerBoard.__super__.nextBlock.bind(this)(swap);
}

ServerBoard.prototype.forceClientUpdate = function() {
  this.gameIndex += 1;
  this.syncIndex = 0;
}

ServerBoard.prototype.serialize = function() {
  return {
    data: this.data,
    blockType: this.block.type,
    gameIndex: this.gameIndex,
    syncIndex: this.syncIndex,
    // The rest of the fields here are the precisely fields that are read
    // by a call to Graphics.drawUI.
    blockIndex: this.blockIndex,
    preview: this.preview,
    held: this.held,
    heldBlockType: this.heldBlockType,
    combo: this.combo,
    score: this.score,
    state: this.state,
    pauseReason: this.pauseReason,
    // State that is only present in battle-mode games.
    attacks: this.attacks,
    attackIndex: this.attackIndex,
  }
}

ServerBoard.prototype.updateScore = function(rows) {
  // Only used in battle mode to determine what kind of attack to hit the
  // opponent with. Cleared by the code that uses this state.
  this.last_rows_cleared = rows;
  ServerBoard.__super__.updateScore.bind(this)(rows);
}

ServerBoard.prototype.maybeAddToPreview = function() {
  this.blockIndex += 1;
  var attackIndex = this.attackIndex || 0;
  var level = DifficultyCurve.getLevel(attackIndex + this.blockIndex);
  if (this.settings.game_type === 'battle' && this.attacks.length > 0) {
    // Pop from the attack queue if it is available.
    level = Math.min(level + this.attacks.shift() + 1, Block.LEVELS - 1);
  }
  this.preview.push(this.curve.generateBlockType(level));
}

ServerBoard.prototype.handleAttack = function(opponent) {
  // Handle an attack coming from the opponent.
  if (!opponent.last_rows_cleared) {
    return;
  }
  this.attacks.push(opponent.last_rows_cleared - 1);
  var poison_damage = opponent.combo + 1;
  // Apply poison damage, which permanently affects the opponent's difficulty.
  this.attackIndex += poison_damage;
  for (var i = 0; i < poison_damage; i++) {
    // Use up randomness so we stay in sync with the opponent's board.
    // However, one unit of randomness will be used to generate the new
    // attack block, which is why we subtract one.
    this.curve.rng.random();
  }
  opponent.last_rows_cleared = undefined;
}

return ServerBoard;
})();

this.combinos.Constants = Constants;
this.combinos.Options = Options;
this.combinos.ClientBoard = ClientBoard;
this.combinos.OpponentBoard = OpponentBoard;
this.combinos.ServerBoard = ServerBoard;

if (Meteor.isClient) {
  Meteor.startup(function() {
    initialize_move_library();
  });
}
